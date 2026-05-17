# F-005: No tool today declares precondition / post-state — synapse model requires migration spec

**Severity:** high
**Track:** T-A
**Date:** 2026-05-17

## Evidence

`tools/REGISTRY.json` schema fields per tool entry:

```
{
  "script": "...",
  "status": "ACTIVE | OPTIONAL",
  "category": "...",
  "purpose": "..."
}
```

No fields express:

- `precondition:` — what state must hold before invoking this tool.
- `post-state:` — what state becomes true after invoking.
- `inputs:` — required W:/L: keys, files, args.
- `outputs:` — artifacts produced, W: keys written, side-effects.
- `next-conditional:` — what tools / programs naturally follow this one.
- `cost:` — token / time / risk budget.

Program-side, `workspace/programs/*.md` headers declare `# desc:`, `# usage:`,
`# inputs:`, `# outputs:`, `# next:` — but only for some programs, and the
`# next:` value is a fixed string (e.g. `"code-dev plan"`), not a conditional.

## Why this matters for the synapse model

The orchestrator loop in D-003 / `_goal.md` requires:

```
candidates ← RANK(synapses, by=fit(state, goal, history))
```

`fit()` needs:

1. **Precondition match.** Is current state compatible with this tool's
   precondition? Without a declared precondition, the ranker can only guess from
   the purpose string.
2. **Post-state advance.** Does this tool's post-state move closer to the goal?
   Without a declared post-state, the ranker can only guess.
3. **Branching next.** What follows this tool depending on outcome? Without
   `next-conditional`, suggestion is hard-coded by program author at best.

Without these fields, **the synapse model cannot operate** beyond the simplest
"after X always suggest Y" pattern that today's `# next:` already provides.

## Implication for Phase 2 / Phase 3

This is the single most blocking design decision for the project. Without a
synapse-contract schema:

- D-005 (hybrid inferred + declared) has no target shape.
- D-010 (suggestion firing) has no machine-readable predicate to evaluate.
- D-006 / D-009 (DAG centrality) lacks node-level metadata to compose graphs from.

## Suggested action

- **Phase 2 design Q (BLOCKER).** Define the synapse-contract schema. Candidate
  shape:

```yaml
synapse:
  name: code-dev-plan
  family: code-dev
  precondition:
    - state: phase.has(01-study.md, "populated")
    - state: project.dev-mode == false  # or anything
  inputs:
    - W:code-dev-project
    - file: phases/{phase}/01-study.md
  outputs:
    - file: phases/{phase}/02-plan.md
    - file: phases/{phase}/02-prs.md
    - file: phases/{phase}/DAG.json
  post-state:
    - phase.has(02-plan.md, "populated")
    - phase.has(DAG.json)
  next-conditional:
    - if: count(prs) > 0
      suggest: [code-dev pr 1, code-dev shadow]
      confidence: 0.9
    - if: count(prs) == 0
      suggest: [code-dev study --revisit]
      confidence: 0.7
  cost:
    tokens-estimate: 2000
    duration-estimate: 90s
  goal:
    advances: "produce-verifiable-pr-set"
```

- **Phase 3 PR seed.** `synapse-infer` tool — parse a program/tool, emit the
  contract above. `synapse-validate` tool — assert declared contract matches
  observed behaviour on a corpus of past runs.
