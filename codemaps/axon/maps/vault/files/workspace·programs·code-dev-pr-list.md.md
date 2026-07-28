---
tags: [code, file]
path: workspace/programs/code-dev-pr-list.md
---

# workspace/programs/code-dev-pr-list.md

> 38 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- --all-projects iterates my-axon/dev-projects/*`
- `- --json emits one JSON object per line, suitable for piping`
- `- --state filters: open | ready-for-review | done | blocked`
- `- Read-only — never mutates _meta.md`
- `ARGS`
- `DISPATCH`
- `DONE`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: code-dev-pr-list`
- `Single-project default: pass current project _meta.md explicitly`
- `budget:`
- `cache-prefix: 2048`
- `code-dev-pr-list.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Cross-phase PR aggregator — table or JSONL view (PR-9.5)`
- `desc:    List every PR across one or all dev-projects (G-I1, D-B1)`
- `domain: code-dev`
- `example: code-dev pr list --all-projects --json`
- `example: code-dev pr list --state=ready-for-review`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 1`
- `inputs:  W:code-dev-project (single-project default)`
- `invocation_source: [program]`
- `next:    code-dev pr ready <N> · code-dev pr-review <N>`
- `output-cap:   2000`
- `outputs-count: 1`
- `outputs: table to stdout (or JSONL with --json)`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\""`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `usage:   code-dev pr list [--all-projects] [--state=<s>] [--phase=<N>] [--json]`

## Depends on
- (none)
