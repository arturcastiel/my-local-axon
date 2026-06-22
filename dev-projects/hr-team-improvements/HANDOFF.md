# HANDOFF — HR-Team Improvements (start here)
> Seeded 2026-06-22 from axon-rearm's META-FINDING + owner cross-session confirmation. Study is DONE.
> Pick up with: `code-dev load hr-team-improvements` → `code-dev plan`.

## In one paragraph
`hr-team` cannot convene a real council on its own: `run_seats` (the documented harness sub-agent fan-out
seam) is unwired. The dev checkout fails-CLOSED (NotImplementedError unless AXON_HR_TEAM_ALLOW_STUB); the
for-use checkout is fail-OPEN — it silently minted fake verdicts (variant-c, 0.2533) in a live task. Same
fail-open / honesty≠enforcement family as axon-rearm's CR-13. This project wires the seam and makes it
fail-closed in every checkout.

## What's here
- 01-study.md — the verified finding (contract vs code), cross-session evidence, owner decisions OD-A/B/C, 5 fix vectors.
- _meta.md — goal, hard constraints, lineage (parent: axon-rearm / PR-T4-hrteam).

## Next action
`code-dev load hr-team-improvements` → `code-dev plan` (turn the 5 fix vectors into a PR backlog + DAG).
Lead PR = propagate the fail-closed guard to the for-use checkout (urgent safety), then wire the fan-out.
