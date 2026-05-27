# Project: DAG Consistency Contract
slug:            dag-consistency
schema-version:  v4
status:        active
legacy:          false
phase:           1-gate
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
supersedes:      firing-dag-missing
created:         2026-05-26
updated:         2026-05-26

## Working Context
- Make the DAG the single source of structural truth across AXON (projects,
  phases, PRs, workflows, synapse neurons), enforced mechanically.
- Foundation first: a consistency GATE (detect drift everywhere) → then cascade-
  wire the 7 mutation programs so splits/adds/merges update the DAG automatically.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.

> **RE-ACTIVATED 2026-05-27** — pulled back out of `obsolete/`: it is a live prerequisite (blocker) for **axon-viz**. The supersession note above is void for this project.
