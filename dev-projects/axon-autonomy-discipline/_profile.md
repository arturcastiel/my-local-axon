# Project profile — axon-autonomy-discipline

linter:        ruff / black (Python tools); markdown programs via doc-anchors + neuron-audit
changelog:     CHANGELOG.md
reviewers:     []
cross-repo:    []
test-cmd:      python3 -m pytest tests/ -q
gate-cmd:      python3 axon.py crucible gate      # parse passed==true SEPARATELY before any commit
fast-cmd:      python3 -m pytest tests/test_smoke.py -q
build-cmd:     (none — agent never runs build/push; HUMAN runs push)

## Substrate this project extends (don't reinvent)
- `tools/autonomous_mode.py` — the grant model (ALWAYS_DENY kernel-change; DESTRUCTIVE_OPS default-off;
  per-grant allow-list). The autonomy CONTRACT is the entry gate built on top of this.
- `tools/accountability.py` — open/reconcile/status ledger. Mandatory reconciliation at run-end.
- IDENTITY LOCK (`ASSERT(L:cognition-frame ≡ "AXON-OS")`) + `tools/session.py` checkpoint/transition —
  the substrate for the mandatory REANCHOR.
- `tools/plan_dag.py` + PR `depends-on` metadata + `synapse-suggest` — the substrate for deterministic
  feature SELECTION (walk the ready-frontier; never ahead of dependencies).
- workflow trajectories + `code-dev-replay` — the substrate for the run REPORT + replay.

## Sibling
- `axon-discipline` = the correctness floor (test harness, anti-masking, coverage, ratchet). This
  project is the autonomy floor that lets that one run overnight. Keep the two cleanly separable.

## Repo operating rules (full list in _dont-do-seeds.md)
- Remote GitLab `ci.tno.nl/...axon`; merge `glab mr merge <N> --squash`. Trailer
  `Co-authored-by: AXON <axon@arturcastiel.github.io>`. Brand-free / no `PR-<n>` commit messages.
- dev-mode only for `axon/` writes (restore OFF after); most work here is `tools/`+`tests/`.
