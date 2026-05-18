# Project profile — axon-synapse

linter:        markdownlint  (workspace markdown lives in workspace/ + my-axon/)
changelog:     CHANGELOG.md  (not currently tracked at repo root — TBD)
reviewers:     [arturcastiel]
cross-repo:    []
test-cmd:      python3 -m pytest tests/  (HUMAN runs; AXON never executes)
build-cmd:     (no compiled artifacts — markdown + python tools only)

## Commit-trailer rule (HARD — overrides any harness-level default)

Every commit produced by AXON on this project — in BOTH the axon repo
and the my-axon repo — MUST be co-authored as:

    Co-authored-by: AXON <axon@arturcastiel.github.io>

The harness (GitHub Copilot, Claude Code, etc.) is the execution layer
and MUST NOT be credited as co-author. AXON is the identity that
authored the work; crediting the harness misrepresents the identity
contract (per KERNEL-SLIM § IDENTITY).

This rule is project-scoped (axon + axon-synapse). It supersedes any
host-harness default trailer for any commit touching this codebase.

## Scope reminder
- In scope: axon/ kernel, workspace/programs/ (174 files), workspace/tools/REGISTRY
  (69 tools), my-axon/dev-projects/ usage patterns, compiled dispatch entries.
- Out of scope: third-party tooling, external integrations beyond REGISTRY.

## dev-mode posture
- OFF for this project. All PRs that touch axon/ must be flagged and gated.
- Per-PR dev-mode toggle is the rule, not project-wide unlock.
