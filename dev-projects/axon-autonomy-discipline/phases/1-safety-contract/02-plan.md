# High-Level Plan — AXON Autonomy Discipline (phase 1-safety-contract)
Updated: 2026-06-03  ·  Iterations: 3  ·  AXON: 9/10  ·  User: 9/10

## Context (from Phase 1 study)
Make AXON's autonomous operation **safe by construction**: off-workflow code work is gate-refused; the
reanchor is enforced on a cadence; the agent acts THROUGH AXON's programs (*use AXON, don't make stuff
up*). Governing frame: **separation of powers** (the director selects from AXON's full program catalog;
the executor runs it gated and holds the gate) with the **anticipation layer** as the menu and
`inference-mode` as the ask↔fire dial. **Criterion-zero:** code-change ⇒ on-workflow. (01-study Parts C–E;
ADR-005..008.)

## Architecture Overview
A subsystem built ON existing AXON primitives — it CLOSES the binding gap, it does not invent an engine
(mirrors how `code-dev` governs development):
- **gate teeth:** `crucible.run_changeset` + the rules pack
- **binding:** `phase-model` (active phase) + `03-prs/` PR specs
- **contract:** `autonomous_mode` grant + AEGIS `_policy.md`
- **operate-through-AXON:** the orchestrator/anticipation + `dispatch`
- **reanchor:** `axon-reanchor` + `session` + the cadence counter
- **ledger/replay:** `accountability` + workflow trajectories

## Plan sections

### S1 · Teeth — bind code-change ⇒ on-workflow (PR-001, PR-007)
`R_CODE_CHANGE_REQUIRES_PR_PHASE`: silent when no project loaded (hotfix exemption); the `r_new_needs_test`
code-classifier; project-meta + generated + non-code EXEMPT; weakest-sound coverage (active phase + ≥1 open
PR spec) → file-level later; WARN→BLOCK via flag; a reproduction test that replays the 2026-06-03 freelance.

### S2 · Reanchor — re-assert the workflow position (PR-002)
Extend the cleaned `autonomy-reanchor` draft to re-assert identity (via `axon-reanchor`) + the workflow
position (active project / phase / next step), fail-closed on off-workflow; fired on cadence + boundaries.

### S3 · Cadence — enforced, not trusted (PR-005, PR-006)
`W:autonomous-command-count` incremented in `dispatch.py` (the runtime command chokepoint) + the
orchestrator fires the reanchor every 5 commands in autonomous mode; the `R_AUTONOMY_CADENCE` backstop
control detects a lapse > 5 (detection = enforcement at gate granularity).

### S4 · Contract — ask for powers, unify authority (PR-003)
`autonomy-contract.md`: a `TOOL(decide)` powers interview → writes `_policy.md` (AEGIS) + the
`autonomous-mode` grant + an `accountability` entry; the overnight entry gate.

### S5 · Breakers — halt, don't push through (PR-004)
`r_autonomy_breaker`: halt-and-surface on a twice-red gate on the same change / N consecutive failures /
out-of-scope touch / budget exhausted.

### S6 · Operate-through-AXON — the discipline on its own engine (PR-005)
`autonomy-discipline.yml` FIXED workflow (contract → reanchor → select → breaker) driven via the
orchestrator/anticipation — the discipline runs on AXON's own engine.

## Residuals (honest — close in the specs/tests)
- File-level "covering" is heuristic (PR-spec format isn't rigidly file-listed) → ship weakest-sound +
  WARN-first; the reproduction test proves it.
- Hard real-time reanchor firing needs an owner-install host hook (`L:host-cap-reanchor`) — the backstop
  substitutes at gate granularity (a lapse caught at the next PR boundary, itself a reanchor point).
