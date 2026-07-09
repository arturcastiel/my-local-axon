---
tags: [code, file]
path: workspace/programs/iterate-or-stop.md
---

# workspace/programs/iterate-or-stop.md

> 25 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `C1: the meta-workflow's s4 edges route on this key (`if: W.mcd-decision == "green"|"iterate"|"abort"`).`
- `C4: abort is a CLEAN outcome, not a workflow error. Emit it for observability, then DONE — the s4`
- `DECIDE — three exits: green | iterate | abort`
- `IDENTITY LOCK`
- `LOAD`
- `OUTPUT`
- `PROGRAM: iterate-or-stop`
- `Priority: hard-abort beats green beats iterate. This protects the`
- `The runner resolves W.* from live memory when it evaluates the edge after this program returns.`
- ``if: W.mcd-decision == "abort"` edge routes to the finalize terminal. (Previously this FAILed, so the`
- `contract-version: neuron-contract v1.1`
- `desc:    Gate synapse for iterate-until-green workflows. Reads W:last-audit-verdict + iter counter; routes to green / iterate / abort. Increments W:multiple-code-dev-iter atomically.`
- `domain: workflow`
- `even if the verdict otherwise says pass.`
- `family: [workflow]`
- `inputs-count: 2`
- `invocation_source: [program]`
- `iterate-or-stop.md`
- `iteration cap / fatal-bug stop surfaced as a workflow ERROR instead of a reported terminal.)`
- `outputs-count: 1`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:last-audit-verdict) ≠ ∅"`
- `rejection criterion: a fatal/unresolved-bug signal stops the loop`
- `role: gate`
- `status: ACTIVE`
- `synapse:`

## Depends on
- (none)
