# 03-plan.md — axon-master plan v5 (FINAL, full study coverage)

**Schema**: plan-v1 · **Status**: ready-for-execution · **Mode**: tactical
**Created**: 2026-05-16 · **Iterations**: 5 (study→audit→plan × 5)
**Source**: helpers/cd-plan-i1..i5-{s,a,p}-*.md
**Coverage**: every R2-R6 actionable item is either scheduled or explicitly deferred (see Post-1.0 queue).
**Governance trace**: loaded `safety/rules.md` (0 rules) · `dont-do.md` (absent) · `_index.md` (pre-W2) · filtered 0 · flagged 0 · conflicts 0

## Plan envelope
- **Scope**: AXON OS hardening so code-dev is dependable as flagship workflow; **all** R2-R6 study outputs are addressed.
- **PR count**: **48** functional PRs + **4** version-bump PRs = **52 PRs** across W1-W4.
- **DONE**: 0.9.x → 1.0.0 at end of W4.
- **Out of scope (explicit, named in Post-1.0 queue below)**: multi-actor, library-dev parallel, PR-stack, v5 schema, visual UI, network sync, CI deep integration, reviewer-bot loop, release workflow, coverage-delta, conflict-predict, first-30-min tutorial, cookbook, NS-3..NS-14 future studies, R3 Wave T5 (drop alias stubs).
- **Constraints**: kernel rules, user-memory safety rules, AGENT contract all in force. Empty `safety/rules.md` is allowed; plan proceeds.

## Owner convention
- **AGENT**: writes code, docs, tests, helpers.
- **HUMAN**: runs `pytest`, runs `compile.py`, runs `migrate_meta.py` (after dry-run review), runs `git push` (only on explicit consent), merges PRs.

---

## WAVE 1 — foundation (7 PRs)

### PR-1 — T1 structural tests + cross-ref lint + boot smoke + tour lint
- **Goals**: G.test.01, G.test.09 (boot smoke), partial G.wf.02 (tour lint).
- **User-visible**: "every code-dev program is now structurally lint-checked; boot smoke test green; tour references validated".
- **Files**:
  - new: `tests/coverage.json`.
  - modified: `tests/test_programs_md.py`, `tests/conftest.py`.
- **Acceptance**: (1) every `workspace/programs/code-dev*.md` with `status != draft|deprecated` passes T1; (2) cross-ref lint — every `EXEC(code-dev-X)` references existing program; (3) `pytest tests/test_programs_md.py -v` (HUMAN) prints "passed N programs"; (4) `tests/coverage.json` enumerates per-program status; (5) boot smoke: agent provides `python3 axon.py --check` (or equivalent) command; HUMAN runs, confirms exit 0; (6) `code-dev-tour.md` cross-ref check passes (references only existing verbs).
- **Rollback**: `git revert`.
- **Owner**: AGENT writes; HUMAN runs pytest + boot smoke.
- **Parallelism**: blocks PR-3, PR-12.

### PR-2 — Compile audit + regression gate + static-prefix lint
- **Goals**: G.tok.01, G.tok.02, G.tok.03, G.tok.04.
- **User-visible**: "compiled programs now have a regression gate; bloat is blocked".
- **Files**:
  - new: `tools/audit_compiled.py`, `workspace/programs/compiled/_quarantine.md`, `study/compiled-audit.md` (in axon-master).
  - modified: `tools/compile-write.py`, `tools/tokenizer.py`, `tools/REGISTRY.json`, `tests/test_compiled_regression.py`, `workspace/preferences/compile.toml` (`gate-mode`).
- **Acceptance**: (1) audit produces full numbers table ≥ 10 programs; (2) classified GREEN/YELLOW/RED/GREY; (3) ≥1 RED quarantined (pr-review confirmed); (4) gate at 0.95 bytes AND 0.95 tokens; (5) floor: src < 512 B skips check; (6) `--override "<reason>"` logs to `_actions.log`; (7) static-prefix lint: first 2 KB byte-stable across two compiles; (8) WARN→BLOCK flip after one full audit pass clean; (9) tokenizer pinned anthropic, fallback char/4; (10) `tools/lint_paths.py` clean.
- **Rollback**: revert `compile-write.py`.
- **Owner**: AGENT writes; HUMAN runs audit + reviews quarantine.
- **Parallelism**: blocks PR-3 and all recompiles.

### PR-3 — Schema migrator v1 → v4.1 + atomic `_meta.md`
- **Goals**: G.inf.01, G.inf.02, G.inf.03, G.study.04, partial G.inf.04.
- **User-visible**: "old projects auto-upgrade their `_meta.md`".
- **Files**:
  - new: `tools/migrate_meta.py`, `workspace/AXON-DOCS-SCHEMA.md`, `workspace/programs/code-dev-migrate.md`, `tests/test_migrator.py`, `tests/fixtures/projects/v1-minimal/`, `tests/fixtures/projects/v1-with-custom/`.
  - modified: `tools/_axon_io.py` (atomic_write), `workspace/programs/code-dev-resume.md`, `tools/REGISTRY.json`, `my-axon/.gitignore` (`*.bak.*`).
- **Acceptance**: (1) dry-run on v1 fixture reports plan, 0 writes; (2) real run produces v4.1 + `_meta.md.bak.<ts>`; (3) idempotent re-run = no-op; (4) `--restore` byte-exact; (5) `--all` iterates `my-axon/dev-projects/*` with confirmation; (6) retention keeps last 3; (7) unknown sections preserved as `## CUSTOM` (e.g. `STUDY DIRECTIVE`); (8) axon-master dry-run reviewed by HUMAN, then real run; (9) `code-dev resume` works post-migration; (10) PR-1 T1 passes after resume edit; (11) `tools/lint_paths.py` clean; (12) creates empty `study/_index.md` skeleton on v1→v4.1 (filled by PR-17 later).
- **Rollback**: `migrate_meta.py --restore`.
- **Owner**: AGENT writes; HUMAN runs dry-run, approves, runs real.
- **Parallelism**: ⊥ PR-4. Depends on: PR-1, PR-2.

### PR-4 — Governance schema + precedence doc + plan-reads-rules stub
- **Goals**: G.gov.01, G.gov.02, partial G.plan.04, G.gov.04 (stub).
- **User-visible**: "`safety/rules.md` schema and precedence are now defined; plans emit a governance trace".
- **Files**:
  - new: `workspace/safety/rules.md`, `workspace/AXON-DOCS-GOVERNANCE.md`, `tools/rules.py`, `tests/test_governance.py`.
  - modified: `workspace/programs/code-dev-plan.md`, `workspace/programs/code-dev-pr-ready.md`, `tools/REGISTRY.json`.
- **Acceptance**: (1) empty rules.md parses → []; (2) `tools/rules.py` exposes `PRECEDENCE` constant; doc generated from it; (3) plan emits "## Governance trace" (empty in W1); (4) `pr ready --strict` prints stub message + exit 1; (5) 8 precedence levels documented; (6) `tools/lint_paths.py` clean.
- **Rollback**: revert files.
- **Owner**: AGENT writes; HUMAN reviews precedence doc.
- **Parallelism**: ⊥ PR-3.

### --- MUST-set boundary (PR-1..4 = MUST for W2 entry; PR-5..7 may finish during W2) ---

### PR-5 — Secret redaction + pre-push scan
- **Goals**: G.safe.03, G.safe.08.
- **User-visible**: "log writes redact secrets; pre-push scan flags secrets in diffs".
- **Files**:
  - new: `tools/redact.py`, `tools/scan_pre_push.py`, `workspace/safety/redact-allowlist.md`, `tests/test_redact.py`.
  - modified: `tools/log.py`, `tools/REGISTRY.json`.
- **Acceptance**: (1) test redacts `sk-...`, `AKIA...`, `eyJ...{20+}`, `*_TOKEN=`, `*_KEY=`; (2) allowlist exempts templates + fixtures; (3) `<file>.redactions.log` sidecar in `my-axon/memory/local/`; (4) pre-push scan exit-1 on match; (5) `tools/lint_paths.py` clean.
- **Rollback**: revert log.py.
- **Owner**: AGENT writes; HUMAN runs scan pre-push.

### PR-6 — One-page cheatsheet
- **Goals**: G.doc.10.
- **User-visible**: "AXON-DOCS-CHEATSHEET.md (one-pager) ships".
- **Files**: new `workspace/AXON-DOCS-CHEATSHEET.md`.
- **Acceptance**: ≤ 80 lines; 10 verbs + 5 flows + 3 escape hatches; only links to existing W1 docs; HUMAN sign-off.
- **Rollback**: delete file.

### PR-7 — Failure-mode catalog + postmortem template
- **Goals**: G.safe.01, G.safe.02, G.safe.09 (hygiene).
- **User-visible**: "canonical failure-mode catalog and postmortem template available".
- **Files**: new `workspace/log/failure-modes.md`, `workspace/templates/postmortem.md`.
- **Acceptance**: (1) ≥ 25 modes across classes A-H; (2) each with trigger/signal/mitigation/owner; (3) template renders one synthetic example; (4) every mode has `last-reviewed: <ISO date>` field (catalog hygiene).
- **Rollback**: delete files.

### PR-V1 — Version bump 0.7.0
- **Files**: modified `VERSION`, `CHANGELOG.md` (`## Unreleased` → `## 0.7.0 — <date>`).
- **Acceptance**: VERSION = `0.7.0`; CHANGELOG block sealed.

### Wave-1 entry gate to W2 (HARD)
1. PR-1 + PR-2 + PR-3 + PR-4 merged.
2. axon-master schema = v4.1.
3. Compile gate in BLOCK after one full audit pass.
4. T1 tests green.
5. Governance trace section appears in `code-dev plan` output.

Soft: PR-5, PR-6, PR-7, PR-V1 may finish during W2.

---

## WAVE 2 — modes + sessions + governance + ergonomics (13 PRs)

### PR-8 — Study modes core (+ target/output/input flags)
- **Goals**: G.study.01, partial G.study.07, T-S1.2, T-S1.3, T-S1.4, T-S1.8.
- **User-visible**: "`code-dev study` supports `--mode`, `--target` (path or glob), `--output engineering|executive|machine`, `--input <path>`".
- **Files**: new `workspace/programs/code-dev-study-area.md`; modified `code-dev-study.md`.
- **Acceptance**: (1) 3 modes produce distinct sectioned outputs; default = `standard` (back-compat); (2) `--target=<path>` scopes (T-S1.2); (3) `--target=<glob>` expands before walk (T-S1.3); (4) `--output engineering|executive|machine` — machine variant emits front-matter parseable by `tools/study_index.py` (T-S1.4); (5) `--input <path>` reads supplied JSON/text and integrates (T-S1.8).

### PR-9 — `_session.md` + auto-checkpoint + atomic state-files
- **Goals**: G.sess.01, G.sess.03, G.inf.04 (full: `_meta.md`, `_actions.log`, `_session.md`, `journal/*`).
- **User-visible**: "every chat journals to `_session.md` with auto-checkpoints; all state files atomic".
- **Files**: new `tools/session.py`, `tests/test_session.py`; modified handoff/freeze/tag/resume programs; `tools/_axon_io.py` (atomic for `_actions.log` and `journal/*`).
- **Acceptance**: (1) `_session.md` created per chat on first verb; (2) state enum {active, frozen, tagged, closed, recovered}; (3) auto-checkpoint every 20 turns AND before `_meta.md` mutation; (4) atomic writes verified by concurrent-edit synthetic test; (5) atomic-write helper extended to cover `journal/*` files (G.inf.04 completion).

### PR-9.5 — `code-dev pr list` aggregator
- **Goals**: G-I1 (R4 top-6), D-B1 (R2 top-4).
- **User-visible**: "list every PR across phases (and projects) in one table".
- **Files**: new `workspace/programs/code-dev-pr-list.md`, `tools/pr_aggregate.py`; `tools/REGISTRY.json`.
- **Acceptance**: (1) reads every `pr-N` block in `_meta.md`; (2) columns: id, slug, phase, state, last-program, age; (3) `--all-projects` iterates `my-axon/dev-projects/*`; (4) `--state=open|done|blocked` filter; (5) `lint_paths.py` clean.
- **Rollback**: revert.
- **Owner**: AGENT writes; HUMAN runs.
- **Depends-on**: PR-3.

### PR-9.6 — `preflight --mode=summary` + `next` reads `_meta.next-action`
- **Goals**: T-C1, T-C2.
- **User-visible**: "fast 1-line preflight; `next` uses cached next-action when available".
- **Files**: modified `workspace/programs/code-dev-preflight.md`, `code-dev-next.md`.
- **Acceptance**: (1) `preflight --mode=summary` prints ≤ 120-char status; (2) `next` reads `_meta.next-action` field if present, else legacy reasoning; (3) `lint_paths.py` clean.
- **Rollback**: revert.
- **Depends-on**: none.

### PR-9.7 — `meta context use <slug>`
- **Goals**: G-I10, G-M1.
- **User-visible**: "switch active project context in one command".
- **Files**: new `workspace/programs/code-dev-meta-context.md`; modified `tools/prefs.py`.
- **Acceptance**: (1) `meta context use <slug>` validates project; writes `W:code-dev-project`; (2) auto-saves current session before switch (warns if dirty); (3) `meta context list` shows all projects; (4) `lint_paths.py` clean.
- **Rollback**: revert.
- **Depends-on**: PR-3.

### PR-10 — Governance `--strict` (full)
- **Goals**: G.gov.04, G.gov.05.
- **User-visible**: "`pr ready --strict` and `plan --strict` actively gate on rules, stale studies, failing tests, missing acceptance".
- **Files**: modified `tools/rules.py`, `code-dev-pr-ready.md`, `code-dev-plan.md`; extends `tests/test_governance.py`.
- **Acceptance**: strict blocks listed; `--strict-explain` enumerates each gate result.

### PR-11 — Plan reads rules (full) + governance trace + `--rule` injection
- **Goals**: G.plan.04, G.plan.05, T-S1.11.
- **Files**: modified `code-dev-plan.md`.
- **Acceptance**: (1) synthetic rule filters an option; (2) trace shows filtered count; (3) HALT if >80% filtered; (4) `plan --rule "<text>"` ad-hoc injection (T-S1.11) — rule echoed under "Governance trace · Ad-hoc rules" subsection.

### PR-12 — Rename-safety harness
- **Goals**: G.umb.04, G.test.07.
- **User-visible**: "any program rename is gated by a snapshot diff".
- **Files**: new `tools/rename_snapshot.py`, `tests/test_rename_safety.py`, `tests/snapshots/programs-pre-rename.jsonl`.
- **Acceptance**: snapshot captures `{program, desc, sections, status}` for every program; diff fails on regression.

### PR-13 — Usage logging
- **Goals**: G.obs.01.
- **Files**: modified `tools/usage.py`; new `my-axon/log/usage/.keep`.
- **Acceptance**: JSONL `{ts, session, program, in_tokens, out_tokens, cache_creation, cache_read}` (nulls allowed); ≥ 1 turn logged.

### PR-14 — Router stubs (full 10-umbrella set)
- **Goals**: G.umb.01 (full R3 set).
- **Files**: new `workspace/programs/code-dev-meta.md`, `code-dev-pr.md` (umbrella; old → `-pr-create` stub), `code-dev-state.md`, `code-dev-lifecycle.md`, `code-dev-safety.md`, `code-dev-review.md`, `code-dev-journal.md`, `code-dev-knowledge.md`, `code-dev-flow.md`, `code-dev-shape.md`.
- **Acceptance**: (1) 10 umbrellas live; (2) stubs dispatch correctly; (3) old verbs alias-route; (4) rename-safety snapshot updated per-router.
- **Depends-on**: PR-12.

### PR-15 — Compaction recovery + sess.04 harness
- **Goals**: G.sess.04, partial G.sess.02 (doc).
- **Files**: modified `tools/session.py`; new `tests/fixtures/compaction/`, `workspace/AXON-DOCS-SESSIONS.md` (initial).
- **Acceptance**: synthetic compaction → recovery announces last action + pending verbs.

### PR-16 — Plan modes (tactical, strategic, operational, decision) + `--budget N`
- **Goals**: G.plan.01, G.plan.02 (full), T-S1.10.
- **Files**: modified `code-dev-plan.md`.
- **Acceptance**: (1) 4 modes produce distinct output structures; (2) default `tactical`; (3) `--budget N` caps PR count; overflow → `02-prs.deferred.md` (T-S1.10).

### PR-17 — `study/_index.md` + staleness flags + journal vocabulary
- **Goals**: G.study.02 (full), G.study.03, T-S0.4.
- **Files**: new `tools/study_index.py`; modified `code-dev-study.md`.
- **Acceptance**: (1) index lists every study with `last-run`, `age-days`, `staleness ∈ {fresh, warn, stale, strict-block}`; thresholds 30/60/90; UTC ISO 8601; (2) inline journal-vocabulary kinds documented (`study.overview`, `study.subsystem`, etc. — T-S0.4).

### PR-V2 — Version bump 0.8.0
- VERSION = 0.8.0; CHANGELOG sealed.

### Wave-2 entry gate to W3
- All W2 PRs merged (PR-8 through PR-17, plus PR-9.5, PR-9.6, PR-9.7).
- One full `code-dev plan --mode=tactical --rule "test"` round-trip producing governance trace with ad-hoc rule echoed.
- Synthetic compaction-recovery test green.
- Rename-safety harness live; 10 router stubs in production.
- `code-dev pr list`, `meta context use`, `preflight --mode=summary` all live.

---

## WAVE 3 — observability + perf + integration + docs (15 PRs)

### PR-18 — Dispatch corpus (seed 30)
- **Goals**: G.test.02 (seed).
- **Files**: new `tests/fixtures/dispatch-corpus.jsonl`, `tests/test_dispatch.py`.
- **Acceptance**: 30 entries covering top-10 verbs; runner produces P@1, P@3.

### PR-19 — Dispatch quality metric
- **Goals**: G.obs.06.
- **Files**: modified `tools/dispatch_stats.py`; new `my-axon/log/dispatch-metrics/<date>.json`.
- **Acceptance**: `code-dev meta dispatch-stats` prints P@1 ≥ 0.8 target, P@3 ≥ 0.95 target; recent failures listed.

### PR-20 — Per-program budget blocks
- **Goals**: G.tok.05.
- **Files**: modified every `workspace/programs/code-dev*.md` (frontmatter `budget:` block); new `tools/budget_lint.py`.
- **Acceptance**: every program has `budget: {input-cap, output-cap, cache-prefix}`; lint rejects missing/invalid; `compile-write.py` warns if compiled > `cache-prefix`.

### PR-21 — Token-ceiling + usage aggregator
- **Goals**: G.tok.08, G.obs.02.
- **Files**: modified `tools/usage.py`, `tools/migrate_meta.py` (default `token-ceiling: 32000`); new `workspace/programs/code-dev-meta-usage.md`.
- **Acceptance**: `code-dev meta usage [--by program | --by session | --by day]` prints aggregates.

### PR-22 — `rules audit`
- **Goals**: G.gov.03.
- **Files**: modified `tools/rules.py`.
- **Acceptance**: detects synthetic contradictions; flags dead rules (90 days no reference); human-readable report.

### PR-23 — AXON-DOCS for workflows/study/plan
- **Goals**: G.doc.01, G.doc.02, G.doc.03.
- **Files**: new `AXON-DOCS-WORKFLOWS.md`, `-STUDY.md`, `-PLAN.md`; cheatsheet updated.
- **Acceptance**: Diátaxis-aligned references; cross-linked from cheatsheet.

### PR-24 — AXON-DOCS-SCHEMA fill + AXON-DOCS-GOVERNANCE expand
- **Goals**: G.doc.04, G.doc.05.
- **Files**: modified `AXON-DOCS-SCHEMA.md`, `AXON-DOCS-GOVERNANCE.md`.
- **Acceptance**: every v4.1 field documented; precedence has 5+ worked examples.

### PR-25 — Idempotence harness
- **Goals**: G.test.04, R5 NS-2.
- **Files**: new `tools/idem_test.py`, `tests/test_idempotence.py`, `_trace/`.
- **Acceptance**: runs program twice; structural-overlap ≥ 80% target; emits `_trace/<prog>-idem.json`.

### PR-15.5 — Events-bus wiring (`_events.log` ↔ kernel)
- **Goals**: D-A1 (R2 score 5/2).
- **User-visible**: "code-dev events appear in the kernel event bus; other programs can subscribe".
- **Files**: modified `tools/events.py`; new `workspace/programs/code-dev-events-emit.md`.
- **Acceptance**: (1) every code-dev verb emits structured event `{program, project, action, ts}` to `_events.log`; (2) kernel `events.py` `ON(<topic>)` handlers can subscribe; (3) one example handler subscribes to `pr.ready` and logs notification; (4) `lint_paths.py` clean.
- **Depends-on**: PR-9.

### PR-15.6 — `igap` feedback from code-dev low-confidence
- **Goals**: D-A3.
- **User-visible**: "HALT/QUERY events feed `igap` for later review".
- **Files**: modified `tools/igap.py`; programs emit `igap` entries at HALT/QUERY points.
- **Acceptance**: (1) HALT-with-QUERY events write to `igap` log with context; (2) `code-dev meta igap` lists recent entries; (3) one synthetic test passes.
- **Depends-on**: PR-13, PR-15.5.

### PR-20.5 — Caches bundle (T-B1, T-B2, T-B3, T-B5)
- **Goals**: T-B1 session read cache, T-B2 resume briefing cache, T-B3 `reviewer-state.json`, T-B5 shadow LRU.
- **User-visible**: "hot reads cached; `resume` and `pr-review` visibly faster".
- **Files**: new `tools/cd_cache.py`, `tests/test_cache.py`; modified `code-dev-resume.md` and `code-dev-pr-review*` (post PR-20.8); new `_reviewer-state.json` per project.
- **Acceptance**: (1) session-scoped read cache (`W:code-dev-cache-*`) hits ≥ 50% on second resume in session; (2) resume briefing cache mtime-keyed; (3) `reviewer-state.json` sidecar persists across sessions; (4) shadow LRU bounded (max 32 entries); (5) cache invalidation on file mtime change verified by test; (6) `lint_paths.py` clean.
- **Depends-on**: PR-13.

### PR-20.6 — `meta board` ASCII Kanban
- **Goals**: G-I8.
- **User-visible**: "Kanban board view of PRs".
- **Files**: new `workspace/programs/code-dev-meta-board.md`; `tools/board.py`.
- **Acceptance**: (1) columns: backlog, in-progress, blocked, ready-for-review, done; (2) reads from PR-9.5 aggregator; (3) `--project <slug>` scope (default all); (4) ≤ 200 columns wide.
- **Depends-on**: PR-9.5.

### PR-20.7 — Study-evals workstream (NS-1)
- **Goals**: NS-1.
- **User-visible**: "study outputs are scored against fixtures".
- **Files**: new `tools/study_evals.py`, `tests/fixtures/study-evals/`.
- **Acceptance**: (1) ≥ 5 fixture codebases × 3 modes; (2) `study_evals.py` scores structural-match + key-fact coverage; (3) JSONL at `my-axon/log/study-evals/<date>.jsonl`.
- **Depends-on**: PR-13, PR-25.

### PR-20.8 — Split `code-dev-pr-review` into P1-P9 sub-programs (T-A2)
- **Goals**: T-A2 — structural fix for the RED program.
- **User-visible**: "`pr review` dispatches to focused P1-P9 sub-programs; smaller compiled output".
- **Files**: new `workspace/programs/code-dev-pr-review-p1.md` through `-p9.md`; modified `code-dev-pr-review.md` (router).
- **Acceptance**: (1) 9 sub-programs (P1=summary, P2=diff, P3=risk, P4=style, P5=tests, P6=docs, P7=security, P8=performance, P9=final); (2) router dispatches by `--phase=N` or `--all`; (3) each sub-program compiled GREEN per PR-2 gate; (4) aggregate ≤ 50% of pre-split bytes; (5) rename-safety snapshot updated.
- **Depends-on**: PR-2, PR-12.

### PR-25.5 — `state next` integration with `_index.md`
- **Goals**: T-S1.12, partial G.wf.07.
- **User-visible**: "`next` factors in stale studies and pending PRs".
- **Files**: modified `code-dev-next.md`; new `tests/test_next_integration.py`.
- **Acceptance**: (1) reads `study/_index.md` for stale areas; (2) suggests `study --mode=X` when staleness > 60d AND area relevant; (3) suggests resuming `pr-N` if state=in-progress; (4) preserves PR-9.6 fast-path when `_meta.next-action` set.
- **Depends-on**: PR-17, PR-9.6.

### PR-V3 — Version bump 0.9.0
- VERSION = 0.9.0; CHANGELOG sealed.

### Wave-3 entry gate to W4
- All W3 PRs merged (PR-18..PR-25 plus PR-15.5, 15.6, 20.5, 20.6, 20.7, 20.8, 25.5).
- Dispatch baseline recorded (P@1, P@3).
- Every program has budget block.
- Top docs (WORKFLOWS/STUDY/PLAN/SCHEMA/GOVERNANCE) live and cross-linked from cheatsheet.
- Events bus emitting; `igap` receiving low-confidence events.
- Caches measurably hit ≥ 50% on second resume in-session.
- `pr-review` split into P1-P9 all GREEN.

---

## WAVE 4 — renames + behavioral + PR-ergonomics + docs (13 PRs)

### PR-26 — Rename wave A (5 low-risk renames)
- **Goals**: partial G.umb.05.
- **Depends-on**: PR-12 (snapshot) + PR-14 (routers).
- **Acceptance**: T1 + rename-snapshot diff approves; alias-stubs print deprecation; no dispatch breakage.

### PR-27 — Rename wave B (10 medium-risk)
- Same pattern.

### PR-28 — Rename wave C (10-15 high-risk in core flow)
- Per-rename HUMAN sign-off.

### PR-29 — Behavioral T3 for 5 critical programs
- **Goals**: G.test.03.
- Targets: `code-dev-plan`, `-study`, `-pr-ready`, `-resume`, `-migrate`.
- **Files**: new `tests/fixtures/programs/...`; mock-model harness `tests/_mock_model.py`.
- **Acceptance**: at least 1 input/expected fixture per target; mock-mode pytest green.

### PR-30 — Per-mode budgets (full)
- **Goals**: G.study.05 + plan budgets.
- Each mode of study/plan declares input/output cap; budget_lint enforces.

### PR-31 — Context-switch ergonomics
- **Goals**: G.sess.05 (chats list/show/switch); partial G.wf.07.
- **Files**: new `workspace/programs/code-dev-chats.md`; modified `code-dev-next.md`.

### PR-32 — Golden study outputs
- **Goals**: G.test.08.
- **Files**: new `tests/fixtures/projects/tiny-py-cli/`, `tiny-ts-lib/`; expected sections per study mode.

### PR-33 — Docs completion wave 1
- **Goals**: G.doc.06, G.doc.07, G.doc.08, G.doc.09.
- **Files**: new `AXON-DOCS-SESSIONS.md`, `-COMPILER.md`, `-TESTING.md`, `-FAILURE-MODES.md`.

### PR-34 — Docgen verify
- **Goals**: G.doc.12.
- **Files**: modified `tools/docgen.py`.
- **Acceptance**: `docgen verify` lints cross-refs across all AXON-DOCS files.

### PR-28.5 — PR-ergonomics suite (sync, drift, export, suggest-reviewer, review-coverage)
- **Goals**: G-I3, G-I5, G-I9, G-I11, R4-wf #9 (CI awareness).
- **User-visible**: "5 new PR-flow commands: `pr sync`, `pr drift`, `pr export`, `pr suggest-reviewer`, `review --mode=coverage`".
- **Files**: new programs `code-dev-pr-sync.md`, `-pr-drift.md`, `-pr-export.md`, `-pr-suggest-reviewer.md`, `-review-coverage.md`; tools `tools/pr_sync.py`, `tools/pr_drift.py`, `tools/pr_export.py`.
- **Acceptance**: (1) `pr sync N` pulls CI checks (`gh pr checks` if available, else graceful skip); (2) `pr drift N` detects spec-vs-code drift via diff snapshot; (3) `pr export N` produces portable packet (markdown + diff + tests); (4) `pr suggest-reviewer N` uses `_actions.log` history; (5) `review --mode=coverage` integrates coverage delta if present; (6) each has its own test; (7) `lint_paths.py` clean.
- **Splittable**: PR-28.5a (sync+drift) / 28.5b (export+suggest-reviewer) / 28.5c (review-coverage) if review heavy.
- **Depends-on**: PR-14, PR-9.5.

### PR-31.5 — Recursive program loop detector + tour cross-ref lint
- **Goals**: G.safe.07, G.wf.02 (full).
- **User-visible**: "program-call graphs are cycle-checked; tour stays valid".
- **Files**: new `tools/call_graph.py`; modified `tests/test_programs_md.py`, `code-dev-tour.md`.
- **Acceptance**: (1) call_graph builds DAG of `EXEC(code-dev-*)`; (2) cycle → CI fail; (3) depth limit 10 enforced at runtime; (4) tour references current verbs only.
- **Depends-on**: PR-1.

### PR-32.5 — Nightly `shadow refresh` cron + scheduler hardening prereq
- **Goals**: T-F1, partial scheduler hardening.
- **User-visible**: "shadows refresh nightly for active projects".
- **Files**: modified `tools/cron.py`, `tools/shadow.py`; new `workspace/scheduler/shadow-refresh.cron.md`.
- **Acceptance**: (1) cron entry refreshes shadows for `status=active` projects; (2) opt-out via `_meta.shadow-cron: false`; (3) results to `my-axon/log/cron/<date>.jsonl`; (4) agent produces install snippet; HUMAN runs cron.
- **Depends-on**: PR-13, PR-20.5.

### PR-34.5 — Cheatsheet auto-section via docgen
- **Goals**: G.umb.06.
- **User-visible**: "cheatsheet verb list auto-updates from program `# desc:`".
- **Files**: modified `tools/docgen.py`, `workspace/AXON-DOCS-CHEATSHEET.md` (markers).
- **Acceptance**: (1) `docgen` emits VERBS section between `<!-- AUTO-VERBS-START -->` and `<!-- AUTO-VERBS-END -->`; (2) verbs sorted by usage-log frequency (top 10) or umbrella; (3) idempotent regeneration; (4) cheatsheet ≤ 80 lines.
- **Depends-on**: PR-23, PR-13.

### PR-V4 — Version bump 1.0.0
- VERSION = 1.0.0; CHANGELOG sealed.

### Wave-4 final gate (DONE)
- All P0 goals closed.
- All top-10 failure-mode mitigations live.
- Rename umbrella complete.
- Dispatch P@1 ≥ 0.8 measured.
- Schema v4.1 universal across `my-axon/dev-projects/*`.
- Sessions + compaction-recovery hardened.
- Top 10 docs live.
- **Every R2 top-15 item: closed or quarantined (T-A1 quarantine, T-A2 split into P1-P9, T-A3 gate, D-A1/2/3/4 done, T-B1/2/3/5 cached, T-C1/2 ergonomics, T-F1 cron).**
- **All 10 R3 umbrellas live; T1-T4+T6 waves done (T5 grace-period to post-1.0).**
- **R4 top-20 active: 16/16 closed (4 explicitly deferred — pr-stack, cookbook, tutorial, team).**
- **R5 T-S0 (1-4) + T-S1 (1-12): all closed.**
- **NS-1 + NS-2 baselines recorded.**
- **`workspace/programs/code-dev-roadmap.md` populated with named Post-1.0 queue.**

---

## POST-1.0 (queued, NAMED — kept in `workspace/programs/code-dev-roadmap.md`)
- D-E1 `code-dev pr-stack` (new / restack / push)
- D-E2 reviewer-bot loop
- D-B4 `code-dev pr-import` (library-dev bridge)
- G-CD-A4 `code-dev release` workflow
- D-C8 `code-dev coverage-delta`
- D-C6 `code-dev conflict-predict`
- G.tok.06 cache-hit-rate metric (depends on provider API)
- G.wf.05 first-30-minutes tutorial
- G.wf.06 workflow cookbook
- G.inf.06 v5 schema spec (stack-id, last-sync, spec-history)
- G.team.* multi-actor mode (G.team.01-04)
- T-S2..T-S6 deeper study targets
- NS-3..NS-14 future study workstreams
- R3 Wave T5 (drop alias stubs after grace period)
- CI deep integration beyond `pr sync N`
- Network sync of `my-axon/`
- Visual UI for AXON
- Plan-vs-plan diff (G.plan.07)
- Plan→PR materialization helper (G.plan.08)

## Execution semantics

### Per-PR loop
1. AGENT reads PR spec here.
2. AGENT writes code + tests + docs.
3. AGENT updates `02-prs.md` block: `pr-N: state=ready-for-review`.
4. AGENT updates `_actions.log` (one JSONL line).
5. HUMAN reviews; runs pytest; merges; pushes (with consent).
6. AGENT updates `_meta.md.pr-N: state=done` + appends CHANGELOG line.

### Resume semantics
On compaction:
1. Boot via `startup.md`.
2. Read `_session.md` + `_meta.md`.
3. Identify last `pr-N: state=in-progress`.
4. Read PR-N spec from this file.
5. Resume at next unchecked acceptance item.

### Replan trigger
HALT and create `cd-plan-i5-*` set if:
- MUST PR fails review unfixably.
- New failure mode appears not in catalog.
- Mid-plan rule addition changes scope.
- Token cost forecast exceeds session budget × 1.5.

## Risk register (final)
1. Migrator breaks live project → dry-run + backup + restore.
2. Gate too tight → `--override` + WARN-first.
3. Wave-1 ALL pre-req for W2 → MUST/NICE split (4 MUST only).
4. Recompile race → gate ships before any recompile.
5. Renames break dispatch → snapshot harness blocks.
6. Empty rules.md silent-bypass → warn-once + log.
7. Cheatsheet bitrot → docgen auto-section in W3.
8. Sessions overhead → opt-in initially.
9. Compaction loss mid-PR → per-PR checkpoint; resume picks up.
10. Strict-mode false-positives → `--strict-explain`.
11. Idempotence < 80% → measure first, ratchet.
12. Provider cache API silent → nulls accepted.
13. Path-helper drift → `lint_paths.py` row in every PR.
14. Plan v1 wrong post-execution → per-wave gate; replan path defined.

## Governance trace
```
loaded: workspace/safety/rules.md (0 rules, will be filled by user as needed)
        workspace/dont-do.md (absent)
        study/_index.md (pre-W2; not consulted)
        kernel rules, user-memory rules, AGENT contract (all in force)
mode: tactical
filtered options: 0
flagged options: 0
conflicts: 0
HALT triggers: 0
```

## Acceptance for this plan itself
- [x] All P0 goals scheduled within W1-W3.
- [x] All top-10 failure modes mitigated by W3.
- [x] DAG acyclic; verified topologically.
- [x] HUMAN/AGENT split explicit per PR.
- [x] Rollback per PR.
- [x] Wave gates defined.
- [x] Resume semantics defined.
- [x] Replan trigger defined.
- [x] Risk register present.
- [x] Out-of-scope explicit.
- [x] Discipline (changelog, version, lint_paths) baked in.

— end of plan v4 (FINAL) —
