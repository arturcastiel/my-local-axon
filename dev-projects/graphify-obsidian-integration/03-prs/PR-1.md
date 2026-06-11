# PR-1 — In-house stdlib code-graph (AXON self-introspection, P1)

Status: merged
Merged: MR !153 → graphify-obsidian-integration (squash 80b3282) · crucible green
Branch: graphify-obsidian/pr-1-code-graph → graphify-obsidian-integration
Depends-on: PR-0 (reuses tools/code_symbols.py)
Phase: execute

## Goal
Give AXON a **deterministic graph of its own Python code** — the capability the study's probe #7 found
missing (the 6 existing introspection tools graph the markdown/registry layer, none parse Python AST).
Pure stdlib `ast`, zero dependency, byte-reproducible. This is the **hybrid decision's AXON-self half**:
Graphify is reserved for multi-language *target* repos (P-CD); AXON's *own* gate-eligible graph stays in-house.

## Change
- **New** `tools/code_graph.py` — builds a deterministic node/edge graph over a Python tree (default `tools/`):
  - nodes: module / function / class (id, file, lineno, kind)
  - edges: `imports` (module→module), `contains` (module→symbol), `calls` (symbol→symbol, intra-tree)
  - every edge tagged `confidence: EXTRACTED` (AST-derived); deterministic order (sorted), byte-identical rebuilds.
  - subcommands: `build [--root <dir>] [--out <json>]`, `affected <symbol>` (reverse blast-radius),
    `dead-code` (defined-but-never-called public functions), `god-nodes [--top N]` (highest-degree), `stats`.
  - reuses `code_symbols` for symbol enumeration where useful; read-only; no network.
- **New** `workspace/programs/axon-graph.md` — program wrapper invoking `code-graph` (satisfies
  R_NO_ORPHAN_TOOLS/liveness): `axon-graph build|affected|dead-code|god-nodes|stats`.
- **Register** `code-graph` in `tools/REGISTRY.json` (ACTIVE, category meta or code-dev).
- **Test** `tests/test_code_graph.py` — build determinism (two builds identical), affected/dead-code/god-nodes
  correctness on a fixture tree, empty/parse-error safety.
- **Docs** add a Guarded-by row; bump CONTEXT.md tool count (159).

## Acceptance criteria
- [ ] `code-graph build` over a fixture tree → stable nodes+edges, 100% EXTRACTED, byte-identical on rebuild.
- [ ] `affected X` returns the transitive callers/importers of X (reverse reachability).
- [ ] `dead-code` lists public functions with no inbound call edge.
- [ ] Parse error / empty file ⇒ skipped gracefully (no crash).
- [ ] `axon-graph` program invokes the tool (liveness: not orphan).
- [ ] Gates green: registry-drift, liveness, lint-paths, docgen, tests, **crucible**.

## Determinism gate
Two consecutive `build` runs MUST produce byte-identical `graph.json` (the AXON-native seed=42 analogue).

## Out of scope
Graphify, Leiden clustering, the Obsidian map (P2); target-repo graphs (P-CD); any LLM path (P3).
