# Project: AXON HR UI
slug:            axon-hr-ui
schema-version:  v4
status:          active
legacy:          false
phase:           pr
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
next-action:     "2026-06-23 SYNCED. ALL AXON + SHARED lanes MERGED (origin/main=cf00b87, 19 nodes). Kernel batch shipped (PR-002a-boot 80f5b1f, PR-007 cf00b87). REMAINING = owner-only: GATE-STRANGER (O2-stranger-test.sh) + PR-T0-bootflow (menu-first-boot design). Deferred heavy tracks (PR-009b/010/012/015 + PR-014) → new projects at track-start. Then phase audit->done + CLOSE. Resume: BUILD-STATE.md (SESSION cont.3) + DAG-NEXT-STEPS.md."
last-program:    code-dev sync (full resync — dag sync + phase check + render + freshness; state tagged)
last-ts:         2026-06-23T15:49:04+00:00
created:         2026-06-22
updated:         2026-06-23

## Working Context
- origin/main = f9c90f1 (11 PRs merged total incl. this session's PR-003, freshness, PR-002a-relabel, flaky-gate-fix).
- RESUME POINTER → BUILD-STATE.md (full handoff: ## SESSION 2026-06-23 narrative + ## WHO-DOES-WHAT table).
  Also: 03-prs/DAG.json + DAG.md (canonical, resynced 2026-06-23T12:05Z), councils/FOLLOWUPS.md, KERNEL-TAPS.md,
  GAPFIND.json, HR-TEAM-FINDINGS.md.
- OWNER scripts (run in a NORMAL terminal): ship.sh <branch> (verify+merge+push, single-file), O2-stranger-test.sh
  (record a cold-start session), O1-apply-pr003.sh / O1-core-rule-12-review.sh (PR-003 — DONE, kept for reference).
- SYNC NOTE: the stale phases/study/03-prs/DAG.json (15 all-pending masterplan-initiative nodes) is SUPERSEDED
  by 03-prs/DAG.json. The phases/study/ dir is the legacy phase-dir layout (FOLLOWUPS: dir retirement pending).
