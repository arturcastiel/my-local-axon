# Prohibition seeds
- No BLOCK gate on dead-key (bulk W: readers make it noise — measured). REPORT/WARN only.
- Parser migration must be proven behavior-equivalent (or behavior-improving with a re-baseline) by the migrated tool's existing tests — never a silent behavior change.
- No new graph unless a genuinely multi-hop/transitive finding appears (PR-007 stays decision-gated).
