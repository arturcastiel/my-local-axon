# PR-0 — Consistency gate (constitution PR)

- **id**: pr-0
- **slug**: consistency-gate
- **wave**: W0 (pre-foundation)
- **depends-on**: (none — this is the root)
- **blocks**: every other PR (pr-1..pr-v4 implicitly require pr-0 checks to pass)
- **parallel-with**: (none — must land first)
- **state**: planned

## Why

Plans drift. The session of 2026-05-16 produced 53 per-PR specs + a hand-built
DAG + a flat helpers/ tree. Audit run shows: **17/53 PRs missing required
schema sections**, **DAG drift is silent** (no checker), **57 code-dev-*
programs in flat namespace** (W4 rename PRs assume consistency that doesn't
exist yet). Before any feature PR lands, we need executable consistency
checks so drift is caught at the source.

> "we are losing integrity of code-dev — so other changes are updated first"
> — directive, 2026-05-16

## Evidence

- DAG.json: hand-built; no regen tool until PR-16.5.
- PR schema audit: 17/53 lack `## Interface sketch` (rename + docs + version PRs).
- workspace/programs/: 57 `code-dev-*.md`, only 11 grouped by prefix (`pr-*`, `plan-*`, `phase-*`, `explain-*`). PR-26/27/28 assume a categorical regrouping is desirable.
- helpers/: 70+ files at flat level; cycle-prefix (`c1-*`, `c2-*`, `c3-*`, `cd-*`) implies a subdir grouping was intended.
- No 02-* file; convention break (gap between 01-study and 03-plan).
- DASHBOARD.md doesn't match the `NN-name.md` numbering convention.

## Design notes

- This PR ships **executable checks**, not policy alone. Policy without enforcement decays.
- Three scripts live in `03-prs/` next to the artifacts they check (tight coupling, intentional):
  - `_dag-check.py` — parses DAG.json, walks pr-*.md `**Depends-on**:` lines, asserts consistency.
  - `_schema-check.py` — asserts every pr-*.md has the required H2 sections.
  - `_workflow-audit.md` — generated; lists every code-dev-* program with status, desc, target umbrella per PR-26/27/28.
- A single entrypoint `_check-all.sh` runs the trio and reports.
- pr-0 is in the DAG but has zero in-edges; every other node implicitly inherits a `pre-pr-0` edge via Acceptance language.

## Pitfalls

- F-DRIFT-1: checks ship but no one runs them → integrate into `code-dev-pr-create` Acceptance (W4 PR-28.5 will wire this).
- F-DRIFT-2: schema check too strict, blocks legitimately terse PRs → exclude `pr-v*.md` from interface-sketch requirement; allow `<!-- skip-schema: section-name -->` opt-out marker.
- F-DRIFT-3: DAG check fails on every commit because DAG.json is hand-edited → expected behavior; forces deliberate edits. PR-16.5 replaces with tool emission.

## Interface sketch

```
$ python3 03-prs/_dag-check.py
OK: 53 nodes ↔ 53 files, topo valid, acyclic.

$ python3 03-prs/_schema-check.py
FAIL: pr-26.md missing '## Interface sketch'
FAIL: pr-27.md missing '## Interface sketch'
... (exit 1)

$ bash 03-prs/_check-all.sh
[dag]      OK
[schema]   FAIL (17 missing sections)
[workflow] regenerated _workflow-audit.md
```

## Spec

- **Files**:
  - **new**: `03-prs/_dag-check.py` (~80 lines): load DAG.json, glob pr-*.md, parse `**Depends-on**:` lines, assert membership + acyclicity + file ↔ node bijection.
  - **new**: `03-prs/_schema-check.py` (~60 lines): required-section list, glob pr-*.md, opt-out marker support, per-PR-type rules.
  - **new**: `03-prs/_workflow-audit.md` (generated): table of all `code-dev-*` programs in `/mnt/c/projects/axon/workspace/programs/` with columns `name | desc | umbrella-target (per PR-26/27/28) | compiled? | registered?`.
  - **new**: `03-prs/_check-all.sh` (~10 lines): runs the three checks; exits non-zero on any fail.
  - **modify**: `_meta.md` — INVARIANTS section (already added).
  - **modify**: `03-plan.md` — reference PR-0 as gating.
  - **rename**: `DASHBOARD.md` → `00-dashboard.md`.
  - **new**: `02-brainstorm.md` (placeholder explaining the deliberate gap).
  - **restructure**: `helpers/` → `helpers/c1/`, `helpers/c2/`, `helpers/c3/`, `helpers/cd/` (move existing flat files into cycle subdirs by prefix).

- **Acceptance**:
  - `bash 03-prs/_check-all.sh` exits 0.
  - Every existing pr-*.md passes `_schema-check.py` (after backfill).
  - DAG.json parses and contains pr-0 as a node.
  - helpers/ contains only the four cycle subdirs + INDEX.md + METHODOLOGY.md.
  - 00-dashboard.md exists; no DASHBOARD.md.

- **Rollback**: revert this commit; checks are additive and don't gate existing automation.
- **Owner**: AGENT writes; HUMAN reviews and runs `_check-all.sh`.
- **Parallelism**: none (must land first).

## Codebase grounding

- **target codebase** for code-dev consistency: [`workspace/programs/`](../../../../workspace/programs/) (57 `code-dev-*.md` sources, 73 `.cmp.md` in `compiled/`).
- **W4 rename PRs that depend on this gate**: pr-26, pr-27, pr-28.
- **PR-16.5 will retire** `_dag-check.py` in favor of `tools/plan_dag.py` (which becomes the canonical DAG emitter).
- **PR-1 lint integration**: when pr-1 lands the tour-cross-ref lint, extend it to call `_workflow-audit.md` regen.
- **REGISTRY.json**: `_dag-check.py` and `_schema-check.py` are project-local; they do NOT register in the global `tools/REGISTRY.json` (project scope, not OS scope).

## Cross-refs

- `_meta.md` § INVARIANTS — the policy this PR enforces.
- pr-1 — first feature PR; gated by pr-0 passing.
- pr-16.5 — supersedes `_dag-check.py`.
- pr-26, pr-27, pr-28 — rename PRs that require workflow consistency baseline.
