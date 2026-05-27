# Masterplan — AXON Polish

## Vision
Take AXON v3.7.0 (axon-synapse) from "feature-complete" to **heavy-workflow ready**:
- Every advertised program/tool actually works as described.
- Every bug has a reproducer and a fix path.
- Every workflow has end-to-end coverage (boot → multi-step → checkpoint → resume).
- Every interface is consistent (naming, errors, output layer, help).
- Every Core Rule has a guarded test.

## Phase graph (directed)

```
1-audit  ──▶  2-prioritise  ──▶  3-design  ──▶  4-implement  ──▶  5-validate
                                                                       │
                                                                       ▼
                                                                   release-ready
```

- **1-audit** *(current)* — inventory + bug census across 9 dimensions.
- **2-prioritise** — score each finding by impact × difficulty; cluster.
- **3-design** — PR specs per cluster (one PR per coherent fix surface).
- **4-implement** — execute PRs with PR-020 discipline (test + doc anchor + coverage).
- **5-validate** — heavy-workflow stress test; declare release-ready or loop back.

Phases are added by: `code-dev phase new`

## 9 audit dimensions (Phase 1 scope)
1. Usability (modes, commands, output layer, menu)
2. Interface (naming consistency, help/explain quality, error messages)
3. Behavior (docs vs. code drift)
4. Workflows (fixed/adaptive/hybrid; missing transitions; dead ends)
5. Programs (missing, redundant, broken)
6. Errors (bug census, halt patterns, fabrication risk)
7. Tools (registry vs. actual; missing; OPTIONAL→ACTIVE candidates)
8. Compliance (Core Rules coverage gaps; gate evasion paths)
9. Heavy-workflow gaps (long sessions, parallel programs, context pressure)
