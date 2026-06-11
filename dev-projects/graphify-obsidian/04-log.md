# Implementation Log — Graphify Integration and Obsidian Check-up
## Entries
_No entries yet. Run: code-dev log_

### PR-001 — registry-aware dead-code · commit 2b2596b · 2026-06-11
- dead_code() rewritten around five deterministic liveness signals (name-refs, attr-call
  evidence, registry cmd_* convention via _axon_registry accessor, subprocess transparency,
  test-only split). Graph stays 100% EXTRACTED — signals never touch links.
- Live impact: 195 → 19 candidates (+7 test_only) — 90% noise cut. Measured-first approach
  (composition probe before design): 38 test-called, cmd_* name-reference class, instance-method
  attr calls were the dominant false-positive sources.
- Gate caught F22 (single-registry-accessor) on first crucible run — fixed by importing
  load_registry instead of hardcoding the path. Second run green (30 controls, residue-lint
  WARN pre-existing). 7 new tests; 2680-test suite green.
- MERGED: squash to main, pushed 06c49f8..2b2596b. Branch deleted.

### PR-002 — axon-graph usage repair + --out UX · commit 3e2736d · 2026-06-11
- Usage line lists all 7 routed subcommands; dead-code render surfaces registry-aware fields;
  >20 truncation now explicit with --out pointer. --out added to 5 query subcommands.
- New contract test: usage line must mention every routed subcommand (drift-class kill).
- Process lesson: commit-trailer lint BLOCKS internal PR-N references in commit messages —
  first commit attempt rejected, message rewritten without them. Lint before commit, always.
- MERGED: squash to main, pushed 2b2596b..3e2736d. Branch deleted.

### PR-003 — graphify-present-path tests · commit 7b507c1 · 2026-06-11
- Probed real graphify on a fixture repo BEFORE authoring tests (label helper() ↔ id
  alpha_helper; caller in blast radius; links schema confirmed). 3 present-path tests,
  module-scoped single build, skipif-guarded (guard verified by forcing availability false).
- semantic happy path deliberately untested (web grant + network); its refusal contract
  already pinned. Wave 1 (checkup) COMPLETE: PR-001 + PR-002 + PR-003 all merged.
- MERGED: squash to main, pushed 3e2736d..7b507c1. Branch deleted.

### PR-004 — living code map + freshness reconciler · commit 4e8017f · 2026-06-11
- Map committed (1883 nodes / 92 communities); code_map reconciler in freshness (check =
  regenerate+byte-compare, refresh = export --canonical); weekly cron now auto-heals it.
- Gate caught F21 (per-file sys.path bootstrap in the reconciler) — replaced with top-level
  sibling import. Health test_score_100 flake investigated: transient, passes consistently
  in isolation; second full-suite run green.
- MERGED: squash to main, pushed 7b507c1..4e8017f. Branch deleted.

### PR-005 — rich Obsidian projection · commit f92ead3 · 2026-06-11
- export_markdown v2: frontmatter, wikilink index over 92 communities, god-node→subsystem
  links, file:lineno member rows. Single-file design kept (multi-page vault = deferred NICE).
- Map regenerated + committed; code_map reconciler unchanged and green.
- Wave 2 (living map) COMPLETE: PR-004 + PR-005 merged. Project: 5/10 PRs (50% by count).
- MERGED: squash to main, pushed 4e8017f..f92ead3. Branch deleted.

### PR-006 — contextual tool surfacing · commit 716b61c · 2026-06-11
- Measured-first: baseline routing for 4 graph phrasings (3 wrong). Shipped the 3-lever
  pattern: dispatch-phrases header (indexer+matcher) · sibling cross-links (deps↔axon-graph,
  honest about shared phrasing) · phase-entry tips (review/plan). Architecture doc section.
- Measured-after: 4 unambiguous intents top-rank; ambiguous surface top-3; controls clean.
  Discovery: long phrase lines DILUTE TF-IDF — short lists win. igap gap (T:9) closed.
- Wave 3 (discoverability — owner addendum) COMPLETE. Project: 6/10 PRs (60%).
- MERGED: squash to main, pushed f92ead3..716b61c. Branch deleted.

### PR-007 — study graph step + shadow node-id cache · commit f6b79e8 · 2026-06-11
- P-CD spine live: S0 GRAPHIFY-MAP in study (build once, persist per-project, fail-degrade);
  shadows cache graph-node-ids; bridge file-nodes owns resolution. Fixed latent build(out)
  ignore defect. Design deviation recorded: S0 inside study, not a 2nd workflow node.
- Gate caught: workflow schema rejects extra node fields (note:) — comment block instead.
- MERGED: squash to main, pushed 716b61c..f6b79e8. Branch deleted. 7/10 PRs (70%).

### PR-008 — code-derived depends_on · commit ec4f76f · 2026-06-11
- pr-edges bridge subcommand (caller-depends-on-callee, advisory INFERRED); plan merges
  hints additively into dag build-from-prs; dag.py untouched. 8/10 PRs (80%).
- MERGED: squash to main, pushed f6b79e8..ec4f76f. Branch deleted.

### PR-009 — review caller-cone + call-based coverage · commit 65615e9 · 2026-06-11
- Review-scope renders advisory caller cone pre-build; test-map graph mode via
  affected --tests-only (+ affected_files); name matches demoted; graph-verified gaps.
  Both fail-degrade. 9/10 PRs (90%).
- MERGED: squash to main, pushed ec4f76f..65615e9. Branch deleted.

### PR-010 — graphify_bonus adaptive synapse · commit 1e58fa0 · 2026-06-11
- Ranker signal mirroring shadow_bonus (weights+additive-keys registered, formula doc'd);
  end-to-end rank test. P-CD track + 10-PR pipeline COMPLETE.
- MERGED: squash to main, pushed 65615e9..1e58fa0. Branch deleted.

## PROJECT COMPLETE — 2026-06-11
All 10 PRs delivered + squash-merged to main (each crucible-green before merge):
Wave 1 checkup (PR-001..003) · Wave 2 living map (PR-004/005) · Wave 3 discoverability
(PR-006, owner addendum) · Wave 4 P-CD (PR-007..010).
main 06c49f8 → 1e58fa0 · 25 files · +2035/−95 · +453 test lines · kernel untouched ·
rag-maturity 58/70 intact · zero new tools. Audit: 05-audit.md (PASS).
