<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-plus

- schema-version: `v1`
- generated:      `2026-06-16T08:22:51Z`
- generator:      `tools/dag.py`
- nodes:          27
- edges:          19
- critical-path:  PR-010 → PR-011 → PR-021a → PR-021b

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | token bench + baseline | token bench + baseline | merged |
| PR-002 | pr | execution receipts | execution receipts | merged |
| PR-003 | pr | menu-render check | menu-render check | merged |
| PR-004 | pr | doc census | doc census | complete |
| PR-005 | pr | census discrepancy fixes | census discrepancy fixes | complete |
| PR-006 | pr | menu aggregation | menu aggregation | merged |
| PR-007 | pr | compile pilot | compile pilot | merged |
| PR-008 | pr | brief envelopes | brief envelopes | merged |
| PR-009 | pr | program shadows | program shadows | merged |
| PR-010 | pr | convergence contract+runner | convergence contract+runner | merged |
| PR-011 | pr | loop designer | loop designer | merged |
| PR-012 | pr | goal-define mode | goal-define mode | merged |
| PR-013 | pr | constraints registry | constraints registry | merged |
| PR-014 | pr | quality-loop program | quality-loop program | merged |
| PR-015 | pr | autonomy ramp gate | autonomy ramp gate | merged |
| PR-016 | pr | situation triggers | situation triggers | merged |
| PR-017 | pr | orchestrator footer live | orchestrator footer live | merged |
| PR-018 | pr | phrases rollout | phrases rollout | merged |
| PR-019 | pr | suggester accuracy | suggester accuracy | merged |
| PR-020 | pr | run visibility | run visibility | merged |
| PR-021a | pr | designer dialogue→yml | designer dialogue→yml | merged |
| PR-021b | pr | synapse generation | synapse generation | merged |
| PR-024 | pr | weak-tier overlay | weak-tier overlay | merged |
| PR-025 | pr | conformance scorecard | conformance scorecard | merged |
| PR-026 | pr | stale sweep | stale sweep | merged |
| PR-027 | pr | doc floor+index | doc floor+index | merged |
| PR-028 | pr | final vs-baseline measurement | final vs-baseline measurement | merged |

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
