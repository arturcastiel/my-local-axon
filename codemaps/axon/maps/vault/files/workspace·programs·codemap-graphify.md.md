---
tags: [code, file]
path: workspace/programs/codemap-graphify.md
---

# workspace/programs/codemap-graphify.md

> 27 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `GUARD`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: codemap-graphify`
- `STEP 1 — Is graphify available? (advisory, never raises)`
- `STEP 2 — Resolve the target repo`
- `STEP 3 — Build / refresh the graph + record provenance`
- `STEP 4 — Mark the DB active (queries route through the fresh-guaranteed layer)`
- `STEP 5 — Provenance card + quick shape`
- `codemap-graphify.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Build the active study's repo into a persistent, always-fresh queryable graph DB`
- `domain: codemap`
- `family: [codemap]`
- `glossary: AXON-GLOSSARY v2`
- `inputs-count: 2`
- `invocation_source: [program]`
- `next-suggests: [codemap-shadow, codemap-map]`
- `next:    codemap shadow`
- `outputs-count: 2`
- `outputs: {study}/graph/graph.json built; W:codemap-graph + W:graphify-db marked active`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:codemap-active) ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_codemap_programs.py`
- `usage:   codemap graphify`

## Depends on
- (none)
