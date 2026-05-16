# CD·PLAN·I4·S — acceptance / completeness study (iteration 4)

> Last iteration. Lens: detail W3 with the same rigor as W1/W2; add changelog + version-bump discipline; finalize per-PR signatures.

## W3 PRs — full detail

### PR-18 — Dispatch corpus (seed)
- **Goals**: G.test.02 (seed 30).
- **Files (new)**:
  - `tests/fixtures/dispatch-corpus.jsonl` (30 prompt→verb pairs).
  - `tests/test_dispatch.py` (corpus runner).
- **Acceptance**:
  1. 30 entries, hand-curated; cover top-10 most-used verbs.
  2. Each entry: `{prompt, expected_verb, expected_top3, notes}`.
  3. Runner produces P@1 and P@3.
  4. Failing entries logged with predicted verb.

### PR-19 — Dispatch quality metric
- **Goals**: G.obs.06.
- **Files (modified)**: `tools/dispatch_stats.py`.
- **Files (new)**: `my-axon/log/dispatch-metrics/<date>.json`.
- **Acceptance**: command `code-dev meta dispatch-stats` prints P@1, P@3, recent failures. Threshold target P@1≥0.8, P@3≥0.95.

### PR-20 — Per-program budget blocks
- **Goals**: G.tok.05.
- **Files (modified)**: every `workspace/programs/code-dev*.md` (frontmatter `budget:` block).
- **Files (new)**: `tools/budget_lint.py`.
- **Acceptance**:
  1. Every program has `budget: {input-cap, output-cap, cache-prefix}` in frontmatter.
  2. Lint rejects missing/invalid budget.
  3. `compile-write.py` reads budget and warns if compiled exceeds `cache-prefix`.

### PR-21 — Token-ceiling + usage aggregator
- **Goals**: G.tok.08, G.obs.02.
- **Files (modified)**: `tools/usage.py`, `tools/migrate_meta.py` (add `token-ceiling: 32000` default).
- **Files (new)**: `workspace/programs/code-dev-meta-usage.md`.
- **Acceptance**: `code-dev meta usage [--by program | --by session | --by day]` prints aggregates from JSONL.

### PR-22 — `rules audit`
- **Goals**: G.gov.03.
- **Files (modified)**: `tools/rules.py` (add `audit`).
- **Acceptance**:
  1. Detects synthetic contradictions in fixture (rule-A "no deps" + rule-B "must use lib X" → flag).
  2. Detects dead rules (no PR/plan in 90 days referenced).
  3. Output: human-readable report.

### PR-23 — AXON-DOCS for workflows/study/plan
- **Goals**: G.doc.01, G.doc.02, G.doc.03.
- **Files (new)**: `workspace/AXON-DOCS-WORKFLOWS.md`, `-STUDY.md`, `-PLAN.md`.
- **Acceptance**: each Diátaxis-aligned reference doc; cheatsheet updated to link them.

### PR-24 — AXON-DOCS-SCHEMA fill + AXON-DOCS-GOVERNANCE expand
- **Goals**: G.doc.04, G.doc.05.
- **Files (modified)**: `AXON-DOCS-SCHEMA.md` (full v4.1 fields), `AXON-DOCS-GOVERNANCE.md` (worked examples).
- **Acceptance**: every field of `_meta.md` v4.1 documented; precedence has 5+ worked examples.

### PR-25 — Idempotence harness
- **Goals**: G.test.04, R5 NS-2.
- **Files (new)**: `tools/idem_test.py`, `tests/test_idempotence.py`, `_trace/` per-program.
- **Acceptance**: runs target program twice; computes structural-overlap; emits `_trace/<prog>-idem.json`; target ≥ 80% structural identical.

## W3 entry gate to W4
- All W3 PRs merged.
- Dispatch P@1 measured; baseline recorded.
- Every program has budget block.
- Top docs (WORKFLOWS/STUDY/PLAN/SCHEMA/GOVERNANCE) live.

## W4 (now detailed enough for plan)

### PR-26 — Rename wave A (low-risk verbs)
- **Goals**: partial G.umb.05 (5 renames).
- Renames the 5 lowest-risk verbs (per R3 W4) under their umbrellas; alias-stubs created.
- Pre: PR-12 snapshot + PR-14 routers.
- Acceptance: T1 + T7 snapshot diff approves; no dispatch breakage.

### PR-27 — Rename wave B (medium-risk)
- 10 more renames; same pattern.

### PR-28 — Rename wave C (high-risk verbs in core flow)
- Final 10-15 renames; explicit HUMAN sign-off per rename.

### PR-29 — Behavioral tests T3 for 5 critical programs
- **Goals**: G.test.03.
- Targets: `code-dev-plan`, `code-dev-study`, `code-dev-pr-ready`, `code-dev-resume`, `code-dev-migrate`.
- Fixtures + mock-model harness.

### PR-30 — Per-mode budgets (full)
- **Goals**: G.study.05, G.plan budgets.
- Each mode of study/plan declares input/output cap; budget_lint enforces.

### PR-31 — Context switch ergonomics
- **Goals**: G.sess.05 (chats list/show/switch), partial G.wf.07 (`code-dev next` weight).

### PR-32 — Golden study outputs
- **Goals**: G.test.08.
- Sample codebase fixtures + expected sections.

### PR-33 — Docs completion wave 1
- **Goals**: G.doc.06, G.doc.07, G.doc.08, G.doc.09.
- AXON-DOCS-SESSIONS, -COMPILER, -TESTING, -FAILURE-MODES.

### PR-34 — Docgen verify
- **Goals**: G.doc.12.
- `docgen verify` lints cross-refs.

## W5 (deferred but sketched)
- PR-35 CI integration (`pr sync` reads checks).
- PR-36 Cron/scheduler hardening.
- PR-37 Plan-vs-plan diff (G.plan.07).
- PR-38 Plan-to-PR materialization (G.plan.08).
- PR-39 First-30-minutes tutorial (G.wf.05).
- PR-40 Workflow cookbook (G.wf.06).

## OUT OF SCOPE (explicit non-goals for v1 plan)
- Multi-actor / team mode (G.team.*).
- PR-stack (G.wf.04).
- Library-dev parallel.
- v5 schema (stack-id, last-sync, spec-history fields).
- Visual UI.
- Network sync.

## Discipline additions

### Each PR must include
- 1-sentence user-visible change → goes into `CHANGELOG.md`.
- Files-touched list (used by review).
- Acceptance numbered list.
- Rollback steps.
- Owner row.
- `tools/lint_paths.py` clean (where applicable).

### Version bumps
- **W1 done** → `VERSION` bumped (e.g. `0.6.0` → `0.7.0`).
- **W2 done** → minor bump.
- **W3 done** → minor bump.
- **W4 done** → minor bump.
- PR-VERSION bump PR at end of each wave (PR-V1, PR-V2, etc.).

### Changelog format
Each PR appends to `CHANGELOG.md` under `## Unreleased` section. At wave end, `## Unreleased` → `## 0.X.0 — YYYY-MM-DD`.

## Open question audit (final)
| Q from earlier iters                            | Answer (final)                                  |
|-------------------------------------------------|-------------------------------------------------|
| W1 PR-3 ships `study/_index.md` skeleton?       | YES — empty index; W2 PR-17 populates.          |
| W1 PR-2 baseline.json?                          | YES — `study/compiled-audit.md` is the baseline. |
| Tests per-area or per-PR?                       | per-area; PRs append to existing files.         |
| WARN→BLOCK flip basis?                          | test-based (one full audit pass passes).         |
| `_session.md` state field richness?             | enum {active, frozen, tagged, closed, recovered}. |
| Migrator preserves unknown sections?            | yes, into `## CUSTOM` appendix.                 |
| Version bumps per wave?                         | YES, dedicated PR.                              |
| User-visible changelog?                         | YES, every PR.                                  |

→ final audit: `cd-plan-i4-a-final.md`.
