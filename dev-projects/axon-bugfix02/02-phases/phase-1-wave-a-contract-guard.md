# Phase 1 — wave-a-contract-guard

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-07

## 1. Envelope
- **Phase number**: 1
- **Slug**: `wave-a-contract-guard`
- **Owner**: AXON Bugfix 02
- **Target window**: TBD
- **PR count**: 2

## 2. Why this phase
> Lands the mechanical guard for the dominant defect class (reader/writer contract drift) BEFORE any
> fixes, in report-mode with a grandfathered baseline. Every later wave burns the baseline down and is
> verifiable against the lint as it merges. Phase boundary because everything downstream is measured
> by what this phase builds.

## 3. PRs in this phase
| PR     | title                                                    | est-complexity | depends-on |
|--------|----------------------------------------------------------|----------------|------------|
| PR-001 | Grow output_manifest.json over the reporting-layer tools | M              | none       |
| PR-002 | Memory-key reader/writer lint (ERROR+allowlist+baseline) | L              | none       |

## 4. MUST vs NICE
**MUST (in-scope)**:
- Manifest entries for every tool the reporting layer touches, each validated by a test
- Unguarded-orphan ERROR class + `W:_*` exclusion + L: config allowlist + baseline file
**NICE (deferred if budget tight)**:
- Advisory listing of guarded orphans (review-once report)
- Manifest entries for tools outside the reporting layer

## 5. Entry gate
- Plan approved (owner gate passed 2026-07-07)
- Full pytest suite green on main

## 6. Exit gate
- Both lints run in report-mode with committed baselines; zero NEW violations possible unnoticed
- Full pytest suite green (tests-with-neurons: both checks covered)

## 7. Phase-local risks
| risk                                              | likelihood | mitigation                                    |
|---------------------------------------------------|------------|-----------------------------------------------|
| Lint noise despite refinement (config-idiom edge) | medium     | baseline + allowlist absorb; ERROR class narrow |
| Manifest entries drift from live tool output      | medium     | per-entry tests pin manifest to real emissions |

## 8. Iteration log
- 2026-07-07 — phase file rendered from `code-dev plan` (tactical), council-repaired lint design
