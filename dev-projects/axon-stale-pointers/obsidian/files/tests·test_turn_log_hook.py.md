---
tags: [code, file]
path: tests/test_turn_log_hook.py
---

# tests/test_turn_log_hook.py

> 20 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Calling _append_turn_log twice appends two entries to the same file.`
- `ModuleType`
- `Path`
- `Tests for PR-17: turn-log + prompt-log driven by a hook.  Finding #15: turn-log`
- `_append_turn_log creates workspace/log/turns/YYYY-MM-DD.md if absent.`
- `_append_turn_log never raises — exceptions are silently caught.`
- `_append_turn_log skips when turn-log-enabled.md contains 'false'.`
- `_load_reanchor()`
- `_load_verify_stop()`
- `main() calls _append_turn_log even when the response gate passes.`
- `prompt_log.py failure is silently swallowed — hook exits 0.`
- `reanchor_store must call prompt_log.py record with the user prompt.`
- `test_prompt_log_failure_does_not_block()`
- `test_prompt_log_record_is_called()`
- `test_turn_log_appends_on_subsequent_turns()`
- `test_turn_log_disabled_by_flag()`
- `test_turn_log_file_created_on_first_turn()`
- `test_turn_log_hook.py`
- `test_turn_log_survives_exception()`
- `test_verify_stop_calls_append_turn_log_on_clean_response()`

## Depends on
- (none)
