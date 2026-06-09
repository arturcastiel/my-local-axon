# Project: AXON Bug-Free — deep codebase audit, bug capture, autonomous remediation
slug:            axon-bug-free
schema-version:  v4
status:          active
legacy:          false
phase:           1-study
workflow-step:   study
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-improvements
sub-projects:    []
created:         2026-05-29
updated:         2026-05-29

## Working Context
- Objective: the deepest feasible study of the AXON codebase → capture every real bug,
  audit correctness + test coverage + mechanical-gate completeness → autonomously
  remediate via the proven fail-closed dev loop
  (branch → FULL `crucible gate` → green → push(SSH) → `glab mr create` → squash-merge).
- Autonomous envelope (AEGIS `_policy.md` × active grant, fail-closed):
  - SELF-MERGE (when crucible GREEN): non-kernel code under `tools/`, `tests/`,
    `workspace/`, `benchmark/`; develop + pr-create + merge-squash.
  - HUMAN-ONLY (capture + propose, never self-merge): any `axon/` kernel/core edit
    (needs dev-mode + owner), `build`/app-run, destructive git (force-push/reset/branch-delete).
- Maps onto the masterplan critical path: dont-do-enforce + dag-consistency + axon-tests → bug-free.
- Feeds axon-million credibility (pillar 1/theory): a bug-free, gate-enforced OS is the
  substrate for the "AXON makes agents more reliable" claim.

## Follow it up
01-study.md = audit charter + live bug ledger + gate-gap register + million-$ delta.
04-log.md   = per-PR remediation log (autonomous loop entries + SESSION markers).

## Start with
code-dev load axon-bug-free → read 01-study.md (charter + live bug ledger).
