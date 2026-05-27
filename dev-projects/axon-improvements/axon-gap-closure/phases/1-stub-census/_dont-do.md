# Phase prohibitions — 1-stub-census

_(seeded from _dont-do-seeds.md on phase start)_

- Never WRITE to axon/ without L:dev-mode ≡ true (Core Rule 9).
- Programs may never write to axon/ — only humans in dev-mode.
- Commits/PRs/files co-author = AXON, never Claude; no harness footers; "PR-N" internal-only.
- Do NOT treat the `autogen-stub` tag or a `· stub` OUTPUT line as a completeness
  signal — it sits on 118 programs incl. working ones. Only `!STUB` is authoritative.
- TESTING IS MANDATORY (owner directive 2026-05-26): no gap is "closed" without
  test criteria + tests in the PR spec. HUMAN runs tests; AXON never executes them.
- Do not conflate code-dev-search (alias) with library-dev-search (real stub).
