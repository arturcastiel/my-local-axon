# CD·C1·P4 — code-dev web findings (broad survey)

> External prior art relevant to code-dev: stacked-diff tooling, agent code-review loops, codebase indexing, spec-driven development. Topics gathered, no live fetch performed in this pass — these are anchor points for cycle-2/3/4 deep dives.

## 1. Stacked-diff workflows (Meta/Google scale)
- **git-spice** — stack-aware rebase / restack, branch graph, submit each branch as a PR. Solves the PR-stack problem in our G-CD-A3.
- **Graphite (CLI + service)** — `gt create / submit / sync`, automatic restack, dependency tracking. Web UI for review queue.
- **GitButler** — virtual branches in a single working dir, drag commits between branches.
- **Sapling (Meta)** — `sl` smartlog, stack diff workflows on top of mercurial-ish UX.
- **Magit / jujutsu (`jj`)** — interactive rebase + stack views.

**Take for code-dev:** v4 already has `_pr-links.md` (depends-on, blocks). A stacked workflow needs (a) restack on parent change, (b) per-stack push command, (c) merge-cascade across the stack.

## 2. Agent code-generation / review loops
- **Aider** — file-edit agent, integrates with git; commits are agent's. Notable: small per-turn context windows + repo-map. Their *repo-map* idea matches our shadow index.
- **Cursor Composer / Agent** — multi-file edits with structured diffs; reviewer-aware UI.
- **Continue.dev** — open-source autonomous loops; pluggable agents.
- **Sweep AI** — issue → PR pipeline; uses codebase-wide semantic index ranked by issue.
- **OpenAI Codex / Devin** — long-running task agents; checkpoint + resume similar to our `code-dev resume`.
- **GitHub Copilot Workspace** — spec → plan → diff workflow (very close to ours).

**Take for code-dev:** all of these have *reviewer-bot loops* and *implicit PR specs*. Our explicit `03-prs/PR-N.md` is more rigorous, but lacks the auto-loop.

## 3. Codebase indexing prior art
- **Aider repo-map** — file → top-N symbols + neighbors, fits in context.
- **Sweep AI** — semantic embeddings + heuristic ranking.
- **Cursor codebase indexer** — embeddings + AST extraction, language-aware.
- **Sourcegraph** — full semantic graph + cross-repo search.
- **OpenGrok / ctags** — old but solid; symbol-level index.

**Take for code-dev:** our shadow indexer is file-level + heuristic symbols. Adding embedding similarity (cheap, local) would give us Sweep-like file-ranking for `plan` and `impact`.

## 4. Spec-driven development
- **TLA+ / Apalache / Alloy** — formal specs + model checkers. Match acceptance criteria → invariants.
- **Property-based testing (Hypothesis, QuickCheck)** — generate tests from properties.
- **OpenAPI / JSON-Schema** — API specs feeding test gen and clients.

**Take for code-dev:** v4 PR `proof:` lines hint at formal-ish acceptance. A bridge to property-based tests would close G-CD-C5 (auto-test-suggest-from-diff).

## 5. PR review automation
- **GitHub Actions reviewer-bot patterns** — `pull_request_review` events drive bots.
- **CodeRabbit / Sourcery / Codiga** — LLM reviewers on PRs.
- **Reviewable.io** — review-state machine with rounds/objections (very similar to our `reviewer-state.md`).
- **Gerrit** — change-set review with explicit votes; supports rebase chains.

**Take for code-dev:** Reviewable's state machine validates our model. Bots run async; we run inline. A code-dev `reviewer-bot-loop` would converge faster (G-CD-E1).

## 6. PR description & changelog generation
- **release-please (Google)** — conventional commits → changelog + version bump.
- **changesets (atlassian-style)** — explicit changelog entries per PR.
- **semantic-release** — fully automated from commit history.

**Take for code-dev:** our `code-dev-changelog` is per-phase; release-please-style version bumping is missing (G-CD-A4 release).

## 7. Stacked rebase + conflict prediction
- **Graphite restack** — heuristic conflict prediction during rebase.
- **gh CLI merge-conflict-base** — pre-merge detection via three-way merge.
- **Mergify** — automated merge-queue with conflict resolution.

**Take for code-dev:** G-CD-C1 (`conflict-predict`) would mirror Graphite's restack-time conflict warning.

## 8. Coverage delta tracking
- **Codecov / Coveralls / Codacy** — diff-aware coverage reporting.
- **diff-cover** — Python tool: coverage on changed lines only.

**Take for code-dev:** test-map could pair with `diff-cover` for coverage-aware suggestions (G-CD-C4).

## 9. Compiled / optimized prompts
- **DSPy** — programs as composable optimizable modules; teleprompter compiles few-shot examples.
- **LMQL / Guidance** — constrained generation DSLs.

**Take for code-dev:** our `.cmp.md` compiled programs are conceptually DSPy-without-optimizer. Adding usage-based optimization would feed back into the compile pipeline (G-CD-B3+B6).

## 10. Session / checkpoint patterns
- **Devin checkpoints** — auto-snapshot project state.
- **Cursor / Aider** — session diffs vs initial state.
- **AXON tag/undo** — our equivalent; v4-only.

**Take for code-dev:** our model is roughly state-of-the-art; gap is integration with kernel checkpoints (cycle 2).

## 11. Library → app handoff (monorepo patterns)
- **Lerna / Nx / Turborepo** — task-graph aware monorepo tools.
- **Bazel** — fully-cached dependency-aware builds.
- **Changesets** (mentioned) — versions propagated across packages.

**Take for code-dev:** G-CD-F1 (library-dev → code-dev handoff) is the natural fit; PR drafts from library findings is novel.

## 12. PR-spec / acceptance-criteria DSLs
- **Cucumber / Gherkin** — Given/When/Then.
- **OpenAI Evals** — model-graded eval suites.
- **Atlassian acceptance-criteria templates**.

**Take for code-dev:** our `acceptance:` + `proof:` lines could grow Gherkin-style structure to drive `suggest-tests` more aggressively.

## Headline takeaways for the next cycles
1. **PR-stack support** is the single biggest missing capability (validated by git-spice / Graphite / Sapling existence).
2. **Reviewer-bot loop** is industry-standard; we're behind on automation.
3. **Embedding-augmented shadow index** would close the gap on Sweep / Cursor file-ranking.
4. **Conventional-commits / release-please-style** version+changelog automation = small effort, high payoff.
5. **Library-dev → code-dev** handoff is novel — our two systems together unlock a "research → spec → PR draft" pipeline absent in prior art.

→ deeper external review in `cd-c2-p4-web-findings.md` and `cd-c4-p4-web-findings.md`.
