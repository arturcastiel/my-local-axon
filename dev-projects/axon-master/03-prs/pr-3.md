# pr-3 — Schema migrator v1 → v4.1 + atomic `_meta.md`

**Wave**: W1 · **Goals**: G.inf.01, G.inf.02, G.inf.03, G.study.04, partial G.inf.04 · **Depends-on**: PR-1, PR-2 · **Parallel-with**: PR-4

## Why (problem statement)
The flagship project `axon-master` itself is **stuck on v1 schema** while the kernel expects v4. `code-dev resume` is brittle against this mismatch (F-B1). R6 marks U-2 ("schema migrator") as a Tier-1 unaddressed gap. R5 adds a v4.1 minor bump for the `study/` folder convention. Without a deterministic migrator with backup + dry-run + restore, no other PR can safely touch `_meta.md`. PR-3 is the substrate for sessions (PR-9), study modes (PR-8), and `study/_index.md` (PR-17).

## Evidence (from studies)
- `helpers/cd-c1-p1-schema-map.md` → "v1 layout: 6 fixed sections; v4 layout: PR blocks + journal/ + study/. No automated upgrade exists."
- `helpers/cd-gap-c2-p2-schema-migrator.md` → full design: dry-run, backup-with-timestamp, idempotent re-run, `--restore`, `--all` walker.
- `helpers/cd-study-c4-p2-targets.md` → T-S0.1 (v4.1 schema bump for `study/` folder), T-S0.2 (migrator).
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.inf.01-04, G.study.04.
- F-B1 schema mismatch on resume is a **HIGH-damage** entry in the failure-mode mitigation top-10.

## Design notes
- `tools/migrate_meta.py`:
  - Parses v1 `_meta.md` → AST → v4.1 emitter.
  - Preserves unknown sections under `## CUSTOM/<name>` (e.g. axon-master's `## STUDY DIRECTIVE`).
  - Always writes `_meta.md.bak.<ISO-ts>` before overwrite; retention keeps last 3 (older auto-pruned).
  - `--dry-run` (default): print plan, write nothing.
  - `--apply`: perform migration.
  - `--restore`: byte-exact restore from most recent `.bak`.
  - `--all`: iterate `my-axon/dev-projects/*` with per-project confirmation.
  - On v1→v4.1, **also creates empty `study/_index.md` skeleton** (filled by PR-17).
- `tools/_axon_io.py` gains `atomic_write(path, content)` helper: write to `path.tmp`, fsync, `os.replace(path.tmp, path)`. Race-safe (F-B2).
- `code-dev-resume.md` updated: on encountering v1 schema, halts with `QUERY(user, "axon-master is v1; run code-dev migrate first?")`.
- Fixtures: two synthetic v1 projects (`v1-minimal` and `v1-with-custom`) so test runs do not touch real `my-axon/`.
- `*.bak.*` added to `my-axon/.gitignore`.

## Pitfalls (from failure-mode catalog)
- **F-B1 schema mismatch on resume** → this PR fixes.
- **F-B2 `_meta.md` race / hand-edit collision** → atomic write.
- Migrator breaks live project → dry-run + backup + `--restore` triple defence.
- Custom sections silently lost → `## CUSTOM/<name>` preservation rule, asserted by fixture `v1-with-custom`.

## Interface sketch
```text
$ python3 tools/migrate_meta.py --dry-run my-axon/dev-projects/axon-master
[plan]
  - rename: phase → phase (preserved)
  - add: ## PRs (empty)
  - add: ## SESSIONS (empty)
  - add: ## STUDY (refs study/_index.md)
  - preserve: ## STUDY DIRECTIVE → ## CUSTOM/STUDY DIRECTIVE
  - create: study/_index.md (empty skeleton)
0 writes. Run with --apply to perform.

$ python3 tools/migrate_meta.py --apply my-axon/dev-projects/axon-master
✓ Backed up _meta.md → _meta.md.bak.2026-05-17T14:22:31Z
✓ Wrote _meta.md (v4.1)
✓ Created study/_index.md
```

## Spec (canonical)
- **Files**:
  - new: `tools/migrate_meta.py`, `workspace/AXON-DOCS-SCHEMA.md`, `workspace/programs/code-dev-migrate.md`, `tests/test_migrator.py`, `tests/fixtures/projects/v1-minimal/`, `tests/fixtures/projects/v1-with-custom/`.
  - modified: `tools/_axon_io.py` (atomic_write), `workspace/programs/code-dev-resume.md`, `tools/REGISTRY.json`, `my-axon/.gitignore` (`*.bak.*`).
- **Acceptance**:
  1. Dry-run on `v1-minimal` fixture reports full plan, 0 writes.
  2. `--apply` produces v4.1 + `_meta.md.bak.<ts>`.
  3. Idempotent re-run on v4.1 = no-op (warns "already migrated").
  4. `--restore` produces byte-identical original.
  5. `--all` iterates `my-axon/dev-projects/*` with per-project confirmation prompt.
  6. Retention keeps last 3 `.bak` files; older deleted.
  7. Unknown sections preserved as `## CUSTOM/<name>` (verified by `v1-with-custom` fixture containing axon-master-style `STUDY DIRECTIVE`).
  8. Axon-master dry-run reviewed by HUMAN, then `--apply` real run.
  9. `code-dev resume` works on `axon-master` post-migration.
  10. PR-1 T1 passes after `code-dev-resume.md` edit.
  11. `tools/lint_paths.py` clean (no hard-coded paths in migrator).
  12. v1→v4.1 path creates empty `study/_index.md` skeleton (PR-17 fills).
- **Rollback**: `tools/migrate_meta.py --restore <project>`.
- **Owner**: AGENT writes + runs dry-run; HUMAN approves, runs `--apply`.
- **Parallelism**: ⊥ PR-4 (governance schema separate). Depends on PR-1 (T1 verifies post-migration), PR-2 (no recompile until gate ships).

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-3.
- Helpers: `helpers/cd-gap-c2-p2-schema-migrator.md` (design), `helpers/cd-c1-p1-schema-map.md` (v1 vs v4), `helpers/cd-study-c4-p2-targets.md` (T-S0.1-2).
