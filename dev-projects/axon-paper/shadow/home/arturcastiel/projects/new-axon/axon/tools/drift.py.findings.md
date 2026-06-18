# SHADOW: /home/arturcastiel/projects/new-axon/axon/tools/drift.py
source-path: /home/arturcastiel/projects/new-axon/axon/tools/drift.py
shadow-created: 2026-06-18
shadow-updated: 2026-06-18
git-hash: 50c1f80
git-branch: main
git-commit: 50c1f80
git-commit-msg: chore: regenerate maintenance artifacts
caller-program: code-dev-study
caller-project: axon-paper

## Summary
Real drift detector, not vapor. Compares actual tool call sequence to expected sequence extracted from program. Score = normalized edit distance over matched prefix. State at workspace/working/drift-trace.json. Subcommands: init --program, record --tool, check, reset, gate. Fail-closed: no trace = state=unknown, decision=halt, modifier=-50.

## Key Structures
_(not yet analysed)_

## Dependencies
_(not yet analysed)_

## Architecture Role
_(not yet analysed)_

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-18 |  | VERIFIED: drift.py is functional. init --program <path> extracts expected tool call sequence from .md file. Scores: 0-0.10=stable, 0.10-0.40=drift, 0.40+=diverged. Fail-closed gate: unknown when no trace, trace unparseable, malformed, or stale beyond DRIFT_TRACE_TTL_S. Currently no active trace (workspace/working/drift-trace.json absent). Fix: run python3 tools/drift.py init --program workspace/programs/menu.md to start a trace. IMPLICATION FOR PAPER: drift detection is REAL and FUNCTIONAL. 'No active trace' ≠ 'not working'. The gate being fail-closed (halt on unknown) is actually a STRONGER claim than 'soft drift warning' — demonstrates conservative-by-default governance. Paper differentiator claim VALID but needs initialization note. |