# CD·WF·C4·P2 — concrete roadmap (waves with deliverables)

> Each wave is a PR (or PR-stack). Each is independently shippable. Order chosen for risk minimization.

## Wave 0 — Quality regression gates  (PR-0.1, 0.2, 0.3)

| PR    | Deliverable                                                     | Files touched                  |
|-------|-----------------------------------------------------------------|--------------------------------|
| 0.1   | compile-write regression gate (T-A3)                            | tools/compile-write.py, tests/ |
| 0.2   | Quarantine pr-review.cmp.md until below 95% src size            | workspace/programs/compiled/, dispatch logic |
| 0.3   | Usage instrumentation (D-A2): every program execution → `tools/usage.py` increments | tools/dispatch.py, tools/usage.py |

**Done when:** CI-style gate refuses to land a compiled program > 95% of source.
**Risk:** zero — purely additive.

## Wave 1 — Verb routers  (PR-1.1..1.10)

10 PRs, one per umbrella (independent). Each ships a router program with no behavior change.

| PR     | Router                          |
|--------|---------------------------------|
| 1.1    | `code-dev-lifecycle.md`         |
| 1.2    | `code-dev-state.md`             |
| 1.3    | `code-dev-journal.md`           |
| 1.4    | `code-dev-pr.md`                |
| 1.5    | `code-dev-review.md`            |
| 1.6    | `code-dev-shape.md`             |
| 1.7    | `code-dev-safety.md`            |
| 1.8    | `code-dev-knowledge.md`         |
| 1.9    | `code-dev-flow.md`              |
| 1.10   | `code-dev-meta.md`              |

**Done when:** each router accepts known sub-commands and forwards to existing programs; `axon-audit` clean.
**Risk:** low — old commands continue to work directly.

## Wave 2 — Aggregators  (PR-2.1..2.4)

| PR    | Deliverable                                          |
|-------|------------------------------------------------------|
| 2.1   | `code-dev pr list` — walks `_meta`, prints table     |
| 2.2   | `code-dev meta board` — ASCII Kanban                 |
| 2.3   | `code-dev meta context use <slug>` + context stack   |
| 2.4   | `code-dev state actions [N]` — `_actions.log` reader |

**Done when:** each command runs in ≤ 1 second and shows expected output for axon-master.
**Risk:** low — read-only.

## Wave 3 — CI awareness  (PR-3.1..3.4)

| PR    | Deliverable                                                  |
|-------|--------------------------------------------------------------|
| 3.1   | `tools/parse_check_results.py` — generic JSON→CheckResult    |
| 3.2   | `code-dev pr sync N` — accepts JSON via `--from-file`        |
| 3.3   | `code-dev pr ready N` gates on synced CI state               |
| 3.4   | `code-dev review --mode=coverage` — coverage-delta calculator|
| 3.5   | `code-dev pr suggest-reviewer N` — CODEOWNERS parser        |

**Done when:** end-to-end test: paste `gh pr view --json` → `pr sync` → `pr ready` correctly green/red.
**Risk:** medium — depends on user's build tool emitting JSON.

## Wave 4 — Stubs + lexicon  (PR-4.1..4.5)

| PR    | Deliverable                                                  |
|-------|--------------------------------------------------------------|
| 4.1   | Alias-stubs for 8 retire candidates from Round-3             |
| 4.2   | Rename `tag` → `state save/restore` (stub the old name)      |
| 4.3   | Fold `next` into `state show` footer (`next` still works)    |
| 4.4   | `code-dev meta dry-run` alias for `whatif`                   |
| 4.5   | `code-dev meta cheatsheet [verb]`                            |

**Done when:** all old invocations work, deprecation warnings emit, new lexicon advertised in help.
**Risk:** medium — touches many small files.

## Wave 5 — Spec discipline + packets  (PR-5.1..5.4)

| PR    | Deliverable                                                  |
|-------|--------------------------------------------------------------|
| 5.1   | `code-dev pr drift N` — semantic diff of spec vs diff        |
| 5.2   | `code-dev pr export N` — markdown packet for offline review  |
| 5.3   | `code-dev pr import --from <path>` — bridge from external    |
| 5.4   | `code-dev journal log --redact-secrets` — regex redactor     |

**Done when:** each acceptance test passes; `pr export` produces a single self-contained markdown.
**Risk:** medium — `pr drift` requires careful semantic comparison.

## Wave 6 — Stacked PRs  (PR-6.1..6.5)

| PR    | Deliverable                                                  |
|-------|--------------------------------------------------------------|
| 6.1   | Schema v5: add `stack-id`, `stack-position` to pr-N entries  |
| 6.2   | `code-dev pr stack new`                                      |
| 6.3   | `code-dev pr stack restack`                                  |
| 6.4   | `code-dev pr stack push` (composes commit/push HUMAN plan)   |
| 6.5   | `code-dev pr stack list` — ASCII stack visualizer            |

**Done when:** can declare a 3-PR stack, restack after upstream change, list shows correct order.
**Risk:** highest — new schema fields + new model.

## Cumulative impact

| Wave | New verbs | Deprecated verbs | Schema bump | Net new lines (est) |
|:----:|:---------:|:----------------:|:-----------:|:-------------------:|
| 0    | 0         | 0                | no          | ~200                |
| 1    | 10 routers| 0                | no          | ~1500               |
| 2    | 4         | 0                | minor       | ~800                |
| 3    | 5         | 0                | minor       | ~1500               |
| 4    | 2         | 10 (stubbed)     | no          | ~600 (mostly stubs) |
| 5    | 4         | 0                | minor       | ~1200               |
| 6    | 5         | 0                | major (v5)  | ~2000               |

## Acceptance criteria (cross-wave)

- ✓ Each wave passes `axon-audit` clean.
- ✓ Each wave passes the compile-write regression gate from Wave 0.
- ✓ benchmark-log shows no compression regression > 2%.
- ✓ All deprecated verbs emit single-line WARN.
- ✓ Help/cheatsheet updated atomically with code.
- ✓ Each wave has an entry in CHANGELOG.

## What this roadmap does NOT include

- Team-mode (G-T*): deferred behind toggle.
- Cross-project dependency declaration: low priority.
- IDE/GUI: out of scope.
- Network polling: kernel rule.

→ next study suggestions: `cd-wf-c4-p3-next-study.md`.
