# Phase: 3-implement
schema-version: v4
status:         active
workflow-step:  implement
branch:         main
current-pr: pr-108
updated:        2026-05-17
created:        2026-05-17

## Goal (per goal-schema-v1.1)
Statement:    "Ship all 28 PRs in the v1.1 migration plan such that:
               (a) every existing test passes, (b) synapse-contract
               coverage ≥ 80 %, (c) shadow.coverage == 100 % across all
               projects, (d) ≥ 5 reference workflows validated, and
               (e) workflow-new --from-description produces a valid
               workflow on 3 fixture descriptions."

Measurement:
  - existing test suite green every PR
  - synapse-contract coverage ≥ 80% (D-6 / D-20)
  - shadow.coverage == 100% (D-23)
  - 5 reference workflows shipped + validated (D-9)
  - workflow-new fixture test passes 3/3 (D-28)

Acceptance:   ∀ PR ∈ pr-101..pr-120 + pr-116a..f + pr-130..132 → status: merged
              AND every measurement above holds.
Rejection:    Any PR causes existing-test-suite regression (D-19).
              OR  Ranker top-1 hit rate falls below 70% (D-21 minimum bar).

## PR roster (28 total)

Critical-path (5 hops):
  pr-101 → pr-104 → pr-107 → pr-108 → pr-117

Parallel groups: see phases/2-design/03-prs/DAG.md § Parallelization.

## Working Context
- Phase 2 closed with 11 specs + 13 ADRs added + 6 improvement artifacts.
- Phase 3 ships per migration-plan-v1.1.
- AXON authors PR specs + file changes; HUMAN runs tests + verifies + merges.
- dev-mode required for PR-112 only; all other PRs land under workspace/
  or my-axon/ without dev-mode.
- Per-PR workflow: spec → review → implement → test (human) → shadow →
  audit → merge.
