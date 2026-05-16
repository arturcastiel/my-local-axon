# 03-plan.md — axon-master plan v4 (FINAL)

**Schema**: plan-v1 · **Status**: ready-for-execution · **Mode**: tactical
**Created**: 2026-05-16 · **Iterations**: 4 (study→audit→plan × 4)
**Source**: helpers/cd-plan-i1..i4-{s,a,p}-*.md
**Governance trace**: loaded `safety/rules.md` (0 rules) · `dont-do.md` (absent) · `_index.md` (pre-W2) · filtered 0 · flagged 0 · conflicts 0

## Plan envelope
- **Scope**: AXON OS hardening so code-dev is dependable as flagship workflow.
- **PR count**: 34 PRs across W1-W4 + version-bump PRs at each wave boundary.
- **DONE**: 0.9.x → 1.0.0 at end of W4.
- **Out of scope**: multi-actor, library-dev parallel, PR-stack, v5 schema, visual UI, network sync, CI deep integration (these are queued post-1.0).
- **Constraints**: kernel rules, user-memory safety rules, AGENT contract all in force. Empty `safety/rules.md` is allowed; plan proceeds.

## Owner convention
- **AGENT**: writes code, docs, tests, helpers.
- **HUMAN**: runs `pytest`, runs `compile.py`, runs `migrate_meta.py` (after dry-run review), runs `git push` (only on explicit consent), merges PRs.

---

## WAVE 1 — foundation (7 PRs)

### PR-1 — T1 structural tests + cross-ref lint
- **Goals**: G.test.01.
- **User-visible**: "every code-dev program is now structurally lint-checked".
- **Files**:
  - new: `tests/coverage.json`.
  - modified: `tests/test_programs_md.py`, `tests/conftest.py`.
- **Acceptance**: (1) every `workspace/programs/code-dev*.md` with `status != draft|deprecated` passes T1; (2) cross-ref lint — every `EXEC(code-dev-X)` references existing program; (3) `pytest tests/test_programs_md.py -v` (HUMAN) prints "passed N programs"; (4) `tests/coverage.json` enumerates per-program status.
- **Rollback**: `git revert`.
- **Owner**: AGENT writes; HUMAN runs pytest.
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
- **Acceptance**: (1) dry-run on v1 fixture reports plan, 0 writes; (2) real run produces v4.1 + `_meta.md.bak.<ts>`; (3) idempotent re-run = no-op; (4) `--restore` byte-exact; (5) `--all` iterates `my-axon/dev-projects/*` with confirmation; (6) retention keeps last 3; (7) unknown sections preserved as `## CUSTOM` (e.g. `STUDY DIRECTIVE`); (8) axon-master dry-run reviewed by HUMAN, then real run; (9) `code-dev resume` works post-migration; (10) PR-1 T1 passes after resume edit; (11) `tools/lint_paths.py` clean.
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
- **Goals**: G.safe.01, G.safe.02.
- **User-visible**: "canonical failure-mode catalog and postmortem template available".
- **Files**: new `workspace/log/failure-modes.md`, `workspace/templates/postmortem.md`.
- **Acceptance**: ≥ 25 modes across classes A-H; each with trigger/signal/mitigation/owner/last-reviewed; template renders one synthetic example.
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

## WAVE 2 — modes + sessions + governance (10 PRs)

### PR-8 — Study modes core
- **Goals**: G.study.01, partial G.study.07.
- **User-visible**: "code-dev study now supports `--mode=overview|subsystem|deep`".
- **Files**: new `workspace/programs/code-dev-study-area.md`; modified `code-dev-study.md`.
- **Acceptance**: 3 modes produce distinct sectioned outputs; default = `standard` (back-compat).

### PR-9 — `_session.md` + auto-checkpoint + atomic `_actions.log`
- **Goals**: G.sess.01, G.sess.03, G.inf.04 (continues).
- **User-visible**: "every chat now journals to `_session.md` with auto-checkpoints".
- **Files**: new `tools/session.py`, `tests/test_session.py`; modified handoff/freeze/tag/resume programs; `tools/_axon_io.py` (atomic for `_actions.log`).
- **Acceptance**: (1) `_session.md` created per chat on first verb; (2) state enum {active, frozen, tagged, closed, recovered}; (3) auto-checkpoint every 20 turns AND before `_meta.md` mutation; (4) atomic writes verified by concurrent-edit synthetic test.

### PR-10 — Governance `--strict` (full)
- **Goals**: G.gov.04, G.gov.05.
- **User-visible**: "`pr ready --strict` and `plan --strict` actively gate on rules, stale studies, failing tests, missing acceptance".
- **Files**: modified `tools/rules.py`, `code-dev-pr-ready.md`, `code-dev-plan.md`; extends `tests/test_governance.py`.
- **Acceptance**: strict blocks listed; `--strict-explain` enumerates each gate result.

### PR-11 — Plan reads rules (full) + governance trace populated
- **Goals**: G.plan.04, G.plan.05.
- **Files**: modified `code-dev-plan.md`.
- **Acceptance**: synthetic rule filters an option; trace shows filtered count; HALT if >80% filtered.

### PR-12 — Rename-safety harness
- **Goals**: G.umb.04, G.test.07.
- **User-visible**: "any program rename is gated by a snapshot diff".
- **Files**: new `tools/rename_snapshot.py`, `tests/test_rename_safety.py`, `tests/snapshots/programs-pre-rename.jsonl`.
- **Acceptance**: snapshot captures `{program, desc, sections, status}` for every program; diff fails on regression.

### PR-13 — Usage logging
- **Goals**: G.obs.01.
- **Files**: modified `tools/usage.py`; new `my-axon/log/usage/.keep`.
- **Acceptance**: JSONL `{ts, session, program, in_tokens, out_tokens, cache_creation, cache_read}` (nulls allowed); ≥ 1 turn logged.

### PR-14 — Router stubs (top umbrellas, no renames yet)
- **Goals**: partial G.umb.01.
- **Files**: new `workspace/programs/code-dev-meta.md`, `code-dev-pr.md` (umbrella; old → `-pr-create` stub), `code-dev-state.md`, `code-dev-lifecycle.md`, `code-dev-safety.md`.
- **Acceptance**: stubs dispatch correctly; old verbs alias-route; rename-safety snapshot updated.
- **Depends-on**: PR-12.

### PR-15 — Compaction recovery + sess.04 harness
- **Goals**: G.sess.04, partial G.sess.02 (doc).
- **Files**: modified `tools/session.py`; new `tests/fixtures/compaction/`, `workspace/AXON-DOCS-SESSIONS.md` (initial).
- **Acceptance**: synthetic compaction → recovery announces last action + pending verbs.

### PR-16 — Plan modes (tactical, strategic, operational, decision)
- **Goals**: G.plan.01, G.plan.02 (full).
- **Files**: modified `code-dev-plan.md`.
- **Acceptance**: 4 modes produce distinct output structures; default `tactical`.

### PR-17 — `study/_index.md` + staleness flags
- **Goals**: G.study.02 (full), G.study.03.
- **Files**: new `tools/study_index.py`; modified `code-dev-study.md`.
- **Acceptance**: index lists every study with `last-run`, `age-days`, `staleness ∈ {fresh, warn, stale, strict-block}`; thresholds 30/60/90; UTC ISO 8601.

### PR-V2 — Version bump 0.8.0
- VERSION = 0.8.0; CHANGELOG sealed.

### Wave-2 entry gate to W3
- All W2 PRs merged.
- One full `code-dev plan --mode=tactical` round-trip producing governance trace.
- Synthetic compaction-recovery test green.
- Rename-safety harness live; ≥ 1 router stub in production.

---

## WAVE 3 — observability + budgets + docs (8 PRs)

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

### PR-V3 — Version bump 0.9.0
- VERSION = 0.9.0; CHANGELOG sealed.

### Wave-3 entry gate to W4
- All W3 PRs merged.
- Dispatch baseline recorded (P@1, P@3).
- Every program has budget block.
- Top docs (WORKFLOWS/STUDY/PLAN/SCHEMA/GOVERNANCE) live and cross-linked from cheatsheet.

---

## WAVE 4 — renames + behavioral + docs completion (9 PRs)

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

---

## POST-1.0 (queued, NOT in this plan)
v5 schema spec · stacks · last-sync · spec-history · CI integration (`pr sync` + checks) · cron/scheduler · plan-vs-plan diff · plan→PR materialization · first-30-minutes tutorial · cookbook · multi-actor / team mode · library-dev parallel · network sync.

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
