---
tags: [code, file]
path: tests/test_safety_freeze_undo_logging.py
---

# tests/test_safety_freeze_undo_logging.py

> 21 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `All COPY-FILE(src, dst) pairs in the branch, as (src, dst) strings.`
- `Path`
- `Payload strings of every APPEND(..., _actions.log, "<row>") in the branch.`
- `Regression test for code-dev-safety-freeze undo-logging defect.  The freeze bran`
- `Return the body of the `IF mode ≡ "freeze" →` branch, up to the `ELSE →`.      T`
- `Sanity: the freeze branch snapshots BOTH _meta.md files.`
- `Split a logged actions row into whitespace-separated fields (no trailing \\n).`
- `The fix: each snapshotted file is referenced by its own _actions.log row.      P`
- `Two reversible rows must carry distinct action-ids so undo can target each.`
- `_actions_log_rows()`
- `_copy_file_targets()`
- `_freeze_branch()`
- `_read()`
- `_row_fields()`
- `doc_anchors guard: this fix must not introduce `name.md:NNN` line anchors.`
- `test_every_snapshot_has_a_reversible_actions_log_row()`
- `test_freeze_program_exists()`
- `test_freeze_snapshots_both_metas()`
- `test_logged_action_ids_are_distinct_per_file()`
- `test_no_unresolvable_line_anchor_comments_in_freeze()`
- `test_safety_freeze_undo_logging.py`

## Depends on
- (none)
