---
tags: [code, file]
path: tests/test_shell_sandbox.py
---

# tests/test_shell_sandbox.py

> 43 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `.test_append_redirect_into_axon_blocked()`
- `.test_audit_is_append_only()`
- `.test_block_writes_audit_row()`
- `.test_chained_commands_both_inspected()`
- `.test_exec_audit_log_populated()`
- `.test_exec_refuses_blocked_command()`
- `.test_exec_runs_allowed_command()`
- `.test_git_add_axon_blocked()`
- `.test_inspect_allow()`
- `.test_inspect_block_axon_write()`
- `.test_inspect_block_hard_forbidden()`
- `.test_mkdir_outside_axon_allowed()`
- `.test_no_subcommand_prints_help()`
- `.test_pattern_refused()`
- `.test_pipe_character_in_argv_sanitized()`
- `.test_pipe_split_doesnt_block_read_side()`
- `.test_read_only_git_outside_axon_allowed()`
- `.test_redirect_into_axon_blocked()`
- `.test_safe_rm_in_tmp_not_blocked()`
- `.test_semicolon_split_inspected()`
- `.test_symlink_into_axon_blocked()`
- `.test_write_to_axon_allowed_with_dev_mode()`
- `.test_write_to_axon_blocked_without_dev_mode()`
- `An argv containing `|` must not break the markdown table format.`
- `Build a minimal workspace skeleton with an axon/ dir.`
- `PR-1.1 — tools/shell.py sandbox tests.  The pre-PR-1.1 OPTIONAL/host registratio`
- `Path`
- `REGISTRY.json must now list shell as ACTIVE/kernel (was OPTIONAL/host).`
- `TestAuditTrail`
- `TestCLI`
- `TestCompoundCommands`
- `TestHardForbidden`
- `TestR9PathEnforcement`
- `_load()`
- `_run()`
- `_ws()`
- ``cat x | grep y` — neither segment writes; both fine.`
- ``ls && cp x axon/y` — second segment must be caught.`
- ``rm <workspace-relative-path>` is allowed; only `rm -rf /` is hard-blocked.`
- `echo 'x' > axon/foo.md must be caught via redirect inspection.`
- `test_registry_has_shell_active()`
- `test_shell_sandbox.py`
- `workspace/sneak -> axon ; write through symlink → blocked via realpath.`

## Depends on
- (none)
