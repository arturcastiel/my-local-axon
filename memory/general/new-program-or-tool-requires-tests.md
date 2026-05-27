---
id: new-program-or-tool-requires-tests
tier: general
scope-ref: 
bindings: 
source: owner-directive-2026-05-26
date: 2026-05-26
confidence: high
privacy: private
supersedes: 
---
HARD DEVELOPMENT RULE (owner directive 2026-05-26): every NEW program added to
AXON (workspace/programs/*.md) and every NEW tool (tools/*.py + REGISTRY entry)
MUST ship tests. No new capability grows the OS without a test. This is enforced
mechanically by the `crucible` control `R_NEW_NEEDS_TEST` (BLOCK severity): on a
diff vs merge-base, an added program without a referencing test, or an added tool
without tests/test_<tool>.py (or a registered crucible control naming it), fails
the gate and blocks merge. WHY: testing is mandatory before anything is "done"
(same owner); an untested addition is debt that the autonomous merge loop must
not let through. HOW TO APPLY: when authoring a program/tool, write tests/ in the
same PR and register the control in tools/crucible.json; the PR-0 autonomous loop
calls `crucible gate` pre-merge, red ⇒ no merge. Crucible is the canonical home
for all controls + tests as AXON grows. Related: [[operating-mode-be-axon-not-using-axon-in-the-bac]] (BE AXON, track state here), and the artifact-identity rule [[artifact-identity-hard-rule-commits-prs-files-ma]] which crucible also enforces via R_MEMORY_RESPECTED.
