# CD·C2·P4 — web findings (depth on stacks, bots, indexing)

> Targeted at gaps surfaced by cycle 2: stacked PRs (G-CD-A3 / W1), reviewer-bot loops (W2), embedding-augmented codebase indexing (W11), and conflict prediction (W7). Plus a deeper read on observed structural patterns.

## 1. Stacked-diff tooling — design notes
### git-spice (`gs`)
- **Model:** every branch knows its *parent*. `gs branch track` builds a stack DAG.
- **Restack:** `gs branch restack` rebases child onto current parent tip. Recursive: `gs stack restack`.
- **Submit:** `gs branch submit` opens a PR, then sets the parent metadata on GitHub.
- **What we can borrow:** the parent-pointer in `_pr-links.md` mirrors this. Add `gs restack`-style cascade.

### Graphite (`gt`)
- **Trunk-based:** stacked PRs always rebase on `main`.
- **Auto-restack:** `gt sync` rebases the whole stack against latest `main`.
- **Track:** `gt log` shows the stack visually; web UI for review queue.
- **What we can borrow:** UI-style render in `code-dev-pr-list` showing the stack tree.

### Sapling (Meta)
- **Smartlog** — graph of working state including local + remote commits.
- **Stack mutation** — commits move between stacks; auto-rebase children.
- **What we can borrow:** the *commit-graph awareness* — code-dev tracks PRs but not commits; pre-merge conflict prediction wants commit-level granularity.

### GitButler
- **Virtual branches** — one working dir, many parallel branches, drag commits.
- **Conflict prediction** — flags two virtual branches editing same lines.
- **What we can borrow:** the conflict-prediction approach (3-way diff vs all open PRs in stack) for W7.

## 2. Agent code-review loops
### Aider's loop
- Edit → diff → linter → tests → confirm.
- *Repo-map* compressed to fit context: ranked symbols + import graph.
- **Take:** our shadow + symbols extraction can be made into a comparable repo-map; pass it whole into `pr-review` P1.

### CodeRabbit / Sweep AI / Sourcery
- Async reviewers on GitHub: ingest PR, run static analyses, comment.
- Use cases dovetail with our reviewer-bot loop (W2 / D-E2).
- **Take:** patterns for review-comment generation are well-explored; we'd integrate via `code-dev pr-respond --reviewer-bot=<name>`.

### Devin's checkpoint model
- Auto-snapshot state after every milestone.
- Resume from any snapshot.
- **Take:** our `code-dev tag` + `_actions.log` is conceptually equivalent; we'd benefit from auto-tagging at gate boundaries (after every successful `preflight`).

## 3. Embedding-augmented codebase indexing
### Sweep AI
- Files chunked, embedded, ranked by issue text.
- File-rank stage filters before expensive LLM reads.
- **Take:** add `shadow embed` operation: write `.findings.md` + `.embed.json`. `plan` and `impact` use the embedding to rank file candidates.

### Cursor codebase indexer
- File-level + symbol-level embedding.
- Real-time re-index on save.
- **Take:** we don't need real-time; we'd re-embed on `shadow refresh` (already a gate).

### Local-only options
- `sentence-transformers` + `faiss` / `hnswlib` — local, deterministic.
- `bm25s` (no model) — pure lexical, much cheaper, still effective for code.
- **Take:** start with `bm25s` (no dependency on a model); upgrade to embeddings later if needed. Keep model-free option for offline/CI.

## 4. Conflict prediction prior art
### Mergify / Conflict-aware merge queues
- Three-way merge against target before queueing; reject if conflict.
- **Take:** our `conflict-predict` could be a pre-merge gate (Gate-11 candidate).

### `git rerere`
- Records resolution; reuses for similar conflicts.
- **Take:** suggest as HUMAN setup in `_profile.md`; cite in docs.

## 5. Spec / acceptance DSLs
### Gherkin (Cucumber)
- Given/When/Then.
- **Take:** our acceptance lines could grow Gherkin-style. `suggest-tests` becomes Gherkin → test-scenario mapper.

### TLA+ / Alloy
- Formal invariants + model checker.
- **Take:** out of scope for a generic OS, but `proof:` lines could be parsed as TLA-lite assertions in a future advanced mode.

## 6. Compaction / resume patterns
### Continue.dev resume
- Persists "state" per project; not as structured as ours.
- **Take:** validates that 10-layer briefing is on the heavy end; a 3-layer "lite resume" for `code-dev next` might be enough.

### Cursor agent / OpenAI Code Interpreter
- Snapshot file + chat; restore both.
- **Take:** our `code-dev tag` doesn't snapshot the codebase; it snapshots project state only. Could optionally bundle a `git stash` reference (HUMAN-confirmed).

## 7. Library → app handoff patterns
### Lerna / Nx / Turborepo
- Task graphs cross-package; downstream re-builds.
- **Take:** code-dev sees one repo at a time. A `code-dev-link` *graph* across projects (already half-built) could surface "downstream needs PR" hints.

### release-please + changesets
- Per-PR machine-readable changelog notes feed into release notes.
- **Take:** integrate with `code-dev-changelog` so every PR emits a `.changeset/` entry.

## 8. Open-source comparable systems
| System              | What they do better                      | What we do better |
|---------------------|------------------------------------------|-------------------|
| Aider               | edits + commits autonomously             | spec/process discipline; reviewer state |
| Cursor              | IDE-tight integration; embedding-aware   | language-agnostic; programmable workflow |
| Sweep AI            | issue → PR; semantic file ranking         | full lifecycle (study → merge) |
| Graphite / git-spice| native stacked diffs                      | nothing yet; gap W1 |
| Devin               | long-running agents; auto checkpoints     | explicit human-only push; safer |
| OpenAI Workspace    | spec → plan → diff UI                     | persistent project + multi-phase |

## Take-aways feeding cycle 3 + 4
1. **bm25s + optional embedding** for `shadow` is a cheap, high-leverage move (W11).
2. **Reviewer-bot loop** is industry-standard — we are notably behind here.
3. **Stacked PRs**: at least the *parent pointer + restack script* (read-only emit) is a small, well-scoped win.
4. **Per-PR changesets** is a tiny addition that pays off hugely at release time.
5. **Auto-tag at gate boundaries** would make `undo` and `tag` much more useful.

→ deepest external review tied to cycle-3 token economy in `cd-c3-p4-web-findings.md`.
