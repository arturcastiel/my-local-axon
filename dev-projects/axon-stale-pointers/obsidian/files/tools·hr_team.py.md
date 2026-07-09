---
tags: [code, file]
path: tools/hr_team.py
---

# tools/hr_team.py

> 68 symbol(s) · 2 outbound file dependency(ies)

## Symbols
- `Append a fan-out receipt to the out-of-band ledger workspace/log/receipts/<date>`
- `Balanced Position Calibration (HANDOFF §4.3): run WSV on the original vs reverse`
- `Build a deterministic, CONTENT-KEYED fake run_seats backend for tests (PR-011).`
- `Build a per-seat fan-out receipt (PR-012). The REAL receipt is written OUT-OF-BA`
- `Build the §4.3 AGGREGATION (NOT a sealed verdict).      ADR-001 / PR-004: this h`
- `C2 fix (axon-bugfix01): write_audit_bundle was fully implemented and test-covere`
- `Classify a dissent SUBSTANTIVE vs PREFERENTIAL (HANDOFF §4.3 / deliberator STEP`
- `Consumer/surface gate (PR-003): a council verdict may be SURFACED only if it is`
- `Decide the outcome after a round (HANDOFF §4.3 re-round): a SUBSTANTIVE dissent`
- `Deterministic keyword/domain roster pre-pass (PR-009 / OD-C). Task tokens are ma`
- `GAP-001: the live surface gate (was a bare `kind` string compare in the router).`
- `GAP-001: the router/dispatcher seals the deliberator's aggregation through the A`
- `Load council context from a path OR literal text (PR-007). Deterministic + sanit`
- `Measurable deliberation-quality metrics (PR-010 'smarter'): the quantitative sig`
- `Mint a call-id per HANDOFF §10.1: YYYY-MM-DDTHHMMSSZ-{slug8}-{hash8}.`
- `Namespace`
- `Normalize a per-seat messages item → (messages, variant, effort, seat). Accepts`
- `Parse the profession _REGISTRY.md → {slug: domain}. Domains are '## DOMAIN: X' h`
- `Post-hoc observability over surfaced councils (PR-014): for a batch of verdicts,`
- `Resolve a mode string — a named preset OR an F1..F6 6-tuple 'a+b+c' (any order,`
- `Seam (ADR-002): execute ONE advisory council round. Returns one     {reason:str,`
- `Stamp the verdict discriminator. ADR-001: ONLY the deliberator neuron path is`
- `The sub_call_ids present in the out-of-band ledger for `date` — the provenance t`
- `True only for a SEALED advisory verdict (carries the kind discriminator + keys).`
- `Verify a verdict's fan-out receipt (PR-012). REAL checks, fail-closed:       - r`
- `Weighted Score Voting (HANDOFF §4.3): weighted_score(answer) = Σ_s w_s·conf_s·[a`
- `Write per-call audit bundle to my-axon/hr-team/councils/{call_id}/.     ADR-008`
- `_build_manifest()`
- `_build_verdict()`
- `_cmd_deliberation_metrics()`
- `_cmd_load_context()`
- `_cmd_match_roster()`
- `_cmd_mint_call_id()`
- `_cmd_provenance_audit()`
- `_cmd_resolve_mode()`
- `_cmd_seal()`
- `_cmd_verify_surfaceable()`
- `_cmd_write_audit_bundle()`
- `_derive_invocation_mode()`
- `_frag_slug()`
- `_ledger_sub_call_ids()`
- `_parse_catalog()`
- `_resolve_seats()`
- `_seat_meta()`
- `aggregate_confidence()`
- `classify_dissent()`
- `deliberation_metrics()`
- `hr_team.py`
- `is_advisory_verdict()`
- `load_context()`
- `main()`
- `make_fake_backend()`
- `make_fanout_receipt()`
- `match_roster()`
- `mint_call_id()`
- `order_sensitivity()`
- `parse_args()`
- `provenance_audit()`
- `reround_decision()`
- `resolve_mode()`
- `run_seats()`
- `seal_advisory_verdict()`
- `verify_fanout_receipt()`
- `verify_surfaceable()`
- `write_audit_bundle()`
- `write_fanout_receipt()`
- `wsv()`
- `Σ_s w_s·conf_s with normalized weights (HANDOFF §4.3).`

## Depends on
- [[_unknown_]]
- [[tools·_axon_paths.py]]
