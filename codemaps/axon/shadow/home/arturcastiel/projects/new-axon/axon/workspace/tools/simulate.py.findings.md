# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/simulate.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/simulate.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
Dry-run a program without touching real state: W/L writes + file writes + TOOL calls intercepted.

## Key Structures
now_iso, classify_line, simulate_program, cmd_run/clean, main

## Dependencies
stdlib: argparse, json, os, re, subprocess, sys, datetime, pathlib

## Architecture Role
Safety/preview layer; backs the 'simulate <program>' menu command before irreversible ops.

## Findings Log
| date | context | finding |
|------|---------|---------|
