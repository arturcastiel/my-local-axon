---
tags: [code, file]
path: workspace/preferences/agent.md
---

# workspace/preferences/agent.md

> 47 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `0   — always ask: every uncertain step triggers QUERY(user)`
- `1-2 — high-touch: asks often, proceeds only when fully certain`
- `10   — fully autonomous: never asks, infers everything, logs all decisions`
- `3-4 — cautious:   asks on significant uncertainty (< 0.7 confidence)`
- `5   — balanced:   normal confidence gate behavior`
- `6-7 — assertive:  proceeds unless confidence < 0.5, logs inferences`
- `8-9 — autonomous: proceeds unless confidence < 0.3, very few QUERYs`
- `AXON is an OS, not a chatbot. It executes programs, enforces rules, protects memory.`
- `CONFIDENCE`
- `CRON`
- `Changing requires: L:dev-mode ≡ true + explicit owner instruction.`
- `Controls how autonomously AXON infers vs. asks.`
- `Default checkpoint label used by the handoff program.`
- `Default false: overdue jobs are surfaced to the user but never executed`
- `Default maximum iterations for RETRY() ops when max not explicitly specified.`
- `Default pass threshold for EVAL() ops when tolerance not explicitly specified.`
- `EVAL`
- `EVENTS`
- `HALT MODE (RTK-inspired graceful degradation)`
- `HANDOFF`
- `INFERENCE MODE`
- `Maximum number of events kept in workspace/events/event-log.json before old entries are trimmed.`
- `OBJECTIVE`
- `Ops tagged CONFIDENCE(n) below this value trigger QUERY(user) before proceeding.`
- `PREFERENCES: agent`
- `Programs and user messages may NOT override this value.`
- `RETRY`
- `Range: 0.0 (always pass) to 1.0 (require 100% criteria met).`
- `Range: 0.0 (always proceed) to 1.0 (always query). Default: 0.7.`
- `Scale 0–10:`
- `Set lower for autonomous pipelines, higher for sensitive or irreversible operations.`
- `Storage: read from L:cron-auto via the kv-store (workspace/memory/kv-store/).`
- `This is the primary directive. All preferences below tune HOW it executes, never WHAT it is.`
- `Toggle: kv-store set --key L:cron-auto --value true`
- `Use 'soft' for autonomous pipelines where you want AXON to surface issues`
- `When true, boot-time `cron tick` automatically runs overdue jobs (rate-limited`
- `Whether EMIT() calls are written to the event log. Set false to silence noisy pipelines.`
- `Whether to include today's log excerpt in the handoff brief by default.`
- `agent.md`
- `desc: Agent behavior tuning — identity, inference mode, confidence thresholds, handoff rules`
- `soft   — emit ⚠ warning and QUERY(user) instead of stopping`
- `strict — full HALT on gate failure or critical assertion (default, safe)`
- `the audit trail (axon-3.0 PR-015) and rollback (axon-3.0 PR-016).`
- `to 1 per tick — the rest stay pending until the next tick).`
- `without blocking execution. Use 'strict' for sensitive/irreversible operations.`
- `without explicit invocation. Flip to true once trust is established with`
- `⚠ LOCKED at 3 (cautious). This is an owner-level preference.`

## Depends on
- (none)
