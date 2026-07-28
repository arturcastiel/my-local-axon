---
tags: [code, file]
path: tests/test_workflow_orchestrator_bridge.py
---

# tests/test_workflow_orchestrator_bridge.py

> 51 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `.src()`
- `.src()`
- `.src()`
- `.test_active_program_clear_is_bridge_gated()`
- `.test_active_program_store_is_bridge_gated()`
- `.test_active_workflow_stores_remain_unconditional()`
- `.test_ask_skipped_in_bridge_mode()`
- `.test_bridge_invocation_order_after_ctx()`
- `.test_bridge_mode_detected_before_active_program_store()`
- `.test_detects_bridge_mode_at_entry()`
- `.test_done_cleanup_order_before_active_program()`
- `.test_done_clears_bridge_keys()`
- `.test_exec_orchestrator_gate_skips_fixed_only()`
- `.test_exec_orchestrator_gated_by_execution_mode()`
- `.test_fire_skipped_in_bridge_mode()`
- `.test_invokes_orchestrator_inside_loop()`
- `.test_no_exec_orchestrator()`
- `.test_no_orchestrator_last_tick_write()`
- `.test_no_phase_ledger_write()`
- `.test_no_store_active_workflow()`
- `.test_no_store_active_workflow_step()`
- `.test_record_block_remains_unconditional()`
- `.test_stores_active_workflow_inside_loop()`
- `.test_stores_active_workflow_step_inside_loop()`
- `All three bridge-related keys must be CLEARed at DONE so the         next free-t`
- `Bridge ops must come AFTER ctx construction (so orchestrator         sees fresh`
- `Bridge-key cleanup must come BEFORE the FINAL CLEAR(W:active-         program) s`
- `Detection must happen BEFORE the (now-conditional) STORE of         active-progr`
- `Orchestrator must read W:active-program BEFORE overwriting it,         and compa`
- `PR-4.1 (ADR-007) — workflow-run ↔ orchestrator light bridge.  Closes F-D4-002 (B`
- `PR-4.2: only the EXEC(orchestrator) call is mode-gated. The         W:active-wor`
- `PR-4.2: the EXEC(orchestrator) call must be gated by an         execution-mode c`
- `PR-4.2: the gate predicate must specifically exclude "fixed"         execution m`
- `PR-4.3: workflow-simulate is the dry-run sibling of workflow-run.     A core des`
- `TestOrchestratorBridgeMode`
- `TestWorkflowRunBridgeStructure`
- `TestWorkflowSimulateBridgeFree`
- `The ACT ask block must also be guarded so the workflow is not         interrupte`
- `The ACT fire block must be guarded by AND NOT bridge-mode so we         don't do`
- `The RECORD step (STORE W:orchestrator-last-tick + LOG/APPEND)         must STAY`
- `The STORE(W:active-program, "orchestrator") must be gated by         NOT bridge-`
- `The exit CLEAR(W:active-program) must be gated by NOT         bridge-mode — othe`
- `test_workflow_orchestrator_bridge.py`
- `workflow-run must EXEC(orchestrator) inside the LOOP body.`
- `workflow-run must STORE(W:active-workflow, wf) inside the LOOP         body so o`
- `workflow-run must STORE(W:active-workflow-step, cursor.id) so         orchestrat`
- `workflow-simulate must NEVER call EXEC(orchestrator). Dry-run         means dry-`
- `workflow-simulate must NOT STORE(W:active-workflow, ...).         Other observer`
- `workflow-simulate must NOT STORE(W:active-workflow-step, ...)         for the sa`
- `workflow-simulate must NOT append to the phase ledger — that         is the audi`
- `workflow-simulate must NOT touch W:orchestrator-last-tick.         That key is t`

## Depends on
- (none)
