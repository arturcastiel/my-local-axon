# SHADOW: tools/memory.py
source-path: tools/memory.py
shadow-created: 2026-07-09
shadow-updated: 2026-07-09
git-hash: f30335ef270c0538df02642fd45a0f4d4aa39942
git-branch: main
git-commit: de0a760
git-commit-msg: axon-obsidian: the invokable code-dev-obsidian step + docs
caller-program: code-dev-study
caller-project: axon-stale-pointers

## Summary
Unified W:/L:/E: memory CLI. One file per key under workspace/memory/{working,longterm,episodic}. L: writes go through single-writer _longterm.write_from_workspace with atomic write + capped rollback(3). W: plain atomic file write.

## Key Structures
_(not yet analysed)_

## Dependencies
_(not yet analysed)_

## Architecture Role
_(not yet analysed)_

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-09 |  | STALE-POINTER SEAM A: W:active-phase is just a file ANY caller can set; no validation that the value's program segment names an existing program (code-dev-pr:1 references nonexistent code-dev-pr.md), no TTL/session-scoping, no coherence link to _phases.json. Kernel stamps are protocol-level agent discipline; nothing mechanical detects a never-cleared pointer. |