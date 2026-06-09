# Phase 2 — PR plan · axon-state-singlewriter

> Ordered; each PR ships tests (Core Rule 13) + must pass the crucible gate. Execution is owner-gated
> (this is a deferred RISKY refactor). AUTO once greenlit; F30/state-layout steps need their safety nets first.

- **PR-1** · shared atomic L:-write+rollback helper; session_save delegates
  - one owner for the L: file format
- **PR-2** · checkpoint: capture .json W: keys + relocate snapshots to .snapshots/ + migrate
  - restore round-trip test
- **PR-3** · lock-tests: single L:-writer + W:-json captured on checkpoint
  - prevent regression

## Gate to PR-specs
On PLAN DONE: write 03-prs/PR-01.md ... in order, then implement (gate-guarded, branch-first).
