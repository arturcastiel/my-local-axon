# axon-user — dashboard

**slug**: axon-user · **status**: active · **phase**: 0-init · **codebase**: /mnt/c/projects/axon

## Quick links
- [_meta.md](_meta.md) — mission, personas, workflow matrix, invariants
- [personas/](personas/) — 5 persona definitions
- [findings/](findings/) — discovered friction points
- [01-study.md](01-study.md) — user-POV surface review
- [02-brainstorm.md](02-brainstorm.md) — adjustment ideas
- [03-plan-v3.md](03-plan-v3.md) — **active plan** (v3, errata + planning-hierarchy upgrade)
- [03-plan.md](03-plan.md) — prior plan (v2, errata only)
- [03-prs/INDEX.md](03-prs/INDEX.md) — per-PR detail index
- [03-prs/DAG-v3.md](03-prs/DAG-v3.md) — dependency graph (Mermaid + topo)
- [04-impl-plan.md](04-impl-plan.md) — **execution runbook** (ordered steps, gates, rollback, DoD)
- [04-log.md](04-log.md) — persona-run journal

## State

| metric                    | value          |
|---------------------------|----------------|
| personas defined          | 5              |
| workflows defined         | 15             |
| runs completed            | 14/15 attempted (5 personas) |
| findings (S1 / S2 / S3)   | 8 / 8 / 3      |
| improvement PRs proposed  | 17 (U-1 .. U-16 + U-V1) |
| plan iteration            | v3             |
| critical path             | U-1 → U-10 → U-11 → U-12 → U-14 → U-V1 (6 hops) |
| dominant finding          | F-001 — rename header mismatch (24 files) |

## Headlines

- **F-001** unblocks all S1 review/dispatch breakage in one 24-line sweep.
- **U-1** (rename-header errata) must land before any other improvement PR.
- **v3 adds wave U.E**: `code-dev plan --mode=X` now produces *real*
  tier artifacts (roadmap / phases / PRs / ADRs) instead of stdout-only
  format changes. This was identified as a fluxogram gap by the user.
- W-04 plan partial blanket budgets contradict per-mode caps (F-011/F-019).
- W-12 chats family is dead-on-arrival until F-005/F-006 ship.
- W-06 save/restore is half-implemented; F-007/F-008 propose dropping the
  unimplemented half (state-restore) and aliasing the rest to `tag`.

## Rule

**Improve, don't add — with one bounded exception (U.E).** Every v2 finding
proposes an edit to an existing file. U.E (planning workflow upgrade) is the
single relaxation — it adds three templates under `workspace/templates/` but
no new programs and no new tools. Out-of-scope feature requests still get
filed under `findings/out-of-scope.md`.
