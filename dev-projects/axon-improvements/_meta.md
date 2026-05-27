# Project: AXON Improvements — the single consolidated plan
slug:            axon-improvements
schema-version:  v4
status:          active
legacy:          false
phase:           1-backlog
workflow-step:   plan
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-05-27
updated:         2026-05-27

## Working Context
- THE single home for all internal AXON improvement work. Consolidates 29 scattered
  projects (now under `../obsolete/`) and references 4 finished (`../finished/`).
- Out of scope — kept as separate top-level projects (NOT folded here):
    axon-million      → the product / proof umbrella (consumes Tiers 1 & 2 below)
    reservoir-eng     → petroleum domain (also supplies benchmark goals 1 & 2)
    cpg-to-unstructure→ external repo
    lab2-* elifoot    → game clone (10 projects)
- The backlog (masterplan.md) is organized by the cross-project DAG:
    Foundation/bug-free  →  Proof feeders  →  Wedge support  →  Subsystems  →  Distribution.
- Each backlog item carries its SOURCE project + last phase, so no scope is lost.

## Start with
code-dev load axon-improvements → work Tier 0 (Foundation / bug-free gates) — those
gate "sellable". The proof (axon-million P3, the rigorous MCP arm) runs in parallel.
