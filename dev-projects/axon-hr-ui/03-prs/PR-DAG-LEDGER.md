# PR-DAG-LEDGER — code-dev DAG-aware PR ledger
Status: merged
Commit: 14f1ace
Phase: pr
Lane: AXON (autonomous, non-kernel)  ·  Depends-on: none  ·  Standalone

## Scope
- `tools/dag.py` — `summarize()`/`cmd_summary()` exposed as `TOOL(dag, summary)` (status-agnostic tally).
- `workspace/programs/code-dev-state-status.md` — renders a DAG ledger line.
- `tests/test_dag.py` — summarize/cmd_summary coverage.

## Why
The glob-only PR count read v4 DAG-only projects (PRs tracked in 03-prs/DAG.json, 0 standalone PR-*.md)
as "0 PRs". This ledger surfaces the real DAG node tally in code-dev status.

## Acceptance
28 dag tests green; `dag summary` returns total/pr_total/open/line; status program shows the ledger line.

## Result
Merged 14f1ace.
