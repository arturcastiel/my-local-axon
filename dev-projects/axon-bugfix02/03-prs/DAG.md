<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-bugfix02

- schema-version: `v1`
- generated:      `2026-07-07T19:49:44Z`
- generator:      `tools/dag.py`
- nodes:          19
- edges:          7
- critical-path:  PR-001 → PR-012 → PR-019

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Grow output_manifest.json over the reporting-layer tools | Grow output_manifest.json over the reporting-layer tools | merged |
| PR-002 | pr | Memory-key reader/writer lint (ERROR+allowlist+baseline) | Memory-key reader/writer lint (ERROR+allowlist+baseline) | merged |
| PR-003 | pr | Repair session-summary: path, digest patterns, dead lines | Repair session-summary: path, digest patterns, dead lines | merged |
| PR-004 | pr | Rebuild resume detection over persisted working memory | Rebuild resume detection over persisted working memory | merged |
| PR-005 | pr | Gain: honest rebuild over data that exists | Gain: honest rebuild over data that exists | merged |
| PR-006 | pr | Board: rewire aggregation to the real PR store (D1) | Board: rewire aggregation to the real PR store (D1) | merged |
| PR-007 | pr | workspace-backup: structured result checks + human-handoff on BLOCK (D3) | workspace-backup: structured result checks + human-handoff on BLOCK (D3) | merged |
| PR-008 | pr | my-axon-init: close the data-loss windows | my-axon-init: close the data-loss windows | merged |
| PR-009 | pr | Shell-result lint: no substring success-sniffing after TOOL(shell) | Shell-result lint: no substring success-sniffing after TOOL(shell) | merged |
| PR-010 | pr | Menu + snapshot contract repair (parity-tested) | Menu + snapshot contract repair (parity-tested) | merged |
| PR-011 | pr | status + stats: real drift source, real queue shape, orphan retirement | status + stats: real drift source, real queue shape, orphan retirement | merged |
| PR-012 | pr | undo: align the rollback contract + run-id-bound manifest | undo: align the rollback contract + run-id-bound manifest | merged |
| PR-013 | pr | list-tools: registry honesty | list-tools: registry honesty | merged |
| PR-014 | pr | find-program: excise the half-deprecated semantic-search block | find-program: excise the half-deprecated semantic-search block | merged |
| PR-015 | pr | axon-docs-gen: drop the phantom .compiled read | axon-docs-gen: drop the phantom .compiled read | merged |
| PR-016 | pr | Metrics ADR + honest-starvation banners (D2) | Metrics ADR + honest-starvation banners (D2) | merged |
| PR-017 | pr | loop-contract: receipts land in the canonical ledger | loop-contract: receipts land in the canonical ledger | merged |
| PR-018 | pr | LOW / doc-honesty sweep | LOW / doc-honesty sweep | merged |
| PR-019 | pr | Mutating-path test conversion + crucible registration | Mutating-path test conversion + crucible registration | merged |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-010 | depends |
| PR-001 | PR-012 | depends |
| PR-001 | PR-015 | depends |
| PR-002 | PR-019 | depends |
| PR-009 | PR-019 | depends |
| PR-012 | PR-019 | depends |
| PR-017 | PR-019 | depends |
