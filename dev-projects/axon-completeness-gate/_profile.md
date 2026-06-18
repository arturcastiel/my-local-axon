# Project profile — axon-completeness-gate

linter:        (python: ruff/flake8 if configured)
changelog:     CHANGELOG.md
reviewers:     []
cross-repo:    []
test-cmd:      python3 axon.py crucible gate     # full gate (AEGIS test-execution = green-only)
build-cmd:     (no build — Python tooling; HUMAN runs any app)
