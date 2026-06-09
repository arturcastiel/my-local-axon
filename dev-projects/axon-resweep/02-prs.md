# 02 — Plan / PR list: axon-resweep (phase 1-fixes)
Updated: 2026-06-04  ·  Source: 01-study.md  ·  Already done: SP-1 (M2+M5, !127, under super-polish)

Grouped by blast-radius + dev-mode requirement; each PR is independently gateable, smallest-risk first, the
two HIGH each isolated with its own test. On-workflow under axon-resweep; gate-first (parse passed
separately); the kernel/axon edits behind L:dev-mode (restore off after; F50 version-lock if KERNEL-SLIM).

## PR-R1 — Tool fixes: audit usage path · neuron-audit flag · rules_loader threshold (M1 · M3 · M4)
- **Status:** ✅ merged (!128, squash 0af89eb) — gate passed:true, zero warnings. axon_audit usage/prompt stats read workspace/ (M1, parameterized + EFFECT-tested); neuron_audit `_lint` passes workspace_path (M3); rules_loader no-op + unused datetime import removed, dead message honest (M4). 13 targeted green; 2 new test files.
- **Complexity:** S  ·  **dev-mode:** no (tools/ only)  ·  **Depends on:** none
- **Scope:** `tools/axon_audit.py` (read usage/prompt logs from `workspace/`, not `MYAXON_ROOT`) ·
  `tools/neuron_audit.py` (`_lint` passes `state={"workspace_path": default_workspace()}`) ·
  `tools/rules_loader.py` (use the `dead_after_days` cutoff, or drop the misleading message) · tests.
- **Why:** clean, isolated, low-risk warm-up; closes a false-metric (M1) + a latent standing-gate fail-open
  (M3) + a no-op (M4). Assert the EFFECT (real on-disk path read; flag honored).

## PR-R2 — Program dangling subcommands: events→log · context→status · memory→get (P2 · P3 · P4)
- **Status:** ✅ merged (!129, f6c6c41) — gate passed:true. 5 call sites in 4 programs corrected; content-lock test (R_TOOL_CALL_EXISTS is blind to choices=-subcommands). [Merge 405'd first — I'd dropped the retry loop; recovered with the proper merge-by-number 405-retry.]
- **Complexity:** S  ·  **dev-mode:** no (workspace/programs/)  ·  **Depends on:** none
- **Scope:** `stats.md` · `code-dev-events-emit.md` (events `list`→`log`, fix its HELP) · `gain.md` ·
  `discover.md` (context `report`→`status`; memory `retrieve`→`get --scope E`). Test: each corrected
  `TOOL(...)` call resolves against the real argparse surface (a smoke that the subcommand exists).
- **Why:** three ACTIVE dashboards/programs currently exit-2 at these steps; correct the call sites. Verify
  against the tool's real subcommands (incl. `choices=`, which R_TOOL_CALL_EXISTS can't see).

## PR-R3 — [HIGH] R9 axon/-write gate: enforce in a fresh clone / pre-boot (H1)
- **Status:** ✅ merged (!130, 41fc88a) — gate passed:true. `main()` runs R9 check-write for any target BEFORE the `_axon_active` persona gate (identity-independent; no-ops for non-axon targets); dont-do stays persona-scoped. 13 hook tests green (2 new main() control-flow tests); merge-with-retry clean.
- **Complexity:** M  ·  **dev-mode:** no (tools/hooks/)  ·  **Depends on:** none
- **Scope:** `tools/hooks/enforce_pretooluse.py` (`_axon_active`/the R9 path) — enforce R9 for `axon/`-targeted
  writes regardless of boot/persona (absent cognition-frame = "AXON repo, not yet booted, still protect the
  core"); keep the booted dev-mode path intact. Mirror the share in the Stop gate / dont-do guard if they
  short-circuit the same way. Test: a fresh-clone fixture (no cognition-frame) + an `axon/` Edit payload →
  BLOCKED with dev-mode off; ALLOWED with dev-mode on; non-`axon/` writes unaffected.
- **Why:** HIGH — the mechanical OS-core floor is currently inert pre-boot/CI (proven). Own PR + test.

## PR-R4 — [HIGH] synapse-suggest call-site drift (P1)
- **Status:** ✅ merged (!131, c0f4410) — gate passed:true. `_load_json` accepts inline JSON-or-path (the programs' intent); orchestrator `--state-json/--goal-json`→`--state/--goal`; workflow-run/new → `rank --state`. Inline-state rank verified end-to-end. [Gate's pytest flaked once (artifact-regen race); a clean full-suite run = 4349 passed + re-gate green confirmed no real break.]
- **Complexity:** M  ·  **dev-mode:** no (workspace/programs/)  ·  **Depends on:** none
- **Scope:** `workflow-run.md:172` · `workflow-new.md:96` · `orchestrator.md:84,116` — correct to
  `rank --state <FILE> [--goal <FILE>] --top N [--explain]`; write the state/goal to temp JSON files first
  (the ranker requires a file path, not an inline dict). Test: the corrected calls resolve + the file-path
  contract holds.
- **Why:** HIGH — the ranker is broken on the adaptive-workflow path AND the mainline orchestrator tick;
  invisible to verify.py. The most "registers-fine, skeleton-broken" finding.

## PR-R5 — mode-router dead EXEC targets (P5) + gate-reliability (bundled)
- **Status:** ✅ merged (!132, 27eb094) — gate passed:true. mode-router chat/plan modes fail gracefully (no `EXEC(new-chat)`/`EXEC(plan-new)`; route to code-dev) — P5. BUNDLED two gate-reliability fixes the gate itself surfaced: per-control timeout (pytest 900→1800s; the suite is ~10-17min under gate load + timed out intermittently) + exempt `lint-code` from the 5s no-args smoke (its default runs ruff over the codebase, slow under load, same as audit/health). Follow-ups logged: chat subsystem unimplemented; parallelize the suite (xdist).
- **Complexity:** M  ·  **dev-mode:** no (workspace/programs/)  ·  **Depends on:** none
- **Scope:** `mode-router.md:58 EXEC(new-chat)`, `:107 EXEC(plan-new)` — create the missing programs OR
  repoint to the real chat/plan entry programs + register; reconcile mode-suggest.md/chat-input.md/resume.md.
  Needs a small design decision (which real targets) — resolve in the PR.
- **Why:** dead dispatch in chat-no-active + plan modes.

## PR-R6 — Kernel batch: inference-mode footer default (K1) [+ K2/K3/K-L1 deferred]
- **Status:** ✅ merged (!133, 9e84bee) — gate passed:true. K1: OUTPUT-LAYER footer default 5→3 (matches the gate/boot canonical 3; docgen already emitted 3). dev-mode enabled ONLY for the axon/ edit + restored off (verified). **K-L1/K2/K3 DEFERRED** (documented in PR-R6.md): K-L1 (output_mode has no writer — needs a design call), K2 (reasoning-trace freshness — turn-stamping the LLM trace), K3 (active-phase boot-expiry — sensitive boot/session/interrupt-gate). **PHASE 1-fixes COMPLETE (6/6).**

## Phase-2 / follow-ups (documented, not done)
K2 (reasoning-trace freshness) · K3 (active-phase boot-expiry; live stale value: axon-workflow-discipline:3-pr) · K-L1 (output_mode persistence design) · chat subsystem (new-chat/open-chat/list-chats unimplemented) · parallelize the gate suite (xdist — it's ~10-17min serial) · teach R_TOOL_CALL_EXISTS to see `choices=`-based subcommands (would gate-catch the P1/P2/P5 drift class).
- **Complexity:** M  ·  **dev-mode:** YES for the axon/ edits (OUTPUT-LAYER.md; the 3 AXON-DOCS)  ·  **Depends on:** none
- **Scope:** `axon/OUTPUT-LAYER.md:23` `| 5`→`| 3` (+ the 3 AXON-DOCS) [dev-mode] · reasoning-trace
  per-turn stamp + freshness in the hook + `r_reasoning_trace` [tools/] · `session_save.py`/boot active-phase
  staleness-clear [tools/] · `boot.py` output_mode key reconcile [tools/]. Split if the dev-mode portion
  wants isolation. Tests for each.
- **Why:** state-surfacing correctness; K2/K3 are latent-but-real (K3 is live on this machine).

## Recommended sequence
R1 → R2 (clean, low-risk, build the on-workflow rhythm) → **R3 (HIGH, isolated)** → **R4 (HIGH, isolated)** →
R5 → R6 (dev-mode last). Re-sweep-confirm after R6 (a focused pass that the fixes hold + introduced nothing),
then close. (Slice 5's dormant-mechanism deep-dive can be a phase 2 if desired.)

## DAG
All six are independent (no inter-PR deps) — orderable purely by risk. SP-1 already merged.
