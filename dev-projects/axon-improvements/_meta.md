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
sub-projects:    [dont-do-enforce, dag-consistency, axon-viz, axon-tests, axon-ascent, axon-memory, axon-gap-closure, axon-wiring-gaps, axon-claude-code-consistency, axon-copilot-anchor, axon-copilot-consistency, copilot-deviation-study]
created:         2026-05-27
updated:         2026-05-27

## Working Context
- THE umbrella. Every internal AXON improvement is tracked HERE — as a nested
  sub-project (12 active workstreams) or an inline backlog item (smaller work).
- RULE (anti-proliferation guardrail): new improvement work becomes a workstream or
  item in masterplan.md — NEVER a new top-level project.
- CANONICAL tree = /home/arturcastiel/projects/new-axon/axon (TNO). /mnt/c is stale code;
  my-axon data is symlinked-shared. Persona repointed 2026-05-27 (boots new-axon).
- 2026-05-27 EVIDENCE AUDIT: 9 projects were WRONGLY archived (had open work) → RESTORED
  here as workstreams; 4 truly finished (../finished/); 19 truly obsolete (../obsolete/).
- Out of scope (separate top-level projects): axon-million (product/proof), reservoir-eng,
  cpg-to-unstructure, lab2-* elifoot.

## Follow it up
masterplan.md = the single STATUS BOARD (open it first). Each sub-project folder = its detail.

## Start with
code-dev load axon-improvements → read the STATUS BOARD at the top of masterplan.md.
