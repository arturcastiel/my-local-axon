# Phase: 2-plan
schema-version: v4
status:         active
workflow-step:  plan
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    1-study (complete)
successor:      (3-implement)
source-repo:    /home/arturcastiel/projects/Claude-for-reservoir-engineering

## Goal
Deep plan for reservoir-eng v1. TOP PRIORITY: MCP egress (tools/mcp_client.py).
Then domain discipline (prefs + review gate), then the program family + 2
workflows (WF-1 screening, WF-3 sensitivity), then validation.

## Outputs (this folder)
- _decisions.md   — 8 open questions resolved
- 02-plan.md      — the deep plan (clusters, per-PR specs, sequencing)
- 02-prs.md       — PR roadmap (sizing + deps)
- 03-dag.md       — dependency DAG

## Exit criteria
Top-cluster (MCP) PRs fully spec'd; PR roadmap sized + DAG'd; ready for
3-implement entry. User reviews plan before implementation starts.
