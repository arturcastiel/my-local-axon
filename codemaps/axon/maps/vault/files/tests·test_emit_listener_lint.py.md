---
tags: [code, file]
path: tests/test_emit_listener_lint.py
---

# tests/test_emit_listener_lint.py

> 27 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A new EMIT not in TELEMETRY_ONLY and no ON handler → ok=False.`
- `A program emitting only TELEMETRY_ONLY events → ok=True.`
- `EMIT with a matching ON(listener) in the same dir → ok=True, in wired.`
- `EMIT with quoted event name is detected.`
- `Files under compiled/ are not scanned.`
- `ON with placeholder ({e}) is not counted as a real listener.`
- `ON(event) in a program file is detected.`
- `Path`
- `Regression: the real workspace/programs/ has no new unwhitelisted EMITs.`
- `Simple EMIT(event, payload) is detected.`
- `Template placeholder events ({W:task}) are skipped.`
- `Tests for PR-18: emit-without-listener lint + triage.  Finding #17: 24 of 26 EMI`
- `_write_md()`
- `test_collect_emits_quoted()`
- `test_collect_emits_simple()`
- `test_collect_emits_skips_compiled_dir()`
- `test_collect_emits_skips_templates()`
- `test_collect_ons_simple()`
- `test_collect_ons_skips_templates()`
- `test_emit_listener_lint.py`
- `test_emit_listener_lint_registered()`
- `test_lint_fails_on_new_unwhitelisted_emit()`
- `test_lint_passes_on_actual_programs_dir()`
- `test_lint_passes_when_all_emits_whitelisted()`
- `test_lint_passes_when_emit_has_listener()`
- `test_lint_returns_whitelist_size()`
- `test_telemetry_only_is_frozenset()`

## Depends on
- (none)
