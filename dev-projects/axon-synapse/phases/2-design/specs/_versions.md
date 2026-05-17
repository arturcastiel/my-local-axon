# Spec version log — Phase 2 (I-02)

> Single source of truth for what changed when. Every spec bump appends
> a row here with ADR link + date + summary.

## AXON-GLOSSARY

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-018 | Initial vocabulary lock; `synapse` = node |
| v2 | 2026-05-17 | D-026 | Biology-correct rename: neuron / synapse / axon; layer axis; exploratory + scheduled modes |

## predicate-language

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 (embedded in goal-schema v1) | 2026-05-17 | D-018 | Informal grammar + built-in functions |
| v1.1 (standalone) | 2026-05-17 | D-027 | Formal grammar + precedence + types + null semantics + snapshot rules |

## goal-schema

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-018 | Initial schema; per-level files |
| v1.1 | 2026-05-17 | D-027 (referenced) | Parent-child status semantics (met-with-open-children) |

## synapse-contract → neuron-contract

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 (synapse-contract) | 2026-05-17 | D-018 | Initial schema; inferred + declared override |
| v1.1 (neuron-contract) | 2026-05-17 | D-026, D-032 | Renamed; `affects-source` + `blast-radius` + clarified `requires-shadow` derivation |

## workflow-file

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-018 | Fixed/Adaptive/Hybrid; suggestions; synapse graph |
| v1.1 | 2026-05-17 | D-026 | Exploratory + Scheduled modes; cross-domain list; mid-step `mode-switch`; suggestion-budget |

## domain-manifest

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-018 | Initial schema; code-dev + library-dev refs |
| v1.1 | 2026-05-17 | D-031, D-032 | `layer:` axis; `source-artifact-glob:` field |

## dag-spec

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-019 | 5 levels; JSON canonical; MD one-way render; mutator API |
| v1.1 | 2026-05-17 | (no new ADR) | `dag recover --from-md`; `dag normalize-pr-filenames` |

## orchestrator-composition

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-021 | Composition over kernel tools; combiner formula |
| v1.1 | 2026-05-17 | D-028, D-029, D-030, D-034 | Tie-break ladder; zero-candidate fallback; cold-start; interrupt-gate integration |

## shadow-enforcement

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-022 | Five enforcement gates; retroactive migration; grace flag |
| v1.1 | 2026-05-17 | D-033 | Explicit grace-flag flip protocol (3-condition + user-confirm) |

## conversational-author

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-018 | Dialog flow; 5 phases; wizard pattern |
| v1.1 | 2026-05-17 | D-030 | Cold-start dialog opening; 30-turn cap |

## migration-plan

| Version | Date | ADR | Summary |
|---------|------|-----|---------|
| v1 | 2026-05-17 | D-018 | 20 PRs sequenced; dependency graph |
| v1.1 | 2026-05-17 | D-035 | PR-116 → PR-116a..f split; PR-108 per-file rollback |

## NEW improvement artifacts (v1.1 cohort)

| Artifact | Created | Purpose | Linked decision |
|----------|---------|---------|-----------------|
| `_flaws.md` | 2026-05-17 | Tracked-known-flaws register | I-01 / D-036 |
| `_versions.md` | 2026-05-17 | Spec version log (this file) | I-02 / D-036 |
| `test-fixtures/orchestrator-fixtures.yaml` | 2026-05-17 (seed) | Ranker fixture corpus | I-03 / D-036 |
| `_pr-template.md` | 2026-05-17 | Per-PR rollback recipe template | I-04 / D-036 |
| (in neuron-contract) `blast-radius:` field | 2026-05-17 | Blast-radius declaration | I-05 / D-036 |
| (in neuron-contract) `reversibility:` field | 2026-05-17 | Reversibility tier | I-06 / D-036 |
