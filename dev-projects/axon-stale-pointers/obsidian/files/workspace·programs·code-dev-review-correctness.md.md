---
tags: [code, file]
path: workspace/programs/code-dev-review-correctness.md
---

# workspace/programs/code-dev-review-correctness.md

> 29 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Findings table rendered in Step 3 above; this program is advisory-only.`
- `INSTRUCTIONS`
- `OUTPUT`
- `PROGRAM: code-dev-review-correctness`
- `PURPOSE`
- `Step 1 — Collect the working diff`
- `Step 2 — Adversarial passes (each pass tries to BREAK the change, not confirm it)`
- `Step 3 — Render (advisory — explicitly NOT a gate)`
- `budget:`
- `cache-prefix: 2048`
- `code-dev-review-correctness.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Adversarial correctness review of the working diff — try to REFUTE the change (WARN-only advisory)`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `input-cap:    8000`
- `inputs-count: 1`
- `invocation_source: [program]`
- `next:    code-dev preflight · code-dev review (all)`
- `output-cap:   1500`
- `outputs-count: 1`
- `outputs: A findings table (suspicion · evidence · severity) — advisory, never a gate`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅"`
- `role: reader`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_pr_spec_contract.py (program contract lock)`
- `usage:   code-dev review-correctness   ·   via dispatcher: code-dev-review sub="correctness"`

## Depends on
- (none)
