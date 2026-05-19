# Phase 2 — Design (axon-autoimprove)

slug:            2-design
schema-version:  v4
status:          active
goal:            Author the 7 specs identified in `../1-study/_closure.md` § "Phase-2 entry brief". Each spec defines a contract — not an implementation. Phase 3 turns specs into PRs.
opened:          2026-05-19

## Inputs

- `../1-study/_closure.md` — phase-1 hand-off (7 specs + 3 spinout proposals + 4 decisions).
- `../1-study/02-deep-audit.md` — 21 bug candidates + new-tool recommendation (`loop-receipt`).
- `../1-study/03-synapse-retro.md` — original synapse goal scorecard (10 acceptance items).
- `../1-study/04-discoverability.md` — menu-coverage gap (closed in part by Menu PR-A).
- `../../_flaws.md` — 34-row open/spec-fixed ledger.
- `../../_demands.md` — D-A01..D-A30 + D-DISC-1..D-DISC-5.

## Spec queue

| # | Spec file                                | Closes                                            | Status |
|---|------------------------------------------|---------------------------------------------------|--------|
| 1 | `specs/loop-receipt-v1.md`               | B-04, B-06, B-07, B-14, B-20, FA-12, D-A25        | drafting |
| 2 | `specs/io-chokepoint-v1.md`              | FA-15, D-A21, D-AUTO-003                          | pending |
| 3 | `specs/cron-circuit-breaker-v1.md`       | FA-13, FA-24, D-A22                               | pending |
| 4 | `specs/drift-fail-closed-v1.md`          | FA-14, D-A23                                      | pending |
| 5 | `specs/predicate-evaluator-wiring-v1.md` | FA-17, D-A26                                      | pending |
| 6 | `specs/r-tool-call-exists-v1.md`         | FA-16, D-A27, D-AUTO-004                          | pending |
| 7 | `specs/usage-find-program-v1.md`         | Synapse AC #10, D-DISC-4                          | pending |

## Exit criteria

- All 7 specs land. Each spec lists: Purpose, Contract, Storage, API, Closes/Resolves, Integration, Test plan, Open questions.
- `code-dev plan` ready to fire with one row per spec → phase-3 PR-AUTO-201..207.
- Decisions D-AUTO-002, D-AUTO-003, D-AUTO-004 resolved or escalated.
