---
tags: [code, file]
path: tests/test_auto_audit_loop_receipt.py
---

# tests/test_auto_audit_loop_receipt.py

> 22 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `All auto-audit receipts use target_kind='jsonl-append'.`
- `Each VALID_ACTOR maps to its trigger source per _ACTOR_TO_TRIGGER.`
- `For N successful record calls, BEGUN count == terminal count == N.`
- `PR-AUTO-203 — auto_audit writes onto loop-receipt.  Every `auto_audit record` ca`
- `Path`
- `Receipt actor field is namespaced: auto-audit:<row_actor>.`
- `Single auto_audit record → 2 ledger rows (begun + committed).`
- `The real <AXON_DIR>/state/loop-receipt.ledger.jsonl must not be touched.`
- `Unknown actor → record fails BEFORE the receipt is opened (no orphan).`
- `_ledger_path()`
- `_read_ledger()`
- `_record()`
- `post_value = pre_value + appended; sha256 of bytes is stable.`
- `test_auto_audit_loop_receipt.py`
- `test_compile_failed_actor_skip()`
- `test_invariant_begun_equals_terminal()`
- `test_ledger_isolated_to_test_workspace()`
- `test_pre_post_values_capture_file_growth()`
- `test_receipt_actor_includes_audit_actor()`
- `test_receipt_trigger_maps_per_actor()`
- `test_record_emits_begun_and_committed()`
- `test_target_kind_is_jsonl_append()`

## Depends on
- [[conftest.py]]
