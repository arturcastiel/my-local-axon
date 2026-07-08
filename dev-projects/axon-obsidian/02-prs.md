# PR List — axon-obsidian
Total: 5 PRs · export-only · always-fresh (propagates from graphify) · advisory + fail-degrade

## PR-01 [MERGED] — Vault exporter core
- **Status:** merged
- tools/obsidian_export.py: graph.json → real Obsidian vault {out}: one note per source_file
  (frontmatter tags/path + symbol list), edges → cross-note [[file]] wikilinks, .obsidian/
  config (app.json + graph.json view). Deterministic, one-way, fail-degrade on bad graph.

## PR-02 [MERGED] — Always-fresh + vault provenance
- **Status:** merged
- Before export, ensure the graph is fresh (reuse graphify_bridge staleness/refresh). Vault
  provenance marker (source graph hash + built_ts); re-invoke is a no-op when unchanged →
  vault never stale vs the target.

## PR-03 [MERGED] — The code-dev-obsidian program
- **Status:** merged
- workspace/programs/code-dev-obsidian.md: standalone, any-phase. Resolve project graph
  (nudge code-dev-graphify if absent), ensure fresh, export vault, STORE(W:obsidian-vault),
  confirm. Fail-degrade. Neuron-conformant.

## PR-04 [MERGED] — Map-of-content + recommended-early
- **Status:** merged
- Vault index note links study/plan/PR artifacts. code-dev-graphify surfaces "code-dev
  obsidian" as the follow-on.

## PR-05 [MERGED] — Docs + tests + registration
- **Status:** merged
- AXON-DOCS-OBSIDIAN (## Guarded by); tests (real graph→vault, freshness no-op/rebuild,
  fail-degrade, program conformance); register program+tool; mirror/doc lockstep.
