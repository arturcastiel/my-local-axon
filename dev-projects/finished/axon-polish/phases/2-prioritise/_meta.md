# Phase: 2-prioritise
schema-version: v4
status:         active
workflow-step:  rank
branch:         main
current-pr:     (none)
created:        2026-05-21
predecessor:    1-audit (done, reconciled)
successor:     (3-design)

## Working Context
- Inputs (frozen at Phase 2 entry):
  - `_flaws.md` — 137 flaws (reconciled severity profile: ~20 BLOCKER, ~64 MAJOR, ~43 MINOR, 10 NIT)
  - `_demands.md` — 48 demands (6 retired by axon-tests, 5 routed to specialized projects)
  - `_prior-work-crossref.md` — 14-project survey + pattern adoption list
  - `_adrs.md` — 3 ADRs resolving active conflicts (TOOL(shell), FAIL, deprecate-policy)
- Goal: produce **PR-shaped clusters** ranked by impact × difficulty.
- Output: `02-plan.md` (cluster proposal) + `02-prs.md` (preliminary PR list with sizing).
- Exit criteria:
  - ≥80% of BLOCKER + MAJOR findings assigned to a cluster
  - Each cluster has: size (S/M/L/XL), depends-on (DAG), risk, linked-findings.
  - Top-5 clusters expanded as Phase 3-design entry points.
