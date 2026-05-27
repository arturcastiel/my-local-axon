# Phase prohibitions — 1-audit

_(seeded from `_dont-do-seeds.md`)_

- Never fix a "bug" without confirming it reproduces against a test in `tests/`.
- Never edit `axon/` without first writing the PR spec under `phases/{phase}/03-prs/`.
- Never delete a program, tool, or workspace file during the audit phase — flag
  in `_flaws.md` or `_demands.md` and decide in phase 2-prioritise.
- Never narrate a tool call (Core Rule 6).
- Never bypass the write gate via symlink or shell expansion.
- Never let the audit balloon: time-box each dimension; carry leftovers to a sub-project.
- Never commit generated files.

## Phase-specific
- Phase 1 is **read-only against the codebase**. No edits to `axon/`, `tools/`,
  `workspace/`, or `tests/` of the dev tree from this phase. All edits go through
  the 4-implement phase via PR specs.
- No premature design choices in `01-study.md` — observations only. Solutions
  land in `02-plan.md` (still phase 1) only after all 9 dimensions are surveyed.
