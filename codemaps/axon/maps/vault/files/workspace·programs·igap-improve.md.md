---
tags: [code, file]
path: workspace/programs/igap-improve.md
---

# workspace/programs/igap-improve.md

> 56 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- If gaps target kernel or programs → prompts before any axon/ write`
- `- If no gaps exist → report and DONE`
- `- Never executes automatically — only when called explicitly`
- `After PRs are applied, clear the session igap counter`
- `Bootstrap project if it doesn't exist`
- `Dev-mode must be ON (gaps may require edits to axon/ kernel or programs).`
- `GUARD`
- `Group improvement actions by where the fix lands:`
- `HELP`
- `Hand off to code-dev-study — user can add more context or say "done"`
- `If halted: resume → picks up at study phase`
- `LOAD DATA`
- `OUTPUT`
- `PROGRAM: igap-improve`
- `Pre-populate 01-study.md with the igap report as raw material`
- `STEP 1 — SURFACE + CONFIRM`
- `STEP 2 — CLASSIFY TARGETS`
- `STEP 3 — STUDY PHASE (reuse code-dev-study)`
- `STEP 4 — PLAN PHASE (reuse code-dev-plan)`
- `STEP 5 — EXECUTE PHASE (reuse code-dev-pr-create)`
- `STEP 6 — CLOSE GAPS`
- `Synthesize the gap report into study material so code-dev-study`
- `[context pressure gate fires here per kernel rule]`
- `[context pressure gate fires here per kernel rule]`
- `[context pressure gate fires here per kernel rule]`
- `can extract goal + priorities without a URL or PDF.`
- `contract-version: neuron-contract v1.1`
- `desc:    Reads igap report, groups improvement actions by target, then drives`
- `desc:    Review logged inference gaps and drive study→plan→execute cycle to close them`
- `doc     — requires edit to README, HOWTO, or other docs`
- `domain: igap`
- `example: igap improve          — review last 7 days of gaps`
- `family: [igap]`
- `glossary: AXON-GLOSSARY v2`
- `igap improve --days 1 — review today only`
- `igap-improve.md`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `inputs-count: 2`
- `inputs:  workspace/log/igap/YYYY-MM-DD.md  (written by igap tracker)`
- `invocation_source: [program]`
- `kernel  — requires edit to axon/KERNEL-SLIM.md or axon/ subsystem files`
- `memory  — requires STORE(L:key) or edit to workspace/memory/`
- `next-suggests: [code-dev-plan, code-dev-pr-create, code-dev-study]`
- `notes:`
- `outputs-count: 5`
- `outputs: drives existing programs — study/plan/execute artifacts land in`
- `precondition: "L:dev-mode ≡ true"`
- `program — requires edit to workspace/programs/*.md`
- `requires: L:dev-mode ≡ true`
- `role: mutator`
- `so code-dev-study can start from it rather than asking for a URL`
- `status: ACTIVE`
- `synapse:`
- `the existing code-dev study → plan → execute chain to close the gaps.`
- `usage:   igap improve [--days N]`
- `{W:myaxon-dev-projects}/axon-igap-{date}/`

## Depends on
- (none)
