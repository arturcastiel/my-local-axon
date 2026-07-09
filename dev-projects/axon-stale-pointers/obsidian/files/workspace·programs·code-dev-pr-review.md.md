---
tags: [code, file]
path: workspace/programs/code-dev-pr-review.md
---

# workspace/programs/code-dev-pr-review.md

> 56 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `"{pr-id}.*status.*" never matched: the `## {pr-id}` header and the `- **Status:**` line are on`
- `Add log entry`
- `Build phase status table`
- `DIFFERENT lines (`.` does not cross newlines) and 'status' was case-wrong vs '**Status:**' (audit).`
- `Extract touched files`
- `Flip the `- **Status:**` line WITHIN this PR's `## {pr-id}` section. The old single-line pattern`
- `GUARD`
- `Generate GitHub description`
- `Generate technical explanation`
- `IDENTITY LOCK`
- `LOAD CONTEXT`
- `OUTPUT → PYTHON_FAST · doc`
- `PHASE 1 — CONTEXT LOAD`
- `PHASE 2 — STUDY (shadow phase)`
- `PHASE 3 — CONFLICT ANALYSIS`
- `PHASE 4 — HARMONIZATION PLAN`
- `PHASE 5 — REBASE`
- `PHASE 6 — EXECUTION (apply fixes)`
- `PHASE 7 — VERIFICATION`
- `PHASE 8 — COMMIT ORGANIZATION`
- `PHASE 9 — DOCUMENTATION + TRACKING`
- `PROGRAM: code-dev-pr-review`
- `Produce numbered plan from conflicts + shadow findings`
- `Read all shadow files for touched files`
- `Read project tracking`
- `SELECT PR`
- `SHADOW GATE`
- `Surface the test targets from the PR spec`
- `Update 02-prs.md status`
- `Upstream state — user must run git commands`
- `Write harmonization file`
- `budget:`
- `cache-prefix: 4096`
- `code-dev-pr-review 1 --phase 6  — resume at Phase 6 (execution)`
- `code-dev-pr-review.md`
- `contract-version: neuron-contract v1.1`
- `desc:    PR review mode — context load → study → conflict analysis → harmonize → rebase → execute → verify → commit → document`
- `dispatch-phrases: review my pull request · do a PR review · check the code review · harmonize and rebase the PR`
- `domain: code-dev`
- `example: code-dev-pr-review 1        — run full review for PR-001`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    16000`
- `inputs-count: 13`
- `inputs:  W:code-dev-project — active project · W:code-dev-pr-review-n — PR number · W:code-dev-pr-review-phase — start phase`
- `invocation_source: [program]`
- `next:    code-dev-pr-create [N] — re-write spec if needed · code-dev log — add implementation entry`
- `output-cap:   6000`
- `outputs-count: 9`
- `outputs: 03-prs/PR-XXX-HARMONIZATION.md · PR-XXX-github-description.md · PR-XXX-explain.md · 04-log.md updated`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND FILE-EXISTS(\"{project-dir}/02-prs.md\") AND pr-entry ≠ ∅"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev-pr-review [PR-N] [--phase N]`

## Depends on
- (none)
