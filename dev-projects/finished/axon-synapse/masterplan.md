# Masterplan — AXON Synapse

## Vision

> Every AXON program is a synapse. AXON is the orchestrator.
> Goals drive every step. Tools are suggested based on user activity,
> declared goals, and the current workflow. Workflows are generated,
> not hand-authored.

## Phase graph (directed)

```
1-study  →  2-design  →  3-implement  →  4-validate
  ✓             ✓            ACTIVE           ⬜
  17 findings  11 specs +   28 PRs            retros +
  + 30 demands 28-PR plan   pr-101 spec       ranker tuning +
  + synthesis  + plan DAG   ready for review  second-domain proof
               + 9 docs +
               flaws-fixed
```

- **1-study** — full audit of axon/ + workspace/programs/ + tools/REGISTRY
  + my-axon/ usage patterns. Output: findings index, tool-graph, workflow catalog,
  goal-derivation, redundancy map, gap map.
- **2-design** — codify goal-of-each-step (study/project/plan/PR/code/audit),
  define the synapse contract (declared inputs/outputs/post-state per program),
  spec the auto-DAG + DAG-mutation API, spec the workflow generator,
  spec the suggestion engine.
- **3-implement** — PR series rolling out: per-program synapse contracts,
  auto-DAG on plan creation, DAG mutation on merge/split, workflow generator,
  goal-tracking ledger, suggestion engine, "after-X → suggest Y" rule registry.
- **4-validate** — measure: did goal-attainment improve, did time-to-next-step
  drop, did the suggestion engine reduce manual program lookups, did auto-DAG
  catch drift? Retros + health-score targets.

## Non-goals (Phase 1)

- No code changes to axon/ this phase (dev-mode OFF).
- No new programs written this phase; only `01-study.md` populated.
- No DAG implementation work yet — only DAG **requirements** from study.

## Phase progression

Phases are added by: `code-dev phase new`.
First phase `1-study` is scaffolded — run `code-dev study` to populate `01-study.md`.
