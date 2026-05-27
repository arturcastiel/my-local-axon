# Plan — 2-design  ·  axon-synapse

> glossary: SYNAPSE-GLOSSARY v1
> resolves: Phase 2 design queue from synthesis-draft.md
> outputs: 02-prs.md, 03-prs/DAG.json + DAG.md, 03-prs/PR-NNN.md per PR

## Goal (Phase 2)

Produce **9 signed-off design specs** sufficient for Phase 3 to ship the
synapse OS without revisiting design questions. ✅ DONE this turn:

| # | Spec | Status |
|---|------|--------|
| 1 | SYNAPSE-GLOSSARY.md | ✅ |
| 2 | synapse-contract-v1.md | ✅ |
| 3 | workflow-file-v1.md | ✅ |
| 4 | goal-schema-v1.md (incl. predicate language v1) | ✅ |
| 5 | domain-manifest-v1.md (+ code-dev + library-dev reference manifests) | ✅ |
| 6 | dag-spec-v1.md (5 levels + sync) | ✅ |
| 7 | orchestrator-composition-v1.md | ✅ |
| 8 | shadow-enforcement-v1.md | ✅ |
| 9 | conversational-author-v1.md | ✅ |
| 10 | migration-plan-v1.md (Phase 3 PR sequencing) | ✅ |

All specs cite `SYNAPSE-GLOSSARY v1`. All specs respect:
- **D-014 / D-025** — code-dev hierarchy preserved.
- **D-015 / D-026** — kernel-level abstractions are domain-agnostic.
- **D-019** — no tests break (CI gate per migration-plan).
- **D-005** — hybrid inferred + declared contract authoring.

## Phase 2 → Phase 3 hand-off summary

### Three pillars of the design

1. **Synapse contract** = the metadata that turns each program/tool into a
   ranker-visible, predicate-checkable, composable unit. Authored once
   (inferred by `synapse-infer`, overridden by hand where needed). Lives
   in synapse file headers (programs) or REGISTRY entries (tools).

2. **Workflow file** = the DAG of synapses representing a goal-bearing
   sequence. Two execution modes (Fixed/Adaptive) + Hybrid. Sideband +
   deviation suggestions live in Fixed. Authored directly OR via
   conversational `workflow-new --from-description`.

3. **Orchestrator** = composition over existing tools (mode-detect,
   dispatch, pattern, usage, drift, events, context) + new synapse-suggest
   combiner. Reads state + goal + history; ranks; fires; observes; loops.

### Five infrastructure subsystems

1. **Goal schema** (per goal-schema-v1) — every level carries goal records.
   Predicate language is shared with synapse `precondition`/`post-state`
   and workflow `acceptance`.

2. **Domain manifest** (per domain-manifest-v1) — every domain (code-dev,
   library-dev, future) carries a manifest at
   `workspace/domains/{name}/manifest.md`. Container conventions, workflows,
   verb-map, default-goals.

3. **DAG at 5 levels** (per dag-spec-v1) — project / phase / plan / PR /
   study. `DAG.json` canonical, `DAG.md` auto-rendered, `dag-sync`
   validates nested consistency.

4. **Shadow enforcement** (per shadow-enforcement-v1) — five enforcement
   gates from synapse contract through to project audit. Retroactive
   migration on 119 existing PRs is a single one-shot PR.

5. **Conversational author** (per conversational-author-v1) — dialog flow
   producing workflow files; reuses orchestrator's ranker for suggestions
   inside the dialog itself.

## Why we shipped this much in Phase 2

Per D-008 (most detailed, no cap) + D-015 (workflow-OS generalization
demands precise vocabulary) — anything less and Phase 3 would have to
revisit schemas mid-stream. Each spec is independently audit-traceable
to the Phase 1 finding(s) that motivated it.

## Phase 3 entry conditions

Phase 3 may start when:

- ✅ All 10 specs exist + non-stub.
- ✅ Glossary v1 fixed (no further vocabulary drift).
- ⏳ User sign-off on the 10 specs (or accepts revisions).

## What Phase 3 ships (per migration-plan-v1)

**20 PRs** sequenced by dependency, summarised in `02-prs.md` and graphed
in `03-prs/DAG.{json,md}`. PR roster (full table in 02-prs.md):

1. PR-101 glossary → workspace
2. PR-102 predicate tool
3. PR-103 goal tool + schema
4. PR-104 synapse-contract schema
5. PR-105 workflow file schema
6. PR-106 domain manifest + code-dev/library-dev reference manifests
7. PR-107 synapse-infer + synapse-validate tools
8. PR-108 domain folder scaffold + metadata migration
9. PR-109 synapse-suggest tool (orchestrator composition)
10. PR-110 DAG spec + dag tool + sync
11. PR-111 orchestrator loop (program)
12. PR-112 output-layer suggestions section (dev-mode-gated)
13. PR-113 plan_dag auto-emit hook
14. PR-114 shadow enforcement gates
15. PR-115 workflow-new conversational author
16. PR-116 shadow retroactive bulk migration
17. PR-117 alias canonicalization + finalize stub + self-review collision
18. PR-118 reference workflows ship
19. PR-119 axon-audit extension
20. PR-120 igap + auto-improve wire to synapse-suggest

Phase 4 (post-1.0):
- PR-150 study-dev domain (D-26 second-domain proof)
- PR-151 cross-domain workflow examples
- PR-152 ranker tuning from lived data
- PR-153 workflow-compile (perf)

## Demands roll-up post-Phase-2

Status changes this phase (per `_demands.md`):

| Demand | Phase 1 status | Phase 2 status |
|--------|--------------|----------------|
| D-2 auto-DAG on plan | ⬜ | 🟨 designed (dag-spec-v1, migration-plan PR-113) |
| D-3 DAG auto-mutation | ⬜ | 🟨 designed (dag-spec-v1 mutator API) |
| D-4 DAG central nested | ⬜ | 🟨 designed (dag-spec-v1 5 levels + sync) |
| D-6 synapse contract | ⬜ | 🟨 designed (synapse-contract-v1) |
| D-7 adaptive orchestrator | ⬜ | 🟨 designed (orchestrator-composition-v1) |
| D-8 workflow generator | ⬜ | 🟨 designed (conversational-author-v1) |
| D-9 pre-built workflows | ⬜ | 🟨 designed (reference workflows in PR-118) |
| D-10 goals per step | 🟨 | 🟨 designed (goal-schema-v1) |
| D-11 suggest by goal+wf | ⬜ | 🟨 designed (orchestrator composition formula) |
| D-12 pop-up questions | ⬜ | 🟨 designed (decide() function) |
| D-13 after-action suggest | ⬜ | 🟨 designed (next-conditional) |
| D-14 hierarchy + suggest | ⬜ | 🟨 designed (sideband + deviation) |
| D-16 post-impl chain | ⬜ | 🟨 designed (python-code-dev workflow) |
| D-17 adjust per project | ⬜ | 🟨 designed (domain manifest verb-map) |
| D-18 infer-or-pick wf | ⬜ | 🟨 designed (workflow-new + workflow run) |
| D-20 auto-discoverable tools | ⬜ | 🟨 designed (synapse contract + register-tool reload) |
| D-22 pseudo-FSM | 🟨 | 🟨 still designed (D-013 / orchestrator loop) |
| D-23 shadow enforced | ⬜ | 🟨 designed (shadow-enforcement-v1) |
| D-26 workflow OS | 🟦 | 🟨 designed (domain manifest + glossary) |
| D-27 register new synapses | 🟦 | 🟨 designed (register-tool + reload) |
| D-28 conversational author | ⬜ | 🟨 designed (conversational-author-v1) |
| D-29 fixed/adaptive modes | 🟨 | 🟨 designed (workflow file `execution-mode`) |
| D-30 suggest in fixed mode | 🟨 | 🟨 designed (sideband + deviation semantics) |

**21 demands moved to 🟨 designed.** Remaining: 5 in-progress (continuous
governance / Phase 4 deliverables), 4 open (Phase 4 / measurement targets).

## Risks remaining for Phase 3

1. **Synapse-infer accuracy** — parser quality determines whether the
   hybrid inferred-first migration actually scales. Mitigation: PR-107
   includes a manual spot-check pass on 20 programs.
2. **Ranker quality** — D-21's 90 % top-1 hit is a Phase 4 target; PR-109
   ships with a relaxed 70 % bar.
3. **Orchestrator stability** — PR-111 adds a new mainline; integration
   testing must cover both modes thoroughly.
4. **Output-layer change** — PR-112 is the single kernel-touching PR;
   blast radius is the whole footer. Mitigation: feature-flag
   `L:suggestions-enabled`.
5. **Shadow migration scale** — 119 PRs across 6 projects. Mitigation:
   PR-116 ships dry-run + `code-dev-undo` rollback.

## Sign-off form

User says "go" (or "ship Phase 3") → run `code-dev pr-create` on PR-101 first
(per migration-plan dependency order).
User says "stop" or names changes → revise specs first; rerun
`code-dev plan` after.
