---
tags: [code, file]
path: workspace/programs/code-dev-journal-event.md
---

# workspace/programs/code-dev-journal-event.md

> 26 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: code-dev-journal-event`
- `budget:`
- `cache-prefix: 2048`
- `called-by: write programs (log, decision, pr-update-spec, freeze, branch, etc.)`
- `code-dev-journal-event.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Append a state-change event to {project}/_events.log`
- `domain: code-dev`
- `family: [code-dev]`
- `format:  <iso-ts>  <kind>  <detail>`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 3`
- `invocation_source: [program]`
- `output-cap:   2000`
- `outputs-count: 2`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev event <kind> "<detail>"`
- `when:    atomic state-change emitted by other programs; internal, rarely user-typed`

## Depends on
- (none)
