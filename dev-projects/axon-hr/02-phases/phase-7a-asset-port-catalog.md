# PR-007a — Asset port: catalog (151 rows + H1-fix + cross-link resolver + slug-uniqueness)
**Parent-plan**: [02-plan.md](../02-plan.md)
Phase 2 plan detail · size M  (split from PR-007 per ADR-010 #2)

## Goal
Port the hr-team profession catalog (151 rows + _REGISTRY.md + _CONFLICT-POLICY.md) into
workspace/hr-team/catalog/professions/ with the mandatory H1-fix so doc_index._title() returns
the real role name for every row (not "L0 IDENTITY"), slug-uniqueness verified against existing
workspace/ identifiers, all 1077 cross-link edges resolved, and doc-index regenerated.
This PR carries the RISK of the full PR-007 split; PR-007b (prompts) is a clean bulk-copy
after this passes review.

## Depends on
- PR-004 hr-team router neuron (the asset consumer — ADR-009 bottom-up places assets after readers)

## Files — new
- workspace/hr-team/catalog/professions/_REGISTRY.md (ported; 1 path-ref rewritten)
- workspace/hr-team/catalog/professions/_CONFLICT-POLICY.md (ported verbatim)
- workspace/hr-team/catalog/professions/{ai-ml,business,design,education,energy,humanities,
  legal,medicine,ops,process,science,software}/{slug}.md (151 row files; H1-fixed)
- tests/test_hr_team_port_integrity.py (catalog tests: file-count + H1 + cross-link-resolver
  + slug-uniqueness + doc-index-freshness checks — prompts tests deferred to PR-007b)
- tests/fixtures/hr-team/catalog/_REGISTRY.min.md (SUPERSEDES the minimal fixture from PR-001;
  full 151-row registry now live)

## Files — modified
- workspace/DOC-INDEX.md (regenerate via tools/doc_index.py export --canonical — ~153 new entries;
  freshness gate drifts until regenerated)
- workspace/programs/REGISTRY.json (regenerate — NO-OP for asset files; run for commit consistency)
- workspace/memory/longterm/dispatch-index.json (rebuild — NO-OP for asset files; run for consistency)

## Changes
 1. COPY: ~/axon-hr-team/output/catalog/professions/** → workspace/hr-team/catalog/professions/**
    Preserve 12 domain subdirs + _REGISTRY.md + _CONFLICT-POLICY.md. Use cp -a / shutil.copytree
    (no rename) so file counts are verifiable before transforms.
 2. H1-FIX (MANDATORY): demote in-frontmatter section markers inside each row's leading ---...---
    block: regex ^# (L[0-5] ) → ## \1 (scoped to frontmatter only — do NOT touch body H1s).
    Post-fix: doc_index._title(row) returns the real name H1 (last line of each file), NOT
    "L0 IDENTITY". Verify with: python3 -c "from tools.doc_index import _title; ..."
    for all 151 rows. (ADR-010 #1 pulled a minimal _REGISTRY fixture into PR-001; this PR
    supersedes it with the real 151-row set.)
 3. PATH-REWRITE (catalog files only — exactly 1 file): _REGISTRY.md L9 path-convention string
    (output/catalog/professions → workspace/hr-team/catalog/professions). No other catalog file
    contains rewritable path refs (catalog row bodies contain only external citation URLs).
 4. SLUG-COLLISION CHECK: assert 151 catalog slugs pairwise-unique AND disjoint from
    workspace/programs/*.md stems AND from {hr-team,hr-team-selector,hr-team-convener,hr-team-deliberator}.
    ADR-010 #6: resolver test PINS its MEASURED cross-link count (direct parse ~1038; never quote
    registry headline 1071 or synthesized 1077).
 5. REGENERATE-AND-COMMIT: python3 tools/doc_index.py export --canonical (REQUIRED — gated by
    freshness 'doc_index'); python3 tools/programs_registry.py generate; python3
    tools/dispatch_index.py rebuild. Then doc_index check + freshness check must both exit 0.

## Acceptance criteria
- workspace/hr-team/catalog/professions has 153 .md (151 rows across 12 named domain subdirs
  with per-domain counts ai-ml=20, business=10, design=8, education=5, energy=18, humanities=8,
  legal=8, medicine=11, ops=9, process=6, science=34, software=14; plus _REGISTRY.md + _CONFLICT-POLICY.md).
- Every catalog row's doc_index._title() returns its real role name (e.g. 'Agent Architect'),
  NOT 'L0 IDENTITY', for all 151 rows.
- Cross-link resolver: every slug referenced by see-also/compose-with/conflicts-with resolves to
  exactly one row file; 0 dangling, 0 ambiguous; measured edge count pinned in test.
- Slug uniqueness: 151 slugs pairwise-unique AND disjoint from existing workspace/programs/*.md
  stems AND from the PR-001..004 neuron slugs.
- workspace/DOC-INDEX.md regenerated; python3 tools/doc_index.py check exits 0.
- Path-rewrite completeness: grep -r 'output/catalog' workspace/hr-team/catalog/ returns no hits.
- No prompts/, no handoff/, no menu.md changes in this PR — catalog only.

## Tests
- test_hr_team_port_integrity.py::test_catalog_file_count — 153 .md, 151 non-underscore rows,
  12 expected domain subdirs, exact per-domain counts.
- test_hr_team_port_integrity.py::test_every_row_has_clean_h1 — doc_index._title(row) !=
  'L0 IDENTITY' AND equals frontmatter `name:` field for all 151 rows (H1-fix regression lock).
- test_hr_team_port_integrity.py::test_crosslink_resolver — builds {slug:path} over all rows,
  resolves every cross-link value, asserts 0 dangling/ambiguous, pins measured edge count.
- test_hr_team_port_integrity.py::test_catalog_slug_uniqueness — 151 slugs unique + non-colliding
  with programs/*.md stems and neuron slugs.
- test_hr_team_port_integrity.py::test_no_unrewritten_catalog_paths — grep for 'output/catalog'
  in workspace/hr-team/catalog/; asserts zero hits.
- test_hr_team_port_integrity.py::test_doc_index_fresh — subprocess python3 tools/doc_index.py
  check exits 0.

## Source grounding
- ADR-010 #2: PR-007 split → 7a (catalog/risk) · 7b (prompts) · 7c (handoff optional).
- ADR-010 #1: minimal _REGISTRY fixture landed in PR-001; superseded here by the full catalog.
- ADR-010 #6: cross-link count = MEASURED (direct parse ~1038 edges); test pins its own measurement,
  never the registry headline (1071) or synthesized total (1077).
- phase-7-asset-port.md §§1,2,3,5,6,8: source grounding for copy/H1-fix/rewrite/uniqueness/regen steps.
