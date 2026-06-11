# Phase 2 — living-map

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-06-11

## 1. Envelope
- **Phase number**: 2
- **Slug**: `living-map`
- **Owner**: Graphify Integration and Obsidian Check-up
- **Target window**: TBD
- **PR count**: 2

## 2. Why this phase
> Delivers the user-facing outcome: the Obsidian map exists, stays fresh automatically (freshness reconciler + existing weekly cron), and becomes genuinely navigable (wikilinks, community pages) — still deterministic and byte-reproducible.

## 3. PRs in this phase
| PR | title | complexity | depends-on |
|----|-------|------------|------------|
| PR-004 | Persist code map + freshness reconciler | M | PR-001 |
| PR-005 | Richer Obsidian projection | M | PR-004 |

(Mirror of 02-prs.md rows — source of truth remains 02-prs.md.)

## 4. MUST vs NICE
**MUST (in-scope)**:
- workspace/_dashboards/axon-code-map.md exists and freshness check covers it
- export remains byte-identical across rebuilds (test-pinned)

**NICE (deferred if budget tight)**:
- per-node pages
- graph-view-optimized frontmatter tuning

## 5. Entry gate
- Phase 1 complete (PR-001 merged — map content trustworthy)

## 6. Exit gate
- freshness check reports code_map true; manual rebuild produces zero diff
- map opens cleanly in Obsidian with working wikilinks

## 7. Phase-local risks
| risk | likelihood | mitigation |
|------|------------|------------|
| map churn noise in git | medium | deterministic ordering; regenerate only on graph hash change |
| vault projection grows surface | low | stay single-dir under _dashboards; no new tool |

## 8. Iteration log
- 2026-06-11 — phase file rendered from `code-dev plan --mode=tactical`
