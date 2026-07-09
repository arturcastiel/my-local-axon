---
tags: [code, file]
path: workspace/programs/quality-loop.md
---

# workspace/programs/quality-loop.md

> 35 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- Every finding is VERIFIED before queueing (W0: 1 of 2 census findings was a probe error).`
- `- GENERATE-then-drain: standing queues are thin (W0 census) — the battery scans fresh.`
- `- Ramp: cycles 1–3 prepare diffs only. Nothing merges until the PR-015 gate flips.`
- `- Shareability routing: shared-surface fixes first-class; local-only logged, never built.`
- `Adversarial verification — every finding probed before it may queue (false premises die here)`
- `C's pilot: the loop-contract tracks open verified findings toward 0`
- `CYCLE`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: quality-loop`
- `Report-only ramp: prepare diffs for shared-surface verified findings; merge NOTHING.`
- `contract-version: neuron-contract v1.1`
- `desc:    Continuous find→verify→fix loop — scan battery generates findings, adversarial verification kills probe errors, fixes prepared as diffs (report-only ramp)`
- `dispatch-phrases: run the quality loop · find and fix bugs · scan for problems · drain the findings · quality sweep`
- `domain: meta`
- `example: quality-loop run → 47 findings → 31 verified → 12 diffs prepared (report-only)`
- `failure re-locks). Below authorization: report-only, no exceptions.`
- `family: [meta]`
- `glossary: AXON-GLOSSARY v2`
- `inputs-count: 1`
- `inputs:  none (battery generates its own material)`
- `invocation_source: [user, cron]`
- `next-suggests: [code-dev-new]`
- `next:    review the cycle report · after 3 clean cycles PR-015's gate unlocks S-fix autonomy`
- `outputs-count: 2`
- `outputs: cycle report (my-axon/dev-projects/<active>/quality/cycle-N.md) + loop-contract iteration`
- `pr-15 RAMP GATE: S-fix application is EARNED (3 clean cycles) and revocable (any`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\""`
- `quality-loop.md`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `usage:   quality-loop [run]   ·   weekly cron: axon-quality-loop`

## Depends on
- (none)
