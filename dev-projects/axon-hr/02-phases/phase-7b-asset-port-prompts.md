# PR-007b — Asset port: prompt pack (69 files, minimal path rewrite)
Phase 2 plan detail · size S  (split from PR-007 per ADR-010 #2)

## Goal
Port the 69-file hr-team prompt pack (5 personas / 7 protocols / 6 tiers / 31 mode-family
modifiers / 20 presets) into workspace/hr-team/prompts/ as a near-pure bulk copy with exactly
one one-line path rewrite (convener.md L201). No H1-fix required — all prompt files already
resolve cleanly. Depends on PR-007a (catalog + doc-index machinery in place) or can land
independently since prompts carry no cross-links into the catalog.

## Depends on
- PR-004 hr-team router neuron (asset consumer — ADR-009 bottom-up)
- PR-007a implicitly recommended (doc-index regen already done; this PR's regen is incremental)

## Files — new
- workspace/hr-team/prompts/personas/{concierge,convener,panel,stealth-auto,triumvirate}.md (5)
- workspace/hr-team/prompts/protocols/{adversarial,consensus,debate,delphi,prediction-market,
  round-robin,weighted-vote}.md (7)
- workspace/hr-team/prompts/tiers/{micro,low,medium,high,xhigh,full}.md (6)
- workspace/hr-team/prompts/modes/families/F1-context..F6-voice/*.md (31 atomic modifiers)
- workspace/hr-team/prompts/modes/presets/*.md (20 presets)

## Files — modified
- workspace/DOC-INDEX.md (regenerate — ~69 new entries from workspace/hr-team/prompts/**)
- workspace/programs/REGISTRY.json (regenerate — NO-OP for prompt files; run for consistency)
- workspace/memory/longterm/dispatch-index.json (rebuild — NO-OP; run for consistency)

## Changes
 1. COPY: ~/axon-hr-team/output/prompts/** → workspace/hr-team/prompts/**
    Preserve personas/protocols/tiers/modes/{families/F1..F6,presets} tree exactly.
    Use cp -a / shutil.copytree; verify 69 .md count before rewrite.
 2. PATH-REWRITE (exactly 1 file, 1 line): prompts/personas/convener.md L201 tier-spec ref
    (output/prompts → workspace/hr-team/prompts). All other prompt files contain no output/ refs.
 3. VERIFY H1s resolve cleanly (no H1-fix needed): convener→'PERSONA: CONVENER', a tier→
    'TIER: full', a family modifier→'MODE MODIFIER: F1-context.with-context', a preset→
    'MODE PRESET: audit-mode'. Spot-check 5 files; assert in test.
 4. SLUG uniqueness: 69 prompt slugs unique and non-colliding with catalog slugs + program stems
    (ADR-004; already verified pre-generation, pinned in test).
 5. REGENERATE-AND-COMMIT: doc_index export --canonical; programs_registry generate;
    dispatch_index rebuild. doc_index check + freshness check must exit 0.

## Acceptance criteria
- workspace/hr-team/prompts has 69 .md: personas(5) protocols(7) tiers(6)
  modes.families(31) modes.presets(20).
- convener.md no longer contains 'output/prompts'; all other prompt path refs (if any) also clean.
- doc_index._title() resolves cleanly for all prompt types (no 'L0 IDENTITY').
- workspace/DOC-INDEX.md regenerated and doc_index check exits 0.
- No catalog/, no handoff/, no menu.md changes in this PR.

## Tests
- test_hr_team_port_integrity.py::test_prompts_file_count — 69 .md with 5/7/6/31/20 split.
- test_hr_team_port_integrity.py::test_no_unrewritten_prompt_paths — grep 'output/prompts'
  in workspace/hr-team/prompts/; asserts zero hits.
- test_hr_team_port_integrity.py::test_prompts_h1_resolve — spot-check 5 representative files
  (one per sub-tree) that doc_index._title() != 'L0 IDENTITY'.
- test_hr_team_port_integrity.py::test_prompt_slug_uniqueness — 69 slugs unique and disjoint
  from catalog slugs and program stems.
- test_hr_team_port_integrity.py::test_doc_index_fresh — subprocess doc_index check exits 0.

## Source grounding
- ADR-010 #2: 7b is the clean bulk-copy half; risk (H1-fix, resolver) is isolated to 7a.
- phase-7-asset-port.md §§1,3,4,5,8: copy/rewrite/uniqueness/regen steps.
- catalog/professions/_REGISTRY.md: cross-links are slug-only (path-independent) → prompts
  carry no cross-links into catalog; copy order between 7a and 7b is flexible.
