# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.

- Never WRITE to axon/ without L:dev-mode ≡ true (Core Rule 9).
- Programs may never write to axon/ — only humans in dev-mode.
- Commits/PRs/files co-author = AXON, never Claude; no harness footers; "PR-N" internal-only.
- Never mark a program "implemented" without verifying its logic actually runs.
- Distinguish the two stub markers: `!STUB`/`## TODO` (real gap) vs trailing
  `autogen-stub` on ## OUTPUT (cosmetic, present on working programs too).

## Added 2026-05-26 (owner directives)
- TESTING IS MANDATORY: nothing is "done" without tests; HUMAN/grant runs them.
- NEW PROGRAM OR TOOL ⇒ MUST SHIP TESTS in the same PR (enforced by crucible
  control R_NEW_NEEDS_TEST, BLOCK). No untested growth of the OS.
- PR specs follow the axon-ascent house style: front-matter (glossary/audience/
  version) + Goal(Statement/Acceptance/Rejection) + Blast radius (I-05) +
  Tests (mandatory) + Rollback (I-04) + Notes. Aggregate, do not duplicate.
- Kernel touches (axon/KERNEL*, axon/BOOT*, OUTPUT-LAYER auto-inject) are
  human-only — split them out of autonomous PRs.
