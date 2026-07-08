# Study — axon-obsidian
Updated: 2026-07-08 · AXON: 9/10 · Owner decisions locked

## Goal
Make Obsidian a properly-hooked, first-class capability: an invokable step that projects a
code-dev project's (always-fresh) graphify graph into a REAL Obsidian VAULT — cross-linked
notes + a .obsidian config — so the owner opens it and understands the target codebase's
structure via Obsidian's graph view / backlinks. Export-only, always-fresh, per-project.

## Owner decisions (2026-07-08)
- Vault content: PER-CODE-DEV-PROJECT GRAPHS (the target repo's graphify graph + the
  project's study/plan/PR artifacts as a map-of-content).
- The hook: invokable step + ALWAYS-FRESH (mirror code-dev-graphify).
- Direction: EXPORT-ONLY (AXON → Obsidian) for v1; two-way round-trip is v2.

## Verified state (the "already there but not hooked")
- graphify-obsidian is a multi-phase initiative; artifacts use Obsidian [[wikilink]] syntax
  (the AXON self-map workspace/_dashboards/axon-code-map.md) — Obsidian-openable.
- BUT: no .obsidian vault config exists anywhere; the map is ONE file with INTRA-file anchor
  links ([[#heading]]), so Obsidian's graph view / backlinks (the point) show nothing; export
  is manual-only; per-project graphify graphs never reach Obsidian.
- The per-project graph.json lives at {project}/graph/graph.json (built by code-dev-graphify)
  and is NOW ALWAYS-FRESH (code-dev-graphify PR-02: staleness + refresh-if-stale). Nodes carry
  id/label/source_file; links carry source/target/confidence.

## Design direction (composes with graphify freshness)
- **The vault** at {project}/obsidian/: a real Obsidian vault —
  - `.obsidian/` config (app + graph-view settings) so opening the folder "just works".
  - one NOTE per source file (node cluster by source_file), each with frontmatter (tags,
    path) and body listing its symbols; edges → cross-note `[[file]]` wikilinks so Obsidian's
    graph view shows the real call/dep structure.
  - an INDEX / map-of-content note linking the project's study/plan/PR artifacts + the file
    notes — the "understand" entry point.
- **The exporter** (deterministic): reads graph.json → projects nodes→notes + edges→
  wikilinks + writes the .obsidian config. One-way (authoring the vault is illegal — it is a
  derived VIEW, like the doctrine DAG ledger).
- **Freshness (cheap, composes)**: the vault build FIRST ensures the graph is fresh (reuse
  graphify_bridge staleness/refresh), then projects. A vault-provenance marker (built-from
  graph hash) makes a re-invoke a no-op when nothing changed. So the vault is never stale vs
  the target repo — the graphify guarantee propagates.
- **The program `code-dev-obsidian`**: standalone, any-phase. Resolve the project graph
  (require/build the graphify DB), ensure fresh, export the vault, confirm ("open {vault} in
  Obsidian"). Fail-degrade (graphify/graph absent → advisory info, no-op).
- **Advisory, export-only.**

## Priorities → PRs (see 02-plan.md)
1. The vault exporter core (graph.json → cross-linked notes + .obsidian config).
2. Always-fresh: ensure-graph-fresh before export + vault provenance (re-invoke is a no-op
   when unchanged).
3. The code-dev-obsidian program (invokable, any-phase, fail-degrade).
4. The map-of-content: study/plan/PR artifacts as index notes + recommended-early surfacing.
5. Docs + tests + registration.

## Constraints
export-only (the vault is a derived VIEW, never hand-authored back) · always-fresh (built
from the fresh graph; never stale vs the target) · advisory + fail-degrade · reduce-surface
(reuse graphify_bridge freshness; a thin exporter) · full suite green per merge · tests reach
the real path (a real graph.json fixture → a real vault).

## Self-assessment
9/10 — the design composes directly on the just-verified graphify freshness (the graph is
already always-fresh; the vault is a deterministic projection of it), and the concrete gap
(no vault, intra-file links, unhooked) is precisely located. Held below 10 by one unknown the
plan must pin: the right note GRANULARITY (per-file vs per-symbol vs per-community) for a
useful Obsidian graph view on a large target repo — start per-file, revisit if noisy.
