---
glossary:   AXON-GLOSSARY
audience:   tier-A
version:    1
---

# PR-I — study-modes (configurable depth/breadth/lens for code-dev study)

**Phase**: 1-stub-census (UX)
**Depends-on**: code-dev-study (program) · study_index (tool)
**Blocks**: nothing
**Wave**: surface · **Reversibility**: reversible (additive — new mode param + tool, default preserves today's behavior)
**Domain**: code-dev · **dev-mode required**: no · **Status**: spec
**Priority**: !NORM — owner long-standing ask 2026-05-26

## Goal
Statement:  `code-dev study` gains a `--mode` that changes HOW it studies — depth,
            breadth, lens, token budget, and which questions it asks — instead of
            one fixed behavior. Same shape as the autonomy axes: a named mode with
            a sensible default and full override. (This is the "study" analog of
            the AEGIS autonomy levels — different axis, same configurability.)
Acceptance: `code-dev study --mode <m>` resolves a mode config via a tool;
            `scan` is the default and reproduces today's behavior; each mode
            changes ingestion breadth + token cap + the question set; mode is
            recorded in 01-study.md front-matter + the phase _meta.md; tests cover
            mode resolution + defaulting.
Rejection:  a mode that silently changes behavior with no record in the study doc;
            default mode that differs from today's behavior (must be backward-compatible);
            new tool without tests (R_NEW_NEEDS_TEST).

## The modes
| mode | depth | breadth | when |
|------|-------|---------|------|
| ▶ `scan` | high-level, shadow-first | wide | default — large codebase orientation, cheap |
| `deep` | line-level + architecture | narrow | a subsystem you'll change heavily |
| `targeted` | focused on `--lens`/`--query` | filtered | one question / one area (the stub-census was this) |
| `audit` | risk/gap/debt hunt | wide | find what's broken/missing (this very project) |
| `compare` | vs a `--ref` codebase/impl | paired | "how does X do it" |
| `onboard` | explain-to-a-newcomer | wide, shallow | first contact with a codebase |

Each mode is a config: `{depth, breadth, token_cap, lens_required, questions:[...], output_shape}`.

## What
1. `tools/study_modes.py` — `resolve(mode, **opts) -> config dict`; `list()` of modes;
   pure + testable. Default `scan`. Unknown mode → error with the valid list.
2. `code-dev-study.md` — accept `--mode` (W:code-dev-study-mode), call the tool,
   branch ingestion/questions on the config, record mode in 01-study.md front-matter.
3. `code-dev.md` router — pass `--mode` through to study.
4. The adaptive-questioning layer (PR-H) reads `config.questions` so each mode asks
   the right structured questions (ties study modes into the workflow-suggestion work).

## Blast radius (I-05)
Affected: `tools/study_modes.py` (new) · `workspace/programs/code-dev-study.md` (mode branch) ·
          `workspace/programs/code-dev.md` (pass-through) · `tests/test_study_modes.py` (new).
Kernel touch: none.

## Tests (mandatory)
- resolve("scan") == default config; resolve() defaults to scan.
- each named mode returns distinct depth/breadth/token_cap.
- targeted/compare require their opt (lens / ref) — error if missing.
- unknown mode → error listing valid modes.
- list() returns all six modes.

## Rollback (I-04)
`rm tools/study_modes.py tests/test_study_modes.py`;
`git checkout workspace/programs/code-dev-study.md workspace/programs/code-dev.md`.

## Notes
Distinct from AEGIS (which governs autonomous *action*); study-modes govern *how
much/what* to read. They meet in PR-H: a mode supplies the question set the
adaptive-workflow layer surfaces. Default `scan` keeps every existing study run identical.
