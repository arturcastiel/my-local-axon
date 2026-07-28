---
tags: [code, file]
path: tests/test_axon_io_lint.py
---

# tests/test_axon_io_lint.py

> 28 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A file NOT in the whitelist with a raw write → ok=False, in violations.`
- `A file in the whitelist with raw writes → ok=True, in whitelisted list.`
- `A raw write on a commented-out line should not be flagged.`
- `Filename containing 'a' (e.g. '_meta.md', 'data.txt') should not trigger mode de`
- `Path`
- `Regression: the real tools/ directory has no unwhitelisted raw writes.`
- `Tests for tools/axon_io_lint.py (axon-completeness-gate PR-10).  Covers:   - fin`
- `_write_py()`
- `f["path"] inside open() should not be treated as 'a' mode.`
- `open(path) defaults to 'r' — no mode arg means no write.`
- `test_axon_io_lint.py`
- `test_comment_suppresses_detection()`
- `test_detects_open_append_mode()`
- `test_detects_open_write_binary()`
- `test_detects_open_write_mode()`
- `test_detects_write_bytes()`
- `test_detects_write_text()`
- `test_ignores_open_no_explicit_mode()`
- `test_ignores_open_read_binary()`
- `test_ignores_open_read_mode()`
- `test_lint_fails_on_unwhitelisted_raw_write()`
- `test_lint_passes_on_actual_tools_dir()`
- `test_lint_passes_on_clean_file()`
- `test_lint_passes_when_file_whitelisted()`
- `test_multiple_raw_writes_per_file()`
- `test_no_false_positive_filename_with_a()`
- `test_no_false_positive_path_keyword()`
- `test_whitelist_is_frozenset()`

## Depends on
- (none)
