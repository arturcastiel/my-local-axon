# CD·PLAN·I1·P — plan draft v1

> First draft. Wave-1 only at PR-resolution; W2-W4 sketched.

## Plan envelope
- **Target**: ship the AXON OS hardening sequence so code-dev is dependable as the flagship workflow.
- **Scope**: 35-45 PRs across 4+ waves.
- **Wave-1 size**: ~7 PRs, mixed tooling + docs.
- **Mode**: tactical.
- **Constraints**: empty `safety/rules.md`, empty `dont-do.md`, all kernel + memory rules in force.
- **Owner default**: agent writes; HUMAN runs/tests/pushes.

## Wave-1 PRs (draft v1)

### PR-1 — Schema v4.1 documented; migrator v1→v4.1
- Goals closed: G.inf.01, G.inf.02, G.inf.03, G.study.04 (folded), partial G.inf.04 (atomic for `_meta.md`).
- Deliverables:
  - `workspace/AXON-DOCS-SCHEMA.md` — version table + field reference.
  - `tools/migrate_meta.py` — migrator with `--target`, `--dry-run`, `--restore`, `--backup`.
  - Hook into `code-dev resume` (program edit).
  - Backup retention: keep last 3 `_meta.md.bak.<ts>` files; older deleted on next migrate.
  - Tests: `tests/test_migrator.py` (idempotence, v1→v4.1, restore byte-exact, dry-run).
- Acceptance:
  - axon-master migrates cleanly to v4.1 in dry-run; HUMAN approves; real run produces backup + new file.
  - Re-run = no-op.
  - `code-dev resume` works post-migration.

### PR-2 — Token audit + compile regression gate
- Goals closed: G.tok.01, G.tok.02, G.tok.04, G.tok.03 (static-prefix lint).
- Deliverables:
  - `tools/audit_compiled.py` — measures every compiled program; emits `study/compiled-audit.md`.
  - `tools/compile-write.py` — adds gate at 0.95 bytes & tokens; `--override` flag.
  - Static-prefix lint: first 2 KB must be byte-stable across two compiles.
  - Quarantine: RED-class programs flagged in `workspace/programs/compiled/_quarantine.md`.
  - Tokenizer pinned: anthropic; fallback char/4.
- Acceptance: numbers table committed; gate active; ≥1 RED quarantined (pr-review confirmed RED at -1%).

### PR-3 — `safety/rules.md` schema + governance precedence doc
- Goals closed: G.gov.01, G.gov.02.
- Deliverables:
  - `workspace/safety/rules.md` — empty + schema header (rules-v1).
  - `workspace/AXON-DOCS-GOVERNANCE.md` — precedence table, conflict resolution rule.
  - `tools/rules.py` — parse + list + audit (audit is W3).
- Acceptance: empty rules file parses; precedence doc reviewed.

### PR-4 — Secret redaction in journal + backup pre-push scan
- Goals closed: G.safe.03, G.safe.08.
- Deliverables:
  - `tools/redact.py` — regex set; applied at log-write-time.
  - `tools/scan_pre_push.py` — invoked by HUMAN before push; flags secrets in staged diff.
  - Allowlist file `workspace/safety/redact-allowlist.md`.
- Acceptance: synthetic secrets test passes; allowlist honored.

### PR-5 — One-page cheatsheet
- Goals closed: G.doc.10.
- Deliverables: `workspace/AXON-DOCS-CHEATSHEET.md` — 10 verbs / 5 flows / 3 escape hatches.
- Acceptance: HUMAN reads; agrees it's useful.

### PR-6 — Test surface T1 (structural) full coverage
- Goals closed: G.test.01.
- Deliverables:
  - Extend `tests/test_programs_md.py` — required-sections, cross-ref check.
  - Inventory dashboard at `tests/coverage.json`.
- Acceptance: every program in `workspace/programs/code-dev*.md` passes T1.

### PR-7 — Failure-mode catalog file
- Goals closed: G.safe.01, G.safe.02 (template).
- Deliverables:
  - `workspace/log/failure-modes.md` — populated from U-4 catalog.
  - `workspace/templates/postmortem.md` — template.
- Acceptance: catalog committed; one synthetic postmortem dry-run.

## Wave-1 gate to enter Wave-2
1. All 7 PRs merged (or alias-approved by HUMAN).
2. axon-master schema = v4.1 (migrator self-test).
3. Compile gate active (one RED quarantined).
4. Cheatsheet present.
5. Failure-mode catalog committed.

## Wave-2 sketch (not detailed yet)
PR-8 study modes (G.study.01 + G.plan.01 minimal); PR-9 `_session.md` + auto-checkpoint; PR-10 governance --strict; PR-11 plan reads rules; PR-12 rename-safety harness; PR-13 usage logging; PR-14 router stubs (top umbrellas).

## Wave-3 sketch
study/_index.md ecosystem · plan modes full · governance audit · sess compaction recovery · router stub finalization · TW2 dispatch corpus · per-program budget blocks · docs umbrella expansion.

## Wave-4+ sketch
File renames (R3 W4) · behavioral tests · golden study outputs · per-mode budgets full · CI integration · multi-actor (deferred).

## Risks called out in draft v1
- **Migrator risk** — if v1 has unexpected hand-edits, migration fails. Mitigation: dry-run + QUERY on schema-detect ambiguity.
- **Gate threshold risk** — 0.95 may be too tight for some programs. Mitigation: `--override` with explicit reason logged.
- **Cheatsheet bitrot** — out-of-date cheatsheet worse than none. Mitigation: regenerate from `# desc:` via `docgen` (W3 dependency).

## Open questions for I2
1. Should PR-1 (migrator) ship the schema v5 fields too (forward-looking), or just v4.1?
2. Is PR-3 + PR-11 (governance schema + plan reads rules) splittable, or merge?
3. Does PR-4 (secret scan) need to be part of `tools/checkpoint.py` for backup safety, or separate?

→ iteration 2 study: `cd-plan-i2-s-challenge.md`.
