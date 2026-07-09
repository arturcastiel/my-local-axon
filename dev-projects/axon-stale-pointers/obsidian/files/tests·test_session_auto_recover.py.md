---
tags: [code, file]
path: tests/test_session_auto_recover.py
---

# tests/test_session_auto_recover.py

> 32 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `.test_active_session_with_current_pid_NOT_recovered()`
- `.test_empty_dir_scans_zero()`
- `.test_legacy_pid_mismatch_still_triggers_recovery()`
- `.test_local_dev_projects_discovered()`
- `.test_missing_dir_is_no_op()`
- `.test_multiple_sessions_partial_recovery()`
- `.test_no_dev_projects_is_no_op()`
- `.test_run_id_mismatch_triggers_recovery()`
- `.test_sibling_my_axon_dev_projects_discovered()`
- `A session whose last_pid matches the current PID is healthy.`
- `A session with stale last_run_id is recovered automatically (PR-19).`
- `An existing-but-empty dir scans 0 sessions.`
- `Backward-compat: write a pre-PR-19 session with only last_pid (no last_run_id).`
- `Boot must not fail if no my-axon/dev-projects/ is discoverable.`
- `Create a fresh active session via session.start().`
- `End-to-end: invoking boot.py prints `session_recovery` in its JSON.`
- `If <workspace>/dev-projects exists, it's used as the sessions root.`
- `If the sessions root doesn't exist, return ok=True with 0 scanned.`
- `Mutate last_run_id so recover() sees a mismatch (PR-19 liveness key).`
- `PR-6.1 — session.auto_recover + boot wire-up tests.  Closes F-D9-022 (session.re`
- `Path`
- `Pre-PR-19 session (only last_pid, no last_run_id) still recovers (backward compa`
- `Scan recovers only the stale ones; healthy ones untouched.`
- `Standard AXON layout: my-axon is a sibling of the workspace's parent.`
- `TestAutoRecover`
- `TestBootAutoRecoverWireUp`
- `_force_stale_pid()`
- `_force_stale_run_id()`
- `_load()`
- `_make_session()`
- `test_boot_json_contains_session_recovery()`
- `test_session_auto_recover.py`

## Depends on
- (none)
