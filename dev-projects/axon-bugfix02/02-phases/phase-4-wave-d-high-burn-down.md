# Phase 4 — wave-d-high-burn-down

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-07

## 1. Envelope
- **Phase number**: 4
- **Slug**: `wave-d-high-burn-down`
- **Owner**: AXON Bugfix 02
- **Target window**: TBD
- **PR count**: 6

## 2. Why this phase
> Burns the remaining HIGH findings (and their attached MEDIUMs) out of the Wave-A baselines, one
> contract per PR: menu+snapshot, status/stats+drift-source, undo, list-tools, find-program,
> axon-docs-gen. Phase boundary: after this wave the reporting layer reads only data that exists.

## 3. PRs in this phase
| PR     | title                                             | est-complexity | depends-on |
|--------|---------------------------------------------------|----------------|------------|
| PR-010 | Menu + snapshot contract repair (parity-tested)   | L              | PR-001     |
| PR-011 | status + stats: drift repoint + orphan retirement | L              | none       |
| PR-012 | undo: rollback contract + run-id manifest         | M              | PR-001     |
| PR-013 | list-tools: registry honesty                      | S              | none       |
| PR-014 | find-program: excise dead semantic-search block   | S              | none       |
| PR-015 | axon-docs-gen: drop phantom .compiled read        | S              | PR-001     |

## 4. MUST vs NICE
**MUST (in-scope)**:
- Menu never instructs a failing command; reminder counts truthful; snapshot/fallback parity pinned
- Drift feeds the health score from the registry-pointed tool; orphaned duplicate deleted
- Successful undo reports success; wrong-run rollback impossible
**NICE (deferred if budget tight)**:
- SELF-IMPROVEMENT panel redesign beyond honest-removal
- find-program OS-programs scan extension (claim-fix is the MUST)

## 5. Entry gate
- Waves A–C merged; baselines list exactly the entries this wave owns

## 6. Exit gate
- Memory-key + accessor baselines empty for all six surfaces; full suite green

## 7. Phase-local risks
| risk                                          | likelihood | mitigation                                  |
|-----------------------------------------------|------------|---------------------------------------------|
| Menu edits regress the collapsed/full render  | medium     | parity + rollup tests (lossless-mandate)     |
| Orphan drift.py deletion breaks a hidden caller | low       | grep + registry check before delete; tests   |

## 8. Iteration log
- 2026-07-07 — phase file rendered
