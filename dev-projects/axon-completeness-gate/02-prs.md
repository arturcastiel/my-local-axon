# PR list — AXON Bug-Free Hardening
19 PRs

## PR-01 — phase_model mode-aware completeness gate  [DONE 3df2ba1]
- wave A · findings #2,#8 · depends —
- change: done() reads manifest `outputs` only (SSOT); REQUIRED_OUTPUTS=seed+drift ref. seed_outputs()+CLI.
- test: tests/test_phase_model_outputs.py

## PR-02 — code-dev-new seeds the gate  [DONE c7724d3]
- wave A · findings #2 · depends PR-01
- change: code-dev-new calls phase-model seed-outputs after init.
- test: integration

## PR-03 — # emits: SSOT + drift-lock  [DONE 5c3b35b]
- wave A · findings #2,#8 · depends PR-01
- change: tools/emits.py + ladder # emits/# phase headers + L1 drift-lock test.
- test: tests/test_emits.py, tests/test_emits_drift.py

## PR-04 — reconnect emits->seed_outputs + recompile  [TODO]
- wave A · findings liveness · depends PR-03
- change: seed-outputs --from-emits resolves each phase program's # emits as SSOT (phase_model imports emits -> live). Recompile stale .cmp.md.
- test: tests/test_phase_model_outputs.py (from-emits)

## PR-05 — R_TERMINAL_OUTPUTS rule (general, silent-until-flag)  [TODO]
- wave A · findings L3 · depends PR-03
- change: RUNTIME/BLOCK/silent-until-flag rule (model r_state_surfaced): on :done resolve # emits, BLOCK if absent. Default-OFF.
- test: tests/test_terminal_outputs.py

## PR-06 — workflow_run node outputs schema + verify  [TODO]
- wave A · findings L4 · depends PR-01
- change: optional per-synapse outputs:; verify_node_outputs(); record_step downgrade; advance refuse. Backward-compat.
- test: tests/test_workflow_node_outputs.py

## PR-07 — R9: PreToolUse Bash matcher -> axon/ write gate  [TODO]
- wave B · findings #1 · depends —
- change: Bash(+MultiEdit) PreToolUse matcher via argv-inspecting gate denying axon/ shell writes when dev-mode!=true.
- test: tests/test_enforce_bash_gate.py

## PR-08 — R9: compile_write traversal sanitize + _axon_io  [TODO]
- wave B · findings #3 · depends —
- change: sanitize --name; assert under out_dir; route via _axon_io.atomic_write.
- test: tests/test_compile_write_traversal.py

## PR-09 — R9: enforce.py cwd->AXON_ROOT classification  [TODO]
- wave B · findings #11 · depends —
- change: anchor relative targets to AXON_ROOT not CWD in is_inside_axon.
- test: tests/test_enforce_root_anchor.py

## PR-10 — R9: _axon_io mandatory write primitive (lint)  [TODO]
- wave B · findings #4 · depends PR-08
- change: lint forbidding raw open('w')/write_text in tools/ except whitelist; route offenders.
- test: tests/test_axon_io_lint.py

## PR-11 — Enforcement: crucible carriage of verify-only BLOCK rules  [TODO]
- wave C · findings #5 · depends PR-05
- change: crucible control running verify-only BLOCK rules over the tree at merge — the missing fail-closed runner.
- test: tests/test_crucible_verify_carriage.py

## PR-12 — Enforcement: identity-independent response/dont-do gate  [TODO]
- wave C · findings #12 · depends —
- change: tracked sentinel marking repo AXON-governed (or identity-independent gate) so fresh-clone/CI aren't allow-all.
- test: tests/test_hook_identity_independent.py

## PR-13 — Enforcement: Stop-hook honest scope / gate-on-next-turn  [TODO]
- wave C · findings #7 · depends PR-11
- change: persist BLOCK + force rewrite/HALT next turn (not log-only); OR honestly reclassify the BLOCK label.
- test: tests/test_stop_hook_next_turn.py

## PR-14 — Drift: wire dispatch_index into freshness+cron  [TODO]
- wave D · findings #9 · depends —
- change: add dispatch_index to freshness._checks + _refresh_steps.
- test: tests/test_freshness_dispatch_index.py

## PR-15 — Drift: dag_consistency DAG-vs-PR + freshness/boot  [TODO]
- wave D · findings #10,#13,#16 · depends —
- change: PR-file cross-check in dag_consistency; wire into freshness + boot tick.
- test: tests/test_dag_pr_reconcile.py

## PR-16 — Firing: reanchor hook re-ticks anticipate  [TODO]
- wave E · findings #14 · depends —
- change: reanchor hook also runs anticipate --footer + refreshes W:orchestrator-last-tick.
- test: tests/test_reanchor_anticipate.py

## PR-17 — Firing: turn-log/prompt-log driven by a hook  [TODO]
- wave E · findings #15 · depends —
- change: drive turn-log+prompt-log from a PostToolUse/Stop hook so always-on logging fires.
- test: tests/test_turn_log_hook.py

## PR-18 — Firing: emit-without-listener lint + triage  [TODO]
- wave E · findings #17 · depends —
- change: triage 24 unhandled EMITs; wire intended ONs; add emit-without-listener lint.
- test: tests/test_emit_listener_lint.py

## PR-19 — Resume: session-owner token instead of getppid  [TODO]
- wave F · findings #6 · depends —
- change: replace getppid liveness key with a stable boot-epoch/run-id token.
- test: tests/test_session_recovery_token.py
