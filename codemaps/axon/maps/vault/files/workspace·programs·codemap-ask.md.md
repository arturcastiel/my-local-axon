---
tags: [code, file]
path: workspace/programs/codemap-ask.md
---

# workspace/programs/codemap-ask.md

> 28 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `GUARD`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: codemap-ask`
- `STEP 1 — Locate relevant nodes in the graph`
- `STEP 2 — Pull relationships for the top hits (graph is the source of truth)`
- `STEP 3 — Pull shadow findings for the implicated files (zero re-read tokens)`
- `STEP 4 — Synthesize a grounded answer`
- `STEP 5 — Surface + log to the study's Q&A trail`
- `codemap-ask.md`
- `contract-version: neuron-contract v1.1`
- `derive 1–4 key terms from the question, then resolve them to graph nodes`
- `desc:    Answer a question about the repo, grounded in the graph + shadow findings (the study loop)`
- `domain: codemap`
- `family: [codemap]`
- `glossary: AXON-GLOSSARY v2`
- `inputs-count: 3`
- `invocation_source: [program]`
- `next-suggests: [codemap-ask, codemap-relations, codemap-map]`
- `next:    codemap ask (keep asking) · codemap relations <sym> · codemap map`
- `outputs-count: 1`
- `outputs: a grounded answer + an appended entry in {study}/reports/qa-log.md`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:codemap-active) ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_codemap_programs.py`
- `usage:   codemap ask "<question>"`

## Depends on
- (none)
