---
tags: [code, file]
path: tests/test_workflow_termination.py
---

# tests/test_workflow_termination.py

> 46 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `# NOTE: predicate.py's actual semantics around OR + undefined may`
- `._trace_body()`
- `.src()`
- `.src()`
- `.test_builds_ctx_per_iteration()`
- `.test_predicate_eval_calls_pass_ctx()`
- `.test_rejection_criterion_checked_inside_loop()`
- `.test_rejection_false_before_bound_true_at_bound()`
- `.test_simulate_also_builds_ctx()`
- `.test_simulate_checks_rejection_inside_loop()`
- `.test_simulate_has_no_revisit_break()`
- `.test_simulate_keeps_max_steps_backstop()`
- `.test_simulate_predicate_eval_passes_ctx()`
- `.test_state_steps_at_threshold()`
- `.test_state_steps_over_threshold()`
- `.test_state_steps_under_threshold()`
- `.test_steps_clause_below_threshold_does_not_trigger()`
- `.test_steps_clause_short_circuits()`
- `A predicate that doesn't reference state.* should work without --ctx.      Backw`
- `Confirms the predicate substrate works for the state.* refs the     workflow pro`
- `Every TOOL(predicate, eval, ...) in the LOOP body must pass --ctx.`
- `Invoke tools/predicate.py eval and return parsed JSON.`
- `PR-5.1 — workflow-run / workflow-simulate termination + ctx-passing tests.  Clos`
- `Reproduces the adaptive-free-text rejection-criterion scenario at the     predic`
- `Return the text of the TRACE LOOP body (LOOP → up to the next ##).`
- `Substrate confirmation: the rejection-criterion simulate now evaluates     each`
- `TestAdaptiveRejectionShortCircuit`
- `TestPredicateWithCtx`
- `TestSimulateRejectionBound`
- `TestWorkflowRunStructure`
- `TestWorkflowSimulateStructure`
- `The LOOP body must build a ctx with state.steps = COUNT(trace).`
- `The first-revisit BREAK must be gone — it truncated cyclic walks.          Repro`
- `The rejection-criterion must be evaluated WITHIN the LOOP body.`
- `The rejection-criterion must be evaluated WITHIN the TRACE loop.          This i`
- `_eval_predicate()`
- ``state.steps > 25` with steps=10 → false.`
- ``state.steps > 25` with steps=25 → false (boundary).`
- ``state.steps > 25` with steps=26 → true (the termination trigger).`
- ``steps > 25 OR <undefined>` with steps=26 → true via short-circuit.          Wit`
- `max-steps must remain as the backstop for unbounded cyclic walks.          With`
- `steps=10 → predicate must NOT trigger termination.`
- `test_predicate_eval_without_ctx_still_works_for_pure_predicates()`
- `test_workflow_termination.py`
- `workflow-simulate's predicate.eval calls pass --ctx.`
- `workflow-simulate.md must build the same ctx pattern.`

## Depends on
- (none)
