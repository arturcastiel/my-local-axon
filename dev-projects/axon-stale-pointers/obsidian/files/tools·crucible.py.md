---
tags: [code, file]
path: tools/crucible.py
---

# tools/crucible.py

> 28 symbol(s) · 12 outbound file dependency(ies)

## Symbols
- `Execute one control. `runner` (cmd:str)->(exit_code:int) is injectable     for t`
- `In an UNATTENDED autonomous run, record this gate's outcome to the circuit break`
- `Pure: compute the gate verdict from control results. Fail-closed —     any BLOCK`
- `Resolve the diff base, or None if unresolvable. None => the change-set gate fail`
- `Return a list of schema problems (empty == valid).`
- `Run the STATIC change-set rules. Returns {violations:[...], ok:bool}.`
- `_changeset_base()`
- `_now()`
- `_record_breaker_outcome()`
- `_select()`
- `_write_status()`
- `build_parser()`
- `changed_files()`
- `cmd_changeset()`
- `cmd_gate()`
- `cmd_list()`
- `cmd_register()`
- `cmd_run()`
- `cmd_status()`
- `crucible.py`
- `git diff --name-status vs base (default: merge-base with origin/main,     fallin`
- `load_registry()`
- `main()`
- `run_changeset()`
- `run_control()`
- `save_registry()`
- `validate_registry()`
- `verdict()`

## Depends on
- [[tools·autonomous_mode.py]]
- [[tools·autonomy_breaker.py]]
- [[tools·rules·r_autonomy_breaker.py]]
- [[tools·rules·r_autonomy_cadence.py]]
- [[tools·rules·r_code_change_requires_pr_phase.py]]
- [[tools·rules·r_dont_do.py]]
- [[tools·rules·r_dont_do_lint.py]]
- [[tools·rules·r_memory_respected.py]]
- [[tools·rules·r_new_needs_test.py]]
- [[tools·rules·r_no_orphan_tools.py]]
- [[tools·rules·r_workflow_node_order.py]]
- [[tools·rules·registry.py]]
