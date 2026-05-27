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

## Codebase grounding
- **modify**: [`VERSION`](../../../../VERSION) — `0.9.0` → `1.0.0`.
- **modify**: [`CHANGELOG.md`](../../../../CHANGELOG.md) — seal `## 1.0.0 — <ISO>` block.
- **new**: `workspace/programs/code-dev-roadmap.md` — lists Post-1.0 items by short-code (D-E1 pr-stack, D-E2 reviewer-bot, D-B4 pr-import, G-CD-A4 release, D-C8 coverage-delta, D-C6 conflict-predict, G.tok.06 cache-hit-rate, G.wf.05 tutorial, G.wf.06 cookbook, G.inf.06 v5 schema, G.team.*, T-S2-S6, NS-3-14, R3 T5, CI deep, plan-vs-plan diff, plan→PR materialization).
- **tag**: `git tag -a v1.0.0 -m "..."` — HUMAN task (per safety rule, AGENT does not push tags).

## Cross-refs
- Master plan: `../03-plan.md` § Wave 4 final gate (DONE) + Post-1.0 queue.
