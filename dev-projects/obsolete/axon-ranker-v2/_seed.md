# axon-ranker-v2 — Seed Audit

slug:            _seed
schema-version:  v4
authored:        2026-05-19
predecessor:     axon-autoimprove
seed-source:     phases/4-validation/01-residual-triage.md (axon-autoimprove)

## Why this project exists

`axon-autoimprove` shipped a complete loop-receipt substrate for every auto-actor write (PR-AUTO-201..204), then declared the ranker work out-of-scope. That decision was correct — the substrate is general-purpose; the ranker is a specific application — but it left one open flaw (**FA-19**) that requires its own design pass.

## Inherited flaw — FA-19

From `axon-autoimprove/phases/1-study/02-deep-audit.md`:

> Auto-tune is one-way ratchet; second daily ratchet inside dispatch.py uses a different cap (B-06)

Two ratchets in the codebase:

1. `tools/dispatch.py` — `feedback` action's auto-tune block (PR-014, refactored under loop-receipt in PR-AUTO-204). Adjusts `preferences/smart-dispatch.md::dispatch-confidence` upward when last-20 dispatches show > 30% negative rate. Cap = 0.9. Never goes down.
2. `tools/synapse_suggest.py` — score-floor auto-tune (PR-AUTO-110 era). Adjusts ranker score floor upward when too many fallbacks fire. Different cap, no shared state with #1.

The substrate's job is **done** — PR-AUTO-204 wrapped both writes in `loop_receipt(intent='tune-threshold')`. Every adjustment is now a paired receipt row. What's missing:

- **Bidirectional control**: thresholds must be able to come down when negative-feedback rate drops below a low-water mark.
- **Single source of truth**: dispatch and synapse-suggest should share a controller surface; today they're independent monotonic counters.
- **Visible state**: SELF-OBSERVE has no row exposing "current threshold · last tune ts · last-N negative rate · cap/floor headroom".
- **Per-program accounting**: a single "bad day" for one program shouldn't drag down the global threshold.

## Inherited substrate (already merged in axon-autoimprove)

- `tools/loop_receipt.py` (PR-AUTO-201) — receipt ledger.
- `tools/_loop_receipt_ctx.py` — context-manager wrapper.
- `loop_receipt(intent='tune-threshold', target_kind='file')` — the call-site contract used by PR-AUTO-204's dispatch auto-tune. Reusable verbatim.
- `tests/test_loop_receipt_fault_injection.py` (PR-AUTO-301) — fault-injection harness proves the substrate is sound under SIGKILL.

## Phase-1 study leads (not yet executed)

- Compare current real-world `dispatch-feedback.jsonl` traces against synthetic positive-streak scenarios — does the threshold *ever* approach its cap in production data?
- Survey controller designs in the literature: PID, EWMA-with-thresholds, multi-armed-bandit (Thompson sampling) for the per-program variant.
- Build a one-shot simulator that replays historical feedback against candidate control laws and reports settling time + steady-state error.

## Out of scope

- Replacing TF-IDF cosine similarity with embeddings (different problem domain).
- Cross-program transfer learning (e.g. "if `find-program` is conservative, `menu` should be too").

## Adjacent open flaws to watch

- **FA-19** is the explicit driver, but the work likely touches:
  - **D-DISC-4** (ranker invisible to user) — SELF-OBSERVE row falls out for free.
  - **B-09** (dispatch threshold not surfaced anywhere) — same fix.

## Entry condition

Start phase-1 study when:
1. `axon-autoimprove` reaches `_closure.md` (so no in-flight contention on `tools/dispatch.py`).
2. Three weeks of real `dispatch-feedback.jsonl` traces accumulate (so phase-1 has lived data to study).

Until then: status `proposed`.
