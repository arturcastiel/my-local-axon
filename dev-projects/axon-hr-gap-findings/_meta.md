# Project: AXON HR Gap Findings
slug:            axon-hr-gap-findings
schema-version:  v4
status:          active
legacy:          false
phase:           3-pr
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-19
updated:         2026-06-19

## Working Context
- Source: hr-team advisory verdict (2026-06-19 · 10 seats · full tier · 5 rounds · confidence 0.884)
- Inception doc: workspace/working/axon-hr-gap-findings.md (expand gaps + PR plan)
- Scope: 8 ranked architecture gaps — drift, enforcement, observability, coverage,
  my-axon paths, health display, orchestrator, self-care cron
- Relationship: parallel-safe alongside axon-completeness-gate (non-overlapping scope)
- HARD CONSTRAINTS:
    NO KERNEL-SLIM.md edits (inviolable floor)
    crucible-green before every merge
    Core Rule 13: every new file/tool needs tests
    AXON-only commit trailer: Co-authored-by: AXON <axon@arturcastiel.github.io>
    no --force git ops
    PR-09 (L: flag activation) requires owner explicit confirmation — NOT autonomous
    DO NOT run scripts/enable-enforcement.sh --apply (no-op; settings already current)
    PR-07 code change requires owner confirm (KERNEL-SLIM core lines 107-138)
- Study phase: DONE 2026-06-19 · AXON 9/10 · User 9/10
  - v4: 4 iterations · 3 ADRs · all claims source-verified
  - Key ADRs: symlink no-migrate · enforcement script no-op · igap 4-site wiring
- Plan phase: DONE 2026-06-19 · council R1 WSV 7.4 · council R2 WSV 9.0 · 6 total revisions
  - R1-R3: W:key registry, igap DONE() heartbeat, test file corrections
  - R4: PR-04 phantom dispatch.md removed; meta-igap.md fix added to scope
  - R5: PR-07a HALT recovery procedure added
  - R6: PR-05 authoring-guide.md §5 section creation added
- PR phase: IN PROGRESS 2026-06-19
  - PR-01: spec-written (03-prs/PR-01.md) — drift --no-program + BOOT.md auto-init
  - PR-02 through PR-09: specs not yet written
  - NO CODE IMPLEMENTED — all work is specification only
