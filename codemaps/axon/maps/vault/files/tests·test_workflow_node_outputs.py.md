---
tags: [code, file]
path: tests/test_workflow_node_outputs.py
---

# tests/test_workflow_node_outputs.py

> 35 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `An explicit non-'ok' status is never overridden by the downgrade logic.`
- `Backward compat: synapse without outputs: is never checked.`
- `Build a simple 2-node workflow where s1 declares outputs:.`
- `Even an illegal node-jump raises NodeOutputsNotCompletedError (not WorkflowJumpE`
- `Glob pattern in outputs: — at least one match → passes.`
- `Glob pattern in outputs: — no match → NodeOutputsNotCompletedError.`
- `Minimal workflow dict for testing.`
- `No synapse argument — no downgrade (backward compat).`
- `Synapse without outputs: field — advance is never blocked by output gate.`
- `Synapse without outputs: field — no downgrade even with workspace provided.`
- `Tests for PR-06: workflow_run node outputs schema + verify.  Covers:   - verify_`
- `Unknown synapse id → treated as unguarded (no crash).`
- `_wf()`
- `_wf_with_outputs()`
- `record_step downgrades status from 'ok' to 'incomplete' when outputs missing.`
- `synapse provided but no workspace — no downgrade (backward compat).`
- `test_advance_allows_when_outputs_present()`
- `test_advance_backward_compat_no_outputs_field()`
- `test_advance_glob_output_missing()`
- `test_advance_glob_output_present()`
- `test_advance_outputs_gate_fires_before_jump_check()`
- `test_advance_refuses_when_outputs_missing()`
- `test_record_step_backward_compat_no_synapse()`
- `test_record_step_backward_compat_no_workspace()`
- `test_record_step_downgrade_when_outputs_missing()`
- `test_record_step_explicit_status_not_overridden()`
- `test_record_step_no_downgrade_when_outputs_present()`
- `test_record_step_no_outputs_field_no_downgrade()`
- `test_verify_glob_pattern_matches()`
- `test_verify_glob_pattern_no_match()`
- `test_verify_no_outputs_field_returns_empty()`
- `test_verify_outputs_all_present()`
- `test_verify_outputs_missing()`
- `test_verify_unknown_synapse_returns_empty()`
- `test_workflow_node_outputs.py`

## Depends on
- (none)
