# Decisions (ADRs) — phase pr

## ADR-001-t2anchor-retroactive
Status: accepted
PR-T2-anchor's code landed off-workflow on fix/wave-g-residual-hardening (781463a) before a spec existed;
the spec (03-prs/PR-T2-anchor.md) anchors it retroactively and the test-contract fix (3497235) closed it.
Marked DAG status=complete 2026-06-22. Conservative: kept as a real spec, not a fingerprint.

## ADR-002-branch-baseline
Status: accepted
The Re-Arm backlog executes on `fix/wave-g-residual-hardening` (inherited from parent Wave G), not `main`.
_meta.branch synced to reflect reality (2026-06-22). M1 "re-baseline vs HEAD" applies: T1-1/T1-3/T1-4 must
re-scope to the residual because the CR-13 empty-diff fail-open is ALREADY closed on this branch.

## ADR-003-dag-m7-edges
Status: accepted
Added M7's authoritative protect-AFTER edges (T0-1→T2-2, T0-3→T2-2, T3-3→T2-2). The prose-only
T1-1+T1-cihost co-merge was NOT encoded (M7's edge list is authoritative; conservative — owner confirms direction).
