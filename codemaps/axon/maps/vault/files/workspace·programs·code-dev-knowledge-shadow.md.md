---
tags: [code, file]
path: workspace/programs/code-dev-knowledge-shadow.md
---

# workspace/programs/code-dev-knowledge-shadow.md

> 56 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- AXON always checks shadow before reading source files — zero re-analysis tokens`
- `- Same-hash file → always use shadow; changed hash → re-analyse and update`
- `- Shadow is built automatically as you run study/plan/pr commands`
- `- Shadow versioned by git-commit hash (falls back to sha256)`
- `- coverage / bulk-phase target PR-level shadow files (per shadow-enforcement-v1)`
- `BULK-PHASE (PR-114 G3 — write missing PR-shadow files across an entire phase)`
- `CLEAR`
- `COVERAGE (PR-114 G2/G4 — read-only coverage report)`
- `Categorise each file`
- `Collect all source files under the target folder`
- `DISPATCH`
- `Findings per file`
- `GUARD`
- `HELP`
- `IDENTITY LOCK`
- `LIST`
- `OUTPUT → PYTHON_FAST · doc`
- `PROGRAM: code-dev-knowledge-shadow`
- `REFRESH`
- `Resolve shadow path`
- `SCAN`
- `SHOW`
- `STALE`
- `STATS (default)`
- `Show files requiring action`
- `budget:`
- `cache-prefix: 2048`
- `code-dev shadow bulk-phase <slug>     — write missing PR-shadow files for a phase (G3)`
- `code-dev shadow clear                 — delete shadow index (will be rebuilt on next run)`
- `code-dev shadow coverage [--phase S]  — PR-shadow coverage report (G2/G4)`
- `code-dev shadow list                  — list all indexed files`
- `code-dev shadow refresh               — re-analyse all stale files`
- `code-dev shadow scan <folder>         — bulk-scan a directory for new/stale shadow files`
- `code-dev shadow show <file>           — show full findings for a specific file`
- `code-dev shadow stale                 — list files with stale (outdated) shadow`
- `code-dev-knowledge-shadow.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Inspect and manage the shadow index for the active code-dev project`
- `desc:    Shadow index management — view, refresh, and query AXON's code findings`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 8`
- `inputs:  W:code-dev-project — active project`
- `invocation_source: [program]`
- `notes:`
- `output-cap:   2000`
- `outputs-count: 5`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND RETRIEVE(W:code-dev-project) ≠ ∅ AND target ≠ ∅ AND check.exists AND QUERY(user): \"Delete entire shadow index for project {RETRIEVE(W:code-dev-project)}? (yes/no)\" ≡ \"yes\" AND folder ≠ ∅ AND COUNT(all-files) > 0"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev shadow                       — show stats for active project`
- `{pr-id} — Shadow`

## Depends on
- (none)
