# High-Level Plan — Graphify Integration and Obsidian Check-up
Updated: 2026-06-11  ·  Iterations: 1  ·  AXON: 9/10  ·  User: 9/10 (text approval)

## Context (from Phase 1)
Goal: Improve and expand the shipped graphify/obsidian integration — (a) check-up fixes,
(b) living Obsidian map for users, (c) the unbuilt P-CD surfaces, (d) discoverability:
surface the graph tools at the moment of need (owner addendum 2026-06-11).

## Architecture Overview
Codebase is AXON itself: deterministic Python tool layer (`tools/*.py`, registered in
`tools/REGISTRY.json`, dispatched via `axon.py`) + markdown program neurons
(`workspace/programs/*.md`, synapse metadata drives dispatch/orchestrator) + gates
(crucible, freshness, registry-drift, R_NEW_NEEDS_TEST). The integration under work:
`code-graph` / `code-symbols` (ACTIVE, stdlib, gate-eligible) · `graphify-bridge`
(OPTIONAL, fail-degrade, target repos) · `axon-graph` (program surface).
Governing partition (inviolable design law): deterministic stdlib drives gates;
Graphify optional + target-repos-only; LLM overlay advisory forever.

## Wave 1 — Check-up (fix what's shipped)
Make the existing tools trustworthy. PR-001 teaches `dead_code()` the REGISTRY
entrypoints (kills ~195-candidate false-positive noise — the dispatch layer is invisible
to ast call edges). PR-002 repairs `axon-graph` doc drift (cluster/export routed but
undocumented) and adds full-output UX. PR-003 adds graphify-present-path tests
(skip-if-absent) now that graphify is installed locally.

## Wave 2 — Living Obsidian map (user-facing)
PR-004 persists `workspace/_dashboards/axon-code-map.md` and registers a `code_map`
reconciler in `tools/freshness.py` (8 reconcilers today; the weekly freshness cron then
auto-heals the map — no manual export). PR-005 enriches the projection: wikilinks,
per-community pages, frontmatter — deterministic and byte-reproducible, pinned by tests.

## Wave 3 — Discoverability (owner addendum)
PR-006 wires the graph tools into machinery AXON already has: synapse trigger signals
(the never-wired `graphify_bonus` from the P-CD spec), dispatch phrases ("what calls X",
"is this dead code", "map this repo"), anticipate hooks at code-dev phase transitions.
Graph tools are the pilot of a reusable tool-discoverability pattern.

## Wave 4 — P-CD surfaces (expand to target repos)
The designed-but-unbuilt track from `graphify-obsidian-integration/study/
code-dev-integration-design.md`: build the target-repo graph once at study, reuse in
plan/review/test-map/workflows. PR-007 study s0 step + shadow node-id cache; PR-008
code-derived depends_on into the plan DAG; PR-009 review caller-cone + test-map real
coverage; PR-010 graphify-query adaptive synapse. All fail-degrade, advisory,
confidence-tiered. Written to lift out cleanly if owner later splits this wave.

## Constraints carried from study
Won't-do line intact (no embeddings/dense RAG; rag-maturity 58/70 is a ceiling) ·
reduce-surface (extend, don't add tools) · R13 tests with every neuron · kernel
untouchable · crucible green before merge · merge/test-execution gated green-only.

## Execution authorization
Autonomous-mode grant ACTIVE (commit/push/pr-create/merge-squash; destructive + kernel
denied) × AEGIS `_policy.md` (develop=grant, test-execution=green-only, merge=green-only,
build=human). Owner directive: run end-to-end without check-ins; stop on red gates or
authorization boundaries.
