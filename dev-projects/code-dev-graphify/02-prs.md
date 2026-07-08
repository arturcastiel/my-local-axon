# PR List — code-dev-graphify
Total: 5 PRs · advisory + fail-degrade throughout · freshness is load-bearing

## PR-01 [MERGED] — Provenance + staleness
- **Status:** merged
- graphify_bridge: build writes a graph.meta.json sidecar {target_repo, git_commit, dirty,
  content_hash, built_ts, graphify_version} beside graph.json; `staleness --graph P` compares
  the live target vs recorded provenance → {fresh|stale, reason, signal}. git HEAD+dirty
  primary; content-hash fallback (tracked-file list + size/mtime) for non-git targets.

## PR-02 [MERGED] — Fresh-guaranteed query layer
- **Status:** merged
- `query <kind> --graph P [args]` where kind ∈ affected|file-nodes|callers|impact|pr-edges.
  It staleness-checks, runs the incremental refresh + rewrites provenance when stale, THEN
  answers — a query can never serve stale data. callers/impact are ergonomic wrappers over
  the graph links. Advisory + fail-degrade (graphify absent → {degraded, note}, never raise).

## PR-03 [MERGED] — The code-dev-graphify program
- **Status:** merged
- workspace/programs/code-dev-graphify.md: standalone, any-phase. Resolve target repo (from
  _meta codebase; human-handoff if unset), TOOL(graphify-bridge, build) + provenance, STORE
  (W:graphify-db, graph-path), confirm with a nodes/edges/provenance card. Fail-degrade if
  graphify absent (one info line, DONE). Neuron-conformant (role reader/router).

## PR-04 [MERGED] — Recommended-early + route existing queries through the fresh layer
- **Status:** merged
- code-dev-study / code-dev-new surface "run code-dev-graphify" at project start (advisory
  nudge). The existing opportunistic graphify call-sites route through the query layer so
  none reads a stale graph. (Minimal, additive edits to the existing programs.)

## PR-05 [MERGED] — Docs + tests + registration
- **Status:** merged
- AXON-DOCS-GRAPHIFY page (## Guarded by); tests: provenance recorded, staleness detects a
  moved target (real git fixture), refresh-on-query, non-git fallback, program conformance,
  fail-degrade. Register the program; mirror + doc counts lockstep.
