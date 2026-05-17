# Code-bias scan over `axon/` kernel (T-A batch 2 follow-on)

> Purpose: identify code-specific terms in kernel-level files that would
> leak code-domain assumptions into the workflow OS (D-015 / D-026).
> Date: 2026-05-17. Method: grep over `axon/*.md`, `axon/core/*.md`,
> `axon/programs/*.md` for the term set
> `{git, build, test, commit, branch, rebase, compile, cmake, ctest, merge,
> fork, clone, push, pull, PR, deploy, CI}`.

## Hit count per file

| File | Hits | Kernel-leak severity |
|------|------|----------------------|
| `axon/KERNEL-SLIM.md` | 19 | LOW (see classification below) |
| `axon/DEVELOPER.md` | 6 | LOW |
| `axon/COMMANDS.md` | 1 | NONE |
| `axon/core/LANG.md` | 2 | NONE |
| `axon/core/TRANSLATE.md` | 0 | NONE |
| `axon/BOOT.md` | 0 | NONE |
| `axon/OUTPUT-LAYER.md` | 0 | NONE |

## Classification of KERNEL-SLIM.md hits (19)

| Category | Count | Example | Action |
|----------|-------|---------|--------|
| Self-referential — AXON's own git | 7 | "axon.git", "my-axon.git", "git push origin main" inside `workspace/` | KEEP — AXON tracks its own repo; this is meta-data, not domain coupling. |
| AXON program compile | 3 | "compile candidates by frequency", "compile-write.py", "compile time" | KEEP — AXON's own program compilation (markdown → compiled dispatch), nothing to do with source-code compilation. |
| Self-protection — anti-coupling rule | 4 | "AXON MUST NEVER initiate, trigger, or suggest running a build..." | KEEP — this rule **prevents** code-domain coupling. Asset, not bug. |
| Mode shortcut | 2 | `2`=build mode (UI mode, not source build) | KEEP — UI mode label; not a code concept. Could be renamed to `2`=develop for less ambiguity (Phase 2 cosmetic). |
| Generic English uses | 3 | "merge / combine" (⊕ symbol meaning), "branch name" (DERIVE example) | KEEP — natural language, not code coupling. |

**Net code-domain leak severity for KERNEL-SLIM: LOW.**
Most "code" terms are either self-referential (AXON's own infrastructure) or
explicit anti-coupling rules. Genuine code-domain bias is minimal.

## Classification of DEVELOPER.md hits (6)

DEVELOPER.md is the developer guide for *editing AXON*. References to
`test step`, `health-check.md`, `axon.git`, `my-axon.git`, lint-paths CI,
changelog. All self-referential to AXON's own dev process. **No leak.**

## Single hit in COMMANDS.md

> `compile [file]` — Compile a workflow to `programs/compiled/`

AXON's own program-compilation command. No code-domain leak.

## Two hits in core/LANG.md

> `⊕   merge / combine`
> "Test: can the reasoning step be written as one or more LANG ops"

Generic English. No leak.

## Overall verdict

**The kernel is largely domain-agnostic.** No file in `axon/` has structural
code-specific assumptions that would break under D-015 / D-026 generalization.
The few apparent hits are:

1. Self-referential to AXON's own infrastructure (git repos, compile, CI).
2. Anti-coupling rules that explicitly **prevent** code-domain leakage.
3. Generic English.

The code-specific surface lives in **`workspace/programs/code-dev-*.md`** —
which is the **code-dev domain**, and is supposed to be code-specific.

## Where code-domain assumptions DO live (not a problem, but worth marking)

- `workspace/programs/code-dev-*.md` — 117 files, all in code-dev domain.
- `workspace/programs/code-dev-pr-review.md` references `cmake --build`,
  `ctest`, `git rebase`, `git reset --mixed`. All as **human-only** actions
  (per kernel anti-coupling rule). No kernel leak.
- `tools/REGISTRY.json` has a `category: code-dev` entry. Single-member
  (F-003); will become a multi-axis tag when domain schema lands.

## Implication

**D-015 generalization is structurally easier than initial F-008 estimate.**
The kernel doesn't need refactoring to support multiple domains; it needs:

1. A **domain manifest** schema declared at `workspace/domains/{name}/manifest.{yml,md}`.
2. A **migration that re-homes** existing `code-dev-*` and `library-dev-*`
   programs into their respective domain folders (filename preserved per
   D-014 / D-025; metadata only).
3. The orchestrator's **mode-router** + **mode-detect** become domain-aware
   (read active project's domain to bias intent classification).

No kernel surgery required.

## Mode shortcut cleanup (Phase 2 cosmetic)

`KERNEL-SLIM.md` line 688 declares mode shortcuts:
`1`=chat · `2`=build · `3`=run · `4`=memory · `5`=system · `6`=plan · `7`=programs.

The label `build` for mode 2 could mislead a non-code-domain user. Phase 2
candidates:

- Rename to `2`=author / `2`=create / `2`=develop. Behavior unchanged.
- OR make mode 2 domain-aware: shows "build" label in a code project,
  "ingest" label in a library project, "design" label in a science project.

Backwards compat (D-014): keep `2`=build as an accepted alias for whatever
the new canonical name becomes.
