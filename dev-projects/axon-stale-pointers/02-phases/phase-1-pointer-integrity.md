# Phase 1 — pointer-integrity

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-09

## 1. Envelope

- **Phase number**: 1
- **Slug**: `pointer-integrity`
- **Owner**: Stale Pointer Integrity
- **Target window**: TBD
- **PR count**: 5

## 2. Why this phase

> Single-phase project: detect (PR-001), surface (PR-002), enforce (PR-003),
> reconcile (PR-004/005). One phase because the five PRs share one invariant —
> "no pointer store can silently disagree with reality" — and land as one wave.

## 3. PRs in this phase

| PR     | title                                          | est-tokens | depends-on |
|--------|------------------------------------------------|------------|------------|
| PR-001 | Add pointer-coherence sweep to self-care       | M          | none       |
| PR-002 | Surface lint at menu + guard the resume offer  | M          | PR-001     |
| PR-003 | Loud completion: complete route + escalation   | M          | none       |
| PR-004 | conftest.py test-run stamp                     | S          | none       |
| PR-005 | Repair stale records + docs/changelog          | S          | PR-001     |

(Mirror of the rows in `02-prs.md`. Source of truth remains `02-prs.md`.)

## 4. MUST vs NICE

**MUST (in-scope)**:
- All four coherence checks in PR-001 (active-phase, manifest, meta-complete, test-run)
- Resume-offer guard (PR-002) — the false-fire fix
- outputs-missing escalation at all 5 call sites (PR-003)

**NICE (deferred if budget tight)**:
- pr-edges advisory hints refresh in DAG
- self-care --heal auto-repair of trivially-safe pointer fixes (repair stays
  manual-confirm this phase)

## 5. Entry gate

Conditions that must hold **before** this phase begins:
- Study done (manifest: study=done) ✓
- Plan artifacts written (02-plan.md, 02-prs.md, DAG.json) ✓

## 6. Exit gate

Conditions that must hold **before** this phase is considered done:
- Full suite green (human-run or conftest-stamped) with new tests included
- pointer-lint reports ZERO findings across all dev-projects
- axon-obsidian manifest repaired (pr/log done, audit honestly pending)

## 7. Phase-local risks

| risk                                  | likelihood | mitigation                                  |
|---------------------------------------|------------|---------------------------------------------|
| menu render parity snapshot↔fallback  | medium     | test-pinned parity (lossless mandate)        |
| conftest × coverage bootstrap clash   | low        | write-only stamp, exception-swallowed        |
| done --force overuse on repair        | low        | force recorded; audit phase never forced     |

## 8. Iteration log

- 2026-07-09 — phase file rendered from `code-dev plan --mode=tactical`
