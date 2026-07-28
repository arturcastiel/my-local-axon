---
tags: [code, file]
path: workspace/programs/hr-team-deliberator.md
---

# workspace/programs/hr-team-deliberator.md

> 82 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `"consensus" / "clearly" / "obviously" / "the panel agrees"`
- `(HANDOFF §4.3 social-choice trade-off documented)`
- `(golden-vector tested). The measurable quality signals (winner_margin, confidence_spread,`
- `ALWAYS present, human_review_required:true, recommendation, ranked_alternatives,`
- `Aggregate TWICE: randomized seat/answer order + reversed order. Compare top answers.`
- `BPC is a DIAGNOSTIC — it does not select the winner; WSV (Step 3) does.`
- `Brier update: weight_s ← weight_s·(1 − brier_s) then renormalize — DEFERRED until ground truth known.`
- `Build warnings list`
- `FORBIDDEN phrases (unless every validated seat returned the identical answer):`
- `GAP-002: BALANCED POSITION CALIBRATION + WEIGHTED SCORE VOTING math now come from the TESTED`
- `GAP-002: winner / weighted_scores / ranked / aggregate_confidence come from `metrics` (the tested`
- `H2 fix (axon-bugfix01): initial-weights (selector elevation incl. the auditor 2x boost)`
- `H3 fix (axon-bugfix01): the re-round used to be unreachable — the convener ran every`
- `Hard ceiling = protocol.rounds_max (≤ 5) to guarantee termination.`
- `IDENTITY LOCK`
- `If substantive dissent persists after round cap → status:contested (never silently dropped)`
- `LOAD CONTEXT`
- `M3 fix (axon-bugfix01): `←` here was ASSIGNMENT-inside-condition — it overwrote`
- `MANDATORY keys on EVERY verdict (ADR-005, HANDOFF §4.3 L374-391):`
- `Narrate distributions VERBATIM: "{N}/{total} seats chose {winner}; {M}/{total} chose {alt}."`
- `OPINION-NEUTRAL WORDING constraint (HANDOFF §5.1 + worked-example-01 V-8.4):`
- `OUTPUT`
- `Optional: option_scores, dissent_class (protocol-supplied, e.g. weighted-vote, adversarial)`
- `PR-010: this inline math is now PINNED by the tested reference implementation in`
- `PREFERENTIAL: disagrees on values/priorities/risk-appetite/aesthetics only`
- `PROGRAM: hr-team-deliberator`
- `Prefer seat's self-reported dissent_class when present + well-formed; else classify from reason text.`
- `Required keys per seat: reason (str), answer (str), confidence (float in [0,1])`
- `SECTION:VALIDATE`
- `STEP 1 — SCHEMA VALIDATION (HANDOFF §4.3 step 2 + §9.2 rules 4-5)`
- `STEP 2 — BALANCED POSITION CALIBRATION (HANDOFF §4.3 step 3 — order-bias mitigation)`
- `STEP 3 — WEIGHTED SCORE VOTING (HANDOFF §4.3 default WSV algorithm)`
- `STEP 4 — DISSENT CLASSIFICATION (HANDOFF §4.3 dissent table + §12.7 IETF)`
- `STEP 5 — RE-ROUND LOGIC (HANDOFF §4.3 steps 6-7)`
- `STEP 6 — EMIT §4.3 VERDICT OBJECT`
- `SUBSTANTIVE → may trigger re-round; PREFERENTIAL → record only, no re-round.`
- `SUBSTANTIVE: claims factual/logical/safety/scope/evidence failure in the majority`
- `This ban is a CONTRACT INVARIANT asserted by the test suite.`
- `Trigger re-round ONLY on SUBSTANTIVE dissent; PREFERENTIAL dissent is recorded-only.`
- `Use only the FINAL round entries (max round per seat)`
- `W:council-transcript     — required; per-round per-seat utterances from hr-team-convener`
- `W:deliberator-verdict — §4.3 advisory verdict object (advisory_only:true, verdict_distribution`
- `W:hr-team-selector-result — required; initial weights + protocol + advisory_only from selector`
- ``reround=true` kwarg never propagated (inline EXEC args don't — H1 class): the convener`
- `advisory_only:true, human_review_required:true, recommendation, ranked_alternatives,`
- `budgeted round unconditionally so rounds-run < rounds-max was always false; it now`
- `contract-version: neuron-contract v1.1`
- `desc:    hr-team Layer 3 — aggregate council seat votes, classify dissent, emit advisory verdict`
- `dissent_rate, order_sensitive) make council quality testable rather than vibes.`
- `dissents. verdict_distribution MUST NOT be omitted even when all seats agree.`
- `domain: deliberation`
- `early-exits on consensus, leaving round budget for exactly this path. The inline`
- `family: [council, advisory, decision-support, aggregation]`
- `flagged the inline duplicate as a divergence risk (the "pinned to tested reference" was a comment,`
- `glossary: AXON-GLOSSARY v2`
- `helper (TOOL(hr-team, deliberation-metrics)), NOT a parallel inline copy — the gap-find council`
- `helper computed above) — the live math IS the unit-tested wsv()/aggregate_confidence(), no inline copy.`
- `hr-team-deliberator.md`
- `inputs-count: 2`
- `inputs:`
- `invocation_source: [program]`
- `next-suggests: [hr-team, hr-team-convener]`
- `not a wire). order_sensitive is the helper's deterministic forward-vs-reversed BPC signal.`
- `outputs-count: 1`
- `outputs:`
- `precondition: "true"`
- `reads W:hr-team-reround-request instead. One-shot guard preserves the hard ceiling.`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tests:   tests/test_hr_team_deliberator_contract.py`
- `tools/hr_team.py — wsv() / aggregate_confidence() / order_sensitivity() / deliberation_metrics()`
- `uniform 1/N. Passed through now; absent weights keep the uniform default.`
- `usage:   called via EXEC(hr-team-deliberator) from the hr-team router; consumes W:council-transcript`
- `used to be computed at line ~43 and never referenced again — aggregation was always`
- `v1 weights stay 1/N at emit time. WSV uses cardinal confidence; IIA is the sacrificed criterion.`
- `verdict-status with the warnings list exactly in the contested case.`
- `weight_s = 1/N; normalize so Σweight_s = 1`
- `weighted_score(answer_i) = Σ_s weight_s · confidence_s · indicator(seat_s.answer == answer_i)`
- `weighted_scores, aggregate_confidence, dissents, status)`
- `weighted_scores, aggregate_confidence, verdict_distribution (ALWAYS present — even unanimous),`
- `winner = argmax(weighted_score); aggregate_confidence = Σ_s weight_s · confidence_s`

## Depends on
- (none)
