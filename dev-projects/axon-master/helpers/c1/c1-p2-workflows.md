# C1·P2 — Workflow Brainstorm

> Synthesized from c1-p1-{kernel,programs,tools}-map.md. AXON has 112 programs and 51 ACTIVE tools. This is a brainstorm of workflows AXON could enable today by *composing* what already exists, plus a few that need small additions.

Each entry: **name · trigger · pieces · output · cycle**.
- `cycle` = how often the workflow recurs (one-shot, daily, per-PR, per-incident).

---

## A. CODE DEVELOPMENT WORKFLOWS

### A1 · Spec-driven refactor
- **trigger**: user wants to refactor module X but keep behavior
- **pieces**: code-dev-new → code-dev-study (semantic-search baseline) → code-dev-plan (with --constraint "no behavior change") → code-dev-pr per file → code-dev-self-review (acceptance gate)
- **output**: PR specs with explicit acceptance criteria + behavioral test scaffolds
- **cycle**: per-refactor

### A2 · PR-review triage (multi-reviewer)
- **trigger**: 3+ reviewers leave comments
- **pieces**: code-dev-review (dashboard) → code-dev-reviewer-track (pattern over history) → code-dev-pr-respond (per-comment) → code-dev-pr-update-spec (when spec needs revision)
- **output**: per-reviewer brief + delta to spec
- **cycle**: per-PR

### A3 · Cross-PR test mapping
- **trigger**: any PR touches module M, ensure M's tests run + uncovered lines surfaced
- **pieces**: code-dev-test-map (source ↔ test) → code-dev-suggest-tests (gaps) → code-dev-self-review acceptance gate
- **output**: list of tests to run + missing-coverage warnings
- **cycle**: per-PR

### A4 · Incident postmortem replay
- **trigger**: production incident, want to retrace decisions
- **pieces**: code-dev-replay (10-layer recovery) → code-dev-decision (ADR for fix) → code-dev-changelog (entry) → code-dev-tag (snapshot)
- **output**: postmortem doc + ADR + changelog + restore point
- **cycle**: per-incident

### A5 · Branch drift watch (daily)
- **trigger**: cron daily 09:00
- **pieces**: code-dev-branch (drift detect) → IF drift > threshold → notify + open code-dev-resume
- **output**: drift report; remediation queued
- **cycle**: daily

### A6 · Pre-push readiness gate
- **trigger**: user types `code-dev pr-ready`
- **pieces**: code-dev-pr-ready (gates 0-10) → code-dev-diff (triple diff) → code-dev-self-review → code-dev-pr-github (draft)
- **output**: pass/fail + GitHub PR draft
- **cycle**: per-PR

### A7 · Phase split / merge
- **trigger**: phase too big OR two phases overlap
- **pieces**: code-dev-divide (split) OR code-dev-combine + code-dev-cascade (refresh deps)
- **output**: restructured phase tree + updated _meta
- **cycle**: ad hoc

### A8 · Multi-project comparison (NEW)
- **trigger**: "compare projects A and B"
- **pieces**: SCAN dev-projects/ → for each: read 01-study + 02-prs + 04-log → produce diff report
- **output**: side-by-side scope/spec/learnings matrix
- **cycle**: ad hoc
- **gap**: needs a new program `code-dev-compare`

### A9 · Scope-drift watcher
- **trigger**: every code-dev-log write
- **pieces**: code-dev-scope-check vs code-dev-dont-do → flag drift → suggest update-spec or split
- **output**: scope drift alert
- **cycle**: per-log

### A10 · Self-review handoff to human
- **trigger**: PR ready, want a single explainer for a non-author reviewer
- **pieces**: code-dev-explain-reviewer → code-dev-impact (API analysis) → code-dev-since (delta)
- **output**: one-page reviewer briefing
- **cycle**: per-PR

---

## B. LIBRARY / KNOWLEDGE WORKFLOWS

### B1 · Reading list ingestion
- **trigger**: drop PDFs into a library folder
- **pieces**: library-dev-new → library-dev-ingest (shadow each) → library-dev-explain (annotated) → library-dev-cite
- **output**: per-article shadow + explanation + bibliography
- **cycle**: per-batch

### B2 · Cross-paper synthesis (theme finder)
- **trigger**: 5+ papers ingested
- **pieces**: library-dev-intersect (themes/contradictions) → library-dev-report (gap-aware)
- **output**: themed synthesis report + open-question list
- **cycle**: per-library milestone

### B3 · Library-to-code bridge (NEW)
- **trigger**: library finding suggests code change
- **pieces**: library-dev-cite → code-dev-decision (ADR linking citation) → code-dev-plan (project from finding)
- **output**: ADR + plan referencing source
- **cycle**: ad hoc
- **gap**: library-dev-cite needs an `--into-project` flag

### B4 · Continuous reading (cron)
- **trigger**: daily cron — check library-dev-search for new papers in topic X
- **pieces**: library-dev-search → diff vs library state → library-dev-ingest new
- **output**: weekly "new papers" digest
- **cycle**: daily

---

## C. AXON META / SELF-IMPROVEMENT WORKFLOWS

### C1 · Boot health audit (cron)
- **trigger**: cron weekly OR `axon-audit`
- **pieces**: axon-audit (structural + usefulness) → health-check → discover (compile candidates) → suggest-compile
- **output**: health score + structural issues + compile backlog
- **cycle**: weekly

### C2 · Inference-gap closure loop
- **trigger**: igap report shows >N gaps
- **pieces**: igap stats → igap-improve (drives study→plan→execute) → code-dev-plan-master (rolls into project) → code-dev-pr per gap
- **output**: gap-closing PRs in dev-projects/igap/
- **cycle**: weekly OR threshold-triggered

### C3 · Compile coverage chase
- **trigger**: `compile-optimizer status` < threshold
- **pieces**: discover (find non-compiled) → simulate (verify deterministic) → compile (write .cmp.md)
- **output**: increased compile coverage
- **cycle**: ad hoc

### C4 · Drift retrospective
- **trigger**: `gain` shows drift trending up
- **pieces**: gain → drift check → coherence guardian replay → identify trigger phrases → propose kernel/program edits (dev-mode)
- **output**: drift root-cause + fix proposals
- **cycle**: weekly

### C5 · Dispatch tuning
- **trigger**: dispatch-stats shows feedback "wrong" > N%
- **pieces**: dispatch-stats → pattern (cluster wrong routes) → propose dispatch threshold change OR new compiled program
- **output**: tuned smart-dispatch.md
- **cycle**: monthly

### C6 · Workspace backup integrity check (NEW)
- **trigger**: weekly
- **pieces**: workspace-backup status → git log my-axon → diff vs local
- **output**: integrity report
- **cycle**: weekly
- **gap**: workspace-backup needs a `verify` subcommand

### C7 · Memory compaction sweep
- **trigger**: `memory-compact` OR cron monthly
- **pieces**: scan E: > size threshold → summarize old episodes → archive raw → keep summary
- **output**: trimmed E: with searchable summary index
- **cycle**: monthly

---

## D. SESSION / CONVERSATION WORKFLOWS

### D1 · Resume after context loss
- **trigger**: user types `resume` after compaction
- **pieces**: resume → code-dev-resume (10-layer) → menu render
- **output**: full state restoration + next-action suggestion
- **cycle**: per-resume

### D2 · Session handoff to another agent
- **trigger**: user types `handoff`
- **pieces**: handoff → session-summary → snapshot W:/L: → write handoff package → upload (or local file)
- **output**: portable session bundle
- **cycle**: ad hoc

### D3 · Mode auto-switch from intent
- **trigger**: user sends free text in chat mode
- **pieces**: mode-router → mode-detect (if confidence low) → suggest mode change
- **output**: routed input + mode hint
- **cycle**: every free-text turn

### D4 · Chat-to-plan promotion
- **trigger**: chat session crosses idea threshold
- **pieces**: chat-input → recognize "I want to do X" pattern → suggest plan-new → seed plan from chat
- **output**: plan with tasks pre-filled
- **cycle**: ad hoc
- **gap**: no auto-detector today; needs `chat-promote` program

---

## E. ADD-ON / DOMAIN WORKFLOWS

### E1 · Investigation case (hollow-signal)
- **trigger**: load a case file
- **pieces**: case-briefing → analyze → interrogate → accuse
- **output**: closed case with evidence chain
- **cycle**: per-case

### E2 · League season (soccer-manager)
- **trigger**: new-game
- **pieces**: set-formation → squad → play → standings → end-season
- **output**: season summary + championship state
- **cycle**: per-season

### E3 · Generic addon scaffold (NEW)
- **trigger**: `addon new`
- **pieces**: read addon README template → scaffold programs/help/data dirs → register in INDEX
- **output**: addon skeleton ready for content
- **cycle**: per-addon
- **gap**: no `addon-new` program; addons currently hand-built

---

## F. TOKEN-ECONOMY WORKFLOWS

### F1 · Compiled-first dispatch (already implemented)
- **trigger**: any program EXEC
- **pieces**: smart-dispatch → if compiled exists + not stale → use .cmp.md
- **output**: ~30% token saving
- **cycle**: every EXEC

### F2 · Shadow-cache hot files
- **trigger**: code-dev project loaded
- **pieces**: code-dev-shadow refresh → semantic-search index → memoized lookups
- **output**: avoided re-reads of unchanged files
- **cycle**: per-session

### F3 · Lazy help-doc loading (NEW)
- **trigger**: user types `help X`
- **pieces**: prefer help/{X}.md only if user requested help; main programs include `# desc:` already
- **output**: skip loading 7 redundant help/*.md files at boot
- **cycle**: per-help
- **gap**: today help/ is parallel-loaded

### F4 · Web-search caching (NEW)
- **trigger**: any TOOL(web-search) call
- **pieces**: hash query → check cache (TTL 7d) → return cached OR fetch + cache
- **output**: ~80% cache hit rate on repeat queries
- **cycle**: every web-search
- **gap**: no caching today

### F5 · Document-parser hash-cache (NEW)
- **trigger**: TOOL(document-parser) on a file
- **pieces**: cache key = (file path, git hash) → return cached parse OR compute + cache
- **output**: avoided re-parse of unchanged PDFs
- **cycle**: every parse
- **gap**: no caching today

### F6 · Health-probe parallelization (NEW)
- **trigger**: TOOL(health) on boot
- **pieces**: parallelize per-tool health probes
- **output**: faster boot
- **cycle**: every boot
- **gap**: today sequential

---

## G. AUTHORING / DEVELOPER WORKFLOWS

### G1 · Author a new program
- **trigger**: user types `authoring-guide`
- **pieces**: authoring-guide → explain (existing similar program) → simulate (dry-run) → register-tool if needed → test → compile
- **output**: new program in workspace/programs/
- **cycle**: per-program

### G2 · Audit unused programs
- **trigger**: `axon-audit` flags unused
- **pieces**: deps → grep for callers → propose archive/delete
- **output**: cleanup PRs
- **cycle**: monthly

### G3 · Extend the language (EXTEND protocol)
- **trigger**: a pattern shows up 3+ times in workspace
- **pieces**: pattern stats → propose extension → load core/LANG.md → write expansion + translation → 2-use validation → activate
- **output**: new EXT-XXX in LANG.md
- **cycle**: when warranted

---

## H. SAFETY / RECOVERY WORKFLOWS

### H1 · Undo last write
- **trigger**: user types `undo`
- **pieces**: undo --list → restore snapshot → log
- **output**: file restored
- **cycle**: ad hoc

### H2 · Snapshot/rewind during long work
- **trigger**: user types `code-dev tag <label>`
- **pieces**: code-dev-tag → write snapshot → resumable from any tag
- **output**: named restore point
- **cycle**: ad hoc

### H3 · Identity-drift recovery
- **trigger**: drift state → "diverged"
- **pieces**: re-read KERNEL-SLIM.md + identity.md → reset W:reasoning-mode → log incident → continue
- **output**: identity restored
- **cycle**: rare

---

## I. CRON / SCHEDULED WORKFLOWS (already declared by axon-cron seed)

### I1 · axon-igap-report (daily)
- existing seeded job

### I2 · axon-compile-rank (daily)
- existing seeded job

### I3 · axon-dispatch-stats (daily)
- existing seeded job

### I4 · axon-memory-compact (weekly)
- existing seeded job

### I5 · axon-session-save (per-session)
- existing seeded job

### I6 · axon-auto-improve (gated)
- existing seeded job

### I7 · axon-programs-registry (daily)
- existing seeded job

---

## J. HIGH-LEVERAGE COMPOSITES (multi-program chains worth naming)

### J1 · "Ship a feature" megachain
`code-dev-new → study → plan → pr → log → audit → pr-ready → pr-github → merge → cascade → changelog → workspace-backup push`
**output**: full feature life-cycle + backup
**ask**: 1 chain.

### J2 · "Read a paper, change a project" megachain
`library-dev-ingest → explain → library-dev-cite --into-project (NEW) → code-dev-decision → plan → pr`
**output**: research-driven code change with citation trail
**ask**: 1 missing flag (`--into-project`)

### J3 · "Self-improve weekly" megachain
`igap report → igap-improve → code-dev-plan-master → study → plan → pr → log → audit → workspace-backup push`
**output**: closed inference gaps each week
**ask**: schedule it.

### J4 · "Daily hygiene" megachain (cron)
`workspace-backup status → axon-audit → code-dev branch → drift check → context status → notify if anomaly`
**output**: morning health digest

---

## K. WHAT'S MISSING TO ENABLE THE BEST WORKFLOWS

| Gap                                                | Adds to workflows                  | Effort |
|----------------------------------------------------|------------------------------------|--------|
| `code-dev-compare` (cross-project)                 | A8                                 | small  |
| `library-dev-cite --into-project`                  | B3, J2                             | small  |
| `chat-promote` (chat → plan)                       | D4                                 | small  |
| `addon-new` scaffolder                             | E3                                 | small  |
| `workspace-backup verify`                          | C6                                 | small  |
| Web-search cache (TTL 7d)                          | F4, library-dev-search             | small  |
| Document-parser cache (file+git-hash)              | F5, library-dev-ingest             | small  |
| Lazy help/ loading                                 | F3                                 | trivial|
| Parallel health probes                             | F6, boot speed                     | small  |
| `pattern` vectorizer cache per window              | dispatch tuning, igap analysis     | small  |
| First-class `shell` tool (replace 96 unregistered calls) | safety + observability       | medium |
| Unified semantic substrate (semantic-search/pattern/dispatch share index) | C5, F2 | medium |
| `code-dev-pr-review` split into 3 sub-workflows    | A2, F1 token saving                | medium |
| auto-route igap → dev-projects/igap/               | C2                                 | small  |
| Multi-project parallel comparison runner           | A8                                 | medium |

---

## L. FEEDBACK CANDIDATES FOR NEXT CYCLE

- C2 (workflow): which families produce the most run-time? (instrument with usage.py)
- C3 (workflow): which workflows actually get used? (dispatch-stats per family)
- F (token economy): measure baseline token cost per workflow, before optimizing

These observations seed C2·P1 (deepen internals) and C3·P1 (token hotspots).
