# Profile — AXON Re-Arm
> Project profile read by code-dev gates (preflight 5/9/10, branch, shadow).

codebase:      /home/arturcastiel/projects/new-axon/axon
vcs:           git
remote:        GitLab (artur.castiel-tno/axon)   # NOTE: not GitHub — see PR-T1-cihost (M5)
review-guide:  CONTRIBUTING.md
linter:        ruff check .            # or: pre-commit run --all-files
test-runner:   python3 -m pytest       # HUMAN-run unless AEGIS test-execution grant + crucible green
cross-repo:    []                      # no sibling repos in this scope

## Conventions (inherited)
- Commit trailer: `Co-authored-by: AXON <axon@arturcastiel.github.io>` ONLY — never the model/harness.
- Gates cannot be broken: no `--force`, no `reset --hard` in the gated flow.
- KERNEL-SLIM / kernel-file edits are human-only (inviolable floor), regardless of any AEGIS grant.
- AEGIS policy (_policy.md): develop=grant · test-execution=green-only · pr-create=grant · merge=green-only · build=human.
