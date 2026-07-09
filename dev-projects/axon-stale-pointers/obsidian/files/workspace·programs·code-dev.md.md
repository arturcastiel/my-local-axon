---
tags: [code, file]
path: workspace/programs/code-dev.md
---

# workspace/programs/code-dev.md

> 87 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(`code-dev skip`, recorded). Premature-done caveat: the pr phase's output contract is a`
- `- Any phase can be re-entered and iterated independently`
- `- Each project lives in {W:myaxon-dev-projects}/{slug}/`
- `- Run phases in order: study → plan → pr → log → audit`
- `- Use 'code-dev status' to see all projects and their phases`
- `1. numeric sub is an ARGUMENT, never a subcommand ("pr 3" → pr-create with W:code-dev-pr-n)`
- `2. a program file code-dev-{cmd}-{sub}.md exists → route there directly`
- `3. otherwise fall through to the single-token table below (umbrella tokens included)`
- `>=1 glob (deviation 2026-07-09) — this route re-checks ALL phases, so a 1-of-N-specs`
- `Applies to: study, plan, pr, log, audit — any command that touches the codebase.`
- `BRANCHES`
- `C5 fix (axon-bugfix01): this used to store a key the target never read and EXEC the`
- `DASHBOARD DATA (when no cmd or after load)`
- `DASHBOARD DATA POST-STEP0 — store for render`
- `Explicit tokenizer bridge (axon-bugfix01, H19): the kernel tokenizer only ever writes the`
- `HELP`
- `IDENTITY LOCK`
- `LOAD CONTEXT`
- `LOAD PROJECT (if cmd = "load")`
- `OUTPUT → PYTHON_FAST · doc`
- `PROGRAM: code-dev`
- `ROUTE — P10/P11 schema + arch`
- `ROUTE — P12 long-tail`
- `ROUTE — P2 foundation`
- `ROUTE — P3 workflow body`
- `ROUTE — P4 gates & merge`
- `ROUTE — P5 closeout`
- `ROUTE — P7 consolidation surface`
- `ROUTE — P8 daily-driver UX`
- `ROUTE — P9 power tools`
- `ROUTE — if cmd provided, dispatch immediately`
- `ROUTE — phase BACK (axon-workflow-discipline: re-enter an earlier phase → cascade-invalidate downstream)`
- `ROUTE — phase DONE (axon-workflow-discipline: explicit DONE-to-advance)`
- `ROUTE — phase SKIP-ATTEMPT (axon-workflow-discipline: NO skip-by-inference; mode decides menu vs hard-HALT)`
- `ROUTE — project COMPLETE (axon-stale-pointers: "complete" is a gated claim, not prose)`
- `ROUTE — umbrella routers + chats (axon-bugfix01, C7 + M7)`
- `ROUTE — v4 commands (require schema-version: v4)`
- `Rule (first-match-wins, BEFORE the single-token table):`
- `Rule: every code-dev session must start from shadow, not raw source.`
- `SCAN PROJECTS`
- `SHADOW GATE — fires before any subcommand when a project with a codebase is loaded`
- `TWO-TOKEN RESOLUTION (axon-bugfix01 — the C6/C7/M7/M8 root-cause fix)`
- `The 8 umbrella hubs and the chats feature were only reachable by typing the literal`
- `The axon-obsidian class — _meta hand-stamped complete while the manifest sat pending —`
- `The old router matched only single hyphenated tokens while the documentation promised`
- ``code-dev new` was born schema-version v1 and the whole v4 surface (resume/phases) stayed dark.`
- ``new → code-dev-init` (v1) route was REMOVED: by first-match-wins it shadowed v4, so every`
- ``new` routes to code-dev-new (the v4 scaffolder) in the P2 section below. The legacy`
- ``review` is dispatched earlier (project-load-guarded → code-dev-pr-review); this second branch was`
- `and the 8 umbrella routers + the meta cluster + chats were unreachable entirely.`
- `becomes unwritable through the workflow. NO force path here: force stays per-phase`
- `budget:`
- `cache-prefix: 2048`
- `code-dev.md`
- `contract-version: neuron-contract v1.1`
- `desc:    5-phase code development workflow for large codebases`
- `desc:    Code development harness — study → plan → PR specs → log → audit`
- `domain: code-dev`
- `example: code-dev new  OR  code-dev load my-feature  OR  code-dev status`
- `family: [code-dev]`
- `generic W:_cmd/W:_arg1/W:_arg2 — nothing mechanical writes W:code-dev-cmd. Correctness used`
- `glossary: AXON-GLOSSARY v2`
- `heavyweight Phase-5 FINAL audit (wrong program, surprise write-prompt included) —`
- `hyphenated filename. Bare `code-dev journal` (etc.) renders the hub's own menu; a`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 10`
- `inputs:  W:code-dev-cmd — subcommand (optional, queried if absent)`
- `invocation_source: [program]`
- `next-suggests: [code-dev-safety-audit, code-dev-branch, code-dev-cascade, code-dev-changelog, code-dev-combine, code-dev-journal-decision, code-dev-divide, code-dev-dont-do, code-dev-journal-event, code-dev-knowledge-explain, code-dev-explain-reviewer, code-dev-safety-freeze, code-dev-state-handoff, code-dev-help, code-dev-hold, code-dev-knowledge-impact, code-dev-init, code-dev-link, code-dev-load, code-dev-journal-log, code-dev-merge, code-dev-state-metrics, code-dev-new, code-dev-next, code-dev-partition, code-dev-phase-, code-dev-plan, code-dev-plan-master, code-dev-pr-create, code-dev-pr-github, code-dev-pr-link, code-dev-pr-ready, code-dev-pr-respond, code-dev-pr-review, code-dev-pr-update-spec, code-dev-safety-preflight, code-dev-replay, code-dev-state-resume, code-dev-review, code-dev-knowledge-reviewer-track, code-dev-journal-search, code-dev-review, code-dev-since, code-dev-state-status, code-dev-study, code-dev-state-save, code-dev-test-map, code-dev-lifecycle-tour, code-dev-state-undo, code-dev-whatif]`
- `next:    code-dev new · code-dev load [slug] · code-dev status`
- `output-cap:   2000`
- `outputs-count: 9`
- `outputs: Project dashboard or routes to sub-program`
- `pr:done cannot leak through to a project-level complete claim on its own.`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND meta ≠ ∅"`
- `resolution, so these entries handle ONLY the bare-token case.`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `tips:`
- `to depend on every agent instance independently rediscovering that bridge; it is now code.`
- `two-word commands: `code-dev pr list` fell through `cmd ≡ "pr"` into PR-CREATE silently,`
- `two-word form (`code-dev journal log`) already short-circuited above via two-token`
- `unreachable (the interpreter takes the first match) and pointed at a different program — removed (F33).`
- `usage:   code-dev [new|load|study|plan|pr|log|audit|status]`
- `while the real structure checker (with --fix support) was called by nothing.`

## Depends on
- (none)
