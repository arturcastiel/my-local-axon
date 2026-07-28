---
tags: [code, file]
path: workspace/programs/code-dev-meta-context.md
---

# workspace/programs/code-dev-meta-context.md

> 36 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- Dirty = _session.md state is "active" with events since last handoff/tag`
- `- `list` reads my-axon/dev-projects/*/_session.md for state per project`
- `- `use` auto-checkpoints the outgoing session and warns if dirty`
- `ARGS`
- `DISPATCH`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: code-dev-meta-context`
- `budget:`
- `cache-prefix: 2048`
- `code-dev meta context current        # print the active slug`
- `code-dev meta context list           # enumerate projects + per-project state`
- `code-dev-meta-context.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Multi-project context manager — list / use <slug> / current (PR-9.7, G-I10)`
- `desc:    Safely switch between dev-projects with auto-checkpoint on the outgoing project`
- `domain: code-dev`
- `example: code-dev meta context use smo-faults`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 5`
- `inputs:  W:code-dev-project — current active project`
- `invocation_source: [program]`
- `next-suggests: [menu]`
- `next:    code-dev load (auto-invoked on use) · code-dev status`
- `output-cap:   2000`
- `outputs-count: 2`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND slug ≠ ∅ AND EXISTS(target-meta)"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `usage:   code-dev meta context use <slug>     # switch active project (auto-save current)`

## Depends on
- (none)
