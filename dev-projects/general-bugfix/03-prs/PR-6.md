# PR-6 — library-dev plumbing [crit library]

Status: merged
Merged: → main (squash) · crucible green 27 controls · ZERO warnings
Branch: general-bugfix/pr-6-library-plumbing → main
Depends-on: PR-2 (merged — path repoint)
Phase: 3-prs
Covers: library dispatcher dead-route, --stdin class, search→ingest dead-drop, conformance BLOCK

## Goal
The library subsystem's remaining plumbing: the dispatcher routed on a zero-writer key
(every subcommand fell through to help), three call-sites passed a `--stdin` flag no tool
declares, search's approved candidates were STOREd into a key nothing read, and the
conformance lint false-flagged retrieval-eval's real `chunk` action.

## Change
- **Dispatcher**: routes on `W:library-dev-cmd` (documented writer contract, code-dev
  pattern); the zero-writer underscore key is gone.
- **--stdin class**: `library.py partition/gate/rank/gap-queries` gain `--input FILE`
  (stdin stays the fallback); the 3 call-sites write a working-file payload and pass the
  path (search gap-queries + rank, report partition).
- **Dead-drop**: ingest READS + CONSUMES `W:library-dev-ingest-new` (approved candidates
  take precedence in the file-selection chain; CLEARed so a later ingest doesn't replay).
- **Lint fix**: `declared_subs` reads the LAST usage brace group — option choices render
  before positionals, so first-brace parsing false-flagged `retrieval-eval chunk` (which
  is valid). Regression-locked.
- **Promotion**: `program-tool-conformance` → **BLOCK, all scopes** (baseline now 0);
  the redundant workflow-scope control retired (subset).
- **Tests**: `tests/test_library_dev_contract.py` — the audit's first program-level
  contract lock (dispatcher key documented, no --stdin, hand-off consumed) + lint
  regression + all-scopes-clean invariant.

## Verified-no-bug
- "gaps regex": `gap_queries` contains no regex — a clean dict-key extractor. The
  report→gaps.md→search PARSE seam is covered by the contract test instead.

## Milestone
Full crucible gate green with **zero warnings** (27 controls) — every guard silent-pass
or BLOCK; no WARN graveyard.
