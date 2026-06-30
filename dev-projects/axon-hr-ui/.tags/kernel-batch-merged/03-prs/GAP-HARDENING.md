# GAP-HARDENING — phase-new cascade split-brain pre-filter (scoped)
Status: merged
Phase: pr
Lane: AXON (autonomous, non-kernel)

## Scope decision
The gap-find backlog bundled 5 unrelated items under GAP-HARDENING. Per minimal-finish, this node ships
the ONE real correctness bug; the other 4 (low-value test-robustness / edge-cases) are DEFERRED (below).

## DONE here — rank 4b: phase-new cascade DAG/manifest split-brain
`code-dev-phase-new.md` adds the phase node + edges to `DAG.json` (lines ~107-111), THEN
`phase-model add --after {pred-csv}` writes `_phases.json` (line ~120). The DAG edge loop already filters
unknown predecessors, but `pred-csv` does NOT — so an unknown predecessor makes `phase-model add` RAISE
*after* the DAG node was written → DAG has the node, the manifest doesn't = split-brain (PR-001 bug class).
**Fix:** validate every predecessor is a KNOWN phase (`phase-model render`) BEFORE any mutation; a bad
predecessor FAILs cleanly with nothing half-written.

## Files
- `workspace/programs/code-dev-phase-new.md` (predecessor-existence guard before the DAG cascade)
- `tests/test_phase_new_cascade.py` (static: validation precedes the DAG add-node)

## DEFERRED (rationale: low value / not minimal-finish)
- rank 9 — synapse dedup degrades on unbalanced parens (edge case; PR-005c lint already guards the common case)
- rank 11 — R_TOOL_CALL_EXISTS blind to loop-built parsers (scanner blindspot; no active false-negative)
- rank 7 — compiled-staleness test mtime-based (test-robustness; content-equivalence test already covers correctness)
- kv `--raw` TTL test (test addition; PR-004 shipped the feature + its core tests)

## Acceptance
- An unknown predecessor fails BEFORE the DAG is mutated (no split-brain).
- Static test pins validation-before-mutation; full crucible green.
