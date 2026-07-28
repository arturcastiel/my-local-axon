# Implementation Log — AXON Bug-Free 3

## SESSION START — 2026-07-13T09:53:19+02:00
project:        axonbugfree3
phase:          study
workflow-step:  build
branch:         feat/codemap-family

## Entries

### 2026-07-13T09:55:48+02:00 — study phase: hunt launched
- Project scaffolded (v4, parent: axon-improvements, umbrella masterplan row updated).
- 4 parallel read-only sweeps dispatched:
  A) program-layer diff audit (post-07-07 markdown surfaces + codemap/graphify/obsidian families)
  B) Python-tools diff audit (doctrine/obedience spine, axon_state snapshot, crucible, phase_model)
  C) live boot-anomaly root-cause (prompt-log split-brain · drift-unknown ↔ auto-improve breaker ·
     axon-state get empty · pointer sweep test-record-stale)
  D) never-audited surfaces (hr-team, workflow-runner+schema, anticipate/orchestrator/synapse chain,
     agent_memory, handoff/chats/plan, REGISTRY integrity)
- Dedupe baseline: bugfix01+bugfix02 AUDIT-FINDINGS (all fixed 2026-07-07).
- Next: adversarial reconfirmation of every candidate → AUDIT-FINDINGS.md ledger + 01-study.md.

### 2026-07-13T13:24:20+02:00 — study phase COMPLETE
- 4 sweeps returned (A: 15 · B: 6 · C: 4 verdicts + 10 collateral · D: 15 + below-cap; D self-re-verified).
- Main-loop reconfirmation: F-H2, F-H3, zero-writer key class, F-H9, F-H10 — all confirmed at source/probe.
- Corrections applied from sweep-D final pass: F-H16 + F-M14 RETRACTED (kept in ledger, marked);
  F-C2 re-graded HIGH, mechanism corrected; F-M16/F-M17 promoted; 4 first-pass leads quarantined.
- Final tally: 1 CRIT · 19 HIGH · 16 MED · 9 LOW + ~8 below-cap + 4 leads. No fixes applied (study is read-only).
- Outputs: AUDIT-FINDINGS.md · phases/study/01-study.md · shadow/sweep-{A,B,C,D}*.md + sweep-D-final-reverified.md.

### 2026-07-13T13:38:37+02:00 — plan + pr phases COMPLETE · execution authorized
- Plan approved 10/10 (user) · 9/10 (AXON). 21 PRs / 6 waves + PR-000 triage. DAG.json 21 nodes verified.
- Owner decisions: grant RENEWED 72h (autonomous_mode renew, human-confirm yes, ts 2026-07-13T11:35Z) ·
  PR-000 triage-first · full gate per WAVE + final · merge feat/codemap-family → main first, then wave branches.
- 22 specs written (03-prs/PR-000..PR-021). Baseline crucible gate running (background).

### 2026-07-13T14:00:11+02:00 — PR-000 baseline triage COMPLETE (17 → 0 expected)
Root causes (2, not 17):
1. STALE COMPILED MIRROR — menu.cmp.md compiled 2026-07-10; menu.md gained 7 functional lines
   (codemap-family menu block, fc05324) after. Cascade: test_compile_write ×2 red →
   constraints 'lossless-mandate' (mechanical) FAIL → doctrine_preflight constraints check false →
   ALL 14 doctrine tests red (preflight validated:false / start refused). FIX: mirror surgically
   recompiled (7 lines inserted at their two source positions, header + TOC ranges refreshed).
   11/11 compile tests + constraints check GREEN → 14 doctrine tests GREEN.
   Ledger note: textbook instance of the incomplete-fix class — the codemap commit edited menu.md
   without recompiling; the lossless staleness test caught it exactly as designed, but nothing
   surfaced the constraint failure's BLAST RADIUS (14 unrelated-looking doctrine reds). Preflight's
   constraints check runs against the LIVE workspace even for tmp-fixture projects — noted as a
   candidate finding for run 4 (test-isolation seam).
2. DISPATCH RANKING REGRESSION — 9 new codemap programs diluted TF-IDF cosine; codemap-map
   (short desc, shared tokens) outranked axon-graph on its DECLARED phrase 'most connected
   modules'. FIX: exact-phrase authority bonus in tools/dispatch.py match (+1.0 on verbatim
   phrase-in-query hit, ≥4 chars) — the declaring program now wins its contracted intents.
   All 23 dispatch tests green + new pin test test_exact_phrase_hit_beats_bag_of_words_neighbors.
Also observed: tests append to the SHARED axon/state/loop-receipt.ledger.jsonl (4.4 MB, mtime
during suite) — isolation seam, run-4 candidate lead.
Full gate running for the codemap-merge push (per-wave cadence).

### 2026-07-13T14:32:17+02:00 — WAVE A IMPLEMENTED (6/6 PRs) · gate running
- 001 workflow dual-root resolve: new `workflow-runner resolve --name` CLI (both roots) + all 4
  program resolvers rewired; unknown name FAILs with the known-names list.
- 002 caller contracts: v.ok/error-count guards ×4 · simulate keys → W:_workflow-simulate-* ·
  check-stale/templating empty-envelope now surfaces as a WARN line (lint malfunction is loud).
- 003 codemap arg contract: router bridge (W:codemap-arg/-remainder/-repo from _arg2/raw-input/--repo);
  4 leaves off positional keys; shadow dispatch reachable (cmd from bridge, scan-path = repo);
  closeout stores the computed total.
- 004 envelope binds: meta.get → .value at 8 sites + found-gated codebase guard (code-dev-graphify);
  shell → .stdout at 6 sites (codemap-new/shadow); obsidian unchanged-path now carries notes/edges.
- 005 graphify impact: node_ids seeds (was always-[]), --symbol path, degraded no-seed envelope;
  codemap-relations renders the impact panel. Live probe: dispatch.py → 21 seeds / 12 impacted.
- 006 pattern.py read_pref strips inline comments; cluster/top/suggest run on shipped prefs.
- Tests: 93 green across the touched surfaces (15 workflow + 22 codemap + 24 graphify + 5 pattern +
  9 routing + rest). Mirror-blessed + freshness refreshed. Full gate in background.

### 2026-07-13T15:05:06+02:00 — WAVE B IMPLEMENTED (4/4 PRs) · gate running
- 007 phase-model 'why' read-only oracle; code-dev refusal loop no longer calls the done() mutator.
- 008 doctrine preflight fail-CLOSED: unblessed OR tampered → integrity.ok false → validated false;
  out-of-tree fixtures noted + runnable. Adversarial injected-routine test.
- 009 hr-team refusal pipeline: 8 selector refusals write {ok:false,refusal}; success sets ok:true;
  router clears pipeline keys at entry + GATES on selector.ok before convener; --protocol override
  is a plain unset-check (no QUERY-in-condition); reround latch cleared per run.
- 010 doctrine-node gate: current-node record timestamped; stale (>6h dead-run) record graced with
  a WARN instead of blocking; block message names 'clear-node' recovery. Deadlock broken.
- Tests: 32 new + 144 hr-team + 41 doctrine regressions green. Mirrors synced (code-dev.cmp).

### 2026-07-13T16:29:10+02:00 — WAVE C IMPLEMENTED (4/4 PRs) · gate running
- 011 drift alignment + DEADLOCK BREAKER: record accepts --type/--detail (kernel interface,
  auto-inits + refreshes trace); new 'refresh' subcommand repairs stale/missing trace; bare
  'init' defaults --no-program; check now AGREES with gate on staleness; boot wires
  refresh_drift_trace BEFORE tick_cron; remediation text made runnable (menu+mirror, stats,
  auto-improve). PROVEN: auto-improve --dry-run now runs (ok:true) — the boot-observed
  drift-unknown → breaker deadlock is broken; breaker re-enabled, 0 tripped.
- 012 suggestion calibration: anticipate footer floors every row + excludes current program
  and _-prefixed stubs (typing menu no longer suggests menu); orchestrator decide ladder +
  sideband recalibrated to the absolute score scale (~0.06-0.14); ranker signal readers
  tolerate real producer shapes (usage top list, context percent, pattern cluster list).
- 013 tick shape unified to {name,why,score} (menu reads .why); situate --turn bound (was
  unbound → argparse-failed the whole hint layer); recent-tools stored.
- 014 reporting batch: session-summary reads the workspace log tree first (F-H7); status
  queue renders t.program; simulate falls back to W:_arg1 + phantom OUTPUT dropped.
- Tests: 22 new + 124 in the suggestion/reporting band + 46 orchestrator/anticipate regressions green.

### 2026-07-13T17:12:56+02:00 — WAVE D IMPLEMENTED (4/4 PRs) · gate running
- 015 chat index reader==writer: index.py chat path resolves the my-axon store the chat
  programs write (was workspace/ → boot resume permanently blind); plan-append returns
  {appended:false,reason} instead of false success.
- 016 episodic store: memory-compact + show-memory read workspace/memory/episodic/ (the
  tree E: writers target; my-axon held only stale test files); archive path unified.
- 017 agent-memory cross-tier: list/recall tier=None routes through _all_entries — project
  + program tiers now surface (live: 22 entries incl. project, was 18 general-only + labeled 'all').
- 018 routing/guards: workspace-backup subcommand ← W:_arg1 (skip/push/status reachable);
  my-axon-init guards a live MYAXON.md (AFTER-MYAXON label; never clobbers user edits);
  resume checks program-exists before EXEC; pointer sweep accepts project-keyed active-phase
  (kills the false unknown-program that suppressed the resume offer this session).
- Tests: 9 new + 43 agent_memory/self_care/resume regressions green.

### 2026-07-13T17:29:52+02:00 — WAVE E IMPLEMENTED (2 PRs, revised) · gate running
- 020 integrity cleanup: registry memory verbs corrected (get/set/append/list/clear/rollback/history);
  axon_state plans active-match whitespace-tolerant; dispatch_index extras compare against DISPATCHABLE
  set (stale STUB now flagged); self-care advertised command → 'self-care check --heal' (menu + tool +
  compiled mirror); pointer sweep surfaces a RED test-record as test-record-red; stray untracked root
  memory/ tree archived to my-axon/generated + removed.
- 019 REVISED per verify-before-build + reduce-surface: the "zero-writer-key lint" ALREADY EXISTS as
  memory_key_lint (it caught W:raw-user-input in wave A) — NOT rebuilt. F-M4 (lint-path-vars kernel
  scope) is coupled to the F-H8 kernel fix (widening now would flag the still-present W:ws-path and block
  the gate) → FOLDED into the PR-021 kernel handoff. NEW ratchet built: tools/envelope_bind_lint.py — a
  narrow high-signal BLOCK control requiring every TOOL(meta, get) result to be .value/.found-unwrapped
  (the F-H6 class that recurred bugfix01 C12 → run3, 8 sites). Registered in crucible (39 controls now)
  + REGISTRY.json + 4 tests. Clean on the current tree.
- Tests: 10 new + 33 regressions green. Menu mirror synced.

### 2026-07-13T18:21:50+02:00 — WAVE F / PR-021 KERNEL FLOOR IMPLEMENTED (owner-gated) · gate running
- Owner explicitly gated the kernel-floor edits positive (dev-mode on, full edit, "as long as fully tested").
- Hunk 1 (F-H8): KERNEL-SLIM.md prompt-log band + context-pressure gate drop the phantom
  --workspace {W:ws-path} (no writer) → canonical default. PROVEN: prompt_log record without the
  flag returns recorded:true.
- Hunk 2 (F-H9): BOOT.md drift init → 'drift refresh' (stale-or-missing, matching the stated
  contract; the FILE-EXISTS guard fired once per trace lifetime). Belt-and-suspenders with boot.py.
- Hunk 3 (BOOT:196): anticipate input → W:raw-user-input (W:recent-input/W:last-summary have no writers).
- Hunk 4 (F-M2): OUTPUT-LAYER drift-reset advice → 'drift refresh' (reset DELETES the trace).
- Hunk 5 (plan-new): goal captured into goal-text BEFORE CLEAR; output renders {goal-text}.
- Hunk 6 (F-M4): lint_path_vars scans kernel top-level .md (core/compiler spec docs excluded);
  the widening SURFACED 2 more pre-existing phantoms (W:ws-name, W:ws-log) — baselined + ledgered as
  run-4 items NEW-1/NEW-2 (grandfathered, not suppressed; the lint works).
- Tests: 11 PR-021 pins + 47 boot/lint/manifest regressions green. Kernel writes gated by dev-mode +
  explicit owner sign-off (Core Rule 10 satisfied).

### 2026-07-13T18:58:54+02:00 — AUDIT phase COMPLETE
- All 22 PRs merged (7 MRs !199-!205); every wave full-gated. Kernel v1.1.11.
- Live reconciliation on main: 11 representative fixes spot-verified (workflow resolve, impact query,
  drift deadlock broken, prompt-log records, pattern.py, hr-team, chat-index, agent-memory tiers,
  envelope-bind lint). Every ranked finding fixed-or-retracted.
- 2 prevention ratchets added (envelope-bind lint; lint_path_vars kernel scope). memory_key_lint
  already covered the zero-writer class (not rebuilt).
- Residual carried forward honestly: NEW-1/2 (ws-name/ws-log phantoms, baselined) + 4 quarantined
  leads + workflow-new deferred. 05-audit.md written. Self-grade 9/10.
- Next: code-dev complete.
- 2026-07-13: COMPLETE (manifest-backed — all phases done; stamped via code-dev complete)
