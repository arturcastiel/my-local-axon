# 01 — Study: the MEGA re-sweep findings (current AXON)

> A deep adversarial correctness sweep, 2026-06-03/04. Method: 5 slices — **tools-correctness**,
> **rules+crucible gate**, **programs-actually-work**, **kernel+state+memory** (subagents, each grounding
> every claim by reading + running the code), plus **integration/registry + gate-wiring** done inline. Every
> finding below was reproduced (exit codes / wrong outputs shown by the agent). Strong refuted + swept-clean
> lists accompany them, so the survivors are signal, not noise.

## Verdict
AXON is broadly sound (large swept-clean surface), but the sweep found **2 HIGH + ~8 MED + ~3 LOW** real
defects — concentrated in the predicted class: **mechanisms that register / import / `--help`-smoke fine but
whose skeleton is broken or never executed in the real path.** None is in the autonomy discipline (audited
twice this session) or the crucible rule-wiring (swept inline — clean).

## Findings (grounded; file:line · repro · fix)

### HIGH
- **H1 — R9 axon/-write gate fails OPEN in a fresh clone / CI.** `tools/hooks/enforce_pretooluse.py:176-195`
  is the ONLY mechanical enforcer of "edits under `axon/` require dev-mode". Its `_axon_active()` (:163-173)
  returns False unless `workspace/memory/longterm/cognition-frame.md` == `AXON-OS` — but that file is
  **gitignored** and written only by an LLM boot STORE (no tool persists it). So pre-boot / fresh clone / CI,
  the hook `sys.exit(0)` → any Edit/Write to `axon/` (incl. `KERNEL-SLIM.md`) is allowed with dev-mode off.
  **Repro (agent ran):** removed the file → edit-to-`axon/` payload piped to the hook → exit 0 (allowed);
  restored `AXON-OS` + dev-mode=false → exit 2 (blocked). The Stop gate + write-time dont-do guard share the
  same short-circuit. **Fix:** R9 is identity-independent — enforce it for `axon/`-targeted writes regardless
  of boot/persona (treat absent frame as "AXON repo, not yet booted, still protect the core"), or arm via a
  TRACKED sentinel decoupled from the gitignored runtime key. **Risk:** must not break the booted dev-mode
  path; own PR + test.

- **P1 — `synapse-suggest` call-site drift (3 ACTIVE programs).** Real CLI: `rank --state <FILE> [--goal
  <FILE>] [--top N] [--explain]` (`tools/synapse_suggest.py:507-518`; subcommand REQUIRED, `--state` is a
  file PATH). Drifted callers:
  - `workspace/programs/workflow-run.md:172` (adaptive-mode branch) — `TOOL(synapse-suggest, "--context … --history … --top-k 5")`: no subcommand + nonexistent flags → exit 2 on every adaptive workflow.
  - `workspace/programs/workflow-new.md:96` (Phase-C synapse-build loop) — same shape, same failure.
  - `workspace/programs/orchestrator.md:84,116` (mainline tick) — uses `rank` but `--state-json/--goal-json`
    (real: `--state/--goal`) AND passes an inline dict where a file path is required → exit 2.
  Invisible to `verify.py` R_TOOL_CALL_EXISTS (blind to `choices=`-based subcommands + 2nd-token-is-flag).
  **Fix:** correct subcommand+flags; write state/goal to temp JSON files and pass the paths.

### MED
- **M1 — `axon_audit.py:402,417` usage/prompt metrics always zero.** `usage_log_stats`/`prompt_log_stats`
  read `MYAXON_ROOT/memory/…`, but every WRITER + every other reader uses `workspace/memory/…` (usage.py,
  prompt_log.py, session_save, …). → audit's usage axis pinned low + emits a false "No usage data yet"
  recommendation into the audit→improve loop. **Fix:** read from `workspace/` (mirror usage.py).
- **M3 — `neuron_audit.py:45-46` `--all` can't see any `L:*-required` flag (latent fail-open).** `_lint()`
  passes `state={}`, so lint rules' `_is_required` resolves the flag from a RELATIVE `workspace/memory/
  longterm/<flag>.md` (wrong cwd) → the standing gate stays WARN even when a flag is set → under-enforces.
  (Same root as the crucible R_MEMORY_RESPECTED workspace_path fix.) **Fix:** `state={"workspace_path":
  default_workspace()}`. (`lint_summary.py` shares the gap but only digests, never gates — lower priority.)
- **M4 — `rules_loader.py:171` `dead_after_days` is a no-op.** The cutoff is computed then discarded (bare
  expression); "dead" is decided purely on log-absence while the message claims a 90d threshold. Dormant
  (0 rules today). **Fix:** compare a per-rule timestamp to the cutoff, or drop the misleading text.
- **P2 — `events list` is not a subcommand → `log`.** `stats.md:67`, `code-dev-events-emit.md:70` (+ the
  latter's HELP advertises a `list` subverb the tool lacks). events.py = emit/listen/log/clear/hook-*.
- **P3 — `context report` → `status`.** `gain.md:36`, `discover.md:26` (context.py has no `report`).
- **P4 — `memory retrieve` → `get --scope`.** `gain.md:26` (memory.py = get/set/append/list/clear/rollback/
  history, `--scope` required); failure masked as "no history" by the next guard.
- **P5 — mode-router dead `EXEC`.** `mode-router.md:58 EXEC(new-chat)`, `:107 EXEC(plan-new)` — neither
  program exists/registers → dead dispatch in chat-no-active + plan modes (also surfaced in mode-suggest.md,
  chat-input.md, resume.md). **Fix:** create the programs or repoint to the real targets.
- **K1 — OUTPUT-LAYER inf-mode default 5 ≠ gate's 3.** `axon/OUTPUT-LAYER.md:23` `RETRIEVE(L:inference-mode)
  | 5`, but the gate + `boot.py:read_pref_inference` default **3**, and `L:inference-mode.md` is absent → the
  footer shows `inf:5(balanced)` while the gate enforces 3. (3 AXON-DOCS files also wrongly say 5.) The output
  layer's job is surfacing TRUE state. **Fix:** `| 3` (+ ideally persist `L:inference-mode` at boot). *axon/.*
- **K2 — R_REASONING_TRACE accepts a STALE trace.** `W:reasoning-trace` is LLM-written; the rule checks only
  existence + non-empty + ≥1 LANG token, no freshness — a leftover trace from a prior session passes every
  later turn (contrast drift.py's TTL + fail-closed). Latent (WARN until the flag is set). **Fix:** stamp the
  trace per-turn (the hook knows the turn); treat older-than-this-turn as absent (fail-closed).
- **K3 — orphaned `W:active-phase` never expires.** Current `active-phase.md` holds a FINISHED campaign
  (`axon-workflow-discipline:3-pr`, never `:done`); `session_save.py:104` doesn't exclude it → survives boots;
  nothing ages it out → arms the interrupt-gate + (with `state-surfaced-required=true`, which IS set)
  R_STATE_SURFACED indefinitely for a program that no longer runs. **Fix:** boot-time staleness check /
  auto-clear, or exclude `active-phase` from the cross-session snapshot.

### LOW
- **K-L1 — `boot.py:324` reads `output-config`, nothing writes it** (writer uses `output-mode`; OUTPUT.md
  self-contradicts l.88 vs l.99) → `boot-result.output_mode` always falls to the PYTHON_FAST default.
- **M5 — ✅ FIXED (SP-1, !127):** `lint_commit_trailer.py --range` skipped an unreadable body (fail-open).
- **M2 — ✅ FIXED (SP-1, !127):** `lint_commit_trailer.py` prefix-exempted `Co-authored-by: AXON via <brand>`
  (the commit brand-gate fail-open) → now exact-match the canonical trailer.

## Swept CLEAN (read + executed; no grounded bug)
verify.py · _longterm · _axon_paths · _axon_registry · _axon_io · aegis_policy · dispatch · session · plan_dag
· workflow_dag/run · accountability · agent_todo/memory · intent_queue · queue_tool · diff_tool · memory.py ·
usage.py · prompt_log.py · dispatch_stats · session_save · r9_axon_write · the crucible GATE rule-wiring (all
9 "crucible" manifest rules match what run_changeset calls; every program_text/output_text rule is mapped to
a runner that passes that field — NO declared-but-inert rule) · REGISTRY.json↔CONTEXT.md (151 = 139+12,
all script files resolve, no drift).

## Refuted (looked like a bug, isn't)
drift-trace bare path (internally consistent r+w) · _longterm first-line `value:` parse (by-design
anti-hijack) · _axon_io/enforce dev-mode (unified, fail-closed) · R_DRIFT_GATE absent-trace (fail-closed).

## Conclusion — study sufficient → PLAN
The study is a completed adversarial sweep: grounded, reproduced, with refuted + swept-clean controls. It is
sufficient to plan from — no further study needed. The fix set is well-bounded (2 HIGH, ~8 MED, ~3 LOW; 2
already merged). Proceed to PLAN: group by blast-radius + dev-mode requirement, smallest-risk first, the
two HIGH (H1, P1) each as its own carefully-tested PR.
