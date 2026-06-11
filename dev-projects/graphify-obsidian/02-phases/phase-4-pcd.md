# Phase 4 — pcd

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-06-11

## 1. Envelope
- **Phase number**: 4
- **Slug**: `pcd`
- **Owner**: Graphify Integration and Obsidian Check-up
- **Target window**: TBD
- **PR count**: 4

## 2. Why this phase
> Expands the integration outward: code-dev on TARGET repos gets graph-backed study, planning, review, and test-mapping — the designed-but-unbuilt P-CD track. All surfaces fail-degrade and advisory; written to lift out cleanly if owner splits the wave.

## 3. PRs in this phase
| PR | title | complexity | depends-on |
|----|-------|------------|------------|
| PR-007 | s0 graphify-map study step + shadow node-id cache | M | PR-003 |
| PR-008 | code-derived depends_on into plan DAG | M | PR-007 |
| PR-009 | review caller-cone + test-map real coverage | M | PR-007 |
| PR-010 | graphify-query adaptive synapse | S | PR-007, PR-006 |

(Mirror of 02-prs.md rows — source of truth remains 02-prs.md.)

## 4. MUST vs NICE
**MUST (in-scope)**:
- target-repo graph built once at study, persisted per-project, reused downstream
- every surface degrades to today's path when graph absent

**NICE (deferred if budget tight)**:
- graphify update --since incremental freshness
- multi-repo graph federation

## 5. Entry gate
- Phases 1-3 complete; graphify-bridge present-path tested (PR-003)

## 6. Exit gate
- all 4 PRs merged crucible-green; a live code-dev run on a fixture repo exercises study->plan->review with the graph present AND absent

## 7. Phase-local risks
| risk | likelihood | mitigation |
|------|------------|------------|
| graphify schema drift breaks bridge | medium | pin graphifyy<0.9.0; links/edges fallback already tested |
| advisory edges leak into gates | low | confidence partition enforced; EXTRACTED-only on gate paths |

## 8. Iteration log
- 2026-06-11 — phase file rendered from `code-dev plan --mode=tactical`
