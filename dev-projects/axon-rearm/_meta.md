# Project: AXON Re-Arm (execute the council report-state handoff)
slug:            axon-rearm
schema-version:  v4
status:          active
legacy:          false
phase:           pr
workflow-step:   build
branch:          main  # fix/wave-g-residual-hardening MERGED to main 2026-06-22 (anchor 781463a,3497235 on main)
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-completeness-gate
sub-projects:    []
current-pr:      —  # PR-T2-anchor MERGED; no PR mid-flight. Next wave = VERIFY-THE-WIRE specs
next-action:     "RECONCILED 2026-06-22: DAG synced (35 nodes = backlog; PR-T2-anchor MERGED to main; added PR-T6-exp-baseline). branch=main. WIP tree resolved (only 5 regen maintenance files dirty — Group C). NEXT = REVISED FIRST SPRINT: (1) M1 re-baseline T1-1 vs HEAD, (2) VERIFY-THE-WIRE write+exec specs PR-T3-1 + PR-T3-3 + PR-T0-1, (3) PROTECT T2-devmode-default + T2-loopreceipt + T2-flags, (4) ARM T0-2 PhaseA. BLOCKER: PR-T1-cihost (no .gitlab-ci.yml; gating pipeline unresolved). HUMAN-ONLY (DONE 2026-06-22 via finish-loose-ends.sh): BOOT.md committed 53fe62c; regen committed c288274; 3 stale branches pruned (archive/pre-prune/* tags); stash dropped. CROSS-PROJECT URGENT: hr-team-improvements code-dev plan → propagate fail-closed run_seats to FOR-USE checkout (fail-OPEN there)."
last-program:    code-dev-state-resume (+ reconcile-sync)
last-ts:         2026-06-22T13:55:00Z
created:         2026-06-19
updated:         2026-06-22

## Working Context — owner-scoped from the 8-council report-state handoff (2026-06-19)
- GOAL: move AXON from "disarmed and blind" to "armed and instrumented." The 8 councils found a strong,
  self-honest architecture shipped with enforcement OFF and instruments unplugged. The fix is mostly
  configuration + unfinished wiring + a handful of small fixes, NOT a redesign.
- STUDY is DONE: the study material IS the 8 council reports + the synthesis handoff
  (axon-completeness-gate/reports/, copied to research/). 01-study.md distils it.
- The owner's 8 decisions (OD-1..OD-8) are RESOLVED and baked into the PR backlog (see 01-study.md §Decisions).
- DRIFT VERDICT (council): ~60% architecture/process, 30% config, 10% irreducible model — and the model
  share is unfalsifiable until the drift detector is instrumented (Tier 0 A1). Do Tier 0 FIRST.

## HARD CONSTRAINTS (inherited + owner)
- Owner directive (repeated, this session): BE CONSERVATIVE. More tests, more coverage. Each PR is
  redo-until-closed — not DONE until its claim is proven by an automated test (no fingerprint-only).
- NO KERNEL-SLIM.md edits except where a decision explicitly requires it AND with per-change owner confirm
  (OD-1 prose reconciliation, OD-2 may touch kernel lines 188/341, F1 version bump — flag each).
- crucible-green before test-execution (AEGIS green-only). AXON-only commit trailer. Gates cannot be broken.
- C-tier touches the security floor (dev-mode toggle, protecting tools/) — highest blast radius, own review.

## Lineage
- Parent: axon-completeness-gate (Wave A–F findings + Wave G residual hardening, branch fix/wave-g-residual-hardening).
- This project executes the forward backlog the handoff produced; the CR-13 fail-open (B1) is the same
  "gates fail open" family Wave G targeted.
