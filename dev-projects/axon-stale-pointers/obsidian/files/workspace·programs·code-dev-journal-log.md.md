---
tags: [code, file]
path: workspace/programs/code-dev-journal-log.md
---

# workspace/programs/code-dev-journal-log.md

> 61 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- AXON does NOT implement — user implements, AXON observes and tracks`
- `- Entries are timestamped and linked to PRs automatically`
- `- If drift is detected, AXON offers to update the plan or PR spec`
- `- Shadow index is updated with new findings when files are modified`
- `Action snapshot for undo (append-truncate: record pre-append size BEFORE the append)`
- `Best-effort — phase_model.done() enforces deps + output-completeness; not-yet-advanceable just logs.`
- `Collect entry fields interactively`
- `DISPATCH`
- `DONE FOR TODAY?`
- `DRIFT`
- `DRIFT DETECTION`
- `DRIFT ESCALATION`
- `Entry — {ts.iso}`
- `GUARD`
- `HELP`
- `IDENTITY LOCK`
- `Key = "{git-branch} | {pr-id}" — allows multiple PRs on same branch without collision`
- `LOAD CONTEXT`
- `LOG ENTRY (default path)`
- `List open PRs (not yet merged) — merged PRs are journaled as `pr-merged {pr}``
- `OUTPUT → PYTHON_FAST · doc`
- `PR-005 (axon-code-dev-improve · R3): phase-entry guidance — goal + how-to (flag-gated, warn-first).`
- `PR-008 (axon-hr-ui): advance the phase manifest so the node-order gate guards REAL state.`
- `PROGRAM: code-dev-journal-log`
- `UPDATE SHADOW FOR MODIFIED FILES`
- `Update branch registry (05-branches.md) with current git state`
- `Update meta`
- `VIEW`
- `WRITE LOG ENTRY`
- `What was done`
- `budget:`
- `cache-prefix: 1024`
- `code-dev log drift        — show drift analysis only`
- `code-dev log view         — show current log`
- `code-dev log view [PR-N]  — show log entries for a specific PR`
- `code-dev-journal-log.md`
- `completion marker, so derive done-PRs from that canonical event source).`
- `contract-version: neuron-contract v1.1`
- `desc:    Phase 4 — log implementation discoveries, modifications, and divergences`
- `desc:    User-driven log of what was actually implemented; AXON tracks drift from plan`
- `domain: code-dev`
- `emits:   04-log.md`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    4000`
- `inputs-count: 9`
- `inputs:  W:code-dev-project — active project`
- `invocation_source: [program]`
- `notes:`
- `output-cap:   800`
- `outputs-count: 10`
- `outputs: {W:myaxon-dev-projects}/{slug}/04-log.md (append-only)`
- `phase:   log`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND FILE-EXISTS(\"{project-dir}/02-prs.md\")"`
- `role: mutator`
- `rows in _events.log by code-dev-merge (the log entries here never carry a`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev log               — interactive log entry`
- `when:    free-form append to 04-log.md; user-typed; not for atomic state changes (use journal-event)`

## Depends on
- (none)
