<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-code-dev-improve

- schema-version: `v1`
- generated:      `2026-06-30T07:45:58Z`
- generator:      `code-dev plan (AXON dev instance) — from 01-study.md locked sequence (D-001/D-002)`
- nodes:          11
- edges:          12
- critical-path:  PR-000 → PR-001 → PR-002 → PR-003 → PR-004 → PR-007 → PR-008

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-000 | pr | Step-0 source re-verification of council claims | re-verify | complete |
| CYCLE0-BOUNDARY | finding | Cycle-0 kernel/adapter boundary spec (AXON deliverable, awaits owner ratification): names phase-ladder adapter as the render landing zone so PR-S0 needs no later migration | Cycle-0 boundary spec | complete |
| PR-S0 | pr | FELT-VALUE SLICE (harmonize council w4vzc426j): study-phase entry-render of per-phase GOAL + how-to block, in the phase-ladder ADAPTER, reads existing goal.py/phase_model metadata, warn-first, flag-gated. Foundation-INDEPENDENT — no schema/reconciler/kernel edit. Precondition: Cycle-0 kernel/adapter boundary spec ratified. Leads the human delivery queue (NOT on the technical critical path). | PR-S0 entry-render (felt value) | merged |
| PR-001 | pr | Invisible prerequisite refactor: plan_dag.py emits via dag.py primitives; phase_model.stale_downstream delegates to dag.cascade_stale; reconcile workflow_dag.py registry/test | consolidate duplicates | merged |
| PR-002 | pr | Widen dag.py node schema (commit, origin:machine|human, disposition, goal-id) as a tested+migrated PR (enum edits + SCHEMA_VERSION bump + workspace migrate); wire _axon_rollback.snapshot() into every DAG write path | schema + snapshot | merged |
| PR-003 | pr | One-time DAG baseline/acknowledge pass (with snapshot): normalize existing DAGs to widened schema; reconciler reports only NEW drift; distinguishes SCHEMA_MISMATCH from GIT_DAG_DRIFT | baseline pass | skipped |
| PR-004 | pr | READ-ONLY git<->DAG reconciler + pre-written CONFLICT-HUMAN-EDIT policy: 3 drift classes, structured JSON, exit-nonzero-on-drift, advisory WARN in crucible one cycle, NO --fix (R2 + R4-detect + R5-detect) | reconciler | merged |
| PR-005 | pr | R3: render goal + how-to guidance at phase ENTRY via constraints-checklist template + goal-define.md auto-suggest (anchoring-aware, edit-vs-accept telemetry); goal-id presence WARN at done() only after phase_gate wired | R3 entry-render+warn | merged |
| PR-006 | pr | R1: instantiate canonical workflow at scaffold (file exists); load-time WARN existing, hard-gate NEW projects only; validate parseable+referentially-valid not mere presence | R1 workflow-file | merged |
| PR-007 | pr | R4 write-half: detected demands -> DAG with origin tagging; require source-id; fail-open on machine/untagged origin; gate human-origin acknowledgment only | R4 demand->DAG | merged |
| PR-008 | pr | R5 repair — MUTATION RE-ENTRY (--fix code cut from v1 per D-006): snapshot + idempotency + CONFLICT-HUMAN-EDIT branch tests are CORE exit criteria; behind a NAMED go/no-go | R5 repair (mutation re-entry) | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-000 | PR-001 | depends |
| PR-001 | PR-002 | depends |
| PR-002 | PR-003 | depends |
| PR-003 | PR-004 | depends |
| PR-002 | PR-005 | depends |
| PR-002 | PR-006 | depends |
| PR-004 | PR-007 | depends |
| PR-002 | PR-007 | depends |
| PR-004 | PR-008 | depends |
| PR-007 | PR-008 | depends |
| PR-S0 | PR-005 | informs |
| CYCLE0-BOUNDARY | PR-S0 | depends |
