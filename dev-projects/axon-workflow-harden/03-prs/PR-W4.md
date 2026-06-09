# PR-W4 — workflow-new hardening: pre-write draft validation + per-phase questions registry

> **✅ MERGED — !145 (`09a1fd4`), gate GREEN (passed:true, 0 blocking, 0 warn).** Verified on main:
> workflow-new.md wires validate-draft, questions.yml + hardening test present. Branch deleted. 4 files / +177/−1.

- **Status:** merged !145
- **Phase:** 2-harmonize  ·  **Complexity:** S (wiring — the function already shipped)  ·  **dev-mode:** no
- **Source:** MR !141's sub-goal C. KEY SIMPLIFICATION: the `validate_draft` function + `validate-draft`
  subcommand ALREADY landed on main via W1's `workflow_run.py` bring (shipped but unwired + untested). So W4 is
  pure wiring + coverage, not a function port.

## What W4 does
1. **Wires the neuron** — `workflow-new.md` now dumps the assembled `draft`, calls
   `TOOL(workflow-runner, validate-draft, "--text {draft-text}")`, and on `count > 0` prints a per-error report
   (`[{phase}] {field}: {message}`) + `FAIL`s before `WRITE-YAML`. Catches the author-time traps: the `when:`/`if:`
   edge confusion (the iter-2 trap), dangling `next:`, duplicate ids, bad `start:`, missing required keys.
2. **Questions registry** — `workspace/programs/workflow-new-questions.yml` (brought verbatim): per-phase question
   lists (identity / goal / backbone / edges, ≥2 each) — reusable + auditable without code changes.
3. **Test** — `tests/test_workflow_new_hardening_c.py` (brought verbatim): registry shape + `validate_draft`
   behavior (the previously-untested function) + neuron-references-registry/validate-draft.

## Decisions
- **Skipped the brought `workflow-new.cmp.md` compiled mirror.** main has no workflow-new mirror; the brought one
  is cognitive output I can't verify fresh, and mirrors are optional. Running from source is correct + avoids a
  staleness hazard (per memory `axon-foreign-program-integration`).
- **Registry: surgical, not full generate.** workflow-new is already registered (no presence/drift issue); only
  its tools-list needed `workflow-runner` added. Hand-added that one line rather than `generate` (which would inject
  unrelated mtime churn on the W2 files). Drift `check` stays green.

## Acceptance
1. `workflow-new.md` calls validate-draft + references the questions registry; structure + kernel still pass. ✓
2. The hardening test passes (registry ≥4 phases/≥2 q each, validate_draft catches the traps). ✓ (14)
3. `crucible gate` passed:true. — pending

## Changes
- `workspace/programs/workflow-new.md` (+14) · `workspace/programs/workflow-new-questions.yml` (new) ·
  `tests/test_workflow_new_hardening_c.py` (new) · `workspace/programs/REGISTRY.json` (+workflow-runner tool)
