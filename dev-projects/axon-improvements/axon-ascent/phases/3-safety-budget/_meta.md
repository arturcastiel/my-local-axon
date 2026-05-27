# Phase: 3-safety-budget
schema-version: v4
status:         planned
workflow-step:  not-started
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    2-integration
successor:      5-benchmark
source-audit:   /home/arturcastiel/projects/axons-audit/recommendations/IMPROVEMENTS.md

## Scope (full detail in ../../masterplan.md § 3-safety-budget)
- Lever #6: token-budget gate (L:session-token-budget + L:daily-token-budget
  + response-gate counter — same shape as confidence/inference gate)
- Lever #4: Docker sandbox adapter (workspace/sandbox/ + L:sandbox-mode);
  builds on axon-polish PR-1.1 shell.py gate (which is partial: gate yes,
  runtime isolation no)
- Feature #7: adversary reviewer response gate (prompt-injection scan)
- Feature #6: plan-mode default for code-dev (flip default to simulate→confirm)

## Start with
code-dev load axon-ascent → code-dev phase start 3-safety-budget
