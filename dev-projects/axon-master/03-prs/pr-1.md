# pr-1 — T1 structural tests + cross-ref lint + boot smoke + tour lint

**Wave**: W1 · **Goals**: G.test.01, G.test.09, partial G.wf.02 · **Depends-on**: none · **Blocks**: PR-3, PR-12, PR-31.5

## Why (problem statement)
There is currently **no structural lint** for `code-dev*.md` programs. A program can ship with a missing `# desc:` line, an unknown `EXEC(code-dev-X)` reference, or a broken section heading and the breakage is only discovered at dispatch time. R6 marks U-3 ("test surface for code-dev programs") as a Tier-1 gap and lists "lint test in CI" as the first deliverable. R4 also flags `code-dev tour` cross-refs as silently rotting (F-F3). PR-1 closes both with a single pytest suite plus a one-shot boot smoke check.

## Evidence (from studies)
- `helpers/cd-gap-c2-p3-test-surface.md` → U-3, "Tier 1: structural lint (T1)" — first item, blocks everything.
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.test.01 ("Every program lints T1"), G.test.09 ("Boot smoke green").
- `helpers/cd-c1-p1-programs-map.md` → 57 code-dev programs already in workspace; no T1 gate today.
- `helpers/cd-wf-c4-p1-synthesis.md` → tour-rot listed under "discoverability decay" failure class.
- `helpers/cd-plan-i1-p-draft.md` → PR-1 sequencing rationale: must precede schema-migrator (PR-3) so migrator's writes can be verified.

## Design notes
- Extend `tests/test_programs_md.py` with three checks:
  1. Required headers present: `# PROGRAM:`, `# desc:`, `status:`, optional `budget:` (warn only at this stage).
  2. Cross-ref lint: every `EXEC(code-dev-X)` resolves to an existing program file in `workspace/programs/`.
  3. Tour-doc cross-ref: `code-dev-tour.md` references only verbs that appear in current program set.
- `tests/coverage.json` (new) enumerates `{program, status, T1, last-run}` so later PRs can extend without touching the test runner.
- Boot smoke: agent ships an `axon.py --check` (or documented `python3 -c "import axon; axon.boot_check()"`) script; HUMAN runs once per PR and confirms exit 0.
- Skip programs with `status: draft` or `status: deprecated`.

## Pitfalls (from failure-mode catalog)
- **F-D2 stub forwards to wrong target** → cross-ref lint catches.
- **F-F2 help text incomplete** → required-headers check catches.
- **F-F3 tour gets stale** → tour cross-ref lint catches.
- **F-D3 recursive program invocation** → out of scope for this PR; handled by PR-31.5.

## Interface sketch
```text
$ pytest tests/test_programs_md.py -v
PASSED tests/test_programs_md.py::test_t1_required_headers
PASSED tests/test_programs_md.py::test_cross_ref_lint  (57 programs, 312 EXEC refs, 0 broken)
PASSED tests/test_programs_md.py::test_tour_cross_refs  (1 tour file, 18 refs, 0 stale)
PASSED tests/test_programs_md.py::test_boot_smoke

$ cat tests/coverage.json
{"program": "code-dev-pr-review", "status": "active", "T1": "pass", "last-run": "2026-05-17T…"}
…
```

## Spec (canonical)
- **Files**:
  - new: `tests/coverage.json`.
  - modified: `tests/test_programs_md.py`, `tests/conftest.py`.
- **Acceptance**:
  1. Every `workspace/programs/code-dev*.md` with `status != draft|deprecated` passes T1 required-header check.
  2. Cross-ref lint — every `EXEC(code-dev-X)` references an existing program; 0 broken refs.
  3. `pytest tests/test_programs_md.py -v` (HUMAN) prints "passed N programs".
  4. `tests/coverage.json` enumerates per-program status; readable by later PRs.
  5. Boot smoke: agent provides `python3 axon.py --check` invocation; HUMAN runs, confirms exit 0.
  6. `code-dev-tour.md` cross-ref check passes (references only existing verbs).
- **Rollback**: `git revert`.
- **Owner**: AGENT writes; HUMAN runs `pytest` + boot smoke.
- **Parallelism**: blocks PR-3 (migrator needs T1 to verify post-migration), PR-12 (rename snapshot needs T1 ground truth), PR-31.5 (loop detector extends this file).

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-1.
- Helpers: `helpers/cd-gap-c2-p3-test-surface.md`, `helpers/cd-gap-c1-p3-goals-extracted.md` (G.test.01, G.test.09), `helpers/cd-plan-i1-p-draft.md`.
