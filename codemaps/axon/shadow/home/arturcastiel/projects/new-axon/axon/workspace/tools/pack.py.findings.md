# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/tools/pack.py
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/tools/pack.py
shadow-created: 2026-07-13
shadow-updated: 2026-07-13
git-hash: b17382473ddad3ae8892c9de5d1e691514cfef6f
git-branch: main
git-commit: b178af5
git-commit-msg: axon-state-surface: menu renders backup + plans from the sna
caller-program: codemap-shadow
caller-project: axon

## Summary
.axon bundle format (zip): manifest + programs/ + templates/ + tools/; pack/unpack/inspect/list.

## Key Structures
now_iso, extract_program_meta, find_related_files, cmd_pack/unpack/inspect/list

## Dependencies
stdlib: argparse, json, os, re, sys, zipfile, datetime, pathlib

## Architecture Role
Program distribution/portability; packages a program + its deps for sharing.

## Findings Log
| date | context | finding |
|------|---------|---------|
