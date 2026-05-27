# Phase: 3-design
schema-version: v4
status:         active
workflow-step:  pr-specs
branch:         main
current-pr:     (none)
created:        2026-05-22
predecessor:    2-prioritise (ranked)
successor:      (4-implement)

## Working Context
- Inputs: top-5 clusters from `../2-prioritise/02-plan.md`, ADRs 001/002/003/005a/006/007 (accepted)
- Goal: produce PR-shaped specs (axon-master 9-section template) ready to hand to implementer
- Output: `03-prs/PR-NNN.md` per PR, with Files-changed, Acceptance, Rollback, Risk
- Exit criteria: top-3 clusters fully spec'd → Phase 4-implement entry
