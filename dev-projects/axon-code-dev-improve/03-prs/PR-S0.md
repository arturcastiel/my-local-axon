# PR-S0 — Study-phase entry-render: per-phase GOAL + how-to block (FELT-VALUE SLICE)
> Phase: pr · Status: spec-ready (AXON deliverable; HUMAN implements) · Maps to: G2 root / R3 user-facing half
> Precondition: Cycle-0 boundary spec ratified (`../CYCLE0-kernel-adapter-boundary.md`)
> Foundation-INDEPENDENT · flag-gated · warn-first · reversible · Effort ≈ one sitting

## Objective (relieves the root goal G2)
At study-phase entry, tell the user **what to do and how** — render (1) the phase's declared **GOAL** and (2) a per-phase **how-to-do-the-work block** (what to read · what questions to answer · what to produce), **replacing** the static, OPM-specific hardcoded example currently in `code-dev-study.md`. Warn-first when no goal is set. This is the smallest change that makes every study-phase run better from merge day.

## Where it lives (per Cycle-0 boundary)
`workspace/programs/code-dev-study.md` — the phase-ladder ADAPTER. It READS kernel data; it does NOT modify `goal.py`/`phase_model.py`. No schema, no reconciler, no `axon/` kernel edit.

## Change detail
**File: `workspace/programs/code-dev-study.md`** — replace the static PURPOSE/WORKFLOW/EXAMPLE block (current lines ~177–214, incl. the hardcoded `Goal: Add LGR well summary vectors…` example) with a data-driven entry render:

1. **GOAL line** — read the active project+phase goal from the kernel:
   - `goal ← TOOL(goal, list, "--level phase")` (filter to this project/phase) or `TOOL(goal, get, "--id {phase-goal-id}")`.
   - IF a phase goal exists → render: `Goal (this phase): {goal.statement}` + its acceptance criterion if present.
   - ELSE (warn-first) → `⚠ No goal set for this phase. Define one: code-dev study --mode=goals  (goal-define)` — never block; degrade to the generic how-to below.
2. **HOW-TO block** — a per-phase static template (project-agnostic), selected by phase id. For `study`:
   - **Read:** the target subsystem's entry points + any existing shadow findings (shadow-first).
   - **Answer:** What is the goal? What's in / out of scope? What are the hard constraints? What's still unknown?
   - **Produce:** `01-study.md` — goal + priorities + grounding + open questions.
   (Sibling templates for plan/pr/log/audit may ride here or land in PR-005; study is the felt-pain surface, so it ships first.)
3. **Remove** the OPM/Eclipse-specific hardcoded example (`SummaryConfig.cpp`, `LGR well summary vectors`) — it is noise for non-OPM projects.

**Flag gate:** wrap the new render behind a pref (e.g. `L:code-dev-phase-guidance`, default on) so it is reversible; flag off → prior behaviour.

**OPEN SCOPE (D-016 — owner's call):** whether to ALSO include a static **auto-suggest "what to do next" template** (e.g. `Suggested next: file <entry-point> · define goal · done`). dx-designer (c=0.88): include it — it *completes* the relief. challenger/goals-strategist/delivery-pm: defer to slice 2. **Spec'd here as INCLUDED (recommended)**; if owner chooses render-only, drop sub-section.

## Acceptance criteria
1. Entering the study phase with a phase goal set renders the goal statement (+ acceptance) and the study how-to block.
2. With NO phase goal set, the warn line renders and the how-to block still shows (no block/HALT).
3. No OPM-specific hardcoded text remains in the study entry render.
4. Flag off → byte-identical to prior entry output (reversibility).
5. [if auto-suggest in scope] the auto-suggest block renders the static next-action template.
6. A test (Core Rule 13) asserts: goal-present path renders the goal; goal-absent path renders the warn; the OPM strings are gone.

## Tests (HUMAN runs — AXON does not execute)
`tests/test_code_dev_study_entry_render.py` (or extend an existing study test): assert the render-helper output for goal-present vs goal-absent; assert no `SummaryConfig`/`LGR` literals; flag-off parity.

## Out of scope
goal-id schema field (PR-002); R3 warn + accept-rate metric backend (PR-005); plan/pr/log/audit how-to templates beyond study (PR-005 or follow-up); workflow-adapter equivalent (later, T3). No kernel edit, no DAG mutation.

## Risks
- If `goal.py` has no goal record keyed to a code-dev phase yet, the warn-first path is the norm until goal-define is run — acceptable (still better than today's static text). Confirm the `goal list --level phase` filter resolves a project's phase goal at implementation time.
