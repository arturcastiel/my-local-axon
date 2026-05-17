# F-010: Kernel `axon/` is already largely domain-agnostic — D-015 is easier than feared

**Severity:** medium (positive finding — de-risks generalization)
**Track:** T-A (validates D-015, D-026)
**Date:** 2026-05-17
**Linked demands:** D-26 (workflow OS), D-25 (preserve code-dev), D-15 (most detailed)
**Linked decisions:** D-015

## Evidence

Code-bias scan over `axon/*.md`, `axon/core/*.md`, `axon/programs/*.md` for
the term set `{git, build, test, commit, branch, rebase, compile, cmake,
ctest, merge, fork, clone, push, pull, PR, deploy, CI}`:

| File | Hits | Leak severity |
|------|------|---------------|
| `KERNEL-SLIM.md` | 19 | LOW |
| `DEVELOPER.md` | 6 | LOW |
| `COMMANDS.md` | 1 | NONE |
| `core/LANG.md` | 2 | NONE |
| `core/TRANSLATE.md` | 0 | NONE |
| `BOOT.md` | 0 | NONE |
| `OUTPUT-LAYER.md` | 0 | NONE |

Detailed classification (in `helpers/code-bias-scan.md`):

- **7 hits** self-referential (AXON's own git repos: axon.git, my-axon.git).
- **3 hits** AXON's own program-compilation (markdown → compiled dispatch).
- **4 hits** anti-coupling rules ("AXON MUST NEVER initiate build/compile/test").
- **2 hits** UI mode shortcut (`2`=build — UI label, not code build).
- **3 hits** generic English (e.g. "merge / combine" describing ⊕ symbol).

**Zero hits represent structural code-domain coupling in the kernel.**

## Why this matters

F-008 (high) flagged a risk that the kernel might leak code-specific
assumptions into the synapse OS, making D-015 / D-026 architecturally
expensive. **The scan refutes that risk.** Generalization is mostly
schema + manifest work; kernel surgery is not required.

The code-specific surface lives where it should live: inside
`workspace/programs/code-dev-*.md`, which IS the code-dev domain.
Library-dev (F-011, this batch) further validates by being a working
non-code workflow on the same kernel ops.

## Risk now downgraded

| Risk | F-008 view | F-010 view |
|------|------------|------------|
| Kernel refactor needed | Possible | No |
| Code-coupling deep in kernel | Suspected | Refuted |
| D-015 architectural cost | High | Medium |
| D-026 timeline | Multi-phase, hard | Multi-phase, tractable |

## Implication for Phase 2 / Phase 3

- **Phase 2.** Author `workspace/domains/{name}/manifest.{yml,md}` schema +
  glossary. No kernel changes.
- **Phase 2 (cosmetic).** Mode-2 label drift — current `build` mode label
  may mislead non-code-domain users. Domain-aware label resolution or rename
  to `develop` / `create`. Backwards-compat alias preserved (D-014).
- **Phase 3.** Add `domain:` field to existing `code-dev-*` and `library-dev-*`
  programs. Re-home conceptually (no filename changes per D-014). Migration
  is pure metadata.
- **Phase 3.** `mode-router` + `mode-detect` become domain-aware — read
  active project's `_meta.md` `domain:` field, bias intent classification.

## Suggested action

- **Phase 2 design Q.** Domain manifest schema. Single fixture domain
  (`code-dev`) authored as reference implementation.
- **Phase 3 PR seed.** `domain-metadata-migrate` — adds `domain:` field to
  every program based on filename prefix. Idempotent.

## Note

This finding is rare in being **positive** — it removes a hypothetical blocker
rather than identifying a new problem. It directly de-risks the project's
biggest architectural decision (D-015).
