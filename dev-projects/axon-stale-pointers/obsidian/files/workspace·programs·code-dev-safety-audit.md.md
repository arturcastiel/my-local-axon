---
tags: [code, file]
path: workspace/programs/code-dev-safety-audit.md
---

# workspace/programs/code-dev-safety-audit.md

> 56 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- Audit is non-destructive — it reads and reports, never modifies plans or specs`
- `- Re-run any time as implementation progresses to get updated status`
- `- Shadow index accelerates file re-analysis (stale files re-indexed automatically)`
- `AUDIT EACH PR`
- `Audit Notes`
- `BUILD SUMMARY STATS`
- `Best-effort — phase_model.done() enforces deps + output-completeness; not-yet-advanceable just logs.`
- `COLLECT ALL PR ENTRIES`
- `Compute PR-level shadow coverage for this project; embed in audit JSON`
- `DISPLAY`
- `GOAL COVERAGE CHECK`
- `GUARD`
- `Goal Coverage`
- `HELP`
- `IDENTITY LOCK`
- `Issues by PR`
- `LOAD CONTEXT`
- `OUTPUT → PYTHON_FAST · doc`
- `PR Status Table`
- `PR-005 (axon-code-dev-improve · R3): phase-entry guidance — goal + how-to (flag-gated, warn-first).`
- `PR-008 (axon-hr-ui): advance the phase manifest so the node-order gate guards REAL state.`
- `PROGRAM: code-dev-safety-audit`
- `Release-readiness gate (G5)`
- `SHADOW COVERAGE  (PR-114 — G2/G4/G5)`
- `Shadow Coverage  (PR-114 — G2/G4/G5)`
- `Shadow Index Stats`
- `WRITE REPORT`
- `and surface a SHADOW COVERAGE block in the terminal report. G5 release-`
- `budget:`
- `cache-prefix: 2048`
- `code-dev audit [PR-N]      — audit a specific PR only`
- `code-dev audit diff        — show only PRs with issues`
- `code-dev-safety-audit.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Final audit — AXON reads every PR spec and log entry, produces status table + issues report`
- `desc:    Phase 5 — audit: cross-reference PR list vs implementation log, surface gaps`
- `domain: code-dev`
- `emits:   05-audit.md`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 10`
- `inputs:  W:code-dev-project — active project`
- `invocation_source: [program]`
- `notes:`
- `output-cap:   2000`
- `outputs-count: 8`
- `outputs: {W:myaxon-dev-projects}/{slug}/05-audit.md`
- `phase:   audit`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND FILE-EXISTS(\"{project-dir}/02-prs.md\")"`
- `readiness consumes shadow.coverage.pass downstream (PR-118).`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev audit              — full audit of all PRs`

## Depends on
- (none)
