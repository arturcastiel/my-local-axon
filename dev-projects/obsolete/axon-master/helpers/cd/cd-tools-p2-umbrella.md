# CD·TOOLS·P2 — umbrella organization (proposed)

> Concrete proposal: 10 top-level verbs, each routing to sub-commands. The 57 programs become ~49 underneath, with a 1-release alias-stub for retired names.

## Verb-centric surface (proposed)

```
code-dev                       # router — unchanged
code-dev <verb> [subcommand] [args]
```

| Verb        | Subcommands                                          | Programs absorbed |
|-------------|------------------------------------------------------|-------------------|
| `lifecycle` | `new` · `init` · `load` · `tour`                     | new, init, load, tour |
| `state`     | `status` · `next` · `resume` · `handoff` · `metrics` · `save <label>` · `restore <label>` · `undo` | status, next, resume, handoff, metrics, tag, undo |
| `journal`   | `log [entry]` · `decision [ADR]` · `event <kind> <detail>` · `search [query]` · `since` | log, decision, event, search, (since→flag), (replay→search mode) |
| `pr`        | `create N` · `update-spec N` · `link N` · `respond N` · `review N` · `ready N` · `github N` · `import <src>` · `list` · `archive` · `stack <op>` | pr, pr-update-spec, pr-link, pr-respond, pr-review, pr-ready, pr-github, (new: import, list, archive, stack) |
| `review`    | `[N]` (default: scope + self + tests) · `--mode=diff` · `--mode=scope` · `--mode=self` · `--mode=tests` · `--mode=coverage` | review, scope-check, self-review, suggest-tests, (diff→mode) |
| `shape`     | `combine` · `divide` · `partition <op>` · `phase new` · `phase start` · `plan-master` · `link` | combine, divide, partition, phase-new, phase-start, plan-master, link |
| `safety`    | `freeze` · `thaw` · `dont-do <op>` · `preflight [--quick] [--summary] [--gate N]` · `audit [--structure]` | freeze, hold, dont-do, preflight, audit, check-structure |
| `knowledge` | `study` · `shadow <op>` · `explain N` · `impact` · `reviewer-track [--reviewer X] [--history]` | study, shadow, explain, impact, reviewer-track, (explain-reviewer→flag) |
| `flow`      | `plan` · `merge` · `cascade` · `changelog` · `test-map` · `finalize` (new) | plan, merge, cascade, changelog, test-map, (finalize: new) |
| `meta`      | `whatif <cmd>` · `help [verb]` · `actions [N]` (new) | whatif, help, (actions: new) |

## File-system mapping (no breaking change)

Each top-level verb is implemented as a *router* program. Subcommands remain individual files (with new names) or stay as flags inside the router.

```
workspace/programs/
├── code-dev.md                  # main dispatcher (extended verb table)
├── code-dev-lifecycle.md        # router
│   └── code-dev-lifecycle-new.md, -init.md, -load.md, -tour.md  (file renames)
├── code-dev-state.md            # router
│   └── code-dev-state-{status,next,resume,handoff,metrics,save,restore,undo}.md
├── code-dev-journal.md          # router
│   └── code-dev-journal-{log,decision,event,search}.md
├── code-dev-pr.md               # router
│   └── code-dev-pr-{create,update-spec,link,respond,review,ready,github,import,list,archive,stack}.md
├── code-dev-review.md           # mostly a router (already routes 3); add --mode
├── code-dev-shape.md            # router
├── code-dev-safety.md           # router
├── code-dev-knowledge.md        # router
├── code-dev-flow.md             # router
└── code-dev-meta.md             # router
```

Routers are tiny (≤ 1 KB). Compilation gains: 10 routers replace inline dispatch logic in `code-dev.md`, reducing main router size.

## Alias-stubs (1-release backward compatibility)

For every retire-candidate from `cd-tools-p1-inventory.md`, ship a 5-line stub:

```
# PROGRAM: code-dev-combine
# desc:    DEPRECATED — alias for `code-dev shape partition merge`. Removed next release.

EXEC(code-dev-shape-partition --op merge)
LOG(WARN, "code-dev-combine is deprecated — use: code-dev shape partition merge")
```

8 stubs × ~5 lines = 40 lines total. Users see a one-time deprecation warning; muscle memory keeps working.

## Sub-command shape (illustrative)

### `code-dev pr <subcommand>` family

```
code-dev pr create 3                         # was: code-dev pr 3
code-dev pr update-spec 3                     # was: code-dev pr-update-spec 3
code-dev pr link 3 --depends-on 2             # was: code-dev pr-link 3 --depends-on 2
code-dev pr respond 3                         # was: code-dev pr-respond 3
code-dev pr review 3 [--phase N]              # was: code-dev pr-review 3 --phase N
code-dev pr ready 3 [--quick]                 # was: code-dev pr-ready 3
code-dev pr github 3                          # was: code-dev pr-github 3
code-dev pr import --from <path>              # NEW (library-dev bridge)
code-dev pr list [--phase active|all] [--status open|merged|review] # NEW
code-dev pr archive --older-than 90d          # NEW
code-dev pr stack {new|restack|push|list}     # NEW (stacked-PR support)
```

### `code-dev review [N] [--mode=…]`

```
code-dev review                # default: scope+self+tests  (was: code-dev review)
code-dev review --mode=diff    # was: code-dev diff
code-dev review --mode=scope   # was: code-dev scope-check
code-dev review --mode=self    # was: code-dev self-review
code-dev review --mode=tests   # was: code-dev suggest-tests
code-dev review --mode=coverage # NEW (coverage-delta)
```

### `code-dev journal <subcmd>`

```
code-dev journal log [--entry "..."]                # was: code-dev log
code-dev journal decision [ADR-NNN]                  # was: code-dev decision
code-dev journal event <kind> "<detail>"             # was: code-dev event
code-dev journal search "<query>" [--since 7d]      # was: code-dev search / since (--since flag)
code-dev journal search --patterns                   # was: code-dev replay
```

### `code-dev state <subcmd>`

```
code-dev state status            # was: code-dev status
code-dev state next              # was: code-dev next
code-dev state resume            # was: code-dev resume
code-dev state handoff           # was: code-dev handoff
code-dev state metrics           # was: code-dev metrics
code-dev state save <label>      # was: code-dev tag <label>
code-dev state restore <label>   # was: code-dev tag rewind <label>
code-dev state undo              # was: code-dev undo
code-dev state actions [N]       # NEW: _actions.log reader
```

### `code-dev safety <subcmd>`

```
code-dev safety preflight [--quick|--summary|--gate N]   # was: code-dev preflight
code-dev safety audit [--structure]                       # was: code-dev audit / check-structure
code-dev safety freeze [reason]                           # was: code-dev freeze
code-dev safety thaw                                      # was: code-dev hold thaw
code-dev safety dont-do {add|list|retire|promote|demote}  # was: code-dev dont-do
```

### `code-dev knowledge <subcmd>`

```
code-dev knowledge study                                  # was: code-dev study
code-dev knowledge shadow {stats|list|stale|refresh|show|scan|clear}  # was: code-dev shadow
code-dev knowledge explain N                              # was: code-dev explain N
code-dev knowledge impact                                 # was: code-dev impact
code-dev knowledge reviewer-track [--reviewer X --history] # was: code-dev reviewer-track / explain-reviewer
```

## Why 10 verbs and not 5 or 20

- **5 verbs** would collapse too many concerns (e.g. `pr` swallowing `review`); hurts mental model.
- **20 verbs** is barely better than today (just renamed files); no real grouping.
- **10 verbs** matches common CLI design (kubectl, git, gh, docker — all in the 8–15 verb range).

## Naming criteria
- Every verb is a **noun or imperative** (state, journal, pr, review, shape, safety, knowledge, flow, lifecycle, meta).
- Every subcommand is a **single English word** when possible.
- No verb name conflicts with existing top-level (`code-dev <verb>` ≠ existing program prefix).

## Token-economy effects of the proposal

| Item | Before | After |
|------|--------|-------|
| Programs in workspace | 57 source files | 49 source files (+ 8 stubs) |
| Top-level surface  | 57 verbs   | 10 verbs (× ~5 subs each) |
| Main router (`code-dev.md`) | 358 lines, 20 KB | ~250 lines, ~12 KB (sub-routing pushed to verb routers) |
| Sub-routers added | 0          | 10 (each ~100 lines) |
| Net program count | 57 | 49 + 10 routers = 59 (small upward shift in file count) |
| Net source bytes | ~330 KB | ~290 KB (estimated, after deduplication) |
| User-visible verbs | 57 | 10 |

The file count is roughly flat; **the user-visible verb count drops 5.7×**.

## What does NOT change
- Schema v4 (no migration).
- Project file layout under `my-axon/dev-projects/<slug>/`.
- Internal program names — only user-facing CLI verbs change.
- Identity-lock blocks, write gates, shadow contract.
- HUMAN-only git operations.

→ implementation order + risk in `cd-tools-p3-migration.md`.
