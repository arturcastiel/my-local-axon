# Phase: 1-study
schema-version: v4
status:         active
workflow-step:  study
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    (none — entry phase)
successor:      (2-plan — goal set by user after Q&A)
source-repo:    /home/arturcastiel/projects/Claude-for-reservoir-engineering

## Goal of this study
Study EVERYTHING in the source repo + relevant online material, in several
layers, and answer: how to use AXON's workflow machinery to produce a new set
of reservoir-engineering programs. Specifically:
  - What reservoir tasks/workflows exist? (domain layer)
  - How do they decompose into AXON programs + workflow DAGs?
  - Do we need NEW programs? NEW tools (MCP client)? Different connections?
  - Which workflows to carve out as first-class?

## Outputs (in this folder)
- 01-study.md            — the layered study + synthesis
- _domain-taxonomy.md    — reservoir task/calculation inventory
- _workflow-designs.md   — proposed AXON workflows (Fixed/Adaptive/Hybrid)
- _new-programs.md       — catalog of programs/tools to add + reuse map
- _open-questions.md     — for the user Q&A before plan phase

## Status
In progress — iterating. Hand back for user technical Q&A when "more than satisfied".
