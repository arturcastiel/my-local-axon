---
tags: [code, file]
path: tools/workflow_run.py
---

# tools/workflow_run.py

> 62 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `Append an ordered step to `trajectory` (pure; ts/run_id supplied by the caller).`
- `Build a single workflow-listing row. Tolerates parse failure.`
- `Build the on-disk sub-workflow loader, closed over ``workspace``.`
- `Compose the predicate-eval ctx from canonical state sources. Pure read; fail-sof`
- `DETERMINISTIC branch selection (axon-next PR-011). next_allowed returns EVERY`
- `Declared outputs for ``synapse`` that don't exist under ``workspace``.      Retu`
- `Detect templating-artifact bugs: synapses whose ``name:`` starts with     a fore`
- `Enumerate installed workflows by scanning the canonical search roots.      Retur`
- `Flag synapses whose ``name:`` references a neuron file that is missing     or ca`
- `Has the sub-workflow's trajectory been recorded AND terminated?      Returns ``(`
- `Missing declared outputs for ``synapse_id`` under ``workspace``.      Returns an`
- `NodeOutputsNotCompletedError`
- `Pre-write validation of a workflow YAML draft.      Sub-goal C. Catches the comm`
- `Raised when ``advance()`` is called FROM a synapse that declares ``outputs:```
- `Raised when ``advance()`` tries to leave a synapse that declares (or matches)`
- `Raised when a transition is not to a declared on-complete target (a node-jump).`
- `Render a plain-English walkthrough of a workflow.      Sub-goal E. Locates the w`
- `Return `requested_next` iff it is a declared on-complete target of `cursor_id``
- `Return the sub-workflow name for ``synapse``, or ``None`` if it isn't one.`
- `SubWorkflowNotCompletedError`
- `Synapse-ids whose on-complete list is empty/missing — i.e. legal terminal nodes.`
- `The canonical sub-trajectory run-id: parent run-id + parent node + sub name.`
- `The declared on-complete target node-ids of `cursor_id` (in rule order).`
- `The node-id of the last recorded step, or None. A non-dict step is malformed and`
- `The set of installed workflow ``name`` values (across reference + user kinds).`
- `The synapse NAME a trajectory step refers to. A run dispatches by name (EXEC <na`
- `Turn an ordered trajectory into a PROPOSED fixed-workflow draft — one synapse pe`
- `WorkflowJumpError`
- `Write a promoted draft to workspace/workflows/<name>.draft.yml — NEVER overwrite`
- `_dead_next_guard()`
- `_default_sub_loader()`
- `_describe_workflow()`
- `_last_node()`
- `_load()`
- `_read_json_soft()`
- `_step_name()`
- `_sub_traj_run_id()`
- `_synapse_missing_outputs()`
- `_traj_path()`
- `_write_draft()`
- `advance()`
- `build_gate_ctx()`
- `check_stale()`
- `check_templating()`
- `doctrine-fix M2: a resolved `next` that names no real node is a dangling edge —`
- `explain_workflow()`
- `list_workflows()`
- `load_trajectory()`
- `main()`
- `next_allowed()`
- `promote()`
- `record_step()`
- `resolve_next()`
- `save_trajectory()`
- `sub_workflow_completed()`
- `sub_workflow_for_synapse()`
- `synapses_by_id()`
- `terminals()`
- `validate_draft()`
- `verify_node_outputs()`
- `workflow_names()`
- `workflow_run.py`

## Depends on
- [[_unknown_]]
