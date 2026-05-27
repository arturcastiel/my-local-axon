# axon-cleanup log

## Round 1 · 2026-05-17 — Study phase (L1 → L3) drafted

Initialised the project, gathered raw data, wrote three iteration
layers.

**Data inputs:**
- Full pytest run (1929 collected, 281 failed, 1642 pass, 6 skip).
- `requirements.txt` parsed; cross-checked against `grep` of top-level
  imports across `tools/`, `tests/`, `axon.py`, `scripts/`.
- axon-audit `internal_refs` warnings (83 entries) for unresolved
  EXECs and unknown TOOLs.
- Manual inspection of one example traceback per failure cluster.

**Artefacts shipped this round:**
- `_meta.md` (phase=1-study)
- `01-study/01-layer-1-surface.md` (raw numbers)
- `01-study/02-layer-2-root-causes.md` (why + edges)
- `01-study/03-layer-3-solutions.md` (fix shapes + implications)
- `01-study/03-final-findings.md` (TL;DR + 5 open questions)
- `04-log.md` (this file)

**Headline numbers:**
- 281 test failures across 9 distinct modes; **273 (97 %) trace to a
  single root cause** — 18 broken program files.
- `requirements.txt` ships **117 packages**; only **18 are directly
  imported**; pip cache is **3.8 GB**.
- 50 unresolved EXEC chains + 30 unknown TOOL('shell') refs in
  `workspace/programs/`.

**Recommended next phase:** await user review + answers to 5 open
questions in `03-final-findings.md`, then advance `_meta.md` to
`2-plan` and start drafting per-wave PRs.

**Status:** study phase complete; awaiting user gate.

---

## Round 2 · 2026-05-17 — Study gate answered; plan drafted

User answered all 5 open questions:
- Q1 chromadb → drop entirely (after confirmation grep)
- Q2 dep declaration → pyproject.toml extras
- Q3 scope → one project, four waves
- Q4 compiled snapshot → keep + CI regenerate
- Q5 behavioural fixtures → defer

Recorded in `01-study/04-decisions.md`. Phase advanced to `2-plan`.

**Plan shipped:** `02-plan.md` lays out four waves, ~25 PRs total:
- Wave 0 (6 PRs) — CI unblock
- Wave 1 (12 PRs) — corpus sweep
- Wave 2 (4 PRs) — requirements cleanup
- Wave 3 (3 PRs) — optional hardening

Per-PR specs not yet written; user said "after that we start the plan
after I check everything" — interpret as: draft the per-PR specs
after user reviews `02-plan.md`. Wait at the plan-review gate.

**Status:** plan-phase wave-level done; awaiting user review of
`02-plan.md` before per-PR drafting.

---

## Round 3 · 2026-05-17 — Per-PR specs drafted (25)

User approved `02-plan.md` as-is. Drafted all 25 PR specs in
`03-prs/PR-{101..142}.md` using a uniform template (Goal · Touch · Tests · Doc · Notes/risks). Each spec carries a `Depends on:` line tying it to the wave-level DAG.

**Distribution:**
- Wave 0 — PR-101..106 (6 specs)
- Wave 1 — PR-110..121 (12 specs)
- Wave 2 — PR-130..133 (4 specs)
- Wave 3 — PR-140..142 (3 specs)

**Numbering convention:** 100s = axon-cleanup (axon-tests used 001..021). Future projects continue 200s / 300s.

**Risk flags raised in specs:**
- PR-106 needs human review of identity-program diff before snapshot bump.
- PR-115 may exceed practical single-PR size (~15–20 program files); split into 115a/b if needed.
- PR-119 touches the call graph — highest blast radius in Wave 1.
- PR-120 has an early decision point (register `shell` tool vs rewrite callers); resolve before drafting the diff.
- PR-130 will stop and ask user if grep surfaces an unexpected chromadb caller.
- PR-140 depends on `compile_optimizer` being deterministic — verify before landing.

**Phase status:** plan complete; awaiting user gate before Wave-0 implementation.

**Next:** user reviews `02-plan.md` + `03-prs/PR-101.md..106.md`. On
green light, advance `_meta.md` to `3-implement` and start PR-101.

---

## Round 4 — Wave 0 implementation (2026-05-17)

Shipped PR-101..106 sequentially. All 6 specs satisfied with implementation;
4 deviations from spec text (logged in `02-deviations.md`):

| PR | Target (spec) | Target (actual) | Why |
|----|----|----|----|
| PR-101 | `.github/workflows/ci.yml`: drop `--maxfail=1`; add guard test | same | — |
| PR-102 | `tools/test.py` always-JSON | `tools/budget_lint.py` `relative_to` crash | test.py already JSON-clean |
| PR-103 | Fix `out[0].stdout` bug in test_plan_dag | same | exposed real cycle in axon-master DAG (logged, out of scope) |
| PR-104 | `cycles` key missing | `_longest_path` recursion on cycles | schema fine; runtime crash before JSON write |
| PR-105 | Recovery dict shape drift | `os.getpid()` → `os.getppid()` | sibling subprocesses must share identity |
| PR-106 | Refresh identity snapshot | Fix `broken_refs` set-diff in `rename_snapshot.py` | snapshot was fine; tool counted pre-existing dangling refs |

Verification (just the affected files, not the full suite — per kernel R3
I am not running pytest autonomously over `tests/`):
  - test_coverage_config.py: passes (1 new test)
  - test_budget_lint.py: 3/3 pass
  - test_plan_dag.py: 3/4 pass (1 surfaces real axon-master cycle)
  - test_call_graph.py: 3/3 pass
  - test_session.py: 8/8 pass
  - test_rename_safety.py: 5/5 pass

Doc co-output: 2 rows added to `workspace/AXON-DOCS-TESTING.md`
(PR-101 + PR-102). PR-103..106 are tool/test fixes that do not change
documented behaviour — no Guarded-by rows needed (existing rows for
test_call_graph / test_session / test_rename_safety still hold).

Files touched this round:
  - .github/workflows/ci.yml
  - tests/test_coverage_config.py
  - tests/test_plan_dag.py
  - tools/budget_lint.py
  - tools/call_graph.py
  - tools/session.py
  - tools/rename_snapshot.py
  - workspace/AXON-DOCS-TESTING.md

Wave 0 is **done** modulo the surfaced axon-master cycle (separate issue).
Next: unblock Wave 1 (`axc-impl-w1`) and Wave 2 (`axc-impl-w2`).

---

## Round 5 — Wave 1 implementation (2026-05-17)

Wave 1 shipped via **automation**, not 12 hand PRs. Single deterministic
patch script (`scripts/autopatch_programs.py`) + 4 surgical follow-ups.

Key numbers:
  - test_programs_md.py:        281 fail → 0 fail   (788/788 pass)
  - test_compiled_regression.py:  71 fail → 0 fail   (targeted set)
  - Programs autopatched:       126 of 170
  - Orphan stubs created:         4
  - Compiled outputs created:   108
  - RED programs quarantined:   118
  - REGISTRY.json entries +1:    shell (OPTIONAL, no implementation)

Strategy callout — the user pre-authorised "bulk auto-patch with stub
OUTPUT/banner/DONE" when I escalated the scale finding (126 vs. the
planned 18). All other deviations stayed within authority granted by
this Wave-1 gate.

Doc co-output: No new AXON-DOCS rows. The Wave is mechanical hygiene;
the behavioural docs continue to apply unchanged. `_quarantine.md` is
self-documenting.

Files touched: see `02-deviations.md` for the full list.

Next: Wave 2 (requirements cleanup — PR-130..133) is now unblocked and
parallel-safe. Wave 3 (PR-140..142, hardening) still blocked on W1
landing in source-control.

---

## Round 6 — Wave 2 (PR-130..133) shipped

### Numbers

- Runtime deps: **117 → 12** (-105, -89.7%)
- Dev/tests: **0 declared → 2 declared** (pytest, pytest-cov)
- Tools deleted: **1** (`tools/semantic_search.py`)
- REGISTRY entries: **75 → 74** (`semantic-search` removed)
- Files updated: 8 (pyproject.toml, requirements.txt, ci.yml,
  health-check.md, SETUP.md, CONTRIBUTING.md, README.md, REGISTRY.json)
- New tests: 4 (in `tests/test_requirements_intent.py`)
- Doc updates: 2 (AXON-DOCS-GOVERNANCE §Dependencies / §Removed
  subsystems; AXON-DOCS-TESTING Guarded-by row)
- Test result on affected suites: **17/17 passing**
  (`test_coverage_config`, `test_requirements_intent`, `test_smoke`)

### Deviations

- **PR-130 risk fired** — chromadb HAD a live caller; user authorised
  hard delete. `axon/tools/semantic-search.md` left in place (R9).
- **PR-132 folded into PR-131** — no separate prune step.
- **PR-133 tomllib import** — Python 3.10 fallback to `tomli`.
- **test_coverage_config** required follow-up edit: the existing
  `test_requirements_lists_pytest_cov` was hard-coded to read
  requirements.txt; it now reads pyproject.toml + asserts the shim.

### Open items

- Full pytest battery not re-run in this segment (kernel R3 — user
  must invoke). Last known full result: post-Wave-1 (788/788 program
  tests + targeted compiled tests).
- `axon-master` DAG cycle still failing one test (pre-existing data).
- `axon/tools/semantic-search.md` stale doc card — flagged in
  02-deviations; awaits dev-mode toggle.

---

## Round 7 — Wave 3 (PR-140..142)

### Numbers

- PR-140: 1 new test file (3 tests, all passing); compile-CLI freshness
  gate added without forcing determinism.
- PR-141: `scripts/install-hooks.sh` now writes a 3-step pre-push hook;
  `tests/test_install_hooks.py` extended (4 tests, all passing).
- PR-142: deferred (50 warns vs spec assumption "few"; spec marked
  optional).
- Doc updates: 2 (AXON-DOCS-COMPILER §Snapshot regeneration;
  AXON-DOCS-TESTING §Pre-push hook).

### Deviations

- PR-140 byte-diff infeasible (timestamp header); shipped structural
  invariants instead.
- PR-142 deferred — see 02-deviations for the open list.

### Result

- Wave 3 closes the axon-cleanup project (PR-101..141 SHIPPED,
  PR-142 DEFERRED, with all guard tests passing on their affected
  suites).

---

## Round 8 — Post-wave cleanup (grooming + dev-mode unlock)

User-driven follow-up: 1) grooming, 2) dev-mode on, 3) DAG fix,
4) execute full battery.

### Numbers
- axon-audit warns: **50 → 0** (verdict: WARNINGS → HEALTHY).
- Files removed: `axon/tools/semantic-search.md`,
  `probe_semantic_search` in `tools/health.py`.
- Audit-tool bugs fixed: `resolve_program` `.md` doubling; EXEC_RE
  template/action/nested filtering; OPTIONAL host-dispatched tools.
- Corpus refs touched: 5 workspace programs (semantic-search comments).
- Axon-master DAG: forward-ref removed from `pr-8.md`,
  `test_real_axon_master_dag` now green.

### Full pytest battery
`2880 passed, 6 skipped, 0 failed` (~15 min runtime).

### Open items
- None blocking. axon-cleanup project closed.
