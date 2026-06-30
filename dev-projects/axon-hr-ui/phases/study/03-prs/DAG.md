<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-hr-ui

- schema-version: `v1`
- generated:      `2026-06-22T21:41:15Z`
- generator:      `tools/dag.py`
- nodes:          15
- edges:          5
- critical-path:  PR-001 → PR-008 → PR-011

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | phase_model add subcommand + wire code-dev-phase-new | phase_model add subcommand + wire code-dev-phase-new | pending |
| PR-002 | pr | Relabel SHADOW GATE advisory + enforcement-posture boot line | Relabel SHADOW GATE advisory + enforcement-posture boot line | pending |
| PR-003 | pr | OS-STATE nominal-collapse to one line | OS-STATE nominal-collapse to one line | pending |
| PR-004 | pr | kv-store --raw / JSON-fallback | kv-store --raw / JSON-fallback | pending |
| PR-005 | pr | synapse-infer dedup + synapse-validate lint | synapse-infer dedup + synapse-validate lint | pending |
| PR-006 | pr | code-dev start entry-point program | code-dev start entry-point program | pending |
| PR-007 | pr | boot re-entry summary / resume-truth | boot re-entry summary / resume-truth | pending |
| PR-008 | pr | FOUNDATION phase state real AND visible | FOUNDATION phase state real AND visible | pending |
| PR-009 | pr | adaptive-loop semantic exit | adaptive-loop semantic exit | pending |
| PR-010 | pr | reanchor cadence (not suppression) | reanchor cadence (not suppression) | pending |
| PR-011 | pr | severity-gated audit->fix + promote/replay verb | severity-gated audit->fix + promote/replay verb | pending |
| PR-012 | pr | single save/sync verb | single save/sync verb | pending |
| PR-013 | pr | GATE cold-start stranger test | GATE cold-start stranger test | pending |
| PR-014 | pr | GATED fast-boot + first-run + discoverability rank | GATED fast-boot + first-run + discoverability rank | pending |
| PR-015 | pr | DEFERRED component grammar internal contract | DEFERRED component grammar internal contract | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-008 | depends |
| PR-008 | PR-011 | depends |
| PR-013 | PR-014 | depends |
| PR-003 | PR-015 | depends |
| PR-008 | PR-015 | depends |
