---
tags: [code, file]
path: tests/test_rules/test_r9_axon_write.py
---

# tests/test_rules/test_r9_axon_write.py

> 30 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `._make_workspace()`
- `.test_absolute_path_to_axon_blocked()`
- `.test_append_axon_blocked_when_dev_mode_off()`
- `.test_axon_outside_workspace_root_not_flagged()`
- `.test_bare_axon_dir_blocked()`
- `.test_dot_slash_axon_path_blocked()`
- `.test_empty_action_returns_none()`
- `.test_missing_state_treated_as_dev_off()`
- `.test_parent_traversal_bypass_blocked()`
- `.test_read_never_blocked()`
- `.test_shell_tool_target_NOT_blocked_by_r9()`
- `.test_symlink_into_axon_blocked()`
- `.test_workspace_root_supplied_by_load_state()`
- `.test_write_axon_allowed_with_dev_mode()`
- `.test_write_axon_blocked_when_dev_mode_off()`
- `.test_write_axon_subdir_blocked()`
- `.test_write_outside_axon_allowed()`
- `A path containing 'axon' but outside workspace_root must not block.          Edg`
- `Build a minimal workspace skeleton with an axon/ directory.`
- `PR-009 — R9 (axon/ write gate) full coverage.  Replaces the PR-006 stub. Tests R`
- `PR-1.2: regression-guards for the 4 F-D8-001 bypass vectors.      Vectors 1-3 (s`
- `Path`
- `R9 only inspects WRITE/APPEND ops; shell pass-through is unrestricted.`
- `TestR9AxonWrite`
- `TestR9BypassVectors`
- `WRITE('<abs>/axon/foo.md') must block when <abs> is workspace_root.          The`
- `WRITE('workspace/../axon/x') must block — realpath collapses '..'.          The`
- `_ctx()`
- `test_r9_axon_write.py`
- `workspace/sneak -> ../axon ; WRITE("workspace/sneak/x") must block.          The`

## Depends on
- [[tools·rules·r9_axon_write.py]]
