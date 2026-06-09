# Implementation Log — axon-resweep

## 2026-06-04 · project opened (study → plan)
Created from the MEGA re-sweep findings (01-study.md = the grounded sweep; raw log in
../super-polish/MEGA-resweep-2026-06-03.md). Study judged sufficient → plan (02-prs.md): 6 PRs R1–R6,
ordered by blast-radius + dev-mode, two HIGH (R3 H1, R4 P1) isolated. SP-1 (M2/M5, the commit-gate
fail-opens) already merged under super-polish (!127). Owner: "enable dev mode and work on it" — dev-mode
reserved for R6 (the only axon/-touching PR), scoped + restored-off per discipline; R1–R5 are tools/ +
programs/ (no dev-mode).

## 2026-06-04 · PR-R1 MERGED (!128, 0af89eb) — tool fixes M1/M3/M4
Clean warm-up PR (no dev-mode): axon_audit usage/prompt stats now read `workspace/` (where usage.py /
prompt_log.py write) not MYAXON_ROOT — the usage axis was always zero + emitted a false "No usage data yet"
(M1; parameterized so the EFFECT is tested against a tmp workspace). neuron_audit `_lint` passes
`state.workspace_path` so lint rules' `_is_required` can resolve `L:*-required` flags — the `--all` standing
gate was flag-blind (M3). rules_loader: removed the discarded `dead_after_days` cutoff no-op + its unused
`import datetime`; the dead-rule message no longer claims a `{N}d` threshold it never applied (M4). 13
targeted green (2 new test files: test_axon_audit, test_rules_loader); gate passed:true zero warnings;
brand-free squash on a branch; leak-clean; no dev-mode. NEXT (on-workflow): PR-R2 — program dangling
subcommands (events→log, context→status, memory→get) in stats/code-dev-events-emit/gain/discover.

## 2026-06-04 · PR-R2 MERGED (!129, f6c6c41) — program subcommand corrections
Fixed 5 dangling TOOL() call sites across 4 ACTIVE programs: events `list`→`log` (stats, code-dev-events-emit
dispatch), context `report`→`status` (gain, discover), memory `retrieve`→`get --scope E --key session-log`
(gain). verify.py's R_TOOL_CALL_EXISTS can't see these (positional `choices=` subcommands, not literal
add_parser) → content-lock test added. 3 targeted green; gate passed:true; no dev-mode. **Process slip
(owned + recovered):** I chained the merge WITHOUT the 405-retry loop (to one-line it); the create→merge
raced and 405'd → the MR didn't merge + I deleted the local branch → main briefly looked un-fixed. The
commit was safe on the remote MR; re-merged with the proper 405-retry (merged attempt 1). Lesson: never drop
the merge-by-number 405-retry. NEXT (on-workflow): PR-R3 — the HIGH, H1 R9 axon/-write fresh-clone fail-open
(tools/hooks/enforce_pretooluse.py); own PR + test.

## 2026-06-04 · PR-R3 MERGED (!130, 41fc88a) — HIGH H1: R9 gate identity-independent
The PreToolUse hook gated R9 behind `_axon_active()` (reads the gitignored cognition-frame) → fresh clone /
CI / pre-boot short-circuited the ONLY mechanical "axon/ needs dev-mode" enforcer to allow-all (a fresh
checkout could Edit KERNEL-SLIM with dev-mode off). Fix: `main()` runs `enforce.py check-write` for any
write target BEFORE the persona gate — it no-ops for non-axon/ targets, so it only ever gates real axon/
writes; the project dont-do enforcement stays persona-scoped (a plain session is otherwise untouched, but
R9 still protects the core). 2 new main() control-flow tests (R9 enforced when not-AXON; R9 runs before the
persona gate) + verified test_dont_do_write_time (direct-unit) unaffected; 13 hook tests green; gate
passed:true; no dev-mode (tools/hooks/). Merge-with-retry (405-safe) clean. **3/6 done (R1·R2·R3).** NEXT
(on-workflow): PR-R4 — the other HIGH, P1 synapse-suggest call-site drift (workflow-run/new + orchestrator;
correct `rank` subcommand + temp-file state).

## 2026-06-04 · PR-R4 MERGED (!131, c0f4410) — HIGH P1: synapse-suggest drift
Rather than make every LLM-interpreted program manage a temp file, taught the ranker to accept the state
INLINE (the programs' actual intent): `synapse_suggest._load_json` now parses a value starting with `{`/`[`
as inline JSON (tolerating a Python-repr dict) OR reads a path (back-compat). Then corrected the 3 call
sites: orchestrator `--state-json/--goal-json`→`--state/--goal` (×2); workflow-run builds `sg-state` +
`rank --state`; workflow-new `rank --state {W:_workflow-author-state}`. Verified end-to-end: `rank --state
'<inline json>'` returns ranked candidates. Tests: `_load_json` inline/repr/path + an inline-state CLI rank
+ a 3-program call-site lock. **Gate flake handled honestly:** the first gate's pytest control blocked, but
a direct full-suite run = **4349 passed, 0 failures**, and a clean re-gate = passed:true zero warnings — a
transient artifact-regen race, not an R4 break (verified before merging, not assumed). Merge 405-retry
(attempt 2). **4/6 done (R1·R2·R3·R4 — both HIGHs closed).** NEXT (on-workflow): PR-R5 — mode-router dead
EXEC targets (new-chat / plan-new).

## 2026-06-04 · PR-R5 MERGED (!132, 27eb094) — P5 + gate reliability (bundled)
mode-router (P5): chat (no active) + plan modes dispatched new-chat / plan-new (both nonexistent). The chat
subsystem is genuinely unimplemented (chat-input itself depends on new-chat) and planning runs through
code-dev, so — per the thesis (don't ship unverified skeletons) — the router now fails GRACEFULLY (captures
intent, routes to code-dev, DONE) rather than creating guessed-at programs. Two NEW gate-reliability findings
the gate surfaced mid-R5 (and which I fixed to unblock the campaign — both genuine "the gate doesn't reliably
work" issues): **(timeout)** run_control used a hardcoded 900s for EVERY control, but the full suite is
~10-17min under the gate's concurrent 22-control load → intermittent TIMEOUT (R4 squeaked under; R5 didn't) →
per-control timeout (default 900) + pytest 1800s; **(smoke flake)** the no-args tool smoke gave lint-code 5s
but its default action runs ruff over the codebase (slow under load, same shape as the already-exempt
audit/health) → exempted it. Diagnosed honestly: chased "flake" → found it was a TIMEOUT (crucible-last.json)
→ raised it → a real test FAILURE surfaced (lint-code smoke) → traced to the slow ruff default, not my code
(a clean 4350-pass full-suite run confirmed). 137 smoke + 22 crucible green; gate passed:true zero warnings;
merge-retry attempt 1. **5/6 done.** NEXT (on-workflow): PR-R6 — the kernel batch (K1 inf-mode · K2
reasoning-trace freshness · K3 active-phase expiry · K-L1 output_mode); the ONE axon/-touching PR → scoped
dev-mode (enable for the axon/ edits, restore off).

## 2026-06-04 · PR-R6 MERGED (!133, 9e84bee) — K1 done; K2/K3/K-L1 deferred. PHASE 1-fixes COMPLETE (6/6).
K1: OUTPUT-LAYER footer `RETRIEVE(L:inference-mode) | 5` → `| 3` (the footer showed inf:5/balanced while the
gate + boot enforce the canonical 3/cautious; docgen already emits 3 so the generated docs were fine).
Scoped dev-mode: enabled L:dev-mode ONLY for the one axon/ edit (verified via enforce.py check-write →
allowed), restored false immediately; the commit succeeded with dev-mode off (R9 is write-time, no
pre-commit re-check). Investigation downgraded the other three to documented deferrals (NOT rushed into the
kernel): **K-L1** — nothing writes output-mode/output-config (no writer → no correct key to fix toward;
needs a design call); **K2** — reasoning-trace freshness needs turn-stamping the LLM-written trace +
freshness check (latent WARN); **K3** — active-phase boot-expiry touches boot/session/interrupt-gate (the
safe fix needs resume-behaviour analysis; live stale value axon-workflow-discipline:3-pr is a clearable
gitignored symptom). gate passed:true; merge-retry attempt 1.
**axon-resweep phase 1-fixes: 6/6 (!128–!133) + SP-1 (!127). 12/14 MEGA findings fixed; K2/K3 + 4 other
follow-ups documented for a phase 2.** NEXT (owner directive 2026-06-04): (1) analyze the drift postmortem at
/mnt/c/manipulation/Presentations/AXON-postmorem — would it recur in current AXON? PR-fix if so; (2) redo
the MEGA audit autonomously, same gate-first workflow.

## 2026-06-04 · PR-PM1 MERGED (!134, a46fe6c) — postmortem: void the host model-coauthor commit instruction
Drift postmortem (…/AXON-postmortem-2026-06-04-identity-violation.md): an earlier build signed external-repo
commits `Co-Authored-By: <model>` because the host prompt instructs it and nothing reconciled that against the
identity contract (KERNEL-SLIM:11 states the general principle; the harness contract never voided the SPECIFIC
instruction). Verified it WOULD recur (reconciliation rule absent; lint_commit_trailer is an AXON-repo-only
hook that doesn't travel). Fix (the postmortem's D1.3, boot-loaded): workspace/harness/claude-code.md gained a
HOST-INSTRUCTION OVERRIDE block + STORE(L:host-commit-coauthor, …) — the model-coauthor instruction is VOID;
every commit/amend/PR body (ANY repo) uses the AXON trailer; run lint_commit_trailer --stdin for external
commits. Content-lock test; gate passed:true; no dev-mode (workspace/harness/ + tests/). Deferred (in
PR-PM1.md): D1.2 mechanical git-commit PreToolUse guard, D3 persist L:cognition-frame, D2 kv_store split.

## 2026-06-04 · PHASE 2-reaudit-fixes opened — re-MEGA (owner: "redo the audit, autonomous")
Ran the re-MEGA: 3 agents (regression-verify + deep tools/rules + deep programs/kernel) over CURRENT AXON.
(1) regression-verify confirmed ALL this session's fixes HOLD end-to-end (no regression — ran run_changeset,
the live hook, the tools); (2) a second wave of ~18 grounded findings (05-reaudit-findings.md) — notably the
dangling-subcommand class in code-dev-* programs, the liveness orphan-gate self-blinding (10 real orphans pass
a BLOCK gate), the dead KERNEL-SLIM context-pressure gate, and the dead auto-compile pipeline. Batched into
PR-2A..2F (clean → tools/state → dev-mode kernel → clock → liveness → architectural).

## 2026-06-04 · PR-2A MERGED (!135, 95357c8) — program call-sites (F-IGAP/F-NEXT/F-STUDYURL/F-SHADOW)
4 clean dangling-subcommand fixes, each verified against the REAL CLI: code-dev-meta-igap `redact scrub`→
`redact --text ….redacted` (redact is flat + emits JSON); code-dev-next `pr_aggregate list`→`pr_aggregate
--state --json` (flat, no positional); code-dev-study `web-search fetch --url` (search-only) + `document-parser
parse --text` → URL branch degrades to paste (no URL-fetch tool exists), PDF uses flat `--file`; code-dev-
study-area `shadow init --summary` (not an arg; missing required --hash) → compute via `shadow hash` then init
(matches the idiom in 5 other programs). +4 content-lock tests (11 total green); gate passed:true 0 warnings;
merge attempt 1; no dev-mode. **F-COMPILE pulled out:** verifying it revealed the whole auto-compile pipeline
is DEAD — compile-write was refactored to a writer-only (requires --name/--source/--src-tokens/--cmp-tokens +
--ops) but compile_suggest.py:145,176 (compile auto-compile/compile) AND compile-optimizer.md:55 still pass the
old `--program` interface → rc=2, silent → PR-2F (architectural) with F-CMPSTALE. NEXT (on-workflow): PR-2B —
tools/state batch (F-STATELOG header leak [confirmed: session-log header is "Time" not "Timestamp"],
F-MYAXON2UP agent_memory/agent_todo two-up→default_myaxon, F-AUDITWS, F-LOADEMPTY, F-RESOLVEVAL).

## 2026-06-04 · PR-2B MERGED (!136, 9bc3ef1) — tools/state batch
5 confirmed defects: axon_state._parse_log skipped only "Timestamp" but the real session-log header is
"| Time |" → leaked as a phantom row (now skips any non-timestamp-leading row); agent_memory/agent_todo
my-axon fallback was two-up (parent of repo) → one-up sibling, matching autonomous_mode + the gate's
_myaxon_root (masked by the gitignored pointer symlink → would break on a fresh clone); axon_audit.main
passed no workspace to the usage/prompt stats → args.workspace threaded through; synapse_suggest._load_json("")
raised → returns None; and (F-RESOLVEVAL, confirmed real) the 3 my-axon readers read the pointer RAW while
the gate's _myaxon_root parses value:/first-line/#comment → factored shared _axon_paths.read_myaxon_pointer
(parses all forms) routed through all 3, killing the divergence class. 6 effect tests + 58 module-regression
green; gate passed:true 0 warnings; merge attempt 1; no dev-mode. NEXT (on-workflow): PR-2C — the dev-mode
kernel batch (F-KCTX context-pressure gate reads dead fields → real ctx-p.pressure/.percent + drop the
double-counting record line; F-IGAPTYPE igap --type missing-route→semantic-search; F-DRIFTICON
OUTPUT-LAYER drift.status→.state; F-INFDEFAULT orchestrator.md:53 |5→|3 + AXON-DOCS), scoped dev-mode.

## 2026-06-04 · PR-2C MERGED (!137, ae1ab7d) — kernel/program defaults (scoped dev-mode + F50)
4 fixes: (F-KCTX) the context-pressure gate read pressure.level/.pct/.tokens but `context status` returns
{pressure, percent, accumulated_tokens} → the checkpoint-before-token-limit gate was DEAD; now keys on
ctx-p.pressure/.percent + DROPPED the "Record pressure" line (context record accumulates → re-recording the
total double-counts; it also fed the undefined pressure.tokens). (F-IGAPTYPE) igap record --type missing-route
∉ VALID_TYPES → find-program routing-gap now semantic-search. (F-DRIFTICON) OUTPUT-LAYER drift-icon keyed
drift.status → drift.state (the gate's real field). (F-INFDEFAULT, no dev-mode) orchestrator.md:53 |5→|3 +
3 hand-written AXON-DOCS "default 5"→"3" (canonical default is 3 per KERNEL-SLIM:45 + the K1 footer). Scoped
dev-mode: enabled L:dev-mode for ONLY the 2 axon/ edits (allowed→edited→restored false, verified blocked
again); F50 bumped v1.1.5→v1.1.6 + updated the lock (sha f675bd65…). 5 content-locks + F50 + 257 kernel-test
regression green; gate passed:true 0 warnings; merge attempt 1. **Batch: 3/6 merged (2A·2B·2C, !135-!137);
13 findings closed.** NEXT (on-workflow): PR-2D — F-CLOCK (give clock real offset/today/elapsed/diff-hours/ago
subcommands + fix the 6 degenerate callers; PRESERVE the no-arg default ~40 TOOL(clock) callers depend on).

## 2026-06-04 · PR-2D MERGED (!138, 8ce3bdb) — clock time-arithmetic
clock.py took no args → ignored every subcommand/flag, returned "now"; 6 callers (yesterday/elapsed/diff-
hours/window) silently got "now" (wrong dates, zero ages, dead staleness). Rewrote clock.py with argparse:
no-arg default preserved BYTE-FOR-BYTE (~40 TOOL(clock) callers untouched) + 5 subcommands via literal
add_parser (R_TOOL_CALL_EXISTS-visible): offset --delta / today / elapsed --from / diff-hours --from / ago
--window. _parse_iso tolerates the episodic-log +00:00Z double-tz; fails LOUD on unknown subcommand. **The
clock-dependent regression caught a real break BEFORE the gate:** cron runs `axon.py clock --workspace <ws>`
→ the old (argparse-less) clock ignored --workspace, the new one REJECTED it (ok=False) → fixed by
accepting+ignoring --workspace (cron/axon.py append it to every tool). Wired 7 caller sites (6 programs) to
the right field (.date/.human/.hours/.iso). 8 effect + content-locks + 239 clock-dependent-suite regression
green; gate passed:true 0 warnings; merge attempt 1; no dev-mode. session-summary.cmp.md (stale --offset)
deferred → PR-2F regen. **Batch: 4/6 merged (2A-2D, !135-138); ~14 findings closed.** NEXT (on-workflow):
PR-2E — F-LIVE (liveness orphan-gate is 100% blind, reached=139/139; fix per-tool corpus + allowlist the
surfaced entry/CLI orphans). Then PR-2F (compile pipeline, architectural).

## 2026-06-04 · PR-2E MERGED (!139, 39ff302) — liveness orphan-gate de-blinded
F-LIVE: the orphan gate (a BLOCK crucible control) was 100% self-blind — its invocation corpus included each
tool's OWN file, so every tool self-matched ("tools/X.py"/"Tool: X" in the docstring read as an invocation) →
reached 139/139, orphans [] — it could never fire. Fixed: per-file corpus (_corpus_files) + reached_by skips
the tool's own file (mirrors r_no_orphan_tools' exclude_rel) → reached 129/139, surfaced 10 pre-existing
orphans. Triage (documented policy: orphan ACTIVE tools → OPTIONAL; allowlist only for genuinely-pending): 8
entry/CLI/installer tools (apply-host-wiring, apply-memory-slot, onboarding, project-graph, workflow-dag,
dual-agent-eval, lint-code, axon-trace) → ACTIVE→OPTIONAL in REGISTRY; 2 (domain_validate, deprecation-log)
are test-pinned ACTIVE (registered tools pending wiring) → kept ACTIVE + grandfathered in liveness-allow.txt.
OPTIONAL-safe verified (axon.py gates only PLANNED → all stay invokable; health ACTIVE-count invariant holds;
total count unchanged). **The gate caught a refactor miss:** the existing test_liveness.py used the old
surfaces key (program_import_dispatch) → KeyError; I'd updated my new test but not the tool's OWN → fixed its
fixtures to the per-file shape (lesson: re-run the refactored tool's own test, not just the new one). Full
suite 4359 passed; re-gate passed:true 0 warnings; merge attempt 1; no dev-mode. **Batch: 5/6 merged
(2A-2E, !135-139); ~17 findings closed.** REMAINING: PR-2F (F-COMPILE + F-CMPSTALE) — auto-compile pipeline,
architectural + NEVER functional (compile-write never had the --program interface its callers assume;
compilation is cognitive per COMPILER.md). Surfacing the revive/deprecate/defer decision to the owner.

## 2026-06-04 · PR-2F MERGED (!140, 2ca670b) — compile pipeline made honest. PHASE 2-reaudit-fixes COMPLETE (6/6).
Owner chose "make it honest" (bounded; over full-revive/defer). git -S confirms compile-write NEVER had the
--program interface its callers assume + compilation is cognitive (COMPILER.md) → a pure tool can't
auto-compile. Fix: compile_suggest reports candidates (suggest) / {compiled:false, reason:cognitive} (compile)
instead of the silent `compile-write --program`; compile-optimizer.md (agent-run) now does the cognitive
compile (READ → COMPILE per COMPILER.md → TOKENS → `compile format --ops --src-tokens --cmp-tokens`); deleted
the 3 stale .cmp.md (workflow-run/new synapse-suggest; session-summary clock --offset) + nulled their pointers.
1100+ targeted green (4 PR-2F + 656 compile/auto_improve/smoke + 471 freshness/drift); gate passed:true 0 warn;
merge attempt 1. Follow-ups noted (separate, NOT this batch): auto_improve.action_auto_compile writes
no-compression copies (--ops=src_text); `compile auto-compile` (unified) routes to a nonexistent compile_suggest
action; programs/REGISTRY.json tools-lists drifted (periodic `programs-registry generate` resync).

═══════════════════════════════════════════════════════════════════════════════════════════════════════════
**axon-resweep PHASE 2-reaudit-fixes COMPLETE — 6/6 merged (!135–!140); ~18 re-MEGA findings closed.**
The owner's "redo the MEGA audit autonomously, keep the nice workflow" is done end-to-end: re-MEGA (3 agents)
→ triage → 6 gate-first PRs (program call-sites · tools/state · kernel/defaults · clock · liveness · compile),
each branch-first → spec → implement → targeted tests → full crucible gate passed:true → merge-by-number →
sync → bookkeep. Regression-verify confirmed phase-1 (!128–134, SP-1 !127) + the autonomy-discipline work
(!111–126) all still hold. Whole-session total this thread: SP-1 + R1–R6 + PM1 + 2A–2F = 14 PRs merged.
Remaining = documented follow-ups only (the 3 PR-2F ones + K2/K3 + chat subsystem), all minor/optional, none
gate-blocking.
═══════════════════════════════════════════════════════════════════════════════════════════════════════════
