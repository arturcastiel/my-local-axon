# Masterplan — HR-Team Improvements (phase graph)
> Executable PR plan → 02-plan.md (pending). Phase status → _phases.json.

## Phases
1. study — DONE (01-study.md)
2. plan  — pending (02-plan.md · 02-prs.md · 03-prs/DAG.json)
3. pr · 4. log · 5. audit — pending

## Fix vectors → PR backlog (to be DAG'd in plan)
1. [CRIT·urgent] Propagate fail-closed run_seats guard to the for-use checkout (close silent-fabrication window).
2. Wire CONVENER → harness sub-agent fan-out (real run_seats backend; ADR-002 boundary kept).
3. Conformance test: STUB response can never reach a §4.3 verdict (fail-open BLOCKED).
4. SELECTOR roster-quality gate: empty/weak/mis-matched roster → fail-closed + loud.
5. Reconcile tools/hr_team.py across dev + for-use checkouts (dev-version-drift family).

## Method
Conservative · test-more · redo-until-closed. Fail-closed exemplar (the anti-thesis of the bug it fixes).
