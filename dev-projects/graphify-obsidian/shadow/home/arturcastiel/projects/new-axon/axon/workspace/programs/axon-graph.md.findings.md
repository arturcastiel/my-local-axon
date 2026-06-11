# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/programs/axon-graph.md
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/programs/axon-graph.md
shadow-created: 2026-06-11
shadow-updated: 2026-06-11
git-hash: 139a014300cc2fb53a443b2bec31099e7045cc2f
git-branch: main
git-commit: 06c49f8
git-commit-msg: Merge branch 'general-bugfix/docs-closeout' into 'main'
caller-program: code-dev-study
caller-project: graphify-obsidian

## Summary
User-facing program wrapper over the code-graph tool: stats (default) / build / affected / dead-code / god-nodes / cluster / export. Read-only, ACTIVE, meta family.

## Key Structures
Route on W:axon-graph-cmd; affected prompts for symbol via W:axon-graph-symbol; export hardcodes --out workspace/_dashboards/axon-code-map.md.

## Dependencies
TOOL(code-graph) only. Identity lock + program preamble standard.

## Architecture Role
The user surface of self-introspection. Listed in menu only indirectly (not in menu sections — discoverability gap); HELP usage line omits cluster and export though both are routed.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-11 |  | Usage string lists build|affected|dead-code|god-nodes|stats but routes also cluster+export (doc drift inside the program). Output truncates affected/dead lists at 20 — no --out option for full results except export. No freshness hook for the exported map. |