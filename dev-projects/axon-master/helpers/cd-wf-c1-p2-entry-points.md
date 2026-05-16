# CD·WF·C1·P2 — entry points & discovery (how to use)

> If a new user opens the project today, what do they type? Today the surface is 57 verbs; discovery requires reading source files.

## Entry-point ladder (today)

| Surface             | What user does          | What they get                            |
|---------------------|-------------------------|------------------------------------------|
| `code-dev` (bare)   | `code-dev`              | dispatcher prints help (varies)          |
| `code-dev help`     | `code-dev help`         | lists ~20 most-used verbs                |
| `code-dev help <v>` | `code-dev help pr-ready`| shows that program's `## HELP` section   |
| `code-dev tour`     | `code-dev tour`         | walks user through 5–7 sample commands   |
| free-text           | "I want to start a PR"  | dispatch.py TF-IDF → suggests `pr`       |
| `code-dev whatif`   | `code-dev whatif "..."` | dry-run a command without executing      |

## Onboarding journey (first 5 turns of a new user)

```
T1: user: "I want to use code-dev"
    → code-dev tour
T2: user: "make a project for my repo at /tmp/foo"
    → code-dev new --slug foo --codebase /tmp/foo
T3: user: "study it"
    → code-dev study
T4: user: "I want to add feature X"
    → code-dev pr 1 --title "Add feature X"
T5: user: "what next?"
    → code-dev next
```

**Issues:**
- T1 — `tour` exists but doesn't appear in the bare `code-dev` output of every program. Users rarely find it.
- T2 — defaults are silent; new users don't know what slug/codebase are.
- T3 — `study` blocks for several turns on large repos; no progress signal.
- T4 — `pr` requires `N` argument; user might type `code-dev pr "Add feature X"` and get an error.
- T5 — `next` suggests verbs (`pr-update-spec`) without explaining when to choose each.

## Discovery surfaces (today)

| Surface          | Discoverable?     | Searchable?         |
|------------------|:-----------------:|:-------------------:|
| Top-level verbs  | yes (`help`)      | partial (TF-IDF)    |
| Verb flags       | partial (`help X`)| no                  |
| Workflows        | NO (only in docs) | no                  |
| Recipes / how-to | NO                | no                  |
| State machine    | NO                | no                  |
| Project artifacts| filesystem only   | grep                |

## Discovery gaps

- **No `examples` command** — `code-dev examples pr` would show real invocations
- **No `wf list`** — no enumeration of named workflows (WF1..WF8)
- **No `wf show pr-lifecycle`** — no per-workflow guided walk-through
- **No global search** — `code-dev search "feedback"` finds journal entries but not programs
- **No state-machine viz** — `code-dev show-state` would show where in WF3 the current PR is

## Proposed entry-point surface (after umbrella rework, Round 3)

```
code-dev                               # prints banner + 10 verbs + "type: code-dev help"
code-dev help [verb]                   # gh-style: lists subcommands of verb
code-dev help workflows                # NEW: lists named workflows (WF1..WF8)
code-dev help workflow pr-lifecycle    # NEW: step-by-step guide for WF3
code-dev examples [verb]               # NEW: real invocations grouped by use case
code-dev tour                          # interactive onboarding (already exists)
code-dev whatif "<prompt>"             # dry-run (already exists)
code-dev meta status                   # NEW: project state ASCII dashboard
```

## How users learn the system today (observed signals)

1. Read source files (`workspace/programs/code-dev*.md`) — high friction
2. Trial-and-error in chat — works but no error recovery hints
3. Read this study and Round-1 study — only because it exists
4. Read AXON-DOCS.md — overview, not workflow-level

**Industrial CLIs solve this with:** man pages, `--help` everywhere, `gh demo`-style interactive demos, cheatsheets in the repo README.

## Cheatsheet (proposed, not yet shipped)

```
NEW PROJECT     : code-dev new --slug foo --codebase /path
RESUME WORK     : code-dev resume        →  code-dev next
START A PR      : code-dev pr create N --title "..."
SELF-REVIEW     : code-dev review --quick
READY TO SHIP   : code-dev pr ready N
RESPOND        : code-dev pr respond N
REVIEW THEIRS   : code-dev pr review N --reviewer
LOG NOTE        : code-dev log "note"
DECISION        : code-dev decision "decided to use X because Y"
SEARCH          : code-dev search "term"
HANDOFF         : code-dev handoff
RECOVER         : code-dev resume        →  code-dev tag rewind <label>
```
→ industrial-gap context in `cd-wf-c2-p1-industrial-gaps.md`.
