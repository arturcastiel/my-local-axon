# Project: HR-Team Improvements (wire the council seam, fail-closed everywhere)
slug:            hr-team-improvements
schema-version:  v4
status:          active
legacy:          false
phase:           study
workflow-step:   build
branch:          fix/wave-g-residual-hardening
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-rearm
sub-projects:    []
current-pr:
next-action:     "Study DONE at seed. Next: code-dev plan → PRs. Lead PR = propagate fail-closed run_seats guard to the for-use checkout (urgent safety), then wire CONVENER→sub-agent fan-out."
last-program:    code-dev-new (hand-seeded)
last-ts:         2026-06-22T08:20:00Z
created:         2026-06-22
updated:         2026-06-22

## Working Context
- Born from axon-rearm's META-FINDING + owner cross-session confirmation (2026-06-22): hr_team.run_seats
  'fanout' backend is unwired. Dev checkout fails-CLOSED (NotImplementedError unless AXON_HR_TEAM_ALLOW_STUB);
  the for-use checkout is fail-OPEN (silently minted variant-a/b/c + 0.2533 fake verdicts in a live task).
- This is the same fail-open / honesty≠enforcement family as axon-rearm's CR-13 — a second subsystem instance.

## HARD CONSTRAINTS (inherited)
- Conservative · test-more · redo-until-closed. New programs/tools REQUIRE tests (Core Rule 13).
- No KERNEL-SLIM edits without dev-mode + per-change owner confirm. AXON-only commit trailer. No --force.
- Anti-fabrication (Core Rule 6) is the CORE invariant here: a STUB seat response must NEVER reach a §4.3 verdict.
