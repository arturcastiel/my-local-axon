# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/rtk.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/rtk.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
Optional RTK (token-killer) integration; wraps the RTK CLI, no-ops gracefully if absent.

## Key Structures
find_rtk, rtk_available, run_rtk, cmd_check/rewrite/gain/discover/session/status, main

## Dependencies
stdlib: json, os, shutil, subprocess, sys; optional external RTK CLI

## Architecture Role
Optional token-reduction integration; fail-degrades when RTK not installed.

## Findings Log
| date | context | finding |
|------|---------|---------|
