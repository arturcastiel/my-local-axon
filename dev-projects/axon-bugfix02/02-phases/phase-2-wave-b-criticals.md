# Phase 2 — wave-b-criticals

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-07

## 1. Envelope
- **Phase number**: 2
- **Slug**: `wave-b-criticals`
- **Owner**: AXON Bugfix 02
- **Target window**: TBD
- **PR count**: 4

## 2. Why this phase
> Repairs the four adversarially-reconfirmed CRITICALs — the advertised features broken on the golden
> path every single run (session-summary, resume, gain, board). Highest owner-felt value; each PR is
> self-contained. Phase boundary: these are the surfaces whose silence hid the whole defect class.

## 3. PRs in this phase
| PR     | title                                                | est-complexity | depends-on |
|--------|------------------------------------------------------|----------------|------------|
| PR-003 | Repair session-summary: path, digest patterns        | M              | none       |
| PR-004 | Rebuild resume over persisted working memory         | M              | none       |
| PR-005 | Gain: honest rebuild over data that exists           | M              | none       |
| PR-006 | Board: rewire aggregation to the real PR store (D1)  | L              | none       |

## 4. MUST vs NICE
**MUST (in-scope)**:
- session-summary reaches Steps 2–5 with real digest counts; resume detects a genuinely interrupted session
- gain renders only panels with real backing; board renders real PRs from 02-prs.md with loud empty-state
**NICE (deferred if budget tight)**:
- resume enrichment from episodic checkpoint rows
- board filters (state/phase) beyond the basic listing

## 5. Entry gate
- Wave A merged (lints in report-mode — fixes here shrink the baseline)

## 6. Exit gate
- All four surfaces produce truthful non-empty output on a live run against this repo
- Baseline entries for these four surfaces removed; full suite green

## 7. Phase-local risks
| risk                                            | likelihood | mitigation                                       |
|-------------------------------------------------|------------|--------------------------------------------------|
| Turn-log degeneracy limits gain's SESSIONS panel | high       | counts-only panel; degeneracy documented for owner |
| pr_aggregate list shape breaks other consumers   | low        | new subcommand, existing ones untouched; tests    |

## 8. Iteration log
- 2026-07-07 — phase file rendered; D1 locked FIX by owner
