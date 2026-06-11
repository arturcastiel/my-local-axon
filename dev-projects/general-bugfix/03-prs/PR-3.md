# PR-3 — phase-model unification [crit C1]

Status: merged
Merged: → main (squash) · crucible green 28 controls
Branch: general-bugfix/pr-3-phase-unification → main
Depends-on: (none — sequenced after Wave 1)
Phase: 3-prs
Covers: C1 (phase split-brain: done/back/skip permanently fail, dashboard all-pending)

## Goal
One phase vocabulary. `_meta.md` speaks the scaffold dialect ("3-prs", "1-study");
`phase_model` speaks canonical ids ("pr", "study"). `code-dev done` feeds the meta token
to the model, the model rejects it → every phase command fails; `code-dev-new` never
seeded `_phases.json` → the dashboard renders all phases pending forever.

## Change
- `phase_model.py` gains **normalize()** — exact manifest id first, then canonical form
  (strip `N-` order prefix, lowercase, alias `prs→pr`); unknown tokens raise listing the
  canonical vocabulary (loud, never silent). Applied on EVERY CLI `--phase` path
  (status/advance/done/stale-downstream) — so `done --phase 3-prs` now works.
- **check** subcommand — the phase-id ⇄ `_meta.phase` consistency guard: resolves the
  meta phase against the manifest; ok=false = split-brain detected (exit 1, gate-usable);
  notes when meta points at an already-done phase.
- **init** subcommand — explicit manifest seed; `code-dev-new` now calls it AT CREATION
  (the missing seed), and its first-phase default is canonical `"study"` (was `"1-design"`,
  a token the model never knew).
- `code-dev-load` surfaces `phase-model check` loudly on load.
- Tests: normalize cases, the **3-prs end-to-end done regression**, check split-brain
  detection, init manifest shape (11 pass).

## Deferred (documented, not dropped)
- Full `phases/{name}/` directory retirement: 5 live consumer programs SCAN it
  (hold, cascade, explain-reviewer, dont-do, journal-search) — that collapse belongs to
  the reduce-surface PR with the route-manifest work.
- Driver unification (new/start/list/done/back/skip → one dispatcher): same home.

## Guarded-by
- `phase-model check` (load-surfaced; gate-usable exit 1).
- C1 regression tests in tests/test_phase_model.py.
