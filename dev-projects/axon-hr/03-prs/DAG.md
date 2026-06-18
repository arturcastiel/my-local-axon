<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · axon-hr/plan

- schema-version: `v1`
- generated:      `2026-06-18T12:05:26Z`
- generator:      `tools/dag.py`
- nodes:          11
- edges:          15
- critical-path:  PR-001 → PR-002 → PR-003 → PR-004 → PR-007a → PR-007c

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | hr-team-selector (+min _REGISTRY fixture) | hr-team-selector (+min _REGISTRY fixture) | pending |
| PR-002 | pr | hr-team-convener (run_seats seam, rich transcript) | hr-team-convener (run_seats seam, rich transcript) | pending |
| PR-003 | pr | hr-team-deliberator (§4.3 verdict + fixture) | hr-team-deliberator (§4.3 verdict + fixture) | pending |
| PR-004 | pr | hr-team router (sealed EXEC pipeline) | hr-team router (sealed EXEC pipeline) | pending |
| PR-005 | pr | tools/hr_team.py (CLI + seam impl + audit + REGISTRY) | tools/hr_team.py (CLI + seam impl + audit + REGISTRY) | pending |
| PR-006 | pr | menu [10] + dispatch-phrases + index rebuild | menu [10] + dispatch-phrases + index rebuild | pending |
| PR-007a | pr | asset port: catalog (151 rows + H1-fix + resolver test) | asset port: catalog (151 rows + H1-fix + resolver test) | pending |
| PR-007b | pr | asset port: prompts (69 files) | asset port: prompts (69 files) | pending |
| PR-007c | pr | asset port: handoff docs (optional) | asset port: handoff docs (optional) | pending |
| PR-008 | pr | find-program dispatch-phrases extension (decoupled) | find-program dispatch-phrases extension (decoupled) | pending |
| PR-009 | pr | docs/wiki FULLEST (last) | docs/wiki FULLEST (last) | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-002 | depends |
| PR-001 | PR-003 | depends |
| PR-002 | PR-003 | depends |
| PR-001 | PR-004 | depends |
| PR-002 | PR-004 | depends |
| PR-003 | PR-004 | depends |
| PR-004 | PR-005 | depends |
| PR-004 | PR-006 | depends |
| PR-004 | PR-007a | depends |
| PR-004 | PR-007b | depends |
| PR-007a | PR-007c | depends |
| PR-005 | PR-009 | depends |
| PR-006 | PR-009 | depends |
| PR-007a | PR-009 | depends |
| PR-007b | PR-009 | depends |
