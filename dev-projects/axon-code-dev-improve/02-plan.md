# Plan — AXON code-dev + workflow harness improvements
> Phase 2 · 2026-06-24 · Architecture D-001 (kernel/adapter) · Sequence D-002 (foundation-first)
> Grounding → `01-study.md` · PR list → `02-prs.md` · DAG → `03-prs/DAG.json`

## Thesis
Five owner demands resolve to **one architecture move + one missing tool**: route both subsystems through shared graph/goal engines (kernel/adapter), and build the absent git↔DAG reconciler that makes code-first drift visible. ~60–70% of primitives exist; the work is the mutation/reconcile/repair half — sequenced so the highest-blast-radius code (graph mutation, `--fix`) ships last, behind snapshots and a read-only detector that has earned trust.

## Build order (why this order)
1. **PR-001 consolidation first** — the duplicate emitters/cascades (`plan_dag.py`, `stale_downstream`) will corrupt R4/R5 if left; collapsing them is invisible but load-bearing.
2. **PR-002 schema + snapshot** — re-audit confirmed widening is a *migrated* PR (closed enums + `SCHEMA_VERSION_MISMATCH`), and `_axon_rollback` is unwired; both must land before any mutation.
3. **PR-003 baseline** — without a one-time normalization, the reconciler drowns every existing hand-edited DAG in `SCHEMA_VERSION_MISMATCH` noise on day one.
4. **PR-004 reconciler (READ-ONLY)** — the MVP center; R2 + R4-detect + R5-detect all stand on it. CONFLICT-HUMAN-EDIT policy written *before* the build.
5. **PR-005 / PR-006** — R3 (warn + entry-render) and R1 (instantiate canonical) can land in parallel once the schema (PR-002) exists. Both gate NEW only; WARN existing.
6. **PR-007 R4 write-half** — only after the reconciler is advisory-stable; origin-tagged, fail-open on machine.
7. **PR-008 R5 / `--fix`** — last, behind a named go/no-go (challenger dissent preserved: defer the code, not just the flag).

## Reference-adapter rule
Prove **code-dev end-to-end on the shared kernel first**; bring workflows (synapse adapter) on only after. Preserve `phase`/`synapse` CLI vocabulary at every boundary (no surfaced "node").

## Carried dissent (do not lose)
- Challenger: cut `--fix` code + both mandatory gates from v1; re-validate compiler round-trip on hand-edited nodes before adopting the kernel spine.
- Product-mgr: incremental adapter-shim alternative exists if foundation-first feels too slow.

See `02-prs.md` for the per-PR table and the 5 owner decisions that finalize PR-004/005/007/008 specs.
