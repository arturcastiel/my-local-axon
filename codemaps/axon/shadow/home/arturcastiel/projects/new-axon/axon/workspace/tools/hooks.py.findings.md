# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/hooks.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/hooks.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
Notification hooks wiring event patterns to actions (notify/log/exec); called by events.py dispatch.

## Key Structures
now_iso, load_hooks/save_hooks, event_matches, interpolate_template, run_notify/run_log

## Dependencies
stdlib: argparse, json, os, re, subprocess, sys, uuid, datetime, pathlib

## Architecture Role
Action layer of the event system; consumes events.py emissions.

## Findings Log
| date | context | finding |
|------|---------|---------|
