# Plan — general-bugfix (Phase 2)

Derived from `01-study.md` (§A criticals · §F tracks · §I prevention architecture · §J integrated decisions).
Codebase: `/home/arturcastiel/projects/new-axon/axon` · base: `main` · PRs land on a `general-bugfix` integration branch.

## Strategy (the §J integrated recommendation)
**Interleave fix-then-guard** (not front-load): every fix PR also ships the guard that locks its class, promoted
**WARN→BLOCK** once green — the proven `cron_conformance` (`f99f5f8`) pattern. Two cheap lints + the COMPILED-MIRROR
KILL go in Step 0; fixes land in value order (workflow + conversational criticals first); heavy guards ride with
their fix-tracks; the one undecidable class (C7 semantic correctness) is held by tests + a WARN-only review.

## Waves
- **Step 0 — foundation:** the 2 cheap lints (WARN) + the COMPILED-MIRROR KILL (closes the largest prevention hole + reduces surface).
- **Wave 1 — highest-value criticals:** T2 (workflow gates) + T3 (conversational), each guarded by a Step-0 lint.
- **Wave 2 — core loop + contracts:** T1 (phase model) · T4/T5/T6 (PR-spec/shadow/library) · the output-manifest+accessor lint.
- **Wave 3 — safety + cleanup:** C8 dry-run mechanism · T8 reduce-surface · T9 doc-honesty · completeness-keystone promotes guards to BLOCK.
- **Residual:** C7 — behavior/mutation tests + WARN-only adversarial diff-review.

## Acceptance (per the AXON contract)
Every PR: a code-dev spec (`03-prs/`), the fix + its paired guard (WARN→BLOCK), a test, the `## Guarded by` doc,
freshness/registry/CONTEXT updates, and a **green crucible gate** before merge. Kernel floor untouched (human-only).

## Map: PR → criticals fixed
PR-1→C2 · PR-2→C3,C4,C5 · PR-3→C1 · PR-5→C6 · PR-6→library criticals · PR-8→C8 · PR-9→C7(check-structure)+residue.
Full PR DAG: `02-prs.md`.
