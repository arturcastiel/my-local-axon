# CD·WF·C1·P3 — recipe cookbook

> Copy-paste recipes for the 12 most common code-dev tasks. Each recipe is verified against the current program set.

## R1 — First-time setup
```
code-dev new --slug myproj --codebase /path/to/repo
code-dev init
code-dev study              # optional but recommended for unfamiliar code
code-dev tour               # optional onboarding tour
```

## R2 — Resume after a break
```
code-dev resume
code-dev next
code-dev status             # if confused about current state
```

## R3 — Start a PR from a fresh idea
```
code-dev pr 1 --title "Add caching layer" --spec inline
# (HUMAN: write code)
code-dev review --quick
code-dev pr update-spec 1
code-dev pr ready 1
# (HUMAN: git commit; gh pr create)
code-dev pr github 1 --url https://github.com/.../pull/123
```

## R4 — Respond to reviewer feedback
```
# (HUMAN: paste reviewer comments)
code-dev pr respond 1
# (HUMAN: implement requested changes)
code-dev pr update-spec 1
code-dev pr ready 1
# (HUMAN: git push)
```

## R5 — Multi-PR phase
```
code-dev phase new "Phase 3: observability"
code-dev plan-master
# Review the generated plan
code-dev phase start 3
# For each PR (1..N): run R3
code-dev cascade           # propagate shared changes across PRs
code-dev merge             # ordered merge plan
code-dev changelog         # compose CHANGELOG entry
```

## R6 — Review a teammate's PR
```
code-dev pr review 42
code-dev scope-check 42
code-dev reviewer-track --reviewer alice --history
# (HUMAN: write review comments)
```

## R7 — Log a decision (ADR)
```
code-dev decision "use redis for session store because of X"
# Auto-numbered ADR-NNN added to my-axon/dev-projects/<slug>/decisions/
```

## R8 — Pause / handoff
```
code-dev handoff           # composes resumable summary
code-dev freeze "waiting for backend team"
# (later, when ready)
code-dev hold thaw
code-dev resume
```

## R9 — Recover from a bad direction
```
code-dev tag rewind <label>     # restore named checkpoint
code-dev undo                   # undo last action
code-dev dont-do add "don't add new dependencies"
```

## R10 — Predict impact before changing code
```
code-dev impact <file_or_dir>
code-dev shadow show <file>     # cached invariants
```

## R11 — Explain something to a reviewer
```
code-dev explain 42 --section "tests"
code-dev reviewer-track --reviewer bob --history
```

## R12 — Free-text dispatch (when unsure)
```
code-dev "I want to start reviewing PR 42"
code-dev whatif "I want to start reviewing PR 42"     # dry-run first
```

## Recipe categories
- **Setup:** R1
- **Resume:** R2
- **Single-PR loop:** R3, R4, R7
- **Multi-PR loop:** R5
- **Reviewing others:** R6, R11
- **Safety / recovery:** R8, R9
- **Reasoning aids:** R10
- **Open-ended:** R12

## What's missing from this cookbook
- Recipe for *coverage delta before/after a PR* — no current support (C3)
- Recipe for *list all in-flight PRs* — no aggregator (C1)
- Recipe for *stacked PRs* — no support (C8 / Round-3 proposal)
- Recipe for *exporting a PR packet to share offline* — no support
- Recipe for *cross-project bookkeeping* (one dev with 3 projects) — `code-dev list-projects` half-exists via state, not surfaced
- Recipe for *integrating with team-chat / Slack* — out of scope today
- Recipe for *converting an old chat thread into a project* — partial via `code-dev load`
- Recipe for *bisecting a regression with code-dev help* — none

→ what an industrial team would expect: `cd-wf-c2-p1-industrial-gaps.md`.
