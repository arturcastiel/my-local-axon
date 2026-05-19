# Phase 4 — Validation (axon-autoimprove)

slug:            4-validation
schema-version:  v4
status:          active
goal:            Prove the phase-3 loop-receipt substrate actually closes FA-18 under fault injection; triage the residual phase-3-exit flaws (FA-19/20/21/23) to either spawn a follow-on project or defer with explicit tickets.
opened:          2026-05-19

## Inputs

- `../3-build/_closure.md` — phase-3 hand-off (4 PRs merged, 1 cooldown-pending).
- `../1-study/02-deep-audit.md` — original flaw inventory (FA-1 .. FA-23).
- `../2-design/specs/loop-receipt-v1.md` — substrate spec; defines the boot-recovery contract we now validate.

## PR queue

| PR              | Scope                                                                       | Status       |
|-----------------|-----------------------------------------------------------------------------|--------------|
| **PR-AUTO-301** | Fault-injection harness for loop-receipt: process-kill mid-`atomic_append`, simulated crash between begin/commit, `recover()` correctness under truncated ledger. Closes FA-18 with a real proof. | ⬜ next       |
| **PR-AUTO-302** | Residual-flaw triage doc. Decide for each of FA-19 / FA-20 / FA-21 / FA-23: spawn `axon-autoimprove-v2` spinout, fold into an in-project phase-5, or close as won't-fix. Output is a single decision table + spinout project skeletons if needed. | ⬜ pending    |
| PR-AUTO-211     | Companion menu surface for `usage find-program` (carried from phase-3).     | ⬜ cooldown   |

## Validation invariants

- **R5 / no fabrication**: fault-injection tests run under `pytest` (no kernel R9 violation — the chokepoint is patched into `tmp_ws/state/`). Process-kill simulation uses `os.kill(pid, SIGKILL)` against a subprocess that holds an open file handle on a sentinel atomic-append target.
- **R9**: ledger writes still flow through `_R9_WHITELIST = {"loop-receipt"}` per PR-AUTO-201; phase-4 introduces no new whitelist entries.
- **Coverage**: phase-4 adds **no new production code** — only test harness + a docs PR. If a test reveals a substrate bug, it gets its own PR-AUTO-303 with a regression test attached.

## Exit criteria

- PR-AUTO-301 merged: ≥6 fault-injection scenarios pass, recover() proven correct under each.
- PR-AUTO-302 merged: each residual flaw has a documented disposition (spinout / phase-5 / won't-fix) with a linked ticket where applicable.
- PR-AUTO-211 merged (cooldown elapsed).

## On exit

→ write `dev-projects/axon-autoimprove/_closure.md` and bump project `_meta.md` status → CLOSED.
→ if PR-302's triage spawned `axon-autoimprove-v2`, that project's `_meta.md` is the immediate successor.
