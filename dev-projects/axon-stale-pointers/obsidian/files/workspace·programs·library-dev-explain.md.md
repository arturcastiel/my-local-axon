---
tags: [code, file]
path: workspace/programs/library-dev-explain.md
---

# workspace/programs/library-dev-explain.md

> 24 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `GUARD`
- `LOAD`
- `OUTPUT`
- `PROGRAM: library-dev-explain`
- `Resolve current branch once (shared across all targets)`
- `STEP 1 — Build target list`
- `STEP 2 — Explain loop`
- `STEP 3 — Update meta`
- `contract-version: neuron-contract v1.1`
- `desc:    Generate annotated explained doc for one or all shadowed articles`
- `domain: library-dev`
- `family: [library-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `inputs-count: 7`
- `invocation_source: [program]`
- `library-dev-explain.md`
- `outputs-count: 2`
- `outputs: library/explained/{stem}.md per article — deep annotation with key insights`
- `precondition: "lib-name ≠ ∅ AND COUNT(shadow-files) > 0 AND FILE-EXISTS(\"{lib-path}shadow/{stem}.md\")"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   library-dev explain [stem|--all]`

## Depends on
- (none)
