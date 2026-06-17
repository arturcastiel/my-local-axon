# Plan — axon new documentation (tactical · budget 7)

**Goal:** a usage-wiki for the big AXON programs (see goal-ledger.md). Hybrid example
contract: runnable tool-cmds with real output + labeled session-transcripts. New
`workspace/wiki/` tree, freshness-gated. Source material: `study/overview.md` +
`study/deep/00–06.md` (command-level reference + verified examples already captured).

## Architecture of the deliverable
```
workspace/wiki/
  INDEX.md              ← navigable index (every manual linked)
  _template.md          ← the manual shape (Purpose · Invocation · Reference · Examples · Guarded by)
  code-dev.md           ┐
  workflow.md           ├ flagship manuals (wave 1)
  library-dev.md        ┘
  goal-define.md  plan.md  chat.md  harness-builder.md   ← peers (wave 2, deferred)
  skills.md             ← host-provided skills (deep-research) — distinct from programs (wave 2)
tools/doc_index.py      ← exclude workspace/memory/ runtime; index workspace/wiki/
tools/freshness.py      ← wiki staleness check wired into check + refresh
tests/test_wiki.py      ← link-check + example-presence + freshness gate (the `## Guarded by`)
```

## Waves
- **Wave 1 (this plan, budget 7):** foundation + flagship 3 — scaffold, freshness/doc_index
  wiring (incl. the runtime-memory drift fix), the 3 hardest manuals, INDEX, and the test
  harness. Proves the manual + verified-example pattern end to end.
- **Wave 2 (02-prs.deferred.md):** peer manuals (goal-define, plan, chat, harness-builder)
  + the skills section (deep-research). Plan via a second `code-dev plan` pass.

## Constraints (project)
wiki-examples-run-verified · wiki-examples-hybrid-contract · wiki-freshness-gated ·
programs-untouched. (constraints registry, scope project:axon-new-doc.)

## Dependency order
PR-001 (scaffold) → {PR-002 freshness, PR-003/004/005 manuals} → PR-006 INDEX → PR-007 tests.
