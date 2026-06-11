# PR-0d — compiled-mirror kill: delete mirrors + compile tools (reduce-surface)

Status: merged
Merged: MR !162 → main (squash) · kernel patch owner-applied via script · crucible green 27 controls
Follow-up: MR !163 — 20 stale kernel-tool test expectations reconciled (worktree-vs-commit gap)
Branch: general-bugfix/pr-0d-mirror-kill → main · Draft MR !162 (NOT merged — green-only)
Depends-on: PR-0c (merged !161)
Phase: 3-prs
Covers: §I largest prevention hole (decision-locked todo 20166489, owner 2026-05-28)

## Goal
Source is truth. Remove the entire compiled-mirror surface now that routing is
source-built (PR-0c): 46 mirror files, 5 compile tools, 8 machinery test files,
2 retired programs, prefer-compiled, the compiled-coverage tripwire — in lockstep.

## Deleted
- `workspace/programs/compiled/` (46 files)
- Tools: `compile.py` · `compile-write.py` · `audit_compiled.py` · `compile_suggest.py`
  · `compile_optimizer.py` (+ 5 REGISTRY entries → 158 tools: 140 ACTIVE + 18 OPTIONAL)
- Tests: `test_compile_write` · `test_audit_compiled` · `test_compiled_freshness` ·
  `test_compiled_regression` · `test_compile_optimizer` · `test_compiled_quality_ratchet`
  · `test_dispatch_prefer_compiled_floor` · `test_reaudit_compile`
- Programs: `suggest-compile.md` · `compile-optimizer.md` (deprecation-log records added)

## Edited (degrade-graceful seams)
- `dispatch.py`: prefer-compiled OUT (relax/floor constants, pref read, effective_match);
  `run` target `compiled/{p}.cmp.md` → `programs/{p}.md`; docstrings.
- `auto_improve.py`: auto-compile action removed (actions = auto-tune, auto-archive).
- `axon_audit.py`: compilation_coverage removed; usefulness/structural scores re-weighted
  (dispatch-ready 15→35 pts; structural = health); recommendations repointed.
- `docgen.py`: compiled badge/legend/mermaid/stat removed; lifecycle TESTED→INDEXED.
- `programs_registry.py`: compiled field + dir scan removed.
- `test_runner.py`: compiled suite removed; regression suite pruned.
- `metrics_manifest.json`: compiled-coverage metric (tripwire retired in lockstep).
- `test_integration.py`: compile-write/compile-suggest classes removed.
- menu.md (Dispatch line replaces Compiled; row + tip pruned), mode-suggest.md,
  axon-audit.md, smart-dispatch.md prefs (prefer-compiled/auto-compile out),
  CONTEXT.md, workspace/tools/REGISTRY.md, AXON-DOCS-COMPILER.md (RETIRED banner).
- Kept: `run.py` (executes source .md) · kernel `axon/compiler/` spec docs.
- Live dispatch-index rebuilt: 165 entries, drift-clean.

## BLOCKER — kernel residue (human-only, inviolable floor)
`axon/programs/interactive.md` still advertises/calls the deleted compile tool →
`axon-audit 1a` WARNs Unknown TOOL('compile') → `test_section_1a_healthy` red →
gate cannot go green. Exact 6-line patch: **PR-0d-kernel-patch.md**. Apply with
dev-mode, push to the PR branch, gate green, then squash-merge.

## Guarded-by
- `registry-drift` (158/158 clean) · `doc_counts` · `freshness` (green post-edit)
- `dispatch-index check` (drift-clean after rebuild)
- R_NO_ORPHAN_TOOLS/R_NEW_NEEDS_TEST n/a (deletes); full pytest = the gate
