---
tags: [code, file]
path: tests/test_loop_receipt_fault_injection.py
---

# tests/test_loop_receipt_fault_injection.py

> 26 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Append a BEGUN row directly via loop_receipt internals (no ctx-mgr).`
- `Isolated workspace for loop-receipt fault-injection tests.      Ledger lives at`
- `PR-AUTO-301 — fault-injection harness for loop-receipt.  Validates that the subs`
- `Path`
- `Sanity: a normal commit path is invisible to recover().`
- `Scenario 1: orphan BEGUN, no caller-provided live value → ABORTED.`
- `Scenario 2: live target == pre → ABORTED ("pre-image intact").`
- `Scenario 3: live target == post → COMMITTED (replay-on-recover).`
- `Scenario 4: live != pre and != post → ABORTED + drift flag.`
- `Scenario 5: a torn (incomplete JSON) line at EOF is skipped by reader.      Appe`
- `Scenario 6: SIGKILL a subprocess between BEGUN and commit.      Spawn a child th`
- `Scenario 7: recover() handles N orphans in a single pass.`
- `Scenario 8: running recover() twice does NOT add a second terminal row.`
- `_begin()`
- `_read_rows()`
- `test_committed_row_is_never_revisited()`
- `test_loop_receipt_fault_injection.py`
- `test_multiple_concurrent_orphans_all_promoted()`
- `test_orphan_with_drift_aborts_and_flags()`
- `test_orphan_with_live_eq_post_commits()`
- `test_orphan_with_live_eq_pre_aborts_clean()`
- `test_orphan_without_live_value_fn_aborts()`
- `test_recover_is_idempotent()`
- `test_subprocess_sigkill_mid_receipt_leaves_parseable_ledger()`
- `test_torn_ledger_line_is_skipped()`
- `ws()`

## Depends on
- (none)
