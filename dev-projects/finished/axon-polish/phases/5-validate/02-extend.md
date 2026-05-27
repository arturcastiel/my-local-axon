# Phase 5 — Heavy-Workflow Validation Extend (BLOCKER-closure wave)

**Project:** axon-polish
**Phase:**   5-validate
**PR:**      PR-PHASE5-002
**Date:**    2026-05-23

---

## Purpose

Companion deliverable to [`01-pilot.md`](01-pilot.md). The pilot proved 8
heavy-workflow capabilities end-to-end. This extend wave proves that the
remaining BLOCKER-closure PRs from the polish wave hold under the same
no-mock e2e regimen.

Scope: six scenarios, one per BLOCKER-closure PR, each exercising the
merged production code against a clean tmp workspace. Validation lives in
`tests/test_phase5_extend.py`; every future PR must keep these scenarios
green or the BLOCKER-closure claim regresses.

---

## Scenarios

| #      | Scenario                                                            | Source PR     | Closes finding | Mechanism                                                                          |
|--------|---------------------------------------------------------------------|---------------|----------------|------------------------------------------------------------------------------------|
| P5-S9  | `enforce check-source --source user:…` is rejected; `--user-instruction` is logged | PR-12.1       | F-D7-007a      | CLI exits 2 on legacy prefix; valid path appends to E:source-log                  |
| P5-S10 | Adaptive workflows terminate via `state.steps > 25` even when goal predicates are null | PR-5.1        | F-D4-003       | `predicate.evaluate_expr` resolves the OR short-circuit with `safe_null=True`     |
| P5-S11 | `context.resolve_limit` returns the right window from `L:host-model` (vendor-prefix and longest-prefix) | PR-7.1        | F-D9-001       | Reads `memory/longterm/host-model.md`; returns `(limit, source)` tuple             |
| P5-S12 | AXON-MANAGED sentinel roundtrips: add → parse → re-add (idempotent) → conflict | PR-16.1       | F-D6-005a      | `add-sentinel` CLI injects the writer comment; `parse_sentinel` recovers it       |
| P5-S13 | Predicate `BUILTINS` exposes the full workflow vocabulary (`goal.*`, `tests.*`, `audit.*`, `review.*`, `build.*`, `ctest.*`) as arity-0 callables that don't crash under `safe_null` | PR-5b         | F-D4-017       | `BUILTINS` table inspection + `evaluate_expr` round-trip per name                  |
| P5-S14 | `registry_drift.detect()` reports `filesystem-orphan` for a `tools/*.py` with no REGISTRY entry | PR-REG-101    | F-D5-002       | Tmp-workspace REGISTRY + fake tool dir; `detect()` returns `ok: false` with orphan |

---

## Coverage delta vs the pilot

| Capability layer                                  | Pilot       | Extend       |
|---------------------------------------------------|-------------|--------------|
| Resume-after-compaction (session + W:)            | S1, S3      | —            |
| Audit trail (forensic chain)                      | S2, S8      | **S9**       |
| Write-path security (sandbox + R9)                | S4          | **S12**      |
| Actionable error reporting (FAIL block)           | S5          | —            |
| Doc lock-step (no count drift)                    | S6          | —            |
| Workflow structural correctness                   | S7          | **S10**      |
| Cross-tool integration (state aggregator)         | S8          | —            |
| Instruction-source provenance                     | —           | **S9**       |
| Host-awareness (context-window resolution)        | —           | **S11**      |
| Write attribution sentinel                        | —           | **S12**      |
| Predicate vocabulary completeness                 | —           | **S13**      |
| Registry / filesystem coherence                   | —           | **S14**      |

Five capability layers that were "covered by unit tests only" before are
now covered end-to-end too.

---

## Findings closed (re-verified by this wave)

| Finding   | Severity  | Re-verified by | Pilot status before |
|-----------|-----------|----------------|---------------------|
| F-D7-007a | BLOCKER   | P5-S9          | unit-only           |
| F-D4-003  | BLOCKER   | P5-S10         | unit-only           |
| F-D9-001  | BLOCKER   | P5-S11         | unit-only           |
| F-D6-005a | BLOCKER   | P5-S12         | unit-only           |
| F-D4-017  | BLOCKER   | P5-S13         | unit-only           |
| F-D5-002  | (family)  | P5-S14         | unit-only           |

Six BLOCKER-flavoured findings move from "unit-only proof" to "e2e proof".
Combined with the pilot's 8 scenarios, the heavy-workflow readiness claim
now rests on **14 end-to-end scenarios**.

---

## What's still e2e-uncovered (next wave candidates)

- PR-8.1 / PR-8.2 / PR-8.3 — three of five Core Rule rule-pack enforcers
  (`R_FAIL_FORMAT`, `R_COGNITION_LANGUAGE`, `processes/active` seed). Unit
  tests in the rule pack already exercise these, but a real-program rule
  pack run against the production `workspace/programs/` tree would close
  the e2e loop.
- PR-DOC-ANCHOR-101 — dangling-doc-anchor detector. Equivalent to P5-S6
  for doc-anchor instead of count-drift.
- PR-HEALTH-101 — already shipped its own smoke test
  (`tests/test_tool_invocation_smoke.py`). No extend needed.
- PR-CD-301 / PR-CD-302 / PR-CD-303 — quality-of-life aggregators. Pilot
  S8 already covers axon-state; lint-summary and r-cognition-language
  could be added as a third wave if appetite warrants.

These are deliberately deferred; the BLOCKER-closure story is what gates
the "heavy-workflow ready" claim, and that story is now complete.

---

## Companion file

- `tests/test_phase5_extend.py` — six scenario tests + one report
  co-location guard (skips when `my-axon/` is not co-located, by design
  so CI never fails on an unrelated checkout shape).

---

## Status

When this test passes alongside the pilot, the heavy-workflow-ready
estimate moves from **95%** (pilot landed) to **~98%**: all closed
BLOCKERs are end-to-end-validated. The remaining 2% is rule-pack and
quality-of-life PRs that don't gate the readiness claim.
