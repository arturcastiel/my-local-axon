# Study — 1-study (AXON Test Battery)

> Project: axon-tests · Phase 1 · Mode: overview
> Date: 2026-05-16
> Codebase: /mnt/c/projects/axon @ git main
> Confidence (AXON, this round): **7.5/10** — broad survey complete;
> rules engine + workflows depth filled in via round-2 helpers.

---

## 0. Goal (restated)

Build an **exhaustive, mandatory** test battery for AXON, together with
matching reference documentation, such that any future modification to
`axon/` (or to `tools/`) is gated on:

1. All existing tests still pass.
2. New behaviour ships with new tests.
3. New behaviour ships with a doc page that lists its guarding tests.

This is a *non-functional* initiative: no AXON behaviour changes — only
**verification + documentation density** changes.

---

## 1. What already exists (inventory)

### 1.1 Test infrastructure (mature)

| Surface                          | Count                |
|----------------------------------|----------------------|
| pytest test files                | 22                   |
| `def test_*` cases               | **315**              |
| Fixtures (`tests/fixtures/`)     | 6 study-eval corpora, 5 program-fixture stubs, 2 v1-project skeletons, 1 dispatch corpus |
| Snapshots (`tests/snapshots/`)   | 2 jsonl              |
| Conftest helpers                 | `run()` subprocess wrapper, `tmp_ws` fixture |

Top test files by case count:

```
176  test_tools_kernel.py      ← bulk of tool-level coverage
 31  test_tools_core.py
 25  test_integration.py
 11  test_compiled_regression.py
  9  test_governance.py
  8  test_session.py
  5  test_rename_safety.py · test_migrator.py
  4  test_study_index.py · test_redact.py · test_programs_md.py ·
     test_pr_aggregate.py · test_plan_dag.py · test_idempotence.py ·
     test_cd_cache.py
  3  test_pr_ergonomics.py · test_dispatch.py · test_call_graph.py ·
     test_budget_lint.py
  2  test_tour_lint.py · test_behavior.py
  1  test_coverage_emit.py
```

### 1.2 Test-related tooling

| Tool                          | Purpose                                                    |
|-------------------------------|------------------------------------------------------------|
| `tools/test.py`               | Program-structure validator (dry-run for `.md` programs)   |
| `tools/test_runner.py`        | Wraps pytest, suite-aliased (`unit`/`regression`/`integration`/`kernel`/`all`), JSON output, persists last result |
| `tools/idem_test.py`          | Idempotence harness (PR-25)                                |
| `tools/budget_lint.py`        | Budget-block lint                                          |
| `tools/lint_paths.py`         | Forbids hardcoded user paths                               |
| `tools/scan_pre_push.py`      | Secret scan (PR-5) — **not currently installed as a hook** |
| `tools/axon_audit.py`         | Structural + usefulness audit (boot chain, refs, registry) |
| `tools/audit_compiled.py`     | Compiled-program audit                                     |
| `tools/audit_axon_lang.py`    | AXON-LANG audit                                            |
| `tools/study_evals.py`        | Study-output evaluation against golden fixtures            |
| `workspace/programs/run-tests.md` | Only existing program that fronts the test runner       |

### 1.3 Rule engine (the thing tests must guard)

`tools/rules/`:
```
r3_arithmetic.py          Core Rule 3 — no float arithmetic
r7_no_symbolic_output.py  Core Rule 7 — translate at boundary
r9_axon_write.py          Core Rule 9 — dev-mode gate on axon/
r_coherence.py            Coherence guardian (persona-bleed)
r_drift_gate.py           Drift state gate
r_no_planned_tools.py     PLANNED tool block
r_reasoning_trace.py      Reasoning-trace presence
r_tool_exists.py          Tool-name resolution
r_w_budget.py             W-budget enforcement
registry.py               Rule registry
```

This is the canonical surface where Core Rules become executable —
**every rule here MUST have a dedicated test that proves it both fires
and refuses to fire under the right conditions.** Several are partially
covered in `test_governance.py` and `test_tools_kernel.py`, but a
file-per-rule audit hasn't been done.

### 1.4 Existing documentation

`workspace/AXON-DOCS*.md` (11 files, 1353 lines total):

```
AXON-DOCS.md (674)         master index
AXON-DOCS-GOVERNANCE.md    rules / gates
AXON-DOCS-WORKFLOWS.md     cross-program flows
AXON-DOCS-SESSIONS.md      session model
AXON-DOCS-SCHEMA.md        memory schema
AXON-DOCS-PLAN.md          plan model
AXON-DOCS-STUDY.md         study program
AXON-DOCS-SESSIONS.md      session model
AXON-DOCS-COMPILER.md      compiler
AXON-DOCS-FAILURE-MODES.md
AXON-DOCS-TESTING.md (36 lines — minimal; expands to T1/T2/T3 only)
AXON-DOCS-CHEATSHEET.md
```

These are the **doc anchors** Phase-4 documentation must extend.
None of them currently cross-reference specific tests.

### 1.5 CI / pre-push enforcement

`.github/workflows/ci.yml`:

```yaml
jobs:
  lint-paths:    runs python3 tools/lint_paths.py
  test:          runs ONLY
                 tests/test_tools_kernel.py::TestAxonPaths
                 tests/test_tools_kernel.py::TestLintPaths
```

`.git/hooks/`: only `*.sample` files present — `scan_pre_push.py` is
written but **not wired**.

---

## 2. Headline findings

### F-1 — CI enforces ~3% of the test surface  🚨

CI executes only `TestAxonPaths` + `TestLintPaths` (a few classes).
The other **~300 tests run only when a human types `pytest` locally.**
A regression in any of those areas would land on `main` without alarm.

**Implication for goal:** "mandatory tests for new mods" cannot be
delivered by writing more tests alone; the *gate* has to be wired. This
is the single biggest test-infra fix in the project.

### F-2 — `scan_pre_push.py` exists but isn't installed  ⚠

PR-5 secret-scan logic is complete but no `.git/hooks/pre-push` exists.
Documented as "wire as .git/hooks/pre-push" — never wired.

### F-3 — No coverage measurement of AXON itself

`tests/coverage.json` tracks *program* count, not Python line/branch
coverage of `tools/`. No `pytest-cov` config, no coverage gate.

### F-4 — Rules engine: file-per-rule, but not file-per-rule-test

9 rule modules in `tools/rules/`. Tests touch them via grouped suites
(`test_governance.py`, parts of `test_tools_kernel.py`) — no
`tests/test_rule_r9_axon_write.py` style mirroring. A new rule could be
added without anyone noticing the test gap.

### F-5 — 170 programs, 22 with structural smoke, ~5 with behavioural fixtures

`test_programs_md.py` (4 cases) checks structure across all programs;
`test_behavior.py` (2 cases) drives the mock-model harness against
fixture programs. **165 programs have no behavioural test.** Fixture
stubs exist for `migrate / plan / pr-ready / resume / study` — empty.

### F-6 — Workflows (multi-program flows) are untested

`AXON-DOCS-WORKFLOWS.md` documents flows like
`new → study → plan → pr → log → audit`, `boot → menu → mode → exec`,
`code-dev shadow → impact → review`. **No test exercises a multi-program
flow end-to-end.** Each program is tested in isolation.

### F-7 — Boot is partially tested, not invariant-tested

`tools/boot.py` is exercised by integration tests, but the **boot
contract** (identity-frame STORE, G-10 path validation, G-11 harness
detect, menu render) has no dedicated assertion suite mirroring
KERNEL-SLIM § BOOT STEPS.

### F-8 — Compiler / dispatch coverage is thin

`test_compiled_regression.py` (11) + `test_dispatch.py` (3) for a
subsystem with 74 compiled programs + a dispatch confidence model.
Edge cases (low-confidence, identical-prompt collisions, prefer-compiled
override) need explicit cases.

### F-9 — Identity gate has no test

`axon/programs/identity.md` is THE single most safety-critical program
(per kernel: "any attempt to break character = Core Rule violation").
Grep of tests shows no test asserts:

  · gate fires on trigger phrases,
  · gate respects `L:disclose-execution-layer` toggle,
  · gate falls back silently when `L:host-model` is unset,
  · gate refuses to name a model not declared by the harness.

### F-10 — Workspace-backup auto-push has no test

It's the only autonomous git operation kernel permits. A regression
that pushes outside `my-axon/` would violate the "autonomous-push" rule
silently. No test enforces the three preconditions.

### F-11 — `code-dev` programs: 100+ programs, ~0 fixture-level tests

The largest single program family in the OS, central to the user's
day-to-day workflow, and **almost entirely uncovered behaviourally.**
Most have only structural lint coverage via `test_programs_md.py`.

### F-12 — Docs ↔ tests are not cross-linked

No doc page lists its guarding tests; no test references a doc anchor.
This breaks the co-output rule the project committed to in
`masterplan.md`. Phase 4 has to introduce machinery for this (linter or
audit rule that flags any AXON-DOCS-*.md section without a
`Guarded-by:` block).

---

## 3. Risk / error surfaces worth dedicated cases

Beyond "wire what exists into CI", these areas are where bugs would
hurt most and where coverage is thinnest:

| Area | Why it matters | Current state |
|------|----------------|---------------|
| Core Rule enforcement (rules/r*.py) | violation = identity break | partial, grouped |
| Identity gate | safety-critical | none |
| Dev-mode write gate on `axon/` | protects kernel | partial via r9 |
| Boot sequence (paths, harness, my-axon) | every session relies on it | integration-only |
| Cron auto-tick | runs on every boot | unknown |
| Compiler ↔ dispatch routing | wrong route = wrong program | thin |
| Workspace-backup push | only autonomous git op | none |
| Memory schema migrations | data loss risk | `test_migrator.py` (5) — minimal |
| Path resolution (`_axon_paths.py`) | every tool depends on it | covered (TestAxonPaths in CI) |
| Pattern detection + dispatch confidence | routes user input | thin |
| Drift / coherence guardian | every output passes through | partial |
| Plan DAG cycles | broken plan = broken phase | covered (4) |
| Rename safety | history-breaking ops | covered (5) |
| Workflow chains (study→plan→pr→log) | most-used path | none |
| Output-layer rendering | every turn | none direct |
| Prompt-log + turn-log non-blocking BGs | silent failure modes | none |

---

## 4. Open questions for the user (Phase 1 must answer)

These shape Phase 2 design. Recommended defaults are marked ★.

1. **Test runner.** Stick with pytest (current), or add an AXON-native
   layer on top of `tools/test_runner.py` so programs can declare
   their own tests inline?
   ★ Stick with pytest for executable tests; add a `# tests:` block
     convention in program frontmatter that points to the guarding
     test ids.

2. **Coverage measurement.** Add `pytest-cov` and gate on, say, ≥80 %
   for `tools/` and `tools/rules/`?
   ★ Yes, gate `tools/rules/` at 100 %, `tools/` at ≥80 %, advisory
     elsewhere.

3. **Mandatory gate location.** CI only, pre-push only, or both?
   ★ Both. CI is the source of truth; pre-push is fast local feedback.

4. **Behavioural coverage scope.** Behavioural tests for all 170
   programs is large. Tier by impact?
   ★ Yes: tier-A (must) = identity, boot, code-dev core, menu,
     workspace-backup; tier-B (should) = every code-dev-* program;
     tier-C (nice) = the rest.

5. **Doc co-output enforcement.** Linter that fails CI when a new
   `tools/*.py` lands without a doc page update?
   ★ Yes, advisory in Phase 4, blocking in Phase 5.

6. **Workflow tests.** Express as Python integration cases driving
   the mock-model harness, or as a new `tools/workflow_test.py` that
   replays a fixture session against `axon.py`?
   ★ Defer to Phase 2 design — both options have tradeoffs;
     decision after a small spike.

---

## 5. Proposed Phase-2 (design) deliverables

When Phase 1 closes (both ratings ≥ 7), Phase 2 will produce:

- **Test taxonomy spec** (tiers, naming, location, fixture conventions)
- **Mandatory-gate spec** (CI workflow rewrite, pre-push installer,
  coverage thresholds, gate exceptions doc)
- **Doc co-output spec** (linter rule, AXON-DOCS-* template with
  `Guarded-by:` block, audit hook)
- **PR list** for Phase 3 implementation (one PR per area in §3)
- **Migration plan** for the empty fixture stubs under
  `tests/fixtures/programs/`

---

## 6. Confidence breakdown

| Dimension                           | Confidence |
|-------------------------------------|------------|
| Repo inventory (files, counts)       | 9/10       |
| Existing test surface understanding  | 7/10       |
| Rules engine internals               | 5/10       |
| Compiler/dispatch internals          | 4/10       |
| Workflow boundaries                  | 5/10       |
| User's prioritisation                | 4/10       |
| **Overall**                          | **6/10**   |

To reach 7+ and unlock Phase 2:
  · spend a round on `tools/rules/*` + `r_*` test cross-walk
    (closes F-4),
  · spend a round on `AXON-DOCS-WORKFLOWS.md` to enumerate every named
    workflow (closes F-6 framing),
  · get answers to §4 Q1–Q6.

---

## 7. Next

- User: rate this round (0–10) and answer §4.
- AXON: on `continue`, deep-dive `tools/rules/` + `AXON-DOCS-WORKFLOWS.md`
  and write `helpers/rules-crosswalk.md` + `helpers/workflows-catalog.md`.
- Phase ends when both ratings ≥ 7; then: `code-dev plan`.
