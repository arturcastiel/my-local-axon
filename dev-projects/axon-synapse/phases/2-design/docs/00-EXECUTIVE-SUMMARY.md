---
explains:      project axon-synapse (whole)
audience:      tier-A
last-checked:  2026-05-17
version:       1
---

# axon-synapse — Executive Summary

## Vision

Turn AXON from a fixed-hierarchy program runner into a **domain-agnostic
workflow OS** with adaptive orchestration. Code-dev is one domain; science,
study, library work follow without kernel changes. Programs are **neurons**;
weighted edges between them are **synapses**; the orchestrator (the
project's namesake **axon**) carries signals between them.

Every step has a **goal** with a measurable acceptance predicate. Workflows
run **Fixed** (declared path) or **Adaptive** (orchestrator picks each
step), or **Hybrid**. Suggestions stay live in both. The user can **register
new neurons** at runtime and **author new workflows conversationally** by
describing them in plain English.

## Where we are (2026-05-17)

| Phase | Status | Output |
|-------|--------|--------|
| 1-study | ✓ complete | 17 findings · 30 demands · synthesis-draft · 6 helpers |
| 2-design | ✓ ready-for-signoff | 10 specs (v1.1) · 02-plan · 02-prs · plan-DAG · docs corpus |
| 3-implement | ⬜ pending | 25 PRs sequenced (PR-101..120 + PR-116a..f + PR-130..132) |
| 4-validate | ⬜ pending | second domain · ranker tuning · workflow-compile |

Confidence: **0.94 weighted** across six axes (direction / consistency /
empirical / rigor / risk / audit). Real flaws found and fixed in
the remediation pass; remaining flaws are tracked in `_flaws.md` (zero
hidden risk).

## Headline insights from Phase 1

1. **AXON's kernel is already domain-agnostic.** Library-dev exists as a
   non-code workflow on the same kernel — proof, not promise.
2. **The orchestrator is composition, not greenfield.** mode-detect,
   dispatch, pattern, usage, drift, events — already shipping. Phase-3
   adds the combiner + the suggester surface.
3. **Workflow programs ALREADY EXIST.** 36+ in code-dev family (review,
   audit, test, shadow, etc.). Phase 3 wires the synapse contract;
   doesn't author new programs.
4. **Shadow coverage is 0% across 119 PRs** despite the tool being
   production-quality. Mandatory shadow enforcement (D-23) is critical.

## Headline design choices (Phase 2)

1. **Synapse contract is hybrid** — inferred by static analysis,
   overridden by author. No 174-program hand-authoring sprint.
2. **DAG is central at 5 levels** — project, phase, plan, PR, study.
   JSON canonical; MD rendered one-way.
3. **Goals always exist** — workflow-bound for known paths, user-stated
   (with AXON-infer + confirm) for ad-hoc.
4. **Fixed vs Adaptive vs Hybrid + Exploratory + Scheduled** execution
   modes — each declared per workflow.
5. **Biology-correct vocabulary** (v2 glossary) — neuron / synapse /
   axon mapped to nodes / edges / orchestrator.

## Phase-3 critical path (5 hops)

```
pr-101 (glossary docs)
  → pr-104 (neuron-contract schema)
    → pr-107 (synapse-infer + validate)
      → pr-108 (domain folder + metadata migration)
        → pr-117 (alias canonicalization + finalize + self-review)
```

All other PRs parallelize. Total: 25 PRs.

## Top 5 risks

1. **Ranker quality.** PR-109 ships at 70% top-1 hit; below 75% real-world
   users disable suggestions. Measurement infrastructure is in place
   (`dispatch-stats`).
2. **Synapse-infer accuracy.** 174 programs auto-migrated; failures
   require hand-authoring. Mitigated by D-020 hybrid + manual spot-check
   in PR-107.
3. **Cost.** Every orchestrator loop = a model call. Compiled-workflow
   cache (Phase 4 PR-153) is the answer if cost compounds.
4. **Single-author bias.** Architecture reflects your mental model.
   `study-dev` domain (Phase 4) is the generalization test.
5. **Self-application avoidance.** Risk of building the OS instead of
   using it. Counter: dogfood Phase-3 work on this very project.

## Next move

1. **You**: read this doc + `01-CONCEPT-MAP.md` + `02-ARCHITECTURE-AT-A-GLANCE.md`
   to confirm internal mental model matches what shipped.
2. **You**: say `start PR-101` to begin Phase 3, OR direct further
   tightening.
3. **AXON**: if asked, ships Phase 3 PRs in critical-path order, pausing
   at PR-112 (dev-mode flip required).

## One-sentence summary

> *"AXON is a workflow OS where each tool is a neuron with declared
> connections to its likely successors, and the orchestrator routes
> signals between them goal-first, observable-state-second,
> user-controllable always."*
