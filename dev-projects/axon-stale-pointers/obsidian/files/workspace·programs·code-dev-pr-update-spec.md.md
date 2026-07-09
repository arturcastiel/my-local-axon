---
tags: [code, file]
path: workspace/programs/code-dev-pr-update-spec.md
---

# workspace/programs/code-dev-pr-update-spec.md

> 26 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Also log to phase _deviations.md`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: code-dev-pr-update-spec`
- `budget:`
- `cache-prefix: 2048`
- `code-dev-pr-update-spec.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Update a PR spec mid-flight when scope changes`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 3`
- `inputs:  W:code-dev-project; W:code-dev-pr-create (or prompted)`
- `invocation_source: [program]`
- `output-cap:   2000`
- `outputs-count: 3`
- `outputs: edits 03-prs/PR-NNN.md; appends update entry to PR spec`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND FILE-EXISTS(pr-path)"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev pr-update-spec [PR-NNN]`

## Depends on
- (none)
