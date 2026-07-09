---
tags: [code, file]
path: tests/test_dag_pr_reconcile.py
---

# tests/test_dag_pr_reconcile.py

> 26 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A DAG node with no matching PR spec → PR_NODE_ORPHAN warning.`
- `A PR spec file with no matching DAG node → PR_SPEC_MISSING warning.`
- `Create a 03-prs/DAG.json with given nodes; return (dag_path, dag_dict).`
- `DAG.json NOT under a 03-prs/ dir → silently skipped (no false positives).`
- `Empty DAG.json with no sibling PR specs → no issues (both sets empty).`
- `Lowercase pr-01.md matches uppercase PR-01 node (case-normalized).`
- `No issues when every DAG node has a matching PR-*.md and vice versa.`
- `Path`
- `Tests for PR-15: DAG.json vs PR-*.md file reconciliation in dag_consistency.  Fi`
- `_make_dag()`
- `check_dag_files() must surface PR_NODE_ORPHAN from check_pr_file_sync.`
- `check_dag_files() returns no PR-sync issues when DAG and specs match.`
- `dag_consistency checker must invoke dag_consistency.py check --root <ws>.`
- `dag_consistency must be listed in freshness._checks.`
- `test_case_insensitive_match()`
- `test_check_dag_files_clean_when_synced()`
- `test_check_dag_files_surfaces_pr_orphan()`
- `test_dag_consistency_check_calls_dag_consistency_tool()`
- `test_dag_consistency_check_has_hint()`
- `test_dag_consistency_in_freshness_checks()`
- `test_dag_pr_reconcile.py`
- `test_empty_dag_with_no_specs_no_issues()`
- `test_missing_spec_detected()`
- `test_no_issues_when_dag_matches_specs()`
- `test_orphan_node_detected()`
- `test_skipped_for_non_pr_dag()`

## Depends on
- (none)
