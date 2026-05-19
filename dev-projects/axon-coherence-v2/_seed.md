# axon-coherence-v2 — Seed Audit

slug:            _seed
schema-version:  v4
authored:        2026-05-19
predecessor:     axon-autoimprove
seed-source:     phases/4-validation/01-residual-triage.md (axon-autoimprove)

## Why this project exists

Two phase-3-exit residual flaws share a root cause: **structural relationships across the program/neuron/FSM graphs are not statically validated**. Each bug is small in isolation, but together they form a pattern that PR-AUTO-212 (R_TOOL_CALL_EXISTS) already proved is worth catching at lint-time.

## Inherited flaws

### FA-22 — code-dev FSM transitions are unguarded

From `axon-autoimprove/phases/1-study/02-deep-audit.md` § 5.3:

> code-dev pseudo-state-machine transitions are unguarded — any subcommand from any state

`code-dev.md` is the only multi-state program shipped today. It has implicit states (`study → plan → build → validate → closure`) but the dispatch from any of its subcommands (`code-dev-state-save`, `code-dev-state-resume`, etc.) doesn't check whether the current state allows the transition. Invalid transitions silently corrupt the project's recorded state.

Audit's recommended scope: declare an explicit transition table; build a rule that walks the program's INSERT/UPDATE of project state files and rejects transitions not in the table.

### FA-23 — synapse-validate accepts unknown neurons

From the same audit (B-17):

> synapse-validate silently passes references to unknown neurons

The synapse graph (`workspace/neurons/*.md`) and the `synapse-validate` tool form a referential system: every `→ {neuron-name}` arrow in a `.md` program should point at an existing neuron. Today, dangling references pass validation. Same diagnostic shape as the broken-TOOL-call bugs caught by PR-AUTO-212.

## Inherited substrate (already merged)

- **PR-AUTO-212 (R_TOOL_CALL_EXISTS)** — the static-lint pattern this project extends. Cycle: AST-walk → check against canonical declaration → block with difflib hint on mismatch. Sibling files in `tools/rules/`.
- **Rule registry** at `tools/rules/registry.py` — adding new rules is a 1-line registration.
- **`tests/test_rules/`** — test-per-rule convention enforced by `test_rules_meta.py`.

## Open design questions for phase-1

1. **Where do FSM transition tables live?** Three candidates:
   - Frontmatter in `code-dev.md` itself (closest to the source of truth, but harder to lint).
   - Separate `workspace/fsm/<program-slug>.json` (clean separation, but adds a new tracked-state surface).
   - In-`tools/rules/` Python constants (fast to lint, but couples the rule and the program).
2. **What's the canonical neuron registry for FA-23?** Today neurons are scattered as `workspace/neurons/*.md` files; the rule could glob the directory at lint-time and use that as the registry. Faster than building a separate index file.
3. **Should cycle detection in suggestion graphs ride along?** D-A26 hinted at "ranker shouldn't recursively recommend itself". Could be a third rule (`R_SUGGESTION_CYCLE`). Decide in phase-1 whether it's in or out.

## Out of scope

- Building a general-purpose graph database for axon (overkill; the static-lint approach proven by PR-AUTO-212 is enough).
- Migrating existing single-state programs to declare an FSM (each program opts in; no forced refactor).

## Entry condition

Start phase-1 study after:
1. `axon-autoimprove` reaches `_closure.md`.
2. At least one user-reported FA-22 incident or FA-23 false-positive lands — otherwise the priority is dispatch ranker (`axon-ranker-v2`) which has visible user impact.

Until then: status `proposed`.
