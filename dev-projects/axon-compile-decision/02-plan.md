# Phase 2 — PR plan · axon-compile-decision

> Ordered; each PR ships tests (Core Rule 13) + must pass the crucible gate. Execution is owner-gated
> (this is a deferred RISKY refactor). AUTO once greenlit; F30/state-layout steps need their safety nets first.

- **PR-1** · measure compression feasibility on a program sample
  - decision input: retire vs repair
- **PR-2** · execute the decision (retire: consolidate+drop / repair: real compressor)
  - gated
- **PR-3** · update dispatch + freshness gate + lock-test
  - no dangling compiled/ refs

## Gate to PR-specs
On PLAN DONE: write 03-prs/PR-01.md ... in order, then implement (gate-guarded, branch-first).
