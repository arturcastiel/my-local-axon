<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:graphify-obsidian

- schema-version: `v1`
- generated:      `2026-06-11T06:46:55Z`
- generator:      `tools/dag.py`
- nodes:          10
- edges:          8
- critical-path:  PR-001 → PR-004 → PR-005

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Make dead-code REGISTRY-aware | Make dead-code REGISTRY-aware | pending |
| PR-002 | pr | Repair axon-graph usage doc + full-output UX | Repair axon-graph usage doc + full-output UX | pending |
| PR-003 | pr | Graphify-present-path tests | Graphify-present-path tests | pending |
| PR-004 | pr | Persist code map + freshness reconciler | Persist code map + freshness reconciler | pending |
| PR-005 | pr | Richer Obsidian projection | Richer Obsidian projection | pending |
| PR-006 | pr | Contextual surfacing: synapse+dispatch+anticipate | Contextual surfacing: synapse+dispatch+anticipate | pending |
| PR-007 | pr | P-CD s0 graphify-map + shadow node-id cache | P-CD s0 graphify-map + shadow node-id cache | pending |
| PR-008 | pr | P-CD code-derived depends_on into plan DAG | P-CD code-derived depends_on into plan DAG | pending |
| PR-009 | pr | P-CD review caller-cone + test-map coverage | P-CD review caller-cone + test-map coverage | pending |
| PR-010 | pr | P-CD graphify-query adaptive synapse | P-CD graphify-query adaptive synapse | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-004 | depends |
| PR-004 | PR-005 | depends |
| PR-002 | PR-006 | depends |
| PR-003 | PR-007 | depends |
| PR-007 | PR-008 | depends |
| PR-007 | PR-009 | depends |
| PR-007 | PR-010 | depends |
| PR-006 | PR-010 | depends |
