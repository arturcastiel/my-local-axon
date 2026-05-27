# CD·WF·C4·P1 — synthesis (workflow study, 4 layers integrated)

> Top-line takeaways merging Rounds 2 (token/quality), 3 (umbrella), 4 (workflow). One executive view.

## What this 4-round study reveals

Layer 1 (canonical flows + entry points + cookbook): the workflow vocabulary is rich — 8 named WFs covering 95% of usage — but **invisible** to users; they must rediscover it each session.

Layer 2 (industrial gaps): code-dev is competitive in *spec discipline* and *audit trail*, but lags industry on:
- aggregator views (`pr list`, board, dashboards)
- CI/CD signal integration
- stacked PRs
- multi-project context
- team-mode (actor attribution)

Layer 3 (naming): the 57-program surface contains ~15 confusing names; the Round-3 umbrella resolves ~12 with stubs, the remaining ~3 (`pr-review` vs `review`, `tag`, `dont-do`) need explicit renames.

Layer 4 (this synthesis): a coherent roadmap can absorb both Round-3 (umbrella) and the new Round-4 findings into one sequence of waves.

## Executive backlog (top-20 actions, merging round 2 + 3 + 4)

| # | Action                                          | Source            | Effort | Impact |
|--:|-------------------------------------------------|-------------------|:------:|:------:|
| 1 | Compile-write regression gate (T-A3)            | R2 cycle 3        | S | 5 |
| 2 | Quarantine `pr-review.cmp.md` (T-A1)            | R2 cycle 3        | S | 5 |
| 3 | Record usage (D-A2: usage instrumentation)      | R2 cycle 3        | S | 4 |
| 4 | Ship Wave T1 (10 verb routers)                  | R3                | M | 5 |
| 5 | Ship Wave T2 (alias-stubs for 8 retire-candidates)| R3              | S | 4 |
| 6 | Add `pr list` (G-I1)                            | R4 c2             | S | 5 |
| 7 | Add `meta board` ASCII Kanban (G-I8)            | R4 c2             | S | 4 |
| 8 | Add `meta context use <slug>` (G-I10 / G-M1)    | R4 c2             | S | 4 |
| 9 | Add `pr sync N` + `pr ready` CI gate            | R4 c2-p2          | M | 5 |
|10 | Add `review --mode=coverage` (G-I3)             | R4 c2             | M | 4 |
|11 | Add `journal log --redact-secrets` (G-D2)       | R4 c2-p3          | S | 4 |
|12 | Rename `state save/restore` (was `tag`)         | R4 c3             | S | 3 |
|13 | Merge `next` into `state show` footer           | R4 c3             | S | 4 |
|14 | Add `meta cheatsheet [verb]`                    | R4 c2-p4          | S | 3 |
|15 | Add `meta dry-run` alias for `whatif`           | R4 c3             | S | 2 |
|16 | Add `pr stack {new|restack|push|list}` (G-I2)   | R4 c2 / R3        | L | 5 |
|17 | Add `pr suggest-reviewer N` (G-I5)              | R4 c2             | S | 3 |
|18 | Add `state actions [N]` reader                  | R4 c1             | S | 3 |
|19 | Add `pr export N` packet (G-I11)                | R4 c2             | M | 3 |
|20 | Add `pr drift N` (G-I9)                         | R4 c2             | M | 4 |

S=small, M=medium, L=large. Impact 1–5.

## Sequenced waves (revised for Round 4)

### Wave 0 — Quality regression gates (PREREQUISITE)
- #1 compile-write regression gate
- #2 quarantine pr-review.cmp.md
- #3 usage instrumentation

### Wave 1 — Umbrella routers (foundation)
- #4 ship 10 verb routers (no behavior change)
- #13 fold `next` into `state show` footer (parallel)

### Wave 2 — High-impact aggregators (new value)
- #6 `pr list`
- #7 `meta board`
- #8 `meta context use`
- #18 `state actions`

### Wave 3 — CI awareness (industrial credibility)
- #9 `pr sync` + gated `pr ready`
- #10 `review --mode=coverage`
- #17 `pr suggest-reviewer`

### Wave 4 — Stub rollout + reshape
- #5 alias-stubs for retire candidates
- #12 state save/restore rename
- #15 `meta dry-run` alias
- #14 `meta cheatsheet`

### Wave 5 — Spec discipline + packets
- #20 `pr drift`
- #19 `pr export`
- #11 `journal log --redact-secrets`

### Wave 6 — Stacked PRs (largest deferred)
- #16 `pr stack` family

## Net result if all 6 waves ship

- 57 verbs → 10 + ~55 subcommands.
- 8 confusing-name pairs retired.
- 12 new capabilities (G-I1, I8, I10, I3, I11, I2, I5, I6, I9, I12, I13, D2).
- CI signal integrated; coverage delta visible.
- Multi-project context supported.
- Industrial-tooling parity reached for solo/small-team workflows.

## What this study does NOT solve

- Team-mode (G-T1..T8): explicitly deferred behind `W:team-mode ≡ true` toggle. Need a separate study.
- IDE / GUI: out of scope.
- Real-time collaboration: kernel single-actor rule.
- Auto-merge / network ops: HUMAN-only rule.
- Cross-project dependency declaration (G-M3): low priority, deferred.

→ Concrete shippable roadmap: `cd-wf-c4-p2-roadmap.md`.
→ Suggested next study: `cd-wf-c4-p3-next-study.md`.
