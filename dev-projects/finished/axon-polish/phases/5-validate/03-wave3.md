# Phase 5 — Heavy-Workflow Validation Wave 3 (doc-anchor coherence)

**Project:** axon-polish
**Phase:**   5-validate
**PR:**      PR-PHASE5-003
**Date:**    2026-05-23

---

## Purpose

Third instalment after `01-pilot.md` (8 scenarios) and
`02-extend.md` (6 BLOCKER-closure scenarios). The pilot proved the
capability layers; the extend wave proved the BLOCKER-closure layers;
this wave proves the **doc-coherence** capability layer that
`PR-DOC-ANCHOR-101` (#67) added.

Scope is intentionally tight: one scenario, one capability, one
production-tree assertion. Future waves can layer additional
quality-of-life scenarios on top.

---

## Scenarios

| #      | Scenario                                                       | Source PR          | Closes finding | Mechanism                                                                                  |
|--------|----------------------------------------------------------------|--------------------|----------------|---------------------------------------------------------------------------------------------|
| P5-S15 | `doc-anchor scan_all(DEFAULT_GLOBS)` finds zero defects        | PR-DOC-ANCHOR-101  | wave-3 gap     | Walks shipped docs via the tool's own public API, asserts every `path:start-end` resolves  |

---

## Coverage delta vs pilot + extend

| Capability layer                              | Pilot | Extend | Wave 3   |
|-----------------------------------------------|:-----:|:------:|:--------:|
| Resume-after-compaction                       | S1,S3 | —      | —        |
| Audit trail                                   | S2,S8 | S9     | —        |
| Write-path security                           | S4    | S12    | —        |
| Actionable error reporting                    | S5    | —      | —        |
| Doc lock-step (count drift)                   | S6    | —      | —        |
| **Doc coherence (anchor refs)**               | —     | —      | **S15**  |
| Workflow structural correctness               | S7    | S10    | —        |
| Cross-tool integration                        | S8    | —      | —        |
| Instruction-source provenance                 | —     | S9     | —        |
| Host-awareness                                | —     | S11    | —        |
| Write attribution                             | —     | S12    | —        |
| Predicate vocabulary completeness             | —     | S13    | —        |
| Registry / filesystem coherence               | —     | S14    | —        |

The doc-coherence layer was previously only covered by a CI gate.
Wave 3 adds the matching Phase-5 scenario so the gate's behaviour is
also a regression-tracked capability.

---

## Cumulative count

After this PR lands:

- Pilot (`tests/test_phase5_pilot.py`):  8 scenarios
- Extend (`tests/test_phase5_extend.py`): 6 scenarios
- Wave 3 (`tests/test_phase5_wave3.py`):  1 scenario
- **Total Phase-5 e2e scenarios: 15**

---

## What's still e2e-uncovered (next-wave candidates)

- **Rule-pack runtime scenario** — exercise the `verify program` path
  against a fixed set of canonical workspace/programs (e.g. menu,
  workflow-run, code-dev) and assert zero rule-pack violations.
  Earmarked for PR-PHASE5-004 if appetite warrants.
- **Workflow-simulate parity** — PR-4.1's bridge ops are explicitly
  scoped to workflow-run; simulate stays bridge-free by design. A
  structural test could lock that invariant.
- **Cron breaker e2e** — PR-AUTO-208 added auto-disable; an end-to-end
  cron-tick scenario could exercise the breaker path.

These are deferred because the *current* Phase-5 story already gates
the "heavy-workflow ready" claim.

---

## Status

Heavy-workflow-ready estimate:

- Before this PR:   `~98%`  (BLOCKER closures all e2e-verified)
- After this PR:    `~99%`  (doc coherence layer added)

The remaining `1%` is the rule-pack and cron-breaker capabilities,
neither of which gates the readiness claim.
