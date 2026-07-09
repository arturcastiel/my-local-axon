---
tags: [code, file]
path: workspace/programs/goal-audit.md
---

# workspace/programs/goal-audit.md

> 26 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `.unresolved-bug-after-pr / .fatal were never set and the loop could neither auto-accept nor hard-stop.`
- `C5/H1: the acceptance / rejection criteria live in the ACTIVE WORKFLOW's default-goal (the YAML). The`
- `Evidence inputs are project-state signals, NOT structural safety.`
- `IDENTITY LOCK`
- `LOAD`
- `OBSERVE — gather project state evidence`
- `OUTPUT`
- `PROGRAM: goal-audit`
- `RECORD`
- `This is what makes goal-audit different from code-dev-safety-audit:`
- `VERDICT — apply the goal's acceptance/rejection predicates`
- `contract-version: neuron-contract v1.1`
- `desc:    Audit current project state against W:current-goal. Reads the goal record and the project state, writes a verdict {pass|fail, reasons, evidence} to W:last-audit-verdict. Pure reader — does not decide flow.`
- `domain: workflow`
- `family: [workflow]`
- `goal-audit.md`
- `inputs-count: 2`
- `invocation_source: [program, user]`
- `outputs-count: 1`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:current-goal) ≠ ∅"`
- `role: reader`
- `runner stores W:active-workflow before each step, so by this audit (s3) they are available — read them`
- `status: ACTIVE`
- `synapse:`
- `there, falling back to W:current-goal then ∅. Without this both preds were always ∅, so verdict.pass /`
- `we ask "did we achieve the goal", not "is the code healthy".`

## Depends on
- (none)
