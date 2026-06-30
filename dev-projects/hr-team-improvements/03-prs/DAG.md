<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:hr-team-improvements

- schema-version: `v1`
- generated:      `2026-06-22T18:32:46Z`
- generator:      `tools/dag.py`
- nodes:          16
- edges:          16
- critical-path:  PR-004 → PR-005 → PR-011 → PR-012 → PR-013 → PR-016

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Re-ground the for-use risk + sync stale checkout | Re-ground the for-use risk + sync stale checkout | merged |
| PR-002 | pr | Conformance test: stub markers can never reach a surfaced verdict | Conformance test: stub markers can never reach a surfaced verdict | skipped |
| PR-003 | pr | Mechanical fail-closed guard in the NEURON council path | Mechanical fail-closed guard in the NEURON council path | merged |
| PR-004 | pr | Collapse the dual path: main() cannot surface a verdict | Collapse the dual path: main() cannot surface a verdict | merged |
| PR-005 | pr | Route CLI flags → W: keys via router (single contract + validation) | Route CLI flags → W: keys via router (single contract + validation) | merged |
| PR-006 | pr | Declare convener the sole run_seats seam; reconcile 2nd call-site | Declare convener the sole run_seats seam; reconcile 2nd call-site | merged |
| PR-007 | pr | Context-load helper + wire --context (sanitized, fail-closed) + tests | Context-load helper + wire --context (sanitized, fail-closed) + tests | merged |
| PR-008 | pr | Deterministic F1..F6 mode resolver + table-driven tests | Deterministic F1..F6 mode resolver + table-driven tests | merged |
| PR-009 | pr | Roster keyword/domain map + fail-closed gate + tests | Roster keyword/domain map + fail-closed gate + tests | merged |
| PR-010 | pr | Deliberation math helpers + golden-vector tests + measurable 'smarter' | Deliberation math helpers + golden-vector tests + measurable 'smarter' | merged |
| PR-011 | pr | Seam schema v2 (variant/effort) + single-seat spawn + injectable fake | Seam schema v2 (variant/effort) + single-seat spawn + injectable fake | merged |
| PR-012 | pr | Parallel fan-out + sealed Round-1 | Parallel fan-out + sealed Round-1 | merged |
| PR-013 | pr | Retry + re-round on invalid/contested | Retry + re-round on invalid/contested | merged |
| PR-014 | pr | Observability/audit of REAL councils (signed provenance) | Observability/audit of REAL councils (signed provenance) | merged |
| PR-015 | pr | for-use sync + cross-checkout parity test | for-use sync + cross-checkout parity test | merged |
| PR-016 | pr | End-to-end real-council + aggregation-correctness suite (via injectable fake) | End-to-end real-council + aggregation-correctness suite (via injectable fake) | merged |

## Edges

| from | to | kind |
|------|----|------|
| PR-004 | PR-005 | depends |
| PR-004 | PR-006 | depends |
| PR-005 | PR-007 | depends |
| PR-005 | PR-008 | depends |
| PR-005 | PR-009 | depends |
| PR-004 | PR-010 | depends |
| PR-005 | PR-011 | depends |
| PR-011 | PR-012 | depends |
| PR-012 | PR-013 | depends |
| PR-010 | PR-013 | depends |
| PR-011 | PR-014 | depends |
| PR-001 | PR-015 | depends |
| PR-004 | PR-015 | depends |
| PR-010 | PR-016 | depends |
| PR-012 | PR-016 | depends |
| PR-013 | PR-016 | depends |
