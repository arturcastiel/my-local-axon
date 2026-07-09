---
tags: [code, file]
path: tests/test_session_runid_rotation.py
---

# tests/test_session_runid_rotation.py

> 14 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A cleanly-closed session must never be resurrected by rotation.`
- `Boot A stamps token A; the live session checkpoints with last_run_id=A. A compac`
- `No rotation between the session's stamp and recovery (same boot) → NOT a compact`
- `Path`
- `Point default_workspace at a tmp dir so current_run_id()/rotate_run_id() (which`
- `Wave G / G2 — arch-audit #6: the run-id must ROTATE per boot or compaction is ne`
- `_mk_session()`
- `test_closed_session_not_recovered_even_across_boots()`
- `test_current_run_id_stable_after_rotate()`
- `test_rotate_changes_token_across_boots()`
- `test_same_boot_active_session_not_recovered()`
- `test_session_runid_rotation.py`
- `test_two_boot_compaction_is_detected()`
- `ws()`

## Depends on
- (none)
