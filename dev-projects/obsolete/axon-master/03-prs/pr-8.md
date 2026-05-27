# pr-8 — Study modes core (+ --target / --output / --input)

**Wave**: W2 · **Goals**: G.study.01, partial G.study.07, T-S1.2, T-S1.3, T-S1.4, T-S1.8 · **Depends-on**: PR-3 (schema)

> Forward-reference (NOT a dep): PR-17 will later fill `study/_index.md`
> from outputs produced by this PR. Documented per pr-16.5's
> "forward references in narrative are not deps" rule.

## Why (problem statement)
Today `code-dev study` writes one fixed-shape `01-study.md` per project. R5 measured this against industry tools (Sourcegraph / CodeQL / Semgrep) and found the program is doing **the work of 14 distinct study modes** behind one verb, with no scope control (`--target`), no output shape control (`--output`), and no external-input integration (`--input`). The mode taxonomy (`cd-study-c1-p2-modes-taxonomy.md`) defines 14 modes; this PR lands the core 3 (`overview / subsystem / deep`) plus the universal flags so downstream Wave-S2..S6 modes (PR-30 etc.) can slot in without touching the verb signature again.

## Evidence (from studies)
- `helpers/cd-study-c1-p2-modes-taxonomy.md` → 14 modes table with token budgets per mode.
- `helpers/cd-study-c4-p2-targets.md` → T-S1.1 (overview refactor), T-S1.2 (`--target=<path>`), T-S1.3 (`--target=<glob>`), T-S1.4 (`--output`), T-S1.8 (`--input <path>`).
- `helpers/cd-study-c3-p2-study-modes-detail.md` → per-mode contract (sections each mode must emit).
- `helpers/cd-study-c1-p3-prior-art.md` → output-shape distinction (engineering vs executive vs machine) drawn from Sourcegraph "code insights" vs "audit reports".
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.study.01, G.study.04-08.

## Design notes
- Two new programs:
  - `workspace/programs/code-dev-study.md` (already exists — gains `--mode`, `--target`, `--output`, `--input` arguments; routes to `-area` for subsystem/deep).
  - `workspace/programs/code-dev-study-area.md` (new) — handles `subsystem` and `deep` modes; reads `--target` path/glob, walks, emits sectioned output.
- Modes shipped this PR:
  - `overview` (default; refactor of current behavior; writes `study/overview.md`).
  - `subsystem` (writes `study/subsystems/<sanitized-target>.md`).
  - `deep` (writes `study/deep/<sanitized-target>.md`; larger token budget).
- `--target=<path>` (T-S1.2): single path; rejected if not under codebase root.
- `--target=<glob>` (T-S1.3): expanded via `pathlib.Path.glob`; budget honored (HALT if expansion > 200 files unless `--force`).
- `--output engineering|executive|machine` (T-S1.4):
  - `engineering` (default): full prose + code refs + recommendations.
  - `executive`: 3-section summary, ≤ 2000 tokens.
  - `machine`: YAML front-matter + section per finding, parseable by `tools/study_index.py` (PR-17).
- `--input <path>` (T-S1.8): JSON or text file (e.g. `coverage.json`, `gh pr view`); contents available under `INPUT.*` keys during composition.
- Back-compat: omitting `--mode` defaults to `overview`; existing `01-study.md` consumers see no break (overview file is the canonical "general study" output).

## Pitfalls (from failure-mode catalog)
- **F-C3 token-budget overflow** → per-mode budget headers (PR-20/PR-30 enforce); this PR declares them.
- **F-E4 stale study not flagged** → out of scope; PR-17 adds `_index.md`.
- Glob explosion → 200-file cap with `--force` escape.
- Mode collision (writing to another mode's file) → strict file-path-per-mode rule documented + asserted.

## Interface sketch
```text
$ code-dev study --mode=overview
✓ wrote study/overview.md (engineering, 4.2k tokens)

$ code-dev study --mode=subsystem --target=tools/_axon_paths.py --output=machine
✓ wrote study/subsystems/tools-axon-paths.md (machine, 1.8k tokens; YAML front-matter)

$ code-dev study --mode=deep --target='tools/*.py' --output=executive --input=my-axon/log/usage/2026-05-17.jsonl
walking 47 files (glob expanded)…
✓ wrote study/deep/tools-glob.md (executive, 1.9k tokens; integrated usage data)
```

## Spec (canonical)
- **Files**:
  - new: `workspace/programs/code-dev-study-area.md`.
  - modified: `workspace/programs/code-dev-study.md`.
- **Acceptance**:
  1. Three modes (`overview`, `subsystem`, `deep`) produce distinct sectioned outputs.
  2. Default = `overview` (back-compat).
  3. `--target=<path>` scopes the walk (T-S1.2).
  4. `--target=<glob>` expands before walk; 200-file cap with `--force` (T-S1.3).
  5. `--output engineering|executive|machine`; machine variant emits parseable front-matter (T-S1.4).
  6. `--input <path>` reads JSON/text and integrates (T-S1.8).
  7. Each mode writes its own file; never appends to another mode's file.
  8. `tools/lint_paths.py` clean.
- **Rollback**: revert; `study --mode=…` flag silently absent; default behavior unchanged.
- **Owner**: AGENT writes; HUMAN runs one of each mode and reviews shape.

## Codebase grounding
- **modify**: [`workspace/programs/code-dev-study.md`](../../../../workspace/programs/code-dev-study.md) — add `--mode`, `--target`, `--output`, `--input` to HELP block; introduce `STORE(W:code-dev-study-mode, ...)` and a mode dispatch table in `## LOAD CONTEXT`.
- **new**: `workspace/programs/code-dev-study-area.md` — area-scoped study program; reuses [`tools/shadow.py`](../../../../tools/shadow.py) `check`/`init` per file under `--target` (path or glob).
- **glob expansion**: use Python `glob.glob` / `pathlib.Path.rglob` in the program tool. `--target="src/**/*.py"` resolves before walk.
- **machine output**: front-matter parseable by `tools/study_index.py` (created in PR-17). Schema: `---\nmode: standard\ntarget: ...\nstaleness: fresh\n---`.
- **outputs**: write to `{project-dir}/study/<mode>.md` (per-mode file) instead of monolithic `01-study.md`. Compatible with future PR-17 `study/_index.md`.
- **back-compat**: when invoked with no flags → mode=`standard` writing to legacy `01-study.md` location.
- **compiled program**: [`workspace/programs/compiled/code-dev-study.cmp.md`](../../../../workspace/programs/compiled/) exists — will require recompile post-PR-2 gate.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 2 / PR-8.
- Helpers: `helpers/cd-study-c4-p2-targets.md` (T-S1.*), `helpers/cd-study-c1-p2-modes-taxonomy.md`, `helpers/cd-study-c3-p2-study-modes-detail.md`.
- Related: PR-17 builds `_index.md` consumer; PR-30 adds per-mode budgets.
