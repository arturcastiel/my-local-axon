# Plan — axon-obsidian
Updated: 2026-07-08 · 5 PRs · AXON: 8.5/10 · Owner: pending gate

## Spine
Export-only + always-fresh. The vault is a DERIVED VIEW of the (already always-fresh)
per-project graphify graph — projecting nodes→notes and edges→[[wikilinks]] into a real
Obsidian vault, rebuilt from the fresh graph so it is never stale vs the target repo.

## Decisions locked (owner 2026-07-08)
- D1 content: per-code-dev-project graph → vault (+ study/plan/PR map-of-content).
- D2 hook: invokable step + always-fresh (mirror code-dev-graphify).
- D3 direction: export-only (v1); two-way is v2.
- D4 (AXON) granularity: one note per SOURCE FILE (revisit if the graph view is noisy).

## PRs
- PR-01 — The vault exporter core. New tools/obsidian_export.py: graph.json → a real Obsidian
  vault at {out}: one note per source_file (frontmatter + symbol list), edges → cross-note
  [[file]] wikilinks, a .obsidian/ config (app.json + graph.json view settings). Deterministic,
  one-way. Fail-degrade on a missing/unparseable graph.
- PR-02 — Always-fresh + vault provenance. Before export, ensure the underlying graph is fresh
  (reuse graphify_bridge staleness/refresh). Write a vault-provenance marker (source graph
  hash + built_ts); re-invoke is a no-op when the graph is unchanged. So the vault is never
  stale vs the target repo — the graphify freshness guarantee propagates.
- PR-03 — The code-dev-obsidian program. workspace/programs/code-dev-obsidian.md: standalone,
  any-phase. Resolve the project graph (require the graphify DB; nudge to run code-dev-graphify
  if absent), ensure fresh, export the vault, STORE(W:obsidian-vault), confirm with an
  "open {vault} in Obsidian" card. Fail-degrade if graphify/graph absent.
- PR-04 — Map-of-content + recommended-early. The vault index note links the project's
  study/plan/PR artifacts (the "understand" entry point). code-dev-graphify / code-dev-new
  surface "code-dev obsidian" as a follow-on (recommended after the graph DB is built).
- PR-05 — Docs + tests + registration. AXON-DOCS-OBSIDIAN page (## Guarded by); tests: a real
  graph.json → a real vault (notes + wikilinks + .obsidian config), freshness no-op on
  unchanged, rebuild on changed, fail-degrade, program conformance + tool-call shapes. Register
  the program + tool; mirror + doc counts lockstep.

## Constraints
export-only (derived view, never authored back) · always-fresh · advisory + fail-degrade ·
reduce-surface (reuse graphify freshness) · full suite green per merge · tests reach the real
path · compiled-mirror lockstep if any edited program has a .cmp.md.

## Open probe
note granularity on a large repo (per-file default; if the Obsidian graph is noisy, offer a
per-community grouping) — pin with a fixture, revisit only if needed.
