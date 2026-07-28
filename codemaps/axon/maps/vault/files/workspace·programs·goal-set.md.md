---
tags: [code, file]
path: workspace/programs/goal-set.md
---

# workspace/programs/goal-set.md

> 23 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `CAPTURE`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: goal-set`
- `RESET — H3: clear loop state so a re-run in the same session starts clean.`
- `W:active-workflow at audit time, so this program stays single-field + reusable outside loops.`
- `Writes a minimal goal record (id + statement + set-at). Acceptance / rejection criteria for an`
- `contract-version: neuron-contract v1.1`
- `desc:    Capture or refresh the Main Goal record into W:current-goal. Used as the entry synapse of iteration workflows (multiple-code-dev) and standalone.`
- `domain: workflow`
- `family: [workflow]`
- `goal-set is the loop's entry synapse (s1), so this is the one place that runs exactly once per run.`
- `goal-set.md`
- `inputs-count: 1`
- `invocation_source: [program, user]`
- `iterate-or-stop only ever increments W:multiple-code-dev-iter; without a reset a 2nd run inherits a`
- `iteration loop live in the workflow YAML's `default-goal` block; goal-audit reads them from`
- `outputs-count: 1`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\""`
- `role: mutator`
- `stale iter (the cap mis-fires on lap 1) and a stale verdict / seed / decision poisons the new run.`
- `status: ACTIVE`
- `synapse:`

## Depends on
- (none)
