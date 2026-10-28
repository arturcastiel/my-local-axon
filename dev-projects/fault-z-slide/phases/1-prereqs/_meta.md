# Phase: 1-prereqs
schema-version: v4
status:         complete
workflow-step:  build
branch:         fix/d1-fault-aware-topology (cpg2python)
current-pr:     (none) — shipped in cpg2python v0.3.0 (897040d), pushed 2026-10-27
created:        2026-10-26

## Working Context
- P0.1 D1 DONE (cpg2python 1eef539, v0.3.0): build_topology fault-aware; D4 face-area fix
  found + fixed on the way. User tested jointly: all green (see 04-log).
- P0.3 DONE (cpg2python 2d41127). P0.2 DONE locally (fieldbook 9cbf066 renumber, ac0ef09 CI token).
- Waiting on USER: create fine-grained PAT + `gh secret set FAULT_PROJECTIONS_TOKEN`; approve pushes/PRs.
- Exit criteria: D1 merged (PR), P0.3 fixed, fieldbook CI decision made.
