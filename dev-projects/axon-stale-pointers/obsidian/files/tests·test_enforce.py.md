---
tags: [code, file]
path: tests/test_enforce.py
---

# tests/test_enforce.py

> 32 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `--user-instruction returns valid + appends to E:source-log.`
- `A missing file path returns exit 2 (real enforcement).`
- `A write inside axon/ is allowed when L:dev-mode=true is set.`
- `A write inside axon/ requires L:dev-mode=true; missing key blocks.`
- `A write outside axon/ is always allowed.`
- `An existing file path should be valid.`
- `BF-001 regression: with no --axon, the gate must resolve the REAL axon/     dir`
- `Instructions containing `|` or newlines must be sanitized into one row.`
- `Invoke enforce.py with `args`; return (returncode, stdout_json, stderr).`
- `Multiple --user-instruction calls append rows; do not overwrite.`
- `Neither --source nor --user-instruction → exit 2 with clear error.`
- `PR-12.1 — tools/enforce.py compliance gate tests.  Fixes:   - F-D7-007a (BLOCKER`
- `The expression should round-trip in the response.`
- `The legacy `--source user:<anything>` short-circuit must now exit 2.`
- `_run()`
- ``--source user:` with empty payload is also blocked.`
- `check-arithmetic must emit advisory_only=true so callers cannot trust it.`
- `test_check_arithmetic_expression_echoed()`
- `test_check_arithmetic_is_advisory()`
- `test_check_source_existing_file_valid()`
- `test_check_source_legacy_user_prefix_blocked()`
- `test_check_source_legacy_user_prefix_blocked_empty_payload()`
- `test_check_source_missing_file_invalid()`
- `test_check_source_no_args_errors()`
- `test_check_source_pipe_and_newline_sanitized()`
- `test_check_source_user_instruction_accepted()`
- `test_check_source_user_instruction_log_is_append_only()`
- `test_check_write_default_axon_is_cwd_independent()`
- `test_check_write_inside_axon_allowed_with_dev_mode()`
- `test_check_write_inside_axon_blocked_without_dev_mode()`
- `test_check_write_outside_axon_allowed()`
- `test_enforce.py`

## Depends on
- (none)
