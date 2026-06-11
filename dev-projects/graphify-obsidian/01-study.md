# Study — Graphify Integration and Obsidian Check-up
Updated: 2026-06-11  ·  Iterations: 1  ·  AXON: 9/10  ·  User: 10/10

## Goal
Improve and expand the shipped graphify/obsidian integration (delivered 2026-06-09 by
`graphify-obsidian-integration`, all 5 PRs merged to main):
- **(a) Check-up fixes** — dead-code precision via REGISTRY-aware entrypoint detection,
  `axon-graph` doc/UX drift, present-path test coverage for the bridge.
- **(b) User-facing** — make the Obsidian map a living, auto-fresh artifact: richer
  projection (wikilinks, per-community notes, frontmatter), freshness/cron wiring.
- **(c) Expand** — build the unbuilt P-CD surfaces: graph-backed study/plan/review/
  test-map/workflows for code-dev target repos (impact already shipped; 5 remain).
- **(d) Discoverability** — surface these tools at the right moment instead of letting
  them get lost: contextual suggestion of axon-graph / graphify-bridge / code-symbols
  when the situation calls for them (owner addendum, 2026-06-11 — see Addendum below).

## Priorities
1. `dead-code` false-positive fix — teach `code_graph` the REGISTRY entrypoints
   (195 candidates today, mostly noise from subprocess/argparse dispatch invisibility).
2. Living Obsidian map — `workspace/_dashboards/axon-code-map.md` is ABSENT; export is
   one-shot, no freshness/cron hook. Make it a maintained artifact + richer vault projection.
3. P-CD surfaces (study/shadow node-id cache · plan/DAG code-derived depends_on ·
   review caller-cone · test-map real coverage · workflow s0 graphify-map) — all effort M,
   fail-degrade, designed in `graphify-obsidian-integration/study/code-dev-integration-design.md`.
4. `axon-graph` UX/doc — usage line omits routed `cluster`/`export`; results truncate at 20
   with no full-output option.
5. Present-path bridge tests — graphify is NOW INSTALLED locally (cli+module); only the
   absent-path contract is tested.
6. Contextual tool-surfacing (owner addendum) — suggest the graph tools at the moment
   they are useful; today they are findable only via find-program / list-tools / menu.

## Constraints
- Won't-do line intact: NO embeddings / dense RAG / RRF / HyDE — `rag-maturity-audit`
  58/70 is a deliberate ceiling (regression guard, not a target).
- Reduce-surface: extend existing tools/programs; avoid new tool surface.
- Core Rule 13 / R_NEW_NEEDS_TEST: every new neuron ships with tests; crucible gate before merge.
- Kernel (`axon/`) untouchable; deterministic stdlib drives anything gate-eligible;
  Graphify stays OPTIONAL (fail-degrade) and target-repos-only; LLM overlay advisory forever.

## Tech Stack
Python stdlib (`ast`, argparse, json) for the deterministic spine · optional `graphifyy`
(pin >=0.8.36,<0.9.0) · AEGIS policy gate (`tools/aegis_policy.py`) for the P3 overlay ·
AXON program layer (markdown neurons) + REGISTRY.json tool registration · pytest.

## Key Concepts
- Hybrid partition: AXON-self = in-house `code_graph` (deterministic, EXTRACTED, gate-eligible);
  target repos = optional `graphify-bridge`; semantics = INFERRED/AMBIGUOUS, advisory-only.
- Confidence ladder EXTRACTED → INFERRED → AMBIGUOUS mirrors R6 anti-fabrication.
- Fail-degrade contract: graphify absent ⇒ `{ok:false, degraded:true}`, stdlib fallback, never crash.
- graph.json schema gotcha: edge key is `links` (with `edges` fallback in the bridge).
- Live graph 2026-06-11: 209 modules / 1878 nodes / 3811 edges (drift since delivery: 206/1853/3776).
- God-nodes today: `_axon_paths` (91), `_axon_paths:default_workspace` (82), `predicate` (47), `dag` (44).

## Open Questions
- Which user-facing direction matters most to the owner: vault richness vs CLI UX?
- Does P-CD land inside this project or split into its own project?
- Map freshness mechanism: cron job vs freshness-tool registration vs on-demand only.

## Architecture Snapshot
(Populated in Phase 2 after codebase analysis)

## Sources
- file: tools/graphify_bridge.py (shadow ✓)
- file: tools/code_graph.py (shadow ✓)
- file: tools/code_symbols.py (shadow ✓)
- file: workspace/programs/axon-graph.md (shadow ✓)
- file: tests/test_graphify_bridge.py (shadow ✓)
- doc:  workspace/AXON-DOCS-ARCHITECTURE.md §Self-introspection
- doc:  workspace/AXON-DOCS-FAILURE-MODES.md (D4, §19)
- prior project: my-axon/dev-projects/graphify-obsidian-integration/
  (_meta, DELIVERY.md, masterplan.md, 04-log.md, study/code-dev-integration-design.md)
- live probes: graphify check (INSTALLED) · code_graph stats/dead-code/god-nodes ·
  workspace/_dashboards/axon-code-map.md absence

## Addendum — discoverability: suggest the right tool at the right moment (owner, 2026-06-11)
**Problem (owner's words):** these tools "get lost inside AXON and we can never find them."
167 programs / 144 tools; the graph tools are reachable only by already knowing their names
(find-program, list-tools, menu's SELF-OBSERVE section). Nothing surfaces `axon-graph affected`
when the user is about to refactor, or `graphify-bridge build` when code-dev loads a
multi-language target repo.

**Existing machinery to build on (extend, don't add — reduce-surface):**
- `orchestrator` / `synapse-suggest` — already rank next-step candidates against state;
  menu renders a suggestion footer (PR-112, `W:orchestrator-last-tick`). Gap: graph tools
  carry no synapse signals (e.g. `graphify_bonus` was designed in the P-CD spec but never wired).
- `anticipate` tool — auto-pop next-suggestion at phase transitions (R_STATE_SURFACED block).
- `dispatch` / `mode-detect` — free-text routing; "what calls X?" / "is this dead code?" /
  "map this repo" should route to axon-graph / graphify-bridge with confidence.
- `igap` — records exactly the moments when an instruction/tool was needed and not found;
  the igap log is evidence for WHERE suggestions should fire.

**Candidate trigger moments (to be settled in plan):**
- code-dev plan/review/pr phases → suggest `axon-graph affected <changed-symbol>` (caller cone).
- code-dev load of a non-Python/multi-language target → suggest `graphify-bridge build`.
- Owner asks about refactor risk / hubs → `axon-graph god-nodes`; "unused?" → `dead-code`.
- After N graph queries in a session → suggest `export` (the Obsidian map) for navigation.

**Scope note:** this generalizes beyond the graph tools — the same wiring pattern (synapse
signals + dispatch phrases + anticipation hooks per tool) is reusable for ANY lost tool.
Plan decision: keep scope to graph tools here, or carve a generic "tool-discoverability"
pattern with graph tools as the pilot.
