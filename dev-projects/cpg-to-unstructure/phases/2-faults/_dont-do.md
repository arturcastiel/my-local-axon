# Phase prohibitions — 2-faults

_(seeded; prohibitions land here as patterns emerge from the
implementation work)_

## Inherited from 1-design (still binding)
- Never edit `axon/` core from project code-dev work
- Never autonomously run pytest / pip install / git push outside
  the workspace-backup whitelist (kernel R9 + Pattern A)
- Never bundle the viz/ sidecar into the installed
  `cpg2unstructured` package — it stays at repo root, excluded
  by setuptools' `include = ["cpg2unstructured*"]`
- Properties algebra, transmissibility, MAPAXES, .EGRID, PyPI
  publish — out of scope per refined project goal (see
  user-side memory: project_cpg2python_goal.md)
