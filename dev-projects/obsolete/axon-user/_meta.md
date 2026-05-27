# Project: AXON User Simulation
slug:         axon-user
status:        obsolete
phase:        0-init
codebase:     /mnt/c/projects/axon
parent:       (none)
sub-projects: []
created:      2026-05-16
updated:      2026-05-16
schema-version: v4

## ONE-LINE MISSION
Stress-test AXON by simulating multiple AI-agent users with distinct
personalities exercising every `code-dev-*` program; document every
friction point, error, and broken assumption; produce an actionable
**improvement-only** backlog (no new features).

## SCOPE — IMPROVE, DO NOT ADD

- ✅ Fix bugs, broken flows, error messages, dead-ends, ambiguities.
- ✅ Tighten existing programs (better defaults, clearer prompts, fewer steps).
- ✅ Improve existing docs (cheatsheet, AXON-DOCS-*).
- ✅ Adjust existing tools to be more robust (e.g. `rename_snapshot.py` path bug).
- ❌ NO new programs, no new tools, no new doc files beyond findings logs.
- ❌ NO new features. If a persona requests a feature, log as `out-of-scope`.

## STUDY DIRECTIVE — multi-persona simulation

Each cycle = one persona runs a workflow end-to-end and writes a finding.

### Personas (5 — span experience, focus, temperament)

| id  | name            | experience | temperament   | primary goal                                |
|-----|-----------------|------------|---------------|---------------------------------------------|
| P1  | novice-naomi    | first day  | curious       | open `code-dev`, complete `lifecycle-tour`  |
| P2  | speedrun-sam    | impatient  | terse         | minimal keystrokes new → first PR pushed    |
| P3  | careful-cassie  | senior     | methodical    | full study/plan/pr-ready with audit trail   |
| P4  | recovery-rio    | mid-level  | distracted    | crash mid-flow, resume after compaction     |
| P5  | meta-mira       | OS-builder | analytical    | exercise `meta-*` + `safety-*` + `journal-*`|

Each persona file in `personas/{id}.md` defines: backstory, voice,
patience-budget (turns before they give up), and the workflows they
**must** attempt.

### Workflow matrix (W-* — every program must be hit at least once)

W-01 boot + identity gate
W-02 `code-dev-new` scaffolding
W-03 `code-dev-study` (overview / subsystem / deep modes — PR-30)
W-04 `code-dev-plan` (tactical / strategic / operational / decision)
W-05 `code-dev-pr-create` + `pr-ready` + `pr-sync` + `pr-drift`
W-06 `code-dev-state-*` save / status / handoff / resume / restore / undo / metrics
W-07 `code-dev-journal-*` log / decision / event / search
W-08 `code-dev-knowledge-*` shadow / explain / impact / reviewer-track
W-09 `code-dev-safety-*` audit / preflight / freeze
W-10 `code-dev-review` (scope / self / diff / tests via internal routers)
W-11 `code-dev-lifecycle-tour` (new-user onboarding)
W-12 `code-dev-chats` list / show / switch
W-13 compaction → `code-dev-resume` (state-resume)
W-14 alias-stub deprecation paths (every renamed verb)
W-15 cheatsheet + AXON-DOCS-* discoverability

### Cycle protocol

For each (persona, workflow) pair:
  1. Persona attempts the workflow in-character (voice + patience).
  2. Every friction → `findings/F-{NNN}.md` with: persona, workflow,
     reproduction, severity (S1 blocker / S2 friction / S3 polish),
     suggested adjustment, file/line citation.
  3. Crashes / silent failures get severity S1 automatically.

## INVARIANTS

1. **No new files in `workspace/programs/`, `tools/`, `axon/`.** Findings
   propose *edits* to existing files. Exception: `findings/` and project-local
   files under `my-axon/dev-projects/axon-user/`.
2. **Every finding must cite an exact file:line.** No vague "the UX is bad".
3. **Personas cannot break character.** Voice consistency is part of the test.
4. **Token economy is itself a test.** Record per-workflow token use; a
   persona running out of budget mid-flow is a finding.

## DELIVERABLES

- `findings/F-*.md` — one per friction point
- `01-study.md` — observed AXON surface from a user POV
- `02-brainstorm.md` — adjustment ideas grouped by program
- `03-plan.md` — improvement PRs (existing-file edits only)
- `03-prs/pr-*.md` — concrete improvement specs
- `04-log.md` — chronological persona-run journal

## EXIT CRITERIA

- All 15 workflows × 5 personas attempted (75 runs).
- Severity-1 finding count → 0 after improvements land.
- Severity-2 count reduced ≥ 50%.
- Cheatsheet + lifecycle-tour pass novice-naomi unaided.

## CROSS-REFS

- Master plan: `../axon-master/03-plan.md`
- Cheatsheet: `/mnt/c/projects/axon/workspace/AXON-DOCS-CHEATSHEET.md`
- Failure-modes taxonomy: `/mnt/c/projects/axon/workspace/AXON-DOCS-FAILURE-MODES.md`

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
