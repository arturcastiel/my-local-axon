# Project: AXON Improvements — the single umbrella for all AXON improvement work
slug:            axon-improvements
schema-version:  v4
status:          active
legacy:          false
phase:           tracking
workflow-step:   plan
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    [dag-consistency, axon-viz]
created:         2026-05-27
updated:         2026-05-27

## Working Context
- THE umbrella. Every internal AXON improvement is tracked HERE — as a nested
  sub-project (substantial work) or an inline backlog item (smaller work).
- RULE (anti-proliferation guardrail): new improvement work becomes a workstream or
  item in masterplan.md — NEVER a new top-level project.
- Sub-projects (nested folders, full detail preserved):
    dag-consistency/  — DAG-as-truth: gate → cascade → nested schema (1-gate→2→3-nest)
    axon-viz/         — projects/workflows/nested-DAG HTML visualizer (a tolerant → b full)
- Out of scope (separate top-level projects): axon-million (product/proof),
  reservoir-eng (domain), cpg-to-unstructure (external), lab2-* elifoot.
- Archives: ../finished/ (4), ../obsolete/ (28).

## Follow it up
masterplan.md = the single STATUS BOARD (open it first). Each sub-project folder = its detail.

## Start with
code-dev load axon-improvements → read the STATUS BOARD at the top of masterplan.md.
