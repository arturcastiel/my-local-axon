# SHADOW: tools/self_care.py
source-path: tools/self_care.py
shadow-created: 2026-07-09
shadow-updated: 2026-07-09
git-hash: 9af435020a8aa6b2bc99d59db238aeb27c2b3a4e
git-branch: main
git-commit: de0a760
git-commit-msg: axon-obsidian: the invokable code-dev-obsidian step + docs
caller-program: code-dev-study
caller-project: axon-stale-pointers

## Summary
Read-only self-maintenance sweep: health, freshness, cron overdue+breakers, drift, igap, path-vars lint, Claude-Code persistence check. --heal reconciles docs + re-probes health. Composition-only over existing tools.

## Key Structures
_(not yet analysed)_

## Dependencies
_(not yet analysed)_

## Architecture Role
_(not yet analysed)_

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-09 |  | STALE-POINTER SEAM C (missing check): sweep has NO pointer-coherence area. Natural home for pointer-lint: cross-check W:active-phase (program exists / not stale vs project state), phase-model check() per active project, _meta status:complete vs manifest all-done, last-test-run.json ts vs latest commit. Pattern to follow: areas dict + attention list + ok flags; add one area, wire into report. |