# code-dev-graphify — log

- COMPLETE 2026-07-08: 5 PRs. graphify is now a first-class, invokable code-dev step with a
  persistent, ALWAYS-FRESH query DB. Provenance sidecar + staleness detection (the verified
  core gap); fresh-guaranteed query layer (refresh-if-stale before every answer — freshness
  by construction, which earns persistence); the code-dev-graphify program (any-phase,
  fail-degrade, recommended-early); 6 existing call-sites routed through the fresh layer.
  Suite 5279/0/15. Owner decisions honored: standalone program + recommended-early, advisory,
  always-fresh. A stale compiled mirror rippled through lossless-mandate into doctrine's
  preflight (19 test cascade) — fixed by updating the .cmp.md in lockstep.
- 2026-07-09: pointer-repair (axon-stale-pointers): pending phases retro-stamped done --force — RATIONALE: this log records delivery/completion; the manifest was never advanced at the time (the silent-pending class). Force is recorded here per repair rules.
