# Phase 1 — STUDY · super-polish

## Goal
Make AXON demonstrably bug-free + "only what we have works": a systematic, multi-agent sweep that
(a) catches real bugs grounded at file:line and proven by adversarial refutation, and (b) confirms
every ACTIVE tool/program actually FUNCTIONS (not just imports). Plus rationalize the destructive-git-op
rule the owner flagged as weird.

## Current state (grounded)
- Strong MERGE-TIME nets exist (crucible 22/0, the locks, the script-mode import parity net, the
  program-dispatch resolution harness, R_DONT_DO + write-time dont-do). These catch import/dispatch/
  schema/regression breakage.
- GAP: there is NO systematic DEEP bug-hunt. "ACTIVE" is asserted by REGISTRY + a --help smoke
  (health-check) — it proves a tool STARTS, not that it WORKS. This session found real latent bugs only
  by chance (cron --workspace placement, cron starvation, F21 functional-insert landmines, the F44 silent
  JSON-state loss). That pattern says: more lurk, and only a focused adversarial sweep will surface them.
- Method that fits: multi-agent fan-out — find (per subsystem) → adversarially refute → synthesize →
  fix. The canonical review pattern, scaled wide. False positives are killed by majority-refutation;
  every surviving finding is grounded + verified, never asserted.

## Subsystems to fan over (bug-hunt dimensions)
memory (memory/_longterm/agent-memory/memory-sync/checkpoint/session_save) · dispatch+run
(axon.py/run.py/dispatch.py/_axon_lib) · scheduler (cron.py) · gate+rules (crucible/verify/enforce/
rules/*/dont_do) · synapse+compile (synapse_*/compile_*/dag) · io+paths (_axon_io/_axon_paths/lint_paths)
· hooks (reanchor/enforce_pretooluse/verify_stop) · liveness+registry (liveness/registry_drift/
_axon_registry) · program-layer (LANG interpretation, OS programs) · proof harness (dual_agent_eval/proof_*).

## Risk + mitigation
- False-positive bugs → adversarial-verify wave (≥majority skeptics must fail to refute) + every claim
  grounded at file:line.  - Over-claim → "ensure-works" wave runs the tool, doesn't trust a smoke.
  - Scope creep → bounded to the ACTIVE surface; fixes are gated PRs (branch-first, crucible-green).

## Confidence
9/10 on the methodology; the unknown is how many real bugs exist (that's what the sweep measures).
