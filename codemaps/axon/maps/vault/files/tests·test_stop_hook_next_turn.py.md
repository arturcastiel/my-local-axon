---
tags: [code, file]
path: tests/test_stop_hook_next_turn.py
---

# tests/test_stop_hook_next_turn.py

> 26 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A corrupt gate file is silently consumed — turn is not blocked.`
- `A gate older than _GATE_TTL is treated as expired — turn is allowed.`
- `An expired gate file is deleted even though it doesn't block the turn.`
- `Gate file is deleted after being consumed (not left to block future turns).`
- `Gate file with a fresh BLOCK → deny turn (exit 2).`
- `ModuleType`
- `No gate file → allow turn (exit 0).`
- `Path`
- `Tests for PR-13: gate-on-next-turn for response-gate BLOCK verdicts.  Finding #7`
- `When neither sentinel nor cognition-frame is set, gate is a no-op.`
- `_load_next_turn_gate()`
- `_load_verify_stop()`
- `next_turn_gate.py must be in UserPromptSubmit hooks WITHOUT '|| true'.`
- `test_corrupt_gate_file_exits_0()`
- `test_expired_gate_exits_0()`
- `test_expired_gate_still_consumed()`
- `test_missing_sentinel_skips_gate()`
- `test_no_pending_gate_exits_0()`
- `test_pending_gate_consumed_after_read()`
- `test_pending_gate_exits_2()`
- `test_settings_wires_next_turn_gate()`
- `test_stop_hook_next_turn.py`
- `test_verify_stop_no_pending_gate_on_pass()`
- `test_verify_stop_writes_pending_gate_on_block()`
- `verify_stop.py must NOT write a gate file when verify.py passes.`
- `verify_stop.py must write response-gate-pending.json when verify.py returns BLOC`

## Depends on
- (none)
