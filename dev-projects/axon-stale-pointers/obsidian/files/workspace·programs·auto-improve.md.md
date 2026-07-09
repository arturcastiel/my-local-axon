---
tags: [code, file]
path: workspace/programs/auto-improve.md
---

# workspace/programs/auto-improve.md

> 47 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `After auto-actions land, refresh the synapse-suggest ranker by exporting`
- `All real work happens in tools/auto_improve.py — that's the cron-fireable`
- `DELEGATE`
- `Each action records to the audit ledger and snapshots its target`
- `GUARD — drift state (PR-012; fail-closed PR-AUTO-213)`
- `GUARD — idle-gap re-confirm (PR-AUTO-401 / D-A17)`
- `GUARD — master toggle (PR-017; HARD-opt-in PR-AUTO-401 / D-A02)`
- `HELP`
- `IDENTITY LOCK`
- `IGAP SIGNAL TAP (PR-120) — re-rank suggester on new inference gaps`
- `OUTPUT`
- `Opt-in must be re-affirmed at least every 30 days. Stale opt-ins`
- `PROGRAM: auto-improve`
- `SURFACE`
- `This .md program is the agent-visible interface; the Python tool is the`
- `auto-improve --action auto-compile`
- `auto-improve --dry-run    — show what would happen`
- `auto-improve.md`
- `auto-tune (dispatch threshold), auto-archive (old episodic memory).`
- `contract-version: neuron-contract v1.1`
- `desc:    Daily orchestrator. Closes auto-applicable improvement loops with`
- `desc:    Run 3 narrow auto-actions: auto-compile (high-use programs),`
- `domain: system`
- `entry point that handles audit + rollback + canonical envelope.`
- `example: auto-improve              — run all 3 actions`
- `family: [system]`
- `for rollback. Disabled by default — enable via L:auto-improve.`
- `full audit trail and rollback. Gated, narrow, opt-in.`
- `get a hard halt with the exact command to re-confirm. This is`
- `glossary: AXON-GLOSSARY v2`
- `implementation.`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `inputs-count: 0`
- `inputs:  L:auto-improve (must be true) · L:dev-mode (read for kernel-touch gates)`
- `invocation_source: [program]`
- `next:    auto-actions — review what was applied · undo --target X — revert`
- `outputs-count: 2`
- `outputs: audit entries · rollback snapshots · compiled programs · tuned threshold`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND L:auto-improve ≡ true AND drift.state ≠ \"diverged\""`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `that's flipped once and forgotten is a default, not a confirmation.`
- `the latest igap entries as a {name: weight} signal map and stashing it`
- `under W:igap-signals so subsequent synapse-suggest calls pick it up.`
- `usage:   auto-improve [--dry-run] [--action auto-compile|auto-tune|auto-archive]`
- `what makes the HARD opt-in actually HARD over time — a switch`

## Depends on
- (none)
