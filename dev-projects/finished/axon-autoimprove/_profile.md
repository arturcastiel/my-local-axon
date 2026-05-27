# Project profile — axon-autoimprove

| Field             | Value |
|-------------------|-------|
| Domain            | code-dev (kernel-meta) |
| Risk class        | medium — touches `E:` state + cron + ranker tuning |
| dev-mode          | OFF for phases 1-3 of impl; optional flip in PR-209 only |
| Predecessor       | axon-synapse (closed) |
| Successor candidate | axon-science (second-domain proof — different project) |
| Estimated PRs     | 6-10 (PR-201..PR-209 + buffer) |
| Estimated phases  | 4 (study · design · implement · validate) |
| Reversibility floor | every PR must be reversible — no one-way migrations |
| Shadow            | required for every PR per D-011 |
| Audit cadence     | `axon-audit` after every wave of 3 PRs |
