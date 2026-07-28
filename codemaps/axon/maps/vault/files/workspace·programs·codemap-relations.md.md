---
tags: [code, file]
path: workspace/programs/codemap-relations.md
---

# workspace/programs/codemap-relations.md

> 25 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `GUARD`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: codemap-relations`
- `STEP 1 — Resolve the target to graph node(s) (refresh-if-stale first)`
- `STEP 2 — Relationships for the strongest match`
- `STEP 3 — Log`
- `codemap-relations.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Show relationships for a symbol or file — callers, affected (blast-radius), impact, neighbors`
- `domain: codemap`
- `family: [codemap]`
- `glossary: AXON-GLOSSARY v2`
- `inputs-count: 2`
- `invocation_source: [program]`
- `next-suggests: [codemap-ask, codemap-map]`
- `next:    codemap ask · codemap map`
- `outputs-count: 1`
- `outputs: a relationship report (callers · affected · impact · neighbors) for the target`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:codemap-active) ≠ ∅ AND FILE-EXISTS(graph-path)"`
- `role: reader`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_codemap_programs.py`
- `usage:   codemap relations <symbol|file>`

## Depends on
- (none)
