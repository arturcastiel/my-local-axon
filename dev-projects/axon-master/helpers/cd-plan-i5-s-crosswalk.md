# CD·PLAN·I5·S — full cross-walk: every study item vs plan v4

> Iteration 5. Walk EVERY actionable item from R2, R3, R4, R5, R6 against plan v4. Mark each: ✅ in-plan, ⚠ partial, ❌ missing, ⏳ deferred-post-1.0.

## Master inventory

### R2 (cd-c*) — top-15 + 7 net-new

| ID | Item | v4 status | Action |
|----|------|-----------|--------|
| T-A1 | Quarantine `pr-review.cmp.md` | ✅ PR-2 | — |
| T-A3 | Compile-write gate | ✅ PR-2 | — |
| D-A2 | Usage recording | ✅ PR-13 | — |
| D-B1 | `pr list` aggregator | ❌ | **add** |
| T-B5 | Shadow LRU cache | ❌ | **add (W3)** |
| T-C1 | `preflight --mode=summary` | ❌ | **add (W2)** |
| T-C2 | `code-dev next` reads `_meta.next-action` | ❌ | **add (W2)** |
| T-F1 | Cron nightly shadow refresh | ❌ | **add (W4)** |
| D-A1 | `_events.log` ↔ kernel event bus | ❌ | **add (W3)** |
| T-B1 | Session-scoped read cache | ❌ | **add (W3)** |
| T-B2 | Resume briefing cache | ❌ | **add (W3)** |
| T-B3 | `reviewer-state.json` sidecar | ❌ | **add (W3)** |
| D-A4 | Benchmark heaviest compiled | ✅ folded into PR-2 audit | — |
| D-A3 | Feed `igap` from code-dev low-confidence | ❌ | **add (W3)** |
| T-A2 | Split `pr-review` into P1-P9 | ❌ | **add (W3 or W4)** |
| D-E1 | `code-dev pr-stack` | ⏳ post-1.0 ✓ | confirm queue |
| D-E2 | reviewer-bot loop | ❌ | **defer (post-1.0)** |
| D-B2 | `code-dev migrate-v4` | ✅ PR-3 | — |
| D-B4 | `pr-import` library-dev bridge | ⏳ post-1.0 ✓ | — |
| G-CD-A4 | `code-dev release` | ❌ | **defer (post-1.0)** |
| D-C8 | `coverage-delta` | ❌ | **defer (post-1.0)** |
| D-C6 | `conflict-predict` | ❌ | **defer (post-1.0)** |

### R3 (cd-tools-*) — 10-verb umbrella + 6 migration waves

| ID | Item | v4 status | Action |
|----|------|-----------|--------|
| Umbrella `pr` | umbrella | ✅ PR-14 | — |
| Umbrella `meta` | umbrella | ✅ PR-14 | — |
| Umbrella `state` | umbrella | ✅ PR-14 | — |
| Umbrella `lifecycle` | umbrella | ✅ PR-14 | — |
| Umbrella `safety` | umbrella | ✅ PR-14 | — |
| Umbrella `review` | umbrella | ❌ | **add to PR-14** |
| Umbrella `journal` | umbrella | ❌ | **add to PR-14** |
| Umbrella `knowledge` | umbrella | ❌ | **add to PR-14** |
| Umbrella `flow` | umbrella | ❌ | **add to PR-14** |
| Umbrella `shape` | umbrella | ❌ | **add to PR-14** |
| T1 routers | wave | ✅ PR-14 | — |
| T2 alias-stubs (8 retire-candidates) | wave | ⚠ partial via W4 renames | confirm in W4 |
| T3 inline flag-merges | wave | ❌ | **add (W4)** |
| T4 sub-command file split | wave | ⚠ in renames | confirm |
| T5 drop alias stubs | wave | ⏳ post-rename grace period (W5+) | defer to post-1.0 |
| T6 recompile + cache audit | wave | ✅ PR-2 + ongoing | — |

### R4 (cd-wf-*) — top-20 backlog

| # | ID | Item | v4 | Action |
|--:|----|------|----|--------|
| 1-3 | (gates) | already covered | ✅ | — |
| 4 | — | 10 verb routers | ⚠ 5 of 10 | **expand PR-14** |
| 5 | — | Wave T2 alias-stubs | ⚠ W4 | confirm in W4 |
| 6 | G-I1 | `pr list` | ❌ | **add (W2)** |
| 7 | G-I8 | `meta board` ASCII Kanban | ❌ | **add (W3)** |
| 8 | G-I10/M1 | `meta context use <slug>` | ❌ | **add (W2)** |
| 9 | — | `pr sync N` + CI gate | ❌ | **add `pr sync` (W4)**; `pr ready --strict` ✅ |
| 10 | G-I3 | `review --mode=coverage` | ❌ | **add (W4)** |
| 11 | G-D2 | `journal log --redact-secrets` | ✅ PR-5 | — |
| 12 | — | (cookbook) | ⏳ post-1.0 | confirm |
| 13 | — | (tutorial) | ⏳ post-1.0 | confirm |
| 14 | — | (Diátaxis docs) | ✅ PR-23/24/33 | — |
| 15 | — | (failure modes) | ✅ PR-7 | — |
| 16 | G-I2 | `pr stack` | ⏳ post-1.0 ✓ | — |
| 17 | G-I5 | `pr suggest-reviewer N` | ❌ | **add (W4)** |
| 18 | — | (study modes) | ✅ | — |
| 19 | G-I11 | `pr export N` packet | ❌ | **add (W4)** |
| 20 | G-I9 | `pr drift N` | ❌ | **add (W4)** |

### R5 (cd-study-*) — T-S targets + NS list

T-S0.* (foundation):
| ID | Item | v4 | Action |
|----|------|----|--------|
| T-S0.1 | Study folder convention | ✅ PR-3 skeleton + PR-17 | — |
| T-S0.2 | Migrator for existing 01-study.md | ✅ PR-3 (folded) | — |
| T-S0.3 | `tools/study_index.py` | ✅ PR-17 | — |
| T-S0.4 | Journal vocabulary doc | ❌ | **fold into PR-23** (workflows doc) |

T-S1.* (study mode core):
| ID | Item | v4 | Action |
|----|------|----|--------|
| T-S1.1 | `study --mode=overview` | ✅ PR-8 | — |
| T-S1.2 | `study --mode=subsystem --target=<path>` | ⚠ mode yes, --target flag not stated | **fold into PR-8** |
| T-S1.3 | `--target=<glob>` | ❌ | **fold into PR-8** |
| T-S1.4 | `--output engineering\|executive\|machine` | ❌ | **add (W2 PR-8 extension)** |
| T-S1.5 | Multi-file output | ✅ implicit PR-8 | — |
| T-S1.6 | `_index.md` auto-update | ✅ PR-17 | — |
| T-S1.7 | `--budget tokens=N` | ⚠ deferred to PR-30 per-mode budgets | confirm |
| T-S1.8 | `--input <path>` | ❌ | **add (W2 PR-8 extension)** |
| T-S1.9 | Staleness flags | ✅ PR-17 | — |
| T-S1.10 | `flow plan --budget N` | ❌ | **add (W2 PR-16 extension)** |
| T-S1.11 | `flow plan --rule "..."` | ❌ | **add (W2 PR-11 extension)** ⚠ — this is the key user-control knob |
| T-S1.12 | `state next` integration | ❌ | **add (W3)** |

T-S2-S6 (extended targets): not enumerated explicitly here; folded into "deeper study modes" — most map to deferred or PR-29 behavioral. Add explicit "T-S2..S6 deferred to post-1.0" note.

NS list (next-study from R5 — these are STUDIES, not features):
| ID | Item | v4 | Action |
|----|------|----|--------|
| NS-1 | Study evals workstream | ❌ | **add (W3) as a study-task PR** |
| NS-2 | Idempotence + stability | ✅ PR-25 | — |
| NS-12 | Failure modes catalog | ✅ R6 + PR-7 | — |
| NS-3..14 | Future studies | ⏳ post-1.0 | **add to post-1.0 queue explicitly** |

### R6 (cd-gap-*) — 93 G.* goals

Sweep:
| ID | Item | v4 | Action |
|----|------|----|--------|
| G.inf.04 | atomic write for `journal/*` | ⚠ partial — `_meta.md`, `_actions.log`, `_session.md` covered; `journal/` not | **fold into PR-9** |
| G.inf.06 | v5 schema spec | ⏳ post-1.0 ✓ | — |
| G.tok.06 | cache-hit-rate metric | ❌ | **defer post-1.0** (depends on provider API) |
| G.tok.07 (folded into G.tok.06) | cache fields | ✅ PR-13 | — |
| G.umb.06 | cheatsheet auto-generated | ⚠ hand W1; auto deferred | **add (W3 PR-23 ext)** |
| G.wf.01 | Canonical-flows doc | ❌ | ✅ PR-23 (covers this) — confirm |
| G.wf.02 | `tour` cross-ref lint | ⚠ partial via PR-1 cross-ref | confirm |
| G.wf.03 | CI integration `pr sync` | ❌ | **add (W4)** |
| G.wf.04 | PR-stack | ⏳ post-1.0 ✓ | — |
| G.wf.05 | First-30-min tutorial | ⏳ post-1.0 ✓ | — |
| G.wf.06 | Cookbook | ⏳ post-1.0 ✓ | — |
| G.wf.07 | `code-dev next` weights | ⚠ partial PR-31 (context-switch) | confirm |
| G.test.09 | Boot smoke test | ❌ | **add (W1 fold into PR-1)** |
| G.safe.07 | Recursive program loop detector | ❌ | **add (W4)** |
| G.safe.09 | Catalog hygiene | ⚠ implicit `last-reviewed` field | confirm |
| G.team.* (4) | Multi-actor | ⏳ post-1.0 ✓ | — |

## Summary

**To ADD into the plan**: ~25 items.
- **PR additions** (new): ~10 new PRs needed.
- **PR expansions** (fold into existing PRs): ~12 acceptance-row additions.
- **Post-1.0 queue additions**: ~6 items.

## Top "you really missed this" items

1. **`plan --rule "..."`** (T-S1.11) — user's primary plan-control knob. Was in R5 design. MISSED.
2. **`plan --budget`** (T-S1.10) — companion to --rule. MISSED.
3. **`study --output engineering|executive|machine`** (T-S1.4) — output shape control. MISSED.
4. **`study --input <path>`** (T-S1.8) — feed-into-study. MISSED.
5. **5 of 10 R3 umbrellas** (review, journal, knowledge, flow, shape) — only half routed. INCOMPLETE.
6. **`pr list`** (D-B1 / G-I1) — top-of-list R4 deliverable. MISSED.
7. **`pr sync` + `pr drift` + `pr export` + `pr suggest-reviewer`** — entire R4 PR-ergonomics layer. MISSED.
8. **`meta board`** + **`meta context use`** (G-I8/I10) — R4 high-impact. MISSED.
9. **Events-bus wiring** (D-A1, score 5/2) — substrate integration. MISSED.
10. **`igap` feedback from code-dev** (D-A3) — learning loop. MISSED.
11. **Resume briefing cache + session cache + reviewer JSON** (T-B1/B2/B3) — perf trio. MISSED.
12. **Split `pr-review` into P1-P9** (T-A2) — the actual fix for the negative-compression program (we only QUARANTINED it; we never SPLIT it). MISSED.

→ audit + plan v5: `cd-plan-i5-a-audit.md`, `cd-plan-i5-p-final.md`.
