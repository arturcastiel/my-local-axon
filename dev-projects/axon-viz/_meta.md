# Project: AXON Viz — projects / workflows / nested-DAG visualizer
slug:            axon-viz
schema-version:  v4
status:          active
legacy:          false
phase:           1-prototype
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
blocked-by:      dag-consistency   # (b) full build needs 3-nest's nested-DAG schema + 1-gate's R_DAG_CONSISTENT
depends-on:      dag-consistency
realizes:        axon-improvements (the visualization layer)
created:         2026-05-27
updated:         2026-05-27

## Working Context
- Escape the terminal: an HTML visualizer for projects, workflows, and NESTED DAGs
  (project ⊃ phase ⊃ PR ⊃ step), color-coded by status, click-to-expand.
- Architecture: generator (mechanical) → graph.json (canonical contract) → static
  cytoscape viewer.html. AXON regenerates graph.json; the HTML is authored once.
- Fidelity (a) PROTOTYPE now: tolerant parser over today's messy files + a gaps report;
  mostly-flat (projects + cross-project DAG + status).
- BLOCKER → dag-consistency: the durable (b) build consumes 3-nest's nested DAG.json
  schema and is enforced by 1-gate's R_DAG_CONSISTENT. The (a) prototype is tolerant,
  starts in PARALLEL, and its gaps report is the fix-list dag-consistency consumes.

## Start with
code-dev load axon-viz → build tools/project_graph.py (generator + tests), then
viewer.html (cytoscape). Run generator → open viewer.html in a browser.
