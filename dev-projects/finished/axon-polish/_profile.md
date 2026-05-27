# Project profile — axon-polish

linter:        black + ruff   # (Python tools/ tree); markdown via axon-audit
changelog:     CHANGELOG.md
reviewers:     []   # GitHub handles, e.g. ['alice', 'bob']
cross-repo:    []   # sibling repo paths
test-cmd:      pytest tests/   # AXON runs in feature branches (no C++ build step here)
build-cmd:     (none — interpreted Python; "build" = lint + tests + coverage gates)

## Handoff policy  (overrides KERNEL-SLIM CODE DEVELOPMENT RULES default)
agent-can-run-tests:   true    # pytest, coverage, ruff, mypy
agent-can-push:        feature-branches-only   # NEVER main
agent-can-open-pr:     draft   # gh pr create --draft, or render body for human
agent-can-merge:       false   # human only
agent-can-destruct:    false   # no force-push / reset --hard / branch -D
handoff-point:         after `gh pr create --draft` — wait for human review + merge
rationale:             "Python project, no C++-style build. Kernel's
                       'building is a human task' rule was framed around
                       cmake/make/cargo and is overridden here by owner
                       instruction 2026-05-23."

## Codebase notes
- Root         : /home/arturcastiel/projects/axon-development/axon
- Version      : 3.7.0 (axon-synapse)
- CI gates     : lint-paths, coverage (tools/rules 100% line+branch, tools/ ≥80%)
- PR-020 rule  : every change ships with tests + AXON-DOCS doc anchor + Guarded-by row
- Hot zones    : axon/ (kernel — dev-mode gated), tools/, workspace/programs/
