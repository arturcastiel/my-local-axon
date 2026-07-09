<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-stale-pointers

- schema-version: `v1`
- generated:      `2026-07-09T07:46:24Z`
- generator:      `tools/dag.py`
- nodes:          5
- edges:          2
- critical-path:  PR-001 → PR-002

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Add pointer-coherence sweep to self-care | Add pointer-coherence sweep to self-care | pending |
| PR-002 | pr | Surface lint at menu + guard resume offer | Surface lint at menu + guard resume offer | pending |
| PR-003 | pr | Loud completion: complete route + escalation | Loud completion: complete route + escalation | pending |
| PR-004 | pr | conftest.py test-run stamp | conftest.py test-run stamp | pending |
| PR-005 | pr | Repair stale records + docs/changelog | Repair stale records + docs/changelog | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-002 | depends |
| PR-001 | PR-005 | depends |
