---
tags: [code, file]
path: workspace/programs/code-dev-pr-link.md
---

# workspace/programs/code-dev-pr-link.md

> 28 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `HELP`
- `IDENTITY LOCK`
- `Initialize if absent`
- `OUTPUT`
- `PROGRAM: code-dev-pr-link`
- `budget:`
- `cache-prefix: 2048`
- `code-dev pr-link <PR-A> blocks <PR-B>`
- `code-dev pr-link check                  # warn if PR-A's deps aren't merged`
- `code-dev pr-link graph                  # render Mermaid into 02-prs.md`
- `code-dev-pr-link.md`
- `contract-version: neuron-contract v1.1`
- `desc:    PR dependency graph — declare and render depends-on / blocks edges`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 7`
- `invocation_source: [program]`
- `output-cap:   2000`
- `outputs-count: 2`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND from-pr ≠ ∅ AND edge ≠ ∅ AND to-pr ≠ ∅ AND edge ≡ \"depends-on\" OR edge ≡ \"blocks\""`
- `role: mutator`
- `status: ACTIVE`
- `storage: appends to {project}/_pr-links.md`
- `synapse:`
- `usage:   code-dev pr-link <PR-A> depends-on <PR-B>`

## Depends on
- (none)
