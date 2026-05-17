# Project: AXON Test Battery
slug:            axon-tests
schema-version:  v4
status:          active
legacy:          false
phase:           5-enforce
workflow-step:   enforce
branch:          main
codebase:        /mnt/c/projects/axon
parent:          (none)
sub-projects:    []
created:         2026-05-16
updated:         2026-05-16

## Working Context
- Goal A — exhaustive automated test battery covering all of AXON
  (kernel rules, programs, tools, workflows) and enforced as mandatory
  for any new modification to axon/.
- Goal B — study deeply enough to produce reference documentation for
  every subsystem touched (kernel rules, tool surfaces, program
  contracts, end-to-end workflows). Tests and docs are co-outputs:
  every test references the doc section it pins; every doc page lists
  the tests that guard it.
- Phase 1 = study (this phase). No code changes yet.
- Run: code-dev study  to begin.
