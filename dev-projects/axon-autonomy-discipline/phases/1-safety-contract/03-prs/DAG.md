<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-autonomy-discipline

- schema-version: `v1`
- generated:      `2026-06-03T10:27:20Z`
- generator:      `tools/dag.py`
- nodes:          7
- edges:          8
- critical-path:  PR-001 → PR-002 → PR-005 → PR-006 → PR-007

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Gate rule: code-change requires PR+phase | Gate rule: code-change requires PR+phase | pending |
| PR-002 | pr | Reanchor workflow-position | Reanchor workflow-position | pending |
| PR-003 | pr | Autonomy contract | Autonomy contract | pending |
| PR-004 | pr | Circuit breakers | Circuit breakers | pending |
| PR-005 | pr | Operate-loop: counter + cadence fire + workflow | Operate-loop: counter + cadence fire + workflow | pending |
| PR-006 | pr | Cadence backstop | Cadence backstop | pending |
| PR-007 | pr | Flip WARN to BLOCK | Flip WARN to BLOCK | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-002 | depends |
| PR-003 | PR-004 | depends |
| PR-002 | PR-005 | depends |
| PR-003 | PR-005 | depends |
| PR-004 | PR-005 | depends |
| PR-005 | PR-006 | depends |
| PR-001 | PR-007 | depends |
| PR-006 | PR-007 | depends |
