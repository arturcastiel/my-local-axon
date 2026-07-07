# Phase 5 — wave-e-metric-pipeline

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-07

## 1. Envelope
- **Phase number**: 5
- **Slug**: `wave-e-metric-pipeline`
- **Owner**: AXON Bugfix 02
- **Target window**: TBD
- **PR count**: 2

## 2. Why this phase
> Executes the owner-locked D2: the starved metric pipeline stops emitting plausible zeros and states
> its real condition; loop-contract receipts start landing where their readers look. Phase boundary:
> this is descope-and-honesty work, deliberately separated from defect repair.

## 3. PRs in this phase
| PR     | title                                            | est-complexity | depends-on |
|--------|--------------------------------------------------|----------------|------------|
| PR-016 | Metrics ADR + honest-starvation banners (D2)     | M              | none       |
| PR-017 | loop-contract: receipts to the canonical ledger  | M              | none       |

## 4. MUST vs NICE
**MUST (in-scope)**:
- ADR-001 records the descope + the kernel-protocol alternative (owner-only future work)
- dispatch-stats states missing inputs explicitly; loop-contract rows land canonical + terminal
**NICE (deferred if budget tight)**:
- goal cross-registration verification loop in loop-contract define

## 5. Entry gate
- None beyond plan approval (independent of waves B–D)

## 6. Exit gate
- A live loop-contract define/iterate writes canonical, committed receipts; dispatch-stats banner verified

## 7. Phase-local risks
| risk                                        | likelihood | mitigation                              |
|---------------------------------------------|------------|------------------------------------------|
| Canonical-path routing breaks isolated runs | low        | mirror the sibling tools' canonical→None guard |

## 8. Iteration log
- 2026-07-07 — phase file rendered; D2 locked HONEST-DESCOPE by owner
