# AUTONOMY — arturcastiel/cpg2python
> Standing autonomy doctrine for this project. Written by the activation interview.
> No completed AUTONOMY.md = no autonomy (fail-closed). Resolved: aegis_policy × grant × gate.

status:          active
schema:          autonomy-doc v1
repo:            arturcastiel/cpg2python
scope:           fault-smo-mesh-adaptation GRANT A - engine, writer, upstream prereqs (8 PRs)
level:           autonomous-gated
budget:          17 PRs across 2 grants; TTL 72h

## capabilities
develop:         grant
test-execution:  green-only
pr-create:       grant
merge:           green-only
build:           human

## destructive
branch-delete:   grant
rebase:          grant

## deviation-policy
on-red:          halt-and-handoff
on-scope-exit:   halt-and-handoff

## floor (not delegable)
# kernel-edit / force-push / reset-hard / branch-delete / bulk-delete / destructive — human-only.
# These hold regardless of anything above; strengthening autonomy never weakens them.

## Dependency graph
<!-- the per-run fluxogram is rendered here (REPLACE-SECTION target, PR-013) -->

## Notes
- ADR-004, owner interview 2026-07-28 (six questions, each grounded in verified repo state).
- A1 loop depth: full loop including merge-squash, gated on green.
- A2 two repos: the grant schema is single-repo, so GRANT A (cpg2python, 8 PRs) runs first,
  then GRANT B (fault-projections, 9 PRs). PR-011's dependency on PR-009 was relaxed to
  PR-005 only, which collapses the schedule from 4 grant windows to 2.
- A3 gate: full pytest + ruff + mypy LOCALLY *and* GitHub Actions green before any merge.
- A4 mode: unattended (breaker recorder + cadence enforcement).
- A5 destructive: branch-delete + rebase delegated for this repo; force-push / reset-hard /
  amend remain human-only. kernel-change is never delegable.
- A6: PR-000a / PR-000b gate-setup PRs land first, since neither repo configured ruff or mypy
  and both CI workflows ran pytest only.
- Full study + 23 design decisions: 01-study.md and phases/study/_decisions.md.
