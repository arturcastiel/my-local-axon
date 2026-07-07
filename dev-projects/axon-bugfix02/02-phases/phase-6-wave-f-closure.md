# Phase 6 — wave-f-closure

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-07

## 1. Envelope
- **Phase number**: 6
- **Slug**: `wave-f-closure`
- **Owner**: AXON Bugfix 02
- **Target window**: TBD
- **PR count**: 2

## 2. Why this phase
> Closes the project: the LOW/doc-honesty sweep, conversion of the study's could-not-verify list into
> real end-to-end tests against the post-fix contracts, and the ratchet flip — both new lints become
> blocking crucible gates once their baselines are empty. Phase boundary: nothing here may land before
> the contracts it tests have stabilized.

## 3. PRs in this phase
| PR     | title                                              | est-complexity | depends-on                         |
|--------|----------------------------------------------------|----------------|-------------------------------------|
| PR-018 | LOW / doc-honesty sweep                            | M              | none                                |
| PR-019 | Mutating-path tests + crucible registration        | L              | PR-002, PR-009, PR-012, PR-017      |

## 4. MUST vs NICE
**MUST (in-scope)**:
- Every could-not-verify item from the study is either test-verified or explicitly re-declared
- Both lints registered blocking in crucible with empty baselines
**NICE (deferred if budget tight)**:
- synapse inputs/outputs-count refresh (stays flagged-LOW if convention remains undefined)

## 5. Entry gate
- Waves A–E merged; both lint baselines empty (or residual entries explicitly owner-accepted)

## 6. Exit gate
- Full pytest suite green with both gates blocking; 05-audit.md can begin

## 7. Phase-local risks
| risk                                            | likelihood | mitigation                             |
|-------------------------------------------------|------------|-----------------------------------------|
| Ratchet flip blocks unrelated in-flight work    | low        | flip last, after baselines verified empty |

## 8. Iteration log
- 2026-07-07 — phase file rendered
