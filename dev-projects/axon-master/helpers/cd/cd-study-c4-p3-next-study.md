# CD·STUDY·C4·P3 — next-study slate (post-R5)

> Where to go after R5 ships. Ranked candidates.

## Candidate next-studies

### NS-1. Study mode quality measurement (`evals`)
**Scope:** how do we know `study --mode=security` is *good*? Define a corpus + golden expected outputs; measure precision/recall over time.
**Why now:** as soon as study modes ship, we want a ratchet.
**Score:** 5/5.

### NS-2. Idempotence + stability of LLM-produced studies
**Scope:** measure 80% idempotence target; tune temperature, prompt structure, retrieval; quantify drift.
**Why now:** without idempotence, `--diff` is noisy.
**Score:** 5/5.

### NS-3. Plan-mode A/B against humans
**Scope:** for a sample project, compare `flow plan --mode=execution` output to a senior engineer's plan. Measure overlap, ordering correlation.
**Why now:** establishes whether plan modes deliver real value.
**Score:** 4/5.

### NS-4. Study cost economics
**Scope:** measure token spend per mode across N codebases. Identify cost-effective modes vs. white-elephant modes.
**Why later:** wait for several modes to be live.
**Score:** 4/5.

### NS-5. `architecture` mode design
**Scope:** Post-MVP mode. Map C4-style architecture descriptions to existing code. Detect architecture-code drift.
**Why later:** depends on T-S2.1..S2.6.
**Score:** 4/5.

### NS-6. Cross-language study coverage
**Scope:** modes were designed Python-first. Validate against TypeScript, Rust, Go, Ruby projects.
**Why later:** ship MVP first.
**Score:** 4/5.

### NS-7. Adaptive token budgeting
**Scope:** today budgets are static per mode. Could be dynamic based on past runs (small repos get smaller budgets, large repos get partials).
**Why later:** depends on accumulated usage data.
**Score:** 3/5.

### NS-8. Plan-quality metrics (cycle time, merged-on-time, churn)
**Scope:** measure quality of plan outputs by downstream PR success.
**Why later:** needs months of data.
**Score:** 3/5.

### NS-9. Study recipe DSL
**Scope:** today recipes are markdown. Could be a tiny DSL with conditionals and parallel steps.
**Why later:** optimize after we have several recipes.
**Score:** 3/5.

### NS-10. Multi-project study (cross-repo)
**Scope:** Study patterns across multiple related repos.
**Why later:** depends on team-mode + multi-project context.
**Score:** 2/5.

### NS-11. Study automation triggers
**Scope:** "auto-run security study when src/auth changes" (event-driven, not just on-demand).
**Why later:** depends on event hooks; tricky in kernel single-shot model.
**Score:** 2/5.

### NS-12. Failure-mode catalog of study (carryover from R4's Study H)
**Scope:** track ways `study` produces bad output; build mitigations.
**Why now:** synergizes with NS-1 and NS-2.
**Score:** 5/5 (but overlap with R4-H).

### NS-13. Pre-flight integration deep-dive
**Scope:** how `pr ready --strict` interacts with study staleness in practice; tune thresholds.
**Why later:** after T-S5.7/S5.8 ship.
**Score:** 3/5.

### NS-14. Plan-as-Negotiation
**Scope:** can plan modes engage user in back-and-forth ("you said no schema changes — but this PR requires one; here are 3 options")?
**Why later:** research-y.
**Score:** 3/5.

## Recommended ordering

```
1. NS-1  Study mode quality measurement (evals)            5/5
2. NS-2  Idempotence + stability                            5/5
3. NS-12 Failure-mode catalog (overlaps R4-H)               5/5
4. NS-3  Plan-mode A/B against humans                       4/5
5. NS-4  Study cost economics                               4/5
6. NS-5  `architecture` mode design                         4/5
7. NS-6  Cross-language coverage                            4/5
8. NS-7  Adaptive token budgeting                           3/5
9. NS-8  Plan-quality metrics                                3/5
10. NS-9 Recipe DSL                                          3/5
11. NS-13 Pre-flight integration deep-dive                   3/5
12. NS-14 Plan-as-negotiation                                3/5
13. NS-10 Multi-project study                                2/5
14. NS-11 Study automation triggers                          2/5
```

## Single best next-study (if forced to pick)

**NS-1 + NS-2 together as a single "study evaluation" workstream.**

Rationale:
- They make every subsequent improvement measurable.
- They are cheap relative to implementing more modes.
- They unblock NS-7 (adaptive budgeting), NS-8 (plan quality), and NS-13.
- They build the discipline of measuring AXON program quality, which carries over to other subsystems (library-dev, etc.).

Second pick: **R4-H (failure modes / postmortems)** still stands; do it in parallel.

## Cross-round dependency graph

```
        R2 (token discipline)
              │
              ▼
        R3 (umbrella names)
              │
              ▼
        R4 (workflow + naming gaps)
              │
              ▼
    ┌─────► R5 (study + plan modes)  ◄─── you are here
    │         │
    │         ▼
    │    NS-1/NS-2 (evals + idempotence)
    │         │
    │         ▼
    │    NS-3..NS-9 (refinements)
    │         │
    │         ▼
    │    R6 (team mode, integrations)
    │
    └── R4-H (failure modes / postmortems) — parallel always-on
```

→ web findings + references for next-study work: `cd-study-c4-p4-web-findings.md`.
