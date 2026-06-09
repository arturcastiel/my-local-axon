# Phase 2 — PR plan · axon-alias-retire

> Ordered; each PR ships tests (Core Rule 13) + must pass the crucible gate. Execution is owner-gated
> (this is a deferred RISKY refactor). AUTO once greenlit; F30/state-layout steps need their safety nets first.

- **PR-1** · program-dispatch test harness
  - assert every code-dev EXEC target resolves to an existing program
- **PR-2** · repoint code-dev.md routes alias→canonical
  - fix the three-hop; aliases still exist
- **PR-3** · mark the 18 aliases loud-deprecated (warn on use)
  - one-release deprecation window
- **PR-4** · delete the aliases + REGISTRY/quarantine entries (next release)
  - after the window + green dispatch tests

## Gate to PR-specs
On PLAN DONE: write 03-prs/PR-01.md ... in order, then implement (gate-guarded, branch-first).
