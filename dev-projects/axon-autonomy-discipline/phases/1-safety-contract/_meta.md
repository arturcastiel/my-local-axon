# Phase: 1-safety-contract
schema-version: v4
status:         active
workflow-step:  pr
branch:         main
current-pr:     (none)
created:        2026-06-03

## Working Context
First phase — the AUTHORITY floor and the MVP of safe autonomy (nothing else is safe to run unattended
without it). Deliver: the autonomy contract (goal + acceptance + scope/op allow-list + budget, as the
entry gate to overnight mode, built on autonomous_mode.py), the circuit breakers (halt-and-surface on
twice-red gate / repeated failure / out-of-scope touch / escalation op / budget exhausted), and the
escalation protocol. The methodology + lessons are seeded in 01-study.md — refine with `code-dev study`,
then `code-dev plan`. See masterplan.md for the target + full phase graph.
