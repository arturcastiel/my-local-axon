# Implementation Log — AXON Polish

## SESSION START — 2026-05-21T17:32:22Z
project:        axon-polish
phase:          1-audit
workflow-step:  build
branch:         main

## Entries

- 2026-05-21 17:32 · project scaffolded · v4 schema · codebase=/home/arturcastiel/projects/axon-development/axon
- 2026-05-21 17:37 · code-dev-study begin · 4 parallel auditors dispatched · 9 dimensions
- 2026-05-22 00:30 · ADR-005, ADR-006, ADR-007 ACCEPTED
  · ADR-005 split: 005a C-now (5 LOC step-count) + 005b A-later (registered builtins)
  · ADR-006 sequenced: Phase 1 C (PID-mismatch hook) → Phase 2 B (phase ledger enforcement)
  · ADR-007 C (light bridge): 2-line workflow-run + observe-only orchestrator guard
  · ADR-004 (phase-transition invariant gate) still PROPOSED — user not yet asked to accept/refine
  · All 3 chose smallest blast radius; reversible if misbehaves
- 2026-05-21 23:55 · ADR design sweep complete (most-conservative path)
  · 3 parallel deep-reads for ADR-005 (adaptive workflow), ADR-006 (resume contract), ADR-007 (workflow↔orch boundary)
  · 4 NEW findings surfaced during read:
       F-D4-017  goal.acceptance.met() is undefined in predicate.py BUILTINS — BLOCKER
                 (every workflow YAML uses it; empirically returns null; safe-null silently bypasses)
       F-D4-018  workflow-run calls predicate.eval with no --ctx — MAJOR
                 (hidden prerequisite: even state.steps > 25 never works)
       F-D9-022  tools/session.py:recover() is orphaned (no entrypoint) — MAJOR
                 (master PR-15 designed it; coded but never wired in)
       F-D9-023  processes/active/[P-NNN].md described in PROCESS.md but unused — MINOR
  · 3 ADRs PROPOSED (awaiting accept):
       ADR-005  Adaptive termination + goal-mutation     → C-now (5 LOC step-count guard) + A-later (registered builtins)
       ADR-006  Resume / compaction contract              → B + C combined (PID-mismatch hook + phase ledger enforcement)
       ADR-007  workflow-run ↔ orchestrator boundary      → C (light 2-line bridge; observe-only orchestrator call)
  · All 3 recommendations chosen for SMALLEST blast radius + minimal scope creep
- 2026-05-21 23:15 · Iteration 2 (Phase 2.5-verify) complete
  · 3 parallel agents + direct pytest/CI check
  · META finding: "dev v3.7.0" and "prod v1.1.4" are SAME CODE at HEAD 97c29c3
    — KERNEL banner v1.1.4 is kernel-spec axis, VERSION 3.7.0 is project axis (per DEVELOPER.md history)
    — F-D3-003 RETRACTED as "drift", REFRAMED as MINOR "ambiguous banner"
  · 2 NEW BLOCKERs surfaced from copilot-deviation-study + firing-dag-missing:
       F-D6-005a  Program-mutated files have no write-attribution sentinel
                  (ADR-001 alone does NOT close this; need P3 sentinel + hook)
       F-D6-005b  EXEC(program) silently degrades to prose simulation on harness
                  (routes to axon-copilot-anchor)
  · 2 new MAJOR findings: F-D4-016 (DAG-skip), MINOR F-D5-009 (drift-log schema)
  · 2 new demands: D-D8-021 (session-heartbeat), D-D8-022 (EXEC verification), D-D6-005a (sentinel)
  · ADR-004 PROPOSED: Phase-transition invariant gate (firing-dag-missing + copilot-deviation overlap)
  · 11 MAJOR runtime traces: 10 CONFIRMED + 1 PARTIAL; 91% reliability rate
       (BLOCKERs were only 66% reliable, so MAJORs are empirically more trustworthy)
  · F-D6-005 + F-D6-006 escalation candidates (both borderline-BLOCKER per agent B)
  · Pytest reconcile: 86 = file count, 3606 = collected tests (audit's "86" was files, not tests)
  · CI status: lint-paths + tests-full + coverage gate (tools/rules 100%, tools/ 80%) all enforced
- 2026-05-21 22:30 · Phase 2-prioritise scaffolded + ranked
  · 3 ADRs accepted: ADR-001 (sandboxed shell.py) · ADR-002 (fail_render.py + incremental) · ADR-003 (30-day hybrid deprecate)
  · 15 clusters drafted from reconciled findings; ranked by impact × (1/difficulty) × prior-work-bonus
  · Top-5 by score: C-12 enforce (9.0) · C-07 context-pressure (8.75) · C-02 fail_render (8.0) · C-01 shell (7.5) · C-05 adaptive (6.75)
  · 3 clusters routed out: C-10 → wiring-gaps · C-11 → cleanup · C-13 → ranker-v2
  · 16 PRs in top-5; ~30 PRs total estimated
  · 3 ADRs still needed for Phase 3 entry: ADR-004 (mainline composition) · ADR-005 (adaptive goal-mutation) · ADR-006 (resume contract)
- 2026-05-21 21:55 · verification + reconciliation pass complete
  · ~22 spot-checks against dev tree: ~92% of audit claims fully verified
  · 4 counts under-reported (TOOL(shell): 88→139, alias/DEPR: 18→42, quarantine: 118→154, programs: 33→61)
  · F-D5-001 partially wrong — 3 of 4 "dead" EXEC targets exist in axon/programs/ (kernel search path); BLOCKER → MINOR
  · 6 unverified BLOCKERs runtime-traced:
       F-D4-001  orchestrator fixed-mode  CONFIRMED but reframed (dead code, not crash)  BLOCKER → MAJOR
       F-D4-003  adaptive-free-text loop  CONFIRMED + WORSE (truly infinite, not 25-bounded)  BLOCKER
       F-D9-006  HALT pressure ceremony  PARTIAL (bounded ~80-150 tok, no overflow)  BLOCKER → MINOR
       F-D9-009  K/I/A interrupt race    REFUTED as infinite (resolves in 1 extra turn)  BLOCKER → MAJOR
       F-D9-011  G-02 turns 1-4         CONFIRMED multi-program impact  BLOCKER
       F-D7-007  enforce.py stubs        CONFIRMED + new sub-finding F-D7-007a (user: prefix bypass)  BLOCKER ↑
  · Net BLOCKER count: ~22 → ~20 (some shifted, F-D7-007a added)
  · _flaws.md annotated with `· RECONCILED 2026-05-21` and `· RUNTIME-TRACED 2026-05-21` markers
  · Ready for Phase 2-prioritise with reconciled severity profile
- 2026-05-21 21:30 · prior-work cross-reference complete · 14 projects surveyed
  · 6 demands retire (axon-tests already shipped: identity behavioral, R9 bypass, etc.)
  · 5 findings route to specialized projects (wiring-gaps, autoimprove, user)
  · 3 active conflicts surfaced: TOOL(shell) gate, FAIL canonical-pieces, catalog deprecate policy
  · Patterns adopted from 7 prior projects (PR spec templates, lifecycle, fixtures, personas)
  · Plan-readiness grade: A- → A+
  · Cross-ref file: _prior-work-crossref.md
- 2026-05-21 19:53 · code-dev-study complete · ~137 flaws + ~48 demands cataloged
  · Top BLOCKERS: PR-111 composition path broken (F-D4-001/002/011),
    TOOL(shell) gate evasion (F-D8-008), R9 bypass vectors (F-D8-001),
    inference-mode-lock unenforced (F-D8-002), identity gate dispatch unenforced (F-D8-003),
    no real resume across compaction (F-D9-002/003/004), context.py 128k hard-cap (F-D9-001),
    REGISTRY 118 unregistered (F-D5-002), menu/quickstart/help duplicated (F-D1-001/002/003),
    4 dead EXEC targets in production routing (F-D5-001)
  · Ready for Phase 2-prioritise: rank findings by impact × difficulty.

## SESSION RESUME — 2026-05-23T13:46:00Z
project:         axon-polish
phase:           2-prioritise
workflow-step:   ranked
branch:          main  (git: pr-health-101-tool-smoke  ⚠ drift)
shadow:          fresh:0 stale:0 branch-stale:0
reviewer:        no PR in review
prohibitions:    11 active (0 promoted)
- 2026-05-23 04:39 · PR-HEALTH-101 MERGED to main (#68 · commit 970fe72)
  · branch: pr-health-101-tool-smoke (ops track, not in phase-3 spec list)
  · payload: tool-invocation smoke test + pr_aggregate missing-dir crash fix
  · approved + merged by user between sessions
- 2026-05-23 14:11 · PR-PHASE5-002 DRAFTED (#69 · branch pr-phase5-002-blocker-closure-extend)
  · tests/test_phase5_extend.py — 6 BLOCKER-closure scenarios (P5-S9..S14)
  · Verified locally: pilot+extend = 14 passed, 2 skipped, no regression
  · Companion report: phases/5-validate/02-extend.md
  · Findings re-verified e2e: F-D7-007a, F-D4-003, F-D9-001, F-D6-005a, F-D4-017, F-D5-002
  · Heavy-workflow-ready: 95% → ~98% on merge
  · Status: AWAITING USER REVIEW + MERGE (handoff point reached)
- 2026-05-23 14:29 · PR-PHASE5-002 MERGED to main (#69 · commit fd9e9e9)
  · 6 BLOCKER-closure e2e scenarios green; all CI checks SUCCESS
  · heavy-workflow-ready: 95% → ~98%
  · Combined pilot+extend: 14 e2e scenarios covering every closed BLOCKER class
  · Earlier CI flake on "Forbid hardcoded user paths" was a checkout-auth glitch (cleared on rerun)
- 2026-05-23 14:55 · PR-4.1 DRAFTED (#70 · branch pr-4.1-workflow-run-orchestrator-bridge)
  · ADR-007 Option C — light bridge workflow-run ↔ orchestrator
  · workflow-run: STORE(active-workflow/step) + EXEC(orchestrator) inside LOOP; cleanup at DONE
  · orchestrator: bridge-mode gate skips STORE/ACT/CLEAR of W:active-program
  · Drive-by: tools/clock.py NTP timeout=1 (fixes test_tool_invocation_smoke[clock] flake)
  · 13 structural tests added; 129 total passed in targeted regression set
  · Findings: F-D4-002, F-D4-014 closed; F-D4-001 partial (schema mismatch defers to ADR-007b)
  · Status: AWAITING USER REVIEW + MERGE (handoff point)
- 2026-05-23 15:02 · PR-4.1 MERGED to main (#70 · commit 8bc04c3)
  · ADR-007 Option C light bridge shipped; CI green on rerun-free first attempt
  · clock NTP timeout=1 fix included → previous flake on main resolved
  · F-D4-002 + F-D4-014 closed (MAJOR); F-D4-001 partial
  · Phase 4-implement progress: C-04 cluster started + ~half closed (3 PRs total to go: 4.2, 4.3 + ADR-007b spec for full F-D4-001 close)
- 2026-05-23 15:14 · PR-4.2 MERGED to main (#71 · commit e8d2c2f)
  · ADR-007 follow-up: fixed-mode workflows skip orchestrator bridge tick
  · CI green first attempt (clock fix from PR-4.1 held)
  · F-D4-014 further tightened (no no-op suggestions in fixed mode)
- 2026-05-23 15:25 · PR-PHASE5-003 MERGED to main (#72 · commit a92a869)
  · P5-S15 doc-anchor e2e scenario shipped
  · Phase 5-validate: 14 → 15 scenarios; heavy-workflow-ready ~98% → ~99%
  · CI green first attempt, no rerun, no flake
- 2026-05-23 15:36 · PR-PHASE5-004 MERGED to main (#73 · commit 33e7375)
  · P5-S16 rule-pack runtime e2e scenario shipped (5 canonical hot-path programs)
  · Phase 5-validate: 15 → 16 scenarios; heavy-workflow-ready ~99% → 100%
  · CI green first attempt
  · End of Phase-5 wave series; remaining open clusters are non-gating refinements
- 2026-05-23 16:25 · PR-4.3 MERGED to main (#74 · commit faf4fa6)
  · workflow-simulate parity guard shipped (5 negative-assertion tests)
  · C-04 mainline cluster: 67% → 100%
  · CI green first attempt
- 2026-05-23 17:03 · PR-3.2 MERGED to main (#75 · commit 320cf3e)
  · axon-deprecation-cron registered in seed-defaults
  · C-03 deprecation cluster: 33% → 67%
  · First attempt blocked by checkout-auth flake (2nd occurrence this session); rerun cleared it
- 2026-05-23 18:23 · PR-3.3 MERGED to main (#76 · commit 11ee339)
  · deprecation-log sweep subcommand shipped; C-03 cluster: 67% → 100%
  · CI green first attempt
  · Only C-08 (last 2 Core Rule enforcers) remains open
- 2026-05-23 18:50 · PR-8.4 MERGED to main (#77 · commit df550de)
  · R_REASONING_TRACE prose-subject fail-open closed (F-D6-001); escalates to BLOCK when required
  · C-08 enforcers: 60% → 80%
  · CI green first attempt
- 2026-05-23 19:?? · PR-8.5 MERGED to main (#78 · commit 615fbf2)
  · R_OVERRIDE_ATTEMPT advisory-tier enforcer; F-D6-007 closed
  · C-08 cluster: 80% → 100%
  · ALL ranked clusters (C-01..C-16 in-scope) now complete
  · CI green first attempt
- 2026-05-23 19:?? · PR-15.1 MERGED to main (#79 · commit e6746a3)
  · 7 dispatcher 'unknown subcommand' errors now enumerate valid options (F-D2-010)
  · C-15 cluster closed → ALL ranked clusters (C-01..C-16 in-scope) complete
  · CI green first attempt
  · ── audit-derived roadmap fully shipped ──
