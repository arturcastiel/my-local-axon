# Phase prohibitions — 1-study

_(seeded from _dont-do-seeds.md on phase start)_

## Hard rules
- Do not write to `axon/` unless `L:dev-mode ≡ true` AND a per-PR dev-mode toggle was logged.
- Do not invoke builds or test runs autonomously.
- Do not commit/push outside the `my-axon/` workspace-backup path.
- Do not fabricate tool output.
- Do not deprecate / delete a tool or program without a documented replacement path.

## Study-phase specific
- Do not propose implementations in 01-study.md. Findings only → design happens in Phase 2.
- Do not redesign programs in-place during study; capture in findings/F-XXX with severity.
- Do not assume an "obvious" goal; surface goals as research questions, not answers.
