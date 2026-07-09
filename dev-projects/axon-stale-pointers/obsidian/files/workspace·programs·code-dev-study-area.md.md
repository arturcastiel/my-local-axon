---
tags: [code, file]
path: workspace/programs/code-dev-study-area.md
---

# workspace/programs/code-dev-study-area.md

> 49 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- --target accepts a single path or a glob; glob expands via pathlib.Path.rglob`
- `- 200-file cap on glob expansion; pass --force to override`
- `- Each mode writes its own file — never appends to another mode's output`
- `- subsystem mode: medium token budget · deep mode: large token budget`
- `CANONICAL STUDY POINTER (PR-019)`
- `DECLARED output (the completeness gate's SSOT, # emits: 01-study.md) is 01-study.md. Write a`
- `DONE`
- `Flag-mode studies write detail to study/{subsystems,deep}/<target>.md, but the study phase's`
- `GUARD`
- `Guard: never clobber a real overview 01-study.md — only write the pointer if absent.`
- `HELP`
- `IDENTITY LOCK`
- `INDEX APPEND (PR-17)`
- `INPUT INTEGRATION (T-S1.8)`
- `LOAD CONTEXT`
- `OUTPUT (per --output)`
- `PROGRAM: code-dev-study-area`
- `Per-mode token budget (PR-30 will enforce; this PR declares)`
- `REQUIRED_OUTPUTS / R_TERMINAL_OUTPUTS (all pinned to 01-study.md by tests + a BLOCK rule).`
- `SHADOW-FIRST WALK`
- `TARGET RESOLUTION`
- `budget:`
- `cache-prefix: 4096`
- `canonical pointer so the gate passes and the ladder advances — WITHOUT touching the emits floor /`
- `code-dev-study-area.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Area-scoped study (subsystem / deep mode) — walks --target path or glob, emits sectioned per-mode file`
- `desc:    Area-scoped study — invoked by `code-dev study --mode=subsystem|deep``
- `domain: code-dev`
- `example: code-dev study --mode=deep --target='tools/*.py' --output=executive`
- `example: code-dev study --mode=subsystem --target=tools/shadow.py --output=machine`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    16000`
- `inputs-count: 8`
- `inputs:  W:code-dev-project · ARGS from code-dev-study (PR-8 dispatch)`
- `invocation_source: [program]`
- `next:    code-dev study --mode=overview · code-dev plan`
- `output-cap:   6000`
- `outputs-count: 3`
- `outputs: {W:myaxon-dev-projects}/{slug}/study/deep/<sanitized>.md`
- `outputs: {W:myaxon-dev-projects}/{slug}/study/subsystems/<sanitized>.md`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND RETRIEVE(W:code-dev-study-target) ≠ ∅ AND target startswith codebase OR not absolute"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `usage:   code-dev study --mode=subsystem --target=<path|glob> [--output=engineering|executive|machine] [--input=<path>]`

## Depends on
- (none)
