# CD·PLAN·I3·P — plan v3

> v2 + I3 study/audit refinements. Each W1 PR now has full file list, acceptance rows, rollback, owner, parallelism flag.

## Conventions
- **Goals**: which G.* IDs each PR closes (or progresses).
- **Files (touched)**: explicit paths (new vs modified).
- **Acceptance**: numbered list of verifiable checks.
- **Rollback**: how to undo.
- **Owner**: AGENT writes; HUMAN runs/approves unless otherwise noted.
- **Parallelism**: which other PRs may run concurrently.

## Wave-1

### PR-1 — T1 structural tests + cross-ref lint
- **Goals**: G.test.01.
- **Files (new)**: `tests/coverage.json`.
- **Files (modified)**: `tests/test_programs_md.py`, `tests/conftest.py`.
- **Acceptance**:
  1. Every `workspace/programs/code-dev*.md` with `status != draft|deprecated` passes T1.
  2. Cross-ref lint: every `EXEC(code-dev-X)` token references an existing program file.
  3. Test runner: `pytest tests/test_programs_md.py -v` (HUMAN run) prints "passed N programs".
  4. `tests/coverage.json` enumerates per-program checks + status.
  5. `tools/lint_paths.py` clean (NA: no new tool code).
- **Rollback**: `git revert <pr-1-commit>`; programs untouched.
- **Owner**: AGENT writes; HUMAN runs pytest.
- **Parallelism**: blocking PR-3, PR-12.

### PR-2 — Compile audit + regression gate + static-prefix lint
- **Goals**: G.tok.01, G.tok.02, G.tok.03, G.tok.04.
- **Files (new)**: `tools/audit_compiled.py`, `workspace/programs/compiled/_quarantine.md`, `study/compiled-audit.md` (in axon-master).
- **Files (modified)**: `tools/compile-write.py`, `tools/tokenizer.py` (verify pin), `tools/REGISTRY.json`, `tests/test_compiled_regression.py`, `workspace/preferences/compile.toml` (new entry `gate-mode`).
- **Acceptance**:
  1. `python3 tools/audit_compiled.py` produces full numbers table (≥ 10 programs).
  2. Each program classified GREEN/YELLOW/RED/GREY.
  3. ≥ 1 RED quarantined (pr-review confirmed at -1%).
  4. Gate runs at 0.95 bytes AND 0.95 tokens; floor: src < 512 B skips check.
  5. `--override "<reason>"` flag works; reason logged to `_actions.log`.
  6. Static-prefix lint: first 2 KB of compiled byte-stable across two compiles.
  7. WARN→BLOCK flip: gate starts in WARN; flips to BLOCK after first full audit pass passes (recorded in `workspace/preferences/compile.toml`).
  8. Tokenizer pinned to anthropic; fallback char/4 when unavailable.
  9. `tools/lint_paths.py` clean.
- **Rollback**: revert `compile-write.py` changes; gate disabled.
- **Owner**: AGENT writes; HUMAN runs audit + reviews quarantine.
- **Parallelism**: blocks PR-3 and any recompile.

### PR-3 — Schema migrator v1 → v4.1 + atomic `_meta.md`
- **Goals**: G.inf.01, G.inf.02, G.inf.03, G.study.04 (folded), partial G.inf.04.
- **Files (new)**: `tools/migrate_meta.py`, `workspace/AXON-DOCS-SCHEMA.md`, `workspace/programs/code-dev-migrate.md`, `tests/test_migrator.py`, `tests/fixtures/projects/v1-minimal/`, `tests/fixtures/projects/v1-with-custom/`.
- **Files (modified)**: `tools/_axon_io.py` (atomic_write helper), `workspace/programs/code-dev-resume.md` (auto-migrate offer), `tools/REGISTRY.json`, `my-axon/.gitignore` (add `*.bak.*`).
- **Acceptance**:
  1. `migrate_meta.py --dry-run` on v1 fixture reports planned changes; zero writes.
  2. `migrate_meta.py` on v1 fixture: produces v4.1 file + `_meta.md.bak.<ts>` backup.
  3. Re-run = no-op (idempotent).
  4. `--restore` byte-exact returns original.
  5. `--all` iterates `my-axon/dev-projects/*` with confirmation prompt.
  6. Backup retention: keeps last 3 (`backup-retention` field in `_meta.md`).
  7. Unknown sections preserved in `## CUSTOM` appendix (e.g. axon-master's `STUDY DIRECTIVE`).
  8. axon-master migration: dry-run reviewed by HUMAN, then real run passes.
  9. `code-dev resume` works post-migration on axon-master.
  10. PR-1 T1 tests pass after resume edit.
  11. `tools/lint_paths.py` clean.
- **Rollback**: per-project `migrate_meta.py --restore`; backups retained 3 deep.
- **Owner**: AGENT writes; HUMAN runs dry-run first, approves, then real run.
- **Parallelism**: independent of PR-4.

### PR-4 — Governance schema + precedence doc + plan-reads-rules stub
- **Goals**: G.gov.01, G.gov.02, partial G.plan.04, stubbed G.gov.04.
- **Files (new)**: `workspace/safety/rules.md`, `workspace/AXON-DOCS-GOVERNANCE.md`, `tools/rules.py`, `tests/test_governance.py`.
- **Files (modified)**: `workspace/programs/code-dev-plan.md` (emit governance trace), `workspace/programs/code-dev-pr-ready.md` (--strict stub), `tools/REGISTRY.json`.
- **Acceptance**:
  1. `rules.md` empty file parses (returns []) without error.
  2. `tools/rules.py` exposes `PRECEDENCE` constant; `AXON-DOCS-GOVERNANCE.md` generated from it (single source of truth).
  3. `code-dev plan` emits "## Governance trace" section (empty in W1).
  4. `code-dev pr ready --strict` prints: "strict mode requires PR-10; falling back" + exit 1.
  5. Precedence list (8 levels) committed.
  6. `tools/lint_paths.py` clean.
- **Rollback**: revert files; programs degrade gracefully.
- **Owner**: AGENT writes; HUMAN reviews precedence doc.
- **Parallelism**: independent of PR-3.

### --- MUST-set boundary ---

### PR-5 — Secret redaction + pre-push scan
- **Goals**: G.safe.03, G.safe.08.
- **Files (new)**: `tools/redact.py`, `tools/scan_pre_push.py`, `workspace/safety/redact-allowlist.md`, `tests/test_redact.py`.
- **Files (modified)**: `tools/log.py` (apply redact at write), `tools/REGISTRY.json`.
- **Acceptance**:
  1. Synthetic test: JSONL with `sk-abc...`, `AKIA...`, `eyJ...{20+chars}`, `*_TOKEN=...`, `*_KEY=...` all redacted.
  2. Allowlist exempts `workspace/templates/**`, `tests/fixtures/**`.
  3. Sidecar `<file>.redactions.log` (in `my-axon/memory/local/`) records originals.
  4. `scan_pre_push.py` flags secrets in `git diff --cached`; exit 1 on match.
  5. `tools/lint_paths.py` clean.
- **Rollback**: revert log.py changes; logs uncensored.
- **Owner**: AGENT writes; HUMAN runs pre-push scan.
- **Parallelism**: independent.

### PR-6 — One-page cheatsheet
- **Goals**: G.doc.10.
- **Files (new)**: `workspace/AXON-DOCS-CHEATSHEET.md`.
- **Acceptance**:
  1. Cheatsheet ≤ 80 lines.
  2. Lists 10 most-used verbs, 5 canonical flows, 3 escape hatches.
  3. Links only to existing W1-current docs.
  4. HUMAN reviews and approves.
- **Rollback**: delete file.
- **Owner**: AGENT writes; HUMAN reviews.
- **Parallelism**: independent.

### PR-7 — Failure-mode catalog (canonical) + postmortem template
- **Goals**: G.safe.01, G.safe.02.
- **Files (new)**: `workspace/log/failure-modes.md`, `workspace/templates/postmortem.md`.
- **Acceptance**:
  1. Catalog classes A-H present; ≥ 25 modes.
  2. Each mode has trigger/signal/mitigation/owner/last-reviewed.
  3. Postmortem template renders one synthetic example.
- **Rollback**: delete files.
- **Owner**: AGENT writes; HUMAN reviews catalog.
- **Parallelism**: independent.

## Wave-1 entry gate to Wave-2

**Hard gate** (Wave-2 cannot start until):
- PR-1 merged + tests passing.
- PR-2 merged + gate active (in BLOCK mode after first audit pass).
- PR-3 merged + axon-master migrated to v4.1.
- PR-4 merged + governance trace appears in `code-dev plan` output.

**Soft gate** (W2 can start; W1 NICE finishes in parallel):
- PR-5 / PR-6 / PR-7 may complete during W2.

## Wave-2 PRs (detailed)

### PR-8 — Study modes core
- **Goals**: G.study.01, partial G.study.07.
- **Files (new)**: `workspace/programs/code-dev-study-area.md`.
- **Files (modified)**: `workspace/programs/code-dev-study.md` (mode dispatch).
- **Acceptance**: `--mode=overview|subsystem|deep` distinct outputs; default = `standard` (back-compat).
- **Parallelism**: ⊥ PR-9, PR-12, PR-13.

### PR-9 — `_session.md` + auto-checkpoint
- **Goals**: G.sess.01, G.sess.03, G.inf.04 (continues).
- **Files (new)**: `tools/session.py`, `tests/test_session.py`.
- **Files (modified)**: `workspace/programs/code-dev-handoff.md`, `-freeze.md`, `-tag.md`, `-resume.md`; `tools/_axon_io.py` (atomic for `_actions.log`).
- **Acceptance**:
  1. Every chat creates `my-axon/chats/<id>/_session.md` on first verb.
  2. State enum: `{active, frozen, tagged, closed, recovered}`.
  3. Auto-checkpoint every 20 turns AND before any `_meta.md` mutation.
  4. Atomic writes verified by concurrent-edit synthetic test.
- **Parallelism**: ⊥ PR-8, PR-12, PR-13.

### PR-10 — Governance --strict (full)
- **Goals**: G.gov.04, G.gov.05.
- **Files (modified)**: `tools/rules.py` (extend), `code-dev-pr-ready.md`, `code-dev-plan.md`.
- **Files (new)**: `tests/test_governance.py` (extend with strict cases).
- **Acceptance**: --strict gates rules + stale>60d + failing tests + missing acceptance; `--strict-explain` enumerates each gate.

### PR-11 — Plan reads rules (full) + governance trace populated
- **Goals**: G.plan.04, G.plan.05.
- **Files (modified)**: `code-dev-plan.md`.
- **Acceptance**: synthetic rule "no new top-level deps" filters one option; trace section shows filtered count; HALT if >80% filtered.

### PR-12 — Rename-safety harness
- **Goals**: G.umb.04, G.test.07.
- **Files (new)**: `tools/rename_snapshot.py`, `tests/test_rename_safety.py`, `tests/snapshots/programs-pre-rename.jsonl`.
- **Acceptance**: snapshot captures `{program, desc, sections, status}` for every program; diff fails on uncoordinated changes.
- **Parallelism**: ⊥ PR-8, PR-9.

### PR-13 — Usage logging
- **Goals**: G.obs.01.
- **Files (modified)**: `tools/usage.py`.
- **Files (new)**: `my-axon/log/usage/.keep`.
- **Acceptance**: JSONL with `ts, session, program, in_tokens, out_tokens, cache_creation, cache_read` (nulls allowed); 1 logged turn observable.
- **Parallelism**: ⊥ PR-8, PR-9, PR-12.

### PR-14 — Router stubs (top umbrellas, no renames yet)
- **Goals**: partial G.umb.01.
- **Files (new)**: `workspace/programs/code-dev-meta.md`, `code-dev-pr.md` (umbrella; current `code-dev-pr` renamed to `code-dev-pr-create` via stub), `code-dev-state.md`, `code-dev-lifecycle.md`, `code-dev-safety.md`.
- **Acceptance**: stubs dispatch correctly; rename-safety snapshot updated; old verbs still work via alias.
- **Depends-on**: PR-12.

### PR-15 — Compaction recovery + sess.04 harness
- **Goals**: G.sess.04, partial G.sess.02 (doc).
- **Files (modified)**: `tools/session.py`.
- **Files (new)**: `tests/fixtures/compaction/`, `workspace/AXON-DOCS-SESSIONS.md` (initial).
- **Acceptance**: synthetic compaction → recovery announces last action and pending verbs.

### PR-16 — Plan modes (tactical, strategic, operational, decision)
- **Goals**: G.plan.01, G.plan.02 (full).
- **Files (modified)**: `code-dev-plan.md`.
- **Acceptance**: 4 modes produce distinct output structures; mode dispatch defaults to `tactical` if unspecified.

### PR-17 — study/_index.md + staleness flags
- **Goals**: G.study.02 (full), G.study.03.
- **Files (new)**: `tools/study_index.py`.
- **Files (modified)**: `code-dev-study.md` (writes index).
- **Acceptance**: index lists every study with `last-run`, `age-days`, `staleness=fresh|warn|stale|strict-block`; thresholds 30/60/90; UTC ISO 8601.

## Wave-2 entry gate to Wave-3
- All W2 PRs merged.
- One end-to-end `code-dev plan --mode=tactical` round-trip with rules + governance trace + reads `_index.md`.
- Synthetic compaction-recovery test green.
- Rename-safety harness green; ≥ 1 router stub live.

## Wave-3 (sketch, will fully detail at I4)

PR-18 dispatch corpus (TW2, 30 prompts) · PR-19 dispatch quality metric · PR-20 per-program budget blocks · PR-21 token-ceiling + usage aggregator · PR-22 `rules audit` · PR-23 AXON-DOCS-WORKFLOWS/STUDY/PLAN · PR-24 AXON-DOCS-SCHEMA/GOVERNANCE · PR-25 idempotence harness.

## Wave-4+ (sketch)

W4: file renames in waves (PR-26..30) · behavioral tests T3 (PR-31..33) · golden study outputs · per-mode budgets full · context-switch ergonomics.

W5+: CI integration · cron/scheduler · sched events · multi-project ergonomics · doc completion · team mode (deferred to v5).

## Open for I4 (final iteration)
1. Acceptance criteria for W3+ need same detail as W1.
2. Should there be a "version bump" PR at end of W1 (VERSION file)?
3. Should each PR have a 1-sentence "user-visible change" summary for changelog?

→ iteration 4 study: `cd-plan-i4-s-acceptance.md`.
