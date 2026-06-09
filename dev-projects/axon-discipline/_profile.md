# Project profile — axon-discipline

linter:        ruff / black (Python tools);  programs are markdown (no code linter — use doc-anchors + neuron-audit)
changelog:     CHANGELOG.md
reviewers:     []            # GitHub/GitLab handles for human review, if any
cross-repo:    []            # none — single-repo (AXON itself)
test-cmd:      python3 -m pytest tests/ -q
gate-cmd:      python3 axon.py crucible gate      # parse passed==true SEPARATELY before any commit
fast-cmd:      python3 -m pytest tests/test_smoke.py -q
build-cmd:     (none — agent never runs build/push; HUMAN runs push)

## Repo-specific operating rules (see _dont-do-seeds.md for the full list)
- Remote: GitLab `ci.tno.nl/gitlab/artur.castiel-tno/axon`. Merge via `glab mr merge <N> --squash`.
- Commit trailer REQUIRED: `Co-authored-by: AXON <axon@arturcastiel.github.io>`.
- Commit messages: brand-free, NO `PR-<n>` tokens (commit-msg hook blocks them).
- dev-mode (L:dev-mode) is required ONLY for writes under `axon/` (the kernel); restore to OFF after.
  This project's work is overwhelmingly in `tools/`, `tests/`, and `workspace/programs/` — no dev-mode
  needed for those. Any KERNEL-SLIM.md edit additionally requires the F50 version-lock bump.
