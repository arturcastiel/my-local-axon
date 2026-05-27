# 03-prs — index

Per-PR detail files for axon-user. Each follows the 9-section schema: WHY ·
Evidence · Design notes · Pitfalls · Interface sketch · Spec (Files /
Acceptance / Rollback / Owner) · Codebase grounding · Cross-refs · Status.

**Active plan**: [`../03-plan-v3.md`](../03-plan-v3.md) (v3, hierarchy upgrade)
**Active DAG**: [`DAG-v3.md`](DAG-v3.md) · [`DAG-v3.json`](DAG-v3.json)
**Prior iteration**: [`../03-plan.md`](../03-plan.md) (v2) · [`DAG.md`](DAG.md) · [`DAG.json`](DAG.json)

## Inventory (v3 — 18 PRs)

| PR    | wave | title                                                       | depends-on              | LOC  |
|-------|------|-------------------------------------------------------------|-------------------------|------|
| U-1   | U.A  | Rename-header sweep (24 files, line 1)                      | —                       | 24   |
| U-2   | U.A  | `tools/session.py list` subcommand                          | —                       | ~15  |
| U-3   | U.A  | `code-dev-chats.md` switch arg fix                          | U-2                     | 2    |
| U-4   | U.B  | Drop `state-restore.md`; alias `state-save → tag`           | U-1                     | ~5   |
| U-5   | U.B  | Absorbed-alias stubs + `--mode=diff` router branch          | U-1                     | ~20  |
| U-6   | U.C  | `pr-ready` drop Gate A; rewire to safety-preflight          | U-1                     | ~10  |
| U-7   | U.C  | Plan/study blanket vs per-mode budget reconciliation        | —                       | ~6   |
| U-8   | U.C  | pr_drift + cheatsheet truncation + SCHEMA refs              | —                       | ~15  |
| U-9   | U.C  | startup gate + `new` defaults + journal `# when:`           | —                       | ~10  |
| U-10  | U.E  | `plan --mode=strategic` writes `02-roadmap.md`              | U-1                     | ~25 + template |
| U-11  | U.E  | `plan --mode=tactical` writes `02-phases/phase-N-*.md`      | U-10                    | ~40 + template |
| U-12  | U.E  | `code-dev pr` reads phase docs; `Parent-phase:` field       | U-11                    | ~15  |
| U-13  | U.E  | `plan --mode=decision` writes `03-decisions/adr-NNN-*.md`   | U-1                     | ~20 + template |
| U-14  | U.E  | `docgen_verify` enforces tier link discipline               | U-10..U-13              | ~30  |
| U-15  | U.E  | `AXON-DOCS-SCHEMA.md` + `v4-schema.md` document hierarchy   | U-10, U-11, U-13        | ~25  |
| U-16  | U.E  | `code-dev-plan.md` HELP rewrite — modes per tier            | U-10..U-13              | ~12  |
| U-V1  | U.D  | VERSION 3.6.0 → 3.6.1 + CHANGELOG (errata + hierarchy)      | all of above            | ~45  |

**Total functional LOC**: ~320 across ~40 existing files + 3 new templates
(v4-roadmap.md, v4-phase.md, v4-adr.md — templates are scaffolding, not programs).

**No new programs. No new tools.** All edits are to existing files except
the three new template files under `workspace/templates/`.

## Graph

- **v3** (current): [`DAG-v3.md`](DAG-v3.md) · [`DAG-v3.json`](DAG-v3.json)
- v2 (kept for history): [`DAG.md`](DAG.md) · [`DAG.json`](DAG.json)

## Acceptance check

Each PR's spec lists its own gates. The project-level `_check-all.sh` is
implied: `lint_paths` + `budget_lint` + `call_graph --check` + `docgen_verify`
(now with tier link checks per U-14) + `scan_pre_push` + relevant pytest suites.
