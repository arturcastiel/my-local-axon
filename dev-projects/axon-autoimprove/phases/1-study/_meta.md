# Phase 1 — Study (axon-autoimprove)
slug:            1-study
schema-version:  v4
status:          CLOSED
opened:          2026-05-18
closed:          2026-05-19
goal:            Audit the auto-improve hooks shipped by synapse PR-120 + the ranker telemetry + the reversibility primitives. Output a findings index, a risk map, and a per-action inventory ready for phase-2 design.
created:         2026-05-18

## Outcome

Phase 1 closed 2026-05-19 — see `_closure.md`. All exit criteria met.
Three deep-study artefacts persisted: `02-deep-audit.md`, `03-synapse-retro.md`,
`04-discoverability.md`. 7 phase-2 specs queued (see closure §"Phase-2 entry brief").

## Inputs

- `../../AUDIT.md` (axon-synapse audit — the trigger doc)
- `../../../axon-synapse/RETRO.md` § "What we deferred"
- `tools/synapse_suggest.py` — ranker source
- `workspace/programs/orchestrator.md` — loop with auto-improve hook
- `axon/OUTPUT-LAYER.md` — surface with optional receipt line
- `tools/usage.py` — telemetry counters (already shipped, baseline not captured)
- `_demands.md` D-A01..D-A12 — constraints to honor
- `_flaws.md` FLA-01..FLA-03, FA-01..FA-04 — open flaws to verify or close

## Deliverables (this phase)

1. **Findings index** (`01-study.md`) — what synapse left in place vs what's missing.
2. **Per-action inventory** — for compile / tune / archive: trigger source, target,
   reversibility primitive available today, what is missing.
3. **Telemetry inventory** — what counters exist, what is captured, what is dropped.
4. **Risk map** — flaws FA-01..FA-04 verified + any new flaws surfaced.
5. **Phase-2 entry brief** — what specs phase-2 must author (≤ 5 specs).

## Exit criteria

- All 9 flaws either confirmed or downgraded.
- Each acceptance criterion in `../../_goal.md` has a phase-3 PR placeholder.
- `code-dev plan` ready to fire (phase-2 will populate it).
