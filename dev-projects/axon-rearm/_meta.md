# Project: AXON Re-Arm (execute the council report-state handoff)
slug:            axon-rearm
schema-version:  v4
status:          active
legacy:          false
phase:           pr
workflow-step:   build
branch:          fix/wave-g-residual-hardening
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-completeness-gate
sub-projects:    []
current-pr:      PR-T2-anchor
next-action:     "RESUME: read SESSION-HANDOFF-2026-06-22.md. Session test/gate arc DONE (5 MRs merged: !177-!181; gate ~3:35 parallel+reliable). Open: BOOT.md in stash@{0} (human commit), stale branches, hr-team-improvements needs code-dev plan, axon-rearm next = VERIFY-THE-WIRE→PROTECT→ARM (02-prs revised sprint)."
last-program:    code-dev-get-it-ready
last-ts:         2026-06-22T08:22:00Z
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
