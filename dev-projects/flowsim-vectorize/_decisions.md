# Decisions log — flowsim-vectorize

_ADRs (Architecture Decision Records) for this project. Append-only._

## ADR-001 — Production target: MPFA-D (2026-07-03)
Owner-approved. Evidence in `../study/artifacts/production-target-decision.md`.

## ADR-002 — Working branch: flowsim-artur (2026-07-03)
Owner directive: all alterations land on `flowsim-artur` branch. No PR flow —
direct commits to the branch. Owner will push/merge to master when ready.

## ADR-003 — Test tolerance: Frobenius 1e-12 / L2 1e-10 (2026-07-03)
Owner-confirmed. Matrices compared by relative Frobenius diff, pressure/flow
vectors by relative L2 norm.

## ADR-004 — Option (b) OOP resolution (2026-07-03)
Owner-approved my recommendation. One class hierarchy under `MetodoBase`:
  - `SolverMPFAH.m` → renamed to `MetodoMPFAH.m` inheriting `MetodoBase`
  - `SolverNLFVPP.m` → renamed to `MetodoNLFVPP.m` inheriting `MetodoBase`
  - `MetodoMPFAQL.m` → newly created (currently missing, factory expects it)
  - The vestigial `SolverBase` reference disappears (no file created)
  - `Caso1.m` (orphan under missing `BenchmarkBase`) → DELETE (not referenced by factory)
Implements PR-A2.

## ADR-005 — Autonomous workflow contract (2026-07-03 T13:07)
Owner-ratified `phases/plan/workflow-contract.md` with amendments:
  - Commit + push autonomously to `flowsim-artur`
  - No PR flow — direct branch merges
  - Status report every 5 PRs (silent between)
  - Test-first with oracle-vs-legacy for Phase B/C/D
  - HALT policy: skip failed PR, continue with independent-deps PRs; hard halt on cascade
  - Legacy retirement: opt-out flag (`useVect<X>` defaults `true`, legacy stays reachable)
  - Continue until end, do everything automatically

Policy updated: `_policy.md` capabilities now grant commit + push + merge.
