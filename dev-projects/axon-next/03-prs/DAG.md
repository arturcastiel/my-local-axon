<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-next

- schema-version: `v1`
- generated:      `2026-07-08T16:39:14Z`
- generator:      `tools/dag.py`
- nodes:          17
- edges:          23
- critical-path:  PR-006 → PR-007 → PR-009 → PR-014 → PR-015 → PR-016 → PR-017

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Deletion-verb gate coverage: verbs, wrappers, interpreters, bulk threshold | Deletion-verb gate coverage: verbs, wrappers, interpreters, bulk threshold | merged |
| PR-002 | pr | Build G1c for real: the cited write-barrier | Build G1c for real: the cited write-barrier | merged |
| PR-003 | pr | Grant TTL + human-only renewal + ledger reconciliation | Grant TTL + human-only renewal + ledger reconciliation | merged |
| PR-004 | pr | Receipts v1.1: one enum bump, hash-chain, destructive wrapping | Receipts v1.1: one enum bump, hash-chain, destructive wrapping | merged |
| PR-005 | pr | Program-integrity manifest incl. AUTONOMY.md + run graphs | Program-integrity manifest incl. AUTONOMY.md + run graphs | merged |
| PR-006 | pr | AUTONOMY.md format, template, parser, anchor | AUTONOMY.md format, template, parser, anchor | merged |
| PR-007 | pr | Activation interview: four-artifact transaction | Activation interview: four-artifact transaction | merged |
| PR-008 | pr | Fail-closed activation stage 1 + grant-doctrine binding | Fail-closed activation stage 1 + grant-doctrine binding | merged |
| PR-009 | pr | Walking skeleton: one tiny mission end-to-end | Walking skeleton: one tiny mission end-to-end | merged |
| PR-010 | pr | Workflow schema: outputs legalized, typed node kinds | Workflow schema: outputs legalized, typed node kinds | merged |
| PR-011 | pr | Goal-ctx bridge + deterministic resolve-next | Goal-ctx bridge + deterministic resolve-next | merged |
| PR-012 | pr | Validation preflight + activation stage 2 | Validation preflight + activation stage 2 | merged |
| PR-013 | pr | Derived DAG ledger + mermaid fluxogram | Derived DAG ledger + mermaid fluxogram | merged |
| PR-014 | pr | Doctrine runner: bound execution, receipts, the wall | Doctrine runner: bound execution, receipts, the wall | merged |
| PR-015 | pr | S7b current-node op-class gate + scope binding | S7b current-node op-class gate + scope binding | pending |
| PR-016 | pr | Unattended arming: evidence-gated promotion | Unattended arming: evidence-gated promotion | pending |
| PR-017 | pr | External-repo E2E proof + docs + v2 stub | External-repo E2E proof + docs + v2 stub | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-006 | PR-007 | depends |
| PR-006 | PR-008 | depends |
| PR-003 | PR-008 | depends |
| PR-005 | PR-008 | depends |
| PR-004 | PR-009 | depends |
| PR-007 | PR-009 | depends |
| PR-008 | PR-009 | depends |
| PR-010 | PR-012 | depends |
| PR-006 | PR-012 | depends |
| PR-010 | PR-013 | depends |
| PR-009 | PR-014 | depends |
| PR-010 | PR-014 | depends |
| PR-011 | PR-014 | depends |
| PR-012 | PR-014 | depends |
| PR-013 | PR-014 | depends |
| PR-014 | PR-015 | depends |
| PR-001 | PR-015 | depends |
| PR-014 | PR-016 | depends |
| PR-015 | PR-016 | depends |
| PR-003 | PR-016 | depends |
| PR-014 | PR-017 | depends |
| PR-015 | PR-017 | depends |
| PR-016 | PR-017 | depends |
