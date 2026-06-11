# SHADOW: /home/arturcastiel/projects/new-axon/axon/tools/code_graph.py
source-path: /home/arturcastiel/projects/new-axon/axon/tools/code_graph.py
shadow-created: 2026-06-11
shadow-updated: 2026-06-11
git-hash: 139a014300cc2fb53a443b2bec31099e7045cc2f
git-branch: main
git-commit: 06c49f8
git-commit-msg: Merge branch 'general-bugfix/docs-closeout' into 'main'
caller-program: code-dev-study
caller-project: graphify-obsidian

## Summary
Deterministic in-house code-graph over AXON's own Python tree (default tools/). stdlib ast; nodes=module/function/class/method; edges=imports/contains/calls, all EXTRACTED; byte-identical rebuilds (sorted walk + sorted output + dedup).

## Key Structures
build(root), affected(graph,name,depth), dead_code(graph), god_nodes(graph,top), cluster(graph,max_iter) label-propagation deterministic, export_markdown(graph,communities,god) — Obsidian map, _resolve(), _module_id(), _iter_py(), _top_defs(), _imports(), _calls().

## Dependencies
Pure stdlib (argparse/ast/json/collections/pathlib). Zero third-party. Read-only except explicit --out writes.

## Architecture Role
AXON-self half of the hybrid: gate-eligible deterministic introspection. Surfaced by workspace/programs/axon-graph.md. Distinct from deps/call_graph/project_graph (markdown/program graphs).

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-11 |  | Live stats 2026-06-11: 209 modules / 1878 nodes / 3811 edges (drifted from 206/1853/3776 at delivery). dead-code returns 195 candidates — heavy false-positive load because subprocess/argparse dispatch (axon.py REGISTRY entrypoints) is invisible to ast call edges; entry-set hardcoded {main,_build_parser,check,build}. cluster: label propagation, tie-break smallest label, cap 20 iters. export writes markdown map; workspace/_dashboards/axon-code-map.md ABSENT on this checkout — never persisted post-merge, no freshness/cron wiring. Skips test_* files. Default root tools/ only (no workspace/addons). |