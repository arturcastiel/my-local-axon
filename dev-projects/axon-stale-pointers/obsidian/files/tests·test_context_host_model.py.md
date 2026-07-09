---
tags: [code, file]
path: tests/test_context_host_model.py
---

# tests/test_context_host_model.py

> 38 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `._import_module()`
- `.test_case_insensitive_host_model()`
- `.test_claude_3_stays_128k()`
- `.test_claude_4_7_returns_200k()`
- `.test_cli_limit_overrides_host_model()`
- `.test_critical_pressure_at_correct_threshold()`
- `.test_explicit_limit_still_wins_via_cli()`
- `.test_longest_prefix_wins()`
- `.test_no_host_model_returns_default()`
- `.test_opus_4_7_returns_200k()`
- `.test_pressure_envelope_includes_limit_source()`
- `.test_reset_records_limit_source()`
- `.test_status_uses_host_model()`
- `.test_unknown_model_falls_back_to_default()`
- `.test_vendor_prefix_stripped()`
- `A token count that's 'critical' under 128k must NOT be critical under 200k.`
- `Backwards-compat: any caller that never set L:host-model gets the     same DEFAU`
- `Build a minimal workspace skeleton with longterm/ + working/ subdirs.`
- `Explicit --limit beats the host-model lookup.`
- `Host-model lookup is lowercased — 'Opus-4.7' matches.`
- `Invoke context.py with the given args + workspace; return JSON output.`
- `L:host-model=claude-3 → 128000 (the legacy window).`
- `L:host-model=claude-4.7 → 200000 via lookup.`
- `L:host-model=opus-4.7 → 200000 (matches the opus-4.7 key).`
- `PR-7.1 — context.py host-model-aware context-limit tests.  Closes:   - F-D9-001`
- `Path`
- `TestCLIIntegration`
- `TestResolveLimit`
- `Unknown model name → DEFAULT_LIMIT, source distinguishes from unset.`
- `Unset L:host-model → DEFAULT_LIMIT, source='default'.`
- `_run()`
- `_set_host_model()`
- `_ws()`
- `anthropic/claude-4.6' → strips vendor and matches 'claude-4.6'.`
- `opus-4.7-experimental' → matches 'opus-4.7' (longest prefix).`
- `reset action surfaces limit_source so callers can verify which path resolved.`
- `test_context_host_model.py`
- `test_no_host_model_preserves_legacy_behavior()`

## Depends on
- (none)
