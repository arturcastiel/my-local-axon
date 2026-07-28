---
tags: [code, file]
path: workspace/programs/code-dev-review-self.md
---

# workspace/programs/code-dev-review-self.md

> 29 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Declared-vs-touched files check — closes the dead `changed-files` capture with its`
- `Get diff against base`
- `HELP`
- `IDENTITY LOCK`
- `Match each criterion against diff CONTENT (keyword presence in the actual change, not file names)`
- `OUTPUT`
- `PROGRAM: code-dev-review-self`
- `budget:`
- `cache-prefix: 2048`
- `code-dev-review-self.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Agent reads PR diff vs spec acceptance criteria; reports gaps`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 6`
- `inputs:  W:code-dev-pr-create (or prompted)`
- `intended feature (bugfix02 sweep): a spec-declared file the diff never touched is a gap.`
- `invocation_source: [program]`
- `output-cap:   2000`
- `outputs-count: 3`
- `outputs: phases/{phase}/03-prs/{PR-NNN}/self-review.md + check-only mode return`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND FILE-EXISTS(spec-path)"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev self-review [PR-NNN]`

## Depends on
- (none)
