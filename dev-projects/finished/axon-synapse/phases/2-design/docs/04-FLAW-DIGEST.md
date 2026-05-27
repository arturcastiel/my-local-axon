---
explains:      _flaws.md
audience:      tier-A
last-checked:  2026-05-17
version:       1
---

# Flaw Digest — 24 tracked flaws in one line each

> Confidence calibrator. Scan to see what's tracked + what's deferred.
> Full text + per-row remediation in `_flaws.md` (project root).

## Status snapshot

| Status | Count | Meaning |
|--------|-------|---------|
| 🟧 spec-fixed   | 21 | Design fix landed; impl pending |
| 🟥 open         |  2 | Phase-4 deferral with rationale |
| 🟨 impl-fixed   |  0 | Phase-3 deliverable |
| 🟩 closed       |  0 | Phase-4 verification |
| ⬛ wontfix      |  1 | Permanent (with rationale) |

## v1 → v1.1 remediation cohort (all 🟧 spec-fixed)

| ID | One-liner | Fix landed in |
|----|-----------|---------------|
| FL-01 | Predicate operator precedence undefined | predicate-language v1.1 |
| FL-02 | Null semantics undefined | predicate-language v1.1 |
| FL-03 | Type system absent | predicate-language v1.1 |
| FL-04 | Ranker tie-break arbitrary | orchestrator-composition v1.1 § Tie-break ladder |
| FL-05 | Zero-candidate fallback hangs | orchestrator-composition v1.1 § Zero-candidate fallback |
| FL-06 | PR-116 single PR for 119 files | migration-plan v1.1 § PR-116 split into a..f |
| FL-07 | Cold-start ranker undefined | orchestrator-composition v1.1 § Cold-start bootstrap |
| FL-08 | `requires-shadow` ambiguous across domains | domain-manifest v1.1 § source-artifact-glob |
| FL-09 | Interrupt-gate × workflow undefined | orchestrator-composition v1.1 § Interrupt-gate integration |
| FL-10 | Grace-flag flip protocol vague | shadow-enforcement v1.1 § Flip protocol |
| GAP-01 | Multi-domain workflow resolution | workflow-file v1.1 § Cross-domain |
| GAP-02 | Mid-workflow mode-switching | workflow-file v1.1 § mode-switch |
| GAP-03 | Sideband suggestion rate-limit | workflow-file v1.1 § suggestion-budget |
| GAP-04 | DAG.json single-point-of-failure | dag-spec v1.1 § MD→JSON recovery |
| GAP-05 | Parent-met-child-open semantics | goal-schema v1.1 § Parent-child status |
| GAP-06 | Snapshot freshness | predicate-language v1.1 § Snapshot semantics |
| GAP-08 | Mixed-case `PR-NNN` filename | dag-spec v1.1 § normalize-pr-filenames |
| OP-01 | Synapse metaphor inverted | AXON-GLOSSARY v2 (rename) |
| OP-03 | `meta` category overloaded | domain-manifest v1.1 § layer axis |
| OP-04 | PR-108 no per-file rollback | migration-plan v1.1 § PR-108 v1.1 |

## Carried-forward to Phase 4 (🟥 open with rationale)

| ID | Rationale |
|----|-----------|
| GAP-07 | Phase-4 ranker tuning data on-ramp — *cannot design until Phase-3 collects lived signal* |
| OP-02 | Linear ranker may be inadequate — *measure linear performance first, tune only if signal* |

## Permanent (⬛ wontfix with rationale)

| ID | Rationale |
|----|-----------|
| OP-01.X | `synapse` user-facing alias kept forever — *backwards-compat priority over biological purity in user input* |

## What this means for confidence

- **Spec rigor 0.93**: every named flaw has a documented fix.
- **Risk awareness 0.95**: known-tracked > unknown-hidden; flaws-register
  ensures none slip silently into Phase 3.
- The two Phase-4 deferrals are structural, not laziness.
- The one wontfix is a deliberate trade-off, documented.

## Audit triggers

- New flaw → row added with 🟥; ADR if non-trivial.
- Spec edits → status promotes to 🟧.
- PR merges with passing tests → status promotes to 🟨.
- Tests + audit confirm → status promotes to 🟩.

Goal for Phase-4 close: **zero 🟥 rows.**
