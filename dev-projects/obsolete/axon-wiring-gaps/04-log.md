# Implementation Log — AXON Memory Key Wiring Gaps

## SESSION START — 2026-05-21T15:00:38Z
project:        axon-wiring-gaps
phase:          1-design
workflow-step:  study
branch:         main
codebase:       /mnt/c/projects/axon

## Entries

### 2026-05-21T15:00:38Z · code-dev new (scaffolded)
- Created via direct scaffold (no `code-dev new` interactive prompt).
- Origin: discovered while answering "what is code-dev-codebase set?"
  during the cpg-to-unstructure resume. Grep found 5 reader programs
  for W:code-dev-codebase, 0 writers in workspace/programs/.
- User asked for a new project to fix this + audit similar keys.
- Per user direction: only set goals + study; no plan, no PR specs.
- Output: _meta.md, _profile.md, _dont-do-seeds.md, masterplan.md,
  05-branches.md, phases/1-design/* (9 stubs), and a populated
  01-study.md (goal-capture).

### 2026-05-21T15:10Z · scope expansion (Goal 3 added)
- While running Option B (pr_drift on PR-4) in the cpg-to-unstructure
  session, two more defects surfaced:
    · code-dev-pr-drift.md dispatches against {proj-dir}/03-prs/ instead
      of the v4 phase path {proj-dir}/phases/{phase}/03-prs/
    · pr_drift tool truncates acceptance items at unbalanced parens
- User requested a third goal: zero out broken programs (target = 0).
- 01-study.md updated:
    · Goal 1 unchanged.
    · Goal 2 unchanged (memory-key audit).
    · Goal 3 NEW: inventory + fix every broken program until count = 0.
    · §5a "Findings registry" added with the 3 seeded rows.
- Scope of project broadens from "memory-key topology" to
  "memory-key topology + broken-program defects". Same root cause
  (incomplete wiring); two surface layers.
- No plan, no PR specs, still deferred.
