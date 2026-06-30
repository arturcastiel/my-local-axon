# Masterplan — AXON code-dev + workflow harness improvements
> Source: deep source audit (5 parallel streams) + hr-team xhigh council (7 seats × 3 rounds, advisory_only) + Step-0 re-verification · 2026-06-24
> Architecture LOCKED (D-001): kernel/adapter. Sequence LOCKED (D-002): foundation-first.
> Full study + verdict + re-audit → `01-study.md`. Raw council verdict → captured in 01-study.md §Council.

## HARMONIZED PLAN — council w4vzc426j (felt-value-first · two-lane) · 2026-06-24
> Supersedes the foundation-first DELIVERY order below. The PR DAG (technical dependency order) is unchanged; DELIVERY is now DECOUPLED from DAG topology and ordered by felt-value-per-human-hour. Strong convergence (0.82–0.91), one preserved dissent.

**Goal hierarchy (root → cut):**
- **ROOT — G2:** relieve the felt guidance pain — at the study phase, be told WHAT to do and HOW (not a code dump). The original motive for the whole project.
- **PRIMARY — R3-render:** per-phase declared goal + how-to block at phase entry (the direct mechanism of G2).
- **SUPPORTING — R1 / R2 / R5:** make the relief universal (reachable everywhere, gated) + durable (doesn't rot after merge).
- **ENABLING — G4 (kernel/adapter):** hard correctness prerequisite for the durable/scale half; NOT a felt goal. Defines WHERE slice-1 lands, does not block it.
- **DEFERRED — R4:** demand→DAG capture; rides last (needs schema + reconciler proven stable).
- **CUT — G3 (owner scripts):** convenience, not G2 → spun into a later `axon-ops-tooling` project (recorded, not lost).
- **ANTI-GOAL:** AXON never edits the harness; AXON specs, human implements → human bandwidth IS the budget, so hierarchy order = human delivery order.

**Two lanes (T1):** AXON spec-lane runs AHEAD + DEEP (zero harness cost); the human implement-lane is the bottleneck, ordered by G2-payoff-per-hour — NOT by DAG topology. The human always has exactly one ratified, self-contained spec waiting.

**Delivery order (human lane):**
1. **Cycle 0 (AXON):** one-page kernel/adapter boundary spec → owner ratifies. Names the phase-ladder adapter as where the render lands (prevents a later migration). Design artifact, not a harness edit.
2. **PR-S0 — FIRST FELT VALUE:** study-phase entry-render (goal + how-to block) in the phase-ladder ADAPTER, reading existing `goal.py`/`phase_model.py` metadata, warn-first, flag-gated, reversible. **Foundation-independent** (reads kernel data, lives in adapter → no schema/reconciler/kernel edit). Effort = one render-fn + one template + one test = one sitting. Relief from merge day.
3. **Re-ratification gate** — confirm appetite for the foundation run before committing the human to invisible infra.
4. PR-001 (refactor) → PR-002 (schema + snapshot) → PR-003 (baseline) → PR-004 (read-only reconciler) → R1+R2 → R3 warn/metric backend → workflow adapter → **R5 + R4 last**.

**Open scope dissent (owner's call):** does PR-S0 include a STATIC auto-suggest text template (dx-designer, c=0.88: cheap, *completes* the relief — "the pain isn't just not seeing the goal, it's not knowing what to DO") or goal+how-to render only (challenger/goals-strategist/delivery-pm: auto-suggest rides slice 2)? Both are foundation-independent.

---

## Phase graph (directed)

- **study** (DONE) → **plan** → pr → log → audit

## Architecture (D-001 — endorsed 7/7, re-verified)

Kernel/adapter shape. The KERNEL is the shared graph + goal engines:
- `tools/dag.py` — the one DAG store/mutate/verify/render engine
- `tools/goal.py` — the 7-level goal engine (already names workflow/step/demand levels)
- `tools/git_dag_reconciler.py` — **NEW**, the missing git↔DAG truth comparator

ADAPTERS compile domain vocabulary DOWN to kernel nodes (no null-field pollution):
- code-dev phase-ladder (`phase_model.py`, `_phases.json`) ⇄ nodes
- workflow synapse-graph (`workflow_run.py`, on-complete edges) ⇄ nodes

NON-NEGOTIABLE: the CLI keeps saying "phase" / "synapse" — the adapter translates kernel "node" back to domain vocabulary at every boundary (ranked-finding #9). "Unify both subsystems" is NOT a milestone name — it invites scope inflation; the real work is an invisible prerequisite refactor (ranked-finding #3).

## Sequenced PR roadmap (council recommended_sequence, owner-chosen foundation-first)

| Step | Title | Maps to | Risk gate |
|------|-------|---------|-----------|
| 0 | Re-verify (DONE) | — | ✅ done — 7 claims re-audited against source |
| 1 | Invisible prerequisite refactor: plan_dag.py → dag.py primitives; phase_model.stale_downstream → dag.cascade_stale; reconcile workflow_dag.py registry/test | consolidation | no behaviour change; tests |
| 2 | Widen dag.py node schema (commit, origin:machine\|human, disposition, goal-id) **as a tested+migrated PR** (enum edits + SCHEMA_VERSION bump + workspace migrate); wire `_axon_rollback.snapshot()` into every DAG write | foundation for R4/R5 | migrated PR, snapshot wired |
| 3 | One-time DAG baseline/acknowledge pass (with snapshot) → reconciler reports only NEW drift; distinguishes SCHEMA_MISMATCH from GIT_DAG_DRIFT | first-run safety | snapshot |
| 4 | **READ-ONLY git↔DAG reconciler** + pre-written CONFLICT-HUMAN-EDIT policy; structured JSON; exit-nonzero-on-drift; advisory WARN in crucible one cycle | R2 + R4-detect + R5-detect | read-only, fail-closed, NO --fix |
| 5 | R3: render goal + how-to at phase ENTRY (constraints-checklist template) + goal-define.md auto-suggest (anchoring-aware, edit-vs-accept telemetry); goal-id presence WARN at done() ONLY after phase_gate wired | R3 (warn) | warn-only; metric pre-committed |
| 6 | R1: instantiate canonical workflow at scaffold (it EXISTS); load-time WARN existing, hard-gate NEW projects only; validate content not presence | R1 | gate new only |
| 7 | R4 write-half: detected demands → DAG with origin tagging; fail-open on machine origin; gate human-origin ack only | R4 (mutation) | after reconciler advisory-stable |
| 8 | R5 + any --fix behind a NAMED go/no-go: mandatory snapshot, full idempotency/dry-run + CONFLICT-HUMAN-EDIT branch coverage | R5 | retrospective go/no-go |

Throughout: prove **code-dev end-to-end on the shared kernel FIRST** (reference adapter) before bringing workflows onto it.

## Live dissent (preserved — never suppressed)
- [challenger] Cut the --fix CODE entirely from v1, not just the flag; cut both mandatory gates rather than warn-downgrade them ("a presence check can never enforce explain-HOW → blocking gate is ceremony").
- [challenger] Validate the synapse→node / phase→node compilers round-trip existing hand-edited nodes (kind:gate, disposition) WITHOUT data loss before adopting the kernel spine.
- [product-program-mgr] Incremental adapter-shim alternative: workflow_dag.py delegates to dag.py so R-items ship sooner, unification as a later cleanup PR. (Owner chose foundation-first instead.)

## Open questions for owner (carried into plan)
1. --fix scope: code absent in v1 (challenger) vs flag-guarded with snapshot+idempotency tests (5 seats)?
2. R3 gate-promotion metric + threshold + window (decide before warn-mode begins).
3. CONFLICT-HUMAN-EDIT precedence rule confirmation (DAG wins on hand-authored fields; git wins on nodeless merged commit; halt when both partially apply).
4. Willing to run the one-time DAG normalization pass over existing hand-edited projects?
5. R4 origin source-id requirement (tool/agent id; user/session id) + fail-open acceptable interim?

Next: `code-dev plan` → numbered PR specs + DAG (dogfood R4: every step lands as a DAG node from the start).
