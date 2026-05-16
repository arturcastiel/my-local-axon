# CD·STUDY·C2·P1 — workflows that consume study output

> The 10 most common user flows where study artifacts are the input. Each flow names the modes it needs and the integration points with `plan` / `pr` / `flow`.

## WF-S1 — Day-0 onboarding to a fresh codebase
```
1. code-dev lifecycle new --slug myrepo --codebase /path
2. code-dev knowledge study --recipe=new-repo-onboarding
3. code-dev flow plan --from study/  --mode=execution
4. code-dev pr create 1               (first concrete PR proposed by plan)
```
Modes used: overview, history, dependencies, api-surface, tests.
Outputs consumed: `study/_index.md` + all per-mode files → `02-prs.md`.

## WF-S2 — Quarterly health check
```
1. code-dev knowledge study --mode=overview --diff --since=90d
2. code-dev knowledge study --mode=history --since=90d
3. code-dev knowledge study --mode=dependencies --diff
4. code-dev knowledge study --mode=tests --diff
5. code-dev flow plan --from study/ --mode=risk-first
```
Modes: overview, history, dependencies, tests (all in --diff form).
Result: prioritized PR list with deltas annotated.

## WF-S3 — Pre-release ship gate
```
1. code-dev knowledge study --recipe=pre-release-audit
2. code-dev safety preflight                  (consumes study/security.md)
3. code-dev pr ready --strict                 (gates on stale studies)
4. code-dev flow finalize
```
Modes: security, dependencies, tests, dead-code, observability.

## WF-S4 — Performance regression hunt
```
1. code-dev knowledge study --mode=history --since=14d   # what changed?
2. code-dev knowledge study --mode=performance --target=<suspected path>
3. code-dev knowledge study --mode=dataflow --from <input> --to <hot fn>
4. code-dev pr create N --title "Fix perf regression in <module>"
```
Modes: history, performance, dataflow.

## WF-S5 — Big-refactor confidence run
```
1. code-dev knowledge study --recipe=refactor-prep --target=src/billing
2. code-dev flow plan --from study/ --mode=constrained --rule "no behavior change"
3. (run PR cycle for each item)
```
Modes: subsystem, naming, dead-code, tests, dataflow.

## WF-S6 — Brownfield acquisition / due diligence
```
1. code-dev lifecycle load --codebase /acquired-repo
2. code-dev knowledge study --recipe=brownfield-dd
3. code-dev flow plan --from study/ --mode=exploratory --output executive
```
Modes: overview, history, dependencies, security, architecture, data-model.
Result: an executive summary for non-technical stakeholders.

## WF-S7 — Library API breaking-change review
```
1. code-dev knowledge study --mode=api-surface --diff --since=v1.0
2. code-dev knowledge study --mode=tests
3. code-dev flow plan --from study/ --mode=execution --emit changelog
```
Modes: api-surface, tests.

## WF-S8 — Bug triage from a report
```
1. code-dev knowledge study --mode=dataflow --from <bug input> --to <error site>
2. code-dev knowledge study --mode=error-handling --target=<module>
3. code-dev pr create N --title "Fix <bug-id>"
```
Modes: dataflow, error-handling.

## WF-S9 — Coverage push
```
1. code-dev knowledge study --mode=tests --input coverage.json
2. code-dev flow plan --from study/tests.md --mode=budgeted --budget 5
3. (PR cycle for the top-5 untested modules)
```
Modes: tests.

## WF-S10 — Architecture decision audit
```
1. code-dev journal search --kind=decision --since=180d
2. code-dev knowledge study --mode=architecture        (NEW post-MVP)
3. (compare ADRs vs current code; produce drift report)
```
Modes: architecture (new), journal cross-read.

## Frequency / priority table

| Workflow | Frequency  | Importance | Implement-priority |
|----------|:----------:|:----------:|:------------------:|
| WF-S1    | rare-but-critical | high | P0                 |
| WF-S2    | recurring | high              | P0                 |
| WF-S3    | recurring | high              | P0                 |
| WF-S4    | when needed | high            | P1                 |
| WF-S5    | when needed | high            | P1                 |
| WF-S6    | rare      | medium             | P2                 |
| WF-S7    | recurring (libs) | medium      | P1                 |
| WF-S8    | recurring | high              | P1                 |
| WF-S9    | recurring | medium             | P1                 |
| WF-S10   | rare      | medium             | P2                 |

→ workflow gaps: `cd-study-c2-p2-workflow-gaps.md`.
