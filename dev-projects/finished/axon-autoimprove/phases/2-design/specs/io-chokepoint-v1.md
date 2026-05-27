# IO Chokepoint Spec (v1)

> glossary: AXON-GLOSSARY v2
> closes:   FA-15 (R9 doc-only at code level — only 2 of ~50 writers call `enforce.py`)
> resolves: D-AUTO-003 (R9 enforcement at IO chokepoint vs per-caller — **chokepoint chosen**)
> serves:   D-A21 (R9 at the IO chokepoint, not at the program)
> sibling:  `loop-receipt-v1.md` (whose ledger writes pass through this chokepoint)

## Purpose

Move R9 enforcement from a tool every caller *should* invoke (`enforce.py
check-write`) — but in practice almost none does — to a helper every caller
*must* go through to write at all. The chokepoint is `tools/_axon_io.atomic_write`,
already imported by 15 tools and already the canonical "atomic file write" path.

If a write to a path under `AXON_ROOT/axon/` reaches `atomic_write` and
`L:dev-mode ≠ true`, it raises `R9WriteError`. No bypass other than enabling
dev-mode OR using the explicit `_actor=` whitelist (reserved for auto-improve
once `loop-receipt-v1` lands).

## Non-goals

- NOT replacing `tools/enforce.py`. That tool stays as the CLI gate used by
  shell-script callers and as the source-of-truth for the R9 rule.
  `_axon_io` becomes a second, in-process enforcement point — defence in
  depth, not replacement.
- NOT enforcing R9 on `os.open`, `open(...).write()`, or `Path.write_text`.
  Those still bypass — but no AXON tool *should* use them for `axon/` paths,
  and the linter (`r-tool-call-exists-v1` sibling) gains a rule to flag them.
- NOT a sandbox. A determined caller can `subprocess.run(["echo", "...", ">",
  "axon/whatever.md"])`. The chokepoint is defence against accident, not malice.

## Contract — `tools/_axon_io.py` v1.1

### New exception

```python
class R9WriteError(PermissionError):
    """Raised when a write to AXON_ROOT/axon/* is attempted with L:dev-mode != true."""
    def __init__(self, target: Path, actor: str | None = None):
        self.target = target
        self.actor  = actor
        super().__init__(
            f"R9 gate: write to {target} requires L:dev-mode=true "
            f"(actor={actor or 'unset'}). "
            f"Enable: python3 tools/memory.py set --scope L --key dev-mode --value true"
        )
```

### Helpers

```python
_AXON_DIR    = AXON_ROOT / "axon"          # from _axon_paths
_DEVMODE_KEY = MYAXON_ROOT / "memory" / "longterm" / "dev-mode.md"

def _is_axon_path(path: Path) -> bool:
    """True iff path resolves under AXON_ROOT/axon/."""
    try:
        path.resolve().relative_to(_AXON_DIR.resolve())
        return True
    except (ValueError, OSError):
        return False

def _dev_mode_active() -> bool:
    """Read L:dev-mode from my-axon/memory/longterm/dev-mode.md.

    Returns False if file is missing or unparseable. Same format as enforce.py:
    a 'value: true' line, otherwise the file's stripped contents.
    """
    if not _DEVMODE_KEY.exists():
        return False
    try:
        for line in _DEVMODE_KEY.read_text(encoding="utf-8").splitlines():
            if line.startswith("value:"):
                return line.split(":", 1)[1].strip() == "true"
        return _DEVMODE_KEY.read_text(encoding="utf-8").strip() == "true"
    except OSError:
        return False
```

### Modified signature

```python
def atomic_write(
    path: Union[str, Path],
    content: str,
    *,
    encoding: str = "utf-8",
    _actor: str | None = None,     # reserved for auto-improve via loop-receipt
) -> None:
    """Atomic write with R9 enforcement.

    Steps:
      0. NEW: R9 gate — raise R9WriteError if path is under AXON_ROOT/axon/
         and L:dev-mode != true, unless _actor is in the whitelist.
      1. Ensure parent dir exists.
      2. ... (unchanged)
    """
    p = Path(path)
    if _is_axon_path(p) and not _dev_mode_active() and _actor not in _R9_WHITELIST:
        raise R9WriteError(p, actor=_actor)
    # ... existing implementation unchanged
```

`_R9_WHITELIST = frozenset()` in v1 — empty. v1.1 lands the auto-improve
entry once `loop-receipt-v1` ships and proves the wrapper logic.

### `atomic_write_json` inherits the gate

No code change needed — it delegates to `atomic_write`.

## API stability

- Default-arg `_actor=None` ⇒ all 15 existing callers continue to work
  unchanged for non-`axon/` paths.
- For callers that DO write to `axon/` (currently a small minority — manual
  audit identifies 2 known: `migrate_meta.py` for kernel docs, `pr_export.py`
  potentially), behaviour changes from "silent write" to "R9WriteError unless
  dev-mode". This is THE intended change (closes FA-15).
- Underscore prefix on `_actor` signals "internal, do not pass from arbitrary
  callers". Future contract: only `tools/_loop_receipt_ctx.py` is allowed to
  pass `_actor=`.

## Test plan — `tests/test_axon_io_r9.py`

| Test                          | Setup                                         | Asserts |
|-------------------------------|-----------------------------------------------|---------|
| `test_write_outside_axon_ok`  | path = tmp_path / "x.md", dev-mode = false   | succeeds |
| `test_write_inside_axon_blocked` | path = AXON_DIR / "synthetic-test.md" (file in axon/ but actually written to fixture), dev-mode = false | raises `R9WriteError`, no file created |
| `test_write_inside_axon_dev_mode_ok` | same, dev-mode = true                | succeeds |
| `test_actor_whitelist_empty_in_v1` | `_actor="auto-improve"`, dev-mode=false | raises `R9WriteError` (whitelist empty in v1) |
| `test_error_message_actionable` | check `R9WriteError` message contains `memory.py set --scope L --key dev-mode --value true` | passes |
| `test_atomic_write_json_inherits_gate` | `atomic_write_json(AXON_DIR / "x.json", {})` | raises `R9WriteError` |

Test isolation: the `AXON_DIR` synthetic-path tests **patch** `_DEVMODE_KEY`
to a tmp file the test controls, so they don't depend on the real
my-axon/memory state. Tests also use `monkeypatch.setattr` to redirect
`_AXON_DIR` to a temp dir for the "would write but blocked" branch — so no
real file under `axon/` is ever touched.

## Phase-3 PR mapping

| PR slug          | Scope |
|------------------|-------|
| **PR-AUTO-205**  | This spec, fully implemented: `_axon_io.py` v1.1 + `tests/test_axon_io_r9.py`. The chokepoint ships dark — no callers change behaviour because nobody writes to `axon/` in normal flow. |
| PR-AUTO-206      | Audit the 15 `atomic_write` callers + identify which actually emit `axon/` paths. Migrate any that need dev-mode-aware paths (likely zero — `axon/` is kernel-immutable in normal ops). |
| PR-AUTO-207      | Add `r_no_raw_axon_write.py` to `tools/rules/` — lint catches `open("axon/...", "w")` and `Path("axon/...").write_text(...)` patterns. |
| (with loop-receipt) | Add `auto-improve` to `_R9_WHITELIST` once `_loop_receipt_ctx` is the ONLY caller passing `_actor=`. |

## Closes / resolves — receipt for the receipts

| Bug / demand | Closes via |
|--------------|------------|
| FA-15 | `_axon_io.atomic_write` now raises `R9WriteError` for `axon/` writes when dev-mode is off. Defence-in-depth on top of `enforce.py`. |
| D-AUTO-003 | Resolved: **chokepoint chosen** over per-caller. Rationale: 15 callers already use atomic_write; adding `enforce.py check-write` to each is more code, more drift surface, easier to forget. |
| D-A21 | "R9 at the IO chokepoint, not at the program" — direct quote, direct delivery. |

## Risks / open questions

| ID  | Concern | Disposition |
|-----|---------|-------------|
| R-1 | A tool legitimately needs to write to `axon/` outside dev-mode (e.g. boot bootstrap writing `axon/state/boot-receipt.json`) | Boot recovery path is the canonical example — addressed by `loop-receipt-v1` § Recovery, which writes through the wrapper that sets `_actor="auto-improve"`. v1.1 whitelist lands then. |
| R-2 | `_is_axon_path` resolves symlinks via `Path.resolve()` — a symlink at `my-axon/foo` pointing into `axon/` would now be blocked | Acceptable: that symlink was a footgun anyway. Document in v1 spec § Non-goals if it bites. |
| R-3 | Performance — every `atomic_write` now reads `dev-mode.md` from disk | Mitigation: cache `_dev_mode_active()` result for 1 second in module-level dict. Cache invalidation = `_dev_mode_invalidate()` for tests. v1.1 if profiling shows it matters; v1 ships without cache (the file is tiny, 1-2 reads per second worst case). |
| Q-1 | Should `enforce.py check-write` also check via `_axon_io._is_axon_path` for consistency? | Yes, refactor `enforce.py` to import `_is_axon_path` so the two enforcement points share the same path-classification logic. Land in PR-AUTO-205. |
| Q-2 | What if `MYAXON_ROOT` is unset (no my-axon checkout)? | `_DEVMODE_KEY.exists()` returns False → `_dev_mode_active()` returns False → `axon/` writes blocked. Matches expected behaviour: dev-mode requires user data to declare it. |

## Hand-off

- This spec is INPUT for the corresponding phase-3 PR-AUTO-205 (lands the
  chokepoint dark). PR-AUTO-205 is independent of `loop-receipt-v1` PRs —
  can land first or in parallel.
- After PR-AUTO-205 merges, `_R9_WHITELIST` stays empty. The whitelist is
  populated only when `_loop_receipt_ctx` exists AND is the sole caller
  passing `_actor=`.

DONE(io-chokepoint-v1 · 2026-05-19)
