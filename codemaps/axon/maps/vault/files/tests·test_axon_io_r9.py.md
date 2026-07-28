---
tags: [code, file]
path: tests/test_axon_io_r9.py
---

# tests/test_axon_io_r9.py

> 26 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `An explicit 'value: false' line blocks the write.`
- `Missing dev-mode key is treated as dev-mode=false (deny-by-default).`
- `Path`
- `Redirect _AXON_DIR + _DEVMODE_KEY into tmp_path so tests are hermetic.      Layo`
- `Tests for R9 enforcement in tools/_axon_io.atomic_write.  Spec: my-axon/dev-proj`
- `The R9WriteError message tells the user exactly how to enable dev-mode.`
- `With dev-mode=true the write succeeds normally.`
- `Writes outside AXON_DIR are never gated, regardless of dev-mode.`
- `Writes under AXON_DIR raise R9WriteError when dev-mode is false.`
- `_set_devmode()`
- `atomic_write_json delegates to atomic_write — gate must fire.`
- `atomic_write_json passes through and serializes correctly with dev-mode on.`
- `dev-mode.md without 'value:' prefix but containing just 'true' is honoured.`
- `fake_axon()`
- `test_actor_whitelist_empty_in_v1()`
- `test_atomic_write_json_inherits_gate()`
- `test_atomic_write_json_ok_in_dev_mode()`
- `test_axon_io_r9.py`
- `test_devmode_plain_true_format()`
- `test_devmode_value_false_blocks()`
- `test_error_message_is_actionable()`
- `test_write_inside_axon_blocked_when_dev_mode_off()`
- `test_write_inside_axon_blocked_when_devmode_missing()`
- `test_write_inside_axon_ok_when_dev_mode_on()`
- `test_write_outside_axon_ok()`
- `v1 ships with an empty whitelist — _actor= alone does not bypass R9.`

## Depends on
- [[tools·_axon_io.py]]
