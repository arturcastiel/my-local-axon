# Phase: 2-integration
schema-version: v4
status:         planned
workflow-step:  not-started
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    1-telemetry
successor:      3-safety-budget
source-audit:   /home/arturcastiel/projects/axons-audit/recommendations/FEATURES-FROM-COMPETITORS.md

## Scope (full detail in ../../masterplan.md § 2-integration)
- Lever #1: tools/mcp_client.py (consume 9,400+ MCP servers as TOOLs)
- Lever #1: tools/mcp_server.py (expose AXON's 93 tools via MCP)
- Lever #3: handoff --protocol a2a (valid A2A envelope)
- Lever #9: SKILL.md shim (workspace/programs/skills/ + skill-adapter)

## Note
Audit calls this exact bundle "the fastest path to close the matrix gap
without touching the moat." All bucket-1 "drops in cleanly" — new tools,
zero kernel rule changes.

## Start with
code-dev load axon-ascent → code-dev phase start 2-integration
