# Project: axon-accountable-autonomy
slug:            axon-accountable-autonomy
schema-version:  v4
status:          complete
phase:           3-pr
workflow-step:   done
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-architecture
created:         2026-06-01
updated:         2026-06-05

## DONE (flipped 2026-06-05) — merged
PR-1 (tools/accountability.py open/reconcile/status) + PR-2 (verify_stop un-reconciled-ledger surface)
merged as **!97** (`04-log.md` "## Merged — 2026-06-01"; merge commit `0d0c624` fix/accountability-ledger on
main). 05-audit done. Status field was stale active.

## Working Context
General, mechanical fix for the "spawn agents and move on" drift: a ledger of spawned/background work +
a LOG-ONLY Stop-hook surface of un-reconciled entries. Prose ("write it down") is advisory and drifts;
this gives the correction teeth. Owner-chosen shape: LOG-ONLY surface + explicit open/reconcile.

## Start with
code-dev load axon-accountable-autonomy -> 01-study.md
