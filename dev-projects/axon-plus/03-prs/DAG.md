# Plan DAG (PR-16.5)
**Nodes**: 19 · **Critical path**: 1 hops · **Parallel-safe entry points**: 19

## Critical path

pr-001

## Mermaid

```mermaid
graph LR
  subgraph ?
    pr_001[pr-001]:::cp
    pr_002[pr-002]
    pr_003[pr-003]
    pr_004[pr-004]
    pr_005[pr-005]
    pr_006[pr-006]
    pr_007[pr-007]
    pr_008[pr-008]
    pr_009[pr-009]
    pr_010[pr-010]
    pr_011[pr-011]
    pr_012[pr-012]
    pr_013[pr-013]
    pr_014[pr-014]
    pr_015[pr-015]
    pr_016[pr-016]
    pr_016_design[pr-016-design]
    pr_017_design[pr-017-design]
    pr_018_design[pr-018-design]
  end
  classDef cp fill:#ffe,stroke:#f80,stroke-width:2px
```

## Topological order

| # | PR | Wave | Deps |
|---|----|------|------|
| 1 | pr-001 | ? | — |
| 2 | pr-002 | ? | — |
| 3 | pr-003 | ? | — |
| 4 | pr-004 | ? | — |
| 5 | pr-005 | ? | — |
| 6 | pr-006 | ? | — |
| 7 | pr-007 | ? | — |
| 8 | pr-008 | ? | — |
| 9 | pr-009 | ? | — |
| 10 | pr-010 | ? | — |
| 11 | pr-011 | ? | — |
| 12 | pr-012 | ? | — |
| 13 | pr-013 | ? | — |
| 14 | pr-014 | ? | — |
| 15 | pr-015 | ? | — |
| 16 | pr-016 | ? | — |
| 17 | pr-016-design | ? | — |
| 18 | pr-017-design | ? | — |
| 19 | pr-018-design | ? | — |
