# Phase 5 — Final Safety Audit — axon-bugfix01
Date: 2026-07-07 · Scope: the full 30-PR change-set (51b5485 → b525071, 29 squash-merges + doc commits on main)

## Gate posture at close
- Full suite: 5172 passed · 0 failed · 16 skipped (project start: 4944 — +228 tests, +187 net new pins)
- Crucible: 35/35 controls green (project added 2: liveness-lint WARN w/ promote condition, exec-args-lint BLOCK)
- Project lints over the merged tree: liveness ✓ · exec-args ✓ · check-stale 0 ✓ · check-templating 0 ✓ ·
  program-tool-conformance 0/51 ✓ · kernel F50 lock ✓ (v1.1.10)
- Every merge: branch full-suite green → 33-35-control crucible green → squash → hash-verified on main → pushed.

## Findings disposition (audit of 2026-07-01)
- SAFETY-CRITICAL 2/2 closed (S1, S2) — now MECHANICAL, kernel claims updated to match.
- CRITICAL 13/13 closed (C1-C13; C8-round-1 /memories/ was owner-scoped-out pre-plan).
- HIGH 26/26 closed. MEDIUM: M1-M8, M10*, M11-M15 closed or dispositioned (*M10 stubs quarantined,
  honest-loud when run); M9 remains owner-gated deletion. LOW: all items fixed or dispositioned.
- 4 ADRs accepted: hybrid descope, preemption descope, goal scoping, L: single backend.
- Audit-claim REVERSALS found during implementation (evidence over findings): M4 (questions file is a
  wired, test-pinned registry — deletion reverted); the 7 "STUB" meta-cluster headers were rot, not stubs.

## New defects FOUND by this project's own guards (beyond the audit)
- all_prs_implemented() — 5th unregistered predicate (vocabulary trap test)
- audit.critical-issues — hyphen-lexed-as-subtraction in every rejection-criterion
- 7 implemented programs with rotted STUB status headers (status-aware index rebuild)
- 11 dead tools total (4 first liveness sweep + 7 masked by the stale registry mirror)
- The un-staged ctx-fix YAML renames (caught during the PR-015 merge recovery)

## OWNER QUEUE (the only open items)
1. QUARANTINE.md sign-offs: finalize + the 3 empty scaffolding stubs + M9 trio + the 10
   liveness-flagged tools (wire or retire each).
2. Liveness lint promotion to BLOCK once the quarantine queue is resolved (condition recorded
   on the control).
3. Recommended follow-up project (axon-bugfix02): the never-audited surfaces — menu.md,
   status/stats, todo, board, workspace-backup, my-axon-init, auto_audit.py.

## Session-lesson ledger (recurring classes, now mechanized where possible)
- "Implemented+tested ≠ live" → liveness lint (sentinels + tool corpus).
- Inline EXEC kwargs never propagate → exec-args lint (BLOCK).
- Explanatory comments must not carry dead literals (tripped own pins 3×).
- Never truncate git-commit output (trailer-hook rejections were swallowed 2×).
- Post-gate docs regeneration blocks checkout → commit docs before checkout; verify merge hash on main.
- Tests can pin a bug as expected behavior (2 cases: check-structure route, bare self-care cron).
