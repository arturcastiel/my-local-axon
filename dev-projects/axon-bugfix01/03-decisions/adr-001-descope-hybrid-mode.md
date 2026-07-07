# ADR-001 — Descope hybrid execution-mode; define adaptive differentiation
Status:   accepted
Date:     2026-07-03
Owner:    axon-bugfix01 (decision D1, owner-delegated "you decide" 2026-07-03)
Findings: H4 (audit 2026-07-01)

## Context
H4: fixed/adaptive/hybrid modes were "not actually differentiated" — workflow-run resolved
next-id identically for every mode, adaptive ranking was printed and discarded, and hybrid had
zero implementing logic anywhere (no shipped workflow even used it). Authoring surfaces
(workflow-new, workflow-edit, the menu) offered hybrid as if it existed.

## Decision
1. **Hybrid is DESCOPED**, not implemented. Authoring surfaces stop offering it; typing it gets
   a loud refusal pointing here. A hybrid-tagged file that reaches the runtime runs as adaptive
   with a WARN (never silently). The schema enum keeps the token for file back-compat only.
2. **Adaptive ≠ fixed via four real, shipped mechanisms** (not via ranked next-id override):
   a. advance-guard deviation allowance (--allow-deviation) — fixed is strict, adaptive may deviate;
   b. per-step ranked suggestions surfaced (sideband + footer);
   c. the orchestrator bridge tick (fixed-mode skips it);
   d. `role: orchestrator` nodes — the sanctioned mechanism for DYNAMIC segments inside a
      declared graph (rank-then-fire over the programs corpus).
3. **Rejected alternative**: synthesizing ephemeral graph nodes from ranked suggestions when no
   on-complete rule fires. It would let the ranker mutate the traversal graph at runtime —
   breaching the rigid-fixed-traversal discipline (axon-workflow-discipline) and making replay/
   promote trajectories unsound. Dynamic segments belong in declared orchestrator nodes.

## Consequences
- Re-scoping hybrid later = a real design + implementation project, starting from this ADR.
- Doc claims (workflow-run.md header) corrected to describe what adaptive actually is.

## Related

- Plan: [`../02-plan.md`](../02-plan.md)
