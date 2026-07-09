---
tags: [code, file]
path: workspace/programs/shadow-retroactive-bulk.md
---

# workspace/programs/shadow-retroactive-bulk.md

> 37 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `APPLY — live; writes shadow stubs, records manifest, optionally flips L:strict`
- `All three sections render inline; no consolidated tail block needed.`
- `DISPATCH`
- `GUARD`
- `IDENTITY LOCK`
- `OUTPUT → PYTHON_FAST · doc`
- `PLAN — dry-run, write nothing`
- `PROGRAM: shadow-retroactive-bulk`
- `UNDO — restore prior state from manifest (byte-perfect)`
- `W:shadow-retroactive-flip-strict   — apply-only: flip strict flag on success`
- `W:shadow-retroactive-projects-root — override default my-axon/dev-projects`
- `budget:`
- `cache-prefix: 1024`
- `contract-version: neuron-contract v1.1`
- `desc:    PR-116 — one-shot retroactive bulk shadow migrator over every my-axon/dev-projects/* PR spec. Idempotent; fully reversible via `undo`.`
- `domain: system`
- `family: [system]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: PR-116`
- `input-cap:    4000`
- `inputs-count: 3`
- `inputs:  W:shadow-retroactive-cmd          — plan | apply | undo  (required)`
- `invocation_source: [program]`
- `next:    code-dev-knowledge-shadow coverage · axon-audit --section 1c`
- `output-cap:   1500`
- `outputs-count: 0`
- `outputs: Per-mode JSON summary surfaced via OUTPUT block (counts, evidence, manifest path)`
- `precondition: "RETRIEVE(W:shadow-retroactive-cmd) | QUERY(user): "Provide shadow retroactive cmd:" ≠ ∅"`
- `role: mutator`
- `shadow-retroactive apply         — live; create stubs + write manifest`
- `shadow-retroactive apply --flip-strict`
- `shadow-retroactive undo          — restore prior state from manifest`
- `shadow-retroactive-bulk.md`
- `status: ACTIVE`
- `synapse:`
- `usage:   shadow-retroactive plan          — dry-run; report candidates only`
- `— live + set L:shadow-enforcement-strict=true`

## Depends on
- (none)
