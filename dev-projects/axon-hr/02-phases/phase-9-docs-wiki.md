# PR-009 — Docs/wiki closeout (FULLEST scope, merged LAST)
Phase 2 plan detail · size L · ADR-011

## Goal
Author the comprehensive hr-team documentation suite: three new wiki reference pages
(hr-team, hr-team-catalog, hr-team-recipes), updates to INDEX.md and getting-started.md,
regenerated AXON-DOCS.md and DOC-INDEX.md, and a CHANGELOG entry. Satisfies test_wiki and
test_freshness_wiki. Merged LAST — after all runtime (PR-001..006), asset (PR-007a/b/c), and
utility (PR-008) PRs have landed. ADR-011 owner directive: "more is better, quality matters."

## Depends on
- All prior PRs (001..008 + 007a/b/c) MERGED — wiki pages reference the live runtime API,
  menu section, asset paths, dispatch-phrases vocabulary. Writing docs before the runtime lands
  risks drift. Merge this PR only after all others are green and merged.

## Files — new
- workspace/wiki/hr-team.md — FULL REFERENCE: overview · why HR Team · 3-layer council arch
  (SELECTOR→CONVENER→DELIBERATOR) · M1/M2/M3 invocation patterns · modes/protocols/tiers/
  personas reference · council transcript persistence · §10 audit bundle · advisory_only +
  Moffatt v. Air Canada 2024 BCCRT 149 legal posture · per-tier cost/latency guidance ·
  troubleshooting/FAQ. Modeled on workspace/wiki/_template.md and the richest existing pages
  (code-dev.md, library-dev.md).
- workspace/wiki/hr-team-catalog.md — catalog user guide: what the 151-profession catalog is ·
  how seats map to catalog rows · the 12 domain taxonomy · how to query by slug · H1 conventions ·
  cross-link semantics · how to author a new catalog row (fields, H1-fix invariant, slug rules).
- workspace/wiki/hr-team-recipes.md — integration recipes: standalone CLI usage · workflow-embed
  patterns · the H1-H4 AXON-native integration patterns (from HANDOFF.md §13) · 6 worked examples
  from the handoff bundle surfaced as tutorial walkthroughs with expected output.
- tests/test_wiki.py — tests: wiki pages exist, meet minimum length, have expected headings, contain
  mandatory sections (advisory_only posture, Moffatt citation in hr-team.md; domain-taxonomy table
  in hr-team-catalog.md; at least 3 recipes with code blocks in hr-team-recipes.md).
- tests/test_freshness_wiki.py — freshness gate: workspace/wiki/*.md and AXON-DOCS.md checksums
  match regenerated output; fails if wiki files exist but doc_index is stale.

## Files — modified
- workspace/wiki/INDEX.md — add hr-team entries: hr-team, hr-team-catalog, hr-team-recipes
  (each with 1-line description); preserve existing entries byte-intact (Core Rule 12).
- workspace/wiki/getting-started.md — add HR-Team discovery blurb: 2-4 line paragraph
  describing how to invoke HR Team (menu[10] or "hr team" dispatch phrase), with link to
  wiki/hr-team.md. Append to the existing getting-started page; do not edit existing content.
- workspace/AXON-DOCS.md (regenerate via tools/doc_index.py export --canonical --format axon-docs)
- workspace/DOC-INDEX.md (regenerate — absorbs wiki .md and test file additions)
- CHANGELOG.md — add entry: `### [axon-hr] v0.1.0 — YYYY-MM-DD` with bullet list of all 9 PRs
  and a 1-line summary of each.

## Acceptance criteria
- workspace/wiki/hr-team.md: ≥2000 words; contains all mandatory sections (Why HR Team; 3-Layer
  Architecture; Invocation M1/M2/M3; advisory_only; Moffatt v. Air Canada citation; Troubleshooting).
- workspace/wiki/hr-team-catalog.md: ≥800 words; contains domain-taxonomy table (12 rows);
  includes how-to-author-a-row section with H1-fix invariant and slug-uniqueness rule.
- workspace/wiki/hr-team-recipes.md: ≥1000 words; contains ≥3 recipes each with a fenced code block.
- workspace/wiki/INDEX.md lists all three hr-team* pages; existing entries unchanged.
- workspace/wiki/getting-started.md contains HR-Team blurb with link to wiki/hr-team.md.
- AXON-DOCS.md regenerated and doc_index check exits 0.
- DOC-INDEX.md regenerated and freshness gate exits 0.
- test_wiki.py: all tests pass on the new wiki files.
- test_freshness_wiki.py: freshness gate passes (no stale wiki checksums).
- CHANGELOG.md has `[axon-hr]` entry referencing all 9 PRs.
- No changes to workspace/hr-team/ asset files (write-protect boundary; docs must describe not modify).
- No changes to workspace/programs/*.md (docs-only PR).

## Tests
- tests/test_wiki.py::test_hr_team_wiki_exists — workspace/wiki/hr-team.md exists and ≥2000 words.
- tests/test_wiki.py::test_hr_team_wiki_mandatory_sections — checks for 'advisory_only',
  'Moffatt', 'M1', 'M2', 'M3', 'Troubleshooting', '3-Layer' (or 'SELECTOR') headings/text.
- tests/test_wiki.py::test_hr_team_catalog_wiki — hr-team-catalog.md exists, ≥800 words,
  contains '12' (domain count) and 'author' (how-to-author section).
- tests/test_wiki.py::test_hr_team_recipes_wiki — hr-team-recipes.md exists, ≥1000 words,
  contains ≥3 fenced code blocks, contains 'H1' or 'H2' or 'H3' (integration pattern refs).
- tests/test_wiki.py::test_wiki_index_has_hr_entries — INDEX.md contains 'hr-team' at least 3 times.
- tests/test_wiki.py::test_getting_started_blurb — getting-started.md contains 'HR Team' (or
  'HR-Team') and a link to wiki/hr-team.md.
- tests/test_freshness_wiki.py::test_axon_docs_fresh — AXON-DOCS.md checksum matches regenerated.
- tests/test_freshness_wiki.py::test_doc_index_fresh_with_wiki — doc_index check exits 0 after wiki adds.
- tests/test_freshness_wiki.py::test_changelog_hr_entry — CHANGELOG.md contains '[axon-hr]'.

## Source grounding
- ADR-011: FULLEST scope; may split into PR-009a (docs) + PR-009b (regen) if review bandwidth
  warrants it; single PR preferred by owner.
- 01-study.md §Open-Questions: Q4 "does advisory_only belong in the wiki?" — answer YES (ADR-011).
- HANDOFF.md §13: H1-H4 integration recipes are the source material for hr-team-recipes.md §§3-6.
- workspace/wiki/_template.md: template for hr-team.md structure (follow section order exactly).
- Merged LAST: ADR-011 timing note: "authored alongside the build, merged LAST."
