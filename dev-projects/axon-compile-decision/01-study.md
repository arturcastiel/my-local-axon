# Phase 1 — STUDY · axon-compile-decision

## Goal
Decide + execute: retire or repair the non-functional compile subsystem (F34).

## Current state (the finding, grounded)
F34 — 4 tools (~950 LOC) + a 154-entry quarantine (118 verbatim 1.00-ratio copies; the flagship target got WORSE at 1.01). The compiled corpus mostly exists to satisfy a freshness test; dispatch barely uses it.

## Design
STUDY decides retire-vs-repair by MEASURING achievable compression on a representative program sample. If meaningful compression is NOT achievable → RETIRE (drop test_every_program_has_compiled_output, remove verbatim copies, consolidate compile_optimizer/compile_suggest/compile-write into compile.py, remove compiled/ from dispatch). If achievable → REPAIR (real compressor, gate ratio<1.0).

## Methodology
1) Measure compression feasibility (study output). 2) Decide. 3) Execute the chosen path, gate each step. Watch dispatch-index references to compiled/.

## Risk
Dispatch + the freshness test reference compiled/; removal must update both. Gate-protected (Python + tests).

## Confidence
7/10 — leaning RETIRE (the data says compression isn't working); the measurement de-risks the decision.

## Gate to PLAN
Owner confirms STUDY (or adds requirements). Per the discipline, PLAN numbers the PRs before any code.
