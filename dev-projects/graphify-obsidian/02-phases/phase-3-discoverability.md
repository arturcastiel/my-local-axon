# Phase 3 — discoverability

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-06-11

## 1. Envelope
- **Phase number**: 3
- **Slug**: `discoverability`
- **Owner**: Graphify Integration and Obsidian Check-up
- **Target window**: TBD
- **PR count**: 1

## 2. Why this phase
> The owner addendum: tools must surface at the moment of need. Wires graph tools into existing suggestion machinery (synapse signals, dispatch phrases, anticipate hooks) as the pilot of a reusable tool-discoverability pattern — extend, never add.

## 3. PRs in this phase
| PR | title | complexity | depends-on |
|----|-------|------------|------------|
| PR-006 | Contextual surfacing: synapse + dispatch + anticipate | M | PR-002 |

(Mirror of 02-prs.md rows — source of truth remains 02-prs.md.)

## 4. MUST vs NICE
**MUST (in-scope)**:
- 'what calls X' / 'map this repo' style free text routes to axon-graph with confidence
- code-dev review/plan entry suggests the caller-cone query

**NICE (deferred if budget tight)**:
- generalized pattern applied to other lost tools (census via igap)

## 5. Entry gate
- Phase 1 complete (PR-002 merged — program file stable)

## 6. Exit gate
- dispatch-index rebuilt; suggestion fires in a live code-dev session
- igap shows no new 'could not find graph tool' gaps

## 7. Phase-local risks
| risk | likelihood | mitigation |
|------|------------|------------|
| suggestion spam | medium | threshold via existing dispatch-confidence pref; anticipation only at phase transitions |
| dispatch phrase collisions | low | test against dispatch fixtures |

## 8. Iteration log
- 2026-06-11 — phase file rendered from `code-dev plan --mode=tactical`
