# Phase 2 — PR plan · axon-registry-accessor

> Ordered; each PR ships tests (Core Rule 13) + must pass the crucible gate. Execution is owner-gated
> (this is a deferred RISKY refactor). AUTO once greenlit; F30/state-layout steps need their safety nets first.

- **PR-1** · _axon_registry accessor + tests
  - load/iter/lookup; parity test vs direct json.load
- **PR-2** · migrate consumers (batches by usage pattern)
  - gate each batch
- **PR-3** · lock-test: no raw REGISTRY json.load outside the accessor
  - prevents regression

## Gate to PR-specs
On PLAN DONE: write 03-prs/PR-01.md ... in order, then implement (gate-guarded, branch-first).
