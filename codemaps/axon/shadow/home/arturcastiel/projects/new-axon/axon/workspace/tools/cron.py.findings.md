# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/cron.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/cron.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
Persistent scheduler for recurring/time-triggered programs; jobs in scheduler/cron.json; check-overdue at boot.

## Key Structures
now_utc/now_iso, load_jobs/save_jobs, parse_schedule, is_overdue, cmd_add/list, main

## Dependencies
stdlib: argparse, json, os, re, sys, uuid, datetime, pathlib

## Architecture Role
Scheduler subsystem; boot surfaces overdue jobs; feeds the menu Cron line + breaker.

## Findings Log
| date | context | finding |
|------|---------|---------|
