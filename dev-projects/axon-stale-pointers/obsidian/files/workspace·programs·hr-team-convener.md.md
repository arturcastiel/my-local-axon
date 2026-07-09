---
tags: [code, file]
path: workspace/programs/hr-team-convener.md
---

# workspace/programs/hr-team-convener.md

> 82 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `"the panel agrees" are BANNED — narrate distributions verbatim instead`
- `(events: convener_announced, protocol_started, seat_invoked, seat_responded, protocol_completed)`
- `- Cannot editorialise the answer or offer an opinion on correctness`
- `- Cannot override deliberation mid-run on operator command`
- `- Cannot silently change evaluation criteria (preamble is locked from selector)`
- `- Cannot suppress minority positions or cherry-pick high-confidence seats`
- `- Cannot treat a seat's prior-round output as first-person memory (§4.2 rule 5 / §13.5)`
- `- Cannot use opinion-loaded phrasing: "the strong consensus" / "clearly" / "obviously" /`
- `- No write actions: no WRITE( / no file creation / no external tool calls except run_seats`
- `- developer MUST NOT contain secrets`
- `- required output schema per seat: {reason, answer, confidence}`
- `- system MUST NOT contain task payload`
- `- user MUST NOT contain persona/protocol instructions`
- `A re-round request (stored by the deliberator on substantive dissent) converts this run`
- `ADR-002 seam: ONE run_seats(messages_all[]) → responses[] call.`
- `ANNOUNCE (§5 — announce-then-act with 30-second objection window)`
- `ASSEMBLE SEATS (HANDOFF §4.2 + §9.2)`
- `ASSIGN MODEL DIVERSITY (ADR-006)`
- `Announce the full council configuration. Operator may CANCEL only (no mid-run edits).`
- `Assign per-seat model_variant (Haiku 4.5 / Sonnet 4.6 / Opus 4.8) + reasoning effort`
- `CONVENER CANNOT`
- `Each round is again one run_seats(messages[]) call (sealed ballot per round).`
- `First emitted line — the tier-pick narration (override note always present)`
- `For each subsequent round: RE-INJECT each seat's system prompt FRESH (§4.2 rule 5 / §13.5).`
- `Fragment order: PERSONA → GUARDRAIL → SKILLS → [DE-BIASING] | MODE → PROTOCOL → FORMAT | TASK`
- `IDENTITY LOCK`
- `If selector deferred (tier missing), apply the convener.md v1.1.0 heuristic:`
- `LOAD CONTEXT`
- `LOW fix (axon-bugfix01): this refusal compared against `session-budget` — a term defined`
- `NOWHERE (vestigial). The budget source is W:hr-team-budget (router-loaded); absent budget`
- `Narrate the tier the SELECTOR chose; CONVENER does NOT re-pick the tier if selector already set it.`
- `No seat receives any other seat's Round 1 output before submitting its own (§4.2 rule 8).`
- `OUTPUT`
- `PR-007 — the router loaded supporting context (path-or-text, sha256-bound) into this key via`
- `PROGRAM: hr-team-convener`
- `Prior-round outputs are passed as transcript DATA in developer/user context — NOT first-person memory.`
- `Prohibitions (§4.2 'Convener cannot' list):`
- `Propagate LOW_DIVERSITY warning if selector already flagged it`
- `REROUND ENTRY (H3, axon-bugfix01)`
- `RUN PROTOCOL ROUNDS (rounds 2..rounds)`
- `RUN ROUND 1 (PARALLEL · SEALED)`
- `Refusal gates — all 7 triggers checked BEFORE any seat is invoked`
- `Role split: system = persona + guardrail + skills + de-biasing`
- `Rotate across the three tiers: small→Haiku 4.5, medium→Sonnet 4.6, large→Opus 4.8.`
- `Step 1: complexity 0-5 (scope tokens × domain breadth)`
- `Step 2: priority modulation: low=−1, normal=0, high=+1, critical=+2 (floor at 2=medium)`
- `Step 3: score→tier map: 0=micro,1=low,2=medium,3=high,4=xhigh,5+=full`
- `TIER NARRATION (HANDOFF §16.2 + convener.md Step 4 — MUST be first emitted line)`
- `The convener has NO write/tool/decision authority beyond the run_seats seam and audit bundle.`
- `The sealed/parallel invariant is enforced here: all messages assembled BEFORE any call.`
- `W:council-transcript — per-round per-seat utterances for the deliberator`
- `W:hr-team-persistence     — optional; none/session/full (default: from selector-result)`
- `W:hr-team-preamble        — required; framing lock from selector (question,scope,evaluation_criteria)`
- `W:hr-team-selector-result — required; config from hr-team-selector (seats,protocol,tier,advisory_only)`
- `W:task                    — required; the original deliberation task/question`
- `contract-version: neuron-contract v1.1`
- `deliberator. The request is consumed (cleared) so it can never loop.`
- `desc:    hr-team Layer 2 — assembles seats, announces, runs parallel sealed rounds via run_seats seam`
- `developer = mode + protocol + format_rules`
- `domain: deliberation`
- `family: [council, advisory, convener]`
- `glossary: AXON-GLOSSARY v2`
- `hr-team-convener.md`
- `inputs-count: 4`
- `inputs:`
- `into ONE additional deliberation round over the EXISTING transcript: the dissent context`
- `invocation_source: [program]`
- `is injected as data, seats respond once, and the merged transcript goes back to the`
- `means unlimited (no refusal). The budget-violation trigger stays part of the 7-refusal contract.`
- `next-suggests: [hr-team-deliberator, hr-team]`
- `outputs-count: 1`
- `outputs:`
- `precondition: "true"`
- `role: reader`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_hr_team_convener_router.py`
- `the deterministic helper; the convener is TOOL-free so it only READS it. Empty → no context block.`
- `to maximize intra-harness diversity across seats. Never collapse all seats to one variant.`
- `usage:   called via EXEC(hr-team-convener) from the hr-team router; consumes W:hr-team-selector-result`
- `user = --- BEGIN TASK --- / task / --- END TASK ---`
- `§9.2 validation rules (ASSERTED):`

## Depends on
- (none)
