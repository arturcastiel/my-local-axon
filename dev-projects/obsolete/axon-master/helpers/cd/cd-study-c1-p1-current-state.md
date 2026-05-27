# CD·STUDY·C1·P1 — what `code-dev study` does today

> Forensic look at the current `study` and `plan` programs before proposing modes.

## Today's `code-dev study`

**Source:** `workspace/programs/code-dev-study.md` (and any compiled variant).

**Surface:**
```
code-dev study              # walks the codebase, writes 01-study.md
```

**Behavior (today):**
1. Reads the codebase root recorded in `_meta.codebase`.
2. Enumerates top-level directories.
3. Identifies subsystem boundaries by folder layout heuristics.
4. Writes/overwrites `my-axon/dev-projects/<slug>/01-study.md` with:
   - "Subsystems" section (one per top folder).
   - "Hot files" (heuristic: largest files, root-level configs).
   - "Open questions" (terse).
5. STORE(W:code-dev-last-study, <timestamp>).

**Output coupling:** single file (`01-study.md`). Subsequent programs read it for context.

## What it doesn't do

| Missing                                  | Impact                                   |
|------------------------------------------|------------------------------------------|
| No depth control (shallow vs deep)       | Always same effort regardless of repo size |
| No mode (overview vs security vs perf)   | Generic output regardless of need        |
| No incremental update                    | Overwrites every run                     |
| No multi-file output                     | Big codebases blow out 01-study.md       |
| No question-driven mode                  | User can't say "study only the auth"     |
| No checkpoint per subsystem              | Crash mid-run loses progress             |
| No diff vs prior study                   | "What changed since last study?" — N/A   |
| No timing / token budget                 | Can blow context window silently         |
| No export                                | Output is only readable inside the project |
| No "what to study next?" suggestion      | User must invent follow-up               |

## Today's `code-dev plan`

**Source:** `workspace/programs/code-dev-plan.md` + `plan-master.md`.

**Surface:**
```
code-dev plan                    # composes a PR plan from 01-study + 02-prs
code-dev plan-master             # epic-level multi-phase plan
```

**Behavior (today):**
- `plan`: reads `01-study.md` + journaled decisions + open issues, produces `02-prs.md` with proposed PRs (priorities, dependencies, scopes).
- `plan-master`: top-down decomposition for an epic; emits multi-phase plan.

**Modes today:** none. Single canonical output shape.

## What `plan` doesn't do

| Missing                                                      |
|--------------------------------------------------------------|
| No "exploratory mode" vs "execution mode"                    |
| No risk-first / impact-first re-prioritization               |
| No size-budgeted output ("only 5 PRs fit this sprint")        |
| No "what-if I have only 1 dev / 3 devs?" mode                |
| No constraint-driven mode (e.g. "no schema changes allowed") |
| No alignment-mode (rank by stated project goals)             |
| No cost-mode (rank by token / time cost)                     |
| No mode for legacy migration / brownfield                    |
| No mode for greenfield (new repo)                            |
| No replay-mode (regenerate plan from prior decisions)        |

## Cross-references

- `01-study.md` ← produced by `code-dev study`
- `02-prs.md` ← produced by `code-dev plan` (after consulting 01-study)
- `03-plan.md` ← produced by `code-dev plan-master` (epic shape)
- `04-log.md` ← journal (read by both study and plan during incremental update)

## What we want from R5

The user said: "*plan modes, suggestions of studies for code*". Concretely:

1. **Study modes** — multiple kinds of study (security, perf, dependency, test-coverage, API-surface, naming, dead-code, performance, accessibility, observability, dataflow, error-handling).
2. **Plan modes** — multiple kinds of plan (exploratory, execution, risk-first, budgeted, constrained, multi-dev, replay).
3. **"What to study next?"** — after one study, code-dev should suggest the next study.
4. **Output discipline** — break study output into multiple files; checkpoint per subsystem; diff vs prior.
5. **Integration with workflow** — study modes feed plan modes; plan modes feed PR creation.

## Constraint set (inherited)

- AXON HUMAN-only git rule still applies.
- Kernel single-actor model.
- No network polling in programs themselves.
- Markdown is the medium.
- Output should reduce, not inflate, the context window.

→ taxonomy of study modes: `cd-study-c1-p2-modes-taxonomy.md`.
