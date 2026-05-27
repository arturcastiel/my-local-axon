# CD·GAP·C1·P3 — goals extracted from prior rounds

> Every concrete goal mentioned anywhere in R2..R5, normalized to a single ID space. Feeds the consolidated goal tree in `cd-gap-c4-p1-goal-tree.md`.

## Extraction rules
- One goal per row, source-cited.
- Renames consolidated.
- Duplicates merged.
- Each gets a stable ID `G.<topic>.<n>`.
- Acceptance from source preserved when present.

## Goals from Round 2 (token / quality)
| ID         | Goal                                                      | Source         |
|------------|-----------------------------------------------------------|----------------|
| G.tok.1    | Quarantine `code-dev-pr-review.cmp.md` (-1% compression) | R2 c3 T-A1     |
| G.tok.2    | Compile-write regression gate (block <95% compression)   | R2 c3 T-A3     |
| G.tok.3    | Audit ALL compiled programs (extend T-A1)                | R2 c3 + R6-U1  |
| G.tok.4    | Usage instrumentation (per-program counters)             | R2 c3 D-A2     |
| G.tok.5    | Per-program token-budget header                          | R2 c3 + R5     |
| G.tok.6    | Prompt-cache static-prefix discipline                    | R2 c3 web      |
| G.tok.7    | Compaction-resilient program structure                   | R2 c3 web      |

## Goals from Round 3 (umbrella)
| ID         | Goal                                                  | Source           |
|------------|-------------------------------------------------------|------------------|
| G.umb.1    | Ship 10 verb routers (additive)                       | R3 W1            |
| G.umb.2    | Stub 8 retire candidates (combine, divide, hold, since, replay, diff, check-structure, explain-reviewer) | R3 W2 |
| G.umb.3    | Flag-merges (--mode, --since, --patterns, --structure, --history) | R3 W3 |
| G.umb.4    | Rename clusters by file (state→safety→…→pr last)      | R3 W4            |
| G.umb.5    | Drop alias stubs after 1 release                      | R3 W5            |
| G.umb.6    | Recompile + cache audit after each cluster            | R3 W6            |
| G.umb.7    | gh-style help text per umbrella                       | R3 c2 (gh)       |
| G.umb.8    | Shared sub-verb lexicon (list/show/create/update/...) | R3 c4            |

## Goals from Round 4 (workflow + naming)
| ID          | Goal                                                       | Source                |
|-------------|------------------------------------------------------------|------------------------|
| G.wf.1      | `code-dev pr list` aggregator                              | R4 G-I1                |
| G.wf.2      | `code-dev meta board` ASCII Kanban                          | R4 G-I8                |
| G.wf.3      | `code-dev meta context use <slug>` (multi-project)         | R4 G-I10               |
| G.wf.4      | `code-dev bisect`                                          | R4 G-I6                |
| G.wf.5      | `code-dev state metrics throughput`                        | R4 G-I13               |
| G.wf.6      | `code-dev retro phase N`                                   | R4 G-I12               |
| G.wf.7      | `code-dev pr export N` packet                              | R4 G-I11               |
| G.wf.8      | `code-dev pr suggest-reviewer N` via CODEOWNERS            | R4 G-I5                |
| G.wf.9      | `code-dev pr sync N` (CI awareness)                        | R4 G-I4 / c2-p2        |
| G.wf.10     | `code-dev review --mode=coverage`                          | R4 G-I3                |
| G.wf.11     | `code-dev pr drift N`                                      | R4 G-I9                |
| G.wf.12     | Append-only spec versioning (`spec-history[]`)             | R4 G-I14               |
| G.wf.13     | `code-dev pr stack {new|restack|push|list}`                | R4 G-I2                |
| G.wf.14     | `code-dev journal log --redact-secrets`                    | R4 G-D2                |
| G.wf.15     | `code-dev meta cheatsheet [verb]`                          | R4 c2-p4               |
| G.wf.16     | `code-dev meta examples [verb]`                            | R4 c1-p2               |
| G.wf.17     | `code-dev meta dry-run` alias for `whatif`                 | R4 c3                  |
| G.wf.18     | Merge `next` into `state show` footer                      | R4 c3 (rename)         |
| G.wf.19     | Rename `tag` → `state save/restore`                        | R4 c3                  |
| G.wf.20     | `code-dev safety rule {add|list|...}` (rename dont-do)     | R4 c3                  |
| G.wf.21     | Write `workspace/AXON-DOCS-WORKFLOWS.md`                   | R4 c1-p4 / web         |
| G.wf.22     | `code-dev pr ready` reads study staleness (warn)           | R5 + R4                |
| G.wf.23     | `code-dev pr ready --strict` (block on staleness)          | R5 + R4                |

## Team-mode goals (deferred unless requested)
| ID         | Goal                                                | Source       |
|------------|-----------------------------------------------------|--------------|
| G.team.1   | Actor in audit log                                  | R4 G-T1      |
| G.team.2   | Owner of PR-N                                       | R4 G-T2      |
| G.team.3   | Mention routing                                     | R4 G-T3      |
| G.team.4   | CODEOWNERS-driven suggestions                       | R4 G-T4 (≡ G.wf.8) |
| G.team.5   | Multi-approver gate                                 | R4 G-T5      |
| G.team.6   | Cross-PR conflict detection                         | R4 G-T6      |
| G.team.7   | Async handoff to inbox                              | R4 G-T7      |
| G.team.8   | Team-level metrics                                  | R4 G-T8      |

## Study-mode goals (Round 5)
| ID         | Goal                                                | Source         |
|------------|-----------------------------------------------------|----------------|
| G.study.1  | `study/` folder + `_index.md`                       | R5 T-S0.1, S0.3|
| G.study.2  | Schema bump for `study/` (v4.1 minor)               | R5 T-S0.1      |
| G.study.3  | Migrator: `01-study.md` → `study/overview.md`       | R5 T-S0.2      |
| G.study.4  | `study --mode=<m>` flag (14 modes)                  | R5 L1-L3       |
| G.study.5  | `--target=<glob>`                                   | R5 T-S1.3      |
| G.study.6  | `--output engineering|executive|machine`            | R5 T-S1.4      |
| G.study.7  | `--budget tokens=N` + HALT-on-overflow              | R5 T-S1.7      |
| G.study.8  | `--input <path>` for mode data                       | R5 T-S1.8      |
| G.study.9  | Staleness flags in `_index.md`                       | R5 T-S1.9      |
| G.study.10 | `state next` reads `_index.md`                       | R5 T-S1.12     |
| G.study.11 | `--diff [--since=...]`                               | R5 T-S4.4      |
| G.study.12 | `--checkpoint` / `--resume`                          | R5 T-S4.5      |
| G.study.13 | `--recipe=<name>` runner                             | R5 T-S4.2      |
| G.study.14 | `--suggest-next`                                     | R5 T-S4.3      |
| G.study.15 | 7 canonical recipes                                  | R5 T-S4.1      |
| G.study.16 | `workspace/AXON-DOCS-STUDY.md`                       | R5 T-S6.5      |

## Plan-mode goals (Round 5)
| ID         | Goal                                                | Source        |
|------------|-----------------------------------------------------|---------------|
| G.plan.1   | `flow plan --mode=execution` (default)              | R5 T-S3.1     |
| G.plan.2   | `--mode=risk-first`                                  | R5 T-S3.2     |
| G.plan.3   | `--mode=budgeted` + `--budget N`                     | R5 T-S3.3     |
| G.plan.4   | `--mode=constrained` + `--rule "..."`                | R5 T-S3.4     |
| G.plan.5   | `--mode=cost`                                        | R5 T-S3.5     |
| G.plan.6   | `--mode=alignment` (reads `_meta.goals`)             | R5 T-S3.6     |
| G.plan.7   | `--mode=exploratory`                                 | R5 T-S3.7     |
| G.plan.8   | `--mode=dry`                                         | R5 T-S3.8     |
| G.plan.9   | `--replay`                                           | R5 T-S3.9     |
| G.plan.10  | `--multi-dev K`                                      | R5 T-S3.10    |
| G.plan.11  | `--epic` (replaces `plan-master`)                    | R5 T-S3.11    |
| G.plan.12  | Plan reads `safety/rules.md` (G-P13)                 | R5 c2-p3      |
| G.plan.13  | Plan reads `journal/decisions/*.md` (G-P12)          | R5 c2-p3      |
| G.plan.14  | Plan emits "STUDIES SUGGESTED NEXT" footer (G-P14)   | R5 c2-p3      |

## Round-6 goals (this round; expanded in later helpers)
| ID         | Goal                                                | Source        |
|------------|-----------------------------------------------------|---------------|
| G.gap.1    | Compiled-program audit (U-1)                        | R6 L2         |
| G.gap.2    | Schema migrator (v1→v4 and forward) (U-2)           | R6 L2         |
| G.gap.3    | Test surface for code-dev programs (U-3)            | R6 L2         |
| G.gap.4    | Failure-mode catalog (U-4)                          | R6 L2         |
| G.gap.5    | Governance composition rules (U-5)                  | R6 L3         |
| G.gap.6    | Session / chat / handoff unified model (U-6)        | R6 L3         |
| G.gap.7    | Documentation tree (U-7)                            | R6 L3         |
| G.gap.8    | Token-budget framework unified (U-8)                | R6 L3         |
| G.gap.9    | Backup hardening (U-11)                             | R6 (deferred) |
| G.gap.10   | Dispatch quality measurement (U-12)                 | R6 (deferred) |

## Tally
- Total normalized goals: **~80**.
- Team-mode (8) deferred unless requested.
- ~72 active goals; sequencing required.

→ external references: `cd-gap-c1-p4-web-findings.md`.
