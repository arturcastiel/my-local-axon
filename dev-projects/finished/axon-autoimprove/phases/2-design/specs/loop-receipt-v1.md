# Loop-Receipt Spec (v1)

> glossary: AXON-GLOSSARY v2
> closes:   FA-12 (kv_store rollback gap), B-04 (tearable log appends), B-06 (double-ratchet in dispatch.py), B-07 (auto-tune cap drift), B-14 (auto_audit row tears), B-20 (auto-improve missing D-A02/D-A17 hooks)
> resolves: D-AUTO-001 (kv_store rollback substrate)
> serves:   D-A24 (atomic appends + fsync), D-A25 (kv_store rollback exists)
> sibling:  `io-chokepoint-v1.md` (which enforces R9 at the IO layer and CALLS loop-receipt for any auto-improve write)

## Purpose

Provide a single, durable, two-phase commit ledger that wraps every
**auto-improve-initiated state change** so any such change is:

1. **Inspectable before commit** — the receipt records intent + pre-image
   + planned post-image.
2. **Atomically committable** — commit is a single fsync'd write; partial
   writes are detected on next boot.
3. **Reversible after commit** — `loop-receipt rollback <id>` restores
   pre-image without re-deriving it.

Today (per FA-12 / `tools/kv_store.py`), there is **no rollback substrate**
for L:/W: writes performed by auto-improve. `tools/undo.py` covers
file-level snapshots but does not cover memory-keys. `tools/auto_audit.py`
emits a one-line ledger after the fact but does not snapshot pre-image.
Loop-receipt unifies these and is the substrate D-A25 declares.

## Non-goals

- NOT a general transaction manager for user-initiated edits — those keep
  using `undo.py` for files and direct `memory.py` for L:/W:.
- NOT a kernel primitive — pure tool-level. Kernel rules R1..R12 are
  unchanged.
- NOT a journaling FS — tears across multiple receipts are NOT prevented
  (each receipt is its own boundary).
- NOT a replacement for `auto_audit` — receipts feed auto_audit, they do
  not replace its weekly summary.

## Contract — receipt record

A single JSONL row at `axon/state/loop-receipt.ledger.jsonl` (write
gated by `io-chokepoint-v1`; reads are always allowed).

```json
{
  "id":         "lr-2026-05-19T08:14:22Z-7f3a",
  "actor":      "auto-improve",
  "intent":     "tune-threshold",
  "trigger":    {"source": "cron", "job": "auto-improve-daily", "tick": 412},
  "target": {
    "kind":   "L|W|file|jsonl-append",
    "scope":  "L",
    "key":    "synapse-suggest.score-floor",
    "path":   null
  },
  "pre":  {"value":  0.55, "checksum-sha256": "..."},
  "post": {"value":  0.50, "checksum-sha256": "..."},
  "rationale":  "auto-tune step -0.05 · capped by D-A20 daily-cap=1 · audit-7d-total=12",
  "phase":      "begun|committed|rolled-back|aborted",
  "begin-ts":   "2026-05-19T08:14:22Z",
  "commit-ts":  "2026-05-19T08:14:22Z",
  "actor-confirmed": false,
  "schema-version": "loop-receipt v1"
}
```

### Field rules

| Field            | Required at | Notes |
|------------------|-------------|-------|
| `id`             | begin       | `lr-{ISO8601Z}-{4-hex}`. Monotone per source-system clock. |
| `actor`          | begin       | Free-text but should match `tools/REGISTRY.json` tool name OR a program slug. |
| `intent`         | begin       | One of: `tune-threshold`, `promote-ephemeral`, `archive-cold`, `compile-pattern`, `auto-update-counter`, `kv-rollback-pre-image`. **Closed set v1.** Adding intents = v1.1. |
| `trigger.source` | begin       | One of: `cron`, `dispatch`, `manual-user`, `goal-met`, `drift-trigger`. |
| `target.kind`    | begin       | One of: `L`, `W`, `file`, `jsonl-append`. |
| `pre.checksum`   | begin       | sha256 of the **canonical** serialization (`json.dumps(..., sort_keys=True)` for L:/W:; raw bytes for `file`/`jsonl-append`). |
| `post.checksum`  | begin       | Same canonical-form rule. |
| `phase`          | mutates     | `begun` → `committed` xor `rolled-back` xor `aborted`. No re-open. |
| `actor-confirmed`| commit      | True iff the actor itself fsync'd successfully. False on synthetic recovery. |

### State machine

```
                    +-----------+
              begin |           |  commit  +-----------+
   (nothing)  ----> |   BEGUN   | -------> | COMMITTED | (terminal)
                    |           |          +-----------+
                    +-----------+
                          |
                          | rollback  +--------------+
                          +---------> | ROLLED-BACK  | (terminal)
                          |           +--------------+
                          |
                          | abort  +-----------+
                          +-----> |  ABORTED  | (terminal — never partially-applied)
                                  +-----------+
```

Allowed transitions are exhaustive. Boot recovery (§ "Recovery") promotes
any `BEGUN` row found at boot to `ABORTED` after verifying no partial
write landed.

## API — `tools/loop_receipt.py`

Subcommands, all stable in v1:

| Subcommand      | Args                                          | Returns                   | Side effect |
|-----------------|-----------------------------------------------|---------------------------|-------------|
| `begin`         | `--actor` `--intent` `--target-kind` `--scope` `--key` `--path` `--pre-json` `--post-json` `--rationale` `--trigger-source` | `{"id": "lr-..."}`        | Append BEGUN row, fsync. |
| `commit`        | `--id`                                        | `{"ok": true}`            | Replay-safe append of COMMITTED. Verify `post.checksum` matches current target value. |
| `rollback`      | `--id`                                        | `{"ok": true, "restored": <pre-value>}` | Write `pre.value` back to target via `io_chokepoint.atomic_write`. Append ROLLED-BACK. |
| `abort`         | `--id` `--reason`                             | `{"ok": true}`            | Mark ABORTED. Useful for dry-run + user-decline paths. |
| `show`          | `--id`                                        | full receipt record       | Read-only. |
| `list`          | `--actor` `--phase` `--since-days N` `--limit M` | array of receipts      | Read-only. |
| `verify`        | `--id`                                        | `{"ok": bool, "drift": ...}` | Recompute `post.checksum` against live state; flag if target was changed by something other than `commit` or a later receipt. |
| `gc`            | `--keep-days N` (default 90)                  | `{"removed": N}`          | Drop TERMINAL rows older than N days. BEGUN rows are NEVER GC'd. |

### Wrapper helper

For Python callers (auto_improve.py, etc.), a context-manager:

```python
from tools._loop_receipt_ctx import loop_receipt

with loop_receipt(actor="auto-improve",
                  intent="tune-threshold",
                  target_kind="L",
                  scope="L",
                  key="synapse-suggest.score-floor",
                  pre_value=0.55,
                  post_value=0.50,
                  rationale="auto-tune step -0.05",
                  trigger=("cron", "auto-improve-daily", tick)) as rcpt:
    memory.set(scope="L", key="synapse-suggest.score-floor", value=0.50)
    # rcpt.commit() called on clean __exit__
    # rcpt.abort(reason=...)   on exception
```

The wrapper guarantees one of {COMMITTED, ABORTED, BEGUN-then-recovery}.
**Never partially-applied** is the central invariant.

## Storage

| File                                              | Purpose                       | Write gate         |
|---------------------------------------------------|-------------------------------|--------------------|
| `axon/state/loop-receipt.ledger.jsonl`            | Append-only ledger            | `io-chokepoint-v1` (R9 routed) |
| `axon/state/loop-receipt.index.json`              | id → byte-offset map (rebuilt on boot if torn) | same |
| `axon/state/loop-receipt.tombstones.jsonl`        | GC'd ids (audit trail)        | same |

> **R9 implication**: the ledger lives under `axon/`, so writes require
> `L:dev-mode ≡ true`. **Resolution per D-A21 / io-chokepoint-v1**:
> auto-improve is the ONLY non-dev-mode caller permitted to bypass the
> R9 gate, and only via the chokepoint, which checks `actor == "auto-improve"`
> against a whitelist. Other actors (manual user, external tools) must
> enable dev-mode first OR write to a `my-axon/` mirror.

## Integration points

| Caller                                | Today                              | After loop-receipt |
|---------------------------------------|------------------------------------|--------------------|
| `tools/auto_improve.py:action_auto_tune` | direct `kv_store.set(...)`      | wrap in `loop_receipt(intent="tune-threshold")` |
| `tools/auto_improve.py:action_auto_promote` | direct write to neuron contract | wrap in `loop_receipt(intent="promote-ephemeral")` |
| `tools/auto_improve.py:action_auto_archive` | direct file moves               | wrap in `loop_receipt(intent="archive-cold")` |
| `tools/auto_audit.py` append          | append without fsync               | route through `loop_receipt.begin/commit` with `target.kind="jsonl-append"` |
| `tools/dispatch.py` daily-cap counter | second ratchet in `dispatch.py`    | **removed** — single counter lives behind `loop_receipt.list(intent="tune-threshold", since-days=1)` |

The dispatch.py second ratchet (B-06) is **deleted**, not replaced — the
ledger IS the cap source-of-truth. Closes B-06 + B-07 simultaneously.

## Recovery (boot path)

`tools/boot.py` (or whichever module runs `boot/health`) MUST call
`loop_receipt.recover()` early, which:

1. Reads the ledger tail (last 1 MB) into memory.
2. For each `BEGUN` row with no matching `COMMITTED`/`ROLLED-BACK`/`ABORTED`:
   a. Compute current checksum of `target`.
   b. If equals `pre.checksum` → write ABORTED row (no harm done).
   c. If equals `post.checksum` → write COMMITTED row (write succeeded but commit-marker was lost; harmless replay).
   d. Otherwise → write ABORTED row + emit `axon.loop-receipt.drift`
      event + surface in next menu render under `SELF-OBSERVE`.

Recovery is **idempotent** and **read-only with respect to the target**
in cases (a) and (c); only case (d) loses information (rare — implies a
third actor edited target between BEGUN and recovery).

## Closes / resolves — receipt for the receipts

| Bug / demand | Closes via |
|--------------|------------|
| FA-12 (kv_store rollback gap) | `loop-receipt rollback <id>` is the rollback substrate. |
| B-04 (tearable log appends) | All ledger writes are single-buffer-write + fsync. Other tearable logs (auto_audit, igap, dispatch-feedback) migrate to receipt-wrapped appends. |
| B-06 (dispatch double-ratchet) | Second ratchet removed; ledger is sole source-of-truth. |
| B-07 (auto-tune cap drift) | Cap enforced by counting `loop_receipt.list(intent="tune-threshold", since-days=1)`. |
| B-14 (auto_audit row tears) | auto_audit ROW writes routed through `loop_receipt.begin/commit` with intent="audit-row". |
| B-20 (auto-improve missing D-A02 / D-A17 hooks) | The receipt wrapper reads `L:auto-improve` (D-A02 opt-in) before BEGIN; emits `axon.idle-gap.confirm-required` if `L:last-user-input` older than D-A17 threshold. Both checks live in `_loop_receipt_ctx.py`, so every auto-improve write is gated uniformly. |
| D-AUTO-001 (kv_store rollback decision) | Resolved: extend kv_store is **rejected**; loop-receipt is the chosen substrate. kv_store stays a pure setter. |
| D-A24 (atomic appends + fsync) | All target.kind="jsonl-append" writes go through a `_axon_io.atomic_append(path, line, fsync=True)` helper called from the chokepoint. |
| D-A25 (kv_store rollback exists) | Receipt-based rollback restores any `pre.value` recorded at BEGIN. |

## Test plan (stub for phase-3)

| Test family | Cases | Tooling |
|-------------|-------|---------|
| Happy-path | BEGIN → COMMIT, BEGIN → ROLLBACK, BEGIN → ABORT | `pytest` (human-run) |
| Recovery | Kill between BEGIN and COMMIT × 3 target.kinds | injection helper `tests/_loop_receipt_kill.py` |
| Idempotency | Replay same COMMIT twice, same ROLLBACK twice | unit test |
| Concurrency | Two BEGIN against same target serialise via flock | integration test |
| Schema | Reject row missing required field; reject post-v1 schema-version mismatch | unit test |
| GC | Old TERMINAL rows pruned; BEGUN rows preserved | unit test |
| Drift detection | External edit between BEGIN and COMMIT detected by `verify` | unit test |

## Risks / open questions

| ID  | Concern | Disposition |
|-----|---------|-------------|
| R-1 | Ledger growth — high-frequency auto-tune fills disk | Mitigation: GC keep-days default 90; auto-improve daily-cap (D-A20) bounds rows/day. |
| R-2 | Clock skew across recovery boundary | Use monotone OS clock for `id` suffix; recovery does not rely on wall-clock ordering — uses byte order. |
| R-3 | `target.kind="W"` writes are also wanted by user-tools (e.g. menu setting suggestions-enabled) | v1: no. User-tools keep direct `memory.set`. Loop-receipt is auto-improve-only. v1.1 may relax. |
| R-4 | What if rollback itself fails mid-flight? | Rollback IS a write — itself receipted. Nested receipts allowed for `intent="kv-rollback-pre-image"`. Bounded depth = 1. |
| Q-1 | Should every drift-fail event re-run loop-receipt.verify on the last 100 receipts? | Defer to `drift-fail-closed-v1.md`. |
| Q-2 | Should menu surface unread-ledger count under SELF-OBSERVE? | Yes — adds row `loop-receipt — N recent (M rolled-back today)`. Wire in Menu PR-B (post phase-3 PR-201). |

## Phase-3 PR mapping

| PR slug         | Scope |
|-----------------|-------|
| **PR-AUTO-201** | New `tools/loop_receipt.py` + `tools/_loop_receipt_ctx.py` + ledger storage. Stand-alone, no auto-improve integration yet. Includes recovery + tests. |
| PR-AUTO-202     | Migrate `auto_improve.action_auto_tune` to receipt wrapper. Delete dispatch.py second ratchet (B-06). |
| PR-AUTO-203     | Migrate `auto_improve.action_auto_promote` + `action_auto_archive`. |
| PR-AUTO-204     | Migrate `auto_audit` row append. Migrate `igap` + `dispatch-feedback` appends. |
| (later)         | Menu SELF-OBSERVE row for loop-receipt (Menu PR-B). |

## Hand-off

- This spec is INPUT for the corresponding `io-chokepoint-v1.md` (which
  defines the R9 gate that loop-receipt's writes pass through) and for
  `cron-circuit-breaker-v1.md` (which uses receipts to bound auto-tune
  per tick).
- Phase-3 entry: PR-AUTO-201 is the FIRST PR. All subsequent
  auto-improve work depends on this substrate.

DONE(loop-receipt-v1 · 2026-05-19)
