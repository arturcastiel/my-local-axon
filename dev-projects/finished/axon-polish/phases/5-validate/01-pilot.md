# Phase 5 — Heavy-Workflow Validation Pilot

**Project:** axon-polish
**Phase:**   5-validate
**PR:**      PR-PHASE5-001
**Date:**    2026-05-22

---

## Purpose

This document is the validation deliverable for the project's primary goal:

> Make AXON ready for heavy workflows.

Phases 1-4 catalogued, prioritised, designed and implemented 22 BLOCKER closures and 29+ MAJOR closures across 27 merged PRs. Each PR shipped its own unit tests. **Phase 5 closes the loop**: an end-to-end pilot that exercises the polish-wave capabilities together against a fresh workspace, validating that the individual pieces actually work as a system.

The validation runs as the test file `tests/test_phase5_pilot.py`. Every PR landing after this one must keep these scenarios green — regression here means the heavy-workflow readiness claim has cracked.

---

## Scenarios

Eight scenarios, each guarded by a pytest function. Numbering is `P5-S<N>`.

| #     | Scenario                                                              | Source PR     | Mechanism                                                                |
|-------|-----------------------------------------------------------------------|---------------|---------------------------------------------------------------------------|
| P5-S1 | Session recovery fires on stale PID; state transitions to `recovered` | PR-6.1        | `session.auto_recover` scans dev-projects, calls `recover()` per file     |
| P5-S2 | Phase ledger advances start → step → done                             | PR-6.2        | `phase_ledger.record` appends rows; `verify --expected-phases` passes     |
| P5-S3 | `checkpoint save → mutate → restore` roundtrips W: memory             | PR-9.4        | Snapshot serialises every `working/<key>.md`; restore rewrites them       |
| P5-S4 | Shell sandbox blocks hard-forbidden + axon/ writes; allows benign     | PR-1.1, PR-1.2| `gate_check` applies R9 path-check via realpath                            |
| P5-S5 | `fail_render` emits the canonical KERNEL-SLIM:411-426 block byte-for-byte | PR-2.1   | `render_fail()` constructs Problem/Cause/Fix/Suggested-next                |
| P5-S6 | `doc-counts check` finds no drift across README + kernel docs         | PR-14.1, 14.2 | Lint gate in CI; this test fails locally if drift sneaks in               |
| P5-S7 | Every shipped workflow validates clean (one documented exemption)     | PR-11.1       | `workflow_dag.analyze` finds zero defects (cycle exempted for documented case) |
| P5-S8 | `axon-state` surfaces real events across multiple audit logs          | PR-CD-303     | Aggregates phase-ledger + session-log + deprecation-log + …               |

---

## Coverage of the polish-wave capabilities

| Capability layer                          | Tested by         |
|-------------------------------------------|-------------------|
| Resume-after-compaction (session + W:)    | P5-S1, P5-S3      |
| Audit trail (forensic chain)              | P5-S2, P5-S8      |
| Write-path security (sandbox + R9)        | P5-S4             |
| Actionable error reporting (FAIL block)   | P5-S5             |
| Doc lock-step (no count drift)            | P5-S6             |
| Workflow structural correctness           | P5-S7             |
| Cross-tool integration (state aggregator) | P5-S8             |

Capabilities NOT covered by this pilot (deferred to follow-up validation):

- **R_IDENTITY_LOCK / R_PHASE_TRACKED migration coverage** — both rules default WARN, so they cannot break the pilot. The `lint-summary` (PR-CD-301) digest shows offender counts; that's the existing surface.
- **Heavy-program performance** — token usage, latency, concurrency. Out of scope for this pilot; covered by `axon-master` PR-W4-01 (cache_control).
- **Cross-project handoffs** — the 5 sibling projects (axon-wiring-gaps, axon-cleanup, axon-ranker-v2, axon-copilot-anchor, firing-dag-missing) each carry their own validation.

---

## Documented exemption — adaptive-free-text.yml cycle

`workspace/workflows/adaptive-free-text.yml` contains a deliberate `s1 → s2 → s1` cycle. PR-5.1 added a runtime step-count termination guard so the cycle cannot loop forever; PR-5b shipped the `goal.rejection.met()` BUILTIN so the rejection-criterion resolves cleanly. The cycle itself remains because adaptive workflows are inherently cyclic — synapse-suggest decides each step.

`test_p5_s7_workflows_dag_clean_or_exempt` allows this single workflow to ship with a `cycle` defect; all other defects across all workflows are blocking. The exemption is listed in `WORKFLOW_EXEMPT_CYCLES` in `tests/test_phase5_pilot.py` and requires deliberate code change to expand.

---

## Outcome

When `pytest tests/test_phase5_pilot.py` passes, the polish-wave goal is met at the validation layer: every shipped capability works end-to-end against a fresh workspace. The 90% heavy-workflow-ready estimate carried in the project plan is upgraded to a **substantiated 90%** rather than a projected one.

The remaining 10% is documented in the project's Phase 4 → Phase 5 transition note:

- ~10 mechanical migration PRs to close the open R_FAIL_FORMAT, R_IDENTITY_LOCK, R_PHASE_TRACKED backlogs (no new MAJOR closures).
- ~5 catalog MAJORs not addressed by the wave (doc-anchor drift, stale-subsystem detector, REGISTRY drift CI gate, health-check coverage, MINOR sweep).
- 5 sibling projects routed out during the audit.

None of those is blocking heavy-workflow use today — they're polish refinement and ecosystem work.

---

## Regression watch

This file's existence is itself guarded by `test_p5_pilot_report_present` (in the pytest file). Any PR that deletes the report fails the test. Any PR that changes the capability surface should update the relevant scenario.

When a new audit-trail tool ships:
1. Add it to `tools/axon_state.py:LOGS`.
2. Add a corresponding scenario row to this report's "Scenarios" table.
3. Extend `test_p5_s8_axon_state_aggregates_audit_trail` to exercise it.

---

## See also

- Project plan: `_meta.md`, `masterplan.md` (axon-polish root)
- Per-PR specs: `phases/3-design/03-prs/PR-*.md`
- Phase-3 DAG: `phases/3-design/03-dag.md`
- Phase-4 implementation notes: `phases/4-implement/` (per-cluster journals)
