# CD·WF·C3·P3 — categories and umbrella definitions

> Tightens the 10 verb-umbrellas from Round-3 with explicit boundaries, one-line descriptions, and the rationale for each.

## Final 10 umbrellas — definition card

### 1. `lifecycle` — start, load, learn the project
- **Owns:** project creation, initialization, codebase tour, loading existing projects.
- **Sub-commands:** `new`, `init`, `load`, `tour`.
- **One-line desc (for dispatch):** "create or open a code-dev project; learn the basics."
- **Not:** anything that happens *after* the project is alive.

### 2. `state` — current situation, navigation, time-travel
- **Owns:** "where am I, what's next, save/restore, undo".
- **Sub-commands:** `show` (status), `next`, `resume`, `handoff`, `metrics`, `save`, `restore`, `undo`, `actions` (NEW).
- **One-line desc:** "inspect, navigate, and snapshot project state."
- **Not:** modifying content (that's other verbs).

### 3. `journal` — append-only history
- **Owns:** logs, decisions (ADRs), events, search across all of the above.
- **Sub-commands:** `log`, `decision`, `event`, `search`.
- **One-line desc:** "record and query a project's append-only history."
- **Not:** state mutation (that's `state` or `safety`).

### 4. `pr` — pull-request lifecycle
- **Owns:** PR specs, updates, links, responses, reviews of one's own PR, ready checks, GitHub sync, list/archive, stacks.
- **Sub-commands:** `create`, `update-spec`, `link`, `respond`, `review`, `ready`, `sync`, `import`, `export`, `list`, `show`, `archive`, `stack`, `drift`, `suggest-reviewer`.
- **One-line desc:** "everything about a single pull request, from spec to merge."
- **Not:** reviewing *others'* code in the abstract (that's `review` top-level).

### 5. `review` — code-review modes
- **Owns:** generic review actions (scope, self, tests, diff, coverage).
- **Sub-commands:** `--mode=scope|self|tests|diff|coverage` (single-verb with modes).
- **One-line desc:** "run a code review pass on the current branch or diff."
- **Not:** reviewing someone else's pinned PR (that's `pr review N`).
- **Rationale for separate verb:** the "I'm reviewing now" intent is distinct from "I'm operating on PR-N".

### 6. `shape` — project structure
- **Owns:** phases, partitions (split/merge of plan items), inter-item links.
- **Sub-commands:** `phase {new|start}`, `partition {split|merge}`, `link`, `plan-master` (under `--epic`).
- **One-line desc:** "structure and restructure work items: phases, partitions, links."
- **Not:** day-to-day work (that's `flow`).

### 7. `safety` — gates, rules, freezes
- **Owns:** freeze/thaw, dont-do rules, preflight, audit (incl. structural).
- **Sub-commands:** `freeze`, `thaw`, `rule {add|list|retire|promote|demote}`, `preflight`, `audit`.
- **One-line desc:** "guards, gates, and explicit prohibitions."
- **Not:** PR-ready checks (those live under `pr ready`, *which delegates* to safety checks).

### 8. `knowledge` — codebase understanding
- **Owns:** study, shadow (cached invariants), impact, explain, reviewer-track.
- **Sub-commands:** `study`, `shadow`, `impact`, `explain`, `reviewer-track`.
- **One-line desc:** "build and use a model of the codebase."
- **Not:** journal events (that's `journal`).

### 9. `flow` — multi-PR / multi-phase coordination
- **Owns:** plan, merge, cascade, changelog, test-map, finalize.
- **Sub-commands:** `plan [--epic]`, `merge`, `cascade`, `changelog`, `test-map`, `finalize`.
- **One-line desc:** "coordinate work across multiple PRs and phases."
- **Not:** single-PR ops (those are in `pr`).

### 10. `meta` — about code-dev itself
- **Owns:** help, dry-run, cheatsheet, board (Kanban), all-prs, context-switch.
- **Sub-commands:** `help`, `dry-run` (alias: `whatif`), `cheatsheet`, `board`, `all-prs`, `context use <slug>`.
- **One-line desc:** "tools about the code-dev tool: help, dry-runs, dashboards."
- **Not:** any in-project work.

## Boundary tests (resolves typical disputes)

| Question                                          | Verb          | Why                                     |
|---------------------------------------------------|---------------|-----------------------------------------|
| "Where am I?"                                     | `state show`  | situational                             |
| "What does PR-3 say?"                             | `pr show 3`   | per-PR                                  |
| "List my open PRs"                                | `pr list`     | per-PR aggregator                       |
| "List my open PRs across all projects"            | `meta all-prs`| cross-project                           |
| "What does this codebase do?"                     | `knowledge study` | codebase model                       |
| "What did I decide?"                              | `journal search --kind=decision` | historical    |
| "Run all gates before push"                       | `pr ready N`  | per-PR gate                             |
| "Lock the project, I'm done for today"            | `safety freeze`| temporary halt                         |
| "Stop suggesting X"                               | `safety rule add` | persistent prohibition              |
| "How long do PRs take on average?"                | `state metrics`| project-scoped stats                   |
| "Show the Kanban"                                 | `meta board`  | dashboard                               |

## Umbrella desc-lines for `help` listing

```
code-dev <verb>          one-line desc
─────────────────────────────────────────────────────────────────────
lifecycle   create or open a code-dev project; learn the basics
state       inspect, navigate, and snapshot project state
journal     record and query a project's append-only history
pr          everything about a single pull request, from spec to merge
review      run a code review pass on the current branch or diff
shape       structure and restructure work items: phases, partitions, links
safety      guards, gates, and explicit prohibitions
knowledge   build and use a model of the codebase
flow        coordinate work across multiple PRs and phases
meta        tools about the code-dev tool: help, dry-runs, dashboards
```

These desc-lines also feed dispatch.py (TF-IDF features), so free-text prompts route accurately.

→ external naming validation: `cd-wf-c3-p4-web-findings.md`.
