# axon-cleanup — Plan

> Source of truth for sequencing and scope. Per-PR specs in `03-prs/`.
> Decisions backing this plan: `01-study/04-decisions.md`.

---

## Constraints (locked)

- **No new tools.** Extend existing `tools/*.py`; add tests; add docs.
  Shell scripts / config files / CI files / pyproject.toml are not
  "new tools".
- **No kernel writes.** `axon/` is read-only this session
  (`L:dev-mode = false`).
- **Sequential implementation**, one PR at a time, deviations logged
  in `02-deviations.md` (axon-tests pattern).
- **Tests + Guarded-by co-output** — every PR that changes behaviour
  ships a test + an `AXON-DOCS-*.md` update with a `## Guarded by`
  row. Enforced by axon-tests gates `tests-full`, coverage, and
  `docgen-strict`.
- **Agent never runs `pytest`** unless user asks (kernel R3 surface).
  Human runs the suite; agent waits.

---

## Wave 0 — CI unblock (≈6 PRs)

Goal: every CI job runs to completion; failures are visible; the
coverage gate executes. Test count expected: 281 → ≈ 210.

| PR | Title | Touch | Test |
|---|---|---|---|
| PR-101 | Drop `--maxfail=1` from `tests-full` CI job | `.github/workflows/ci.yml` | meta-test on CI config |
| PR-102 | `tools/test.py` always emits JSON (no empty stdout) | `tools/test.py` | new `tests/test_tools_test_json_shape.py` |
| PR-103 | Fix `test_plan_dag::test_real_axon_master_dag` — CompletedProcess → JSON | `tests/test_plan_dag.py` | self |
| PR-104 | Fix `test_call_graph::test_cycle_detected` — restore or rename `cycles` key | `tools/call_graph.py` or test | self |
| PR-105 | Fix `test_session::test_recover_active_session` — confirm tool vs test bug, patch the wrong one | `tools/session.py` or test | self |
| PR-106 | Refresh `test_rename_safety` identity snapshot OR fix tool — diff identity must be clean | snapshot fixture | self |

PR-101 first, then PR-102..106 in any order. PR-102 is independent and
unblocks `test_budget_lint.py::*`.

---

## Wave 1 — Program-corpus sweep (≈12 PRs)

Goal: `tools/test.py --all` returns `ALL_PASS`. `test_programs_md.py`
and `test_compiled_regression.py` go green. axon-audit warns drop
sharply.

Grouped by concern; each PR is one coherent edit to a program family.

| PR | Title | Programs touched |
|---|---|---|
| PR-110 | Add OUTPUT + ▶ banner to `auto-*` programs | `auto-actions.md`, `auto-improve.md` |
| PR-111 | Fix `authoring-guide.md` DONE() placeholder | `authoring-guide.md` |
| PR-112 | Add OUTPUT + DONE + priority to `code-dev-audit.md` family | `code-dev-audit.md`, `code-dev-rules-audit.md`, `code-dev-safety-audit*.md` |
| PR-113 | Add OUTPUT to `code-dev-branch.md` + state programs | `code-dev-branch.md`, `code-dev-state*.md` |
| PR-114 | Add OUTPUT to `code-dev-pr-*` review chain | `code-dev-pr-review-p1..9.md` |
| PR-115 | Add OUTPUT to `code-dev-meta-*` + `code-dev-knowledge-*` | meta + knowledge families |
| PR-116 | Add OUTPUT to remaining code-dev-* programs | the rest |
| PR-117 | Add OUTPUT to `library-dev-*` family | library-dev-{cite,explain,ingest,intersect,new,report,search,status,library-dev}.md |
| PR-118 | Add OUTPUT to `igap-improve.md` + orphaned singles | the long tail |
| PR-119 | Resolve 50 `Unresolved EXEC()` — author stubs or fix refs | callers + new stubs |
| PR-120 | Resolve 30 `Unknown TOOL('shell')` — register or rewrite | `REGISTRY.json` + program callers |
| PR-121 | Regenerate `generated/compiled/programs/` snapshot | run `compile_optimizer` + commit |

After this wave, suite expected: ≈ 210 → < 5 failures.

---

## Wave 2 — Requirements cleanup (≈4 PRs)

Goal: install footprint < 100 MB. CI install step < 30 s.

| PR | Title | Touch |
|---|---|---|
| PR-130 | Confirm chromadb has no live caller; archive `tools/semantic*.py` if any | grep + move |
| PR-131 | Rewrite deps as `pyproject.toml [project]` + `[project.optional-dependencies] dev` | `pyproject.toml`, `requirements.txt` (shim or delete), `SETUP.md`, `CONTRIBUTING.md`, CI |
| PR-132 | Drop unused top-level packages (rich/typer/pydantic/server stack/etc.) | pyproject only |
| PR-133 | Guard test: `tests/test_requirements_intent.py` — every declared dep has a direct import or whitelist | new test |

---

## Wave 3 — Optional hardening (≈3 PRs)

| PR | Title | Touch |
|---|---|---|
| PR-140 | CI job: regenerate compiled snapshot + assert no diff | `.github/workflows/ci.yml`, `tools/compile_optimizer.py` |
| PR-141 | Pre-push hook adds `tools/test.py --all` (≤ 2 s) | `scripts/install-hooks.sh` |
| PR-142 | Audit-warn cleanup — close remaining axon-audit warns | various |

Behavioural fixtures (study Q5) deferred to `axon-fixtures` follow-up
project.

---

## Dependency graph (wave-level)

```
Wave 0  ──┬──>  Wave 1  ──>  Wave 3
          └──>  Wave 2  ──>  (independent of Wave 1)
```

Wave 0 must land before Wave 1 (CI must be running for sweep to
verify). Wave 2 can run in parallel with Wave 1 but lands separately
so the diff stays readable.

---

## Done definition

- Full pytest: 0 failures (was 281).
- `tests-full` job green; coverage gate green; `docgen-strict` green.
- `pip install -e .[dev]` completes in < 30 s with ≤ 20 packages
  installed.
- `tools/test.py --all` returns `ALL_PASS`.
- `axon-audit` section 1a returns `verdict: OK` (was `WARNINGS`).
- Every change has a `## Guarded by` row in the relevant AXON-DOCS
  page.

---

## What's NOT in this plan

- Refactors to working tools.
- Kernel changes (`axon/`).
- New tool scripts.
- Behavioural fixtures.
- Performance optimisation of `tools/test.py`.

If something in those buckets becomes necessary mid-implementation,
log a deviation and stop for user confirmation.
