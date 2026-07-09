---
tags: [code, file]
path: workspace/programs/code-dev-pr-create.md
---

# workspace/programs/code-dev-pr-create.md

> 74 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(file-level OPM C++ PR style; folded in from code-dev-pr-spec in axon-3.0 PR-008)`
- `- AXON checks the shadow index before reading any file — zero re-analysis tokens`
- `- Run once per PR; re-run to iterate on a specific PR`
- `- Shadow findings are updated automatically when new code is analyzed`
- `A new PR spec MUST appear in the phase PR-DAG immediately — not only at the next`
- `ALSO CHECK DEPENDENT PR SPECS (for context on deps)`
- `AXON rates own spec`
- `Acceptance Criteria`
- `Architecture Impact`
- `Best-effort — phase_model.done() enforces deps + output-completeness; not-yet-advanceable just logs.`
- `CASCADE TO DAG (PR-DAG stays the single source of structural truth)`
- `COMPOSE SPEC`
- `CONSTRAINTS`
- `Changes Required`
- `Determine which PR to write`
- `Entry Conditions`
- `Files Analysed (shadow index)`
- `Find next unwritten PR`
- `G-11: Register branch at spec-write time (key = branch + PR, allows multiple PRs per branch)`
- `GUARD`
- `Goal Context`
- `HELP`
- `IDENTITY LOCK`
- `ITERATION LOOP`
- `Implementation Notes`
- `LOAD CONTEXT`
- `OUTPUT → PYTHON_FAST · doc`
- `PR-005 (axon-code-dev-improve · R3): phase-entry guidance — goal + how-to (flag-gated, warn-first).`
- `PR-008 (axon-hr-ui): advance the phase manifest so the node-order gate guards REAL state.`
- `PROGRAM: code-dev-pr-create`
- `READ + INDEX NEW FILES`
- `Risks & Gotchas`
- `SHADOW LOOKUP — before reading any source files (token optimisation)`
- `Summary`
- `Update PR status in 02-prs.md — the planner writes each PR's status as `- **Status:** not-started``
- `WRITE SPEC FILE`
- ``code-dev plan` rerun. Bootstrap the DAG if absent, add the node, wire existing deps.`
- `budget:`
- `cache-prefix: 2048`
- `code-dev-pr-create.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Phase 3 — write detailed specification document for a single PR`
- `desc:    Produce a full PR specification: what changes, why, architecture context, files, acceptance criteria`
- `dispatch-phrases: open a new pull request · scaffold a PR · write a PR spec · start a fresh PR · create the next PR`
- `domain: code-dev`
- `emits:   03-prs/PR-*.md`
- `example: code-dev pr 1`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `header is `## PR-001 — …`, so the lookup is `## {pr-id}` — NOT `## PR-{pr-id}` (which double-prefixed`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 12`
- `inputs:  W:code-dev-project — active project · W:code-dev-pr-n — PR number (optional)`
- `invocation_source: [program]`
- `next-suggests: [code-dev-pr-review]`
- `next:    code-dev pr [N+1] — write next PR · code-dev log — log implementation`
- `output-cap:   2000`
- `outputs-count: 10`
- `outputs: {W:myaxon-dev-projects}/{slug}/03-prs/PR-00N.md`
- `phase:   pr`
- `pr-id already carries the `PR-` prefix + zero-pad (line 97: "PR-{pad(pr-n,3)}"), and the section`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND FILE-EXISTS(\"{project-dir}/02-prs.md\") AND pr-entry ≠ ∅ AND L:cognition-frame ≡ \"AXON-OS\""`
- `resolution at spec render time. Legacy flat plans skip this.`
- `role: mutator`
- `sibling not-started PR is untouched.`
- `spec-written PR stayed not-started forever). Flip the status line scoped to THIS PR's section so a`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `to `## PR-PR-001`, matched nothing, and left the PR stuck not-started). Mirrors line 98's pr-entry lookup.`
- `under a `## PR-{id} — …` section, with NO `← {pr-id}` arrow (the old literal matched nothing, so a`
- `usage:   code-dev pr [N]   — write spec for PR-N`
- `v4.2 — if tactical phase files exist, load the index for parent-phase`

## Depends on
- (none)
