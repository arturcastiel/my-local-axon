# CD·WF·C1·P4 — web findings (workflow design patterns)

> External patterns relevant to code-dev workflow design — distilled from CLI / dev-workflow literature.

## Pattern 1 — "Just type X" onboarding (Heroku, Vercel, Stripe CLI)

Heroku's onboarding mantra is **"just type `heroku create`"**. The first command does enough useful work that users see value without reading docs.

**Today in code-dev:** `code-dev new --slug ... --codebase ...` requires 2 named flags before doing anything. Friction.
**Borrow:** detect cwd as codebase, derive slug from folder name → `code-dev new` becomes one word.

## Pattern 2 — Verb-noun consistency (`gh issue list`, `gh pr view`)

Across all `gh` verbs the subcommands are the same lexicon: `list`, `view`, `create`, `edit`, `close`, `delete`. Users predict the next command without help.

**Today in code-dev:** every cluster invents its own verbs (`pr-update-spec`, `phase-new`, `tag rewind`, `hold thaw`). No shared vocabulary.
**Borrow:** define a shared sub-verb lexicon (`list`, `show`, `create`, `update`, `delete`, `archive`, `replay`) and reuse across verbs.

## Pattern 3 — Workflow-first docs (Stripe, Twilio quickstarts)

Both companies' top-rated docs are **task-oriented** ("send your first SMS") not API-oriented ("Message resource fields"). Users adopt faster.

**Today in code-dev:** docs are program-oriented (one section per program). No workflow-oriented intro.
**Borrow:** ship `workspace/AXON-DOCS-WORKFLOWS.md` enumerating WF1..WF8 with full transcripts.

## Pattern 4 — State-machine awareness (`git status` golden output)

`git status` tells you *exactly* what to do next: "untracked files, use git add". State-machine is exposed in human-readable form.

**Today in code-dev:** `status` exists but is terse and doesn't say "next, type X". `next` exists separately. Two commands, one purpose.
**Borrow:** merge into `code-dev status` with explicit "TO PROCEED:" footer (like `git status`).

## Pattern 5 — Resumable state across sessions (kubectl context, gh repo set-default)

Industrial tools persist user context (current cluster, current repo) so subsequent commands don't repeat it.

**Today in code-dev:** `W:code-dev-project` is persistent — already there. Good.
**Gap:** no `code-dev context use <slug>` to switch between active projects. Users have to call `code-dev load`.

## Pattern 6 — Dry-run before destructive ops (terraform plan, kubectl --dry-run)

Standard pattern: `plan` before `apply`. Lowers fear of trying commands.

**Today in code-dev:** `whatif` provides this — well-designed but underused.
**Borrow:** make `whatif` the default for first invocation of unknown verbs (toggle via prefs).

## Pattern 7 — Audit log + replay (Datadog audit trail, AWS CloudTrail)

Production systems record every action. Replay supports incident investigation.

**Today in code-dev:** `_actions.log` is partial (program-level). `replay` exists but unstable.
**Borrow:** structured JSONL `_actions.log` per project + `code-dev journal replay --since 7d`.

## Pattern 8 — Templates (cargo init --lib vs --bin, gh repo create --template)

CLIs let users pick scaffolds for different shapes.

**Today in code-dev:** every project gets the same scaffold.
**Borrow:** `code-dev new --template {python-lib,python-cli,ts-pkg,axon-program-set}`.

## Pattern 9 — Cheatsheet built into the binary (`tldr` / `bat --tldr`)

Every modern CLI ships a cheatsheet. Discoverable, scannable.

**Today in code-dev:** no `code-dev cheatsheet`. Users assemble their own.
**Borrow:** add `code-dev meta cheatsheet [verb]` returning 12 most common invocations.

## Pattern 10 — Progress signals for long-running ops (cargo build, docker pull)

Multi-step ops emit progress bars or step counters. Reduces "is it stuck?" perception.

**Today in code-dev:** `study` and `plan-master` block for many turns silently.
**Borrow:** stream "step 3 of 7" markers; let `code-dev status` show progress mid-flight.

## Pattern 11 — Stacked diffs / patch series (`gt stack`, `git absorb`, `jj`)

Modern teams use stacked PRs. Graphite, Aviator, Sapling all support this.

**Today in code-dev:** no stack model. `pr-link --depends-on` is partial.
**Borrow:** `code-dev pr stack {new|restack|push|list}` — exactly the Round-3 proposal.

## Pattern 12 — Bi-directional sync with GitHub/GitLab (gh, glab)

`gh pr view` reads PR status from GitHub. `gh pr merge` writes back.

**Today in code-dev:** `pr github` stores a URL but doesn't read PR status, comments, or check runs. One-way.
**Borrow:** `code-dev pr sync N` polls GitHub for status, fetches new comments → feeds into `pr respond`.

## Pattern 13 — Project graph / dashboard (Linear, Notion projects, Jira boards)

Modern tools show a **board** of work items with status columns.

**Today in code-dev:** no dashboard. Users read text files.
**Borrow:** `code-dev meta board` → ASCII Kanban (in-spec / coding / review / merged) using `pr list` data.

## Patterns NOT to borrow
- IDE plugins (out of scope; we're a markdown-based system).
- Real-time collaboration (multi-user simultaneous edit — kernel single-actor model).
- GUI (we're terminal/chat first).
- Auto-merge bots (HUMAN-only git policy).

→ which gaps to close first: `cd-wf-c2-p1-industrial-gaps.md`.
