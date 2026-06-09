# Phase 4 — Portability (make the surface honest, no scope creep)

**Goal:** Convert 'runnable in-AXON' into 'self-documenting + copy-runnable' with zero new tool, dependency, or write path.

- Score after: 70/70 (or carried-over Phase-3 figure — Phase 4 adds 0 points by design)
- Reach after: + copy-runnable off-AXON as a standalone file with a declared public contract
- Exit gate: crucible passed:true; test_standalone_run_without_axon_paths green (copy runs exit 0); test_public_surface_is_declared green; existing tests prove zero in-AXON behavior change.

## PRs in this phase
- PR-12: declare __all__ on retrieval_eval.py and rag_maturity_audit.py (pure docs, pinned by an equality test); guard retrieval_eval's `from _axon_paths import` with a try/except fallback to Path(__file__).parent.parent so a copied file runs standalone (today dies ModuleNotFoundError — verified); one doc line on cross-install reach. NO package shim, NO pip wheel (deferred until real external demand)
> Parent plan: [02-plan.md](../02-plan.md)
