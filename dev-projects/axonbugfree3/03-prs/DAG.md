<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axonbugfree3

- schema-version: `v1`
- generated:      `2026-07-13T11:33:32Z`
- generator:      `tools/dag.py`
- nodes:          21
- edges:          2
- critical-path:  PR-006 → PR-012

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Resolve workflow names across both roots | Resolve workflow names across both roots | pending |
| PR-002 | pr | Workflow caller contracts | Workflow caller contracts | pending |
| PR-003 | pr | Codemap arg contract + shadow dispatch | Codemap arg contract + shadow dispatch | pending |
| PR-004 | pr | Envelope binds | Envelope binds | pending |
| PR-005 | pr | graphify-bridge impact | graphify-bridge impact | pending |
| PR-006 | pr | pattern.py pref parse | pattern.py pref parse | pending |
| PR-007 | pr | phase-model reason oracle | phase-model reason oracle | pending |
| PR-008 | pr | doctrine preflight fail-closed | doctrine preflight fail-closed | pending |
| PR-009 | pr | hr-team refusal pipeline | hr-team refusal pipeline | pending |
| PR-010 | pr | doctrine-node recovery | doctrine-node recovery | pending |
| PR-011 | pr | drift alignment + deadlock breaker | drift alignment + deadlock breaker | pending |
| PR-012 | pr | suggestion calibration | suggestion calibration | pending |
| PR-013 | pr | tick shape + situate bridge | tick shape + situate bridge | pending |
| PR-014 | pr | reporting batch | reporting batch | pending |
| PR-015 | pr | chat index reader==writer | chat index reader==writer | pending |
| PR-016 | pr | episodic store | episodic store | pending |
| PR-017 | pr | agent-memory tiers | agent-memory tiers | pending |
| PR-018 | pr | routing/guards batch | routing/guards batch | pending |
| PR-019 | pr | contract lints ratchet | contract lints ratchet | pending |
| PR-020 | pr | integrity cleanup | integrity cleanup | pending |
| PR-021 | pr | kernel spec (human-only) | kernel spec (human-only) | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-006 | PR-012 | depends |
| PR-011 | PR-021 | depends |
