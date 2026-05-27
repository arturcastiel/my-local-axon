# Phase 3 — Build — CLOSURE

slug:            3-build
schema-version:  v4
status:          CLOSED
opened:          2026-05-19
closed:          2026-05-19
predecessor:    `phases/2-design/_closure.md`
successor:      `phases/4-validation/_meta.md` (to be created)

---

## Scorecard

Substrate-migration sub-phase complete. The single largest phase-2 spec
(`loop-receipt-v1.md` — the two-phase-commit receipt ledger) shipped as
**four merged PRs** that landed the tool itself and migrated every known
state-mutating auto-actor write onto it.

| #  | PR              | Scope                                                       | Merged on `main`            | Net new LOC* |
|----|-----------------|-------------------------------------------------------------|-----------------------------|--------------|
| 1  | **PR-AUTO-201** | `tools/loop_receipt.py` + `_loop_receipt_ctx.py` + `_axon_io.atomic_append` + R9 whitelist + `REGISTRY.json` | axon#25 → `main`            | +700 / +280  |
| 2  | **PR-AUTO-202** | `tools/auto_improve.py` — wrap `auto_tune` / `auto_archive` / `auto_compile` writes onto loop-receipt | axon#26 → `main`            | +107 / +199  |
| 3  | **PR-AUTO-203** | `tools/auto_audit.py` — wrap `append_row` onto loop-receipt with per-actor trigger-source map | axon#27 → `main`            | +58 / +149   |
| 4  | **PR-AUTO-204** | `tools/igap.py` + `tools/dispatch.py` — wrap 5 writes (igap log + igap counter + dispatch feedback + dispatch correlate + dispatch auto-tune) | axon#28 → `main`            | +136 / +167  |
| 5  | PR-AUTO-211     | Companion menu surface for `usage find-program`             | — pending (cooldown +7 d)   | spec only    |

\* LOC = code / tests, hand-counted.

**Loop-receipt substrate now serves every auto-actor write in the codebase.**
Every BEGUN row is paired with exactly one terminal row (COMMITTED |
ABORTED | ROLLED-BACK). Boot-time `recover()` reaps orphaned BEGUNs.

## Delta vs phase-2 entry brief

| Phase-2 prediction                                         | Actual                                                              |
|------------------------------------------------------------|---------------------------------------------------------------------|
| 4 PRs to ship the spec end-to-end (201..204)               | 4 PRs ✓                                                              |
| ~520 LOC for the tool itself                               | ~700 LOC (added: 9th subcommand `recover` + boot-recovery semantics) |
| Three writer migrations (auto_improve, auto_audit, igap+dispatch) | Three migrations ✓ — but `dispatch` ended up with **3** writes (feedback + correlate + auto-tune-threshold), not 1 as predicted |
| Per-actor trigger-source mapping was vague                 | Locked: `_ACTOR_TO_TRIGGER` total map for `auto_audit`; `(dispatch, ...)` for dispatch.py; `(manual-user, ...)` for igap; per-actor for auto_improve |
| Test fixture would be straightforward                      | One round of debugging: `importlib.reload` fixture (PR-202 first draft) polluted other tests in the same session → switched to direct `monkeypatch.setattr` on module-level path constants |

## Flaws closed this phase

- **FA-12** (atomic-write tearable inside auto-actors) — substantively closed by substrate; **validation deferred to phase-4** (FA-18 follow-on)
- **B-04** (audit-row receipts) — closed by PR-203
- **B-06** (dispatch-feedback receipts) — closed by PR-204
- **B-07** (auto-improve receipts) — closed by PR-202
- **B-14** (igap log receipts) — closed by PR-204
- **B-20** (auto-compile failure auditability) — closed by PR-202

## Residual flaws routed forward

| Flaw  | Disposition                                                                 |
|-------|------------------------------------------------------------------------------|
| FA-18 | Validation pending — phase-4 fault-injection harness proves boot-recovery     |
| FA-19 | Design fix (dispatch dual-ratchet) — follow-on project                       |
| FA-20 | Kernel-program ASSERT for D-A02/D-A17 — follow-on project                    |
| FA-21 | Archive rate-limit — follow-on project                                       |
| FA-22 | Already spun out as `axon-coherence-v2` (not this project's scope)           |
| FA-23 | Synapse-validate neuron-existence — follow-on project                        |

## Lessons

1. **Backward-compat by kwargs default.** PR-203 (`append_row(path, row, *, workspace=None, actor=None)`) and PR-204 (`_receipt_workspace(workspace)` helper added per-tool) both kept their pre-existing 8/8 + 12/12 regression suites green without touching them. Pattern: when adding a side-effect to a leaf function, add the new context as keyword-only with sane defaults; never reshape the positional signature.
2. **Test isolation via monkeypatch beats reload.** First draft of PR-202 used `importlib.reload(_axon_paths, _axon_io, loop_receipt, _loop_receipt_ctx, auto_improve)` to pick up a tmp `AXON_ROOT` — this polluted six other tests in the same session because reload's effects persist past the test scope. Switched to `monkeypatch.setattr(module, "AXON_DIR", tmp)` directly. Lesson: reload is a wrecking ball; if a fixture needs to isolate path constants, patch the constants.
3. **`_receipt_workspace()` is the right boundary.** Production callers use the canonical workspace → ledger goes to `AXON_DIR/state/`. Test/isolated workspaces → ledger lands at `<workspace>/state/`. The same 4-line helper now appears in `auto_audit`, `igap`, and `dispatch`. Could be lifted to `loop_receipt` itself as `_lr.resolve_ledger_workspace(ws)` if more callers appear — phase-4 candidate refactor.
4. **Closed-set vocabularies pay off at every wrap-site.** Every PR was a 3-line decision: pick an intent, a target_kind, and a trigger source. Zero negotiation, zero invention. The locked set from PR-201 (7 intents · 4 target kinds · 5 trigger sources) covered every call site without extension.

## Exit criteria — status

- [x] All 4 substrate-migration PRs merged.
- [x] All 3 known atomicity-violating writers using the new substrate.
- [x] Hermetic test classes covering: begin/commit, begin/rollback, begin/abort, double-commit guard, boot recovery from orphaned BEGUN, ledger gc, context-manager exception → auto-abort.
- [ ] PR-AUTO-211 lands once 7-day cooldown elapses (independent timing — does NOT block phase-4 entry).

## Phase-4 entry brief

**Scope:** validation-only. Two PRs:

1. **PR-AUTO-301** — fault-injection harness for loop-receipt. Process-kill mid-`atomic_append`, simulated crash between begin and commit, recover() correctness under truncated/torn ledger. Proves FA-18 is actually closed under the substrate.
2. **PR-AUTO-302** — residual-flaw triage. Formally route FA-19, FA-20, FA-21, FA-23 to either `axon-autoimprove-v2` follow-on project or fold them into the existing closure as deferred-with-tickets. Decide once-and-for-all whether `axon-autoimprove` is done.

PR-AUTO-211 lands when its cooldown elapses (independent of phase-4 progress).

After phase-4 closes → project closure (`dev-projects/axon-autoimprove/_closure.md`)
or a small phase-5 if the triage in PR-302 says so.
