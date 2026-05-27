# Flaws register — axon-synapse (I-01)

> Tracked-known design flaws. A flaw without a row here is a defect.
> Updated on every spec bump.

## Status legend

| Symbol | Meaning |
|--------|---------|
| 🟥 open       | flaw acknowledged, no spec fix yet |
| 🟧 spec-fixed | design fix landed in spec; impl pending |
| 🟨 impl-fixed | code change landed; verification pending |
| 🟩 closed     | verified resolved + tests pass + audit clean |
| ⬛ wontfix    | acknowledged + documented as a known limitation |

## v1 → v1.1 remediation cohort (2026-05-17)

### Closed in v1.1 (🟧 spec-fixed)

| ID | Flaw | Fix | Decision |
|----|------|-----|----------|
| FL-01 | Predicate operator precedence undefined | Formal grammar (`predicate-language-v1.1`); AND > OR; NOT prefix; implication right-assoc | D-027 |
| FL-02 | Null semantics undefined | Safe-eval default (null = false in predicate ctx); strict-null opt-in | D-027 |
| FL-03 | Type system absent | Six base types + explicit coercion rules + type_mismatch errors | D-027 |
| FL-04 | Ranker tie-break arbitrary | Six-level ladder ending in lexicographic name | D-028 |
| FL-05 | Zero-candidate fallback hangs | TF-IDF registry-wide fallback + register/free-text QUERY | D-029 |
| FL-06 | PR-116 single PR for 119 files | Split into PR-116a..f per project, each with sub-DAG | D-035 |
| FL-07 | Cold-start ranker undefined | 20-fire frequency-prior bootstrap from REGISTRY | D-030 |
| FL-08 | `requires-shadow` source-file detection ambiguous | Domain manifest `source-artifact-glob:` drives inference | D-032 |
| FL-09 | Interrupt-gate × workflow undefined | Four-case integration: continuation / deviation / pause-and-task / abort | D-034 |
| FL-10 | Grace-flag flip protocol vague | Explicit triple-condition flip + user-confirm + dev-mode unflip | D-033 |
| GAP-01 | Multi-domain workflow resolution | `domain:` accepts list; first-listed primary | workflow-file v1.1 |
| GAP-02 | Mid-workflow mode-switching | Per-step `mode-switch:` allowed-transitions field | workflow-file v1.1 |
| GAP-03 | Sideband suggestion rate-limit | `suggestion-budget:` block per workflow | workflow-file v1.1 |
| GAP-04 | DAG.json single-point-of-failure | `dag recover --from-md` last-resort path | dag-spec v1.1 |
| GAP-05 | Parent-met-child-open semantics | `met-with-open-children` state + cascade rules | goal-schema v1.1 |
| GAP-06 | Snapshot freshness for long-running neurons | Entry-time default; continuous opt-in | predicate-language v1.1 |
| GAP-07 | Phase 4 data-collection on-ramp | (still open — see below) | — |
| GAP-08 | Mixed-case `PR-NNN` filename migration | `dag normalize-pr-filenames` tool | dag-spec v1.1 |
| OP-01 | Synapse metaphor inverted from biology | Vocabulary rename: neuron / synapse / axon | D-026 |
| OP-03 | `meta` category overloaded | `layer:` axis with 5 values | D-031 |
| OP-04 | PR-108 modifies 174 files with no per-file rollback | `--rollback-per-file` mode via `undo` tool | D-035 |

### Carried forward as Phase-4 work (🟥 open — wontfix-for-v1)

| ID | Flaw | Reason for deferral | Target |
|----|------|---------------------|--------|
| GAP-07 | Phase-4 ranker tuning needs labeled data; how/when labels are gathered not yet defined | Requires lived data from Phase-3 launch; spec can't be authored until usage exists | Phase-4 PR-152 prerequisite |
| OP-02 | Linear ranker likely inadequate for nonlinear signal interactions | Defer — measure linear performance first, tune only if signal | Phase 4+ |
| OP-01.X | `synapse` user-facing alias may confuse future contributors expecting biology-correct meaning | Backwards-compat priority — keep alias forever; document in glossary | permanent ⬛ |

## Triage process

- A new flaw lands → row added with 🟥.
- Spec fix lands → status 🟧 + decision link.
- Implementation lands → status 🟨 + PR link.
- Tests + audit pass → status 🟩.
- Cannot/wontfix → status ⬛ with rationale.

Audit (Phase-4): zero 🟥 rows is the goal.

## Roll-up (2026-05-17 post-remediation)

| Status | Count |
|--------|-------|
| 🟥 open       | 2 (GAP-07 + OP-02 deferred) |
| 🟧 spec-fixed | 21 (this cohort) |
| 🟨 impl-fixed | 0 (Phase 3 pending) |
| 🟩 closed     | 0 (Phase 4 pending) |
| ⬛ wontfix    | 1 (OP-01.X) |
| **Total**     | **24** |
