# Autonomous Build Run-book — axon-hr-ui
> Owner directive 2026-06-22: full autonomy until the end; design questions → HR council; dev-mode on.
> Authority: autonomous-mode grant (artur.castiel-tno/axon: commit/push/pr-create/merge-squash, deny kernel-change)
> + AEGIS _policy.md (develop:grant, test-execution:green-only, merge:auto, build:human) + crucible gate.

## Preconditions to START (both must be true)
1. Eval/replan council (wf_d5efea5a-9dc) landed → consolidated final PR list in 02-prs.md (v2).
2. Crucible baseline green (4788 tests) recorded as the pre-build bar.

## Per-PR autonomous loop (in wave/dependency order)
For each PR in the consolidated list:
  1. ROUTE LAYER:
     - non-kernel (workspace/ · tools/ · tests/ · workflows/ · my-axon/) → autonomous path.
     - kernel (axon/ core: KERNEL-SLIM, BOOT, OUTPUT-LAYER, GRAMMAR, core/, hooks) → STAGED path.
  2. DECIDE (only if the PR has an open design question): convene an HR decision council
     (micro/low tier) → record the verdict as the answer. No question goes to the owner.
  3. IMPLEMENT: create branch `axon-hr-ui/PR-NNN-<slug>`; write the change on a git worktree.
  4. AUDIT: convene an HR audit council (review lens: correctness · scope · tests · regression)
     → it must return PASS or a fix-list; apply fixes; re-audit until PASS or 3 rounds.
  5. TEST: run the suite / crucible. ALL tests must pass (green). On red → fix → re-test; if a
     PR can't go green in 3 cycles → HALT that PR, log, continue others (no red merges, ever).
  6. MERGE + PUSH (autonomous path only): commit (Co-authored-by: AXON), merge-squash to main on
     green, push origin. Mark PR status: merged in 02-prs.md.
     STAGED path: stop at a ready diff + green tests; surface for ONE owner confirm (floor: per-change
     confirm). Do not merge kernel changes autonomously.
  7. CHECKPOINT + continue to next PR.

## After ALL waves
  A. HR council — audit the code-dev audit: did each PR deliver its acceptance? regressions? drift?
  B. Improve-audit + gap-find: run code-dev audit + a gap-finding council → write a follow-up
     findings doc (round-2 backlog) under councils/.

## Hard invariants (non-waivable)
- No red merge. No kernel auto-merge. No build (human-only). No force-push/reset/rebase.
- Each new program/tool ships with tests before ACTIVE (Core Rule 13).
- Verify-first PRs (PR-009 adaptive-exit, PR-011 promote/replay, render claims) confirm the dispute
  against the live repo BEFORE writing code; a verified no-op closes as such.
