# PR-007c — Asset port: handoff docs (optional)
**Parent-plan**: [02-plan.md](../02-plan.md)
Phase 2 plan detail · size XS · OPTIONAL  (split from PR-007 per ADR-010 #2)

## Goal
Port the 6-file hr-team handoff doc bundle (HANDOFF.md, V-checklist.md, INDEX.md, and 3 companion
docs) + manifest.json into workspace/hr-team/handoff/ as read-only reference material, rewriting
output/ path refs and regenerating checksums.sha256. This PR is OPTIONAL — the runtime (PR-001..006)
and asset packs (PR-007a/b) are complete without it; handoff docs serve as in-repo reference for
future maintainers. Defer or drop without consequence to the build.

## Depends on
- PR-007b (prompts landed; provides stable path constants for path-rewrite)

## Files — new
- workspace/hr-team/handoff/INDEX.md
- workspace/hr-team/handoff/HANDOFF.md
- workspace/hr-team/handoff/V-checklist.md
- workspace/hr-team/handoff/{companion-doc-1,companion-doc-2,companion-doc-3}.md (actual filenames from source)
- workspace/hr-team/handoff/manifest.json (output/ refs rewritten → workspace/hr-team/)
- workspace/hr-team/handoff/checksums.sha256 (regenerated over all ported .md files; or OMIT if checksums
  cannot be regenerated cleanly — omission is acceptable for reference material)

## Files — modified
- workspace/DOC-INDEX.md (regenerate — ~7 new entries)
- workspace/programs/REGISTRY.json (regenerate — NO-OP; run for consistency)

## Changes
 1. COPY: ~/axon-hr-team/output/handoff/** → workspace/hr-team/handoff/**
    Exact 6 .md + manifest.json; verify count before rewrite.
 2. PATH-REWRITE: all output/ refs in manifest.json and any path-ref lines in .md files
    → workspace/hr-team/. Grep for 'output/' after rewrite; assert zero hits.
 3. CHECKSUMS: regenerate checksums.sha256 over all ported .md files (sha256sum *.md > checksums.sha256
    from workspace/hr-team/handoff/); OR omit the file with a note in the PR body if the source
    checksums were over the OUTPUT layout (they would mismatch post-copy regardless).
 4. REGENERATE-AND-COMMIT: doc_index export --canonical; programs_registry generate. doc_index check exits 0.

## Acceptance criteria
- workspace/hr-team/handoff has 6 .md + manifest.json (+ optional checksums.sha256).
- grep -r 'output/' workspace/hr-team/handoff/ returns zero hits.
- doc_index check exits 0.
- No changes to workspace/hr-team/catalog/, workspace/hr-team/prompts/, or any neuron/test files.

## Tests
- test_hr_team_port_integrity.py::test_handoff_file_count (optional block) — 6 .md + manifest.json present.
- test_hr_team_port_integrity.py::test_no_unrewritten_handoff_paths — grep 'output/' in
  workspace/hr-team/handoff/; asserts zero hits.
- test_hr_team_port_integrity.py::test_doc_index_fresh — subprocess doc_index check exits 0.

## Source grounding
- ADR-010 #2: 7c is optional; defer or drop without impacting runtime.
- phase-7-asset-port.md §7: handoff port detail (6 .md + manifest.json + checksums handling).
