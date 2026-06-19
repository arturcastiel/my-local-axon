# HANDOFF — AXON Re-Arm (start here)

> A code-dev project, scoped 2026-06-19 from the 8-council report-state handoff. Study is DONE; this is
> ready to enter the **plan → pr** phases. Pick it up with: `code-dev load axon-rearm`.

## In one paragraph
Eight sealed councils + a synthesis audited AXON and found a **correct, self-honest architecture shipped
disarmed and uninstrumented** — zero `L:*-required` flags on disk, the flagship Core Rule 13 test-gate
fails OPEN in CI (a resolver bug, `crucible.py:131` vs `:155`), and the drift detector reads an empty wire
so it reports "stable" by construction. The fix is overwhelmingly **configuration + unfinished wiring +
small fixes, not a redesign.** This project executes that backlog. Do **Tier 0 first** — until the meter
is plugged in (A1) and the flags are flipped (A2), the system can't even tell you whether later fixes worked.

## What's here
- `01-study.md` — the distilled findings, the 7 cross-cutting themes, the drift verdict, and the 8 RESOLVED owner decisions.
- `02-prs.md` — the **26-PR backlog** across 7 tiers (Tier 0 arm+instrument → Tier 6 the thin-kernel experiment), each with a test claim.
- `research/00-AXON-report-state-handoff.md` — the full capstone (and the 8 source reports live in `../axon-completeness-gate/reports/`).
- `_meta.md` — goal, hard constraints, lineage (parent: axon-completeness-gate / Wave G).

## The 8 decisions (resolved, baked into the backlog)
OD-1 **arm** the flags · OD-2 drift-gate `unknown` is a **bug** (fail-closed) · OD-3 **type both, gate on EXEC** ·
OD-4 **investigate** the 29 legacy first · OD-5 **adopt** shrink-only test-grandfather · OD-6 **close** the
clone fail-open · OD-7 **decide naming now** (verb-first, `-` sep, flat namespace) · OD-8 **run** the thin-kernel experiment.

## First sprint (council recommendation — 8 mostly-small changes)
`PR-T0-1` instrument drift · `PR-T0-2`(+`T0-2a`) arm flags (seed emits first) · `PR-T0-3` mechanical counters ·
`PR-T1-1` fix the CR-13 resolver · `PR-T1-2` CI fetch-depth · `PR-T2-1` gate the dev-mode toggle · `PR-T2-2` protect tools/.
→ moves AXON from "disarmed and blind" to "armed and instrumented," after which compliance/drift become **measurable**.

## Hard constraints (owner, this session)
- **Conservative · test-more · redo-until-closed** — a PR is DONE only when a STRONG automated test proves its
  claim (security/gate PRs must reproduce-then-block the failure). No fingerprint-only closure.
- **crucible-green before test-execution**; **AXON-only commit trailer**; gates cannot be broken (no --force).
- **KERNEL-SLIM edits** only where a decision requires it (OD-1 prose, OD-2 lines 188/341, F1 version) — each
  needs dev-mode + per-change owner confirm. The kernel floor stays human.
- Tier 2 touches the **security floor** (dev-mode toggle, protecting tools/) — highest blast radius, own review.

## Next action for whoever picks this up
`code-dev load axon-rearm` → `code-dev plan` (produce 02-plan.md + 03-prs/DAG.json from 02-prs.md) →
`code-dev pr` starting with the first-sprint set. Tier 0 is non-negotiable first.
