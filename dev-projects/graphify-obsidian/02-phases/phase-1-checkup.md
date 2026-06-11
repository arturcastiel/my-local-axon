# Phase 1 — checkup

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-06-11

## 1. Envelope
- **Phase number**: 1
- **Slug**: `checkup`
- **Owner**: Graphify Integration and Obsidian Check-up
- **Target window**: TBD
- **PR count**: 3

## 2. Why this phase
> Make the shipped integration trustworthy before extending it. Fixes the dead-code noise, the program doc drift, and the untested live-graphify path — each independently mergeable, no cross-deps.

## 3. PRs in this phase
| PR | title | complexity | depends-on |
|----|-------|------------|------------|
| PR-001 | Make dead-code REGISTRY-aware | M | none |
| PR-002 | Repair axon-graph usage doc + full-output UX | S | none |
| PR-003 | Graphify-present-path tests (skip-if-absent) | S | none |

(Mirror of 02-prs.md rows — source of truth remains 02-prs.md.)

## 4. MUST vs NICE
**MUST (in-scope)**:
- dead-code candidate count drops to a reviewable set (REGISTRY entrypoints excluded)
- axon-graph usage line matches routed subcommands

**NICE (deferred if budget tight)**:
- entrypoint edges rendered in the export map
- god-nodes annotations

## 5. Entry gate
- plan approved (done 2026-06-11)
- crucible green on main

## 6. Exit gate
- all 3 PRs merged, crucible green each
- dead-code output manually sanity-checked against 5 known-live functions

## 7. Phase-local risks
| risk | likelihood | mitigation |
|------|------------|------------|
| REGISTRY parse misses dynamic entrypoints | medium | conservative: only mark KNOWN entry kinds; keep candidate list semantics |
| present-path tests flaky vs graphify version | low | pin assertion to stable markers; skipif absent |

## 8. Iteration log
- 2026-06-11 — phase file rendered from `code-dev plan --mode=tactical`
