# Cycle-0 — Kernel / Adapter Boundary Spec
> AXON design deliverable (NOT a harness edit). Precondition for PR-S0 and all later render/UX work.
> Source: harmonization council w4vzc426j (systems-architect's load-bearing insight). Owner ratifies before any human PR.

## Why this exists
PR-S0 (and every render after it) must land in the **adapter** layer, never the **kernel**. Without this contract written first, a render dropped into `goal.py`/`phase_model.py` would later need a migration PR when the kernel/adapter split formalizes (G4). One page now prevents that rework.

## The boundary

**KERNEL — data + engines (domain-agnostic; hold/serve canonical state; never render domain UX):**
- `tools/dag.py` — the one DAG store/mutate/verify/render-to-DAG.md engine.
- `tools/goal.py` — the 7-level goal engine (`project/phase/workflow/step/pr/finding/demand`); index `workspace/memory/goals.yml`.
- `tools/phase_model.py` — the `_phases.json` manifest engine (phase nodes, deps, status, outputs).
- `tools/git_dag_reconciler.py` — (future, PR-004) read-only git↔DAG truth comparator.

**ADAPTER — vocabulary + UX (domain-specific; translate kernel nodes ↔ "phase"/"synapse"; render the user surface; store NO canonical state):**
- `workspace/programs/code-dev-*.md` — the **phase-ladder** adapter (code-dev's study→plan→pr→log→audit surface).
- `workspace/programs/workflow-*.md` + `tools/workflow_run.py` — the **synapse-graph** adapter.

## Rules (the contract)
1. **All rendering / phase-entry UX lives in the ADAPTER program** (e.g. `code-dev-study.md`), and READS kernel data via tool calls (`goal.py get/list`, `phase_model.py render`). Reading kernel data is NOT modifying the kernel.
2. **Kernel never renders domain UX**; **adapter never stores canonical state.**
3. **CLI vocabulary is preserved at every adapter boundary** — the adapter translates kernel "node" → "phase" / "synapse" in every render, error, and status line. No surface emits "node" where domain vocabulary was used (first-council ranked-finding #9).
4. **New renders are flag-gated + warn-first** (reversible; degrade gracefully when the data they read is absent).
5. Landing zone for PR-S0: the `code-dev-study.md` entry-render block (the phase-ladder adapter). Landing zone for the workflow equivalent: the synapse adapter — specced in parallel, implemented later (T3).

## Status
AXON deliverable — DRAFT, ready for owner ratification. On ratify, PR-S0 may be implemented against it.
