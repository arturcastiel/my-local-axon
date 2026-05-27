# Study — 2-prioritise

> Phase 2 inputs are frozen from Phase 1-audit (reconciled):
> - 137 flaws in `../../_flaws.md`
> - 48 demands in `../../_demands.md`
> - 14-project prior-work cross-ref in `../../_prior-work-crossref.md`
> - 3 ADRs resolving active conflicts in `../../_adrs.md`

## Inputs
- Severity profile (reconciled):
  - BLOCKER: ~20
  - MAJOR: ~64
  - MINOR: ~43
  - NIT: 10

## Method (this phase only)
For each finding (flaws + demands):
1. Determine **size**: S (<1d), M (1-3d), L (1-2w), XL (multi-week).
   - Demands have sizes already from Phase 1. Flaws need backfill.
2. Determine **prior-work cost reduction**: 0% (greenfield) · 25% (pattern adopted) · 50% (substrate exists) · 75% (mostly shipped) · 100% (retired).
3. Determine **impact**: how many other findings does fixing this unblock? Does it move the heavy-workflow needle?
4. Determine **risk**: low / medium / high — how likely is the fix to ripple unexpectedly?
5. Assign to a **cluster** (PR-shaped grouping). Each cluster owns its ADR boundary.

## Output
- `02-plan.md` — cluster proposal with ranks
- `02-prs.md` — preliminary PR list (one row per cluster)
- `phases/2-prioritise/03-prs/*.md` — empty (PR specs land in Phase 3-design)

## Cluster seeds (initial draft, to be ranked in 02-plan)

Following the ADRs as natural cluster boundaries plus the surviving design-open / partial findings:

| Cluster | Owns | Closes findings | ADR | Notes |
|---|---|---|---|---|
| C-01 | TOOL(shell) sandbox + R9 realpath hardening | F-D3-001, F-D7-001, F-D8-001, F-D8-006, F-D8-008 | ADR-001 | bundle the shell.py + R9 fixes (paired per audit) |
| C-02 | fail_render.py + bulk migration kickoff | F-D2-001, F-D2-007, F-D2-016, D-D2-018, D-D2-019 | ADR-002 | tool first; migration is incremental |
| C-03 | Deprecation policy scaffold + log + cron | F-D2-005, F-D5-003, D-D5-001 | ADR-003 | initial sweep + cron + log |
| C-04 | Mainline composition path (PR-111) | F-D4-001, F-D4-002, F-D4-011, F-D4-014 | (open — needs ADR-004) | workflow-run ↔ orchestrator boundary; design decision still required |
| C-05 | Adaptive workflow termination + checkpoint | F-D4-003, F-D4-008, F-D9-002, F-D9-005 | (open — needs ADR-005) | infinite-loop fix + per-step active-phase |
| C-06 | Heavy-workflow / resume / compaction | F-D9-003, F-D9-004, F-D9-008, F-D9-011, F-D9-013, F-D9-014 | ADR-006 (proposed) | session.recover + checkpoint.restore + 25-key prune + G-02 turn-1 protection |
| C-07 | Context-pressure recalibration | F-D9-001, F-D9-005, F-D9-006, F-D9-015 | align with master W3-01/W3-03 | host-model awareness; not greenfield |
| C-08 | Core Rule enforcer fill-in | F-D6-001, F-D6-004, F-D6-007, F-D8-002, F-D8-003, F-D8-007, F-D8-010, F-D8-011 | D-D8-001..017 | 5 missing enforcers (down from 7; tests-PR-007/009 shipped 2) |
| C-09 | Duplicated files + dead-code cleanup | F-D1-001, F-D1-002, F-D1-003, F-D6-011, F-D9-011 | align with master TOP-12 F-07 | menu/quickstart/help dedup + r_reasoning_trace dead bottom |
| C-10 | Dispatcher wiring (explain/simulate/modes) | F-D1-004, F-D1-005, F-D1-006, F-D1-008 | route to axon-wiring-gaps | 5-readers-0-writers method |
| C-11 | Catalog grooming pass | F-D2-003 (53 autogen-stubs), F-D2-004 (dup-function), F-D3-007 (compiled 82% placeholder), F-D5-005 (96% inferred metadata), F-D2-006 (code-dev-* prefix bloat) | align with cleanup PRs | sweep, not PR; ongoing |
| C-12 | enforce.py hardening | F-D7-007, F-D7-007a (user: bypass) | ADR-001 sibling | small targeted fix |
| C-13 | Synapse ranker correctness | F-D3-004 (10 vs 11 signals), F-D4-005 (no mode param), F-D4-013 (cold-start unused) | route to axon-ranker-v2 | already proposed elsewhere; align |
| C-14 | Doc-drift correction | F-D3-002 (tool counts), F-D3-003 (version banner), F-D3-009 (program counts), F-D3-010 (HOWTO stale), F-D3-013 (PLANNED cron) | D-D7-007, D-XC-001 | live-count pipeline |
| C-15 | Worst error messages + worst FAILs | F-D2-016, F-D6-013, F-D6-015 | ADR-002 dependent | downstream of fail_render adoption |

15 clusters, average 4 findings each. Phase 2 task = rank these by impact × difficulty.
