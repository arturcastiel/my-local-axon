# Project: AXON Bugfix 02
slug:            axon-bugfix02
schema-version:  v4
status:          active
legacy:          false
phase:           audit
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          (none)
sub-projects:    []
created:         2026-07-07
updated:         2026-07-07

## Working Context
- IMPLEMENTATION COMPLETE 2026-07-07: 19/19 PRs merged + PUSHED (b525071..389a889, 22 commits).
  Suite 5250/0/16. All three lint ratchets EMPTY; memory-key + shell-result lints now BLOCK.
  See 04-log.md session entry. Next: code-dev audit (05-audit.md).
- PLAN COMPLETE 2026-07-07 (owner approved: "follow advises, and adapt plan"). 02-plan.md + 02-prs.md
  (19 PRs, 6 waves, lint-first ratchet) + 02-phases/ (6 files) + 03-prs/DAG.json (19 nodes, verify ok).
  Decisions locked: D1 board=FIX · D2 metrics=HONEST-DESCOPE-ADR · D3 restore=HUMAN-HANDOFF.
  Council ran INLINE (parallel council killed by host session limit) — verdicts source-verified;
  repairs: lint design (67% naive noise → unguarded+allowlist), resume via persisted W:active-phase,
  2 NEW workspace-backup defects (push-precedence no-op; unchecked clone-restore path) → PR-007.
- Next: code-dev pr 1 — write PR-001 spec (output_manifest growth), then implement wave A.
- STUDY COMPLETE 2026-07-07 (AXON self-grade 9/10 — met owner's >=9 target on round 1).
  01-study.md + AUDIT-FINDINGS.md: 4 CRIT, ~18 HIGH, ~22 MED, ~25 LOW. Root cause: reporting-layer
  reader/writer contract drift (dashboards/session read keys+fields nothing writes).
- (original) Follow-up to axon-bugfix01 (owner-ordered 2026-07-07): audit the surfaces bugfix01 NEVER covered
  (declared residual gaps in its study): menu.md, status/stats, todo, board, workspace-backup,
  my-axon-init, auto_audit.py, loop-contract, constraints, axon-docs-gen, lint-paths/lint-path-vars,
  dispatch-stats, find-program, list-tools, undo, gain, session-summary, resume.
- Study mode: AUTONOMOUS ITERATION until AXON self-grade ≥ 9 (owner directive).
