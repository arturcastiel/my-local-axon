# PR-4 — LLM semantic overlay (P3, inert+gated) + project completion

Status: merged (MR !156)
Branch: graphify-obsidian/pr-4-semantic-complete → graphify-obsidian-integration
Depends-on: PR-3 (graphify_bridge)
Phase: execute

## Goal
Deliver P3 the AXON way — the panel's "first to cut" / non-deterministic piece — as a **bounded, INERT,
AEGIS-gated, advisory-only** capability (the established "build inert until granted" pattern). It introduces
NO non-determinism onto any gate and makes NO network call until the owner grants it. Then **complete the project**.

## Change
- **Extend** `tools/graphify_bridge.py` with a `semantic` subcommand:
  - AEGIS-gated via `aegis_policy` (`web` capability). **Without a grant → refused + degraded** (inert default).
  - With a grant → would run graphify's LLM extraction over a target repo; output tagged **INFERRED/AMBIGUOUS,
    advisory-only**. Hard contract: P3 output NEVER feeds a gate.
- **Tests** `tests/test_graphify_bridge.py` (extend): `semantic` without grant → refused/degraded (the safety
  test); output confidence is never EXTRACTED (advisory contract).
- **Completion:** run `code-dev audit`; update `DELIVERY.md` (all PRs); mark project `_meta` complete;
  final `04-log` entry. Optionally open the integration→main MR for owner review.

## Acceptance criteria
- [ ] `graphify-bridge semantic` with no `web` grant → `{ok:false, refused:true, degraded:true}` (inert).
- [ ] semantic output is never tagged EXTRACTED (advisory contract; never gate-eligible).
- [ ] No test requires graphify installed or a network call.
- [ ] Gates green incl. crucible.
- [ ] Project marked complete; DELIVERY.md final.

## Out of scope
A real LLM extraction run (needs the owner's key + grant — that's the opt-in, post-delivery).
