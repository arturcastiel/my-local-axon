# CD·WF·C1·P1 — canonical workflows (what to do)

> The 8 happy paths users follow with code-dev today, mapped step-by-step. Source: actual program contents under `workspace/programs/code-dev*.md`, the v4 schema, and observed `_actions.log` patterns.

## Workflow inventory

| ID  | Workflow                              | Trigger                  | Typical duration |
|-----|---------------------------------------|--------------------------|------------------|
| WF1 | Bootstrap a new dev project           | "start project X"        | 1 turn           |
| WF2 | Daily resume + next step              | "resume" / "next"        | 1 turn           |
| WF3 | Define + ship a single PR             | "PR for feature Y"       | 5–15 turns       |
| WF4 | Multi-PR phase (epic)                 | "plan phase 2"           | 10–40 turns      |
| WF5 | Code review (incoming)                | "review PR N"            | 1–3 turns        |
| WF6 | Reviewer-feedback respond loop        | "respond to feedback"    | 3–8 turns        |
| WF7 | Discovery / study an unknown codebase | "study"                  | 1–5 turns        |
| WF8 | Drop-in handoff                       | "handoff" / "freeze"     | 1 turn           |

## WF1 — Bootstrap a new dev project
```
1. user: "start dev project axon-redesign at /path/to/repo"
2. code-dev new  → creates my-axon/dev-projects/<slug>/{_meta,01-study,02-prs,03-plan,04-log}.md
3. code-dev init → STORE(W:code-dev-project), sets last-program, writes _actions.log header
4. code-dev study (optional) → walks codebase, writes 01-study.md
5. → arrives at "phase 1, ready for first PR plan"
```
Gaps: no template selection (data-pipeline vs library vs cli all get same scaffold).

## WF2 — Daily resume
```
1. user: "resume" / "where was I"
2. code-dev resume  → reads _meta.last-program, _actions.log tail, prints state
3. code-dev next    → suggests next 1–3 actions based on state machine
4. user picks one OR types prompt → dispatch finds matching program
```
Gaps: `next` suggests verbs, not concrete next *artifacts*. Users still have to remember which PR is in-flight.

## WF3 — Single PR lifecycle (the core loop)
```
1. code-dev pr create N --title "..." --spec inline
2. user: implement code in the codebase (HUMAN task)
3. code-dev review N --quick      → self-review checklist
4. code-dev pr update-spec N      → fold late changes into spec
5. code-dev pr ready N            → preflight gate (lint, test ref, ADRs, scope)
6. HUMAN: git commit, push, open PR on GitHub
7. code-dev pr github N --url https://github.com/.../pull/123 → records URL
8. (later) code-dev pr respond N  → integrate reviewer feedback into PR-N
9. (later) HUMAN: merge → code-dev pr archive N (proposed)
```
**This is THE workflow most users run.** Currently spans 9 distinct programs.

## WF4 — Multi-PR phase (epic)
```
1. code-dev phase new "Phase 2: caching layer"
2. code-dev plan-master   → decomposes into PR-2.1, 2.2, 2.3...
3. code-dev phase start 2
4. for each pr in phase:
     run WF3 (PR lifecycle)
5. code-dev cascade       → propagates shared changes across in-flight PRs
6. code-dev merge         → merge sequence + integration check
7. code-dev changelog     → composes CHANGELOG entry from phase
```
Gaps: no progress bar (3/7 PRs merged), no phase dashboard.

## WF5 — Incoming code review
```
1. code-dev pr review N           → routes to: scope-check + self-review + suggest-tests
2. user iterates with comments
3. code-dev reviewer-track --reviewer alice --history  → learn this reviewer's style
4. (during review) code-dev explain N --section foo  → produce reviewer-targeted explanation
```
Gaps: no separation between "I'm reviewing someone else's PR" vs "self-review my own".

## WF6 — Respond-to-feedback loop
```
1. user pastes reviewer comments
2. code-dev pr respond N
3. → categorizes comments (nit / suggestion / blocker / question)
4. → groups responses, suggests code changes
5. → user implements; back to WF3 step 4 (update-spec)
```
Gaps: no thread tracking (comment-1 fixed by commit-abc, comment-2 declined w/ reason).

## WF7 — Codebase study
```
1. code-dev study  → walks codebase tree, identifies subsystems
2. → updates 01-study.md with module map
3. code-dev shadow scan  → cache invariants + hot files
4. code-dev impact <change>  → predict blast radius before touching
```
Gaps: study output is single file (01-study.md); for large codebases users want per-subsystem study notes — that's exactly what we're doing manually in `helpers/`.

## WF8 — Handoff / pause
```
1. code-dev handoff   → composes "where I left off" doc
2. code-dev freeze [reason]  → halts writes, locks state
3. code-dev tag <label>      → checkpoint snapshot
4. (later) code-dev hold thaw / code-dev tag rewind <label>
```
Gaps: handoff text is for humans; no machine-readable "resumable state" export.

## Coverage map: programs ↔ workflows

| Program             | WF1 | WF2 | WF3 | WF4 | WF5 | WF6 | WF7 | WF8 |
|---------------------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| new / init          | ✓   |     |     |     |     |     |     |     |
| status / resume / next |  | ✓   | ✓   | ✓   |     |     |     | ✓   |
| pr (create)         |     |     | ✓   | ✓   |     |     |     |     |
| pr-update-spec      |     |     | ✓   |     |     | ✓   |     |     |
| pr-ready            |     |     | ✓   | ✓   |     |     |     |     |
| pr-github           |     |     | ✓   |     |     |     |     |     |
| pr-respond          |     |     |     |     |     | ✓   |     |     |
| pr-review           |     |     |     |     | ✓   |     |     |     |
| review (sub-router) |     |     | ✓   |     | ✓   |     |     |     |
| scope-check         |     |     | ✓   | ✓   | ✓   |     |     |     |
| self-review         |     |     | ✓   |     |     |     |     |     |
| suggest-tests       |     |     | ✓   |     |     |     |     |     |
| plan / plan-master  |     |     |     | ✓   |     |     |     |     |
| phase-new / start   |     |     |     | ✓   |     |     |     |     |
| merge / cascade     |     |     |     | ✓   |     |     |     |     |
| changelog           |     |     |     | ✓   |     |     |     |     |
| study               | ✓   |     |     |     |     |     | ✓   |     |
| shadow              |     |     |     |     |     |     | ✓   |     |
| impact              |     |     | ✓   |     |     |     | ✓   |     |
| explain             |     |     |     |     | ✓   | ✓   |     |     |
| reviewer-track      |     |     |     |     | ✓   | ✓   |     |     |
| handoff / freeze    |     |     |     |     |     |     |     | ✓   |
| tag                 |     |     | ✓   |     |     |     |     | ✓   |
| audit / preflight   |     |     | ✓   | ✓   | ✓   |     |     |     |
| dont-do             | ✓   | ✓   | ✓   | ✓   | ✓   | ✓   | ✓   | ✓   |
| log / decision / event |  |     | ✓   | ✓   |     |     |     |     |
| search / since      |     | ✓   |     |     |     |     |     |     |
| help / whatif       | ✓   | ✓   | ✓   | ✓   | ✓   | ✓   | ✓   | ✓   |

## Frequency (estimate — pending D-A2 instrumentation)
- **High freq:** resume, next, status, pr (create/respond/ready/review), help, search
- **Med freq:** plan, study, log, decision, scope-check, self-review
- **Low freq:** phase-new, plan-master, cascade, merge, changelog, shadow, impact, reviewer-track, freeze, tag

## What users currently can't do (capabilities entirely absent)
- C1. List all in-flight PRs in this project (`pr list`)
- C2. Show progress across a phase (`phase status`)
- C3. Compute coverage delta for a PR (`review --mode=coverage`)
- C4. Detect when a PR drifts from its spec (`pr drift N`)
- C5. Suggest reviewers based on file ownership (`pr suggest-reviewer`)
- C6. Track who-reviewed-what across time
- C7. Replay a workflow from an audit-log for debugging
- C8. Export a "PR packet" (spec + diff + tests + ADR refs) for offline review

→ industrial gaps detail in `cd-wf-c2-p1-industrial-gaps.md`.
