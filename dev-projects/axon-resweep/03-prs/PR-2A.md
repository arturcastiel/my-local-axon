# PR-2A — Program call-sites: fix dangling subcommands in code-dev-* programs

- **Status:** merged (!135, 95357c8)
- **Phase:** 2-reaudit-fixes  ·  **Complexity:** S  ·  **dev-mode:** no (workspace/programs/ + tests/)  ·  **Depends on:** none
- **Source:** re-MEGA findings (05-reaudit-findings.md) — F-STUDYURL, F-IGAP, F-NEXT, F-SHADOW. The deep-program
  agent resolved every `TOOL()` against the real argparse (incl. `choices=` subcommands `verify.py` can't see);
  each below was grounded by running the call and getting exit 2 / wrong shape.

## Fixes (clean call-site swaps — each verified against the real CLI)
- **F-IGAP** `code-dev-meta-igap.md:53-55` — `redact.py` is flat `(--text|--file)`, no `scrub` subcommand, and
  outputs JSON `{hits, redacted}`. → `TOOL(redact, "--text {…}").redacted` (drop `scrub`, read `.redacted`).
- **F-NEXT** `code-dev-next.md:66` — `pr_aggregate.py` is flat (no `list` positional). → `TOOL(pr_aggregate,
  "--state in-progress --json")` (drop `list`; `--state` is free-form, accepts `in-progress`).
- **F-STUDYURL** `code-dev-study.md:302-308` — `web-search` is search-only (no `fetch`/`--url`); `document-parser`
  has no `parse`/`--text` (only `--file`, prints to stdout). → URL branch **degrades to paste** (AXON has no
  URL-fetch tool); PDF branch → `TOOL(document-parser, "--file {path}")`.
- **F-SHADOW** `code-dev-study-area.md:93` — `shadow init` requires `--hash` and has no `--summary` (summary
  already lives in `findings`). → compute `h ← TOOL(shadow, hash, "--file {f}").hash` then
  `shadow init --shadow-dir … --file … --hash {h}`.

## Pulled out of this PR (architectural — see PR-2F)
- **F-COMPILE** — verifying it revealed the whole auto-compile pipeline is dead (compile-write refactored to a
  writer-only; `compile_suggest.py:145,176` + `compile-optimizer.md:55` still call the old `--program`
  interface). Not a clean swap. + **F-CMPSTALE** (the 2 stale `.cmp.md` regenerate once the pipeline works).

## Acceptance
1. The 4 call sites use the real CLIs; no `redact scrub` / `pr_aggregate list` / `web-search fetch` /
   `document-parser parse` / `shadow … --summary`. [content-lock tests in test_resweep_program_subcommands.py]
2. `crucible gate` passed:true.

## Changes
- `workspace/programs/code-dev-meta-igap.md` · `code-dev-next.md` · `code-dev-study.md` · `code-dev-study-area.md`
- `tests/test_resweep_program_subcommands.py` (+4 content-lock tests)
