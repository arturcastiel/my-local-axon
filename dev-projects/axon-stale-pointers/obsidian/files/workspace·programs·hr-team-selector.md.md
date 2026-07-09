---
tags: [code, file]
path: workspace/programs/hr-team-selector.md
---

# workspace/programs/hr-team-selector.md

> 60 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Conditional: elevate auditor weight for self-referential tasks`
- `Conditional: inject prompt-injection-red-teamer when task can carry untrusted text`
- `Cost estimate: seats × rounds × per-seat-per-round cost (§11.2 cost matrix)`
- `Elevate auditor weight if self-referential (Step 5 flag)`
- `Explicit --protocol overrides tier default`
- `Explicit rosters do NOT bypass Challenger, budget, safety, or catalog checks (§4.1 invariant)`
- `IDENTITY LOCK`
- `LOAD`
- `LOW_DIVERSITY is a WARNING, not a refusal (Selector invariant 4)`
- `OUTPUT`
- `PR-009 / OD-C: the router ran a DETERMINISTIC keyword/domain roster pre-pass (match-roster over`
- `PROGRAM: hr-team-selector`
- `STEP 0 — Task gate (clarify-if-vague)`
- `STEP 1 — Safety + circular-call gates (HANDOFF §4.1 refusal table — checked before framing)`
- `STEP 10 — Assign weights and diversity check (HANDOFF §4.1 step 6, ADR-006)`
- `STEP 2 — Lock framing (HANDOFF §4.1 step 1 — produces the preamble the CONVENER consumes)`
- `STEP 3 — Invocation-mode dispatch (M1/M2/M3 per HANDOFF §3)`
- `STEP 4 — Catalog load + slug-existence validation (HANDOFF §4.1 step 3 + §6)`
- `STEP 5 — Mandatory Challenger seat (HANDOFF §4.1 step 4 + §16.3 — INVARIANT, ALL modes/tiers)`
- `STEP 6 — Tier selection (HANDOFF §16, ADR-005)`
- `STEP 7 — Context-overflow gate`
- `STEP 8 — Build final seat list (trim/pad to seats-count, preserve Challenger last)`
- `STEP 9 — Budget check (HANDOFF §4.1 step 5)`
- `Tier parameter table (§16.1)`
- `Uniform 1/N weight initialization (Selector invariant; §4.3 WSV init; Brier-updatable later)`
- `Validate each candidate slug against registry (slug-only, cross-domain resolve)`
- `W:hr-team-budget      — optional; max cost cap for the council run`
- `W:hr-team-catalog     — optional; path prefix for catalog (default: workspace/hr-team/catalog/)`
- `W:hr-team-filter      — optional; {domain,family,roles,size,budget} narrowing object (M2)`
- `W:hr-team-fixture-mode — optional; true iff running inside a regression fixture (unlocks circular-call)`
- `W:hr-team-mode        — optional; named preset or F1..F6 6-tuple (default: default-deliberation)`
- `W:hr-team-priority    — optional; low/normal/high/critical (default: normal)`
- `W:hr-team-protocol    — optional; one of round-robin/weighted-vote/consensus/debate/delphi/adversarial`
- `W:hr-team-roster      — optional; explicit slug list for M3 explicit mode`
- `W:hr-team-selector-result — config object: {invocation_mode, seats, protocol, tier, rounds,`
- `W:hr-team-size        — optional; tier override: micro/low/medium/high/xhigh/full`
- `W:task                — required; the deliberation task/question`
- `contract-version: neuron-contract v1.1`
- `desc:    hr-team Layer 1 — validates task+roster, selects seats/mode/protocol/tier, emits config`
- `domain: deliberation`
- `family: [council, advisory, decision-support]`
- `final-roster gate downstream stays the backstop. No silent LLM-takeover on a mismatched roster.`
- `glossary: AXON-GLOSSARY v2`
- `hr-team-selector.md`
- `inputs-count: 10`
- `inputs:`
- `invocation_source: [program]`
- `is fail-closed (hard, not a guess); a weak keyword match is surfaced as a warning and the empty`
- `next-suggests: [hr-team-convener, hr-team]`
- `outputs-count: 1`
- `outputs:`
- `persona, persistence, rationale, warnings, cost_estimate, advisory_only:true}`
- `precondition: "true"`
- `prediction-market is flagged-advanced: refused unless explicitly requested (ADR-007)`
- `role: composer`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_hr_team_selector.py`
- `the catalog) into W:hr-team-roster-candidates — the deterministic-first pool. An UNKNOWN domain`
- `usage:   called via EXEC(hr-team-selector) from the hr-team router neuron`

## Depends on
- (none)
