# Workflow catalog — observed + plausible workflows in AXON (T-B output, serves D-5)

> Compiled from F-006 (workflow-completion programs), library-dev FSM walk,
> code-dev-canonical-fsm helper, and dev-projects/04-log.md lived usage.
> Date: 2026-05-17.

## Observed workflows (lived in `my-axon/dev-projects/*`)

### WF-01 · code-dev canonical chain (Fixed)
**Domain.** code-dev.
**Goal.** Take a software change from idea to merged + audited.
**Synapses (default mode):**
```
code-dev new
  → code-dev load <slug>
  → code-dev study   [--mode=overview|subsystem|deep]
  → code-dev plan    [--mode=tactical|strategic|operational|decision]
  → (loop) code-dev pr-create [N]
  → code-dev log
  → code-dev pr-review [N]   (9-phase sub-FSM)
  → code-dev safety-audit
  → code-dev-knowledge-shadow (per PR)
  → code-dev finalize (orphan stub today — F-012)
```
**Acceptance.** Audit returns zero open issues; all PRs implemented; shadow
coverage = 100 %.
**Lived examples.** axon-master (55 PRs), axon-cleanup (25 PRs),
axon-tests (21 PRs), axon-user (17 PRs).

### WF-02 · library-dev canonical chain (Fixed)
**Domain.** library-dev.
**Goal.** Convert a folder of PDFs/TXTs into a searchable, explained,
synthesized library with citations.
**Synapses (default mode):**
```
library-dev new <name>
  → library-dev ingest   [--folder | --file]
  → library-dev explain  [stem | --all]
  → library-dev intersect [--lens "topic"]
  → library-dev report   [type | --lens "question"]
  → library-dev cite     [--format bibtex|apa|mla]
  → (sideband) library-dev search    when knowledge gaps surface
  → (sideband) library-dev status    at any point
```
**Acceptance.** Shadow % == explain % == 100; gaps.md addressed; cite
file produced.
**Lived examples.** (workspace/libraries/ — out of scope for this audit;
empirical proof TBD if user has libraries).

### WF-03 · PR-review sub-FSM (Fixed, hybrid w/ deviation paths)
**Domain.** code-dev (sub-workflow of WF-01).
**Goal.** Take a branch from "needs review" or "diverged" to clean, rebased,
tested, documented.
**Synapses (per master `code-dev-pr-review.md`):**
```
P1 Context load
  → P2 Study (shadow files)
  → P3 Conflict analysis
  → P4 Harmonization plan
  → P5 Rebase
  → P6 Execution
  → P7 Verification (grep sweeps, build, ctest)
  → P8 Commit organization (git reset --mixed)
  → P9 Documentation
```
**Suggester hooks today.** EMIT(code-dev.pr.review.phase) at each phase.
**Branching opportunities (un-declared).**
- P3 conflicts == 0 → skip P4/P5.
- P7 tests fail → branch to `code-dev-review-tests` or back to P5/P6.
- P9 → auto-suggest `code-dev-knowledge-shadow` + `code-dev safety-audit`.

### WF-04 · Self-improvement / igap loop (Adaptive)
**Domain.** meta.
**Goal.** Reduce future inference gaps by closing today's open ones.
**Synapses:**
```
igap stats
  → igap report
  → (gated by dev-mode) igap improve   (study→plan→execute cycle)
  → auto-improve   (daily orchestrator that automates parts of the loop)
```
**Lived data.** `auto-improve` is scheduled daily (cron-job seen at boot).

### WF-05 · Auto-actions audit loop (Adaptive)
**Domain.** meta.
**Goal.** Review recent auto-applied changes, accept/reject, audit drift.
**Synapses:**
```
auto-actions   (review unread)
  → undo --list <path>   (per-file rollback inspection)
  → undo apply <id>      (restore prior state)
  → auto-audit (summary | list | record)
```
**Lived data.** Menu surfaces "Auto-actions ▶ N unread" line.

### WF-06 · Boot + resume (Fixed; structural)
**Domain.** kernel / meta.
**Goal.** Restore a working session from prior state.
**Synapses:**
```
boot tool
  → prefs tool
  → my-axon load (MYAXON.md path keys)
  → harness contract (workspace/harness/{harness}.md)
  → index list --type chat
  → IF active-phase ≠ done → offer resume
  → ELSE EXEC(menu)
```

### WF-07 · Workspace backup (Fixed; cron-driven)
**Domain.** meta.
**Goal.** Push my-axon/ to private GitHub remote.
**Synapses:**
```
workspace-backup push
  → (git add -A + git commit + git push origin main)
  → write status markers in memory/local/
```
**Lived data.** Fired manually this session ("synk it" request).

## Plausible-but-not-yet-codified workflows (Phase 3 candidates)

### WF-08 · python-code-dev (Fixed, parameterized)
**Domain.** code-dev (Python variant).
**Goal.** Ship a Python code change.
**Synapses:**
```
code-dev study
  → run linter (TBD: register `python-lint` synapse)
  → code-dev-suggest-tests
  → run-tests
  → code-dev-review-tests
  → code-dev-self-review (or code-dev-review-self per F-007)
  → code-dev-review-coverage
  → code-dev-explain  (generate commit msg / explanation)
  → code-dev pr-create
  → code-dev pr-review
  → code-dev safety-audit
  → code-dev-knowledge-shadow
  → code-dev finalize (once F-012 stub closed)
```
**Trigger.** User: "I want a python workflow" → workflow-new --from-description.

### WF-09 · cpp-code-dev (Fixed, parameterized, includes build)
**Domain.** code-dev (C++ variant).
**Goal.** Ship a C++ code change.
**Synapses:**
```
code-dev study --mode=deep --target=<header>
  → code-dev-suggest-tests
  → (HUMAN) cmake --build ...      ← per kernel rule, human-only
  → (HUMAN) ctest -R '...'         ← per kernel rule, human-only
  → code-dev-review-tests
  → code-dev-self-review
  → code-dev pr-review   (9-phase, includes git rebase)
  → code-dev safety-audit
```
**Adaptive deviation example.** If P7 tests fail in `pr-review`,
orchestrator suggests `code-dev-review-coverage` to triage.

### WF-10 · study-dev (Fixed; non-code domain)
**Domain.** study-dev (proposed Phase 4 domain).
**Goal.** Read a body of literature, take notes, synthesize.
**Synapses (mirroring library-dev verb-map):**
```
study-dev new <topic>
  → study-dev source <pdf|url>      (≡ ingest)
  → study-dev annotate <stem>        (≡ explain)
  → study-dev synthesize             (≡ intersect)
  → study-dev present <type>         (≡ report)
  → study-dev cite                   (shared with library-dev)
```

### WF-11 · science-dev (Fixed; non-code domain)
**Domain.** science-dev (proposed Phase 4 domain).
**Goal.** Design + execute + analyze a scientific experiment.
**Synapses:**
```
science-dev new <hypothesis>
  → science-dev design       (protocol authoring)
  → science-dev preregister  (OSF / repo submission)
  → science-dev run          (log experimental runs)
  → science-dev analyze      (stats analysis)
  → science-dev write        (paper draft — re-uses code-dev-explain)
  → science-dev review       (re-uses code-dev-pr-review machinery!)
  → science-dev publish      (submission)
```
**Cross-domain reuse.** `code-dev-pr-review` 9-phase FSM applies to paper
draft review with adjusted vocabulary.

### WF-12 · adaptive free-text task (Adaptive)
**Domain.** any.
**Goal.** User states a task; orchestrator figures out the path.
**Synapses (dynamic — composed at runtime):**
```
[mode-detect or intent classifier]
  → propose top-k candidate synapses
  → QUERY user (gated by L:inference-mode)
  → fire chosen synapse
  → observe new state
  → re-rank candidates
  → loop until goal-met OR user-stops
```
**This is the canonical D-7 / D-29-Adaptive realization.**

## Corrigenda (lint pass 2026-05-17)

- "journal-search" referenced as a program — it is NOT a standalone
  program. Real name: `code-dev-journal-search.md`. Journal family
  programs are `code-dev-journal*.md` (journal entry point +
  decision/event/log/search subcommands).
- "igap-stats" referenced as a program — it is NOT a standalone program.
  `igap stats` is a tool invocation
  (`python3 axon.py igap stats --days N`). Only `igap-improve.md` is a
  standalone program in the family.

## Cross-cuts and shared verbs (D-15 candidates)

Verbs that appear in multiple domains — candidates for shared programs:

| Verb | code-dev | library-dev | future study-dev | future science-dev |
|------|----------|-------------|------------------|---------------------|
| `new` | code-dev-new | library-dev-new | study-dev-new | science-dev-new |
| `shadow` | code-dev-knowledge-shadow | (library `shadow/` dir) | (TBD) | (TBD) |
| `explain` | code-dev-explain | library-dev-explain | (TBD `annotate`) | (TBD `write`) |
| `status` | (TBD) | library-dev-status | (TBD) | (TBD) |
| `cite` | (TBD) | library-dev-cite | (shared) | (shared) |
| `audit` | code-dev-safety-audit | (TBD) | (TBD) | (TBD) |
| `report` | (TBD) | library-dev-report | (TBD `present`) | (TBD `write`) |

→ Shared-program hoist candidates: `flow-new`, `flow-shadow`, `flow-explain`,
`flow-status`, `flow-cite`, `flow-audit`, `flow-report`.

## Workflow file template (Phase 2 input)

```yaml
# workflow: python-code-dev
name:             python-code-dev
domain:           code-dev
execution-mode:   fixed
default-goal:
  statement:      "Ship a Python code change end-to-end."
  acceptance-criterion: "All PRs implemented + tests pass + shadow 100% + audit OK."
triggers:
  - "user said: 'I want a python workflow'"
  - "project _meta.codebase contains *.py files"
allow-suggestions:  true   # sideband suggestions stay live
allow-deviation:    true   # user may break out of fixed path with confirm
synapses:
  - name: code-dev-study
    mode: subsystem
  - name: python-lint        # synapse to be registered
  - name: code-dev-suggest-tests
  - name: run-tests
  - name: code-dev-review-tests
  - name: code-dev-self-review
  - name: code-dev-explain
  - name: code-dev-pr-create
  - name: code-dev-pr-review
  - name: code-dev-safety-audit
  - name: code-dev-knowledge-shadow
  - name: code-dev-finalize
```

This template format is the **Phase 2 deliverable**.
