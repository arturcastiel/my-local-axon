# PR-5 — shadow contract [crit C6]

Status: merged
Merged: → main (squash) · crucible green 28 controls
Branch: general-bugfix/pr-5-shadow-contract → main
Depends-on: (none)
Phase: 3-prs
Covers: C6 (both shadow index-write paths abort; branch-tracking dead)

## Goal
`shadow init` rejected the 5 provenance flags the refresh/scan paths pass
(`--branch/--commit/--commit-msg/--caller-*`) → argparse exit 2 → BOTH primary
index-write paths aborted; branch-tracking entirely dead. Plus two phantom
`_READ_SHADOW_HEADER(...)` calls (a function existing nowhere), `study-area`
reading a `fresh` key `check` never emitted, and `review-coverage` orphaned.

## Change
- `shadow.py init` accepts + PERSISTS the provenance flags (header lines:
  git-branch/git-commit/git-commit-msg/caller-program/caller-project); the
  hash-refresh path updates branch/commit in place.
- `check` now emits `fresh` (= exists AND hash_match) — the key study-area reads.
- New `header` subcommand (JSON meta) = the single header source; both phantom
  `_READ_SHADOW_HEADER` call-sites in code-dev-knowledge-shadow repointed to it.
- `code-dev review-coverage` routed (was an authored-but-unreachable program;
  full review-family consolidation stays with the PR-spec contract work).
- Live-verified end-to-end: init-with-flags → header → refresh → fresh=true.
- Tests: 3 contract locks (flags persist · fresh key · header serves/absent).

## Guarded-by
- `program-tool-conformance` (the shadow call-sites now parse clean by construction).
- C6 contract locks in tests/test_shadow_enforcement.py.
