# Phase prohibitions — 3-implement

_(seeded from _dont-do-seeds.md + tightened for implementation phase)_

## Hard rules (inherited)
- Do not write to `axon/` unless `L:dev-mode ≡ true` AND a per-PR dev-mode toggle was logged.
- Do not invoke builds or test runs autonomously (kernel rule D-19).
- Do not commit/push outside the `my-axon/` workspace-backup path.
- Do not fabricate tool output.
- Do not deprecate / delete a tool or program without a documented replacement path.

## Implementation-phase specific
- Do not skip the PR spec step — every PR has `03-prs/pr-NNN.md` before
  any source file changes.
- Do not bundle unrelated changes into one PR — one PR per migration-plan row.
- Do not modify glossary vocabulary mid-Phase-3 without ADR + spec bump.
- Do not bypass the `_pr-template.md` mandatory sections (per I-04).
- Do not advance to next PR while previous PR has 🟧 spec-fixed flaws
  that depend on it.
- Do not run `git push origin main` autonomously outside the workspace-backup
  permitted-autonomous-op path (kernel HARD RULE).
- Do not edit shipped workflow files in `workspace/workflows/` without
  bumping their `version:` field + adding row to `_versions.md`.
- Do not promote `L:shadow-enforcement-strict` until PR-116a..f complete
  AND user explicitly runs `shadow-enforce strict` (per D-033).
