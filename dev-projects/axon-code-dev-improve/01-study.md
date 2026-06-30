# Study — AXON code-dev + workflow harness improvements
Updated: 2026-06-24 · Method: deep source audit (5 parallel streams) + hr-team xhigh council (7 seats × 3 rounds, advisory_only) + Step-0 re-verification · AXON: 9/10 · Owner: confirmed

## Goal
Harden AXON's two project-execution subsystems — **code-dev** (phase-ladder projects) and **workflows** (synapse-graph runs) — against five owner-stated quality-of-life demands, built **once on shared engines** wherever the two subsystems can converge. The recurring problem across all five: AXON has mature *detectors* but few *mutators/reconcilers*, and work created mid-flow goes invisible to the plan. Codebase = the AXON repo itself (`/home/arturcastiel/projects/new-axon/axon`); `workspace/` programs + `tools/` are in scope, `axon/` kernel edits are human-only and owner-staged.

## Priorities — the five demands (each applies to BOTH subsystems)
- **R1** Every project/workflow MUST have a workflow file, created by default at scaffold (gated).
- **R2** Generalize the ad-hoc "code-dev sync" resync (keep DAG / phases / docs / git consistent) into a first-class routine.
- **R3** EVERY phase/step MUST declare a clear GOAL (AXON may auto-suggest) + the study phase must explain HOW to do the work, not just dump code — gated.
- **R4** New demands (PRs/tasks) born mid-flow — machine OR human — MUST be detected and written into the DAG, then cascade-update. No work invisible to the plan.
- **R5** Repair + consistency routines to detect a broken/inconsistent project format and repair+resync.

## Constraints
- Building is a human task — AXON never runs build/test/merge/push autonomously.
- `axon/` kernel edits = inviolable floor: human-only, per-change confirm, even in dev-mode.
- No DAG-mutating code path ships without `_axon_rollback.snapshot()` wired first.
- New gates WARN on existing in-flight projects; hard-block NEW projects only.
- New neurons (programs/tools) require tests (Core Rule 13).
- Convergence/consensus never substitutes for source re-verification (council Step 0).

---

## Verified grounding (deep source audit — 5 parallel streams, all CONFIRMED)
~60–70% of the primitives already exist. The work is *build the missing half + gate + wire*, ideally once for both subsystems.

| # | Gap (confirmed) | Already exists | Net new |
|---|-----------------|----------------|---------|
| R1 | `code-dev-new` scaffolds 0 workflow files; nothing gates it | canonical `code-dev.canonical.yml` (7 synapses) + `parent-workflow` inheritance key; full workflow suite | scaffold-instantiation + load/scaffold gate |
| R2 | "code-dev sync" is only a 275-line hand SOP (`CODE-DEV-RESYNC.md`); no program/route; `dag.py sync` is read-only despite the name | `dag.py`, `phase_model.py check`, `dag_consistency.py` (all detect-only) | a first-class sync routine over the reconciler |
| R3 | phase records carry only `{id,name,order,deps,status,outputs}` — no goal/guidance/done-when; study entry text is STATIC (its "Goal:" line is a hardcoded example); pr-create/log/audit render no goal | `goal-define.md` (goal-hardening engine) + `constraints.py` (per-phase checklist renderer) | goal/guidance fields + entry render + (later) gate |
| R4 | **strongest gap** — `dag_consistency.py` never reads git → code-first drift invisible; crucible DAG gate passes clean on a drifted repo; no `origin:machine\|human` | `goal.py` `demand` level + `_demands.md` ledger (not wired to DAG); `dag.py add-node` | git↔DAG reconciler + demand→DAG wiring + origin field |
| R5 | `dag_consistency.py` is self-documented "the DETECTION half… cascade/repair half never built"; no repair function exists | the detection layer | repair routine behind go/no-go |
| mirror | workflows use synapses not phases; `workflow_dag.py` reimplements `dag.py`; `dag_consistency` claims workflows in-scope but only walks for `DAG.json` files (workflows have none) | `goal.py` is a 7-level engine naming workflow/step/demand | route workflows through shared engines |

---

## hr-team council verdict (xhigh · 7 seats × 3 rounds · adversarial-debate · advisory_only:true)
Roster: harness-os-architect · state-consistency-eng · dx-api-designer · release-devops-sre · qa-enforcement-eng · product-program-mgr · CHALLENGER. Confidence rose 0.66–0.82 (R1) → 0.72–0.87 (R3); 6/7 seats changed position across rounds (genuine deliberation). 22 agents, ~730k tokens.

### Consensus (high-confidence)
1. **Kernel/adapter architecture is sound** — `dag.py` + `goal.py` + a new git-DAG reconciler = kernel; phase-ladder + synapse-graph are vocabulary adapters that compile DOWN to nodes.
2. **"Unify both subsystems" must NOT be the framing/milestone** — it invites scope inflation; the real work is an invisible prerequisite refactor collapsing confirmed duplicates.
3. **The git↔DAG reconciler is the MVP center** (R2, R4-detect, R5-detect all stand on it).
4. **Ship the reconciler READ-ONLY** — fail-closed, exit-nonzero-on-drift, structured diff, **no `--fix` in v1**; advisory WARN in crucible for one cycle.
5. **Write a CONFLICT-HUMAN-EDIT policy BEFORE building** the reconciler.
6. **R3 ships warn + auto-suggest + render-at-entry** — does NOT block at `done()` in v1.
7. A presence check can never enforce "explain HOW"; gate promotion must be evidence-based behind a pre-committed metric.
8. **Do code-dev end-to-end FIRST** as the reference adapter; not both subsystems at once.
9. `_axon_rollback.snapshot()` must be wired before any mutation; idempotency/dry-run is a precondition for any `--fix`.
10. **R5 auto-repair + R4 write-half are deferred** until the reconciler is advisory-stable.
11. R1: instantiate canonical workflow at scaffold (cheap, file exists); WARN existing, hard-block new only; validate content not presence.

### Top ranked findings
- **#1 (critical)** Reconciler must be read-only + fail-closed + CONFLICT-HUMAN-EDIT policy documented first. Three classes: CODE-FIRST-DRIFT (git branch, no node → propose scaffold), DAG-AHEAD-OF-GIT (node complete, branch unmerged → propose nothing), CONFLICT-HUMAN-EDIT (node carries non-git-derivable fields that disagree → halt, never auto-resolve).
- **#2 (critical)** `phase_model.done()` is NOT wired to `phase_gate.check()` → the proposed R3 "universal chokepoint" does not exist → R3 = warn/entry-render first.
- **#3 (high)** Real consolidation target = confirmed duplicates: `plan_dag.py` separate DAG.json emitter; `phase_model.stale_downstream` duplicating `dag.cascade_stale`; `workflow_dag.py` registry/test state.
- **#4 (high)** First-run baseline/migration pass missing — reconciler else fires `SCHEMA_VERSION_MISMATCH` on every existing hand-edited DAG.
- **#5 (high)** No idempotency/dry-run/snapshot contract; `_axon_rollback` unwired.
- **#6 (high, contested)** Schema widening: additive (6/7) vs real migrated PR (1/7). → resolved by re-audit (see below): it IS a migrated PR.
- **#7 (med)** R1: instantiate cheaply, never hard-block in-flight, validate content.
- **#8 (med)** Auto-suggested goals risk anchoring bias / goal-quality decay; presence checks can't enforce quality.
- **#9 (med)** Preserve phase/synapse CLI vocabulary across consolidation (adapter translates "node" back).
- **#10 (med)** R4: detection now, write-into-DAG + gating later; fail-open on machine origin.
- **#11 (med)** R5 auto-repair = lowest-value highest-risk → defer behind explicit go/no-go.

### Dissent (preserved)
- [challenger] Cut the `--fix` CODE entirely from v1 (defer code, not just flag). Cut both mandatory gates rather than warn-downgrade.
- [challenger] Validate synapse→node / phase→node compilers round-trip existing nodes (kind:gate, disposition) WITHOUT data loss before adopting the kernel spine.
- [harness-os-architect] Schema widening is NOT additive (closed enums + SCHEMA_VERSION_MISMATCH). — **vindicated by re-audit.**
- [product-program-mgr] Incremental adapter-shim alternative (ship R-items sooner, unify as later cleanup). — owner chose foundation-first.

---

## Step-0 re-verification (Challenger's demand: "do NOT let convergence substitute for re-verification")
Every checkable council claim audited against source 2026-06-24:

| Claim | Verdict | Evidence |
|-------|---------|----------|
| `phase_model.done()` not wired to `phase_gate` | ✅ TRUE | `grep phase_gate phase_model.py` = 0; `done()` (L251) only `_deps_done` |
| `plan_dag.py` emits schema-incompatible DAG.json | ✅ TRUE | `from _axon_io import atomic_write` (L19); `"nodes":[n["id"]…]` id-strings (L157); no schema-version |
| Schema widening NOT additive (1/7 dissent) | ✅ DISSENTER RIGHT | `add_node`/`set_status` raise on unknown kind/status (closed enums L106-109/185-186), build fixed-key dict (drops extras); `verify()` hard-fails SCHEMA_VERSION_MISMATCH (L373) |
| `_axon_rollback.snapshot()` unwired to DAG writes | ✅ TRUE | zero refs in dag.py/phase_model.py/plan_dag.py |
| `stale_downstream` duplicates `cascade_stale` | ✅ TRUE | phase_model.py:335 + dag.py:219 both exist |
| `code-dev.canonical.yml` may be absent | ❌ REFUTED | exists, parseable, 7 synapses → R1 = instantiate |
| `workflow_dag.py` is a dangling pointer | ⚠️ HALF | live (355 lines, in REGISTRY) but no program calls it → orphaned consumer |

---

## Decisions (locked this phase)
- **D-001** Architecture = kernel/adapter (dag.py + goal.py + new reconciler as kernel; phase/synapse adapters compile down).
- **D-002** Sequence = FOUNDATION-FIRST (owner-chosen 2026-06-24).
- **D-003** Reconciler ships READ-ONLY, fail-closed, no `--fix` in v1.
- **D-004** R3 ships warn + auto-suggest + entry-render; no `done()` hard-gate in v1.
- **D-005** Schema widening = a tested + migrated PR (not additive).

## Revised PR sequence (→ becomes the plan/DAG)
Step 0 re-verify (DONE) → 1 invisible refactor (plan_dag→dag primitives; stale_downstream→cascade_stale; workflow_dag registry/test) → 2 widen schema as migrated PR + wire snapshot → 3 one-time DAG baseline pass → 4 READ-ONLY git↔DAG reconciler + CONFLICT-HUMAN-EDIT policy → 5 R3 entry-render + auto-suggest (warn) → 6 R1 instantiate canonical + gate-new-only → 7 R4 write-half (origin-tagged, fail-open machine) → 8 R5 + any --fix behind named go/no-go. Throughout: code-dev end-to-end first; preserve phase/synapse CLI vocabulary.

## Open questions for owner (carried into plan)
1. `--fix` scope: code absent in v1 (challenger) vs flag-guarded + snapshot/idempotency tests (5 seats)?
2. R3 gate-promotion metric + threshold + window (decide before warn-mode begins).
3. CONFLICT-HUMAN-EDIT precedence rule confirmation.
4. Run the one-time DAG normalization pass over existing hand-edited projects?
5. R4 origin source-id requirement + fail-open acceptable interim?

## Sources / provenance
- Deep source audit: 5 parallel agents over `tools/` (dag.py, dag_consistency.py, phase_model.py, phase_gate.py, phase_ledger.py, plan_dag.py, workflow_run.py, workflow_dag.py, goal.py, constraints.py), `workspace/programs/code-dev*.md`, `workspace/programs/workflow-*.md`, `workspace/workflows/*.yml`, `workspace/domains/code-dev/workflows/`, `workspace/schemas/workflow-file.schema.json`, `axon-hr-ui/CODE-DEV-RESYNC.md` + `AUTONOMOUS-FLOW.md` + `03-prs/DAG.json`.
- hr-team council run: workflow `wf_74eaa87f-9d4` (xhigh, 7×3, advisory_only:true), one Round-1 seat dropped on JSON-retry cap, positions present in later rounds.
- Step-0 re-verification: direct source grep/read 2026-06-24.
- Origin artifacts (axon-hr-ui scripts that motivated R1/R2): ship.sh, O1-apply-pr003.sh, O1-core-rule-12-review.sh, O2-stranger-test.sh, councils/_render.py.
