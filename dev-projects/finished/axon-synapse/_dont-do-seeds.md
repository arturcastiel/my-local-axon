# Project-wide prohibition seeds — axon-synapse

These seed every phase's `_dont-do.md`.

## Hard rules
- Do not write to `axon/` unless `L:dev-mode ≡ true` AND a per-PR dev-mode toggle was logged.
- Do not invoke builds or test runs autonomously. State "ready for human to build/test."
- Do not commit/push outside the `my-axon/` workspace-backup path.
- Do not fabricate tool output. On tool failure → LOG(ERROR) + QUERY(user).
- Do not deprecate / delete a tool or program without a documented replacement path.

## Scope rules
- Do not propose features that are not derivable from study findings (audit-first stance).
- Do not assume what a "goal" of a code-dev phase is until study has codified it.
- Do not collapse the synapse metaphor into mere shortcut-menu — suggestions must be
  derived from declared inputs/outputs/post-state of programs, not hardcoded lists.

## Process rules
- Every PR must cite a study finding or a derived goal.
- DAG mutations (merge / split / fold-in) must be reversible — log before/after.
- No silent renames; if a program changes name, leave a forwarder + DEPRECATED marker.
