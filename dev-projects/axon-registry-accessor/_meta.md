# Project: axon-registry-accessor
slug:            axon-registry-accessor
schema-version:  v4
status:          complete
phase:           audit
workflow-step:   study
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-architecture
created:         2026-05-30
updated:         2026-05-30

## Working Context
Goal: One shared REGISTRY accessor; migrate the 22 independent parsers off it (F22).
Deferred from axon-architecture as a risky refactor (held by "nothing breaks"); now its own code-dev
project so it gets a proper study + plan before any execution. Execution awaits owner greenlight.

## Start with
code-dev load axon-registry-accessor -> 01-study.md
