# Project: AXON Ranker v2 — closed-loop ranker with cap/floor/decay
slug:            axon-ranker-v2
schema-version:  v4
status:        obsolete
legacy:          false
phase:           0-seed
workflow-step:   seed
branch:          main
codebase:        /mnt/c/projects/axon
parent:          axon-autoimprove
sub-projects:    []
created:         2026-05-19
updated:         2026-05-19
predecessor:     axon-autoimprove (phase-3 PR-AUTO-204 substrate)
seed-audit:      _seed.md

## Working Context

Spinout from `axon-autoimprove` (PR-AUTO-302 triage). Owns the ranker design problem that `auto-improve` deliberately scoped out:

- The dispatch threshold and synapse-suggest score-floor are both **one-way monotonic** auto-tune signals (FA-19). They go up when negative feedback is loud, but they never come down. Over weeks of use this systematically over-conservatives the dispatcher into fallback territory.
- PR-AUTO-204 wired auto-tune writes through `loop-receipt(intent='tune-threshold')`, so the **observability** is there. What's missing is the **control law**.
- Ranker state (current threshold, recent negative rate, time-to-next-tune) is not surfaced in SELF-OBSERVE — see D-DISC-4. Users can't tell if the ranker is converging or saturating.

## Goal (top-level)

Replace the one-way ratchet with a **bounded controller**:
- Explicit floor (e.g. 0.5) and cap (e.g. 0.9) on `dispatch-confidence`.
- Decay term: positive-feedback streaks pull the threshold **down**.
- Per-program success/fail accounting (not just global negative rate).
- Loop-receipt-tracked state transitions remain mandatory.
- SELF-OBSERVE row exposing current controller state (last tune, current value, drift-from-baseline).

## Out of scope (v1)

- Replacing TF-IDF with embeddings (separate spinout if ever needed).
- Auto-discovery of program intent from natural language (already shipped via PR-108).

## Phase plan (preliminary)

| Phase            | Status | Owner       |
|------------------|--------|-------------|
| 0-seed           | active | this doc    |
| 1-study          | TBD    | TBD         |
| 2-design         | TBD    |             |
| 3-build          | TBD    |             |
| 4-validation     | TBD    |             |

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
