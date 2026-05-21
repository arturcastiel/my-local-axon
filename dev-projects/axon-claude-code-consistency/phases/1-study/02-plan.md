# Plan — 1-study

_Phase plan for the study itself. Population pending — run `code-dev plan`._

## Step list (proposed)

1. A1 — read each file in the anchoring stack (`~/.claude/output-styles/axon.md`,
   `~/.claude/settings.json` hook config, `~/.claude/agents/axon.md`,
   `scripts/setup-persona.sh`). Record observed state vs. claimed state.

2. A2 — run the 9-probe corpus in a FRESH Claude Code session (subagent
   invocation OR user-driven new session). Score against the rubric.
   Capture transcripts.

3. A3 — confirm or reject each candidate TC-code against the A1 + A2
   evidence. Eliminate the ones not supported by evidence; add any
   newly-discovered ones.

4. Bias check — verify findings reproduce in subagent reproduction. Any
   that don't are downgraded.

5. Phase exit doc — `01-study.md` populated; user signs off.
