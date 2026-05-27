# Phase: 1-study
schema-version: v4
status:         active
workflow-step:  study
branch:         main
current-pr:     (none — study output is markdown only)
created:        2026-05-21

## Working Context

Three deliverables to close phase 1:

1. **Measured baseline** — run the 9-probe corpus (from sibling project)
   adapted for Claude Code. Replace the 7/10 self-audit estimate with a
   number derived from probe outcomes.
2. **Anchoring stack audit** — read each file in `~/.claude/` that
   participates in the AXON persona, identify what's wired and what's
   not (Stop hook = known-unwired).
3. **Gap list (T-codes)** — symmetric to T1-T5 from the Copilot project,
   produce a list of specific tensions / failure modes with concrete
   citations and proposed phase-2 fix scope.

Phase ends when 01-study.md exists with all three sections populated AND
the user signs off.

## Bias caveat

Authored inside Claude Code (the very harness being studied). Same trap
the sibling projects flagged. Mitigation per `_dont-do.md`: phase-2 PRs
must validate via subagent or fresh-session reproduction, not the
authoring session.
