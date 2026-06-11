# PR-0 — Fix code-dev impact blast-radius (dependency-free)

Status: merged
Merged: MR !152 → graphify-obsidian-integration (squash 22efee8) · crucible green
Branch: graphify-obsidian/pr-0-code-symbols → graphify-obsidian-integration
Depends-on: (none)
Phase: execute

## Goal
Repair the live-broken `code-dev impact` blast-radius analysis and lay the symbol-extraction
foundation for the in-house stdlib code-graph (P1) — with **no new dependency** (the panel-agreed
first step; see `study/worth-it-evaluation.md`).

## Problem (FAILURE-MODES D4)
`workspace/programs/code-dev-knowledge-impact.md` read `symbols.exported` from `TOOL(shadow, check)`,
but `shadow.py` never emits that field. So `JOIN(∅,'|')` made the caller-grep `\b()\b`, which matches
unrelated files as fake callers — a silently-degraded safety feature (false-negative on real callers,
false-positive on noise).

## Change
- **New** `tools/code_symbols.py` — deterministic, stdlib-only exported-symbol extractor
  (`ast` for Python = `EXTRACTED`; conservative regex for C/C++/JS/Go/Rust/Java = `INFERRED`).
  Read-only, no network. The R6 confidence ladder is native to the output.
- **Rewire** `code-dev-knowledge-impact.md` to derive a real symbol set via `TOOL(code-symbols, exports)`,
  guarding the empty case so `\b()\b` can never recur; surfaces the confidence tier per file.
- **Register** `code-symbols` in `tools/REGISTRY.json` (ACTIVE, code-dev).
- **Document** the failure mode (`AXON-DOCS-FAILURE-MODES.md` D4 + Guarded-by row).
- **Test** `tests/test_code_symbols.py` (11 tests incl. the empty-file regression).
- **Count** bump `CONTEXT.md` 157→158 tools (F58).

## Files
| File | Note |
|------|------|
| tools/code_symbols.py | new tool |
| tests/test_code_symbols.py | new test (load-bearing: empty-file regression) |
| tools/REGISTRY.json | register code-symbols |
| workspace/programs/code-dev-knowledge-impact.md | rewire to real symbols + empty guard |
| workspace/AXON-DOCS-FAILURE-MODES.md | D4 + Guarded-by |
| CONTEXT.md | tool count 157→158 (F58) |

## Acceptance criteria
- [x] `code-symbols exports --file <py>` returns real top-level public symbols (ast).
- [x] Empty / missing / unsupported file ⇒ empty list (no crash, no `\b()\b`).
- [x] Extraction is deterministic (same bytes → same output).
- [x] `tests/test_code_symbols.py` green (11 tests).
- [x] Gates: registry-drift, liveness (not orphan), lint-paths, docgen — green.
- [ ] Crucible gate green (merge gate).

## Out of scope
Graphify, the stdlib code-GRAPH (import/call edges — P1), and any code-dev wiring beyond the impact fix.
