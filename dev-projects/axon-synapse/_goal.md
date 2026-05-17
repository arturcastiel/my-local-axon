# Project goal — axon-synapse

> Per D-007: goals always exist. This file is the authoritative project-level goal.
> Sub-goals live per-phase in `phases/{n}/_meta.md` `goal:` field (to be added in Phase 2).

## Stated by user (2026-05-17, AXON Synapse kickoff + clarifications M2..M6)

Transform AXON from a fixed-hierarchy program runner into a **domain-agnostic
workflow OS** with adaptive synapse orchestration. Code is one domain; science
and study domains follow without re-architecting the kernel. Existing code-dev
hierarchy is preserved, not replaced. The new layer:

1. **Audits** every existing tool (69) and program (174) — what works, what is
   redundant, what is dead, what is missing.
2. Treats each program as a **synapse** with declared
   precondition / post-state / next-conditional.
3. **Identifies the user's task** from natural input, **dispatches** the right
   synapse, **observes** the resulting state, **re-routes** adaptively — instead
   of forcing the user through a fixed hierarchy.
4. Ships an **auto-DAG** that is created on every plan and **mutated** on every
   merge / split / fold-in operation.
5. Ships a **workflow generator** that composes new workflows from the synapse
   graph for goals it has not seen before.
6. **Always tracks a goal** — workflow-bound goals are pre-defined per workflow;
   open-ended goals are user-stated with AXON-infer + confirm fallback.
7. **Suggests tools / next-steps** continuously based on goal + current state +
   recent history. Suggestions reduce the gap between user intent and the right
   program. "After implementing X → suggest self-review" is one example of
   thousands of conditional suggestions.

## Acceptance — when is this project done?

- ✓ Findings catalog complete for every program + every tool (Phase 1).
- ✓ Synapse contract spec'd; inference engine seeded for ≥ 80 % of programs (Phase 2 + 3).
- ✓ DAG is central at every level — project, phase, plan, PR, study (D-009).
  Every level has `DAG.json` + `DAG.md` sync-checked. Nested DAG consistency
  enforced (child nodes ↔ parent edges).
- ✓ Auto-DAG fires on every `code-dev plan`. DAG mutates on every
  merge / split / fold-in / defer / cut operation. Mutation is reversible
  (before/after logged).
- ✓ Goal ledger live (D-007); no dispatch path bypasses goal-existence check.
  Workflows carry `default-goal:`; ad-hoc work prompts for goal + AXON-infer-confirm.
- ✓ Suggestion engine (D-010) surfaces ranked candidates on every program
  completion, on state delta, and on free-text input. Suggestions are
  predetermined-or-ephemeral; ephemeral promotes after ≥ N accepts.
- ✓ Shadowing (D-011) is mandatory and enforced — every source-touching PR
  has a shadow file; `code-dev audit` FAILs if absent.
- ✓ Workflow generator composes a viable workflow for at least 3 novel goals
  in user testing.
- ✓ Phase 4 retro shows measurable drop in "manual program lookup" frequency
  (proxy: `tools/usage.py find-program` invocations per session).

## Non-goals (this project)

- Replacing AXON's identity contract, language gate, or compliance enforcement.
- Building a learning/ML ranker — Phase 3 ranker is rule-based + frequency priors.
- Building a UI beyond markdown output and footer/menu integration.
- Refactoring or renaming any existing `code-dev-*` program (D-014 / D-025).
- Hardcoding code-specific concepts into kernel primitives. All primitives —
  workflow, synapse, domain, project, phase, goal — must be domain-agnostic
  per D-015 / D-026. Code-dev is one domain; future domains (science-dev,
  study-dev) plug in without kernel changes.
