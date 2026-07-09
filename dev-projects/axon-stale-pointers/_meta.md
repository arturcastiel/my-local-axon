# Project: Stale Pointer Integrity — phase/state bookkeeping audit
slug:            axon-stale-pointers
schema-version:  v4
status:          complete
legacy:          false
phase:           audit
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          (none)
sub-projects:    []
created:         2026-07-09
updated:         2026-07-09

## Working Context
Owner-reported problem (2026-07-09): state pointers are not being properly updated and go
stale. Investigation question — is this a defect in the code-dev workflow programs (missing
stamp steps), an autonomous-run discipline failure (agent skips the steps that exist), or a
missing mechanical enforcement seam (nothing verifies pointer consistency at completion)?

Concrete evidence captured at boot 2026-07-09 (all from the axon-obsidian completion,
2026-07-08 — project verifiably COMPLETE: 5 PRs merged, pushed to origin/main de0a760):

1. W:active-phase held "code-dev-pr:1" across sessions — never advanced to ":done" despite
   kernel "Program phase tracking" mandating the DONE stamp. Consequence: the boot resume
   offer and the active-program interrupt gate FALSE-FIRED this session on a finished project.
2. _phases.json (axon-obsidian) pr phase still "pending" while 02-prs.md records all 5 PRs
   MERGED — the phase-model manifest (single source of phase truth, per code-dev-new C1) was
   never advanced; `code-dev done` apparently never ran, or ran without writing.
3. workspace/memory/longterm/last-test-run.json stale at 2026-07-03 (kernel suite, 164 tests)
   while the project log claims a full-suite 5296/0/15 run — the suite verdict was never
   stamped into the mechanical record; the completion claim rests on an agent-written log line.
4. Timeline sleuthing needed to reconstruct events (pytest lastfailed 23:19 with 29 failures,
   commits 23:43-44, untracked pytest activity 00:49) — evidence of the same gap: state
   transitions happen, pointers don't follow.

Scope hypothesis (verify in study): three distinct writer seams — kernel W:active-phase
discipline (protocol-level, agent-applied), phase-model manifest advancement (mechanical but
must be invoked), longterm run-records (tool exists, not wired into completion path). Likely
verdict is "both": programs omit stamp steps at their exits AND nothing mechanical audits
pointer coherence (candidate fix shape: a `pointer-lint` / self-care check that cross-checks
W:active-phase × _phases.json × _meta.md status × log claims, plus stamp steps added to the
code-dev exit paths).

Run: code-dev study  to begin.
