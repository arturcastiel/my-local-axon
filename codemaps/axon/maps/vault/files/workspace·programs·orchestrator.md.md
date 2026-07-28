---
tags: [code, file]
path: workspace/programs/orchestrator.md
---

# workspace/programs/orchestrator.md

> 66 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `ACT — only if decide() says fire (otherwise wait for user)`
- `ANTICIPATE (axon-workflow-discipline PR-8) — revive the always-on anticipation layer`
- `CANDIDATES — fixed vs adaptive selection (per § The loop)`
- `DECIDE — confidence + inference-mode → fire | ask | surface-only (per § decide())`
- `IDENTITY LOCK`
- `In bridge-mode we (a) do NOT overwrite W:active-program — leave the`
- `L:inference-mode                — 0..10 — selects decide() branch`
- `OBSERVE — snapshot of W:/L:/files/events (per § observe() in spec)`
- `OUTPUT → PYTHON_FAST · doc`
- `PR-4.1 (ADR-007) — bridge-mode caller (workflow-run) owns step`
- `PR-4.1 (ADR-007) — bridge-mode detection. When workflow-run invokes`
- `PR-4.1 (ADR-007) — only clear active-program if we set it. In`
- `PR-8 — the always-on anticipation surface. Honest about silence (cardinal rule).`
- `PROGRAM: orchestrator`
- `RECORD — for audit/replay (per § Measurement)`
- `RENDER — next-action set`
- `Render block lives inline above (RENDER section). No tail block needed.`
- `SIDEBAND (D-30) — even in fixed-mode, compute sideband suggestions`
- `Situation-trigger hint (axon-plus pr-16, Goal B): ≤1 deduped hint carrying why+command,`
- `UserPromptSubmit hook (prepared, owner-install). Until it lands, fall back to raw-user-input`
- `W:active-workflow               — workflow descriptor or ∅ (adaptive)`
- `W:active-workflow-step          — current step inside a fixed workflow`
- `W:orchestrator-last-tick), W:active-program is "workflow-run" at entry.`
- `W:raw-user-input at input-parse; the TRUE W:recent-user-input producer is the host`
- `ZERO-CANDIDATE FALLBACK (FL-05 — Never hang)`
- `a guess — wrong anticipation is worse than none.`
- `and W:orchestrator-last-tick are updated regardless.`
- `anticipate.py wraps the same ranker with a confidence-MARGIN gate + density verdict and LOGS`
- `axon-workflow-discipline PR-8 — interim recent-input producer bridge. The kernel stores`
- `bridge-mode the caller (workflow-run) is still active; do not stomp.`
- `budget:`
- `cache-prefix: 2048`
- `caller's marker intact — and (b) skip the ACT block so we don't`
- `contract-version: neuron-contract v1.1`
- `desc:    Mainline loop (PR-111) — after a neuron fires, query synapse-suggest, walk the DAG, render the next-action set. Both fixed-workflow and adaptive-free-text modes covered.`
- `dispatch. Skip fire AND ask so we don't double-fire or interrupt the`
- `domain: system`
- `double-fire the step workflow-run already dispatched.`
- `family: [system]`
- `for things the ranker did NOT already surface. Injected into the tick; the footer`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: PR-111`
- `input-cap:    8000`
- `inputs-count: 4`
- `inputs:  W:current-goal                  — goal record per goal-schema-v1 (REQUIRED per D-007)`
- `invocation_source: [program]`
- `layer that "went missing": built + registered ACTIVE but invoked by NOTHING. Wiring it here`
- `makes it compute every orchestrator tick. Cardinal rule: a weak margin yields SILENCE, never`
- `next:    synapse-suggest · dispatch · code-dev (continuation)`
- `orchestrator --explain          — include reason/signals in the next-action set`
- `orchestrator --top N            — surface top-N candidates (default 3)`
- `orchestrator as an observe-only sideband (to wake PR-112's footer +`
- `orchestrator.md`
- `output-cap:   2000`
- `outputs-count: 1`
- `outputs: W:orchestrator-last-tick        — last-tick record for replay/audit`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\""`
- `renders it (PR-017). Silence is first-class.`
- `role: mutator`
- `so the revived anticipation layer below has a real signal instead of "".`
- `spec:    my-axon/dev-projects/axon-synapse/phases/2-design/specs/orchestrator-composition-v1.md`
- `status: ACTIVE`
- `synapse:`
- `the prediction (episodic/anticipation-log.jsonl) for accuracy scoring + replay. This is the`
- `usage:   orchestrator                    — single tick of the loop on current state`
- `workflow with a prompt. RECORD above still ran, so PR-112's footer`

## Depends on
- (none)
