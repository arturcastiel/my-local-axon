# pr-v4 — Version bump 1.0.0

**Wave**: W4 (close, DONE) · **Depends-on**: ALL prior PRs merged

## Why
1.0.0 marks the completion of the axon-master hardening programme: all R2-R6 actionable items closed or explicitly deferred (see Post-1.0 queue in `../03-plan.md`).

## Spec
- **Files**: modified `VERSION`, `CHANGELOG.md`; new `workspace/programs/code-dev-roadmap.md` (Post-1.0 queue, named).
- **Acceptance**:
  1. `VERSION` = `1.0.0`.
  2. CHANGELOG `## 1.0.0 — <ISO>` sealed.
  3. `code-dev-roadmap.md` lists every named Post-1.0 item (D-E1 pr-stack, D-E2 reviewer-bot, etc. per `../03-plan.md` Post-1.0 section).
  4. All Wave-4 final-gate conditions in `../03-plan.md` satisfied.
- **Rollback**: revert version (functionality stays).
- **Owner**: AGENT writes; HUMAN reviews + tags release.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 4 final gate (DONE) + Post-1.0 queue.
