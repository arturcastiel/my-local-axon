# Project: AXON-LANG consolidation — one parser, the deferred read-side, and cleanup
slug:            axonlang-consolidate
schema-version:  v4
status:          complete
legacy:          false
phase:           complete (pivoted to lead-fixes; all done)
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          axon-improvements
sub-projects:    []
created:         2026-07-14
updated:         2026-07-14 (COMPLETE — MR !207; 3 confirmed lead-bugs fixed; consolidation deemed unnecessary)

## Working Context
- PIVOT (2026-07-14): R4 verification (VERIFY-FINDINGS.md) turned the 4 quarantined run-3 leads into
  3 CONFIRMED bugs + 2 PARTIAL + 1 doc-defect. Consolidation (R1) was judged NOT NECESSARY (the parser
  divergence hides zero real bugs today — measured). So this project's real work is the LEAD FIXES, ranked
  in VERIFY-FINDINGS §RECOMMENDED FIX ORDER. Top-2 are cheap agent_memory fixes; #3c touches a DESTRUCTIVE
  gate (gc) and should land soon. All non-kernel, inside the autonomous envelope.

- The continuation of axon4bugfree (run "5"). axon4bugfree shipped tools/axonlang.py (the canonical
  AXON-LANG extractor) + axonlang-exec gate, and DEFERRED (ADR-002): dead-key gate, PR-006 consolidation,
  PR-007 graph — each with evidence. This project picks up the deferred work, RE-RANKED by a fresh measurement.
- KEY NEW MEASUREMENT (2026-07-13, grounds the ranking): the dead-key gate is FUNDAMENTALLY noisy as a BLOCK —
  W: keys have GENERIC BULK READERS (checkpoint SNAPSHOT(W:), session_save, menu-snapshot) that read the whole
  namespace, so written-never-read can't distinguish a truly-dead key from a bulk-read one. 56 of 78 candidates
  survive ASSERT+Python-read filtering, but many are bulk-read. So dead-key BLOCK is DESCOPED to a REPORT.
- Not yet studied. Run: code-dev study  (graphify + measure before building — the axon4bugfree pattern).
