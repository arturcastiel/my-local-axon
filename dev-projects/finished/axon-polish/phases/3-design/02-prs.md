# PR list — 3-design

> Tier-1 PRs drafted from master plan (`01-master-plan.md`).
> All 8 are S-sized, ADR-grounded, low-risk, and independent — can ship in parallel.

## Tier-1 (8 PRs, all spec drafted in 03-prs/)

| PR | Cluster | ADR | Closes (BLOCKERs) | Closes (MAJORs) | Effort | Risk | Status |
|---|---|---|---|---|---|---|---|
| PR-12.1 enforce.py user: bypass fix | C-12 | ADR-001 sibling | F-D7-007a, F-D7-007 | — | S | low | spec done |
| PR-1.2 R9 realpath hardening | C-12 sibling | ADR-001 | F-D8-001 (vec 1-3) | — | S | low | spec done |
| PR-7.1 context.py host-model awareness | C-07 | align master | F-D9-001 | F-D9-005, F-D9-015 | S | low | spec done |
| PR-2.1 fail_render.py tool | C-02 | ADR-002 | — | F-D2-001, F-D2-007 | S | low | spec done |
| PR-5.1 workflow-run step-count + ctx | C-05a | ADR-005a | F-D4-003 | F-D4-008, F-D4-018 | S | medium | spec done |
| PR-9.1 menu/quickstart/help dedupe | C-09 | none | F-D1-001, F-D1-002, F-D1-003 | F-D1-013 | S | very low | spec done |
| PR-9.2 r_reasoning_trace dead-bottom | C-09 | none | — | F-D6-011 | S | very low | spec done |
| PR-6.1 session.recover() wire-up | C-06 phase 1 | ADR-006 | F-D9-022, F-D9-004 | — | S | medium | spec done |

**Tier-1 totals**: 9 BLOCKERs + 7 MAJORs + 8 MINORs + 6 demands closed in ~3-5 days parallel.

## Tier-2 (M-sized, follows Tier-1)
| PR | Cluster | ADR | Status |
|---|---|---|---|
| PR-1.1 tools/shell.py sandbox + allowlist | C-01 main | ADR-001 | spec needed |
| PR-2.2 LANG shorthand: FAIL(prog, problem, cause, fix, suggested_next) | C-02 | ADR-002 | spec needed |
| PR-2.3 migrate 5 highest-FAIL-usage programs | C-02 | ADR-002 | spec needed |
| PR-2.4 advisory lint rule + extend cleanup's autopatch | C-02 | ADR-002 | spec needed |
| PR-3.1 deprecation log + cron job + initial sweep of 42 files | C-03 | ADR-003 | spec needed |
| PR-4.1 workflow-run light bridge to orchestrator | C-04 | ADR-007 | spec needed |
| PR-4.2 orchestrator observe-only guard | C-04 | ADR-007 | spec needed |
| PR-4.3 CLEAR(W:orchestrator-last-tick) on workflow DONE | C-04 | ADR-007 | spec needed |
| PR-6.2 R_PHASE_TRACKED + program audit | C-06 phase 2 | ADR-006 | spec needed |
| PR-16.1 write-attribution sentinel + pre-commit hook | C-16 (NEW) | ADR-001 supplement | needs design |

## Tier-3 (L-sized, design-pending)
| Group | Blocked on |
|---|---|
| PR-8.x — Core Rule enforcers (5 missing) | needs ADR-008 (batch) |
| PR-5b.x — register full predicate vocab | ADR-005b accepted but PR design pending |
| PR-14.x — doc-drift / live-count pipeline | D-XC-001 |
| ADR-004 phase-transition gate PRs | user accept of ADR-004 |

## Routed-out (handed off to other projects)
| Cluster | Receiving project |
|---|---|
| C-10 explain/simulate dispatcher wiring | axon-wiring-gaps |
| C-11 catalog grooming pass | axon-cleanup |
| C-13 synapse ranker correctness | axon-ranker-v2 |
| F-D6-005b EXEC silent simulation | axon-copilot-anchor |
| F-D4-016 DAG auto-emit | firing-dag-missing |
| F-D5-009 / F-D6-016 drift-log gaps | axon-copilot-anchor |

## Phase 3 entry checklist
- [x] Master plan written (`01-master-plan.md`) integrating ALL artifacts
- [x] Tier-1 PRs (8) spec'd in `03-prs/PR-*.md`
- [x] Dependency graph documented (Tier-1 all independent)
- [x] Coverage map: 9 BLOCKERs + 7 MAJORs in Tier-1
- [ ] ADR-004 user decision (still PROPOSED — only design item blocking Tier-2)
- [ ] Phase 4-implement entry — pick any Tier-1 PR to ship first
