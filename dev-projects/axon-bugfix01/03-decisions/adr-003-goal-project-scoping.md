# ADR-003 — Goal records get an optional project scope; goal-define writes the index
Status:   accepted
Date:     2026-07-07
Owner:    axon-bugfix01 (decision within PR-018)
Findings: C12, M14 (audit 2026-07-01)

## Context
C12: all 5 phase-entry guidance call sites treated `goal list`'s {ok, count, goals} envelope as
the goals array — the "no goal set" fallback could never trigger and FIRST() operated on the
dict; live-verified the guidance had never surfaced a real goal in any project. Compounding
(M14): `goal set` had no production caller (goal-define wrote only a markdown ledger;
workspace/memory/goals.yml did not exist on disk), and the record schema had no project field —
even a fixed reader could not be project-specific.

## Decision
- Records gain an OPTIONAL `project` field (slug). `goal list --project X` returns X's records
  PLUS global (unscoped) records — global goals stay visible everywhere; scoped goals are private
  to their project. Omitting --project keeps the old behavior (everything).
- goal-define (the only interactive goal-hardening flow) writes goal-shaped items through
  `goal set` with the active project's scope — the index becomes real, with the markdown ledger
  retained as the human narrative.
- Call sites read `.goals` from the envelope and pass `--project {project}`.

## Rejected
- A required project field: global/OS-level goals (axon self-improvement) are legitimate.
- Per-project goals.yml files: a single index with a filter is simpler and keeps `goal audit`
  (which already traverses projects) unchanged.

## Related

- Plan: [`../02-plan.md`](../02-plan.md)
