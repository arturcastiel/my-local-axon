---
tags: [code, file]
path: tests/test_igap_dispatch_loop_receipt.py
---

# tests/test_igap_dispatch_loop_receipt.py

> 26 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `Both igap receipts carry actor='igap'.`
- `N feedback writes → N BEGUN + N terminal audit-row receipts.`
- `One igap record emits: audit-row receipt + auto-update-counter receipt.      Eac`
- `PR-AUTO-204 — igap + dispatch-feedback writes onto loop-receipt.  Every state-mu`
- `Path`
- `Subprocess tests must not write to AXON_DIR/state/loop-receipt.ledger.jsonl.`
- `Successive records' audit-row pre/post values grow monotonically.`
- `The audit-row receipt's target.path points at the daily log file.`
- `The auto-update-counter receipt's target.path points at     working/igap-session`
- `Unknown gap type errors at argparse BEFORE any receipt is opened.`
- `_igap_record()`
- `_ledger_path()`
- `_read_ledger()`
- ``dispatch correlate` (when a recent dispatch exists) emits a receipt.`
- ``dispatch feedback` writes a BEGUN+COMMITTED audit-row receipt.`
- `test_dispatch_correlate_emits_audit_row()`
- `test_dispatch_feedback_emits_audit_row()`
- `test_dispatch_feedback_invariant_begun_equals_terminal()`
- `test_igap_actor_is_igap()`
- `test_igap_audit_row_target()`
- `test_igap_counter_target()`
- `test_igap_dispatch_loop_receipt.py`
- `test_igap_invalid_type_no_orphan()`
- `test_igap_pre_post_growth()`
- `test_igap_record_emits_two_receipts()`
- `test_isolation_from_real_ledger()`

## Depends on
- [[conftest.py]]
