---
tags: [code, file]
path: tools/rules/r_code_change_requires_pr_phase.py
---

# tools/rules/r_code_change_requires_pr_phase.py

> 25 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `A PR spec is OPEN unless its `Status:` field is terminal (merged/done/closed/aba`
- `Active phase ids from a flat _phases.json (status=active) — the legacy/flat layo`
- `All plausibly-active phase ids — v4 _meta.md `phase:` FIRST (authoritative), the`
- `Code surfaces tracked in axon.git (mirrors r_new_needs_test._classify + tests +`
- `R_CODE_CHANGE_REQUIRES_PR_PHASE: a code change must be ON-WORKFLOW (criterion-ze`
- `Resolve the project dir (my-axon is gitignored but present locally); None if abs`
- `The loaded code-dev project slug (W:code-dev-project), read from disk; None if n`
- `The single active phase id (v4 _meta preferred), for callers that need ONE (e.g.`
- `The v4 _meta.md `phase:` value — the AUTHORITATIVE current phase — or None.`
- `_active_phase()`
- `_active_project()`
- `_candidate_phases()`
- `_has_open_pr_spec()`
- `_is_code_file()`
- `_json_active_phases()`
- `_meta_phase()`
- `_myaxon_root()`
- `_norm()`
- `_project_dir()`
- `_required()`
- `_spec_is_open()`
- `check()`
- `my-axon root, honoring W:myaxon-path (the working pointer the grant + contract r`
- `r_code_change_requires_pr_phase.py`
- `≥1 OPEN PR spec (PR-*.md with a non-terminal Status) in the project root 03-prs/`

## Depends on
- [[tools·rules·registry.py]]
