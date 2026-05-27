---
explains:      _decisions.md (Phase 1) + phases/2-design/_decisions.md
audience:      tier-A
last-checked:  2026-05-17
version:       1
---

# Decision Digest — 36 ADRs in one line each

> Scan from top. Deep-read the ones that surprise you.
> Full ADR text in `phases/1-study/_decisions.md` (D-001..D-017)
> and `phases/2-design/_decisions.md` (D-018..D-036).

## Phase 1 (D-001 .. D-013) — vision-locking

| ID | One-liner |
|----|-----------|
| **D-001** | Audit-first; derive goals from findings, not before |
| **D-002** | One umbrella project `axon-synapse`, not multiple |
| **D-003** | Programs are synapses; AXON orchestrates adaptively |
| **D-004** | dev-mode OFF project-wide; per-PR flip only |
| **D-005** | Synapse contract = **hybrid** inferred + declared override |
| **D-006** | DAG persistence = both `DAG.json` + `DAG.md`, sync-checked |
| **D-007** | Goals always exist; workflow-bound OR user-stated (infer + confirm) |
| **D-008** | Study depth = most detailed, no cap (split track at 80 KB) |
| **D-009** | DAG central at 5 levels (project, phase, plan, PR, study) |
| **D-010** | Suggestion firing = state-driven; predetermined + ephemeral; promote after ≥ N accepts |
| **D-011** | Shadowing **mandatory**; orchestrator-enforced at finalize + audit |
| **D-012** | Regression-safe; no tests break; new tools in REGISTRY auto-suggestable |
| **D-013** | Synapse model formalized as **pseudo-FSM** (non-deterministic, observable state) |

## Phase 1 (D-014 .. D-017) — vision-deepening

| ID | One-liner |
|----|-----------|
| **D-014** | Preserve current code-dev hierarchy verbatim; never break it |
| **D-015** | AXON Synapse is a **workflow OS**; code-dev is one domain among many |
| **D-016** | New synapses + workflows are first-class registrable (direct OR conversational) |
| **D-017** | Two workflow modes (Fixed / Adaptive) + Hybrid; suggestions live in both |

## Phase 2 v1 (D-018 .. D-025) — initial design decisions

| ID | One-liner |
|----|-----------|
| **D-018** | Glossary is the singular vocabulary source; every spec cites version |
| **D-019** | `DAG.md` is one-way rendered output; hand-edits ignored |
| **D-020** | Synapse-contract: bulk-infer-first, declared-override progressive |
| **D-021** | Ranker is rule-based for v1; learning is Phase 4+ |
| **D-022** | Shadow-grace flag (`L:shadow-enforcement-strict`) for backwards-compat |
| **D-023** | Suggestion delivery defaults = footer + opt-in panel |
| **D-024** | Workflow-compile (cache) → Phase 4 |
| **D-025** | Phase 1 validation gate: synthesis sign-off, no per-track gate |

## Phase 2 v1.1 (D-026 .. D-036) — remediation cohort

| ID | One-liner |
|----|-----------|
| **D-026** | **Biology-correct vocab rename:** neuron / synapse / axon (closes OP-01) |
| **D-027** | Predicate language v1.1: formal grammar + precedence + types + null semantics |
| **D-028** | Ranker tie-break ladder (6-level, ends in lexicographic) — reproducibility |
| **D-029** | Zero-candidate fallback: TF-IDF registry search → QUERY; never hang |
| **D-030** | Cold-start ranker: frequency-prior for first 20 fires |
| **D-031** | `layer:` axis splits `meta` overload (kernel/system/meta/shared/domain) |
| **D-032** | `source-artifact-glob:` per domain disambiguates `requires-shadow` |
| **D-033** | Shadow grace-flag flip protocol = 100% coverage twice + audit clean + user-confirm |
| **D-034** | Interrupt-gate workflow-aware: continuation / deviation / pause / abort |
| **D-035** | PR-116 split per project; PR-108 per-file rollback via `undo` tool |
| **D-036** | 6 improvement artifacts ship: flaws-register, version-log, fixtures, PR-template, blast-radius, reversibility tier |

## The handful you absolutely cannot forget

If you internalize **6** ADRs you have 80 % of the design:

1. **D-007** — goals always exist
2. **D-014** — preserve code-dev (don't break what works)
3. **D-015** — domain-agnostic kernel (workflow OS, not code-dev redesign)
4. **D-017** — Fixed vs Adaptive vs Hybrid; suggestions in both
5. **D-026** — vocabulary: neuron / synapse / axon (biology-correct)
6. **D-029 + D-030** — never silent-hang; cold-start fallback

The rest specify; these constrain.

## Hot-link table (jump to full ADR text)

- D-001 .. D-013 → `phases/1-study/_decisions.md` § D-NNN
- D-014 .. D-017 → `phases/1-study/_decisions.md` § D-NNN (latter half)
- D-018 .. D-036 → `phases/2-design/_decisions.md` § D-NNN

## Demand cross-reference

For *which demand* a decision serves, see `_demands.md` § Cross-reference
table (Phase-1 D-1..D-26 + Phase-2 v1.1 ADRs).
