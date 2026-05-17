# Project profile — axon-synapse

linter:        markdownlint  (workspace markdown lives in workspace/ + my-axon/)
changelog:     CHANGELOG.md  (not currently tracked at repo root — TBD)
reviewers:     [arturcastiel]
cross-repo:    []
test-cmd:      python3 -m pytest tests/  (HUMAN runs; AXON never executes)
build-cmd:     (no compiled artifacts — markdown + python tools only)

## Scope reminder
- In scope: axon/ kernel, workspace/programs/ (174 files), workspace/tools/REGISTRY
  (69 tools), my-axon/dev-projects/ usage patterns, compiled dispatch entries.
- Out of scope: third-party tooling, external integrations beyond REGISTRY.

## dev-mode posture
- OFF for this project. All PRs that touch axon/ must be flagged and gated.
- Per-PR dev-mode toggle is the rule, not project-wide unlock.
