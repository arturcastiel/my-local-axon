<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon4bugfree

- schema-version: `v1`
- generated:      `2026-07-13T17:36:55Z`
- generator:      `tools/dag.py`
- nodes:          8
- edges:          3
- critical-path:  PR-004 → PR-005 → PR-006

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | G1 kernel-scope program_tool_conformance | G1 kernel-scope program_tool_conformance | pending |
| PR-002 | pr | G3 generate doc-counts | G3 generate doc-counts | pending |
| PR-003 | pr | G3 auto-recompile+bless | G3 auto-recompile+bless | pending |
| PR-004 | pr | G2 AXON-LANG edge extractor | G2 AXON-LANG edge extractor | pending |
| PR-005 | pr | G2 gating lints | G2 gating lints | pending |
| PR-006 | pr | G2 reconcile existing lints | G2 reconcile existing lints | pending |
| PR-007 | pr | G4 graph emission (gated) | G4 graph emission (gated) | pending |
| PR-008 | pr | G5 markdown runner (deferred) | G5 markdown runner (deferred) | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-004 | PR-005 | depends |
| PR-005 | PR-006 | depends |
| PR-004 | PR-007 | depends |
