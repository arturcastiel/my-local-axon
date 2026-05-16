# CD·WF·C2·P4 — web findings (industrial workflow tooling)

> Distilled patterns from industrial code-review/CI tools, mapped to code-dev gaps.

## Tool 1 — Graphite (`gt`)

- Verb surface: `gt branch`, `gt stack`, `gt repo`, `gt log`, `gt pr`, `gt user`.
- Stacked PRs are the *primary* abstraction.
- `gt submit` pushes the entire stack as a series of PRs.
- `gt restack` re-bases a stack after upstream merge.

**Borrow:** Round-3's `code-dev pr stack {new|restack|push|list}` is directly Graphite-inspired. Add `gt log`-style ASCII stack viz to `pr list`.

## Tool 2 — Aviator (chromium-style flow)

- "MergeQueue": serializes merges to ensure each PR is tested *after* the previous one merges.
- `av pr` family handles patch-series.
- Emphasis on **fast-forward only**, no merge commits.

**Borrow:** the *concept* — `code-dev merge` could enforce a queue model when planning a phase merge.
**Skip:** the actual merge-bot (HUMAN-only git).

## Tool 3 — Reviewable / Phabricator-style review

- Stateful review threads (per comment, mark "addressed" / "discussion" / "blocking").
- Resolution tracked across diff iterations.

**Borrow:** `code-dev pr respond N` should track thread state, not just paste a wall of comments.

## Tool 4 — release-please (Google)

- Reads conventional-commit history → composes CHANGELOG → opens release PR.
- Fully automatic.

**Borrow:** `code-dev changelog` already exists; add `--from-commits` mode that parses git log (HUMAN provides log output).

## Tool 5 — `gh` (GitHub CLI)

- One-liner for everything: `gh pr create --title "..." --body "..."`.
- `gh pr status` shows your in-flight PRs.
- Compose-friendly: `gh pr list --json | jq ...`.

**Borrow:** `code-dev pr list` should accept `--json` for piping.
**Borrow:** `code-dev pr status` (alias for `pr list --mine`).

## Tool 6 — `codecov` / `coverage.py`

- Standard format for coverage JSON.
- Per-file delta on PR.
- Threshold gates.

**Borrow:** `code-dev review --mode=coverage` reads `coverage.json`, computes delta against `_meta.coverage-baseline`.

## Tool 7 — `gitleaks` / `trufflehog`

- Pre-commit / pre-push secret scans.
- JSON output.

**Borrow:** `code-dev pr ready` can optionally invoke (or parse output of) such tools.
**Note:** HUMAN runs the scanner; code-dev parses the JSON.

## Tool 8 — Linear (project tracker)

- Cycles (= phases), with progress bars.
- `linear issue list` and a Kanban board.
- Each issue has owner, status, cycle, project, priority.

**Borrow:** `_meta.pr-N.priority`, `_meta.pr-N.status` fields. `code-dev meta board` renders Kanban.

## Tool 9 — Sapling SCM (Meta)

- Treats commits as patches; stacks are first-class.
- `sl absorb` pushes commits into the right ancestor.

**Borrow:** the *philosophy* (stack-first). The `absorb` model maps cleanly onto code-dev's PR-respond loop ("which prior PR should this fix go into?").

## Tool 10 — Conventional Commits + commitlint

- Structured commit messages enable downstream automation.

**Borrow:** `code-dev pr ready` can validate the proposed commit message format from `_meta.pr-N.title`.

## Patterns to AVOID

- **PR templates that require 20 fields** — Round-3 cuts this; favor inferable defaults.
- **Mandatory reviewer assignment** — flexible suggestions only.
- **Auto-merge** — violates HUMAN-only rule.
- **Network polling loops** — kernel single-shot execution.

## Cross-tool naming-style alignment

| Concept                    | gh    | gt    | sl    | linear  | proposed code-dev |
|----------------------------|-------|-------|-------|---------|------------------|
| list things                | list  | list  | log   | list    | `list`           |
| show one                   | view  | info  | show  | view    | `show`           |
| create                     | create| new   | new   | create  | `create`         |
| update                     | edit  | edit  | amend | edit    | `update`         |
| delete / close             | close | rm    | hide  | delete  | `delete` (rare)  |
| archive                    | (n/a) | (n/a) | obsolete | archive | `archive`     |
| sync to remote             | (n/a) | sync  | pull  | sync    | `sync`           |

→ Round 4 layer-3 dives into naming: `cd-wf-c3-p1-name-collisions.md`.
