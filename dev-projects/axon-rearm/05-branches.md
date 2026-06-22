# Branch registry — AXON Re-Arm
> Updated by code-dev-journal-log / code-dev-pr-create / code-dev branch sync.

| Branch                          | PR(s)         | Status   | Commits                | Notes |
|---------------------------------|---------------|----------|------------------------|-------|
| fix/wave-g-residual-hardening   | PR-T2-anchor  | merged   | 781463a, 3497235       | R9 AXON_ROOT sentinel anchor (M4). MERGED to main 2026-06-22 (both commits ancestors of main). |

## Notes
- 2026-06-22 (reconcile): fix/wave-g-residual-hardening MERGED to main. Active base is now `main`; `_meta.branch=main`.
  New PR work branches off main per-PR. STALE branches PRUNED 2026-06-22 (finish-loose-ends.sh): `fix/gate-serial-restore`, `chore/test-council-actions`, `perf/xdist-parallel` force-deleted; restore points kept as `archive/pre-prune/<branch>` tags.
- Working tree: resolved — only 5 regenerated maintenance files dirty (Group C, see _wip-register.md). HELD for human: axon/BOOT.md kernel-floor edit in `git stash@{0}`.

## Commits 2026-06-22 (this session)
| Commit | Group | Project | Note |
|--------|-------|---------|------|
| 01325dc | A | hr-team-improvements | run_seats fail-closed guard + contract test |
| 966715a | B | axon-rearm (Wave 0)  | enforcement-flag integration tests |
| e82bfc9 | C | maintenance          | regenerated docs/cron/audit |
Pushed → MR !177 (merged). _policy.md now committed/tracked. axon/BOOT.md (kernel-floor orchestrator-tick doc sync) COMMITTED 2026-06-22 → 53fe62c on main. stash dropped.
