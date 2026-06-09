# Phase 2 — PR plan · axon-pkg-boundaries

> Ordered; each PR ships tests (Core Rule 13) + must pass the crucible gate. Execution is owner-gated
> (this is a deferred RISKY refactor). AUTO once greenlit; F30/state-layout steps need their safety nets first.

- **PR-1** · add tools/__init__.py + package smoke-test
  - additive; verify all imports still resolve
- **PR-2** · convert imports: core libs cluster (_axon_*, registry, verify)
  - absolute imports + drop bootstraps
- **PR-3** · convert imports: remaining clusters (batches)
  - one batch/PR, gate each
- **PR-4** · delete residual sys.path.insert + lint-test
  - forbid sys.path.insert in tools/ going forward

## Gate to PR-specs
On PLAN DONE: write 03-prs/PR-01.md ... in order, then implement (gate-guarded, branch-first).
