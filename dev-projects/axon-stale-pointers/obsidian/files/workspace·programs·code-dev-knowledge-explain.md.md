---
tags: [code, file]
path: workspace/programs/code-dev-knowledge-explain.md
---

# workspace/programs/code-dev-knowledge-explain.md

> 62 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(parent directory created on-demand by WRITE)`
- `- Regenerate after any code change by re-running with the same PR number`
- `- The explanation is self-contained — can be shared with reviewers`
- `- Use shadow hits to avoid re-reading unchanged files`
- `Content also rendered to chat for immediate reading`
- `EXPLANATION STRUCTURE (generate each section in order)`
- `Extract predecessor and successor PRs for dependency context`
- `GENERATE EXPLANATION`
- `GUARD`
- `HELP`
- `IDENTITY LOCK`
- `Instructions for the generation agent — enforced during output composition:`
- `LOAD SUPPLEMENTARY CONTEXT`
- `OUTPUT → PYTHON_FAST · doc`
- `PROGRAM: code-dev-knowledge-explain`
- `RESOLVE TARGET PR`
- `Read and shadow any un-indexed files`
- `Render full explanation to chat for immediate reading`
- `Rule 1 — Problem first, mechanism second`
- `Rule 2 — ASCII diagram + one sentence per step for pipelines`
- `Rule 3 — Concrete before abstract`
- `Rule 4 — Name gaps explicitly`
- `Rule 5 — Match depth to domain background`
- `SHADOW CHECK — resolve which source files to read vs retrieve from shadow`
- `STYLE GUIDE (apply to all explanations)`
- `Section 1 — Mental Model`
- `Section 2 — Two Functions / Types You Must Not Confuse (if applicable)`
- `Section 3 — Per-Change Annotated Walkthrough`
- `Section 4 — End State`
- `Section 5 — Test Coverage Table`
- `Section 6 — Quick Reference Table`
- `This is the core generation step.`
- `W:code-dev-explain-n   — PR number to explain (optional, inferred if absent)`
- `W:code-dev-explain-out — output path override (optional)`
- `WRITE OUTPUT`
- `budget:`
- `cache-prefix: 2048`
- `code-dev explain       — explain the most recently written PR spec`
- `code-dev-knowledge-explain.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Generate a deep-dive annotated code explanation for a PR in the active project`
- `desc:    Reads a PR spec and the files it touches, then produces a full annotated`
- `design rationale, traps to avoid, end-state diagram, and test coverage table.`
- `domain: code-dev`
- `explanation: mental model, per-change walkthrough with inline comments,`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 12`
- `inputs:  W:code-dev-project     — active project (required)`
- `invocation_source: [program]`
- `next:    code-dev pr [N+1] — write next PR spec`
- `output-cap:   2000`
- `outputs-count: 4`
- `outputs: Markdown file written to {project-dir}/explained/PR-00N-explained.md`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND COUNT(written) > 0 AND spec ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `usage:   code-dev explain [N]   — explain PR-N in the active project`

## Depends on
- (none)
