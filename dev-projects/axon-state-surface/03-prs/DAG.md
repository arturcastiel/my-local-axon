<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · pr · my-axon/dev-projects/axon-state-surface/03-prs

- schema-version: `v1`
- generated:      `2026-07-10T14:38:09Z`
- generator:      `tools/dag.py`
- nodes:          2
- edges:          1
- critical-path:  PR-001 → PR-002

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Snapshot code-resolves backup and plans | Snapshot code-resolves backup and plans | merged |
| PR-002 | pr | menu.md consumes snapshot; degraded-safe; invariants | menu.md consumes snapshot; degraded-safe; invariants | merged |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-002 | depends |
