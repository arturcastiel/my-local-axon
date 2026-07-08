# Project: AXON Next — council follow-ups
slug:            axon-next
schema-version:  v4
status:          active
legacy:          false
phase:           study
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          (none)
sub-projects:    []
created:         2026-07-08
updated:         2026-07-08

## Working Context
- SOURCE: the hr-team standing audit (my-axon/generated/axon-standing-report-2026-07-08.md).
  Owner triage 2026-07-08 of the council's four Tier-1/2 recommendations:
  - T1 BENCHMARK — PARKED ("hanging"): owner believes the benchmark is STALE and needs
    adjustment before any run. Scope when picked up: refresh the guide (stale prompt-level
    caveat vs the merged --axon-arm mcp), re-validate the 2026-05-28 pre-registration against
    the current OS (40 days of change), re-run preflight/power, THEN decide the run.
  - T2 STRANGER TEST — PENDING owner understanding (explained in-session 2026-07-08);
    decision open: run it vs declare author-only.
  - T3 SAFETY GAPS — COMMITTED scope: (a) deletion-verb gate coverage in tools/shell.py
    (find -delete, rsync --delete, shred, xargs rm, bulk rm -rf under workspace/ + threshold);
    (b) grant TTL/budget + receipts for delegated destructive acts; (c) program-integrity
    tripwire (reviewed-hash manifest over workspace/programs/*.md, advisory→BLOCK staged).
  - T4 AUTONOMOUS-MODE STRENGTHENING — owner wants it STRONGER and wants to talk scope
    first (conversation opened 2026-07-08). Council counterweights to honor: safety seat's
    W1/W2/W5 (deletion blind spots, conditional kernel floor, standing grant) — strengthening
    autonomy and closing those gaps are the SAME project, not opposites.
- Next: converse T4 scope with owner → code-dev study over the autonomy stack + T3 surfaces.
