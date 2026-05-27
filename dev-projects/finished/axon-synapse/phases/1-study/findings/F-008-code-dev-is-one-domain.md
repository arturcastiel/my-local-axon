# F-008: Code-dev is one domain among many — kernel vocabulary must be domain-agnostic

**Severity:** high
**Track:** T-A (cross-cuts T-D, T-F)
**Date:** 2026-05-17
**Linked demands:** D-26 (workflow OS generalization), D-25 (preserve code-dev)
**Linked decisions:** D-014, D-015

## Evidence

`workspace/programs/` contains 174 programs. Family breakdown by filename
prefix:

- `code-dev-*` — 117 programs (67 %)
- `library-dev-*` — 9 programs (5 %) — already a non-code domain (ingest PDFs,
  shadow, explain, intersect, report)
- Other / meta — 48 programs (28 %) — including `axon-audit`,
  `harness-builder`, `mode-router`, `igap-*`, `auto-improve`, `cron`, etc.

`library-dev` exists today as a non-code-implementation workflow:
`new → ingest → shadow → explain → intersect → cite → report`. Same vocabulary
(study, plan, shadow, audit) — different artifacts (PDFs, citations, library
items vs source files, PRs, commits).

`axon/KERNEL-SLIM.md` does not contain code-specific concepts in its core
language ops (READ, WRITE, STORE, EXEC, ASSERT, etc.). However:

- Several rule examples reference "code", "build", "test", "git push" —
  but only as examples and human-only-actions, not as kernel primitives.
- `tools/REGISTRY.json` has a `code-dev` category with one entry (F-003).
- `workspace/programs/code-dev-*` programs reference git operations directly
  (`code-dev-rebase`, `code-dev-finalize`).

## Why this matters for the synapse model

The user's clarification (M6) elevates the project goal from "redesign code-dev"
to "build a workflow OS where code-dev is one domain." This shifts every
downstream design decision:

1. **Vocabulary lockdown.** Words must mean one thing precisely (Q15.1).
   "Workflow", "synapse", "domain", "phase" must apply uniformly to a code
   project, a science experiment, and a study reading.
2. **Synapse contract schema (F-005) must be domain-agnostic.** No
   `git-branch:` field; instead `inputs: [file, scalar, repository-ref]` with
   pluggable input types.
3. **Domain folder structure.** Each domain (`code-dev`, `library-dev`,
   future `science-dev`, `study-dev`) lives under `workspace/domains/{name}/`
   with: workflow files, domain-specific programs, file-convention spec,
   glossary.
4. **Existing programs are re-homed conceptually, not physically.** No
   filename changes; metadata says `domain: code-dev`.
5. **Backwards compatibility (D-025).** `code-dev plan` continues to work.
   The generalization is additive: a new generic `flow plan` may exist
   alongside it (Phase 2 design Q15.5).

## Library-dev as proof point

`library-dev-*` programs use the same kernel vocabulary as `code-dev-*`:
`new`, `study`, `plan`, `shadow`, `audit`, `explain`. They produce different
artifacts (citations, library items, intersection reports vs source files,
PRs). This existence proof shows AXON already has multi-domain DNA — but it
is implicit, not formalized in a `domain:` schema.

The synapse rollout should **formalize what library-dev demonstrates** rather
than invent a new abstraction from scratch.

## Implication for Phase 2 / Phase 3

- **Phase 2.** Author `workspace/SYNAPSE-GLOSSARY.md` first — every term gets
  one fixed meaning. Then derive synapse contract schema from glossary, not
  from code-dev conventions.
- **Phase 2.** Author `domain` spec: a folder structure + a manifest
  (`workspace/domains/{name}/manifest.{yml,md}`) declaring the domain's
  workflows, programs, file conventions, default goals.
- **Phase 3.** Add `domain:` field to every existing program and tool.
  Default value derives from filename prefix (`code-dev-*` → `code-dev`;
  `library-dev-*` → `library-dev`; otherwise → `meta` or `system`).
- **Phase 3.** Domain-aware `mode-router` / `mode-detect` — free-text intent
  classification reads the active project's `domain:` to bias suggestions.
- **Phase 4.** Bootstrap a second domain (proposed: `study-dev` for academic
  reading and synthesis). Goal: prove the vision on a non-code workflow with
  zero kernel changes.

## Risk

If the synapse schema or orchestrator leaks code-specific assumptions early,
generalizing later is significantly harder. **Vocabulary discipline is the
single biggest design control** for this risk.

## Suggested action

- **T-A follow-on.** Sweep `axon/` and `workspace/` for code-specific terms
  in kernel-level files (not domain-level). Produce `helpers/code-bias-scan.md`.
- **Phase 2 design Q.** Author SYNAPSE-GLOSSARY.md as a hard-fix vocabulary list.
- **Phase 3 PR seed.** `domain-manifest-spec` — defines manifest format
  and migration tool.
