# Project: AXON Coherence v2 — structural-coherence validation across program graphs
slug:            axon-coherence-v2
schema-version:  v4
status:        obsolete
legacy:          false
phase:           0-seed
workflow-step:   seed
branch:          main
codebase:        /mnt/c/projects/axon
parent:          axon-autoimprove
sub-projects:    []
created:         2026-05-19
updated:         2026-05-19
predecessor:     axon-autoimprove (PR-AUTO-302 triage routed FA-22 + FA-23 here)
seed-audit:      _seed.md

## Working Context

Spinout from `axon-autoimprove` (PR-AUTO-302 triage). Combines two structural-coherence flaws that share a root cause:

- **FA-22** — code-dev's pseudo-state-machine transitions are unguarded; any subcommand can be invoked from any state. The audit explicitly proposed `axon-coherence-v2` for this.
- **FA-23** — `synapse-validate` silently passes references to unknown neurons (B-17). Same family of bug: a structural relationship (FSM transition · neuron reference) goes unchecked at validate-time and surfaces only at runtime, often silently.

Both are extensions of the static-lint pattern proven by **PR-AUTO-212 (R_TOOL_CALL_EXISTS)**: catch the broken structural reference at lint-time, before runtime, with actionable error messages.

## Goal (top-level)

Build a **structural-coherence layer** that checks invariants across program/neuron/FSM graphs:

1. **FSM coherence (FA-22)**: declare transition tables for state-machine programs (`code-dev.md`, future others); rule `R_FSM_TRANSITION` blocks invalid transitions at validate-time.
2. **Neuron-reference coherence (FA-23)**: declare neuron names somewhere stable (registry? convention?); rule `R_NEURON_EXISTS` blocks `synapse-validate` on dangling references.
3. (Optional v2 scope) Cycle detection in suggestion graphs.

## Phase plan (preliminary)

| Phase            | Status | Owner       |
|------------------|--------|-------------|
| 0-seed           | active | this doc    |
| 1-study          | TBD    | TBD         |
| 2-design         | TBD    |             |
| 3-build          | TBD    |             |
| 4-validation     | TBD    |             |

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
