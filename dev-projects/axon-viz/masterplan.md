# Masterplan — AXON Viz (escape the terminal)

> An HTML visualizer for AXON projects, workflows, and nested DAGs. Built because the
> terminal can't render nested/interactive graphs. Fidelity **(a) PROTOTYPE** first.

## Architecture — the contract decides everything
```
messy files ─► project_graph.py (generator, tolerant) ─► graph.json (canonical) ─► viewer.html (cytoscape, static)
```
- The generator absorbs the mess ONCE; the viewer only ever reads `graph.json`.
- AXON regenerates `graph.json` (mechanical, no fabrication); `viewer.html` is authored once and reused.
- NOT: AXON hand-emitting HTML per request (drifts, not a source of truth).

## graph.json schema (reuse + extend the existing DAG.json shape)
```json
{
  "generated": "<iso>",
  "nodes": [{"id","label","type":"project|phase|pr|step","status","phase","source","graph?":{...}}],
  "edges": [{"from","to","kind":"depends|blocks|builds-on|feeds"}]
}
```
- Reuses the existing `{from,to,kind}` edge shape from `*/03-prs/DAG.json`.
- `graph?` lets a node embed a nested sub-DAG → the nested/adaptive view. (b) populates this
  from dag-consistency **3-nest** (project ⊃ phase ⊃ PR).

## Phase (a) — PROTOTYPE  (this build · can start NOW, tolerant)
### Step 1 — generator `tools/project_graph.py` (+ tests · R_NEW_NEEDS_TEST)
- Tolerant-parse `dev-projects/*/_meta.md` (slug, status, phase, blocked-by, builds-on, parent),
  tag `finished/*` and `obsolete/*` by folder, pull `axon-improvements` tiers.
- Emit `graph.json` (flat project DAG + cross-project edges) **+ a GAPS report**
  (unparsed files — e.g. axon-docs = 0 fields). The gaps report is dag-consistency's fix-list.
### Step 2 — `viewer.html` (cytoscape.js, self-contained, no build step)
- Load `graph.json`; projects = nodes, deps = edges; color by status
  (active=green · finished=blue · obsolete=grey · blocked=amber); zoom/pan; click → details.
### Step 3 — wire + doc
- Register `project-graph` tool; README: "regenerate graph.json → open viewer.html".

## Phase (b) — FULL  (after dag-consistency)
- Recursive NESTED DAGs (project ⊃ phase ⊃ PR ⊃ step) via dag-consistency **3-nest**.
- Schema validator so `_meta.md` + `DAG.json` can't drift (rides **1-gate** R_DAG_CONSISTENT).
- cron-regenerated `graph.json`.

## BLOCKER
- **dag-consistency** (phase 1-gate now): (b) needs **3-nest**'s nested-DAG schema +
  **1-gate**'s enforcement. (a) is tolerant → parallel; its gaps report feeds dag-consistency.

## Discipline
New tool + viewer ⇒ tests in the same change; generation mechanical; you run the gate; you commit.
