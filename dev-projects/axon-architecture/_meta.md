# Project: AXON Architecture — flawless, maintainable, enforcement-real
slug:            axon-architecture
schema-version:  v4
status:          complete
legacy:          false
phase:           audit
workflow-step:   study
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-improvements
sub-projects:    []
created:         2026-05-29
updated:         2026-05-29

## Working Context
Objective: make AXON architecturally FLAWLESS + maintainable. Run via the RIGID code-dev workflow
(study→plan→pr→log→audit, no node-skip — dogfooding axon-workflow-discipline). Bar: flawless.

Seed problems from the 2026-05-29 architecture review (to VERIFY + extend during study, NOT assume true):
- P1 Enforcement is advisory-by-default; the harness hook is an optional bolt-on, not the spine.
- P2 Orphaning unmanaged at scale (11 ACTIVE tools unreferenced; R_NO_ORPHAN_TOOLS is new-only +
  tool-granularity; no single source of truth for "how is each tool invoked").
- P3 code-dev sprawl: 118/187 programs are code-dev-*; programs up to 506 lines of LLM-interpreted md.
- P4 The "immutable" kernel is honor-system markdown; critical invariants lack Python/hook teeth.
- P5 Footguns: strict-halt WARN==BLOCK; L:*-required flag proliferation; dual-checkout drift;
  determinism / path-independence not a default at tool birth.

Method ("100 loops"): an orchestrated loop-until-dry study — many parallel auditors across architecture
dimensions, every finding grounded at file:line + adversarially verified, completeness critics each
round, looping until rounds return nothing new. THEN plan → gated PRs (one at a time, fail-closed) →
completion audit. Flawless = converged + verified + gate-green, not first-pass.

## Follow it up
01-study.md (audit + design) → 02-plan.md + 02-prs.md → 03-prs/PR-N.md → 04-log.md → 05-audit.md.

## Start with
code-dev load axon-architecture → 01-study.md.
