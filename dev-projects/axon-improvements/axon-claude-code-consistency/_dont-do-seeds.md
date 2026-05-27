# Project-wide prohibition seeds — axon-claude-code-consistency

Seeded into each phase's `_dont-do.md` on `code-dev phase start`.

- **Never** commit changes to `axon/` without `L:dev-mode ≡ true`. This
  project mostly touches `~/.claude/` (user-local, not in repo) and
  `scripts/setup-persona.sh` (repo-scoped). Kernel writes are off-limits
  unless dev-mode is explicit.
- **Never** validate fixes only inside the authoring session. Bias caveat:
  this project is being written inside Claude Code; same trap as the
  sibling projects. Phase-2 PRs must be tested via a subagent invocation
  (separate Claude Code context) OR by the user restarting the session
  after install.
- **Never** propose interventions that depend on Anthropic-side changes
  (model retraining, SDK changes). Stay within harness-engineering scope.
- **Never** assume the 9-probe corpus run results without literally running
  the probes. Measurement first, hypothesis after.
- **Never** sign commits or PRs as Claude. AXON identity only.
- **Never** modify `~/.claude/` files without checkpointing the prior version
  first — these affect future sessions and are easy to break.
