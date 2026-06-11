# PR-0c — compiled-mirror kill, step 0: decouple the dispatch index from compilation

Status: merged
Merged: MR !161 → main (squash) · crucible green 27 controls
Branch: general-bugfix/pr-0c-dispatch-decouple → main
Depends-on: (none)
Phase: 3-prs
Covers: §I largest prevention hole, step 0 (decision-locked todo 20166489)

## Goal
`dispatch.match` routes against an index populated ONLY as a compile side-effect
(`compile_suggest.register_in_dispatch_index`). That coupling is what blocked the
compiled-mirror kill: delete compilation and routing starves. Live index at decouple
time: ONE demo entry ("foo") — routing covered none of the 170 real programs.

## Change
- **New** `tools/dispatch_index.py` — builds the index from program SOURCE
  (`programs/*.md` `# PROGRAM:`/`# desc:` headers), independent of compilation.
  `rebuild` (idempotent) · `status` (drift report) · `check` (exit 1 on drift).
  Entry shape stays reader-compatible; `indexed_at` replaces `compiled_at`
  (`freshness` reads either — fallback added).
- **Regression test (the decouple proof)**: `dispatch.match` reproduces routing from a
  pure source-built index (fixture workspace, zero compiled mirrors, ≥0.65 confidence).
- **Wiring**: `self-care --heal` auto-rebuilds the index on drift (regenerable artifact,
  same class as freshness refresh). dispatch.py empty-index hint repointed
  (compile-suggest → dispatch-index).
- **Registry**: `dispatch-index` ACTIVE (162 → 163; CONTEXT.md reconciled).
- **Live index rebuilt** from source (runtime state, not committed).
- **No deletes yet** — compile_suggest/compiled mirrors untouched (that is PR-0d).

## Guarded-by
- `tests/test_dispatch_index.py` (5: rebuild/skip/drift/regression/CLI-gate).
- `dispatch-index check` available as a future crucible control (wired at PR-0d when the
  legacy writer is removed and source becomes the ONLY writer).

## Out of scope
Deleting compiled/, the 5 compile tools, prefer-compiled (PR-0d).
