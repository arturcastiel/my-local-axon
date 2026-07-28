---
tags: [code, file]
path: workspace/programs/code-dev-next.md
---

# workspace/programs/code-dev-next.md

> 43 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `1. Branch drift`
- `10. Catch-all`
- `2. Stale session marker (>2h) or absent`
- `3. Open objections on the active PR`
- `4. workflow-step = merged → cascade`
- `5. workflow-step = frozen → no-op`
- `6. Shadow stale > 5 items`
- `7. re-implementing without active draft → preflight`
- `8. build + spec exists + diff exists → review`
- `9. No PR active in phase`
- `After PR-9.6 cache miss, surface stale studies + in-progress PRs.`
- `CACHED NEXT-ACTION (PR-9.6 — T-C2)`
- `Cap = 2 candidates. Opt-out via `--no-study-suggest`.`
- `HELP`
- `IDENTITY LOCK`
- `INTEGRATION SIGNALS (PR-25.5 — T-S1.12)`
- `OUTPUT`
- `PROGRAM: code-dev-next`
- `SIGNALS`
- `TEN MOMENTS — first match wins`
- `budget:`
- `cache-prefix: 1024`
- `code-dev-next.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Suggest the single most-relevant next command for the current state ("10-moment classifier")`
- `dispatch-phrases: what should I do next · suggest the next action · pick the next task · what is the next step`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    4000`
- `inputs-count: 5`
- `inputs:  project state (_meta, log markers, reviewer state, git, shadow)`
- `invocation_source: [program]`
- `next-suggests: [code-dev-state-status, code-dev-plan]`
- `output-cap:   800`
- `outputs-count: 2`
- `outputs: one line — the recommended next command, with rationale`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev next`

## Depends on
- (none)
