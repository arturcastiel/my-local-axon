# Project: AXON coverage-gap closure (validated from the deep-study)
slug:            axon-coverage
schema-version:  v4
status:          active
legacy:          false
phase:           1-study
workflow-step:   study
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-04
updated:         2026-06-04

## Working Context
Source: the external **AXON coverage deep-study** (/mnt/c/manipulation/Presentations/AXON-coverage-deep-study-
2026-06-04.md), written about a DIFFERENT, *production* AXON instance (the OPM/reservoir-engineering one —
opm-common · compositional-keyword · opm-dual-porosity). (The "field-separation/gas-plant" doc is unrelated —
owner confirmed; ignore it.) The study found, for that instance: telemetry **inert**, memory tiers **empty**,
an 8-item **GAP list** of hand-rolled work (ship / status-deck / pr-github / amend-push / import-principles /
reviewer-track-populate / knowledge-manual / dag-cascade), and cleanup items (semantic-search stale, rtk
OPTIONAL, dangling refs).

Goal of THIS project: those claims are about the OTHER instance — so **validate each against THIS dev axon
(the shared AXON core)**, then close only the gaps that are *real here*, gate-first per the established
workflow. This dev axon has **diverged** (the just-finished re-MEGA — !135–140 — fixed new-chat/plan-new, the
compile pipeline, liveness, etc.), so several claims are already-fixed and must NOT be redone. `01-study.md` =
the validation + scope. NEXT: study → (sufficient?) → plan → pr → build.
