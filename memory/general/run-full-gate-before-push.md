---
id: run-full-gate-before-push
tier: general
scope-ref: 
bindings: 
source: session-2026-05-26-axon-gap-closure
date: 2026-05-26
confidence: high
privacy: private
supersedes: 
---
DEVELOPMENT DISCIPLINE: run the FULL crucible gate (the whole pytest suite +
verify rule-predicates), NOT a targeted subset, before every push/merge.
WHY: in the 2026-05-26 gap-closure session, pushing on targeted tests alone
twice let real regressions through — (1) a library-dev-search source that
failed R_TOOL_CALL_EXISTS because TOOL(library, gap-queries) had no CLI
subcommand, and (2) a config.md missing its ## OUTPUT banner. Both were caught
only when the full suite ran. The compile-optimizer-verify, program-structure,
and lint-code checks live OUTSIDE the targeted files you just edited, so a
narrow run is blind to source/mirror/structure drift. HOW TO APPLY: after any
program/tool change, run `crucible gate` (or `pytest tests/ -q`, deselecting only
the 2 known-environmental failures: the /mnt/c gitignored session-state
lint-paths and the reasoning-trace-unset WARN — both pass in clean CI). Push only
on 0 real failures. This operationalizes [[new-program-or-tool-requires-tests]]:
having the test isn't enough — you must RUN the whole gate.
