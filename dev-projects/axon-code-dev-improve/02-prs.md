# PR list — AXON code-dev + workflow harness improvements
> From `01-study.md` locked sequence (D-001 kernel/adapter · D-002 foundation-first). DAG: `03-prs/DAG.json`.
> Status: PR-000 complete · PR-001..008 pending. Critical path: PR-001 → 002 → 003 → 004 → 007 → 008.

| PR | Title | Maps to | Depends on | Risk gate |
|----|-------|---------|-----------|-----------|
| PR-000 | Source re-verification of council claims | Step 0 | — | ✅ complete |
| PR-S0 | Study-phase goal + how-to entry-render (felt value) | G2 root / R3 user-half | Cycle-0 boundary | ✅ **MERGED** @5e44b07 |
| PR-001 | Invisible refactor — collapse confirmed duplicates (plan_dag.py→dag.py primitives; stale_downstream→cascade_stale; workflow_dag.py registry/test) | R2/R5 substrate | PR-000 | no behaviour change; tests green |
| PR-002 | Widen `dag.py` node schema (commit, origin:machine\|human, disposition, goal-id) **as a migrated PR**; wire `_axon_rollback.snapshot()` into every DAG write | R4/R5 foundation | PR-001 | enum+version migrated; snapshot wired; round-trip test |
| PR-003 | One-time DAG baseline/acknowledge pass (snapshot); split SCHEMA_MISMATCH vs GIT_DAG_DRIFT | first-run safety | PR-002 | snapshot; idempotent |
| PR-004 | **READ-ONLY git↔DAG reconciler** + CONFLICT-HUMAN-EDIT policy doc; 3 drift classes; exit-nonzero; advisory WARN one cycle; no `--fix` | R2 + R4-detect + R5-detect | PR-003 | read-only; fail-closed; policy written first |
| PR-005 | R3 — goal + how-to at phase ENTRY (constraints template) + goal-define auto-suggest; goal-id presence WARN at done() only after phase_gate wired | R3 (warn) | PR-002 | warn-only; metric pre-committed |
| PR-006 | R1 — instantiate canonical workflow at scaffold; WARN existing, hard-gate NEW only; validate content | R1 | PR-002 | gate new only; content-validated |
| PR-007 | R4 write-half — demands→DAG, origin-tagged, source-id required, fail-open on machine | R4 (mutation) | PR-004, PR-002 | after reconciler advisory-stable |
| PR-008 | R5 repair + any `--fix` behind a NAMED go/no-go | R5 | PR-004, PR-007 | snapshot + idempotency + full branch coverage |

## Owner decisions — RESOLVED by decision council (hr-team high 5×2, advisory → ratifiable)
| # | Decision | Resolution (recommended) | Vote · conf |
|---|----------|--------------------------|-------------|
| D-006 | `--fix` scope in v1 | **CUT mutation code entirely**; re-enters as PR-008 (snapshot+idempotency+CONFLICT tests = core exit) | 5/5 · 0.87 |
| D-007 | CONFLICT-HUMAN-EDIT precedence | **Amend: HALT-as-default** for all residual ambiguity; DAG wins on hand-authored fields; git wins only on nodeless merged commit | 4/5 · 0.78 |
| D-008 | One-time normalization pass | **Yes** — snapshotted, idempotent, fail-closed (leave-unknowns-flagged) → PR-003 | 5/5 · 0.88 |
| D-009 | R3 gate-promotion metric | **Pre-commit metric (accept-rate, window min(200,30d), N≥50), NO auto-flip**; warn→block needs explicit ratification | 4/5 · 0.75 |
| D-010 | R4 origin source-id | **Hard precondition** (defined PR-002, asserted PR-007); fail-open on untagged/machine interim | 5/5 · 0.85 |

**One residual owner choice (D-009):** name a candidate threshold now (qa: accept-rate ≥0.60 / two 30d windows) vs **observation-only, no number** (4 seats — adopted as default). Veto/confirm.

Full ADRs → `phases/study/_decisions.md` (D-006…D-012). PR-001 spec written → `03-prs/PR-001.md` (Item C dropped: workflow_dag.py is live+tested).

Next: PR-001 spec is DONE. → `code-dev pr 2` (PR-002 spec: schema widening + source-id field + rollback wiring) once decisions are ratified.
