# Helper — Workflows catalog & coverage (Round 2)

> Round 2 of phase 1-study, axon-tests project.
> Scope: enumerate every named workflow + every implicit multi-program
> chain, and rate current test coverage.

## TL;DR

`AXON-DOCS-WORKFLOWS.md` names **7 core workflows** (W-01..W-07).
Static scan of `EXEC()` chains in `workspace/programs/` reveals at
least **8 additional implicit workflows** that aren't catalogued.
**None of the 15 has an end-to-end test.** Existing tests pin
individual programs, not chains.

## Catalogued workflows (from AXON-DOCS-WORKFLOWS.md)

| ID    | Entry verb                                         | Programs in chain                                                    | Tests today |
|-------|----------------------------------------------------|----------------------------------------------------------------------|-------------|
| W-01  | `code-dev pr new`                                  | code-dev-plan → code-dev-pr → code-dev-preflight                     | 0 e2e       |
| W-02  | `code-dev pr review N`                             | router → pr-review-p1..p9 → _reviewer-state.json                     | 0 e2e       |
| W-03  | `code-dev resume`                                  | code-dev-session recover → cache hit → briefing                      | 0 e2e       |
| W-04  | `code-dev study --mode=subsystem`                  | code-dev-study → code-dev-study-area → study_index.append            | partial: test_study_index (4)  |
| W-05  | `code-dev pr ready --strict`                       | code-dev-pr-ready → rules.evaluate (4 gates)                         | 0 e2e (governance tests touch loader only) |
| W-06  | `code-dev plan --mode=strategic --budget 12`       | code-dev-plan → rules.trace → plan_dag                               | partial: test_plan_dag (4)     |
| W-07  | `code-dev meta context use <slug>`                 | code-dev-meta-context → handoff outgoing → resume incoming           | 0 e2e       |

## Implicit (not catalogued) workflows discovered via EXEC scan

Top `EXEC()` targets in `workspace/programs/*.md` (by call-count):

```
6  quickstart            ← entry-point fan-out (menu → quickstart → many)
5  code-dev-review       ← review umbrella router
4  code-dev-freeze
3  code-dev-log, code-dev-load, code-dev-pr, code-dev-combine
2  code-dev-tag, code-dev-handoff, code-dev-actions, code-dev-study,
   code-dev-plan, code-dev-divide, menu, send-report, library-dev-status,
   find-program
```

From these, additional named flows that warrant test coverage:

| Proposed ID | Description                                            | Hot path? |
|-------------|--------------------------------------------------------|-----------|
| W-08        | **Boot** — startup.md → KERNEL-SLIM boot steps 1-3 → G-10/G-11/my-axon → menu | yes — runs every session |
| W-09        | **Menu → mode → free-text → mode-router → program**    | yes — every interactive turn |
| W-10        | **code-dev new** → scaffold (v4 schema) → study        | hot for new projects |
| W-11        | **code-dev load <slug>** → `_meta` validate → resume   | yes — every project switch |
| W-12        | **code-dev review** umbrella → review-self / review-scope / review-diff / review-tests / review-coverage | yes |
| W-13        | **code-dev freeze → safety-freeze → safety-audit-structure** | safety-critical |
| W-14        | **Identity gate** — input matches trigger → identity.md → render | safety-critical, runs many turns |
| W-15        | **Workspace-backup auto-push** — boot tail → workspace-backup → my-axon push | only autonomous git op |

## What today's tests actually pin

Existing integration-style tests (`test_integration.py` × 25,
`test_session.py` × 8, `test_idempotence.py` × 4) exercise *tool* code
paths against real filesystems in `tmp_path`. They do not drive a
program-level chain. The mock-model harness in `test_behavior.py` has
only 2 active cases and is parametrised against fixture programs whose
fixture directories are mostly empty stubs.

## Implications

1. **W-08 (Boot)** is the single highest-leverage workflow to test —
   every session depends on it. Must assert:
   - `L:cognition-frame` set to `AXON-OS` after step 1
   - `W:reasoning-mode` set to `kernel-ops`
   - G-10 path validation HALTs with the right message on bad path
   - G-11 harness detection routes correctly for CLAUDECODE / COPILOT /
     generic
   - my-axon detection: missing → prompt; present → MYAXON.md ops
     evaluated
   - workspace-backup auto-push fires only with the three preconditions

2. **W-14 (Identity gate)** must have a behavioural fixture set:
   each canonical trigger phrase ("what model are you?", "are you
   GPT?", "who made you?", ...) → identity render → assert the render
   contains expected fields when `L:host-harness`+`L:host-model` set,
   minimal render otherwise.

3. **Workflow tests need a new tool** (option A) or a new pytest
   convention (option B). Phase-2 decision:
   - **Option A:** `tools/workflow_test.py` replays a `.flow.jsonl`
     fixture against `axon.py` (subprocess), asserts state snapshots.
   - **Option B:** Drive the mock-model harness from
     `test_behavior.py` with multi-turn JSONL fixtures already
     supported by the harness.
   - Recommended: **B for behavioural, A for state-machine** (boot,
     backup) where the mock-model isn't involved.

4. **The catalog itself needs maintenance.** Three of the listed
   `EXEC()` targets in WORKFLOWS.md (e.g. `rules.evaluate`) are tool
   actions, not program files; mixing the two makes the catalog
   confusing. Phase 4 doc work should split into "Program chains" and
   "Tool chains".

## Doc anchor

`AXON-DOCS-WORKFLOWS.md` is the natural home. Phase 3 will add a
`## Guarded by` row to every W-NN entry, listing the test ids that pin
it. Phase 4 adds W-08..W-15.

## Proposed test layout

```
tests/test_workflows/
  __init__.py
  conftest.py                       — workflow harness + tmp project fixtures
  test_w01_pr_new.py
  test_w02_pr_review.py
  test_w03_resume.py
  test_w04_study_subsystem.py
  test_w05_pr_ready_strict.py
  test_w06_plan_wave.py
  test_w07_meta_context_use.py
  test_w08_boot.py                  — highest priority
  test_w09_menu_to_program.py
  test_w10_code_dev_new.py
  test_w11_code_dev_load.py
  test_w12_review_umbrella.py
  test_w13_freeze_safety_audit.py
  test_w14_identity_gate.py         — highest priority (safety)
  test_w15_workspace_backup.py      — highest priority (only autonomous git op)
```

15 files, target ≥3 cases each → ≥45 workflow cases, currently ~0.
