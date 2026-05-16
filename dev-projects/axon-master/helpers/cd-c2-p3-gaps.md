# CD·C2·P3 — deeper improvements (post-internals)

> Cycle-2 ranked backlog. Builds on cycle-1 gaps + deeper findings from `cd-c2-p1-internals.md`. Each entry has Impact / Effort / Score and traces back to a workflow (W1–W15 in `cd-c2-p2-workflows.md`).

## A. CRITICAL — substrate integration

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-A1  | Wire `_events.log` to kernel event bus; emit standard kinds | 5 | 2 | 2.5 | W8 / G-CD-B1 |
| D-A2  | Record `usage` for every code-dev run; expose to `compile-suggest` | 4 | 1 | 4.0 | G-CD-B3 |
| D-A3  | Record `igap` entries when low-confidence in study / plan / pr | 4 | 2 | 2.0 | G-CD-B2 |
| D-A4  | Benchmark heaviest compiled programs (pr-review, audit) | 4 | 2 | 2.0 | G-CD-B6 |

## B. HIGH — missing core commands

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-B1  | `code-dev pr-list` aggregator across phases | 4 | 1 | 4.0 | W10 / G-CD-A2 |
| D-B2  | `code-dev migrate-v4` (dry-run by default) | 5 | 3 | 1.7 | W9 / G-CD-A1 |
| D-B3  | `code-dev finalize` (merge+cascade+changelog+audit) | 4 | 2 | 2.0 | W4 |
| D-B4  | `code-dev pr-import` (from library-dev or external draft) | 4 | 2 | 2.0 | W3 / G-CD-F1 |
| D-B5  | `code-dev pr-archive` (move merged PR specs to archive/) | 2 | 1 | 2.0 | G-CD-A5 |

## C. HIGH — quality / drift

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-C1  | Per-round HARMONIZATION-vN.md history | 3 | 1 | 3.0 | D-PR1 from internals |
| D-C2  | `pr-review` P2 scope cap (spec files + 1-hop deps, --full opt-out) | 4 | 2 | 2.0 | D-PR2 |
| D-C3  | `pr-review` P5 emits `harmonize.sh` script for HUMAN | 3 | 2 | 1.5 | D-PR3 |
| D-C4  | Mechanical Gate-3 for `[scope]` prohibitions | 3 | 2 | 1.5 | W15 |
| D-C5  | reviewer-state in JSON; markdown render becomes view-only | 3 | 3 | 1.0 | G-CD-G1 |
| D-C6  | `code-dev conflict-predict` for stacks/PRs | 4 | 4 | 1.0 | W7 / G-CD-C1 |
| D-C7  | `code-dev test-from-diff` auto test-suggest | 3 | 3 | 1.0 | W5 / G-CD-C5 |
| D-C8  | `code-dev coverage-delta` on changed lines | 4 | 3 | 1.3 | W6 / G-CD-C4 |
| D-C9  | Semantic scope-creep gate (new public API detection) | 4 | 4 | 1.0 | G-CD-C6 |

## D. MEDIUM — observability

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-D1  | metrics: per-program runs + duration | 3 | 1 | 3.0 | W13 / G-CD-D1 |
| D-D2  | metrics: shadow hit/miss rate | 3 | 1 | 3.0 | G-CD-D2 |
| D-D3  | metrics: reviewer round-time + cycle distribution | 3 | 2 | 1.5 | G-CD-D3 |
| D-D4  | Mermaid render of `_pr-links.md` | 2 | 1 | 2.0 | G-CD-D4 |
| D-D5  | `_actions.log` reader CLI (`code-dev actions [N]`) | 2 | 1 | 2.0 | G-CD-G3 |
| D-D6  | Typed-schema header for `_events.log` (front-matter) | 2 | 1 | 2.0 | G-CD-G4 |

## E. MEDIUM — orchestration / stacks

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-E1  | `code-dev pr-stack` commands (new/restack/push) | 4 | 4 | 1.0 | W1 / G-CD-A3 |
| D-E2  | reviewer-bot-loop convergence harness | 4 | 4 | 1.0 | W2 / G-CD-E1 |
| D-E3  | `code-dev parallel` safety semantics (lock + per-PR worktree hint) | 3 | 3 | 1.0 | G-CD-E2 |
| D-E4  | `code-dev reviewer-assign` (routing in _profile.md) | 2 | 1 | 2.0 | G-CD-E3 |

## F. MEDIUM — UX / cross-system

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-F1  | code-dev metrics ⇒ axon-audit usefulness | 2 | 1 | 2.0 | G-CD-F3 |
| D-F2  | code-dev resume cache (mtime-keyed) | 3 | 2 | 1.5 | internals §5 |
| D-F3  | Better `handoff` — diff-from-last-handoff mode | 2 | 2 | 1.0 | G-CD-D6 |

## G. LOW — schema polish

| ID    | Item | I | E | Score | Sources |
|-------|------|--:|--:|------:|---------|
| D-G1  | Per-branch shadow scoping (sub-dirs per branch) | 3 | 4 | 0.75 | internals §3 |
| D-G2  | Lock-file for project (single-writer) | 3 | 2 | 1.5 | internals concurrency |
| D-G3  | Index `_decisions.md` by `Supersedes:` chain | 2 | 2 | 1.0 | internals §4 |
| D-G4  | Embedding cache co-located with shadow findings | 3 | 4 | 0.75 | W11 |

## TOP 15 (cycle-2 ranked)

| Rank | ID | Item | Score |
|------|----|----- |------:|
| 1  | D-A2 | usage recording                              | 4.0 |
| 2  | D-B1 | pr-list aggregator                            | 4.0 |
| 3  | D-D1 | metrics per-program runs/duration              | 3.0 |
| 4  | D-D2 | metrics shadow hit/miss                        | 3.0 |
| 5  | D-C1 | per-round HARMONIZATION-vN                     | 3.0 |
| 6  | D-A1 | events-bus wiring                              | 2.5 |
| 7  | D-B3 | code-dev finalize                              | 2.0 |
| 8  | D-B4 | code-dev pr-import (library-dev bridge)        | 2.0 |
| 9  | D-A4 | benchmark heaviest compiled                    | 2.0 |
| 10 | D-A3 | igap recording                                 | 2.0 |
| 11 | D-C2 | pr-review P2 scope cap                         | 2.0 |
| 12 | D-D4 | Mermaid `_pr-links.md`                         | 2.0 |
| 13 | D-D5 | `_actions.log` reader                          | 2.0 |
| 14 | D-B5 | `pr-archive`                                   | 2.0 |
| 15 | D-B2 | `migrate-v4`                                   | 1.7 |

## Sequencing recommendation
1. **Substrate first** (D-A1..A4) — unlocks observability for everything else.
2. **Cheap UX wins** (D-B1, D-B5, D-D4, D-D5) — visible payoff, near-zero risk.
3. **pr-review hardening** (D-C1..C3) — directly attacks largest compiled program.
4. **Metrics enrichment** (D-D1..D3) — needs A2/A4 wired first.
5. **Big features** (D-E1..E3, D-B2) — substantive design and migration work.

→ token economy in `cd-c3-p1-tokens.md`; final synthesis in `cd-c4-p3-improvements.md`.
