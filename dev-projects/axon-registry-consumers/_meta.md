# Project: axon-registry-consumers
slug:            axon-registry-consumers
schema-version:  v4
status:          complete
phase:           3-pr
workflow-step:   done
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-registry-accessor
created:         2026-06-01
updated:         2026-06-05

## DONE (flipped 2026-06-05) — merged
PR-1 (migrate consumers to _axon_registry) + PR-2 (close the F22 lock scope hole + tighten allowlist) merged
(`04-log.md` "## Merged — 2026-06-01"; merge commit `b12871b` fix/f22-lock-single-accessor on main). 05-audit
8.5/10. Residual is ACCEPTABLE-by-design: 9 path-parameterised consumers still derive a registry path to pass
the accessor (correct for non-default registry locations) — schema-coupling, the real F22 risk, is gone.

## Working Context
Goal: close the largest SAFE audit gap — finish the F22 consumer migration (20 tools still hardcode
tools/REGISTRY.json; only 3 were migrated) and plug the single-accessor lock's tools/rules/ hole.
Parent axon-registry-accessor shipped the accessor + lock; this finishes the adoption.

## Start with
code-dev load axon-registry-consumers -> 01-study.md
