# PR List — Graphify Integration and Obsidian Check-up
Updated: 2026-06-11  ·  Total PRs: 10

## PR-001 — Make dead-code REGISTRY-aware (kill false positives)
- **Status:** merged (2b2596b, 2026-06-11)
- **Phase:** 1-checkup
- **Complexity:** M
- **Scope:** tools/code_graph.py (dead_code: REGISTRY.json script entrypoints + cmd_* conventions as entry set; optional entrypoint edges) · tests/test_code_graph.py · docs regen
- **Depends on:** none
- **Why:** 195 noise candidates make the tool untrustworthy today.
- **Spec:** 03-prs/PR-001.md (not written yet)

## PR-002 — Repair axon-graph usage doc + full-output UX
- **Status:** merged (3e2736d, 2026-06-11)
- **Phase:** 1-checkup
- **Complexity:** S
- **Scope:** workspace/programs/axon-graph.md (usage adds cluster/export; --out/full-list option) · program registry · contract test
- **Depends on:** none
- **Why:** cluster/export routed but undocumented; lists truncate at 20.
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — Add graphify-present-path tests (skip-if-absent)
- **Status:** merged (7b507c1, 2026-06-11)
- **Phase:** 1-checkup
- **Complexity:** S
- **Scope:** tests/test_graphify_bridge.py (tiny fixture repo; build + semantic smoke, pytest.mark.skipif graphify absent)
- **Depends on:** none
- **Why:** only the degrade contract is pinned; the live path is untested.
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — Persist the code map + freshness reconciler
- **Status:** merged (4e8017f, 2026-06-11)
- **Phase:** 2-living-map
- **Complexity:** M
- **Scope:** tools/freshness.py (code_map reconciler) · workspace/_dashboards/axon-code-map.md · tools/code_graph.py (canonical export path) · tests
- **Depends on:** PR-001
- **Why:** the Obsidian artifact must exist and stay current without manual runs.
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — Richer Obsidian projection (wikilinks, community pages)
- **Status:** merged (f92ead3, 2026-06-11)
- **Phase:** 2-living-map
- **Complexity:** M
- **Scope:** tools/code_graph.py export_markdown (wikilinks, frontmatter, per-community sections/pages) · tests (determinism pinned)
- **Depends on:** PR-004
- **Why:** the user-facing payoff — a navigable living map, not a flat dump.
- **Spec:** 03-prs/PR-005.md (not written yet)

## PR-006 — Contextual surfacing: synapse signals + dispatch + anticipate
- **Status:** merged (716b61c, 2026-06-11)
- **Phase:** 3-discoverability
- **Complexity:** M
- **Scope:** workspace/programs/axon-graph.md synapse block · dispatch trigger phrases · code-dev phase-transition anticipate hooks · tool-discoverability pattern doc
- **Depends on:** PR-002
- **Why:** owner addendum — tools must appear at the moment of need, not be hunted.
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — P-CD: s0 graphify-map study step + shadow node-id cache
- **Status:** merged (f6b79e8, 2026-06-11)
- **Phase:** 4-pcd
- **Complexity:** M
- **Scope:** workspace/programs/code-dev-study.md (s0 build target graph, persist my-axon/dev-projects/<slug>/graph/graph.json) · tools/shadow.py (node-id cache) · canonical workflow yml · tests
- **Depends on:** PR-003
- **Why:** build the target-repo graph once at study, reuse through every phase.
- **Spec:** 03-prs/PR-007.md (not written yet)

## PR-008 — P-CD: code-derived depends_on into plan DAG
- **Status:** merged (ec4f76f, 2026-06-11)
- **Phase:** 4-pcd
- **Complexity:** M
- **Scope:** workspace/programs/code-dev-plan.md · tools/dag.py (merge code-derived edges into build-from-prs) · tests
- **Depends on:** PR-007
- **Why:** fills the deprecated semantic-search slot with real edges.
- **Spec:** 03-prs/PR-008.md (not written yet)

## PR-009 — P-CD: review caller-cone + test-map real coverage
- **Status:** merged (65615e9, 2026-06-11)
- **Phase:** 4-pcd
- **Complexity:** M
- **Scope:** workspace/programs/code-dev-review.md (affected --depth 3 caller cone pre-build) · workspace/programs/code-dev-test-map.md (affected --filter kind=test) · tests
- **Depends on:** PR-007
- **Why:** transitive callers visible before build; coverage by call, not filename.
- **Spec:** 03-prs/PR-009.md (not written yet)

## PR-010 — P-CD: graphify-query adaptive synapse (workflows)
- **Status:** merged (1e58fa0, 2026-06-11)
- **Phase:** 4-pcd
- **Complexity:** S
- **Scope:** adaptive orchestrator synapse + graphify_bonus signal · tests
- **Depends on:** PR-007, PR-006
- **Why:** the adaptive workflow layer gains the same discoverability as chat.
- **Spec:** 03-prs/PR-010.md (not written yet)
