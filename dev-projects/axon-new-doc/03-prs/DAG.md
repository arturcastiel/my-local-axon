<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-new-doc

- schema-version: `v1`
- generated:      `2026-06-17T17:00:00Z`
- generator:      `tools/dag.py`
- nodes:          7
- edges:          11
- critical-path:  PR-001 → PR-003 → PR-006 → PR-007

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | wiki scaffold + template + INDEX skeleton | wiki scaffold + template + INDEX skeleton | pending |
| PR-002 | pr | freshness + doc_index wiring (+runtime-memory fix) | freshness + doc_index wiring (+runtime-memory fix) | pending |
| PR-003 | pr | code-dev manual | code-dev manual | pending |
| PR-004 | pr | workflow manual | workflow manual | pending |
| PR-005 | pr | library-dev manual | library-dev manual | pending |
| PR-006 | pr | INDEX population + cross-links | INDEX population + cross-links | pending |
| PR-007 | pr | wiki test harness (Guarded by) | wiki test harness (Guarded by) | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-002 | depends |
| PR-001 | PR-003 | depends |
| PR-001 | PR-004 | depends |
| PR-001 | PR-005 | depends |
| PR-003 | PR-006 | depends |
| PR-004 | PR-006 | depends |
| PR-005 | PR-006 | depends |
| PR-003 | PR-007 | depends |
| PR-004 | PR-007 | depends |
| PR-005 | PR-007 | depends |
| PR-006 | PR-007 | depends |
