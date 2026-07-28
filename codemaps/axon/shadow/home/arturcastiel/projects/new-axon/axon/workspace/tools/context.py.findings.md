# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/context.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/context.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
Context-pressure estimator: tracks estimated token usage vs the window and labels pressure (check/record/reset/report).

## Key Structures
load_state/save_state, pressure_label, pressure_icon, cmd_check/record/tee_record/reset/report, main

## Dependencies
stdlib: json, sys, os, datetime

## Architecture Role
Feeds the kernel context-pressure gate (checkpoint/HALT before phase transitions).

## Findings Log
| date | context | finding |
|------|---------|---------|
