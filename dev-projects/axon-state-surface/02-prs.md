# PR List — State-Surface Integrity
Updated: 2026-07-10  ·  Total PRs: 2  ·  Plan: council-approved v9 (hr-team 5/5, mean confidence 0.892)

## PR-001 — Snapshot code-resolves raw backup + plans (writer's resolver) + fixture value-pinning
- **Status:** merged
- **Complexity:** M
- **Scope:** tools/axon_state.py::cmd_menu_snapshot + tests
- **Depends on:** none
- **Why:** the two warning fields become code-resolved at the authoritative source, via the writer's own pointer (`_axon_paths.read_myaxon_pointer` → reader==writer); fail-soft; fixture value-pinning (a healthy fixture alone would have caught the 2026-07-10 false "not configured").
- **Spec:** 03-prs/PR-001.md (not written yet)

## PR-002 — menu.md + compiled twin consume snapshot; degraded-safe render; delete render resolution; static invariants
- **Status:** merged
- **Complexity:** M
- **Scope:** workspace/programs/menu.md + workspace/programs/compiled/menu.cmp.md + tests/synapse/corpus/menu.contract.json (+header, optional hygiene) + tests
- **Depends on:** PR-001
- **Why:** the render stops resolving paths (source from `snap` only); a degraded/failed snapshot renders "snapshot unavailable"/silent, never a false "not configured"; today's proven os-warn logic kept (no noise regression); six static neuron-text invariants (a)-(f) enforce it at the only CI-enforceable layer (run.py does not execute the render).
- **Spec:** 03-prs/PR-002.md (not written yet)
