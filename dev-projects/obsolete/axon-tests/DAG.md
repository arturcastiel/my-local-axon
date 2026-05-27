# DAG — AXON Test Battery

> Project: axon-tests · Generated: 2026-05-16
> Source: canonical SQL todo_deps + `02-prs.md`
> 21 nodes · 25 edges · **acyclic** ✓
> Critical path: 7 PRs (PR-001 → PR-006 → PR-009 → PR-011 → PR-018 → PR-020 → PR-021)

## Mermaid graph

```mermaid
flowchart TD
  %% Wave colors
  classDef waveA fill:#dff5e1,stroke:#2e7d32,color:#1b5e20
  classDef waveB fill:#fde2e1,stroke:#c62828,color:#b71c1c
  classDef waveC fill:#e3f2fd,stroke:#1565c0,color:#0d47a1
  classDef waveD fill:#fff3e0,stroke:#ef6c00,color:#e65100
  classDef critical stroke-width:3px,stroke-dasharray:0

  %% Wave A — Foundations
  PR001[PR-001<br/>CI: full pytest]:::waveA
  PR002[PR-002<br/>coverage gate]:::waveA
  PR003[PR-003<br/>install pre-push]:::waveA
  PR004[PR-004<br/>doc template]:::waveA
  PR005[PR-005<br/>workflow harness]:::waveA
  PR006[PR-006<br/>rules scaffold]:::waveA

  %% Wave B — Safety-critical
  PR007[PR-007<br/>identity gate]:::waveB
  PR008[PR-008<br/>boot contract]:::waveB
  PR009[PR-009<br/>R9 dev-mode]:::waveB
  PR010[PR-010<br/>workspace-backup]:::waveB
  PR011[PR-011<br/>full rules]:::waveB

  %% Wave C — Breadth
  PR012[PR-012<br/>verifier integration]:::waveC
  PR013[PR-013<br/>workflows W-01..07]:::waveC
  PR014[PR-014<br/>workflows W-09..15]:::waveC
  PR015[PR-015<br/>compiler+dispatch]:::waveC
  PR016[PR-016<br/>tier-A programs]:::waveC
  PR017[PR-017<br/>tool gaps]:::waveC

  %% Wave D — Closure
  PR018[PR-018<br/>docgen blocking]:::waveD
  PR019[PR-019<br/>mandatory pre-push]:::waveD
  PR020[PR-020<br/>CONTRIBUTING]:::waveD
  PR021[PR-021<br/>final docs + badges]:::waveD

  %% Edges
  PR001 --> PR002
  PR001 --> PR005
  PR001 --> PR006
  PR001 --> PR007
  PR001 --> PR015
  PR001 --> PR019
  PR003 --> PR019
  PR004 --> PR007
  PR004 --> PR018
  PR002 --> PR017
  PR005 --> PR008
  PR005 --> PR010
  PR005 --> PR013
  PR005 --> PR014
  PR005 --> PR016
  PR006 --> PR009
  PR006 --> PR011
  PR009 --> PR011
  PR011 --> PR012
  PR011 --> PR018
  PR013 --> PR014
  PR013 --> PR018
  PR014 --> PR018
  PR018 --> PR020
  PR020 --> PR021

  %% Critical path highlight
  class PR001,PR006,PR009,PR011,PR018,PR020,PR021 critical
```

## Topological levels (max parallelism per level)

| Level | Can run in parallel                                                | Width |
|-------|--------------------------------------------------------------------|-------|
| L0    | PR-001 · PR-003 · PR-004                                           | 3     |
| L1    | PR-002 · PR-005 · PR-006 · PR-007 · PR-015 · PR-019                | 6     |
| L2    | PR-008 · PR-009 · PR-010 · PR-013 · PR-016 · PR-017                | 6     |
| L3    | PR-011 · PR-014                                                    | 2     |
| L4    | PR-012 · PR-018                                                    | 2     |
| L5    | PR-020                                                             | 1     |
| L6    | PR-021                                                             | 1     |

Max parallel width is 6 (at L1 and L2). With unlimited reviewers,
the project finishes in 7 sequential steps (the critical path).

## Critical path (longest chain)

```
PR-001 ──▶ PR-006 ──▶ PR-009 ──▶ PR-011 ──▶ PR-018 ──▶ PR-020 ──▶ PR-021
( CI )     (scaffold)  ( R9 )    (full     (gate     (CONTRIB)   (docs +
                                  rules)    blocking)             badges)
```

Any delay on these 7 PRs slips the whole project. PR-001 and PR-006
are the two earliest critical nodes — keep them ungrouped and ship
them first.

## Notable fan-out / fan-in

- **Fan-out from PR-005** (workflow harness): 5 children
  (PR-008, 010, 013, 014, 016). If PR-005 slips, half of Wave B/C
  blocks.
- **Fan-out from PR-001** (CI full-suite): 6 children. The single
  highest-leverage node.
- **Fan-in to PR-018** (doc gate blocking): 4 parents
  (PR-004, 011, 013, 014). PR-018 cannot start until every doc-
  producing PR has landed.

## Independent starting nodes (parallel work today)

PR-001, PR-003, PR-004 have no dependencies. They can all be
implemented in parallel right now.

## See also

- `02-plan.md`   — tactical plan
- `02-prs.md`    — PR list (titles, scope, deps)
- `02-roadmap.md` — strategic roadmap (releases R1..R4)
- `DAG.json`     — machine-readable form of this graph
