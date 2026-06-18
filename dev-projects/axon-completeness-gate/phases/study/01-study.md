# Study — Terminal-Transition Completeness Gate (seed)

_Run: code-dev study (deep) to populate the full synthesis._

## Problem (one screen)
A node can reach a TERMINAL status (`done`/`complete`) without its DECLARED post-conditions
(outputs/effects) existing — because AXON's state-advances are guarded by PRE-conditions
(deps, order, no-skip) but not POST-conditions. Proven instances:
- `tools/phase_model.py:done()` guarded by `_deps_done` ONLY → axon-hr `plan` marked done with
  `03-prs/DAG.json` never emitted; nothing caught it.
- `tools/workflow_run.py:advance()` guards order + no-jump + sub-workflow anti-skip, but the leaf
  `record_step(status="ok")` is trusted, and workflow nodes declare NO outputs to verify.
General rule observed: **check-running gates (crucible, dag-consistency, write-gate) are sound;
label-advance transitions (done/complete) are vulnerable.**

## Goal
Make "no terminal transition without declared post-conditions" a uniform mechanical invariant,
driven by the SINGLE SOURCE OF TRUTH programs already carry: the `# outputs:` header (already
parsed by the program-entry preamble: `EXTRACT(src,"# outputs:") | EXTRACT(src,"## OUTPUTS",lines=1)`).

## Target sites to study (deep)
1. `tools/phase_model.py` — the partial fix (REQUIRED_OUTPUTS map + tests). Generalize: read the
   relevant program's `# outputs:` instead of a hardcoded, drift-prone map. Keep map as fallback only.
2. Program `DONE(id)` shorthand (KERNEL-SLIM §Shorthands) — the most general instance. Mechanize as a
   TOOL (e.g. `tools/terminal_gate.py` / extend phase_model) + a verifier RULE (R_TERMINAL_OUTPUTS in
   tools/verify.py). **NEVER edit KERNEL-SLIM.md** (inviolable floor) — the rule observes, the kernel text stays.
3. `tools/workflow_run.py:advance()` + workflow node schema (workspace/WORKFLOW-SPEC.md / workflows/*.json) —
   add optional node `outputs:`/`effects:`; verify before `record_step(status="ok")`.
4. Confirm-or-deny the same gap at: process lifecycle COMPLETE, scheduler/queue task COMPLETE, `dag set-status`.

## Design questions for study to answer
- Is `# outputs:` consistently machine-parseable across programs? (survey the real headers.)
- How are mechanical rules registered in tools/verify.py (R_NEW_NEEDS_TEST as the template)?
- What is the right output-path resolution (project-root-relative? glob? per-phase override)?
- Existence vs freshness: do we verify only existence (v1) or wire a consistency check (dag-consistency) too?
- How to avoid the drift residual (#5) entirely via the `# outputs:` source of truth.

## Constraints (HARD)
- "gates cannot be broken": no --force, no skip; crucible-green before test-execution (AEGIS green-only).
- No axon/ kernel edits (KERNEL-SLIM DONE shorthand stays; the mechanism is a tool + rule).
- Core Rule 13: tests in the same change. Bottom-up ACTIVE-with-tests.

## Existing partial fix (in tree, unvalidated until crucible green)
- `tools/phase_model.py` done() output-completeness guard + `tests/test_phase_model_outputs.py` (9 cases).
- This project SUPERSEDES its hardcoded map with the `# outputs:`-driven source of truth.
