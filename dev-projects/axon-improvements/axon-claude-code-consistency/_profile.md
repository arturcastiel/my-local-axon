# Project profile — axon-claude-code-consistency

linter:        markdownlint (md docs) · shellcheck (bash hooks) · python3 ruff (any tool code)
changelog:     CHANGELOG.md (axon repo root)
reviewers:     [arturcastiel]
cross-repo:    []
test-cmd:      python3 -m pytest tests/ -q (when build affects tooling)
build-cmd:     (no build — config + markdown + small scripts only ; HUMAN runs validation)
