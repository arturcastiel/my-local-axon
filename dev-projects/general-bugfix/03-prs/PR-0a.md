# PR-0a — lint_path_vars: define-vs-use lint for path variables (WARN)

Status: merged
Merged: MR !159 → main (squash) · crucible green 26 controls
Branch: general-bugfix/pr-0a-lint-path-vars → main
Depends-on: (none)
Phase: 2-plan
Covers: T3 (conversational-subsystem path rot) — guard side

## Goal
Every `W:ws-*` / `W:myaxon-*` path variable referenced in a program must be DEFINED in the path map
(`workspace/WORKSPACE.md` for `ws-*`, `my-axon/MYAXON.md` for `myaxon-*`). The study found whole
subsystems (chat / plan / library) wired to `W:ws-chats` / `W:ws-plans` / `W:ws-episodic` /
`W:ws-libraries` / `W:ws-name` / `W:ws-path` with ZERO definitions — `SCAN`/`READ` silently hit
nonexistent dirs and dashboards report empty instead of erroring. This lint turns that silent rot
into a loud, deterministic finding.

## Change
- **New** `tools/lint_path_vars.py` — defined set parsed LIVE from WORKSPACE.md + MYAXON.md (no
  hand-maintained mirror, cannot drift). `check` exits 1 on any undefined reference (gate);
  `list` reports without failing. Read-only, stdlib-only, deterministic. De-duped (var, file)
  findings with line numbers.
- **Registry**: `lint-path-vars` ACTIVE in `tools/REGISTRY.json` (160 → 161 tools; CONTEXT.md
  counts reconciled).
- **Crucible control** `lint-path-vars` — severity **WARN** (24 known undefined refs are the
  pre-existing baseline; PR-2 repoints them, then this promotes to **BLOCK**).
- **Wiring** (R_NO_ORPHAN_TOOLS): `self-care` sweep gains a `path_vars` area (undefined count →
  needs_attention) + menu META TOOLS row.
- **Tests**: `tests/test_lint_path_vars.py` (regex, contract shape, defined-set canonicals,
  de-dup/location) + `test_self_care.py` path_vars-area coverage.

## Guarded-by
- Crucible `lint-path-vars` (WARN → BLOCK at PR-2).
- `R_NEW_NEEDS_TEST` (tool ships with tests).

## Out of scope
Repointing the 24 undefined refs (PR-2, T3 fix side). Promotion to BLOCK (PR-2).
