# MEGA re-sweep — 2026-06-03 (owner directive: "perform mega again")

A fresh super-polish adversarial sweep over CURRENT AXON (post the axon-autonomy-discipline work, !111–!126).

## Status: STARTED, fan-out blocked by session limit
- Launched the 5-agent adversarial fan-out (tools-correctness · rules+crucible · programs-actually-work ·
  kernel+state+memory · integration/claims-vs-reality). **All 5 hit the account session limit (resets
  21:20 Europe/Amsterdam) — returned 0 tokens, killed before producing findings.** Five heavy parallel
  deep-readers at once exceeded the one-shot budget.
- Fell back to an INLINE sweep (no subagents) over the two highest-value slices the thesis points at.

## Inline findings (grounded, verified by running the code)
1. **Gate / rule wiring — CLEAN.** Swept every changeset/static/runtime rule for the declared-but-inert /
   fail-open class (the R_MEMORY_RESPECTED bug class: a rule wired at BLOCK that reads a ctx field its
   runner never passes → silently never fires). Verified: the 9 manifest "crucible" rules EXACTLY match the
   9 `run_changeset` actually calls; every `program_text` rule is mapped to lint/audit/verify (which pass
   program_text via `verify_program`); every `output_text` rule → verify (`verify_output`); the two
   `?`-input rules (`r_reasoning_trace`, `r_w_budget`) read `ctx["state"]`, which `load_state()` populates
   with their fields. **No inert rule found anywhere.**
2. **Registry / docs — CLEAN.** REGISTRY.json = 151 entries; CONTEXT.md claims 151 (139 ACTIVE + 12
   OPTIONAL) — consistent. All 151 entries' `script` fields resolve to real files (incl. the name≠file
   cases: todo→agent_todo.py, queue→queue_tool.py, workflow-runner→workflow_run.py, rules→rules_loader.py,
   diff→diff_tool.py). No orphan / no drift.

## DEFERRED to the full fan-out (after the 21:20 reset)
The broad correctness sweep needs the parallel agents (too much for one inline pass):
- **tools-correctness** — fail-open / silent-no-op / parse bugs across the ~149 decision/parse tools.
- **programs-actually-work** — dangling TOOL()/subcommand refs, broken fail-closed control-flow, stale wiring.
- **kernel+state+memory** — state read/write mismatches, boot-order fail-open, gitignored-state-assumed-present.
- **integration / dormant-mechanism** — pieces that exist + test green in isolation but are never invoked in
  the real path (the autonomy-discipline had several; hunt the same shape elsewhere).
Resume: re-dispatch the 5 briefs (they're in the session transcript) after the limit resets; triage → fix
on-workflow under super-polish (load it, open a sweep phase, gate-first per PR).

## RESUMED 23:24 (past the 21:20 reset) — small batches (5-at-once was the burst that tripped it)

### Slice 1: tools-correctness — COMPLETE (5 grounded findings; broad swept-clean)
A solo probe agent ran clean (limit cleared). Findings (ranked; each with a repro the agent ran):
- **M1 [MED-HIGH] `axon_audit.py:402,417`** — `usage_log_stats`/`prompt_log_stats` read `MYAXON_ROOT/memory/...`
  but every WRITER + reader uses `workspace/memory/...` (usage.py, prompt_log.py, session_save, etc.) →
  always-zero → the audit's usage axis is pinned low + emits a false "No usage data yet" recommendation
  into the audit→improve loop. Fix: read from `workspace/` (mirror usage.py).
- **M2 [MED] `lint_commit_trailer.py:57`** — `_scan_body_leaks` exempts brand scanning when a line
  *startswith* `"Co-authored-by: AXON"` (PREFIX match), so `Co-authored-by: AXON via Claude Code <…>` is
  skipped AND `FORBIDDEN_COAUTHORS` misses it → the brand "Claude" leaks with zero violations. This is the
  exact body-brand-leak class the gate exists to catch. Fix: scrub only the EXACT canonical trailer, or
  brand-scan co-author lines after stripping the literal `AXON <axon@…>` token.
- **M3 [MED, latent] `neuron_audit.py:45-46`** — `_lint()` passes `state={}`, so lint rules' `_is_required`
  resolves the gate flag from a RELATIVE `workspace/memory/longterm/<flag>.md` (wrong cwd) → the `--all`
  standing gate can't see any `L:*-required` flag → under-enforces the moment one is set (same root as the
  crucible R_MEMORY_RESPECTED workspace_path fix). Fix: `state={"workspace_path": default_workspace()}`.
- **M4 [LOW-MED] `rules_loader.py:171`** — `dead_after_days` cutoff is computed then DISCARDED (bare
  expression); "dead" is decided purely on log-absence while the message claims a 90d threshold. Dormant
  (0 rules today). Fix: compare a per-rule timestamp to the cutoff, or drop the misleading threshold text.
- **M5 [LOW] `lint_commit_trailer.py:122-123`** — `--range` `continue`s (skips, unscanned) a commit whose
  body is unreadable → fail-open. Narrow. Fix: fail closed on a None body in-range.
- Swept CLEAN (read + executed): verify.py, _longterm, _axon_paths, _axon_registry, _axon_io, aegis_policy,
  dispatch, session, plan_dag, workflow_dag/run, accountability, agent_todo/memory, intent_queue, queue_tool,
  diff_tool. (`replay.py` does not exist in this tree.)
- NOTE: M2 (the commit brand-gate fail-open) is the highest-priority to fix — it's the gate guarding every
  commit message in this very campaign. M1 next (corrupts audit decision-support).

### Slice 2: programs-actually-work — COMPLETE (5 findings; verify.py R_TOOL_CALL_EXISTS is blind to these)
The agent cross-checked every `TOOL(name,sub,…)` against real argparse surfaces (incl. positional `choices=`,
which R_TOOL_CALL_EXISTS can't see) + ran the failing calls (exit 2). All pass `verify.py program` clean.
- **P1 [HIGH] synapse-suggest call-site drift** — 3 ACTIVE programs call the ranker with a stale API:
  `workflow-run.md:172` + `workflow-new.md:96` (no `rank` subcommand + `--context/--history/--top-k` that
  don't exist → exit 2 on every adaptive-workflow / synapse-build loop); `orchestrator.md:84,116` (uses
  `rank` but `--state-json/--goal-json` instead of `--state/--goal`, and passes an inline dict where a JSON
  FILE PATH is required → exit 2 on the mainline tick). Real CLI: `rank --state <file> [--goal <file>]
  [--top N] [--explain]`. Fix: correct subcommand+flags + write state/goal to temp files first.
- **P2 [MED] `events list` → `log`** — `stats.md:67`, `code-dev-events-emit.md:70` (events.py choices =
  emit/listen/log/clear/hook-*; the query verb is `log`). code-dev-events-emit's own HELP also advertises a
  `list` subverb the tool lacks (claims-vs-does).
- **P3 [MED] `context report` → `status`** — `gain.md:36`, `discover.md:26` (context.py has no `report`).
- **P4 [MED] `memory retrieve` → `get --scope`** — `gain.md:26` (memory.py = get/set/append/list/clear/
  rollback/history, `--scope` required); the failure is masked as "no history" by the next guard.
- **P5 [MED] mode-router dead EXEC** — `mode-router.md:58 EXEC(new-chat)`, `:107 EXEC(plan-new)` — neither
  program exists / is registered → dead dispatch in chat-no-active + plan modes. Fix: create or repoint.
- CLEAN: orchestrator non-synapse calls, workflow-run rest, code-dev*, pr-create/review/ready, memory-compact.

### Slice 3: kernel+state+memory — COMPLETE (1 HIGH, 3 MED, 1 LOW; strong refuted list)
- **H1 [HIGH] R9 axon/-write gate fails OPEN in a fresh clone/CI** — `tools/hooks/enforce_pretooluse.py:
  176-195` is the ONLY mechanical enforcer of "axon/ writes need dev-mode", but its `_axon_active()`
  (:163-173) returns False when `workspace/memory/longterm/cognition-frame.md` is absent — and that file is
  GITIGNORED + written only by an LLM boot STORE. So pre-boot / fresh clone, the hook `sys.exit(0)` → any
  Edit/Write to `axon/` (incl. KERNEL-SLIM) is allowed with dev-mode off. Agent PROVED it (removed the file
  → Edit-to-axon payload → exit 0 allowed; restored → exit 2 blocked). Same short-circuit weakens the Stop
  gate + write-time dont-do guard. Fix: R9 is identity-independent — enforce it for axon/-targeted writes
  regardless of boot/persona (treat absent frame as "AXON repo, not yet booted, still protect the core"), or
  arm via a TRACKED sentinel decoupled from the gitignored runtime key.
- **K1 [MED] OUTPUT-LAYER inf-mode default 5 ≠ gate's 3** — `axon/OUTPUT-LAYER.md:23` `| 5` but the gate +
  boot.py default 3; `L:inference-mode.md` absent → footer shows `inf:5(balanced)` while the gate enforces
  3. (axon/ → needs dev-mode to fix.)
- **K2 [MED] R_REASONING_TRACE accepts a STALE trace** — no freshness check; a leftover trace from a prior
  session passes every later turn (contrast drift.py's TTL). Latent (WARN until the flag is set). Fix: stamp
  the trace per-turn; treat older-than-this-turn as absent (fail-closed).
- **K3 [MED] orphaned `W:active-phase` never expires** — current `active-phase.md` holds a FINISHED campaign
  (`axon-workflow-discipline:3-pr`, never `:done`); session_save doesn't exclude it → survives boots; nothing
  ages it out → arms the interrupt-gate + (with state-surfaced-required=true, which IS set) R_STATE_SURFACED
  indefinitely for a program that no longer runs. Fix: boot-time staleness check / auto-clear; or exclude
  active-phase from the cross-session snapshot.
- **K-L1 [LOW] boot.py output_mode key mismatch** — reads `output-config`, nothing writes it (writer uses
  `output-mode`); OUTPUT.md self-contradicts (l.88 vs l.99). Always falls to PYTHON_FAST default.
- Refuted (NOT bugs): drift-trace bare path (internally consistent), _longterm first-line parse (by design),
  _axon_io/enforce dev-mode (now unified, fail-closed), R_DRIFT_GATE absent-trace (fail-closed).

## TRIAGE / FIX PLAN (on-workflow under super-polish; gate-first)
Confirmed, grounded findings: **2 HIGH (P1, H1) + ~8 MED + ~3 LOW.** Proposed fix PRs, prioritized:
- **SP-1** ✅ MERGED (!127, dab3565) — lint_commit_trailer fail-opens closed (M2 exact-trailer-match + M5
  range fail-closed); gate passed:true, 2 regression tests, brand-free squash (validated by the hardened gate).
- **SP-2** H1 — R9 hook fresh-clone fail-open (tools/hooks/, no dev-mode; delicate — own PR + test).
- **SP-3** tool metric/gate fixes: M1 axon_audit usage path · M3 neuron_audit workspace_path · M4 rules_loader.
- **SP-4** program dangling-refs: P2 events→log · P3 context→status · P4 memory→get (workspace/programs/, no dev-mode).
- **SP-5** P1 synapse-suggest call-site drift (workspace/programs/; involved — temp-file state).
- **SP-6** P5 mode-router missing programs (create/repoint).
- **SP-7** kernel/axon (dev-mode batch): K1 inf-mode · K2 reasoning-trace freshness · K3 active-phase expiry · K-L1 output_mode.
Slice 5 (integration/dormant-mechanism deep-dive) not separately run — registry + gate-wiring done inline (CLEAN); a dormant-mechanism sweep can be a later slice.
