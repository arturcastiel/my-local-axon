---
id: surface-handoffs-via-tool
tier: general
scope-ref: 
bindings: 
source: owner-correction-2026-05-26
date: 2026-05-26
confidence: high
privacy: private
supersedes: 
---
HANDOFF DISCIPLINE (owner correction 2026-05-26): every GATED HUMAN-ACTION point
— build, test, commit, push, merge, open-PR, a decision AXON can't make, or a
hard blocker — MUST be surfaced via TOOL(human-handoff, {reason, need, options,
context}) as a bordered block, NEVER as a sentence buried in prose. This is a
RESPONSE-CONVENTIONS.md kernel-floor mandate ("Human-action points must be ...
a bordered block, never a sentence buried in prose"). WHY: in the
2026-05-26 sessions, gated actions ("you run pytest", "this is yours to merge",
"awaiting only you: merge the branch", "give me the command") were rendered as
prose — easy to miss, and a compliance drift. ROOT CAUSE (same family as
[[artifact-identity-hard-rule-commits-prs-files-ma]] and the DAG/test gaps): the
convention is not MECHANICALLY enforced, so under a long autonomous flow it
decays to prose. HOW TO APPLY: when you reach a human-only step (e.g. the
autonomous-mode grant denies the op — kernel-change, or a non-grant repo), call
TOOL(human-handoff) with the exact need + options; do not narrate it. Choices
between options use TOOL(decide); narration uses TOOL(narrate). FOLLOW-UP (to-do
ccc8e2b0): make this mechanical — a check that flags prose-handoff phrases not
wrapped in a handoff render. Until then, self-discipline + this memory.
