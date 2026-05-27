# CD·PLAN·I5·A — audit + classification

> Decide for each gap from I5·S: (A) add as new PR, (B) fold into existing PR's acceptance, (C) defer to post-1.0 explicitly.

## Classification table

### A. NEW PRs to add

| New PR | Title | Wave | Bundles |
|--------|-------|-----:|---------|
| **PR-9.5** | `code-dev pr list` aggregator (D-B1 / G-I1) | W2 | top-2 R4 item, top-4 R2 item |
| **PR-9.6** | `code-dev preflight --mode=summary` (T-C1) + `code-dev next` reads `_meta.next-action` (T-C2) | W2 | both small UX wins |
| **PR-9.7** | `meta context use <slug>` (G-I10 / G-M1) | W2 | multi-project ergonomics |
| **PR-15.5** | Events-bus wiring `_events.log` ↔ kernel (D-A1) | W3 | substrate |
| **PR-15.6** | `igap` feedback from code-dev low-confidence moments (D-A3) | W3 | learning |
| **PR-20.5** | Caches: session-scoped read (T-B1), resume briefing (T-B2), shadow LRU (T-B5), `reviewer-state.json` sidecar (T-B3) | W3 | perf bundle |
| **PR-20.6** | `meta board` ASCII Kanban (G-I8) | W3 | discovery |
| **PR-20.7** | NS-1 study-evals workstream — design + initial harness | W3 | quality |
| **PR-20.8** | Split `code-dev-pr-review` into P1-P9 sub-programs (T-A2) | W3 | actual fix for RED program |
| **PR-25.5** | `state next` integration with `_index.md` (T-S1.12) | W3 | study-aware next-action |
| **PR-28.5** | PR-ergonomics suite: `pr sync N`, `pr drift N`, `pr export N`, `pr suggest-reviewer N`, `review --mode=coverage` (G-I3/I5/I9/I11 + W3-wf #9) | W4 | R4 industrial wave |
| **PR-31.5** | Recursive program loop detector (G.safe.07) + `tour` cross-ref lint (G.wf.02) | W4 | safety + UX |
| **PR-32.5** | Nightly `shadow refresh` cron + scheduler hardening prereq (T-F1) | W4 | automation |
| **PR-34.5** | Cheatsheet auto-section via `docgen` (G.umb.06) | W4 | doc hygiene |

### B. FOLD into existing PRs (acceptance-row additions)

| Existing PR | Additions |
|-------------|-----------|
| **PR-1** (T1 tests) | Add (5) boot smoke test (G.test.09): `python3 axon.py --check` exits 0; (6) `tour` cross-ref lint covered |
| **PR-3** (migrator) | Add (12) creates empty `study/_index.md` skeleton on v1→v4.1 |
| **PR-8** (study modes) | Add (5) `--target=<path>` flag (T-S1.2); (6) `--target=<glob>` expansion (T-S1.3); (7) `--output engineering\|executive\|machine` (T-S1.4); (8) `--input <path>` (T-S1.8) |
| **PR-9** (sessions) | Add (5) atomic-write for `journal/*` (G.inf.04 completion) |
| **PR-11** (plan reads rules) | Add (4) `plan --rule "<text>"` ad-hoc injection (T-S1.11) |
| **PR-14** (routers) | Add 5 more umbrellas: `code-dev-review.md`, `-journal.md`, `-knowledge.md`, `-flow.md`, `-shape.md` (full 10-verb set) |
| **PR-16** (plan modes) | Add (4) `plan --budget N` PR cap (T-S1.10) — overflow → `02-prs.deferred.md` |
| **PR-17** (study _index) | Add (4) `journal vocabulary` doc snippet referencing index kinds (T-S0.4) |
| **PR-23** (top docs) | Add (4) journal vocabulary section (T-S0.4); (5) workflow canonical-flows doc (G.wf.01) |
| **PR-26-28** (rename waves) | Add: cover R3 T2-T5 (alias-stubs, sub-command splits) — pre-existing PR set absorbs |
| **PR-7** (failure-mode catalog) | Add (4) `last-reviewed: <date>` per entry (G.safe.09 hygiene) |

### C. EXPLICITLY DEFER to post-1.0 (queue entries)

| Item | Why deferred |
|------|--------------|
| D-E1 PR-stack | high effort; needs new schema fields |
| D-E2 reviewer-bot loop | needs evals (NS-1) to be mature |
| D-B4 `pr-import` library-dev | new workflow class; deserves own study |
| G-CD-A4 `code-dev release` | semantic-release-like; substantial |
| D-C8 `coverage-delta` | depends on CI integration depth |
| D-C6 `conflict-predict` | needs PR-stack first |
| G.tok.06 cache-hit-rate metric | depends on provider API surface |
| G.wf.05 first-30-min tutorial | post-1.0 polish |
| G.wf.06 cookbook | post-1.0 polish |
| G.inf.06 v5 schema spec | wait for v4.1 production |
| G.team.* multi-actor | explicit non-goal for v1 |
| T-S2..S6 deeper study targets | post-1.0 unless individually pulled |
| NS-3..NS-14 future studies | study-task, not feature |
| R3 Wave T5 (drop alias stubs) | grace period; post-1.0 |

## Re-validation

### Coverage now
- R2 top-15: 15/15 ✓
- R2 net-new: 7 → 1 (migrator) shipped, 6 deferred explicitly ✓
- R3 umbrellas: 10/10 ✓
- R3 migration waves T1-T6: T1, T2, T3, T4, T6 in W4 + W2; T5 deferred ✓
- R4 top-20: 20/20 (16 active + 4 deferred with reason) ✓
- R5 T-S0.*: 4/4 ✓
- R5 T-S1.* (1-12): 12/12 ✓
- R5 NS-1, NS-2, NS-12: 3/3 ✓; NS-3..14 deferred ✓
- R6 G.*: ~93 — every P0 scheduled, every P1 scheduled or deferred with reason

### PR count after I5
- W1: 7 PRs (unchanged) + PR-V1.
- W2: 10 + **PR-9.5, 9.6, 9.7** = 13 PRs + PR-V2.
- W3: 8 + **PR-15.5, 15.6, 20.5, 20.6, 20.7, 20.8, 25.5** = 15 PRs + PR-V3.
- W4: 9 + **PR-28.5, 31.5, 32.5, 34.5** = 13 PRs + PR-V4.
- **Total**: 48 PRs + 4 version bumps = **52 PRs** to reach 1.0.0.

### DAG check (new PRs)
- PR-9.5 depends-on: PR-3 (schema, pr blocks).
- PR-9.6: independent (T-C1 reads `_meta.next-action` field which exists after PR-3 migration).
- PR-9.7: depends-on PR-3 (multi-project context implies stable schema).
- PR-15.5: depends-on PR-9 (sessions provide event-emit context).
- PR-15.6: depends-on PR-13 (usage logging) + PR-15.5.
- PR-20.5: depends-on PR-13 (caches measured by usage).
- PR-20.6: depends-on PR-9.5 (board reads pr-list output).
- PR-20.7: depends-on PR-13 + PR-18.
- PR-20.8: depends-on PR-2 (gate enforces post-split sizes).
- PR-25.5: depends-on PR-17.
- PR-28.5: depends-on PR-14 (routers in place for `pr` subcommands).
- PR-31.5: depends-on PR-1.
- PR-32.5: depends-on PR-13.
- PR-34.5: depends-on PR-23.

All acyclic.

### Wave gates remain valid
- W1 gate: unchanged.
- W2 gate: must include PR-9.5, 9.6, 9.7 in "all W2 PRs merged".
- W3 gate: must include 7 new W3 PRs.
- W4 gate: must include 4 new W4 PRs.

### Risk additions
- **R-15**: PR-14 expanded from 5 to 10 routers — bigger surface, more snapshot churn. Mitigation: still ships in one PR but rename-safety harness runs per-router.
- **R-16**: PR-28.5 bundles 5 new commands — could be split if review is heavy. Mitigation: PR can be split into PR-28.5a/b at execution time.
- **R-17**: PR-20.5 cache bundle — caches can introduce staleness bugs. Mitigation: each cache mtime-keyed + tested via PR-1 T1 framework extended.

## Verdict
- Plan v5 covers every actionable study output: **add** 14 new PRs, **fold** 11 acceptance-row additions into existing PRs, **defer** 14 items explicitly with reasons.
- Nothing from R2-R6 studies is silently dropped.

→ plan v5: `cd-plan-i5-p-final.md`.
