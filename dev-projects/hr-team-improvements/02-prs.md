# PR List — HR-Team Improvements (v2 · council-revised)
Updated: 2026-06-22  ·  Total PRs: 16  ·  Source: 01-study.md (10 vectors + ADR-001 + §11 re-grounding) + hr-team council (all 10 suggestions adopted)

> v2 supersedes the 11-PR v1. Changes: PR-009[XL] split into 3 (PR-011/012/013); keystone hardened to COLLAPSE not relabel (PR-004);
> for-use premise re-grounded (PR-001/015); new mechanical neuron fail-closed guard (PR-003); sole-seam reconcile (PR-006);
> observability/provenance (PR-014); measurable 'smarter' + tests-forward + injectable-fake seam (PR-010/011/016). Dependency-ordered.

## PR-001 — Re-ground the for-use risk + sync stale checkout
- **Status:** MERGED (!182)
- **Wave:** 0 · Safety/Re-ground
- **Vector:** V1 (re-grounded)  ·  **Council:** #3
- **Complexity:** S
- **Scope:** docs + ops: for-use is 289 behind origin/main & never had tools/hr_team.py; record that sync inherits the dev fail-closed version; correct the study's stale 'for-use fail-open hr_team.py' locus
- **Depends on:** none
- **Why:** Verified: no fail-open hr_team.py exists in for-use to patch. The real locus is the neuron seam (PR-003). Avoid building on a false premise.
- **Spec:** 03-prs/PR-001.md (not written yet)

## PR-002 — Conformance test: stub markers can never reach a surfaced verdict
- **Status:** ABSORBED into PR-004 (CLI conformance) + PR-003 (neuron conformance)
- **Wave:** 0 · Safety/Re-ground
- **Vector:** V3 (strengthened)  ·  **Council:** #2(appsec)
- **Complexity:** M
- **Scope:** tests/: assert STUB reason + fabricated confidence + status can NEVER appear in any surfaced verdict (CLI or neuron) — not just exit codes
- **Depends on:** none
- **Why:** Existing test only checks run_seats raises. The real hole is a marked-but-shaped verdict reaching a user. Lock the property end-to-end.
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — Mechanical fail-closed guard in the NEURON council path
- **Status:** not-started
- **Wave:** 0 · Safety/Re-ground
- **Vector:** V1b (new, re-grounding)  ·  **Council:** re-ground
- **Complexity:** M
- **Scope:** hr-team-convener.md / deliberator.md + a run-receipt: a neuron council that did NOT actually fan out to real sub-agents cannot surface a §4.3 verdict (require a fan-out receipt the deliberator checks)
- **Depends on:** none
- **Why:** The TRUE fail-open locus: the neuron path has no mechanical guard — a faithful council with no real run_seats fabricates (bit axon-rearm + the for-use session).
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — Collapse the dual path: main() cannot surface a verdict
- **Status:** MERGED (!183) · council-hardened
- **Wave:** 1 · Keystone
- **Vector:** V9a (hardened)  ·  **Council:** #2
- **Complexity:** M
- **Scope:** tools/hr_team.py main() (L319-346 verified to print(json.dumps(verdict))): structurally refuse/exit or delegate to the neuron runtime; CLI becomes fixture/helper-only, never emits a §4.3 verdict
- **Depends on:** none
- **Why:** Verified dual path is structural. Relabeling as 'fixture' is cosmetic; main() must be incapable of self-aggregating or the split re-emerges.
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — Route CLI flags → W: keys via router (single contract + validation)
- **Status:** not-started
- **Wave:** 1 · Keystone
- **Vector:** V9b  ·  **Council:** orig
- **Complexity:** M
- **Scope:** hr-team.md: marshal --task/--domain/--roster/--mode/--context/--protocol into validated W:hr-team-* keys the neurons read; one invocation contract
- **Depends on:** PR-004
- **Why:** One authoritative entry (the neuron path). Removes the dual-path ambiguity + adds input validation at the boundary.
- **Spec:** 03-prs/PR-005.md (not written yet)

## PR-006 — Declare convener the sole run_seats seam; reconcile 2nd call-site
- **Status:** MERGED (!185)
- **Wave:** 1 · Keystone
- **Vector:** V9c (new)  ·  **Council:** #10
- **Complexity:** S
- **Scope:** hr-team-deliberator.md:64-65 (verified 2nd run_seats call-site): route the retry through the convener seam or document the exception; one cognition boundary
- **Depends on:** PR-004
- **Why:** Verified the deliberator pokes run_seats on retry — 'lone seam' is currently false. Two seam call-sites can diverge.
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — Context-load helper + wire --context (sanitized, fail-closed) + tests
- **Status:** MERGED (!186)
- **Wave:** 2 · Helpers
- **Vector:** V6  ·  **Council:** #5(tests)
- **Complexity:** M
- **Scope:** tools/hr_team.py deterministic path-or-text loader + hash + sanitize (TOOL-callable) + unit tests; SELECTOR/CONVENER read W:hr-team-context
- **Depends on:** PR-005
- **Why:** --context is dead (parsed, never used). Untrusted input channel → sanitize + fail-closed. Ships with its own tests.
- **Spec:** 03-prs/PR-007.md (not written yet)

## PR-008 — Deterministic F1..F6 mode resolver + table-driven tests
- **Status:** MERGED (!187)
- **Wave:** 2 · Helpers
- **Vector:** V7  ·  **Council:** #5(tests)
- **Complexity:** L
- **Scope:** tools/hr_team.py: expand preset→6-tuple, parse, validate enums, return family-fragment paths (pure fn, fully testable); CONVENER calls via TOOL + loads fragments
- **Depends on:** PR-005
- **Why:** The 6-tuple system is documentation-only (zero parsing). Highest-value pure-function test win.
- **Spec:** 03-prs/PR-008.md (not written yet)

## PR-009 — Roster keyword/domain map + fail-closed gate + tests
- **Status:** MERGED (!188)
- **Wave:** 2 · Helpers
- **Vector:** V4  ·  **Council:** #5(tests)
- **Complexity:** M
- **Scope:** tools/hr_team.py: the deterministic 'rules' map (HANDOFF.md:231) over _REGISTRY.md; SELECTOR pre-pass before DERIVE; weak/empty/mismatch → fail-closed + loud + tests
- **Depends on:** PR-005
- **Why:** Roster matching is non-deterministic prose that mis-matched professions. Deterministic-first + fail-closed closes the 'LLM took over' gap.
- **Spec:** 03-prs/PR-009.md (not written yet)

## PR-010 — Deliberation math helpers + golden-vector tests + measurable 'smarter'
- **Status:** MERGED (!189)
- **Wave:** 2 · Helpers
- **Vector:** V8 (measurable)  ·  **Council:** #5,#7
- **Complexity:** L
- **Scope:** tools/hr_team.py: WSV/BPC/aggregate-confidence as unit-tested fns + golden vectors; define smartness metrics (order-sensitivity delta, dissent-class precision vs fixtures); DELIBERATOR calls them
- **Depends on:** PR-004
- **Why:** 'Smarter' must be measurable, not vibes. Kills templated _build_verdict-as-truth + the 0.2533 stub aggregate; math is provable now.
- **Spec:** 03-prs/PR-010.md (not written yet)

## PR-011 — Seam schema v2 (variant/effort) + single-seat spawn + injectable fake
- **Status:** MERGED (!190)
- **Wave:** 3 · Seam (split 1/3)
- **Vector:** V10a  ·  **Council:** #1,#4,#5,#9
- **Complexity:** M
- **Scope:** run_seats(messages)→responses schema extended to carry per-seat variant/effort (convener emits them, tool drops them today L310-317); single-seat real spawn; a record/replay injectable fake backend
- **Depends on:** PR-005
- **Why:** Thin real slice pulled FORWARD beside the keystone; the injectable fake makes the whole seam deterministically testable (no flaky live sub-agents).
- **Spec:** 03-prs/PR-011.md (not written yet)

## PR-012 — Parallel fan-out + sealed Round-1
- **Status:** MERGED (!191) · council-recut to receipt-provenance keystone
- **Wave:** 3 · Seam (split 2/3)
- **Vector:** V10b  ·  **Council:** #1
- **Complexity:** L
- **Scope:** run_seats spawns all seats in parallel (sealed R1, fresh system re-injection per round) via the harness sub-agent fan-out
- **Depends on:** PR-011
- **Why:** The real council cognition. Split out of the old XL so it is independently reviewable.
- **Spec:** 03-prs/PR-012.md (not written yet)

## PR-013 — Retry + re-round on invalid/contested
- **Status:** MERGED (!192)
- **Wave:** 3 · Seam (split 3/3)
- **Vector:** V10c  ·  **Council:** #1
- **Complexity:** M
- **Scope:** one-retry-on-bad-JSON (hr-team-convener.md:210-218) + substantive-dissent re-round (deliberator) wired to the real seam + the math helpers
- **Depends on:** PR-012, PR-010
- **Why:** Final seam slice; depends on real fan-out (012) and the dissent math (010). Completes the run_seats split.
- **Spec:** 03-prs/PR-013.md (not written yet)

## PR-014 — Observability/audit of REAL councils (signed provenance)
- **Status:** MERGED (!193)
- **Wave:** 4 · Close
- **Vector:** V-new  ·  **Council:** #6
- **Complexity:** M
- **Scope:** audit-bundle + verdict carry signed provenance that responses came from real fan-out (not the fake/stub); surfaced verdicts assert provenance present
- **Depends on:** PR-011
- **Why:** The fail-closed thesis is unprovable in production without provenance. Closes the 'is this council real?' question mechanically.
- **Spec:** 03-prs/PR-014.md (not written yet)

## PR-015 — for-use sync + cross-checkout parity test
- **Status:** MERGED (!194)
- **Wave:** 4 · Close
- **Vector:** V5 (re-grounded)  ·  **Council:** #8
- **Complexity:** M
- **Scope:** sync for-use to origin/main (289 behind); once hr_team.py is present, a parity test asserts both checkouts' hr_team.py are byte/AST-identical
- **Depends on:** PR-001, PR-004
- **Why:** Re-grounded V5: not 'reconcile divergence' but 'sync + prevent future divergence by test, not by doc'.
- **Spec:** 03-prs/PR-015.md (not written yet)

## PR-016 — End-to-end real-council + aggregation-correctness suite (via injectable fake)
- **Status:** not-started
- **Wave:** 4 · Close
- **Vector:** V3/V8 e2e  ·  **Council:** #5,#7
- **Complexity:** L
- **Scope:** tests/: run a full council via the deterministic injectable fake (PR-011); exercise F-tuple parser, --context, BPC/dissent/re-round/contested on controlled seat outputs — deterministic, not flaky
- **Depends on:** PR-010, PR-012, PR-013
- **Why:** Proves the smart deliberation actually runs, deterministically. The fake seam (PR-011) makes this non-flaky — eval's core objection answered.
- **Spec:** 03-prs/PR-016.md (not written yet)

