# PR list — axon-new-doc · wave 1 (tactical · budget 7)
Updated: 2026-06-17 · 7 PRs (wave 1) · peers deferred → 02-prs.deferred.md

## PR-001 — wiki scaffold + page template + INDEX skeleton
- **Status:** planned · **Depends on:** none
- **Scope:** create `workspace/wiki/` + `_template.md` (Purpose · Invocation · Command
  reference · Worked examples [hybrid] · `## Guarded by`) + `INDEX.md` skeleton.
- **Acceptance:** dirs+template+index exist; template has all 5 sections.

## PR-002 — freshness + doc_index wiring (+ runtime-memory drift fix)
- **Status:** planned · **Depends on:** PR-001
- **Scope:** fix `tools/doc_index.py` to EXCLUDE `workspace/memory/` + root `memory/`
  (runtime churn finding); index `workspace/wiki/`; add a wiki-staleness check to
  `tools/freshness.py` (check+refresh). Update doc_index test.
- **Acceptance:** `freshness check` green with the wiki tree present; doc_index no longer
  indexes runtime memory; tests pass.

## PR-003 — code-dev manual (flagship)
- **Status:** planned · **Depends on:** PR-001
- **Scope:** `workspace/wiki/code-dev.md` from `study/deep/00–03`: purpose, the 5-phase
  ladder, ~58 subcommands reference, ≥2 hybrid worked examples (tool-run: phase-model/
  shadow; transcript: a full study→plan→pr session). `## Guarded by`.
- **Acceptance:** all sections; ≥2 examples (≥1 tool-run with REAL output); links resolve.

## PR-004 — workflow manual (flagship)
- **Status:** planned · **Depends on:** PR-001
- **Scope:** `workspace/wiki/workflow.md`: fixed vs adaptive, the yml spec, run/new/list/
  simulate/validate; ≥2 hybrid examples (tool-run: workflow-runner; transcript: workflow run).
- **Acceptance:** as PR-003.

## PR-005 — library-dev manual (flagship)
- **Status:** planned · **Depends on:** PR-001
- **Scope:** `workspace/wiki/library-dev.md`: ingest→shadow→explain→report, intersect/cite/
  search; the canonical YAML format (B-trap resolved); ≥2 hybrid examples.
- **Acceptance:** as PR-003.

## PR-006 — INDEX population + cross-links
- **Status:** planned · **Depends on:** PR-003, PR-004, PR-005
- **Scope:** populate `workspace/wiki/INDEX.md` (all wave-1 manuals + a "Skills" placeholder),
  cross-link manuals, add to the architecture-doc cross-reference.
- **Acceptance:** every wave-1 manual linked from INDEX; no dangling links.

## PR-007 — wiki test harness (the `## Guarded by`)
- **Status:** planned · **Depends on:** PR-003, PR-004, PR-005, PR-006
- **Scope:** `tests/test_wiki.py`: each manual has the 5 sections + ≥2 examples; INDEX links
  resolve; freshness-gated; tool-run example commands are real (smoke). Register as the
  manuals' guard.
- **Acceptance:** crucible green; the test fails if a manual drops a section/example or a link breaks.
