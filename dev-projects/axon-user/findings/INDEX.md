# axon-user findings — index (post first-run synthesis 2026-05-16)

| id    | persona | workflow | sev | summary                                                          | file                                    |
|-------|---------|----------|-----|------------------------------------------------------------------|-----------------------------------------|
| F-001 | P3,P5   | W-06/10/14 | S1  | **Renamed program files retain OLD `# PROGRAM:` header (≈20 files)** | F-001-rename-header-mismatch.md         |
| F-002 | P3,P5   | W-10     | S1  | `code-dev-review` router calls internals whose headers don't match filename | F-002-review-router-name-mismatch.md    |
| F-003 | P5,P2   | W-09     | S1  | `code-dev-preflight` is full program but desc says "alias stub"; still EXECs old absorbed names | F-003-preflight-mislabeled.md           |
| F-004 | P3      | W-09     | S1  | `code-dev-safety-audit-structure` is duplicate of `check-structure`, not an alias | F-004-safety-audit-structure-dup.md     |
| F-005 | P4      | W-12     | S1  | `code-dev-chats list` calls `TOOL(session, list, ...)` — session.py has no `list` command | F-005-chats-list-missing.md             |
| F-006 | P4      | W-12     | S1  | `code-dev-chats switch` invokes `transition` with `--from/--to` args session.py doesn't accept | F-006-chats-switch-signature.md         |
| F-007 | P4      | W-06     | S1  | `code-dev-state-save.md` body is a copy of `code-dev-tag.md` — restore round-trip impossible | F-007-state-save-is-tag-copy.md         |
| F-008 | P4      | W-06     | S1  | `code-dev-state-restore.md` is 7-line stub; doesn't restore _meta or phases | F-008-state-restore-stub.md             |
| F-009 | P5      | W-14     | S2  | Absorbed-alias stubs forward `--mode=X` flag but router reads `W:code-dev-review-sub` instead | F-009-review-alias-flag-vs-w-key.md     |
| F-010 | P5      | W-14     | S2  | `code-dev-diff` alias forwards to `code-dev-review --mode=diff` but router has no `diff` branch | F-010-diff-no-router-branch.md          |
| F-011 | P3      | W-04     | S2  | `code-dev-plan` per-mode budgets exist but program still declares a single blanket `# budget:` | F-011-plan-blanket-budget.md            |
| F-012 | P3      | W-07     | S2  | `journal-log` vs `journal-event` vs `journal-decision` — semantic boundaries undocumented | F-012-journal-semantic-overlap.md       |
| F-013 | P3      | W-05     | S2  | `pr_drift.py` token heuristic silently passes criteria with no ≥4-char tokens | F-013-pr-drift-heuristic-gaps.md        |
| F-014 | P2      | W-05     | S2  | `pr-ready` Gate A duplicates `preflight` Gate 0 (branch-sync twice) | F-014-pr-ready-redundant-gate.md        |
| F-015 | P5      | W-15     | S3  | Cheatsheet AUTO-VERBS truncates at 54 chars — descriptions cut mid-word | F-015-cheatsheet-truncation.md          |
| F-016 | P1      | W-01     | S2  | `startup.md` audience sections (AGENT vs USER) cause first-time confusion | F-016-startup-audience-split.md         |
| F-017 | P1      | W-02     | S3  | `code-dev-new` 4 sequential QUERY prompts; `first-phase` lacks default | F-017-new-query-chain.md                |
| F-018 | P5      | W-15     | S3  | `docgen_verify` reports 3 broken refs in `AXON-DOCS-SCHEMA.md` (templates/v4-meta.md, code-dev-migrate.md) | F-018-docs-schema-broken-refs.md        |
| F-019 | P3      | W-03     | S2  | `code-dev-study.md` references modes but lacks `# budget:` block enforcement comment | F-019-study-budget-doc-drift.md         |

## Counts

- **S1 — 8** (blockers)
- **S2 — 8** (friction)
- **S3 — 3** (polish)
- **Total — 19** unique findings (from 5 personas × 15 workflows simulated)

## The big one — F-001

The PR-26 / PR-27 / PR-28 renames were done via `cp old.md new.md`. This created the
new filename but the `# PROGRAM:` header inside the file (line 1) still says the
**old** name. If the AXON dispatcher resolves programs by header (not filename), every
single rename in W4 silently dispatches to the old slug.

**Affected files** (verified):

```
code-dev-state-save.md          → header: code-dev-tag
code-dev-state-status.md        → header: code-dev-status
code-dev-state-undo.md          → header: code-dev-undo
code-dev-state-resume.md        → header: code-dev-resume
code-dev-state-handoff.md       → header: code-dev-handoff
code-dev-state-metrics.md       → header: code-dev-metrics
code-dev-review-scope.md        → header: code-dev-scope-check
code-dev-review-self.md         → header: code-dev-self-review
code-dev-review-tests.md        → header: code-dev-suggest-tests
code-dev-review-diff.md         → header: code-dev-diff
code-dev-safety-audit-structure.md → header: code-dev-check-structure
code-dev-safety-audit.md        → header: code-dev-audit
code-dev-safety-preflight.md    → header: code-dev-preflight
code-dev-safety-freeze.md       → header: code-dev-freeze
code-dev-knowledge-explain.md   → header: code-dev-explain
code-dev-knowledge-impact.md    → header: code-dev-impact
code-dev-knowledge-shadow.md    → header: code-dev-shadow
code-dev-knowledge-reviewer-track.md → header: code-dev-reviewer-track
code-dev-journal-log.md         → header: code-dev-log
code-dev-journal-event.md       → header: code-dev-event
code-dev-journal-decision.md    → header: code-dev-decision
code-dev-journal-search.md      → header: code-dev-search
code-dev-lifecycle-tour.md      → header: code-dev-tour
code-dev-pr-create.md           → header: code-dev-pr
```

24 files. All need header line 1 corrected to match filename.
