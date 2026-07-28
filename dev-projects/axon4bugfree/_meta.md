# Project: AXON 4 Bug-Free — improvement-backlog feasibility study (graphify-grounded)
slug:            axon4bugfree
schema-version:  v4
status:          complete
legacy:          false
phase:           complete (all 5 phases done)
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          axon-improvements
sub-projects:    []
created:         2026-07-13
updated:         2026-07-13 (COMPLETE — MR !206, canonical AXON-LANG extractor + kernel-scope gates)

## Working Context
- STUDY SUBJECT = the 8 improvement points surfaced at the close of axonbugfree3 (run 3).
- MANDATE (owner 2026-07-13): deep-study each point until we understand HOW GOOD it is —
  feasibility, blast radius, what already exists, effort, leverage — GROUNDED IN THE CODE GRAPH.
  graphify MUST be used (affected / callers / impact / file-nodes over graph/graph.json), not prose guesses.
- ⚑ GOAL SET (HR council verdict 2026-07-13, goal-2026-07-13-1): "Make AXON's self-analysis see its own
  AXON-LANG layer — GATING LINTS first, unified-graph query layer second (gated), markdown runner last."
  Owner's "markdown-blind = worthless" judged an OVERSTATEMENT (unanimous): true that the graph has zero
  AXON-LANG semantic edges, but not worthless — the dominant defect class is already partly gated by
  markdown-native lints; run-3 bugs survived on a SCOPE GAP (kernel not scanned), not a missing graph.
  Verdict + ordered goal G1-G5: COUNCIL-VERDICT.md. Council corrected the study's keystone error (runner
  is NOT the keystone; static extraction needs no interpreter).
- Deliverable: 01-study.md with a per-point verdict (BUILD / EXTEND-EXISTING / DEFER / DROP) backed by
  real graph queries; a ranked recommendation for the next run.
