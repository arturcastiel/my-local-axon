# CD·PLAN·I2·P — plan v2

> v1 + all I2 study/audit fixes. Wave-1 fully detailed; W2 detailed; W3-W4 sketched.

## Wave-1 (final order)

### PR-1 — T1 structural tests + cross-ref lint
- Goals: G.test.01, partial G.test.09 (boot smoke if cheap).
- Files touched:
  - `tests/test_programs_md.py` (extend)
  - `tests/coverage.json` (new)
  - `tests/conftest.py` (small fixture helpers)
- Acceptance:
  - Every `workspace/programs/code-dev*.md` with `status != draft` passes T1.
  - Cross-ref check: every `EXEC(code-dev-X)` references an existing program.
  - `lint_paths.py` passes on any new tool code (NA here).
  - HUMAN runs: `pytest tests/test_programs_md.py -v` green.
- Risk / mitigation:
  - Drafts incorrectly flagged → frontmatter `status: draft` opt-out.
- Status check: HUMAN runs tests; agent does not.
- Owner: agent writes; HUMAN verifies.

### PR-2 — Token audit + compile regression gate + static-prefix lint
- Goals: G.tok.01, G.tok.02, G.tok.03, G.tok.04.
- Files touched:
  - `tools/audit_compiled.py` (new)
  - `tools/compile-write.py` (gate)
  - `tools/tokenizer.py` (verify anthropic; fallback char/4)
  - `workspace/programs/compiled/_quarantine.md` (new)
  - `study/compiled-audit.md` (output of audit)
  - `tests/test_compiled_regression.py` (extend with audit assertions)
  - `tools/REGISTRY.json` (register audit_compiled)
- Acceptance:
  - Numbers table: src bytes/tokens, cmp bytes/tokens, ratio, classification (GREEN/YELLOW/RED/GREY) for every compiled program.
  - Gate active: 0.95 byte AND 0.95 token thresholds; `--override "<reason>"` flag.
  - Floor: source < 512 bytes skips ratio check.
  - Static-prefix lint: first 2 KB of compiled file byte-stable across two compiles.
  - ≥1 RED quarantined (pr-review confirmed RED).
  - All paths via `_axon_paths.py`.
- Risk / mitigation:
  - Threshold too tight → `--override` with logged reason.
  - Re-compile race vs gate → ship gate before any compiled-program edit (this PR is first).
- Owner: agent writes; HUMAN runs benchmark + reviews quarantine list.

### PR-3 — Schema migrator v1 → v4.1 + atomic `_meta.md` writes
- Goals: G.inf.01, G.inf.02, G.inf.03, G.study.04, partial G.inf.04.
- Files touched:
  - `workspace/AXON-DOCS-SCHEMA.md` (new)
  - `tools/migrate_meta.py` (new)
  - `tools/_axon_io.py` (atomic-write helper if absent)
  - `workspace/programs/code-dev-resume.md` (integrate)
  - `workspace/programs/code-dev-migrate.md` (new wrapper)
  - `tests/test_migrator.py` (new)
  - `tools/REGISTRY.json`
  - `my-axon/.gitignore` (ignore `*.bak.*`)
- Acceptance:
  - v1 fixture → v4.1 fields present (phase, last-program, pr blocks stub, `study/_index.md` skeleton).
  - Idempotent (run twice = no-op).
  - `--dry-run` produces report, zero writes.
  - `--restore` byte-exact rollback.
  - `--all` iterates `my-axon/dev-projects/*`.
  - Backup retention: keep last 3.
  - axon-master migrated cleanly in dry-run before real run.
  - `code-dev resume` works post-migration.
  - PR-1 T1 tests pass after resume edit.
- Risk / mitigation:
  - Malformed v1 file → HALT + QUERY (tolerant parser).
  - Race with HUMAN edit → mtime check.
- Owner: agent writes; HUMAN approves before non-dry-run on real projects.

### PR-4 — `safety/rules.md` schema + governance precedence doc + plan-reads-rules stub
- Goals: G.gov.01, G.gov.02, partial G.plan.04, G.gov.04 (stub).
- Files touched:
  - `workspace/safety/rules.md` (new; empty + schema header)
  - `workspace/AXON-DOCS-GOVERNANCE.md` (new)
  - `tools/rules.py` (new; parse + list)
  - `workspace/programs/code-dev-plan.md` (or compiled — read rules; emit governance-trace)
  - `workspace/programs/code-dev-pr-ready.md` (stub `--strict`)
  - `tools/REGISTRY.json`
- Acceptance:
  - Empty rules.md parses (yields zero rules).
  - Plan emits "Governance trace" section (empty in W1).
  - `pr ready --strict` prints "strict mode requires W2 PR-10; falling back to non-strict" and exits 1.
  - Precedence doc lists 8 levels (kernel → user-memory → rules.md → strict → studies → staleness → dont-do → heuristic).
- Risk / mitigation:
  - Strict-mode silent failure → explicit message + exit 1.
- Owner: agent writes; HUMAN reviews precedence doc.

### --- MUST-set boundary ---
PR-1 through PR-4 = MUST. Wave-2 can start with these only.

### PR-5 — Secret redaction + pre-push secret scan
- Goals: G.safe.03, G.safe.08.
- Files touched:
  - `tools/redact.py` (new)
  - `tools/scan_pre_push.py` (new)
  - `workspace/safety/redact-allowlist.md` (new)
  - `tools/log.py` (apply redact at write)
  - `tools/REGISTRY.json`
- Acceptance:
  - Synthetic secrets test passes: a JSONL with `sk-abc...`, `AKIA...`, `eyJ...` redacted.
  - Allowlist exempts `workspace/templates/**` and `tests/fixtures/**`.
  - Pre-push scan flags secrets in staged diff; exit 1 if found.
- Owner: agent writes; HUMAN runs scan before each push.

### PR-6 — One-page cheatsheet
- Goals: G.doc.10.
- Files touched: `workspace/AXON-DOCS-CHEATSHEET.md` (new).
- Acceptance: HUMAN reads + signs off. Links only to existing docs.

### PR-7 — Failure-mode catalog (canonical)
- Goals: G.safe.01, G.safe.02.
- Files touched:
  - `workspace/log/failure-modes.md` (new — adapted from R6 U-4 helper)
  - `workspace/templates/postmortem.md` (new)
- Acceptance: catalog committed; classes A-H present; template renders one synthetic postmortem.

## Wave-1 gate to enter Wave-2 (revised)
1. **MUST**: PR-1, PR-2, PR-3, PR-4 merged.
2. axon-master schema = v4.1.
3. Compile gate active.
4. T1 tests green.
5. Governance schema + precedence doc present (even if rules empty).
6. NICE PRs (5/6/7) may follow async; do NOT block Wave-2.

## Wave-2 (detailed)

### PR-8 — Study modes core (overview, subsystem, deep)
- Goals: G.study.01, G.study.07 (subset), G.study.02 (skeleton).
- Files: `workspace/programs/code-dev-study.md` (modes dispatch); `workspace/programs/code-dev-study-area.md` (new).
- Acceptance: `code-dev study --mode=overview|subsystem|deep` produces sectioned output.

### PR-9 — `_session.md` + auto-checkpoint
- Goals: G.sess.01, G.sess.03.
- Files: `tools/session.py` (new); `workspace/programs/code-dev-handoff.md` etc. updated to write `_session.md`.
- Acceptance: every chat creates `my-axon/chats/<id>/_session.md`; checkpoint at 20-turn cadence.

### PR-10 — Governance --strict full
- Goals: G.gov.04, G.gov.05.
- Files: `tools/rules.py` (extend); `code-dev-pr-ready.md`.
- Acceptance: --strict gates rules, stale-studies, failing tests, missing acceptance.

### PR-11 — Plan reads rules (full) + governance trace
- Goals: G.plan.04, G.plan.05.
- Files: `code-dev-plan.md` (full integration).
- Acceptance: synthetic rule "no new deps" filters an option in test fixture.

### PR-12 — Rename-safety harness
- Goals: G.umb.04, G.test.07.
- Files: `tools/rename_snapshot.py`; `tests/test_rename_safety.py`; snapshot at `tests/snapshots/programs-pre-rename.jsonl`.
- Acceptance: snapshot captures `{program, desc, sections}` for every program; diff fails on regression.

### PR-13 — Usage logging
- Goals: G.obs.01.
- Files: `tools/usage.py` (extend); per-turn JSONL at `my-axon/log/usage/<date>.jsonl`.
- Acceptance: ≥1 turn logged with cache_creation + cache_read fields (or null if API silent).

### PR-14 — Router stubs (top umbrellas)
- Goals: G.umb.01 (partial — stubs only, no renames).
- Files: new `workspace/programs/code-dev-meta.md`, `code-dev-pr.md` (umbrella), `code-dev-state.md`, etc.
- Acceptance: stubs route to existing programs; deprecation message printed if old verb invoked.
- Depends on: PR-12 (rename-safety snapshot must be in place).

### PR-15 — Compaction recovery + sess.04 harness
- Goals: G.sess.04, G.sess.02 (doc).
- Files: `tools/session.py` (extend); test fixture for synthetic compaction.
- Acceptance: synthetic compaction → recovery reads latest checkpoint + announces resume.

### PR-16 — Plan modes (tactical, strategic, operational)
- Goals: G.plan.01, G.plan.02 (full).
- Files: `code-dev-plan.md` (mode dispatch).
- Acceptance: three modes produce distinct output structure.

### PR-17 — study/_index.md ecosystem + staleness
- Goals: G.study.02 (full), G.study.03.
- Files: `tools/study_index.py`; `code-dev-study.md` writes index.
- Acceptance: study run emits/updates `_index.md` with timestamps; 30/60/90 thresholds enforced.

## Wave-2 gate to enter Wave-3
- All W2 PRs merged.
- One full `code-dev plan --mode=tactical` round-trip with governance trace.
- One full compaction-recovery test passes.

## Wave-3 sketch

PR-18 dispatch corpus (TW2, seed 30) · PR-19 dispatch quality metric (G.obs.06) · PR-20 per-program budget blocks (G.tok.05) · PR-21 token-ceiling field + `usage` aggregator (G.tok.08, G.obs.02) · PR-22 governance audit (`rules audit`) (G.gov.03) · PR-23 AXON-DOCS-WORKFLOWS, AXON-DOCS-STUDY, AXON-DOCS-PLAN (G.doc.01-03) · PR-24 AXON-DOCS-SCHEMA, AXON-DOCS-GOVERNANCE (G.doc.04-05) · PR-25 idempotence harness (G.test.04, R5 NS-2).

## Wave-4+ sketch

File renames (R3 W4) bundled by area · behavioral tests T3 for 5 critical programs · study golden outputs T4 · per-mode budgets full · CI integration `pr sync` · AXON-DOCS-SESSIONS / -COMPILER / -TESTING / -FAILURE-MODES · cheatsheet auto-section · context-switch ergonomics · cron/scheduler hardening · backup hardening expanded.

## Plan-level governance trace
```
loaded: safety/rules.md (0 rules)
       dont-do.md (not present)
       _index.md studies (0 — pre-W2)
filtered options: 0
flagged options: 0
conflicts: 0
mode: tactical
wave: 1 (detailed) + 2 (detailed) + 3/4 (sketch)
```

## Open question for I3
- Should W1 PR-3 (migrator) ALSO write a `study/_index.md` skeleton, or is that PR-17 (W2)?
- Should W1 PR-2 (gate) also produce a baseline `benchmark/baseline.json` that future runs compare to?
- Cross-PR test orchestration: do tests live in one folder or per-area?

→ iteration 3 study: `cd-plan-i3-s-risk.md`.
