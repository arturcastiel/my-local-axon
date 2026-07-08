# Study — code-dev-graphify
Updated: 2026-07-08 · AXON: 9/10 · Owner decisions locked (see below)

## Goal
Make graphify a first-class, invokable code-dev STEP that establishes the target repo's
code graph as a PERSISTENT, ALWAYS-FRESH database, queried throughout the project (advisory).

## Owner decisions (2026-07-08)
- Step shape: BOTH — a standalone `code-dev-graphify` program AND recommended-early
  (surfaced at project start), invokable at any phase.
- Query surface: owner-delegated to AXON, with the GOVERNING CONSTRAINT — "if we can ensure
  it is always fresh and not outdated it can persist". Freshness is the load-bearing
  requirement; persistence is earned by guaranteed freshness.
- Authority: ADVISORY — informs, never blocks; fail-degrade when graphify is absent.

## What exists today (verified against source)
- graphify_bridge.py is INSTALLED + working (check → ok, not degraded; cli at
  ~/.local/bin/graphify, module present).
- Underlying build = `graphify update <repo>` — INCREMENTAL (code-dev-study.md:137 "re-runs
  on resume are cheap"); build() copies the produced graph.json to {project}/graph/graph.json.
- Query surface already implemented in graphify_bridge: affected (reverse blast-radius, typed
  by confidence EXTRACTED/INFERRED/AMBIGUOUS), file-nodes, pr-edges (advisory PR dep hints),
  semantic (INERT/AEGIS-gated).
- Already referenced by 6 programs: code-dev-study (builds it as advisory "s0"),
  code-dev-plan (pr-edges hints), code-dev-review, code-dev-test-map, code-dev-review-scope,
  code-dev-knowledge-impact. Graph path convention: {project}/graph/graph.json.

## The gaps the owner named + the verified core gap
1. Build is buried in code-dev-study — skip study / start mid-project → no graph.
2. Advisory-only + opportunistic — nothing establishes "the DB is live, query it".
3. **THE CORE GAP (verified): NO PROVENANCE / STALENESS mechanism.** build() records no
   target-commit/hash/timestamp, so nothing can tell whether graph.json is stale vs the
   target repo's current state. Without this, "persist" = "silently serve outdated data" —
   exactly what the owner forbade. This is the load-bearing new work.

## Design direction (freshness-centric)
- **Provenance sidecar**: on build, record graph.meta.json {target_repo, git_commit,
  dirty, content_hash, built_ts, graphify_version} beside graph.json.
- **Staleness signal**: primary = target repo git HEAD + working-tree dirty; fallback (no
  git) = a cheap content hash (tracked-file list + mtimes/size). Stale iff the live signal
  ≠ recorded provenance.
- **Fresh-guaranteed query layer**: EVERY query staleness-checks first; if stale, it runs
  the incremental `graphify update` + re-copies + rewrites provenance, THEN answers. So a
  query can never return outdated data — freshness by construction, which is what earns
  persistence.
- **The program `code-dev-graphify`**: standalone, any-phase. Resolve target repo (from
  _meta codebase; prompt/human-handoff if unset), build + record provenance, mark the DB
  active (W:graphify-db = path), confirm with a summary (nodes/edges/provenance). Fail-
  degrade if graphify absent (one info line, project proceeds — today's posture).
- **Recommended-early**: code-dev-study / code-dev-new surface "run code-dev-graphify" at
  project start; the existing opportunistic query call-sites route through the fresh-
  guaranteed layer so none can read a stale graph.
- **Advisory always**: confidence-tiered (AMBIGUOUS never auto-followed); never a gate.

## Priorities → PRs (see 02-plan.md)
1. Provenance + staleness (the core gap).
2. Fresh-guaranteed query layer (the "always fresh" guarantee).
3. The code-dev-graphify program (invokable, any-phase, target-repo resolution, fail-degrade).
4. Recommended-early surfacing + route existing queries through the fresh layer.
5. Docs + tests + registration.

## Constraints
Fail-degrade (graphify absent → advisory info, never a hard failure) · advisory-only (never
a gate) · reduce-surface (extend graphify_bridge, don't fork it) · freshness is
load-bearing (a query must never serve stale data) · full repo suite green per merge.

## Self-assessment
9/10 — the capability + query surface exist and are verified; the one genuine gap
(provenance/staleness) is precisely located and the incremental-refresh primitive that
makes "always fresh" cheap is confirmed. Held below 10 by two unknowns the plan must probe:
the exact incrementality cost on a large target repo, and the non-git target fallback's
reliability (content-hash granularity).
