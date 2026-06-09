# Project: AXON Discipline — methodology for safe growth
slug:            axon-discipline
schema-version:  v4
status:          active
legacy:          false
phase:           1-foundations
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-03
updated:         2026-06-03

## Working Context
Establish AND implement a development discipline so AXON can keep growing without silent regressions.
Born from the super-polish arc (MR !107 65-bug sweep → !108 git-op rule → !109 the 15 audit
regressions the sweep missed → !110 docs regen). The recurring root cause: logic lives in
LLM-interpreted markdown that is never executed in a test, "covered" by static text assertions that in
the worst case assert the bug itself (producer-only masking). The full charter + acceptance criteria
are in `masterplan.md`; the complete evidence, diagnosis, inventory, gaps, and 7-principle methodology
are seeded in `phases/1-foundations/01-study.md`. Hard constraints (merge discipline, anti-masking law,
no bulk PRs, gate-first) are in `_dont-do-seeds.md`.

NEXT (overnight): code-dev load axon-discipline → code-dev study (refine 01-study) → code-dev plan
(produce the PR breakdown) → code-dev pr … → gate green → merge per discipline.
