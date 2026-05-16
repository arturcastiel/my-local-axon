# CD·PLAN·I5·P — plan v5 (FINAL, full study coverage)

> v4 + the 14 new PRs and 11 acceptance-row additions identified in I5. Same discipline (acceptance, rollback, owner, parallelism, lint_paths) applies to every new PR.

## Wave summary (v5)

| Wave | PRs | New in v5 | Goals delivered |
|------|-----|-----------|-----------------|
| W1   | 7   | 0 (folds into PR-1, PR-3, PR-7) | foundation |
| W2   | 13  | **+3** (PR-9.5, 9.6, 9.7) + folds into PR-8, 9, 11, 14, 16, 17 | modes/sessions/governance + ergonomics |
| W3   | 15  | **+7** (PR-15.5, 15.6, 20.5, 20.6, 20.7, 20.8, 25.5) + folds | obs/perf/integration |
| W4   | 13  | **+4** (PR-28.5, 31.5, 32.5, 34.5) | renames/behavior/PR-ergonomics |
| **Σ**| **48** + 4 V-bumps = 52 | **+14 new** | |

## NEW W2 PRs

### PR-9.5 — `code-dev pr list` aggregator (D-B1 / G-I1)
- **Goals**: G-I1 (R4 top-6); D-B1 (R2 top-4).
- **User-visible**: "list every PR across phases in a single table".
- **Files**: new `workspace/programs/code-dev-pr-list.md`; `tools/pr_aggregate.py`.
- **Acceptance**: (1) `code-dev pr list` reads every `pr-N` block in `_meta.md` and any cross-project; (2) columns: id, slug, phase, state, last-program, age; (3) `--all-projects` flag iterates `my-axon/dev-projects/*`; (4) `--state=open|done|blocked` filter; (5) `lint_paths.py` clean.
- **Rollback**: revert.
- **Depends-on**: PR-3 (v4.1 schema).

### PR-9.6 — `preflight --mode=summary` (T-C1) + `next` reads `_meta.next-action` (T-C2)
- **Goals**: T-C1, T-C2.
- **User-visible**: "fast 1-line preflight + `next` actually reads cached next-action".
- **Files**: modified `workspace/programs/code-dev-preflight.md`, `code-dev-next.md`; minor `_axon_io.py`.
- **Acceptance**: (1) `preflight --mode=summary` prints single-line status (≤ 120 chars); (2) `next` reads `_meta.next-action` field (set by previous program) instead of reasoning from scratch when populated; (3) fallback to legacy behavior if field empty; (4) `lint_paths.py` clean.
- **Rollback**: revert.
- **Depends-on**: none.

### PR-9.7 — `meta context use <slug>` (G-I10 / G-M1)
- **Goals**: G-I10, G-M1.
- **User-visible**: "switch active project context with one command".
- **Files**: new `workspace/programs/code-dev-meta-context.md`; modified `tools/prefs.py` to handle `W:code-dev-project`.
- **Acceptance**: (1) `code-dev meta context use <slug>` validates project exists; (2) writes `W:code-dev-project` via prefs; (3) auto-saves current session before switch (warns if dirty); (4) `code-dev meta context list` shows all projects; (5) `lint_paths.py` clean.
- **Rollback**: revert.
- **Depends-on**: PR-3 (schema).

## NEW W3 PRs

### PR-15.5 — Events-bus wiring (`_events.log` ↔ kernel) (D-A1)
- **Goals**: D-A1 (R2 score 5/2).
- **User-visible**: "code-dev events appear in the kernel event bus; other programs can subscribe".
- **Files**: modified `tools/events.py`; new `workspace/programs/code-dev-events-emit.md`.
- **Acceptance**: (1) every code-dev verb emits structured event `{program, project, action, ts}` to `_events.log`; (2) kernel `events.py` `ON(<topic>)` handlers can subscribe; (3) one example handler subscribes to `pr.ready` and logs notification; (4) `lint_paths.py` clean.
- **Rollback**: revert; events stop emitting.
- **Depends-on**: PR-9 (session context).

### PR-15.6 — `igap` feedback from code-dev low-confidence (D-A3)
- **Goals**: D-A3.
- **User-visible**: "when code-dev hits ambiguity, it feeds `igap` (instruction-gap) for later review".
- **Files**: modified `tools/igap.py`; programs emit `igap` entries at HALT/QUERY points.
- **Acceptance**: (1) HALT-with-QUERY events write to `igap` log with context; (2) `code-dev meta igap` lists recent entries; (3) one synthetic test passes.
- **Rollback**: revert.
- **Depends-on**: PR-13 (usage logging baseline), PR-15.5.

### PR-20.5 — Caches bundle (T-B1, T-B2, T-B3, T-B5)
- **Goals**: T-B1 session read cache, T-B2 resume briefing cache, T-B3 `reviewer-state.json`, T-B5 shadow LRU.
- **User-visible**: "hot reads are cached; `resume` and `pr-review` are visibly faster".
- **Files**: new `tools/cd_cache.py`; new `tests/test_cache.py`; modified `code-dev-resume.md`, `code-dev-pr-review.md` (or its splits — see PR-20.8); new `_reviewer-state.json` per project.
- **Acceptance**: (1) session-scoped read cache (`W:code-dev-cache-*`) hits ≥ 50% on second resume in session; (2) resume briefing cache mtime-keyed; (3) `reviewer-state.json` sidecar persists across sessions; (4) shadow LRU bounded (max 32 entries); (5) cache invalidation on file mtime change verified by test; (6) `lint_paths.py` clean.
- **Rollback**: revert; reads fall back to direct.
- **Depends-on**: PR-13 (so we can MEASURE benefit, not blindly add).

### PR-20.6 — `meta board` ASCII Kanban (G-I8)
- **Goals**: G-I8.
- **User-visible**: "Kanban board view of PRs across projects".
- **Files**: new `workspace/programs/code-dev-meta-board.md`; `tools/board.py`.
- **Acceptance**: (1) columns: backlog, in-progress, blocked, ready-for-review, done; (2) reads from PR-9.5 aggregator; (3) `--project <slug>` scopes; default = all; (4) ≤ 200 columns wide.
- **Rollback**: revert.
- **Depends-on**: PR-9.5.

### PR-20.7 — Study-evals workstream (NS-1)
- **Goals**: NS-1.
- **User-visible**: "study mode outputs are now scored against a small eval set".
- **Files**: new `tools/study_evals.py`; new `tests/fixtures/study-evals/`; integration with PR-25 idempotence.
- **Acceptance**: (1) eval set of ≥ 5 fixture codebases × 3 modes; (2) `study_evals.py` runs target mode + scores structural-match + key-fact coverage; (3) score JSONL at `my-axon/log/study-evals/<date>.jsonl`; (4) `meta usage --by study-eval` integrates.
- **Rollback**: revert; tests bypassable.
- **Depends-on**: PR-13, PR-25 (idempotence).

### PR-20.8 — Split `code-dev-pr-review` into P1-P9 sub-programs (T-A2)
- **Goals**: T-A2 — the actual structural fix for the RED program.
- **User-visible**: "`pr review` now dispatches to focused P1-P9 sub-programs; compiled output is smaller and faster".
- **Files**: new `workspace/programs/code-dev-pr-review-p1.md` through `-p9.md`; modified `code-dev-pr-review.md` (router); compiled artifacts replaced.
- **Acceptance**: (1) 9 sub-programs, each focused (e.g. P1=summary, P2=diff, P3=risk, P4=style, P5=tests, P6=docs, P7=security, P8=performance, P9=final); (2) router dispatches by `--phase=N` or `--all` (default); (3) compiled output of each sub-program: GREEN per PR-2 gate; (4) pr-review aggregate ≤ 50% of pre-split bytes; (5) rename-safety snapshot updated.
- **Rollback**: revert; keep old `code-dev-pr-review` as fallback for one wave.
- **Depends-on**: PR-2 (gate), PR-12 (snapshot harness).

### PR-25.5 — `state next` integration with `_index.md` + staleness (T-S1.12)
- **Goals**: T-S1.12, partial G.wf.07.
- **User-visible**: "`next` factors in stale studies and pending PR-blocks".
- **Files**: modified `code-dev-next.md`; new `tests/test_next_integration.py`.
- **Acceptance**: (1) `next` reads `study/_index.md` for stale areas; (2) suggests `study --mode=X` when staleness > 60d AND area relevant to active PR; (3) suggests resuming pr-N if `pr-N.state=in-progress`; (4) preserves PR-9.6 fast-path when `_meta.next-action` is set.
- **Rollback**: revert.
- **Depends-on**: PR-17, PR-9.6.

## NEW W4 PRs

### PR-28.5 — PR-ergonomics suite (G-I3/I5/I9/I11 + R4-wf #9)
- **Goals**: G-I3 (`review --mode=coverage`), G-I5 (`pr suggest-reviewer`), G-I9 (`pr drift`), G-I11 (`pr export`), `pr sync N` (CI awareness).
- **User-visible**: "5 new PR-flow commands: sync, drift, export, suggest-reviewer, review-coverage".
- **Files**: new programs `code-dev-pr-sync.md`, `-pr-drift.md`, `-pr-export.md`, `-pr-suggest-reviewer.md`, `-review-coverage.md`; tooling `tools/pr_sync.py`, `tools/pr_drift.py`, `tools/pr_export.py`.
- **Acceptance**: (1) `pr sync N` pulls CI checks state (provider-agnostic interface; default reads `gh pr checks` if available); (2) `pr drift N` detects spec-vs-code drift via diff snapshot; (3) `pr export N` produces a portable packet (markdown + diff + tests); (4) `pr suggest-reviewer N` reads `_actions.log` to suggest based on history; (5) `review --mode=coverage` integrates coverage delta if data present (else: graceful skip); (6) each program has its own test; (7) `lint_paths.py` clean.
- **Rollback**: revert; programs deletable.
- **Depends-on**: PR-14 (routers), PR-9.5 (pr list).
- **Splittable note**: if review is heavy, can be PR-28.5a (sync+drift), PR-28.5b (export+suggest-reviewer), PR-28.5c (review-coverage).

### PR-31.5 — Recursive program loop detector + `tour` cross-ref lint (G.safe.07, G.wf.02)
- **Goals**: G.safe.07, G.wf.02.
- **User-visible**: "calls between programs can't loop forever; `tour` references are lint-checked".
- **Files**: new `tools/call_graph.py`; modified `tests/test_programs_md.py` (extend); `code-dev-tour.md` updated.
- **Acceptance**: (1) call_graph.py builds DAG of `EXEC(code-dev-*)` references; (2) cycle detected → CI fail; (3) depth limit (10) enforced at runtime via wrapper; (4) `tour` references current verbs only.
- **Rollback**: revert.

### PR-32.5 — Nightly `shadow refresh` cron + scheduler hardening prereq (T-F1)
- **Goals**: T-F1, partial scheduler hardening.
- **User-visible**: "shadows refresh nightly for active projects".
- **Files**: modified `tools/cron.py`; new `workspace/scheduler/shadow-refresh.cron.md` (declarative); modified `tools/shadow.py`.
- **Acceptance**: (1) cron entry refreshes shadows for projects with `status=active`; (2) opt-out via `_meta.shadow-cron: false`; (3) result logged to `my-axon/log/cron/<date>.jsonl`; (4) HUMAN-run cron — the agent does NOT install cron; produces installation snippet for user.
- **Rollback**: remove cron declaration.
- **Depends-on**: PR-13 (usage), PR-20.5 (cache integration).

### PR-34.5 — Cheatsheet auto-section via docgen (G.umb.06)
- **Goals**: G.umb.06.
- **User-visible**: "cheatsheet's verb list auto-updates from program `# desc:` lines".
- **Files**: modified `tools/docgen.py`; modified `workspace/AXON-DOCS-CHEATSHEET.md` (split: hand-written prose + auto-generated VERBS section between markers).
- **Acceptance**: (1) `docgen` emits VERBS section between `<!-- AUTO-VERBS-START -->` and `<!-- AUTO-VERBS-END -->`; (2) verbs sorted by frequency from usage log (top 10) or by umbrella otherwise; (3) regeneration is idempotent; (4) cheatsheet stays ≤ 80 lines.
- **Rollback**: remove markers; hand-edit reverts.
- **Depends-on**: PR-23, PR-13.

## EXISTING PRs — added acceptance rows

### PR-1 (T1 tests) — append acceptance
- (5) Boot smoke test (G.test.09): HUMAN runs `python3 axon.py --check` or equivalent and confirms exit 0 (agent provides command).
- (6) `tour` cross-ref check (G.wf.02 partial): `code-dev-tour.md` references only existing programs.

### PR-3 (migrator) — append acceptance
- (12) Creates empty `study/_index.md` skeleton on v1→v4.1 migration (filled by PR-17 later).

### PR-7 (failure-mode catalog) — append acceptance
- (4) Each mode has `last-reviewed: <ISO date>` field (G.safe.09 hygiene).

### PR-8 (study modes) — append acceptance
- (5) `--target=<path>` flag (T-S1.2).
- (6) `--target=<glob>` expansion (T-S1.3).
- (7) `--output engineering|executive|machine` (T-S1.4); machine variant emits front-matter parseable by `tools/study_index.py`.
- (8) `--input <path>` flag (T-S1.8).

### PR-9 (sessions) — append acceptance
- (5) Atomic-write helper extended to cover `journal/*` files (G.inf.04 completion).

### PR-11 (plan reads rules) — append acceptance
- (4) `plan --rule "<text>"` ad-hoc injection (T-S1.11); rule echoed in "Governance trace · Ad-hoc rules" subsection.

### PR-14 (router stubs) — expand from 5 to 10
- Add new umbrellas: `code-dev-review.md`, `code-dev-journal.md`, `code-dev-knowledge.md`, `code-dev-flow.md`, `code-dev-shape.md` (R3 full 10-verb set).

### PR-16 (plan modes) — append acceptance
- (4) `plan --budget N` PR cap (T-S1.10); overflow PRs written to `02-prs.deferred.md`.

### PR-17 (study _index + staleness) — append acceptance
- (4) Journal-vocabulary kinds documented inline (`study.overview`, `study.subsystem`, etc. — T-S0.4 fold).

### PR-23 (top docs) — append acceptance
- (4) Journal-vocabulary doc section (T-S0.4 deeper version).
- (5) Workflow canonical-flows doc (G.wf.01).

### PR-26-28 (rename waves) — append note
- These waves absorb R3 Wave T2 (alias-stubs), T3 (inline flag-merges), T4 (sub-command file splits). Each rename wave PR enumerates its T2/T3/T4 subset.

## Post-1.0 queue (explicit, named)

Move all of these to `workspace/programs/code-dev-roadmap.md` (W5+):
- D-E1 `code-dev pr-stack`
- D-E2 reviewer-bot loop
- D-B4 `code-dev pr-import` (library-dev bridge)
- G-CD-A4 `code-dev release` workflow
- D-C8 `coverage-delta`
- D-C6 `conflict-predict`
- G.tok.06 cache-hit-rate metric (needs provider API)
- G.wf.05 first-30-minutes tutorial
- G.wf.06 workflow cookbook
- G.inf.06 v5 schema spec (stack-id, last-sync, spec-history)
- G.team.* multi-actor mode
- T-S2..T-S6 deeper study targets (beyond mode core)
- NS-3..NS-14 future study workstreams
- R3 Wave T5 (drop alias stubs after grace period)

## Updated final gate (DONE = 1.0.0)
On top of v4 criteria, add:
- Every R2 top-15 item: closed or quarantined.
- All 10 R3 umbrellas: live.
- R4 top-20 active items: all 16 closed (4 explicitly deferred).
- All R5 T-S0 + T-S1 items (1-12): closed.
- NS-1 + NS-2 baselines recorded.
- Post-1.0 queue file `code-dev-roadmap.md` populated with named items.

## Risk additions (v5)
- **R-15**: PR-14 expansion 5→10 routers — bigger snapshot. Mitigated by PR-12 harness.
- **R-16**: PR-28.5 bundles 5 commands — may need split. Splittable into 5.a/b/c.
- **R-17**: PR-20.5 caches may introduce staleness bugs. mtime-keyed + tests.
- **R-18**: PR-20.8 pr-review split changes UX. Keep router for back-compat.
- **R-19**: 14 new PRs increases plan execution time materially. Mitigation: parallel-safe edges where possible; per-wave gate intact.

## DAG (additions)
All new PRs slot acyclically. Topological order remains W1 → W2 → W3 → W4 with parallel groups inside each wave; explicit `depends-on` per new PR.

— end of plan v5 (FINAL) —
