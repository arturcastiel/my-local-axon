# Test-Suite Council Report — 2026-06-22
> 26-agent workflow (15 investigators -> consolidate -> 5-seat pruning council -> 5-seat vote).
> 359 files audited, 490s runtime, 1.31M tokens. Conservative bar: slow != prune; coverage > speed.

## Stats
- Usefulness: {"2": 3, "3": 57, "4": 166, "5": 133} (mean 4.19/5)
- Category: {"core": 230, "integration": 33, "conformance": 79, "meta": 8, "smoke": 8, "fixture": 1}

## Executive summary
SCOPE: 359 test files audited, 490s total wall-clock. The suite is healthy and high-value: mean usefulness 4.19/5, with 83.3% of files rated 4-5 and only 3 files (0.8%) rated 2 — and even those were not flagged for pruning. By category the suite is 64.1% core (230), 22.0% conformance (79), 9.2% integration (33), 2.2% meta (8), 2.2% smoke (8), 0.3% fixture (1).

WHERE THE TIME GOES: Runtime is extremely concentrated. The top 20 slowest files account for 432.6s (88.3%) of the 490s total, and just the top 6 account for 281.1s (57.4%). The single biggest cost centers are test_quality_loop.py (66.74s/10t, use5), test_tools_kernel.py (58.18s/143t, use5), and test_integration.py (57.95s/22t, use4). Critically, slowness correlates with VALUE here, not waste: of the 6 slowest files, 4 are rated use5 and 2 are use4. The expensive files are agent/proof/liveness/integration suites whose cost is inherent to exercising real behavior end-to-end. High test-count files are cheap per assertion (test_programs_md 0.04s/t, test_tool_import_parity 0.04s/t, test_tool_invocation_smoke 0.05s/t, test_tools_kernel 0.41s/t) — these are efficient parametrized batches, not bloat. The genuine per-test outliers are single-test files: test_dispatch.py (28.58s for 1 test, use3) and test_audit_compass.py (7.68s for 1 test, use4).

WHERE THE REDUNDANCY IS: One strong signal — test_liveness.py and test_reaudit_liveness.py share an IDENTICAL footprint (31.17s, 6 tests, use5 each), 62.3s combined (12.7% of total runtime). Identical duration and test count points to overlapping/re-run liveness coverage worth a dedup investigation. Secondary overlap clusters: a dispatch cluster (test_dispatch + test_dispatch_graph_routing, 45.4s combined) and an audit cluster (quality_loop, axon_audit_synapse, audit_compass, reaudit_liveness). The investigator flagged ZERO prune candidates, and this audit concurs: no file should be deleted. The opportunity is optimization (parallelization, fixture sharing, dedup of the liveness twin), not removal.

## Themes
- Redundancy cluster — the liveness twin: test_liveness.py (31.17s/6t/use5) and test_reaudit_liveness.py (31.17s/6t/use5) have byte-identical runtime and test counts. This is the clearest overlap signal in the suite (62.3s = 12.7% of total). Both are high-value, so the action is investigate-and-dedup (or share a fixture), NOT prune one.
- Redundancy cluster — dispatch/routing: test_dispatch.py (28.58s/1t/use3) and test_dispatch_graph_routing.py (16.85s/6t/use4) cover adjacent dispatch behavior (45.4s combined). The use3 single-test dispatch file is the weakest member and the best merge/refactor candidate.
- Redundancy cluster — audit family: test_quality_loop.py (66.74s/use5), test_axon_audit_synapse.py (19.79s/use4), test_audit_compass.py (7.68s/use4), and test_reaudit_liveness.py (31.17s/use5) form an audit/quality cohort with likely shared setup. Candidate for common-fixture consolidation to cut repeated startup cost.
- Excessive area — conformance breadth: conformance is 22% of all files (79). The large parametrized members (test_programs_md 392t, test_tool_import_parity 160t, test_tool_invocation_smoke 157t) are individually cheap per test (0.04-0.05s/t) and high-value, so this is broad coverage rather than excess. No trimming warranted; monitor only if file count keeps growing.
- Trivial / low-value tests: only 3 files rated use2 (0.8% of suite) and none were investigator-flagged. The thinnest individual case by efficiency is test_dispatch.py — a single test costing 28.58s at use3. Worth refactoring for speed, but its coverage is not trivial enough to drop.
- Slow-but-valuable (do not touch): the runtime budget is dominated by genuinely valuable suites — test_quality_loop (66.74s, use5), test_tools_kernel (58.18s/143t, use5), test_integration (57.95s/22t, use4), test_proof_mms (35.9s, use5). These exercise real agent/proof/integration paths; their cost is intrinsic. Speed them via parallelization and fixture reuse, never by deletion.
- Per-test outliers vs. batch efficiency: single-test slow files (test_dispatch 28.58s/t, test_audit_compass 7.68s/t) are the real per-test cost outliers, while high-count files amortize extremely well (test_tools_kernel 0.41s/t, test_programs_md 0.04s/t). Optimization effort should target the single-test outliers, not the large parametrized suites.

## Recommendation
HOLD THE CONSERVATIVE BAR: prune nothing. The investigator flagged 0 prune candidates and the data agrees — mean usefulness 4.19, only 0.8% of files at use2, and every slow file is rated use4 or use5. Slowness is a function of value, not waste, so coverage stays intact and speed is pursued only through non-destructive means.

PRIORITIZED ACTIONS (all preserve coverage):
1. Investigate the liveness twin first (highest ROI). test_liveness.py and test_reaudit_liveness.py have identical 31.17s/6t/use5 footprints (62.3s, 12.7% of total). Confirm whether re-audit truly re-runs the base liveness path; if so, share fixtures or parametrize into one suite to reclaim ~30s without losing any assertion. Do not delete either until overlap is proven.
2. Parallelize the top cost centers. The top 6 files are 57.4% of runtime (281s). Distributing the independent suites (quality_loop, tools_kernel, integration, proof_mms, both liveness files) across workers (e.g. pytest-xdist) is the single biggest wall-clock win and removes zero coverage.
3. Refactor the single-test slow outliers for speed, not removal. test_dispatch.py (28.58s for 1 test, use3) and test_audit_compass.py (7.68s/1t) carry heavy per-test setup; move shared startup into session/module fixtures. test_dispatch is also the natural merge candidate with test_dispatch_graph_routing if their coverage overlaps.
4. Consolidate fixtures across the audit family (quality_loop, axon_audit_synapse, audit_compass, reaudit_liveness) to amortize repeated environment setup.
5. Leave the large parametrized conformance/smoke suites alone — they are cheap per test (0.04-0.05s/t) and high-value; they are the model for how the slow suites should be structured.

BOTTOM LINE: A genuinely healthy suite. One real redundancy worth deduping (the liveness twin), a handful of slow single-test files worth speeding up, and a large optimization upside from parallelization. No deletions.

## Slowest 20 files
- tests/test_quality_loop.py 66.74s/10t use5
- tests/test_tools_kernel.py 58.18s/143t use5
- tests/test_integration.py 57.95s/22t use4
- tests/test_proof_mms.py 35.9s/13t use5
- tests/test_liveness.py 31.17s/6t use5
- tests/test_reaudit_liveness.py 31.17s/6t use5
- tests/test_dispatch.py 28.58s/1t use3
- tests/test_axon_audit_synapse.py 19.79s/7t use4
- tests/test_dispatch_graph_routing.py 16.85s/6t use4
- tests/test_programs_md.py 16.25s/392t use5
- tests/test_dual_agent_eval.py 12.09s/13t use5
- tests/test_lint_summary.py 10.6s/8t use4
- tests/test_program_tool_conformance.py 8.63s/5t use5
- tests/test_audit_compass.py 7.68s/1t use4
- tests/test_tool_invocation_smoke.py 7.41s/157t use5
- tests/test_tool_import_parity.py 6.05s/160t use4
- tests/test_freshness.py 5.32s/4t use5
- tests/test_self_care.py 5.27s/3t use4
- tests/test_cron_conformance.py 3.72s/5t use5
- tests/test_code_graph.py 3.22s/7t use5

## VOTE — candidates (every voted test shown)

### #1 [meaningless] → PRUNE  (keep 0 / merge 0 / prune 5)
- target: `tests/test_dispatch.py::test_dispatch_metrics_baseline`
- rationale: Its sole assertion `assert p1 >= 0.0 and p3 >= 0.0` is tautological (hit-ratios are always >= 0, the docstring even calls it advisory with no threshold), yet it spawns ~30 dispatch subprocesses costing 30-42s empirically (99.8% of the file's runtime) to verify nothing.
- votes:
  - prune: Sole assertion p1>=0.0 and p3>=0.0 is mathematically tautological (hit/n of non-negative counts is always >=0) and docstring says advisory/never-fail; it can never go red on any regression yet costs 33.4s of 33.4s file runtime spawning ~30 subprocesses, and corpus shape is already covered by sibling tests test_corpus_loaded/test_corpus_phrasing_distribution in <5ms.
  - prune: Verified: sole assertion p1>=0.0 and p3>=0.0 is mathematically always-true (hit/n with n>0), docstring says advisory/non-failing, and it burns 31.3s (~99.9% of the file) spawning ~30 subprocesses to assert nothing — a true tautological/dead test, not a neuron under test.
  - prune: Sole assertion p1>=0.0 and p3>=0.0 is mathematically tautological (counts/positive-n always >=0); docstring confirms advisory with no threshold, and the dispatch.py match subprocess path is really covered by test_dispatch_graph_routing.py, so ~30s buys zero coverage.
  - prune: Verified: the sole assertion `assert p1 >= 0.0 and p3 >= 0.0` is tautological (hit-ratios are non-negative by construction) and the docstring marks it advisory with no threshold, yet it spawns ~30 dispatch subprocesses for 30-42s to verify nothing — corpus shape is already covered by test_corpus_loaded/phrasing_distribution, so this is a true dead/tautological test.
  - prune: Verified tautological: sole assertion `p1 >= 0.0 and p3 >= 0.0` (line 66) is always true since hits only increment from 0; docstring/comment call it advisory with no threshold, yet it spawns 30 dispatch subprocesses to verify nothing -- corpus shape already covered by test_corpus_loaded/test_corpus_phrasing_distribution.

### #2 [merge] → MERGE  (keep 1 / merge 4 / prune 0)
- target: `tests/test_reaudit_liveness.py::test_check_green_after_reclassify`
- rationale: This 21-28s subprocess green-gate asserts the same 'no un-grandfathered orphans in the live tree' invariant already covered in-process by test_liveness.py::test_resolve_live_tree_matches_allowlist, so its orphan-check should be folded into that test (keeping only a thin CLI-exit smoke if the entry-point path is still wanted).
- votes:
  - keep: Not a true duplicate: this is the only test exercising the literal `python3 tools/liveness.py check` CLI contract (returncode 0, stdout JSON ok/orphans) that crucible.json:268 wires as a live gate, whereas test_resolve_live_tree_matches_allowlist only tests the in-process resolver lib; and that in-process test is itself 15.46s (not the cheap alternative the merge premise assumes), so folding would drop real end-to-end gate coverage with negligible time savings — keep on doubt per no-false-green.
  - merge: Verified the 21-28s subprocess green-gate asserts the identical orphans==[] invariant already checked in-process by test_liveness.py::test_resolve_live_tree_matches_allowlist (same res/allow filter); fold the orphan check there and keep a thin CLI exit-code smoke for the entry-point path.
  - merge: Its orphans==[] invariant duplicates test_liveness.py::test_resolve_live_tree_matches_allowlist (same in-process check), but it uniquely exercises main()'s CLI JSON shape + exit-code gate; fold the orphan check into the in-process test and keep a thin CLI-exit smoke.
  - merge: Confirmed the orphan invariant (resolve() + _allowlist() filter) is already asserted in-process by test_liveness.py::test_resolve_live_tree_matches_allowlist, so the redundant 21-28s subprocess orphan-check should fold there; keep only a thin CLI-exit smoke since the returncode==0/ok-JSON exercises main()/sys.exit not covered in-process (Core Rule 13), making this a merge not a prune.
  - merge: Confirmed overlap: this 21-28s subprocess test asserts the same no-un-grandfathered-orphans invariant as in-process test_liveness.py::test_resolve_live_tree_matches_allowlist; fold the orphan-check there and keep only a thin CLI-exit/returncode smoke since the entry-point (ok/orphans JSON + exit 0) is the only unique coverage.