# CD·C4·P3 — executive top-15 backlog (synthesis)

> Final ranked backlog combining cycle-1 (G-CD-*), cycle-2 (D-*), and cycle-3 (T-*). Dedup applied. Score = Impact / Effort (same rubric throughout). Sequenced for least-risk delivery.

## TOP 15 — executive backlog

| Rank | ID    | Item | I | E | Score | Cycle |
|-----:|-------|------|--:|--:|------:|:-----:|
| 1  | T-A1  | **Quarantine `code-dev-pr-review.cmp.md`** (negative-compression file) | 5 | 1 | **5.0** | C3 |
| 2  | T-A3  | **Compile-write gate: refuse cmp.bytes > src.bytes**                    | 4 | 1 | 4.0     | C3 |
| 3  | D-A2  | **Record `usage` for every code-dev run** (compile-suggest blind today) | 4 | 1 | 4.0     | C2 |
| 4  | D-B1  | **`code-dev pr-list` cross-phase aggregator**                            | 4 | 1 | 4.0     | C2 |
| 5  | T-B5  | **Shadow result LRU in-process cache**                                   | 3 | 1 | 3.0     | C3 |
| 6  | T-C1  | **`preflight --mode=summary`** (1-line output)                           | 3 | 1 | 3.0     | C3 |
| 7  | T-C2  | **`code-dev next` reads only `_meta.next-action`**                        | 3 | 1 | 3.0     | C3 |
| 8  | T-F1  | **Cron nightly `shadow refresh` per active project**                     | 3 | 1 | 3.0     | C3 |
| 9  | D-A1  | **Wire `_events.log` to kernel event bus** (EMIT/ON handlers)            | 5 | 2 | 2.5     | C2 |
| 10 | T-B1  | **Session-scoped read cache** (W:code-dev-cache-*)                       | 4 | 2 | 2.0     | C3 |
| 11 | T-B2  | **Resume briefing cache** (mtime-keyed)                                  | 4 | 2 | 2.0     | C3 |
| 12 | T-B3  | **`reviewer-state.json` sidecar**                                        | 4 | 2 | 2.0     | C3 |
| 13 | D-A4  | **Benchmark heaviest compiled programs**                                 | 4 | 2 | 2.0     | C2 |
| 14 | D-A3  | **Feed `igap` from code-dev low-confidence moments**                     | 4 | 2 | 2.0     | C2 |
| 15 | T-A2  | **Split `code-dev-pr-review` into P1–P9 sub-programs**                   | 5 | 4 | 1.25    | C3 |

## Net-new capabilities (separate, not in top-15 because of effort, but high impact)
| ID    | Item | Cycle |
|-------|------|:-----:|
| D-E1  | `code-dev pr-stack` (new / restack / push)                  | C2 |
| D-E2  | reviewer-bot-loop                                            | C2 |
| D-B2  | `code-dev migrate-v4`                                        | C2 |
| D-B4  | `code-dev pr-import` (library-dev bridge)                    | C2 |
| G-CD-A4 | `code-dev release` workflow                                 | C1 |
| D-C8  | `code-dev coverage-delta`                                    | C2 |
| D-C6  | `code-dev conflict-predict`                                  | C2 |

## Sequencing — 5 waves

### Wave 1 — Cleanup + measurement (ship together; near-zero risk)
- T-A1 (quarantine pr-review.cmp.md)
- T-A3 (compile-write regression gate)
- D-A2 (usage recording)
- D-A4 (benchmark heaviest)

**Outcome:** the worst regression is contained, future regressions blocked, real workload visible to the rest of AXON.

### Wave 2 — UX wins (visible, cheap)
- D-B1 (pr-list)
- T-C1 (preflight summary)
- T-C2 (next reads next-action)
- T-F1 (nightly shadow refresh cron)

**Outcome:** user-visible speedups in the most-used commands.

### Wave 3 — Substrate integration
- D-A1 (events-bus wiring)
- D-A3 (igap from code-dev)
- T-B5 (shadow LRU)

**Outcome:** code-dev becomes a first-class kernel citizen — events, gaps, perf measured.

### Wave 4 — Caching the hot reads
- T-B1 (session read cache)
- T-B2 (resume briefing cache)
- T-B3 (reviewer JSON)

**Outcome:** -30% session token cost in typical workflows.

### Wave 5 — pr-review refactor
- T-A2 (split pr-review into P1–P9)

**Outcome:** the largest workflow becomes phase-loadable instead of monolithic. Eliminates the single biggest per-session token line item.

## Combined estimated impact (Waves 1–5)
| Dimension              | Before        | After       | Δ |
|------------------------|--------------:|------------:|----:|
| Session token cost     | ~25–30 KB     | ~17–20 KB   | -30% |
| Negative-compression files | 1         | 0           | -1   |
| Compile regression risk| open          | gated       | mitigated |
| Substrate integration  | partial       | full        | + |
| Visible to user        | slow `next`, verbose preflight, monolithic pr-review | fast, summarized, phase-loadable | + |

## What ships AFTER the top-15 (medium-term roadmap)
- D-E1 PR-stack (Wave 6): brings code-dev to industry parity with Graphite/git-spice.
- D-E2 reviewer-bot loop (Wave 7): converges review cycles faster.
- D-B2 migrate-v4 (Wave 8): unblocks legacy projects (this very project, `axon-master`).
- D-B4 pr-import (Wave 9): library-dev bridge — novel capability.
- G-CD-A4 release workflow (Wave 10): semantic-release-style automation.
- D-C8 coverage-delta + D-C6 conflict-predict (Wave 11): quality-driven gates.

## Risks & mitigations (per Wave)
- W1: removing compiled pr-review until split means slower P1–P9 on source. Mitigate via `quarantine/` not delete; minimal wrapper.
- W2: behavioral change in `next` and `preflight --summary` — write tests + update docs.
- W3: events-bus wiring could double-log if old `_events.log` writes aren't gated. Mitigate: write to bus, mirror to file via single helper.
- W4: cache invalidation bugs. Mitigate: strict (path, mtime) keys; no TTL; tests.
- W5: program split has the highest design surface. Mitigate: spec-driven; use code-dev itself to plan the PRs.

## Backlog status post-cycle
Total findings: 50+ (G-CD-A..G across C1; D-A..G across C2; T-A..F across C3).
Promoted to executive top-15: 15.
Held for medium-term (Waves 6–11): 7 net-new capabilities.
Remaining (LOW-priority polish, score < 1.5): 28 items, deferred.
