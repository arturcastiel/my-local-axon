---
explains:      Phase-3 working rhythm (you ↔ AXON)
audience:      tier-A (you)
last-checked:  2026-05-17
version:       1
---

# Phase 3 — Implementation Guide

> How you and AXON will collaborate to ship the 28 PRs.
> Read this once; refer back per PR.

## The rhythm — one PR at a time

```
   ┌─────────────────────────────────────────────────┐
   │ STEP 1. AXON authors the PR spec                │
   │   File: phases/3-implement/03-prs/pr-NNN.md     │
   │   Format: per _pr-template.md (I-04)            │
   │   Includes: goal, blast-radius, files, rollback │
   └────────────────────┬────────────────────────────┘
                        │
                        ↓
   ┌─────────────────────────────────────────────────┐
   │ STEP 2. YOU review the spec                     │
   │   Say "approve" / name edits / ask questions    │
   └────────────────────┬────────────────────────────┘
                        │
                        ↓
   ┌─────────────────────────────────────────────────┐
   │ STEP 3. AXON implements                         │
   │   Writes the actual files (tools/, programs/,   │
   │   workspace/) per the spec.                     │
   │   For axon/ writes (PR-112 only): dev-mode flip │
   │   requested explicitly.                         │
   └────────────────────┬────────────────────────────┘
                        │
                        ↓
   ┌─────────────────────────────────────────────────┐
   │ STEP 4. YOU verify (kernel rule D-19)           │
   │   Run tests; observe behaviour; rollback if bad │
   │   AXON never runs builds/tests autonomously     │
   └────────────────────┬────────────────────────────┘
                        │
                        ↓
   ┌─────────────────────────────────────────────────┐
   │ STEP 5. AXON writes shadow (D-23 mandatory)     │
   │   File: phases/3-implement/shadow/PR-NNN.findings.md │
   └────────────────────┬────────────────────────────┘
                        │
                        ↓
   ┌─────────────────────────────────────────────────┐
   │ STEP 6. AXON updates trackers                   │
   │   - PR row in 05-branches.md                    │
   │   - changed-files in _files.md                  │
   │   - 04-log.md entry                             │
   │   - DAG.json node status → complete             │
   │   - _demands.md status bump where applicable    │
   └────────────────────┬────────────────────────────┘
                        │
                        ↓
   ┌─────────────────────────────────────────────────┐
   │ STEP 7. YOU say "next" → loop back to step 1    │
   │   OR "pause" / "audit" / "review the chain"     │
   └─────────────────────────────────────────────────┘
```

## Per-PR vocabulary

| You say | AXON does |
|---------|-----------|
| `start pr-NNN` | author spec (step 1); pause for review |
| `approve` | implement (step 3); pause for verify |
| `tests pass` | shadow + tracker updates (steps 5-6); pause for next |
| `next` | start the next PR in critical-path order |
| `pause` | checkpoint state; menu |
| `audit` | run `code-dev safety-audit` against this phase |
| `rollback pr-NNN` | invoke the spec's rollback recipe |
| `show the DAG` | render plan DAG with current statuses |
| `which PR next?` | check critical-path + parallelizable PRs |

## What AXON does autonomously vs not

### AXON-autonomous (permitted per kernel)
- Read any file under axon/, workspace/, my-axon/.
- Write under workspace/ and my-axon/ (no axon/ without dev-mode).
- Commit + push **my-axon/** changes (the workspace-backup permitted op).
- Compute predicates, run validators, render DAGs, write shadows.
- Render menu, footer, suggestions.

### HUMAN-only (kernel rule D-19)
- Run `cmake --build`, `ctest`, `pytest`, `python -m`, `make`, `cargo build`.
- `git push origin main` for the axon repo itself (only my-axon backup
  is autonomous-permitted).
- Flip `L:dev-mode` to true. AXON requests; you confirm.
- Merge / accept PRs upstream.

## The 28-PR plan at a glance

### Critical-path (must land in order — 5 hops)

```
pr-101  glossary → workspace docs        zero-risk, no tests
  ↓
pr-104  neuron-contract schema           low-risk, schema docs
  ↓
pr-107  synapse-infer + synapse-validate medium-high risk (parser)
  ↓
pr-108  domain folder + metadata migrate medium risk (touches 174 programs)
  ↓
pr-117  alias canon + finalize + self-rev medium risk (resolves F-012)
```

### Parallel groups (overlap with critical path)

| Group | PRs | Earliest start |
|-------|-----|----------------|
| Group 1 | pr-102, pr-104, pr-106, pr-110 | after pr-101 |
| Group 2 | pr-103, pr-105, pr-107, pr-113 | after Group 1 starts |
| Group 3 | pr-108, pr-109, pr-114 | after pr-107 + pr-103 + pr-104 |
| Group 4 | pr-111, pr-112, pr-115, pr-120 | after pr-109 |
| Group 5 | pr-116a..f, pr-117, pr-118 | after pr-114 + pr-108 |
| Group 6 | pr-119 | finally (depends on most others) |

For solo work, recommend serializing close to critical-path order to
keep mental model coherent. Parallelization only matters if you'd
otherwise idle.

### Per-PR effort estimate (rough)

| Risk | Typical PRs | Estimated effort |
|------|-------------|------------------|
| low | docs / schemas (pr-101, pr-104, pr-105, pr-106, pr-113, pr-118, pr-119, pr-120) | 1-2 hrs each |
| medium | tools / programs (pr-102, pr-103, pr-107, pr-108, pr-110, pr-114, pr-115, pr-117) | 3-6 hrs each |
| medium-high | new mainlines (pr-109, pr-111) | 1-2 days each |
| risky | kernel-touching (pr-112) | half-day + extra review |
| migration | retroactive shadows (pr-116a..f) | 2-3 hrs per project |

**Realistic timeline for full Phase 3 (solo, focused):** 6-10 weeks.
**Realistic timeline for first useful slice (pr-101..pr-109):** 2-3 weeks.

## What can go wrong + how to handle it

### Spec turns out wrong mid-implementation
**Symptom:** you start coding and realize the spec doesn't account for X.
**Action:** pause, surface as a `_deviations.md` row, propose spec patch.
Don't push through a known-broken spec.

### Existing test fails after a PR
**Symptom:** D-19 violation imminent.
**Action:** revert the file changes immediately; investigate; either
fix the PR or document the necessary test change in the PR with rationale.

### Synapse-infer accuracy below spot-check bar (PR-107)
**Symptom:** parser gets contract fields wrong.
**Action:** pause critical path; fix parser; rerun spot-check. PR-107
re-issues until ≥ 90% on the 20-program sample.

### Ranker hit rate below 70% (PR-109)
**Symptom:** PR-109 ships with poor suggestions.
**Action:** tune `L:ranker-weights` against fixture corpus; document in
_deviations; do NOT proceed to PR-111 until baseline met.

### A PR's blast radius turns out larger than declared
**Symptom:** more files modified than spec said.
**Action:** stop. Either subdivide the PR or update the spec's
blast-radius declaration + re-review.

## Sanity-check questions before saying "next"

After each PR, ask:

1. ✓ Did the existing test suite pass?
2. ✓ Was a shadow file written?
3. ✓ Did `05-branches.md` get the PR's row?
4. ✓ Did `_files.md` register all changed paths?
5. ✓ Did `04-log.md` get an entry?
6. ✓ Did the DAG status flip to `complete`?
7. ✓ Backup pushed? (commit visible at origin/main)
8. ✓ Any new flaws surfaced → row added to `_flaws.md`?

If any answer is no, don't say "next" — say "complete pr-NNN" so AXON
catches up the tracker.

## When to stop / pause

- **End of day** — say "pause"; everything checkpoints to W:active-phase.
- **End of critical-path** (post pr-117) — natural review milestone.
- **Test regression** — immediate halt; diagnose.
- **Anything feels off** — pause + ask. The plan is a guide, not a rail.

## Acceptance for Phase 3 close

When all 28 PRs are `🟩 merged`:
- Existing test suite passes (D-19 ✓)
- ≥ 80 % synapse-contract coverage (D-6 ✓)
- 100 % shadow coverage (D-23 ✓)
- 5 reference workflows ship + validate (D-9 ✓)
- workflow-new fixture test passes 3/3 (D-28 ✓)
- `_flaws.md` shows zero new 🟥 rows for Phase 3 cohort

Then: `code-dev safety-audit` → Phase 3 closes → Phase 4 (validation) opens.

## First action

Open `phases/3-implement/03-prs/pr-101.md` — the spec is ready for your review.
Once approved, say "approve" and AXON ships the file changes.
