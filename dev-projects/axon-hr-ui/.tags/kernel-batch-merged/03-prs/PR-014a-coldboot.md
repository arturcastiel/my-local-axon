# PR-014a-coldboot — AXON-COLDBOOT mechanical preflight
Status: merged
Commit: d4f6ba3
Phase: pr
Lane: AXON (autonomous, non-kernel)
Depends-on: none  ·  Realizes: PR-013 (dropped)  ·  Informs: PR-014, PR-T0-bootflow

## Scope
- `tools/boot_friction.py` (registered OPTIONAL as `boot-friction`) — Layer 0 static, subject-free
  boot-path audit: dead load-bearing targets, missing Step-0 install script, front-loading metric.
- `benchmark/cold-start/` — Layer 1 naive-agent harness (cold_stranger.py, tasks.json, rubric.json,
  run.sh, README). Reports gitignored.
- `tests/test_boot_friction.py`, `tests/test_cold_stranger.py`.

## Why
The mechanical half of the O2/PR-014 onboarding tier — gives the stranger test a wired preflight that
needs no owner session. Robustness: per-run credential refresh (frozen-token 401 fix), 5xx/overloaded
retry, honest reached/auth/skip tally.

## Acceptance
- 26 cold-boot tests green · Layer-0 audit clean · live run shows auth-clean + transients retried.
- `boot-friction` OPTIONAL (benchmark tool, not runtime) → liveness clean.

## Result
Merged d4f6ba3. Surfaced finding PR-T0-bootflow (newcomer boot halts at my-axon gate).
