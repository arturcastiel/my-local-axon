# Phase: 1-telemetry
schema-version: v4
status:         planned
workflow-step:  not-started
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    (none — entry phase)
successor:      2-integration, 4-eval
source-audit:   /home/arturcastiel/projects/axons-audit/recommendations/LOW-HANGING-FRUIT.md

## Scope (full detail in ../../masterplan.md § 1-telemetry)
- Fruit B: L:prompt-log-enabled + L:turn-log-enabled = true
- Fruit C: seed dispatch index (compile-suggest compile --top 10)
- Fruit D: axon-audit weekly cron
- Fruit F: L:auto-improve on (dry-run, 1 week)
- Lever #13: observability dashboard MVP (Flask+HTMX over log/audit/local)

## Why first
Refreshed baseline (../../_baseline-2026-05-23.md): usefulness stuck at 72.6
because dispatch/usage/plans/prompt-log are all zero. Nothing downstream is
measurable until this phase flips telemetry on.

## Start with
code-dev load axon-ascent → code-dev phase start 1-telemetry
