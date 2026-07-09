# SHADOW: tools/phase_model.py
source-path: tools/phase_model.py
shadow-created: 2026-07-09
shadow-updated: 2026-07-09
git-hash: 133b08b5d215ebc77aa450cf511f40e6c799d1a5
git-branch: main
git-commit: de0a760
git-commit-msg: axon-obsidian: the invokable code-dev-obsidian step + docs
caller-program: code-dev-study
caller-project: axon-stale-pointers

## Summary
Data-driven phase manifest (_phases.json) for code-dev projects. done() gates on deps-done AND declared-outputs-exist; best-effort mode returns ok:false+reason_code instead of raising. check() detects _meta.phase vs manifest split-brain. stale_downstream() cascade-invalidates dependents.

## Key Structures
done(force)/advance/add/normalize/check/seed_outputs/stale_downstream/render. PhaseError subclasses DepsNotDone, OutputsMissing carry machine reason codes. REQUIRED_OUTPUTS seed: pr phase requires 03-prs/PR-*.md (glob >=1).

## Dependencies
_(not yet analysed)_

## Architecture Role
_(not yet analysed)_

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-09 |  | STALE-POINTER SEAM B: mechanically sound but PASSIVE — advances only when a program calls it. Best-effort demotes outputs-missing to a LOG line: caller proceeds, manifest stays pending forever (exact axon-obsidian failure: PR specs batched into 02-prs.md, 03-prs/ empty, gate refused correctly, nothing reconciled). check() exists but NOTHING invokes it routinely (not boot, not menu, not self-care). _meta phase:complete is not a manifest id -> check() would flag it -> never runs. |