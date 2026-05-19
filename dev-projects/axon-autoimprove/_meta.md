# Project: AXON Auto-Improve — self-tuning ranker + ephemeral-promotion + telemetry baseline
slug:            axon-autoimprove
schema-version:  v4
status:          active
legacy:          false
phase:           2-design
workflow-step:   plan
branch:          main
codebase:        /mnt/c/projects/axon
parent:          axon-synapse
sub-projects:    []
created:         2026-05-18
updated:         2026-05-19
predecessor:     axon-synapse (closed 2026-05-18)
seed-audit:      ../axon-synapse/AUDIT.md

## Working Context
- Direct follow-on from axon-synapse (the composition path). Synapse shipped the
  ranker + orchestrator + suggestions footer; auto-improve closes the loop by
  letting the system tune its own thresholds, promote ephemeral suggestions to
  permanent ones, archive cold paths, and surface live metrics — all narrow,
  reversible, opt-in via `L:auto-improve`.
- Hooks already shipped via synapse PR-120 (toggle `L:auto-improve`, cron stub).
  This project wires the actual orchestration behind those hooks.
- Closes axon-synapse acceptance criteria #7 (ephemeral promotion) and #10
  (manual-lookup baseline) — both deferred at synapse close.
- dev-mode OFF initially. Most work lands in `tools/` + `workspace/programs/`.
  Only the kernel-side "auto-improve receipt" footer line (if shipped at all)
  would require dev-mode — that's a phase-3 decision, not phase-1.
- Run: `code-dev study` to begin Phase 1.

## Acceptance gates (top-level — see _goal.md for full set)
1. `L:auto-improve = true` enables the daily cron action and the system measurably
   improves on at least one metric over 7 days of lived data.
2. Every auto-action is reversible (rollback log + `undo` command).
3. Drift gate honored — no auto-action fires when `drift.state ≡ "diverged"`.
4. R9 holds — no `axon/` writes unless a strictly-scoped, dev-mode-gated PR
   demands it (e.g. an opt-in receipt line).
