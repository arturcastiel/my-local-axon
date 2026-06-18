<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · axon-completeness-gate/plan

- schema-version: `v1`
- generated:      `2026-06-18T17:01:32Z`
- generator:      `tools/dag.py`
- nodes:          19
- edges:          8
- critical-path:  PR-01 → PR-03 → PR-05 → PR-11 → PR-13

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-01 | pr | phase_model mode-aware completeness gate | phase_model mode-aware completeness gate | complete |
| PR-02 | pr | code-dev-new seeds the gate | code-dev-new seeds the gate | complete |
| PR-03 | pr | # emits: SSOT + drift-lock | # emits: SSOT + drift-lock | complete |
| PR-04 | pr | reconnect emits->seed_outputs + recompile | reconnect emits->seed_outputs + recompile | complete |
| PR-05 | pr | R_TERMINAL_OUTPUTS rule (general, silent-until-flag) | R_TERMINAL_OUTPUTS rule (general, silent-until-flag) | pending |
| PR-06 | pr | workflow_run node outputs schema + verify | workflow_run node outputs schema + verify | pending |
| PR-07 | pr | R9: PreToolUse Bash matcher -> axon/ write gate | R9: PreToolUse Bash matcher -> axon/ write gate | complete |
| PR-08 | pr | R9: compile_write traversal sanitize + _axon_io | R9: compile_write traversal sanitize + _axon_io | complete |
| PR-09 | pr | R9: enforce.py cwd->AXON_ROOT classification | R9: enforce.py cwd->AXON_ROOT classification | complete |
| PR-10 | pr | R9: _axon_io mandatory write primitive (lint) | R9: _axon_io mandatory write primitive (lint) | pending |
| PR-11 | pr | Enforcement: crucible carriage of verify-only BLOCK rules | Enforcement: crucible carriage of verify-only BLOCK rules | pending |
| PR-12 | pr | Enforcement: identity-independent response/dont-do gate | Enforcement: identity-independent response/dont-do gate | pending |
| PR-13 | pr | Enforcement: Stop-hook honest scope / gate-on-next-turn | Enforcement: Stop-hook honest scope / gate-on-next-turn | pending |
| PR-14 | pr | Drift: wire dispatch_index into freshness+cron | Drift: wire dispatch_index into freshness+cron | pending |
| PR-15 | pr | Drift: dag_consistency DAG-vs-PR + freshness/boot | Drift: dag_consistency DAG-vs-PR + freshness/boot | pending |
| PR-16 | pr | Firing: reanchor hook re-ticks anticipate | Firing: reanchor hook re-ticks anticipate | pending |
| PR-17 | pr | Firing: turn-log/prompt-log driven by a hook | Firing: turn-log/prompt-log driven by a hook | pending |
| PR-18 | pr | Firing: emit-without-listener lint + triage | Firing: emit-without-listener lint + triage | pending |
| PR-19 | pr | Resume: session-owner token instead of getppid | Resume: session-owner token instead of getppid | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-01 | PR-02 | depends |
| PR-01 | PR-03 | depends |
| PR-03 | PR-04 | depends |
| PR-03 | PR-05 | depends |
| PR-01 | PR-06 | depends |
| PR-08 | PR-10 | depends |
| PR-05 | PR-11 | depends |
| PR-11 | PR-13 | depends |
