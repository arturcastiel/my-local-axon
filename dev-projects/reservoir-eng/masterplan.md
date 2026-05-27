# Masterplan — Reservoir-Eng

> Goal: leverage AXON's workflow machinery to ship reservoir-engineering
> programs + workflows, with host-independent MCP egress as the foundation.
> Source findings: phases/1-study/. Decisions: phases/2-plan/_decisions.md.

## Phase graph (directed)
```
1-study  (done) ──▶ 2-plan (active) ──▶ 3-implement ──▶ 4-validate
```

## Cluster → phase map
| Cluster | Theme | Phase | Priority |
|---------|-------|-------|----------|
| M — MCP egress | tools/mcp_client.py + server registry + pyrestoolbox link | 3-implement | **TOP** |
| D — domain discipline | reservoir.md prefs + output-standard gate + reservoir-review | 3-implement | high |
| P — programs+workflows | reservoir dispatcher + qa/dca/pvt/sensitivity + WF-1/WF-3 | 3-implement | high |
| V — validation | e2e on course sample data + review-gate pass | 4-validate | gate |

## v1 scope (locked)
IN:  MCP egress · reservoir prefs+gate · reservoir-review · reservoir(dispatcher)
     · reservoir-qa · reservoir-dca + WF-1 screening · reservoir-sensitivity + WF-3
OUT (v2): reservoir-pvt black-oil table (WF-2), matbal, nodal, relperm, flash,
     heterogeneity, geomechanics, mcp_server (reverse direction).

## Cross-project link
mcp_client built here is consumed by axon-ascent (lever #1). SPAWN/subagent
fan-out (WF-3) exercises axon-ascent #16. Coordinate; do not duplicate.
