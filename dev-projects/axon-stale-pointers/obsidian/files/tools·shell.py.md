---
tags: [code, file]
path: tools/shell.py
---

# tools/shell.py

> 49 symbol(s) · 2 outbound file dependency(ies)

## Symbols
- `(subcommand, args-after-subcommand, -C dir) for a token list starting at 'git'.`
- `.__init__()`
- `Dry-run: report what gate_check would do, without executing.`
- `Every deletion the command performs → [{verb, targets, recursive}]. Covers direc`
- `Find shell-redirect targets (`> file`, `>> file`, `tee -a file`).      arch-audi`
- `GateBlock`
- `Map a git command to an autonomous_mode DESTRUCTIVE_OPS name, or (None, c_dir).`
- `Protected-subtree deletes DENY (never routine); bulk deletes need an explicit`
- `Raise GateBlock unless the active grant explicitly delegates `op` for the target`
- `Raised when a command is refused by the sandbox.`
- `Return (head, subcommand) for a tokenized command.      Skips leading shell-var-`
- `Run all gate checks on `argv` without executing. Returns a verdict dict.      Ra`
- `S7b — the host-level current-node op-class gate. While a doctrine run is active,`
- `Split a shell line on `&&`, `;`, `|` and return per-command token lists.      We`
- `Strip leading wrapper heads (xargs/env/timeout/busybox …) so the REAL verb surfa`
- `Subset of already-axon/-classified paths that are kernel-floor files.`
- `The current doctrine-run node record the runner writes each step (PR-014), or`
- `The repo root the write-barrier anchors to (the dir holding axon/ + workspace/).`
- `True if a sed/perl token cluster requests in-place editing: -i, -i.bak, -pi,`
- `True iff `p` resolves inside `workspace_root`/axon. Delegates to the single`
- `True iff an unattended autonomous run is in progress. Fail-safe False.`
- `_classify_deletions()`
- `_classify_destructive_git()`
- `_command_anchors()`
- `_command_head()`
- `_default_workspace()`
- `_dev_mode_active()`
- `_doctrine_current_node()`
- `_enforce_deletions()`
- `_enforce_destructive_git()`
- `_enforce_doctrine_node()`
- `_extract_redirect_targets()`
- `_git_parse()`
- `_git_repo_slug()`
- `_has_inplace_flag()`
- `_is_axon_path()`
- `_kernel_floor_paths()`
- `_read_longterm()`
- `_resolve_repo_anchor()`
- `_split_commands()`
- `_unattended_run_active()`
- `_unwrap_wrapper()`
- `append_audit()`
- `cmd_exec()`
- `cmd_inspect()`
- `gate_check()`
- `main()`
- `owner/name of the origin remote for the repo at c_dir (or cwd); None if unresolv`
- `shell.py`

## Depends on
- [[_unknown_]]
- [[tools·_axon_paths.py]]
