# Feature Inventory — axon
> Repo:      /home/arturcastiel/projects/new-axon/axon
> Method:    graph communities (size ≥ 4) named from hubs + shadow arch-role findings
> Generated: 2026-07-13T06:51:56.671379Z

## Rule Engine & Compliance Rules :: the static/runtime rule predicates (Rn, R_*) and the Violation registry that enforce every Core Rule
- cluster: c1 · 68 nodes
- modules: tools/rules, tests
- key symbols: Violation, registry.py, run_static(), r_autonomy_cadence.py, r_autonomy_breaker.py

## Workflow Execution Engine :: walks a synapse DAG, dispatching each node per its on-complete predicates (fixed + adaptive)
- cluster: c2 · 79 nodes
- modules: workspace/programs
- key symbols: workflow-run.md, PROGRAM: workflow-run, walk the synapse DAG

## Predicate / Expression Evaluation :: safe evaluation of precondition/predicate expressions used across gates and synapse contracts
- cluster: c4 · 88 nodes
- modules: tools
- key symbols: predicate.py, _ctx_path_value(), Parser, _truthy()

## Program Authoring Templates :: the PROGRAM-TEMPLATE + authoring scaffolds that new programs are copied from
- cluster: c3 · 72 nodes
- modules: axon/programs
- key symbols: PROGRAM-TEMPLATE, program authoring scaffold

## Code-Dev Study Phase :: the study stage of the code-dev lifecycle (budgeted overview/subsystem/deep analysis)
- cluster: c8 · 63 nodes
- modules: workspace/programs
- key symbols: code-dev-study.md, PROGRAM: code-dev-study

## Code-Dev Planning :: turns study findings into PR specs (the plan stage of code-dev)
- cluster: c6 · 66 nodes
- modules: workspace/programs
- key symbols: code-dev-plan.md, PROGRAM: code-dev-plan

## HR-Team Advisory Council :: multi-persona deliberation — selects seats, runs protocol, returns a dissent-preserving verdict
- cluster: c59 + c54 · 126 nodes
- modules: workspace/programs
- key symbols: hr-team.md, hr-team-deliberator.md, aggregate council seat votes

## Event Bus & Hooks (shadow-enriched) :: EMIT/ON reactive composition + notification hooks; the reactive pipeline backbone
- cluster: workspace/tools subsystem
- modules: workspace/tools
- key symbols: events.py, hooks.py, cron.py, context.py
- shadow arch-role: "Reactive pipeline backbone; hooks.py dispatches on emitted events" · "Action layer of the event system"

---
_Features are inferred from graph structure, not declared intent — verify against docs. Re-run after `codemap graphify`._
