# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/deps.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/deps.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
Program dependency-graph builder: parses Deps: headers + EXEC() calls, detects missing/circular deps.

## Key Structures
scan_programs, find_circular, reverse_graph, cmd_show/graph/check/tree, main

## Dependencies
stdlib: argparse, json, os, re, sys, pathlib

## Architecture Role
Static program-graph integrity; complements synapse next-suggests and coherence-lint.

## Findings Log
| date | context | finding |
|------|---------|---------|
