---
tags: [code, file]
path: workspace/programs/code-dev-state-save.md
---

# workspace/programs/code-dev-state-save.md

> 30 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: code-dev-state-save`
- `SESSION HOOK (PR-9)`
- `budget:`
- `cache-prefix: 2048`
- `code-dev rewind "<label>"         # restore from named snapshot`
- `code-dev tag list                 # list tags`
- `code-dev-state-save.md`
- `contract-version: neuron-contract v1.1`
- `default: create`
- `desc:    Phase 5 — alias for code-dev-state-save (milestone snapshot; rewind restores)`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 5`
- `invocation_source: [program]`
- `leaves 04-log / 05-branches / _actions.log referencing reverted phases/PRs`
- `output-cap:   2000`
- `outputs-count: 3`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND DIR-EXISTS(snap-dir) AND label MATCHES \"^[a-zA-Z0-9_-]+$\" AND NOT DIR-EXISTS(snap-dir)"`
- `project-root mutable state must roll back with _meta + phases, else rewind`
- `role: mutator`
- `scope:   only AXON project files — never touches user codebase (git's job)`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev tag "<label>"            # snapshot project _meta + phase folder`

## Depends on
- (none)
