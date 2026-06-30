# 04 — Log: HR-Team Improvements

## SESSION START — 2026-06-22T08:20:00Z
project:  hr-team-improvements   phase: study   workflow-step: build
branch:   fix/wave-g-residual-hardening
seeded:   from axon-rearm META-FINDING + owner cross-session confirmation. Study DONE at seed.
next:     code-dev plan → PR backlog (5 fix vectors). Lead = propagate fail-closed guard to for-use checkout.

## 2026-06-22 · test-suite council + executed verdict
Ran a 26-agent council (15 investigators → consolidate → 5-seat propose → 5-seat vote) over all 359 test
files / 4723 tests. 1.31M tokens. Report: research/test-suite-council-2026-06-22.md.
Verdict (conservative bar held): only 2 of 4723 surfaced — PRUNE 1 (tautological dispatch metrics test,
unanimous) + MERGE 1 (liveness CLI test, 4-1, dissent preserved). Plus the council-recommended liveness
dedup (shared resolve fixture). Executed on branch chore/test-council-actions → MR !179. Full gate green.
Net ~60s off the suite, zero coverage lost. Bigger win (xdist parallelism) scoped separately.

## 2026-06-22 · xdist gate parallelization (MR !180)
The council's "real fix" (parallelize, don't delete). Suite proven race-free under 12 workers
(naive -n auto: 4708 pass / 0 races). Crucible pytest control -> `-n auto`: ~8:43 -> ~3:30 (~2.5x).
3 files, zero test logic touched. Gate "failure" was NOT flakiness — adding pytest-xdist to pyproject
tripped test_requirements_intent (declared-deps-must-be-imported-or-whitelisted); xdist is a plugin →
whitelisted (1 line). Measure-don't-assume corrected the wrong "revert it, it's flaky" conclusion.

## 2026-06-22 · parallel gate: flaky → root-caused → fixed (MR !181)
The xdist gate (!180) was flaky AS A GATE (1 red / 4 runs on merged main) — caught by the post-merge gate
(per-branch greens don't cover a merged combo). Root cause: pytest CACHE races across xdist workers (the one
var differing green-vs-red was -p no:cacheprovider). Fix (!181): gate cmd -> `-n auto -p no:cacheprovider`.
Verified 9/9 green cache-disabled (5 dedicated + 3 prior + 1 gate-context) vs 1 red cache-on.
main gate now ~8:43 serial -> ~3:35 parallel (~2.4x), RELIABLE. Serial fallback (fix/gate-serial-restore)
pushed as insurance, now superseded/unmerged. Lesson: gate the MERGED state, not just branches; and the
diagnostic data (not a guess) found the cause.

## SESSION END — 2026-06-22T12:40:00Z
Context cleared. NEXT: code-dev plan (5 fix vectors -> PR backlog). Lead = propagate fail-closed run_seats guard to the for-use checkout. See ../axon-rearm/SESSION-HANDOFF-2026-06-22.md.

## 2026-06-22T14:35:56Z · STUDY EXPANSION — owner scope directive (10 fix-vectors)
- Owner added 4 scope areas to the original 5 safety vectors: (6) council data-input, (7) council modes,
  (8) make-it-smarter deliberation, (9) AXON-can't-use-it usability — plus (10) run_seats real backend (refines orig #2).
- Grounded via read-only Explore sweep of hr-team{,-selector,-convener,-deliberator}.md + tools/hr_team.py + HANDOFF.md + tests.
- ROOT CAUSE surfaced: DUAL DIVERGENT IMPLEMENTATIONS — rich .md neurons vs thin tools/hr_team.py shadow
  (hardcoded seats L305, dead --context L271, doc-only F1..F6 modes, templated _build_verdict, stub-only run_seats).
  Keystone PR = resolve the dual-path (unblocks 6/7/8/10). All findings file:line-pinned in 01-study.md sec.7-9.
- Test posture gap logged: behavioural suite runs only against the stub; no real-council / aggregation-correctness test.
- Study 47 -> 122 lines. Phase still 'study'; READY for: code-dev plan.

## 2026-06-22T14:43:17Z · ADR-001 — unification direction decided (owner): NEURONS-AUTHORITATIVE
- Owner chose: .md neurons = single authoritative runtime; tools/hr_team.py DEMOTED to deterministic helper library + test fixture.
- Hardcoded pipeline (seats L305, templated _build_verdict, index-stub confidence) relabelled fixture/stub — never a real verdict path.
- Division of labour: COGNITION in neurons (agent-executed); DETERMINISTIC MATH/IO in TOOL()-called UNIT-TESTED Python helpers
  (WSV, BPC compare, confidence agg, F-tuple parse, registry/keyword map, manifest, audit, schema-validate); run_seats = lone fail-closed seam.
- Keystone V9 reframed: demote hr_team.py to helpers+fixture + route CLI flags (router hr-team.md) into W: keys neurons read.
- Recorded as ADR-001 in 01-study.md sec.10. Project now plan-ready with an unambiguous keystone.

## 2026-06-22T14:46:26Z · PHASE 2 PLAN COMPLETE — 11 PRs, dependency-ordered
- 02-plan.md + 02-prs.md + 03-prs/DAG.json (11 nodes / 11 edges, verify ok) written from the 10 fix-vectors + ADR-001.
- Waves: 0-Safety (PR-001 fail-closed→for-use, PR-002 conformance) · 1-Keystone (PR-003 demote hr_team.py, PR-004 route flags)
  · 2-Helpers (PR-005 context, PR-006 mode-resolver, PR-007 roster-map, PR-008 deliberation-math) · 3-Seam (PR-009 real run_seats)
  · 4-Close (PR-010 reconcile checkouts, PR-011 e2e real-council tests).
- Critical path: PR-003→PR-004→{005,006,007,009} ; 009→011. Safety PR-001/002 independent, land first.
- Fix-vector coverage complete (V1-V10). Phase study=done, plan=done, pr=active. _meta.phase→3-pr.
- NEXT: code-dev pr PR-001 (or PR-003 keystone) — write per-PR specs.

## 2026-06-22T15:00:01Z · COUNCIL + RE-GROUND + PLAN v2 (16 PRs)
- Ran a REAL hr-team council (5 live sub-agent seats, sealed R1, no stub): graded each PR; plan B-, study A-; PR-009[XL] graded D.
- Owner voted ALL 10 suggestions. VERIFIED claims first: (A) for-use checkout 289 behind & NEVER had tools/hr_team.py — 'for-use fail-open' premise STALE/corrected; (B) main() prints a §4.3 verdict (dual path structural); (C) deliberator L65 2nd run_seats call-site; (D) dev stub fail-closed + STUB-marked.
- Study re-grounded: §11 added (corrections + verified facts). Plan rebuilt v2: 11→16 PRs.
  Split PR-009→011/012/013; hardened keystone PR-004 (collapse main); new PR-003 mechanical NEURON fail-closed guard (true fix); PR-006 sole-seam; PR-014 observability/provenance; tests-forward + injectable fake (011) + measurable smarter (010); PR-001/015 re-grounded for-use sync+parity.
- DAG rebuilt (16 nodes), verify ok. NEXT: owner review v2, then code-dev pr.

## 2026-06-22T15:55:29Z · AUTONOMOUS EXECUTION — PR-001 + PR-004 merged
- PR-001 (!182): re-grounding doc; loop self-corrected 2 pre-commit hooks + 1 doc_index test failure.
- PR-004 (!183): KEYSTONE collapse. 3-seat design council (ship-with-changes) caught the import-seam hole; adopted all hardening:
  main() refuses (exit 2, typed stderr) + emits only marked non-verdict seam shape under 2 locks; verdict-hood positively gated by
  'kind' discriminator; seal_advisory_verdict requires authorization (gates import seam); audit-bundle write dropped from main;
  contract tests re-homed import-level + 6 negative collapse tests. Crucible gate GREEN (full suite).
- PR-002 ABSORBED into PR-004 (CLI conformance delivered there) + PR-003 (neuron conformance). DAG: 001/004 merged, 002 skipped.
- NEXT: PR-003 mechanical fail-closed guard in the NEURON path (council on the fan-out-receipt design).

## 2026-06-22T16:17:45Z · MILESTONE — Wave 0 + Wave 1 (keystone) COMPLETE (5 PRs merged)
- PR-001 (!182) re-ground doc · PR-004 (!183) keystone collapse + import-seam seal · PR-003 (!184) live consumer gate
  · PR-005+006 (!185) single invocation contract + sole-seam contract. PR-002 absorbed into PR-004.
- 3 design councils run; caught 2 real holes (import-seam bypass; PR-004 gate being dead-code on the live path).
- All merges crucible-green; autonomous loop (commit→gate→push→MR→squash-merge) stable; floor never touched.
- NEXT: Wave 2 helpers — PR-007 context-load, PR-008 mode resolver, PR-009 roster map, PR-010 deliberation math.
  These need a deterministic-helper CLI surface (subcommands) so neurons can TOOL()-call them, since main() now refuses.

## 2026-06-22T17:11:18Z · WAVE 2 COMPLETE — helpers (PR-007..010 merged, 10 PRs total, ~62%)
- PR-007 (!186) context-load + helper CLI surface · PR-008 (!187) F1..F6 mode resolver (31 fragments reachable)
  · PR-009 (!188) deterministic roster keyword/domain map + fail-closed (stopword-filtered) · PR-010 (!189) deliberation
  math helpers (WSV/BPC/confidence/metrics) — _build_verdict uses them, killed the templated 0.25xx aggregate; measurable 'smarter'.
- hr-team contract tests now 48. All gates green; merge 405-race handled by retry-until-merged loop.
- NEXT: Wave 3 — real run_seats backend (PR-011 schema+spawn+fake → PR-012 parallel fan-out → PR-013 retry/re-round) +
  the deferred un-forgeable receipt. Convening a design council (the real fan-out is agent-behavior; the testable core is
  the injectable fake + schema + receipt).

## 2026-06-22T18:41:59Z · GAP-FIND COUNCIL (4 seats) — 16 PRs done, full suite 4764 green, BUT a serious gap found
- ALL 16 plan PRs merged (!182-!195); PR-002 absorbed. Full suite: 4764 passed / 16 skipped.
- GAP-FIND verdict (harness/app-sec/eval/challenger, all HIGH-converging): the Python enforcement (seal,
  verify_surfaceable, receipt, deliberation math) is REAL + tested but UNWIRED — the live neuron path
  bypasses all three gates with string literals (same dead-code-on-live-path pattern as the PR-003 council found):
  G1 deliberator hand-writes kind:"advisory_verdict", never calls seal_advisory_verdict.
  G2 router surface gate is a bare `IF result.kind ≠ advisory_verdict` — never calls verify_surfaceable; receipt machinery test-only.
  G3 deliberator re-implements WSV inline; _build_verdict + tested math not on the live path.
  G4 call_id never minted on the live path → 'unknown'. G5 for-use parity test always skips. G6 conformance test partly tautological.
  Deepest: the real fan-out is agent-behavior (ADR-001 design); true un-forgeability needs a harness dispatcher that doesn't exist (honest ceiling).
- ACTION (owner directive: close gaps auto): GAP-CLOSURE wave — wire the live router path through the Python gates
  (mint call_id; deliberator emits unsealed aggregation; router seals via TOOL + verify_surfaceable, fail-closed),
  fix the tautological conformance test, honest-downgrade the always-skip parity test, + the smaller eval test gaps.

## 2026-06-22T19:35:05Z · GAP-CLOSURE COMPLETE — GAP-001 + GAP-002 merged (!196, !197)
- GAP-001 (!196): wired the LIVE council path through the Python gates — deliberator emits unsealed
  aggregation; router mints call_id + seals via authorized TOOL + runs verify_surfaceable (was a bare
  `kind` string compare that bypassed seal/verify — the council's #1 HIGH finding). Closes G1,G2,G4.
- GAP-002 (!197): deliberator core math via TOOL(deliberation-metrics) not inline copy (G3); conformance
  test de-tautologized (one frozen literal); _build_verdict uses real threaded variant (G5); BACKEND constant removed.
- 18 MRs total (!182-!197). 6 design councils. hr-team tests ~80 -> ~165.
- RESIDUAL (genuine DESIGN-LIMITS, not closeable in-process — owner decisions):
  R1 the REAL fan-out is agent behavior (ADR-001); no executable substrate; can't be unit-tested. Needs a harness dispatcher.
  R2 the receipt is forgery-RESISTANT/detectable, not unforgeable, absent a dispatcher-held key the agent can't read.
  R3 require_receipt is OFF (no real receipts exist); turning it on = fail-closed-no-councils until R1's dispatcher exists.
  R4 for-use parity test owner-activated (for-use has no hr_team.py / is 289 behind — sync is an ops decision).
  R5 minor: classify_dissent fixture-vs-engine inconsistency; receipt freshness-boundary coverage (low value).
- STATUS: the closeable gap-closure is COMPLETE. Residual items require owner decisions / harness capabilities.

## 2026-06-22T20:09:45Z · COUNCIL SLATE EXECUTED — D3 synced, D1 reframed, D2 deferred (advisory council, 4 seats)
- Owner ran a REAL hr-team council on the 3 residual decisions. Verdict (contested on D1; app-sec dissent for fail-closed preserved):
  KEY REFRAME — provenance only matters across a TRUST BOUNDARY; single-agent use has none (convener = relying party).
- D3 DONE: for-use checkout synced (ff-only autostash; 289→0 behind); hr_team.py now BYTE-IDENTICAL to dev; parity guard
  passes live (AXON_FORUSE_CHECKOUT). The original for-use fail-OPEN risk is RESOLVED. (for-use local config in its stash@{0}.)
- D1 DONE: require_receipt stays OFF; receipt reframed as a RUN-INTEGRITY LOG (catches silent non-convening), not a security
  control in single-trust use; the zero-signal blanket provenance banner (fired on 100% of councils) dropped.
- D2 DEFERRED behind a WRITTEN TRIGGER: build the harness sub-agent dispatcher + un-forgeable signed receipts ONLY when a named
  EXTERNAL relying party audits verdicts AND a key external to the convening agent exists. Until then it's "a heavier lock on a
  door with no wall" (challenger). The smallest-viable tested dispatch() seam is optional (turns fan-out into a tested code path).
