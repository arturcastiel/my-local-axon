---
tags: [code, file]
path: tests/test_workflow_run_g.py
---

# tests/test_workflow_run_g.py

> 24 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A casual workflow-run that passes --parent-run-id but never actually entered the`
- `A workflow with no sub-workflow declarations must advance normally     even with`
- `Before EXEC(workflow-run), the program must STORE the parent     run-id + parent`
- `Mirror of the refusal test: after recording a sub-trajectory     that terminates`
- `Paired args: --parent-run-id alone is ambiguous (no node = no path).     The pro`
- `Parent context must be cleared after the nested EXEC returns so     subsequent s`
- `Tests for sub-goal G — workflow-run.md auto-threads parent-run-id and dispatches`
- `The LOOP body must branch on cursor.sub-workflow before EXEC,     re-entering wo`
- `The advance TOOL call must include --parent-run-id={run-id} so the     runner's`
- `The program reads W:_workflow-run-parent-run-id and     W:_workflow-run-parent-n`
- `When parent context is set, run-id := {parent}::{node}::{wf.name} (plus an optio`
- `_axon()`
- `_wfrun_text()`
- `test_advance_call_passes_parent_run_id_by_default()`
- `test_back_compat_workflow_without_sub_workflow_field()`
- `test_runner_cli_allows_when_sub_trajectory_recorded()`
- `test_runner_cli_refuses_faked_parent_at_sub_workflow_synapse()`
- `test_sub_workflow_dispatch_clears_parent_context_after_exec()`
- `test_sub_workflow_dispatch_sets_parent_context_before_exec()`
- `test_workflow_run_accepts_parent_args()`
- `test_workflow_run_fails_loud_on_parent_run_id_without_parent_node()`
- `test_workflow_run_g.py`
- `test_workflow_run_has_sub_workflow_dispatch_branch()`
- `test_workflow_run_uses_canonical_sub_run_id_when_parent_set()`

## Depends on
- (none)
