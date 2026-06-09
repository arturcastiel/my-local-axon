# Phase 5 — Completion Audit · axon-registry-accessor (F22)

> Method: re-check the study's goal against what shipped; classify done / deferred; record residual
> risk honestly. Date 2026-05-30, main `b12871b`, gate 22 controls / 0 fail.

## Verdict
**The F22 mechanism is COMPLETE and locked.** The single accessor exists, is tested against the raw
file, is adopted by the three clear duplicates, and the boundary is enforced by the gate — no new tool
can re-derive the registry path. Confidence **8/10**. Deduction: 14 legacy consumers still read raw
(stable, but the end-state of "one parser" isn't reached); the lock scopes to top-level `tools/*.py`
(rules/ runners aren't scanned — a small, low-risk hole).

## Goal coverage
- **"One home for the path + schema"** — ✅ `_axon_registry.py`. Path + the
  `{schema_version, contract_version, description, tools:{…}}` shape live there and nowhere sanctioned.
- **"Consumers delegate"** — ◑ the 3 pure duplicates do (verify/health/run); 14 legacy + 6 by-design
  validators still read raw. The validators *should* stay raw (independent check); the 14 are backlog.
- **"Drift can't return"** — ✅ the AST lock fails the gate on any new raw consumer, and forces a
  migrated file to drop off the ALLOWLIST (the list only shrinks).

## Residual / deferred (tracked, low-risk)
1. **14 legacy raw consumers** — incremental cleanup; each is a 1-file PR that swaps the load and drops
   itself from `ALLOWLIST`. No functional change, so deferred over churn/fatigue risk. The lock keeps
   the count from growing.
2. **6 validators stay raw by design** — registry_drift / drift / dag_consistency / coherence_lint /
   domain_validate / freshness. Documented in the lock-test; not a bug.
3. **Lock scope** — top-level `tools/*.py` only. `tools/rules/*.py` runners aren't scanned; extending
   the glob is a one-line follow-up if a rule ever hand-rolls the path.

## Honest note
This project deliberately delivered the *enforced boundary* over a *full rewrite*. That's the right
risk trade for a working system (the 14 legacy reads are correct today; the danger was new ones), but
it means the literal "20+ → 1 parser" headline number is "1 sanctioned + 6 by-design + 14 backlog",
not "1". The ratchet guarantees the backlog only ever shrinks.
