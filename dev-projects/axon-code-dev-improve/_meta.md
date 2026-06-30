# Project: AXON code-dev + workflow harness improvements
slug:            axon-code-dev-improve
schema-version:  v4
status:          active
legacy:          false
phase:           pr
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          (none)
sub-projects:    []
next-action:     "7 PRs merged (@d0dc5e5); PR-003 absorbed. R1/R2/R3-render/R4(detect+additive-write)/R5-detect all SHIPPED. ONLY remaining: PR-008 (OVERWRITE/field repair) — held behind its named go/no-go (D-021): requires Tier-B (a drift-exercised finding human-classified) + PR-007 stable one real cycle. Natural pause. Trivial follow-up: refresh git_dag_reconciler REGISTRY purpose line."
last-program:    hr-team decision council (high 5x2) + PR-001 spec
last-ts:         2026-06-24T11:50:04Z
created:         2026-06-24
updated:         2026-06-24

## Working Context
- GOAL: harden AXON's code-dev AND workflow subsystems against 5 owner demands (workflow-file-per-project; generalized sync; per-phase goal+how-to; new-demand->DAG capture; repair/consistency) — built ONCE on shared engines where possible.
- Codebase = the AXON repo itself (Layer-2 workspace/ programs + tools/ are in scope; axon/ kernel edits are human-only, owner-staged).
- STUDY is complete and deep: parallel source audit (5 streams) + hr-team xhigh council (7 seats x 3 rounds, advisory_only) + Step-0 re-verification of every checkable council claim. Full record -> 01-study.md.
- Architecture decided (D-001): kernel/adapter. Sequence decided (D-002): foundation-first.
- Key source-confirmed facts that shaped the plan: phase_model.done() NOT wired to phase_gate (R3 can't hard-gate v1); plan_dag.py emits a schema-incompatible DAG.json (duplicate); schema widening is a migrated PR not additive; _axon_rollback unwired; stale_downstream duplicates dag.cascade_stale; canonical code-dev.yml EXISTS (R1 = instantiate).
