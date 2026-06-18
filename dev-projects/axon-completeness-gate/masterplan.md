# Masterplan — Terminal-Transition Completeness Gate

## Objective
Make "a node cannot reach a terminal status (done/complete) unless its DECLARED post-conditions
exist" a uniform, mechanical invariant across AXON's state-advance points — driven by the
`# outputs:` declarations programs already carry (single source of truth, no drift).

## Phase graph (directed)
- study -> plan -> pr -> log -> audit

## Target sites (to confirm + design in study)
1. tools/phase_model.py `done()` — partial fix exists; generalize REQUIRED_OUTPUTS -> read program `# outputs:`.
2. Program `DONE(id)` shorthand — the most general instance; mechanize as a TOOL + verifier RULE
   (R_TERMINAL_OUTPUTS / extend the response-gate), NEVER a KERNEL-SLIM edit.
3. tools/workflow_run.py `advance()` — add an optional node `outputs:`/`effects:` schema + verify
   before record_step(status="ok"); today there is NOTHING declared to verify (the schema gap).
4. (confirm) process lifecycle COMPLETE, scheduler/queue task COMPLETE, `dag set-status` node-done.

## Invariants
- Source of truth = the program's own `# outputs:` (parsed already by the program-entry preamble).
- Guard lives in the transition function / a mechanical rule -> bites regardless of verify.py flags.
- No kernel edits. No gate bypass. Tests-in-change. Crucible-green before test-execution.
