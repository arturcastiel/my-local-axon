# SHADOW: workspace/programs/code-dev.md
source-path: workspace/programs/code-dev.md
shadow-created: 2026-07-09
shadow-updated: 2026-07-09
git-hash: b5250714681bfeb4bb6633dcf380fc4436df409e
git-branch: main
git-commit: de0a760
git-commit-msg: axon-obsidian: the invokable code-dev-obsidian step + docs
caller-program: code-dev-study
caller-project: axon-stale-pointers

## Summary
code-dev dispatcher: two-token resolution, ~60 routes, shadow gate, dashboard. Explicit DONE-to-advance route (cmd=done -> phase-model done, loud FAIL on refusal), back (cascade-stale), skip (guarded, force recorded).

## Key Structures
_(not yet analysed)_

## Dependencies
_(not yet analysed)_

## Architecture Role
_(not yet analysed)_

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-09 |  | STALE-POINTER SEAM D: 'code-dev done' is loud+strict — but OPTIONAL; nothing at project completion requires it. Dashboard reads manifest as source of truth (correct) yet no route reconciles manifest vs _meta vs 02-prs merged-counts. No 'code-dev complete' closeout that stamps status:complete only when manifest is all-done. Phase-advance calls in study/plan/pr-create are best-effort -> silent-pending failure mode. |