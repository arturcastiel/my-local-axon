# Phase prohibitions — 1-study

_(Seeded from `../../_dont-do-seeds.md` on phase start.)_

- Never commit changes to `axon/` without `L:dev-mode ≡ true`.
- Never validate fixes only inside the authoring session.
- Never propose interventions depending on Anthropic-side changes.
- Never assume probe results without running them.
- Never sign commits/PRs as Claude. AXON identity only.
- Never modify `~/.claude/` files without checkpointing first.

## Phase-specific

- **Study only — no `~/.claude/` edits this phase.** Phase 1 produces a
  measured baseline + an audit + a gap list. All hook/file changes happen
  in phase 3.
- **Read-only on the anchoring stack.** Inspect `~/.claude/output-styles/`,
  `~/.claude/settings.json`, `~/.claude/agents/`, `scripts/setup-persona.sh`.
  Do not edit.
