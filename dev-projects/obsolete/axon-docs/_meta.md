# axon-docs

**Created:** 2026-05-17
**Phase:** done
**Workflow-step:** done
**Mode:** documentation-only — NO new tools, NO code modifications
**Owner:** Artur Castiel Reis de Souza
**Goal:** produce a comprehensive, accurate, current, navigable documentation
set for the AXON OS, after thoroughly studying the post-cleanup codebase
(programs, tools, workflows, kernel, doc surfaces).

## Scope

In scope:
- Study every program (`workspace/programs/*.md`, `axon/programs/*.md`).
- Study every tool (`tools/REGISTRY.json`, `tools/*.py`, `axon/tools/*.md`).
- Study every existing doc surface (`README`, `SETUP`, `CONTRIBUTING`,
  `WORKFLOW`, `COPILOT`, `AGENTS`, `CONTEXT`, `startup.md`,
  `workspace/AXON-DOCS-*.md`, `axon/*.md`).
- Map programs to workflows (what triggers what, what produces what).
- Identify gaps, contradictions, drift, stale content, redundancy.
- Plan: which docs to add, which to rewrite, which to retire.
- Plan: ownership conventions (Guarded-by, source of truth, single-write).
- Plan: navigation surface (index, see-also graph).

Out of scope:
- Any code change (tools, scripts, test fixtures).
- Any program-corpus mutation (no .md program edits).
- Any new tool. Documentation is the artefact.

## Phases (planned)

- **1-study** — thorough inventory + gap analysis (3 layers).
- **2-plan** — per-doc-surface PRs with co-output rows.
- **3-implement** — author/rewrite docs PR-by-PR.
- **4-finalize** — cross-link audit, navigation pass, PR cycle close.

## State

Phase 1 (study) complete — `01-study.md`.
Phase 2 (plan) complete — `02-plan.md` accepted 2026-05-17.
Phase 3 (implement) complete — 15/15 PRs done. Log: `04-log.md` Rounds 2-7.
Phase 4 (finalize) complete 2026-05-17 — pytest green (20/20),
`docgen_verify --strict` clean, commit `708992e` pushed to
`arturcastiel/axon` main, dev-mode toggled OFF. Project closed.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
