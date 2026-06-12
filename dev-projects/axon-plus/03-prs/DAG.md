<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-plus

- schema-version: `v1`
- generated:      `2026-06-11T16:55:05Z`
- generator:      `tools/dag.py`
- nodes:          27
- edges:          19
- critical-path:  PR-010 → PR-011 → PR-021a → PR-021b

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | token bench + baseline | token bench + baseline | pending |
| PR-002 | pr | execution receipts | execution receipts | pending |
| PR-003 | pr | menu-render check | menu-render check | pending |
| PR-004 | pr | doc census | doc census | pending |
| PR-005 | pr | census discrepancy fixes | census discrepancy fixes | pending |
| PR-006 | pr | menu aggregation | menu aggregation | pending |
| PR-007 | pr | compile pilot | compile pilot | pending |
| PR-008 | pr | brief envelopes | brief envelopes | pending |
| PR-009 | pr | program shadows | program shadows | pending |
| PR-010 | pr | convergence contract+runner | convergence contract+runner | pending |
| PR-011 | pr | loop designer | loop designer | pending |
| PR-012 | pr | goal-define mode | goal-define mode | pending |
| PR-013 | pr | constraints registry | constraints registry | pending |
| PR-014 | pr | quality-loop program | quality-loop program | pending |
| PR-015 | pr | autonomy ramp gate | autonomy ramp gate | pending |
| PR-016 | pr | situation triggers | situation triggers | pending |
| PR-017 | pr | orchestrator footer live | orchestrator footer live | pending |
| PR-018 | pr | phrases rollout | phrases rollout | pending |
| PR-019 | pr | suggester accuracy | suggester accuracy | pending |
| PR-020 | pr | run visibility | run visibility | pending |
| PR-021a | pr | designer dialogue→yml | designer dialogue→yml | pending |
| PR-021b | pr | synapse generation | synapse generation | pending |
| PR-024 | pr | weak-tier overlay | weak-tier overlay | pending |
| PR-025 | pr | conformance scorecard | conformance scorecard | pending |
| PR-026 | pr | stale sweep | stale sweep | pending |
| PR-027 | pr | doc floor+index | doc floor+index | pending |
| PR-028 | pr | final vs-baseline measurement | final vs-baseline measurement | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-006 | depends |
| PR-001 | PR-007 | depends |
| PR-001 | PR-008 | depends |
| PR-007 | PR-009 | depends |
| PR-010 | PR-011 | depends |
| PR-012 | PR-013 | depends |
| PR-010 | PR-014 | depends |
| PR-014 | PR-015 | depends |
| PR-011 | PR-021a | depends |
| PR-019 | PR-021a | depends |
| PR-021a | PR-021b | depends |
| PR-002 | PR-024 | depends |
| PR-024 | PR-025 | depends |
| PR-004 | PR-026 | depends |
| PR-026 | PR-027 | depends |
| PR-006 | PR-028 | depends |
| PR-007 | PR-028 | depends |
| PR-008 | PR-028 | depends |
| PR-009 | PR-028 | depends |
