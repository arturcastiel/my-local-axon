# Deviations from plan — study

_No deviations recorded yet._

- 2026-07-09 · code-dev-pr-create spec deviation (recorded): the program's tail
  advance (phase-model done --phase pr --best-effort) was DELIBERATELY not run
  after PR-001's spec — the pr output contract is a >=1 glob, which would stamp
  pr:done with 4 of 5 specs unwritten (premature-done, the inverse stale-pointer
  bug). Manifest advance deferred until all 5 specs exist. Latent-bug scope → PR-003.
