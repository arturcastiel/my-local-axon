# Phase: 2-design
schema-version: v4
status:         ready-for-signoff
workflow-step:  design
branch:         main
current-pr:     (none)
created:        2026-05-17
updated:        2026-05-17

## Goal (per F-017 / D-007 / D-010)
Statement:    "Produce signed-off design specs for the synapse contract,
               workflow file, goal schema, domain manifest, DAG (5 levels),
               orchestrator composition, shadow enforcement, conversational
               author, and the migration plan — sufficient for Phase 3 to
               ship without revisiting design questions."

Measurement:
  - specs/SYNAPSE-GLOSSARY.md           exists + reviewed
  - specs/synapse-contract-v1.md        exists + validated against ≥ 3 corpus programs
  - specs/workflow-file-v1.md           exists + parser sketch / tests
  - specs/goal-schema-v1.md             exists + predicate language defined
  - specs/domain-manifest-v1.md         exists + code-dev + library-dev reference manifests
  - specs/dag-spec-v1.md                exists + nested sync rules
  - specs/orchestrator-composition-v1.md exists + signal-combiner formula
  - specs/shadow-enforcement-v1.md      exists + gate placement
  - specs/conversational-author-v1.md   exists + dialog scripts
  - specs/migration-plan-v1.md          exists + ordered task list

Acceptance:   ∀ spec ∈ above: file exists AND non-stub AND user sign-off.
Rejection:    Any spec contradicts D-014 (preserve code-dev) or D-015
              (domain-agnostic kernel) or D-019 (no tests break).

## Working Context
- Phase 1 closed with 17 findings + 30 demands + synthesis-draft.md.
- 6 helper files in phases/1-study/helpers/.
- Phase 2 deliverables land in phases/2-design/specs/.
- Phase 2 produces 02-plan.md + 02-prs.md + DAG.json/md as the
  hand-off to Phase 3.
- dev-mode remains OFF (D-004); specs are docs not kernel writes.
