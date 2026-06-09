# Project-wide prohibition seeds — axon-discipline

These seed each new phase's `_dont-do.md` on `code-dev phase start`. They are INVARIANTS for every PR
in this project. Most are hard-won from the super-polish arc (see 01-study.md §1–2).

## Testing / correctness (the reason this project exists)
- **DON'T ship a producer-only test.** Never assert only that a producer WROTE a value. Always assert
  the OBSERVED end-state / that the consumer saw it (write → read back → assert the effect changed).
  A passing test over wrong behavior is worse than a known-open bug. This is the project's prime law.
- **DON'T assert program behavior by reading the markdown alone** when the behavior is mechanical
  (string interpolation, tool-call args, EXTRACT/REPLACE, state read/write, branch routing). Execute
  the mechanical layer (the harness) and assert the effect. Static text assertions are a backstop for
  SHAPE only (guard-precedes-EXEC, right tool called), never a substitute for an effect assertion.
- **DON'T fix a confirmed bug without first writing the regression test that reproduces it** (red →
  green). The test lands in the same PR as (or before) the fix.
- **DON'T weaken or skip a crucible control to get green.** The gate floor only rises. If a control is
  wrong, fix the control in its own PR with justification — never route around it.

## Change size / process
- **DON'T do bulk landings.** Small, single-concern PRs, each independently gated green. The 65-bug
  bulk fix did NOT cleanly hold (it spawned 15 regressions). One concern per PR.
- **DON'T merge on anything but `passed: true`.** Parse `python3 axon.py crucible gate` JSON and check
  `passed` in a SEPARATE step BEFORE committing — never chain commit after the gate in one pipe (that
  masked a RED verdict twice and landed bad commits).
- **DON'T branch late.** Branch BEFORE the first edit, every time.

## Merge discipline (GitLab `ci.tno.nl`) — see memory [[axon-merge-discipline]]
- **DON'T put brand words or `PR-<n>` tokens in a commit message.** The commit-msg hook
  (`lint_commit_trailer.py`) rejects forbidden co-authors, `\bPR-\d+\b`, the "Generated with" footer,
  and brand words in prose: `Claude|Copilot|ChatGPT|Gemini|Cursor|Anthropic|OpenAI`.
  FOOTGUN: "Cursor" matches case-insensitively, so describing AXON's loop variable `cursor` (e.g.
  `{cursor.id}`) in a commit body is REJECTED — write `<id>` / "the current node" instead.
- **DON'T forget the trailer:** every commit ends with `Co-authored-by: AXON <axon@arturcastiel.github.io>`.
- **DON'T merge before pre-linting the squash message:** `lint_commit_trailer.py --stdin < msg`
  (server-side squash bypasses the local hook). Merge by NUMBER: `glab mr merge <N> --squash
  --squash-message "$MSG" --remove-source-branch --yes` with a 405-retry loop (run backgrounded —
  foreground sleep is blocked). Verify the squash+merge commits with `--range` after.
- **DON'T ever `glab auth login`.** Auth is already configured.
- **DON'T `git add -A`.** Stage only the specific files you changed (the tree carries runtime artifacts:
  coverage.json, AXON-DOCS*.md, workspace/memory state — never commit those).

## Kernel / scope
- **DON'T write under `axon/` without L:dev-mode=true**, and restore it to OFF immediately after. Any
  `axon/KERNEL-SLIM.md` edit additionally requires the F50 version bump (`AXON vX.Y.Z` +
  `tests/test_kernel_version_lock.py` EXPECTED_SHA256). Prefer keeping this project OUT of the kernel.
- **DON'T regress the doc/freshness gate:** after touching programs or generators, run
  `python3 tools/freshness.py check` (must stay `ok:true`) and `axon.py doc-anchors check`.
- **DON'T re-attempt the DONE held refactors** (F21 sys.path, F30 aliases) — see [[axon-held-refactors]];
  in particular don't look for deleted `code-dev-<verb>` files (router-served) and KEEP the 3 functional
  sys.path inserts (crucible / dont_do_lint / _axon_lib).

## Methodology integrity
- **DON'T try to make LLM JUDGMENT deterministic** or exact-trace-test the fuzzy layer. The harness
  tests the MECHANICAL layer only; judgment points are stubbed. Fuzzy matching (structural overlap) is
  acceptable where judgment is unavoidable — mirror the existing behavioral-fixture approach.
- **DON'T reinvent existing substrate.** Build on crucible (22 controls), coverage-gate, neuron-audit,
  the behavioral fixtures (`tests/fixtures/programs/*/responses.jsonl`), workflow-simulate, and the
  contract metadata. Extend, don't replace.
