# Plan — code-dev-graphify
Updated: 2026-07-08 · 5 PRs · AXON: 8.5/10 · Owner: pending gate

## Spine
Freshness is the load-bearing guarantee (owner: persistence is earned by always-fresh). The
whole plan hangs off a provenance+staleness mechanism (absent today) and a query layer that
refreshes-if-stale before every answer — so the persisted DB can never serve outdated data.

## Decisions locked (owner 2026-07-08)
- D1 shape: standalone `code-dev-graphify` program + recommended-early surfacing.
- D2 query surface: AXON-designed, freshness-governed → a fresh-guaranteed wrapper over the
  existing affected/file-nodes/pr-edges + a couple of ergonomic queries (callers, impact).
- D3 authority: advisory, fail-degrade.
- D4 (AXON) staleness signal: git HEAD + dirty primary; content-hash fallback for non-git.

## PRs
- PR-01 — Provenance + staleness. graphify_bridge gains: build records a graph.meta.json
  sidecar {target_repo, git_commit, dirty, content_hash, built_ts, graphify_version}; a
  `staleness` action comparing live target vs recorded provenance → {fresh|stale, reason}.
- PR-02 — Fresh-guaranteed query layer. A `query` surface (affected/file-nodes/callers/
  impact/pr-edges) that staleness-checks first and runs the incremental refresh + rewrites
  provenance when stale, THEN answers — freshness by construction. Advisory + fail-degrade.
- PR-03 — The `code-dev-graphify` program. Standalone, any-phase: resolve target repo (from
  _meta codebase; human-handoff if unset), build + record provenance, STORE(W:graphify-db),
  confirm (nodes/edges/provenance card). Fail-degrade if graphify absent.
- PR-04 — Recommended-early + route existing queries. code-dev-study / code-dev-new surface
  "run code-dev-graphify" at project start; the existing opportunistic graphify call-sites
  (plan/review/test-map/knowledge-impact/review-scope) route through the fresh-guaranteed
  layer so none can read a stale graph.
- PR-05 — Docs + tests + registration. AXON-DOCS-GRAPHIFY page (Guarded-by); tests for
  provenance/staleness/refresh + the program; register the program + any new tool surface;
  mirror/doc counts.

## Constraints
fail-degrade · advisory-only (never a gate) · reduce-surface (extend graphify_bridge) ·
freshness load-bearing (no stale answers) · full suite green per merge · tests reach the
real path (a real target repo fixture, real git provenance — no faked staleness).

## Open probes for implementation (study self-graded)
- incremental refresh cost on a large repo (bound it; if slow, cache + only refresh on a
  real staleness signal, which the git-HEAD check already gives cheaply).
- non-git target fallback (content-hash granularity) — pin with a fixture.
