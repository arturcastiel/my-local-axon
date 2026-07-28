# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/events.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/events.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
caller-program: codemap-shadow
caller-project: axon

## Summary
Event bus for EMIT/ON reactive composition: emit/list/handlers/register/unregister.

## Key Structures
now_iso, load_json/save_json, cmd_emit/list/handlers/register/unregister

## Dependencies
stdlib: argparse, json, os, subprocess, sys, datetime, pathlib

## Architecture Role
Reactive pipeline backbone; hooks.py dispatches on emitted events.

## Findings Log
| date | context | finding |
|------|---------|---------|
