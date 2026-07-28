---
tags: [code, file]
path: workspace/programs/codemap-shadow.md
---

# workspace/programs/codemap-shadow.md

> 29 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `DISPATCH`
- `GUARD`
- `IDENTITY LOCK`
- `OUTPUT`
- `OUTPUT → PYTHON_FAST · doc`
- `PROGRAM: codemap-shadow`
- `REFRESH`
- `SCAN`
- `STATS (default)`
- `codemap shadow refresh    — re-index stale files`
- `codemap shadow scan [dir] — index new/stale source files (always-shadowed reads)`
- `codemap-shadow.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Bulk-shadow the study's repo so every later read is zero-token (hash-keyed findings)`
- `domain: codemap`
- `family: [codemap]`
- `glossary: AXON-GLOSSARY v2`
- `inputs-count: 3`
- `invocation_source: [program]`
- `next-suggests: [codemap-map, codemap-ask]`
- `next:    codemap map · codemap ask`
- `outputs-count: 2`
- `outputs: {study}/shadow/*.findings.md (one per source file, hash-keyed)`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:codemap-active) ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_codemap_programs.py`
- `usage:   codemap shadow            — index coverage stats for the active study`

## Depends on
- (none)
