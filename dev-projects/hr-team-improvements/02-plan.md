# High-Level Plan — HR-Team Improvements (v2 · council-revised)
Updated: 2026-06-22  ·  16 PRs  ·  Source: study (10 vectors + ADR-001 + §11 re-grounding) + hr-team council (all 10 suggestions)

## What changed from v1 (why this is better)
The hr-team council (5 real seats) graded v1 PLAN B-, STUDY A-, and flagged PR-009[XL] as D. All 10 suggestions adopted +
verification re-grounded two false premises. Concretely:
- PR-009[XL] mega-PR → SPLIT into PR-011 (schema+single-spawn+fake), PR-012 (parallel fan-out), PR-013 (retry/re-round).
- Keystone hardened: PR-004 makes main() STRUCTURALLY incapable of emitting a verdict (verified L319-346) — collapse, not relabel.
- for-use premise CORRECTED: it is 289 commits behind & never had hr_team.py — so PR-001/PR-015 become re-ground + sync, not 'patch a fail-open'.
- New PR-003: the TRUE fail-open fix — a MECHANICAL fail-closed guard in the NEURON path (a fan-out receipt the deliberator checks).
- New PR-006: reconcile the verified 2nd run_seats call-site (deliberator L65) — one seam.
- New PR-014: observability/signed provenance that a verdict came from real fan-out (fail-closed thesis unprovable in prod otherwise).
- Tests pulled FORWARD: each helper PR (007/008/009/010) ships its own tests; PR-011 adds an injectable record/replay fake so the
  fan-out is deterministically testable; PR-016 e2e runs on the fake (not flaky live sub-agents). 'Smarter' (PR-010) made measurable.

## Architecture (ADR-001, unchanged): neurons authoritative
Neurons are the single runtime; tools/hr_team.py = deterministic unit-tested helper library + fixture; run_seats = the lone cognition
seam (real harness sub-agent fan-out). Cognition in neurons; deterministic math/IO in TOOL-called tested helpers.

## Waves
- **0 · Safety / re-ground** — PR-001 (re-ground+sync for-use), PR-002 (stub-never-surfaces test, strengthened), PR-003 (mechanical neuron fail-closed guard — the real fix).
- **1 · Keystone** — PR-004 (collapse main()), PR-005 (route flags + validate), PR-006 (sole seam / reconcile 2nd call-site).
- **2 · Helpers (parallel, each with tests)** — PR-007 context, PR-008 mode resolver, PR-009 roster map, PR-010 deliberation math + measurable smarter.
- **3 · Seam (split 3)** — PR-011 schema+single-spawn+fake (pulled forward), PR-012 parallel fan-out, PR-013 retry/re-round.
- **4 · Close** — PR-014 observability/provenance, PR-015 for-use sync + parity test, PR-016 e2e real-council via fake.

## Critical path
PR-004 → PR-005 → {PR-007, PR-008, PR-009, PR-011} ; PR-011 → PR-012 → PR-013 ; {PR-010,PR-012,PR-013} → PR-016.
Safety PR-001/002/003 are independent — land first.

## Council suggestion → PR coverage (all 10)
1 split-009 → 011/012/013 · 2 collapse-not-relabel → 004 · 3 re-verify-for-use → done+001/015 · 4 pull-seam-forward → 011 ·
5 tests-forward+fake → 007/008/009/010 + 011 + 016 · 6 observability → 014 · 7 measurable-smarter → 010+016 ·
8 parity-test → 015 · 9 seam-schema variant/effort → 011 · 10 2nd-call-site → 006.
