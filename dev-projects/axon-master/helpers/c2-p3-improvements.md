# C2·P3 — Improvements from deep internals

> Builds on C1·P3 + C2·P1 + C2·P2. Focus areas where the cycle revealed structural issues vs cosmetic gaps.

## Scoring rubric (same as C1·P3)
Impact 1-5, Effort 1-5. Score = Impact / Effort. Top of backlog ≥ 1.5.

---

## A. STRUCTURAL CONSISTENCY (foundational)

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-A1 | Reconcile `COMPLETE` (SCHEDULER) vs `COMPLETED` (PROCESS) status enum | 4 | 1 | 4.0 | C2·P1 finding 2 |
| C2-A2 | Resolve HIGH preemption rule disagreement                      | 3 | 1 | 3.0 | C2·P1 finding 2 |
| C2-A3 | Document `local/` scope in MEMORY.md                           | 4 | 1 | 4.0 | C2·P1 finding 2 |
| C2-A4 | Audit + reconcile cross-spec terminology drift (full sweep)    | 3 | 2 | 1.5 | C2·P1 + C2·P2 A1 |
| C2-A5 | Document or replace `CLEAR(W:key-*)` glob assumption           | 3 | 1 | 3.0 | C2·P1 finding 3 |
| C2-A6 | Split `KILL` into `COMPLETE-PROCESS` + `KILL-PROCESS`          | 3 | 3 | 1.0 | C2·P1 finding 3 |

---

## B. SNAPSHOT MECHANICS (collapse parallel systems)

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-B1 | Unified `W:snapshot-[type]-[id]-[seq]` store (replace `W:preempt-*` + `W:checkpoint-*`) | 4 | 4 | 1.0 | C2·P1 finding 4 |
| C2-B2 | `axon snapshot list / inspect / restore` command suite        | 3 | 2 | 1.5 | C2·P2 B2 |

---

## C. COMPILER OPTIMIZATIONS (token compression)

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-C1 | O7 soft-shape fusion (handle interleaved no-op LOG/STORE)     | 3 | 3 | 1.0 | C2·P1 finding 5 |
| C2-C2 | O11 — constant folding (literal arithmetic, string concat, bool ops at compile time) | 3 | 3 | 1.0 | C2·P2 C2 |
| C2-C3 | O12 — cross-phase optimization (hoist invariants, merge stores) | 4 | 4 | 1.0 | C2·P2 C3 |
| C2-C4 | Empirical compression dashboard (read benchmark-log → ratio trend per program) | 3 | 2 | 1.5 | C2·P2 C4 |
| C2-C5 | Per-program `# budget: <n>` directive + compile gate          | 4 | 3 | 1.3 | C2·P2 E2 |

---

## D. GRAMMAR COVERAGE (close known gaps)

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-D1 | Grammar-miss tracker (log misses; ranked report)              | 4 | 2 | 2.0 | C2·P2 D1 |
| C2-D2 | Add grammar rules for: time/date math, resource locking, rate limiting, pagination, generic negation | 3 | 3 | 1.0 | C2·P1 finding 7 |
| C2-D3 | `grammar add <pattern>` assisted authoring program            | 3 | 3 | 1.0 | C2·P2 D2 |

---

## E. SOFT-FAIL POLICY (correctness)

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-E1 | Non-interactive staleness auto-recompile (`compile --auto-recompile`) | 4 | 2 | 2.0 | C2·P1 finding 6, C2·P2 F1 |
| C2-E2 | Per-program `# strict-schema: true` directive                 | 3 | 2 | 1.5 | C2·P2 F2 |
| C2-E3 | `L:compile-strictness = strict` preference                    | 2 | 1 | 2.0 | C2·P2 F3 |

---

## F. MEASUREMENT (instrumentation)

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-F1 | Verify tiktoken-on-hot-path; reconcile c1-p1 vs c2-p1 contradiction | 3 | 1 | 3.0 | C2·P1 finding 8 |
| C2-F2 | Real benchmarking: 10-program before/after on each new optimizer rule | 3 | 2 | 1.5 | C2·P2 E1 |
| C2-F3 | Token estimator unification (single code path)                 | 3 | 2 | 1.5 | C3·P1 confirms 3 paths |

---

## G. AUTHORING ERGONOMICS

| ID    | Item                                                          | Impact | Effort | Score | Source |
|-------|---------------------------------------------------------------|--------|--------|-------|--------|
| C2-G1 | Template gallery program (list `axon/compiler/templates/` + `workspace/templates/`) | 2 | 1 | 2.0 | C2·P2 H1 |
| C2-G2 | `compile template apply <name> --to <new>` scaffolder         | 3 | 2 | 1.5 | C2·P2 H2 |

---

## TOP 12 from this cycle (by score, ≥1.5)

| Rank | ID    | Item                                                          | Score |
|------|-------|---------------------------------------------------------------|-------|
| 1    | C2-A1 | Reconcile COMPLETE/COMPLETED enum                             | 4.0   |
| 2    | C2-A3 | Document `local/` scope in MEMORY.md                          | 4.0   |
| 3    | C2-A2 | Resolve HIGH preemption rule                                  | 3.0   |
| 4    | C2-A5 | Document/replace CLEAR(W:key-*) glob                          | 3.0   |
| 5    | C2-F1 | Verify tiktoken-on-hot-path                                   | 3.0   |
| 6    | C2-D1 | Grammar-miss tracker                                          | 2.0   |
| 7    | C2-E1 | Non-interactive staleness auto-recompile                      | 2.0   |
| 8    | C2-G1 | Template gallery program                                       | 2.0   |
| 9    | C2-E3 | L:compile-strictness preference                               | 2.0   |
| 10   | C2-A4 | Cross-spec terminology drift sweep                            | 1.5   |
| 11   | C2-B2 | axon snapshot list/inspect/restore                            | 1.5   |
| 12   | C2-C4 | Compression dashboard                                         | 1.5   |

---

## STRUCTURAL OBSERVATIONS

The cycle-2 findings split cleanly into **two failure modes**:

1. **Spec drift** — multiple files document the same concept differently. Cure: a single CONTRACT.md or stronger axon-audit.
2. **Soft-fail philosophy** — warn-only checks let real bugs through. Cure: per-program strictness opt-in + non-interactive default.

Both are fixable without dramatic re-architecture; the leverage is high (foundational), the effort is low (mostly docs + one or two compile flags).

---

## RISKS

- **C2-A1 / C2-A6** (enum/KILL rename): existing programs reference current names. Migration shim required.
- **C2-B1** (unified snapshot): same migration concern.
- **C2-C1/C2/C3** (new O-rules): need empirical validation per C2-F2 before activation.

---

## NOT IN SCOPE FOR THIS CYCLE

- Cross-spec audit *automation* (proposed in C2-A4 as `kernel-conflict-scan`) — flag for cycle 3 implementation if dev-mode session is opened.
- O7/O11/O12 *implementation* — flag for cycle 4 plan.
