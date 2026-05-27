# CD·STUDY·C2·P4 — integration with existing gates and surfaces

> How study modes and plan modes plug into `pr ready`, `state next`, `safety preflight`, `meta board`, and the broader workflow.

## Integration matrix

| Surface             | What it reads                          | What it does with study/plan output |
|---------------------|----------------------------------------|--------------------------------------|
| `state show`        | `study/_index.md`                      | Reports last study per mode, staleness flags |
| `state next`        | `study/_index.md`, `_meta`, `_actions` | Suggests next study mode by heuristics |
| `pr ready N`        | `study/security.md`, `study/tests.md` (if PR touches relevant areas) | Warns or blocks on stale study |
| `pr ready --strict` | Same                                   | BLOCKS on stale study                |
| `pr review N`       | `study/dataflow-*.md` (matched to PR diff) | Surfaces relevant dataflow trace |
| `safety preflight`  | `study/security.md`, `study/dependencies.md` | Cross-checks gates against findings |
| `safety audit`      | `study/_index.md`                      | Confirms all expected studies exist  |
| `flow plan`         | `study/*.md` + `_meta.goals` + `safety/rules.md` + `journal/decisions/*.md` | Emits 02-prs.md per mode |
| `flow merge`        | `study/dependencies.md`                | Warns of breaking dep changes        |
| `flow cascade`      | `study/api-surface.md`                 | Identifies PRs needing API alignment |
| `flow changelog`    | `study/api-surface.md`, `study/dependencies.md` | Emits CHANGELOG with deltas |
| `flow finalize`     | All studies                            | Final ship gate (G-I7 from R4)       |
| `meta board`        | `_index.md`                            | Shows "studies fresh / stale" column |
| `meta context use`  | per-project `study/`                   | Switches project context             |

## Staleness model

A study is `fresh` if:
- last-run-timestamp > codebase-mtime
- AND last-run-timestamp > 30d ago (default; configurable per mode)

A study is `stale` if:
- codebase touched relevant files after last run
- OR last run > stale-threshold

A study is `missing` if:
- no entry in `_index.md`

Surfaces that act on this:
- `state next` — surfaces missing/stale as suggestions
- `pr ready` — warns on stale studies relevant to the PR
- `pr ready --strict` — blocks on stale studies relevant to the PR
- `meta board` — column / icon

## Relevance heuristic ("which studies does this PR need?")

```
PR diff touches files matching patterns:
  src/auth/**        → requires fresh security study
  src/db/**          → requires fresh data-model study
  src/api/**         → requires fresh api-surface study
  **/test_*.py       → requires fresh tests study
  requirements*.txt  → requires fresh dependencies study
  src/hot/**         → requires fresh performance study  (if labeled hot)
```

Patterns declared in `workspace/study-rules/relevance.md` (overridable per project).

## Failure modes & gates

### F-1. Study mode exceeds token budget
- HALT mid-run.
- Emit partial output to `study/<mode>.partial.md`.
- `_index.md` marks the mode `partial`.
- HUMAN can re-run with `--target=<narrower-scope>`.

### F-2. Study reads stale codebase (HUMAN edited files mid-run)
- Detect via mtime check pre/post.
- Warn in output header.

### F-3. Plan output exceeds budget
- `--budget` enforces.
- Deferred items written to `02-prs.deferred.md`.

### F-4. Plan finds contradiction
- Two rules conflict.
- HALT with QUERY back to user.

### F-5. Study finds critical issue
- Plan must include a PR for it (cannot defer).
- `--strict` enforces.

## Integration with `code-dev journal`

- Each study run logs: `journal event study.<mode> <target> <duration> <token-usage>`.
- Each plan run logs: `journal event plan.<mode> <pr-count> <budget>`.
- `journal search --kind=study --since=30d` returns the study history.
- `journal search --kind=plan` returns prior plan invocations.

## Integration with `code-dev meta cheatsheet`

`code-dev meta cheatsheet study` output (proposed):

```
CODEBASE STUDY MODES
  knowledge study --mode=overview            broad map (default)
  knowledge study --mode=security            OWASP-style surface
  knowledge study --mode=performance         hot paths
  knowledge study --mode=tests               coverage + gaps
  knowledge study --mode=dependencies        BOM + vulns
  knowledge study --mode=dataflow --from --to  trace a value
  knowledge study --recipe=new-repo-onboarding   full ramp-up
  knowledge study --diff --since-last        what changed
  knowledge study --suggest-next             pick next mode

PLAN MODES
  flow plan                                   execution mode (default)
  flow plan --mode=risk-first
  flow plan --mode=budgeted --budget 5
  flow plan --mode=constrained --rule "..."
  flow plan --multi-dev 3
  flow plan --replay                          annotate prior plan
  flow plan --dry                             preview only
```

## File-system impact (summary)

```
my-axon/dev-projects/<slug>/
├── _meta.md
├── 01-study.md           # KEEP as executive summary (auto-composed from study/_index.md)
├── 02-prs.md             # plan output (current)
├── 02-prs.deferred.md    # NEW: budgeted-mode overflow
├── 03-plan.md            # plan-master / --epic
├── 04-log.md
├── study/                # NEW directory
│   ├── _index.md
│   ├── overview.md
│   ├── security.md
│   ├── performance.md
│   ├── tests.md
│   ├── dependencies.md
│   ├── api-surface.md
│   ├── data-model.md
│   ├── dead-code.md
│   ├── naming.md
│   ├── observability.md
│   ├── error-handling.md
│   ├── history.md
│   ├── dataflow-<query>.md
│   └── subsystems/
│       └── <name>.md
└── safety/
    └── rules.md           # consumed by plan; existing under another name today
```

→ Layer 3: detailed plan-mode design + outputs: `cd-study-c3-p1-plan-modes.md`.
