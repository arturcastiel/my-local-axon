# CD·STUDY·C4·P1 — synthesis

> Round 5 condensed: where study + plan stand today vs. where they should go.

## The four findings, one screen

```
┌────────────────────────────────────────────────────────────────┐
│ L1 — study modes (today: 1, proposed: 14)                       │
│      overview only → +13 modes (subsystem, security, perf, …)   │
├────────────────────────────────────────────────────────────────┤
│ L2 — workflows (10 named WF-S1..WF-S10, today none runnable)    │
│      20 gaps; top-10 close in Wave S1                           │
├────────────────────────────────────────────────────────────────┤
│ L3 — plan modes (today: 1 implicit, proposed: 10)               │
│      execution + risk-first / budgeted / constrained / replay   │
│      / multi-dev / cost / alignment / exploratory / dry         │
├────────────────────────────────────────────────────────────────┤
│ L4 — output discipline: 01-study.md monolith → study/ folder    │
│      _index.md, staleness, multi-file, checkpoint               │
└────────────────────────────────────────────────────────────────┘
```

## The 20 gaps re-ranked (consolidated)

| # | Gap (short) | Score | Wave |
|--:|-------------|------:|------|
| 1 | mode flag on `study` (G-S1) | 5.0 | S1 |
| 2 | multi-file output (G-S7) | 5.0 | S1 |
| 3 | _index.md (G-S8) | 4.0 | S1 |
| 4 | --target (G-S2/G-S19) | 4.0 | S1 |
| 5 | staleness (G-S11) | 3.0 | S1 |
| 6 | plan --budget (G-S14) | 3.0 | S1 |
| 7 | plan --rule (G-S13) | 3.0 | S1 |
| 8 | --output engineering/executive (G-S20) | 3.0 | S1 |
| 9 | --input (G-S4) | 3.0 | S1 |
|10 | suggest-next (G-S9) | 2.0 | S4 |
|11 | --diff (G-S3) | 2.0 | S4 |
|12 | --budget on study (G-S6) | 2.0 | S1 |
|13 | recipes (G-S5) | 2.5 | S4 |
|14 | checkpoint/resume (G-S10) | 1.5 | S4 |
|15 | replay plan-mode (G-P7) | 1.5 | S3 |
|16 | history mode (G-S17) | 2.0 | S2 |
|17 | dataflow mode (G-S16) | 1.3 | S5 |
|18 | tests coverage delta (G-S18) | 1.3 | S2 |
|19 | plan-from study folder (G-S12) | 1.7 | S1 |
|20 | dry-run plan (G-P10) | 3.0 | S3 |

## Targets (precise, measurable)

### T-1. Study folder convention shipped
**Definition:** every project has `study/_index.md`. Old `01-study.md` becomes auto-composed view.
**Done when:** axon-master migrated; `code-dev knowledge study --mode=overview` writes `study/overview.md` and updates `_index.md`.

### T-2. Mode flag on study
**Done when:** `code-dev knowledge study --mode=<m>` accepts at least: overview, subsystem, security, dependencies, tests, history.

### T-3. Plan modes
**Done when:** `flow plan --mode=<m>` accepts at least: execution (default), risk-first, budgeted, constrained, replay, dry.

### T-4. Recipes
**Done when:** at least 3 recipes ship and run end-to-end (`new-repo-onboarding`, `pre-release-audit`, `refactor-prep`).

### T-5. Integration with `state next`
**Done when:** `code-dev state next` reads `study/_index.md` and surfaces stale or missing modes.

### T-6. Integration with `pr ready`
**Done when:** `pr ready N` warns (and `--strict` blocks) on stale studies relevant to PR-N's touched files.

### T-7. Documentation
**Done when:** `workspace/AXON-DOCS-STUDY.md` describes all study modes, all plan modes, and the 7 recipes.

## Sequencing summary (releases)

```
Release α  → S0 plumbing + S1 core (T-1, T-2 partial, T-3 partial)
Release β  → S2 additional study modes + S3 plan modes (T-2, T-3)
Release γ  → S4 recipes + suggest-next + diff + checkpoint (T-4, T-5)
Release δ  → S5 niche modes + integrations (T-6)
Release ε  → S6 polish + docs (T-7) + 01-study.md redirect removed
```

α and β each ship measurable user value. γ unlocks "guided workflows".

## Headlines (in plain English)

1. **Today `study` is one button.** It should be 14 buttons sharing a chassis.
2. **Today `plan` has no modes.** It should have 10; default behavior unchanged.
3. **Today no surface tracks "what's been studied".** A small `_index.md` fixes this.
4. **Today nothing warns "study is stale".** `pr ready` should.
5. **Today recipes don't exist.** 7 named recipes cover 90% of common cases.
6. **Today the `01-study.md` monolith is brittle.** A `study/` folder breaks it up.
7. **Today `plan-master` is a separate program.** Should fold into `plan --epic`.
8. **Today `suggest-next` doesn't exist.** Easy heuristic adds it.

## Cross-round alignment

| Round | Closes which R5 items                                          |
|-------|----------------------------------------------------------------|
| R2    | Token discipline (study/plan outputs must respect cap)         |
| R3    | Verb-umbrella naming (`knowledge study`, `flow plan`)          |
| R4    | `pr ready` gating, `state next`, `meta board`, `safety preflight` |
| R5    | Study modes + plan modes + recipes + _index.md                 |

## What R5 does NOT solve

- Team-mode multi-actor studies (deferred to a separate study).
- Network-fed inputs (still HUMAN-runs scanners → pastes JSON).
- Real-time IDE indexing (out of scope).
- LLM cost prediction precision (heuristic only).

→ Concrete next-study slate: `cd-study-c4-p3-next-study.md`.
