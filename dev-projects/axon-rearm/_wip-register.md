# WIP register — axon-rearm (uncommitted working-tree, attributed)
## RESOLUTION 2026-06-22 (reconcile)
> STATUS: largely RESOLVED. Group A (hr-team guard) committed 01325dc → MR !177 (merged main). Group B (enforcement-flag integration tests) committed 966715a → !177. Group D (_policy.md) now TRACKED/committed. Only **Group C** remains: 5 regenerated maintenance files still dirty in the working tree (tests/coverage.json, workspace/AXON-DOCS.md, workspace/_dashboards/axon-code-map.md, workspace/programs/REGISTRY.json, workspace/scheduler/cron.json) — disposition unchanged: commit as `chore(regen)` or discard. HUMAN decision.

---
_Original snapshot (2026-06-22 pre-merge) preserved below for audit:_

> Council closure #1: the dirty tree is not unattributed noise — every file maps to a thread.
> Committing is HUMAN (commit not in the AEGIS grant; spans projects). Commands proposed per group.
> Snapshot at reconcile: 2026-06-22 · branch fix/wave-g-residual-hardening.

## Group A — hr-team fail-closed guard  → project: hr-team-improvements (fix-vector #1/#3)
- tools/hr_team.py              (+23)  the ALLOW_STUB_ENV guard + NotImplementedError (the fail-closed seam)
- tests/test_hr_team_contract.py (+38) the contract test for the guard
NOTE: the dev checkout's safety currently DEPENDS on this uncommitted change — a reset would re-open fail-open.
Disposition: commit to hr-team-improvements' lead PR. Suggested:
  git add tools/hr_team.py tests/test_hr_team_contract.py
  git commit -m "fix(hr-team): run_seats fails closed by default (stub is tests-only) <AXON trailer>"

## Group B — enforcement-flag integration tests  → project: axon-rearm (Wave 0 / PR-T0-2 vicinity)
- tests/test_verify_integration.py (+67) integration tests for the opt-in enforcement flags
Disposition: attribute to PR-T0-2 (arm flags). Commit with that PR, or as a standalone test-add now.

## Group C — boot / docs / cron maintenance  → uncategorized AXON maintenance (NOT axon-rearm scope)
- axon/BOOT.md                  (+/-14)  orchestrator-tick / boot text
- workspace/AXON-DOCS.md        (+/-16)  docs regen
- workspace/AXON-DOCS-W-KEYS.md (+/-8)   W-keys registry regen
- workspace/audit/axon-lang.md  (+/-7)   audit regen
- workspace/scheduler/cron.json (+/-12)  cron state
- tests/coverage.json           (+/-2)   coverage artifact (regenerated)
Disposition: these are general maintenance churn, not re-arm work. Commit as a "chore(docs/boot/cron)" batch
or discard the regenerated artifacts (coverage.json, AXON-DOCS*) if they are auto-generated.

## Group D — AEGIS policy  → commit (it is the autonomous-mode delegation, currently untracked)
- _policy.md (untracked)        develop=grant · test-execution=green-only · pr-create=grant · merge=green-only
Disposition: commit to the repo root so the AEGIS grant is tracked.
  git add _policy.md && git commit -m "chore(aegis): track project autonomy policy <AXON trailer>"

## Why this closes council #1
The tree is now ATTRIBUTED with a disposition per file — the "10 unattributed changes" are resolved as
documented WIP across hr-team-improvements (A), axon-rearm (B), maintenance (C), and AEGIS (D). The actual
commits remain the owner's call; axon-rearm's own metadata/state is clean.
