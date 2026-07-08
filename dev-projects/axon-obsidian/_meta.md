slug:            axon-obsidian
schema-version:  v4
status:          complete
phase:           complete
workflow-step:   code-dev-study
branch:          (none)
codebase:        (none)

## Working Context
Properly HOOK Obsidian: the compatibility artifacts exist but nothing wires them into a
usable Obsidian VAULT. Make it a first-class capability (like code-dev-graphify made the
graph DB) — a step that CONNECTS the AXON knowledge/code graph to Obsidian and lets the
owner navigate/UNDERSTAND it there.

Verified state (study seed 2026-07-08):
- The "graphify-obsidian integration" is a multi-phase initiative: P1 = AXON self code-map
  (code_graph.py export → workspace/_dashboards/axon-code-map.md, uses [[wikilinks]]);
  P-CD = per-project graphify graphs.
- The code-map is ONE file with INTRA-file anchor links ([[#heading|alias]]) — Obsidian-
  openable as a document but NOT a real vault: no .obsidian config anywhere, no cross-note
  [[Note]] structure, so Obsidian's graph view / backlinks (the point) show nothing.
- Export is MANUAL only (axon-graph export); nothing establishes/refreshes a vault; per-
  project graphs aren't exported to Obsidian.

Owner intent (2026-07-08): "obsidian compatibility is already there but not properly hooked
— standard project to connect and understand." Similar shape to code-dev-graphify.
