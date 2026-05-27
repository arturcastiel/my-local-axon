# Phase: 6-ecosystem
schema-version: v4
status:         planned
workflow-step:  not-started
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    4-eval
successor:      (none — terminal)
source-audit:   /home/arturcastiel/projects/axons-audit/recommendations/IMPROVEMENTS.md

## Scope (full detail in ../../masterplan.md § 6-ecosystem)
- Lever #15: plugin/registry — axon install <name> from a git-backed registry
- Lever #10 / Feature #16: subagent registry — SPAWN(<harness-name>)
  (Claude Code subagent when host=Claude Code, else subprocess)
- Lever #7 / Feature #15: background/remote exec — remote-agent <goal>
  (handoff-packaged, detached, EMITs completion)
- Feature #14: browser/computer-use tool (tools/browser.py, Playwright, OPTIONAL)

## Start with
code-dev load axon-ascent → code-dev phase start 6-ecosystem
