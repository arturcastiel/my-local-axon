# PR-2 — Deterministic organization + Obsidian map (P2)

Status: merged (MR !154, squash 139a014)
Branch: graphify-obsidian/pr-2-organize → graphify-obsidian-integration
Depends-on: PR-1 (extends tools/code_graph.py)
Phase: execute

## Goal
The "organize better" deliverable, fully deterministic + zero-dependency: cluster AXON's own code-graph into
communities and render a human-navigable **Obsidian/markdown map**. Extends `code_graph` (no new tool → reduce-surface).

## Change
- **Extend** `tools/code_graph.py`:
  - `cluster` — deterministic community detection (label propagation: sorted node processing, smallest-label
    tie-break, fixed iteration cap → byte-identical across runs). Communities = AXON's natural subsystems.
  - `export` — write a markdown cluster report (`--out`): communities, their members, and the top god-nodes —
    openable in Obsidian as the "map of AXON". Deterministic.
- **Extend** `workspace/programs/axon-graph.md` — route `cluster` and `export`.
- **Tests** — clustering determinism (two runs identical), cluster membership on a fixture, export shape.
- **Docs** — update the code-graph registry `args` + axon-graph help; Guarded-by row.

## Acceptance criteria
- [ ] `code-graph cluster` → stable communities, byte-identical across runs.
- [ ] `code-graph export --out x.md` → a markdown map (communities + members + god-nodes).
- [ ] axon-graph routes cluster/export; subcommands literal (R_TOOL_CALL_EXISTS).
- [ ] Gates green incl. crucible.

## Out of scope
The full deps/call_graph program-graph merge (noted follow-on); Graphify (P-CD); LLM (P3).
