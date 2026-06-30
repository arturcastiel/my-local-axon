# Replan (v2) — axon-hr-ui consolidated PR list
> From the eval council (wf_d5efea5a-9dc) + applied verified findings. advisory_only.
> Audit JSON: councils/eval-replan.json

## ⚠ Harness bug disclosed (honest record)
The eval council received the plan as the literal string `undefined` (workflow `args` did not reach the
script — same bug that hit 2 discovery seats). So the council did NOT evaluate PR bodies. It DID verify the
3 disputed claims against the live repo (high-value) and surfaced 2 strong test-PRs. Auditor caveat carried:
"no objection ≠ endorsement" — un-evaluated PRs are NOT blessed; each gets a per-PR audit council on its
REAL diff during the build (file-grounded, args-free). Build councils must Read actual files, never rely on args.

## Verified-against-repo decisions (apply)
- **DROP PR-009 (adaptive-loop exit):** loop already terminates (feedback-loop.tpl.md UNTIL max-iter=3;
  KERNEL-SLIM:155 termination-guard rule). Re-file as PR-009b = termination tests for the 4 exits + the
  narrow `# Skip to next iteration` no-op fix (test-only, Rule 13).
- **DROP menu orphaned-ELSE concern:** mode-router.md ELSEs all IF-paired; Core Rule 12 full render. Non-bug.
- **REFINE PR-011 (promote/replay):** code-dev-replay is ACTIVE but menu.md doesn't surface it. Drop re-impl;
  add a thin text-only menu surface + a listing test. Auto-apply (audit→fix) stays gated behind
  L:auto-improve + L:dev-mode (surface-not-enforce).
- **SPLIT PR-002 (shadow/enforcement labeling):** NEVER claim a gate "enforced / cannot be bypassed"
  (surface-vs-BLOCK = class-1 safety). 2a = relabel + posture surfacing (verify label strings vs live hook);
  2b = flag activation after hook wiring. axon/BOOT.md slice → STAGED (kernel).
- **SPLIT PR-010 (reanchor):** cadence and discoverability are unrelated; scope ONE cadence knob, tested,
  via L:dev-mode. reanchor_store.py is just prompt storage. Kernel (G-02) slice → STAGED.

## Added (KEEP — test-first, high value)
- **PR-016 R9 write-gate integration test:** enforce_pretooluse.py is the one real mechanical R9 gate —
  exit-2 integration test on an axon/ write with dev-mode OFF. (tests/ — autonomous.)
- **PR-017 rule-module tests:** two-tier advisory + BLOCK cases so the suite fails loudly at the flip.
- **PR-009b termination tests:** 4-exit termination + the Skip-to-next-iteration no-op fix.
- **PR-011 promote-path test** (vs replay).

## Corrected execution list (autonomous unless marked STAGED=kernel)
Wave 1 quick-wins: PR-001 phase_model add · PR-004 kv-store --raw · PR-005 synapse dedup ·
  PR-016 R9 test · PR-017 rule tests · PR-009b termination tests · PR-003 OS-STATE collapse (menu.md;
  output-layer slice STAGED) · PR-007 resume-truth · PR-006 code-dev start (+tests).
Wave 2 foundation: PR-008 phase state real+visible (dep PR-001; ActiveProgramStrip; bounded).
Wave 3 workflow: PR-011 replay surface+test · PR-012 save/sync verb · PR-002a label+posture (BOOT slice STAGED) ·
  PR-010 cadence knob (STAGED kernel).
Wave 4 gate/later: PR-013 stranger-test gate → PR-014 (gated) · PR-015 deferred (kernel) · PR-002b flags.

## Dissent preserved
- harness-designer: the Skip-to-next-iteration no-op IS a real narrow defect (→ PR-009b).
- app-sec: conditionally keep 009/011 (minority) — addressed by re-scoping, not full drop.
- challenger: "void-author-reissue" (re-run eval) — declined in favor of per-PR audit councils on real diffs.
- auditor: "no objection ≠ endorsement" — honored via per-PR audits.
