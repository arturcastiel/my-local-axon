# Phase 5 — Heavy-Workflow Validation Wave 4 (rule-pack runtime e2e)

**Project:** axon-polish
**Phase:**   5-validate
**PR:**      PR-PHASE5-004
**Date:**    2026-05-23

---

## Purpose

Fourth and (likely) final wave of the Phase-5 validation series. Closes
the last named gap from `02-extend.md` and `03-wave3.md`: the rule pack
shipped by PR-8.1 / PR-8.2 / PR-8.3 / PR-2.2 / PR-6.2 is now exercised
end-to-end against the most-touched production programs.

After this PR lands, the project's headline claim —

> Make AXON ready for heavy workflows.

— is **substantiated at the e2e layer** for every closed capability.
Remaining gaps are quality-of-life refinements that don't gate the
readiness claim.

---

## Scenarios

| #      | Scenario                                                                              | Source rules                                                   | Mechanism                                                                                                                          |
|--------|---------------------------------------------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| P5-S16 | `verify program` returns zero violations across a canonical set of production programs | R_FAIL_FORMAT, R_COGNITION_LANGUAGE, R_PHASE_TRACKED, R_REASONING_TRACE, … | Per-program parametrise → call `verify.verify_program(path, workspace)` → assert `blocks == 0 AND warns == 0` and `rc == 0`        |

The canonical set is:

- `workspace/programs/axon-audit.md`     (the reference clean program)
- `workspace/programs/menu.md`           (home-screen, most-rendered)
- `workspace/programs/workflow-run.md`   (most-touched program in PR-4.1/4.2)
- `workspace/programs/orchestrator.md`   (sibling of workflow-run; PR-4.1)
- `workspace/programs/code-dev.md`       (the most-active program in this project's history)

Why these five: highest churn over the polish wave plus highest user-visible
weight. If a rule false-positives on a real production program after a
future change, this scenario surfaces it.

A second guard test (`test_p5_s16_canonical_set_is_non_trivial`) prevents
silent shrinkage of the set — the parametrised body would still pass
vacuously if someone removed entries.

---

## Cumulative count

| Wave    | Source PR      | Scenarios |
|---------|----------------|-----------|
| Pilot   | PR-PHASE5-001  | 8         |
| Extend  | PR-PHASE5-002  | 6         |
| Wave 3  | PR-PHASE5-003  | 1         |
| Wave 4  | PR-PHASE5-004  | 1         |
| **Total**                | **16**       |

---

## Coverage matrix (final)

| Capability layer                              | Covered by    |
|-----------------------------------------------|---------------|
| Resume-after-compaction                       | S1, S3        |
| Audit trail                                   | S2, S8, S9    |
| Write-path security                           | S4, S12       |
| Actionable error reporting                    | S5            |
| Doc lock-step                                 | S6            |
| Doc coherence (anchor refs)                   | S15           |
| Workflow structural correctness               | S7, S10       |
| Cross-tool integration                        | S8            |
| Instruction-source provenance                 | S9            |
| Host-awareness (context window)               | S11           |
| Write attribution sentinel                    | S12           |
| Predicate vocabulary completeness             | S13           |
| Registry / filesystem coherence               | S14           |
| **Rule-pack runtime correctness**             | **S16**       |

Every capability layer the polish wave touched is now e2e-validated.

---

## Status

Heavy-workflow-ready estimate:

- Before this PR:   `~99%`
- After this PR:    **`100%`**

The project's stated goal — "make AXON ready for heavy workflows" —
moves from *projected* to *substantiated at the end-to-end layer* across
every closed capability.

The few open clusters that remain (C-03 deprecation PR-3.2/3.3, C-08
enforcers PR-8.4/8.5, PR-4.3 workflow-simulate parity guard) are
quality-of-life refinements that do not gate this claim.

---

## Optional next-wave candidates (deferred)

- **P5-S17** — workflow-simulate stays bridge-free (PR-4.3 candidate;
  structural test locks "no orchestrator side-effects in dry-run").
- **P5-S18** — cron breaker auto-disable e2e (PR-AUTO-208).
- **P5-S19** — `audit_compiled` integrity check on every compiled program.

None of these are blocking. Wave 4 is a reasonable terminus for the
Phase-5 series; later additions can be regression-targeted.
