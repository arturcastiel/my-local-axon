---
id: verify-before-build-plans-drift
tier: general
scope-ref: 
bindings: 
source: owner directive 2026-05-27
date: 2026-05-27
confidence: high
privacy: private
supersedes: 
---
STANDING RULE (owner, 2026-05-27): before building ANY planned item, AUDIT what is already implemented in the CANONICAL tree (new-axon/axon) — plans drift and features are often already done. Update the project's tracking (masterplan/04-log/_meta) to match reality, THEN build only the genuine gap. EVIDENCE this session: dag-consistency '2-cascade' was already wired (all 7 mutation programs had TOOL(dag,...) ops; the 04-log still said REMAINING); axon-tests '5-enforce' was already satisfied by crucible (pytest BLOCK + R_NEW_NEEDS_TEST); prompt-log just got enabled (axon-ascent plan still lists it 'off'); the '13 orphan' compiled mirrors were actually valid axon/programs/ core mirrors. WATCH: some project _meta.codebase fields point at STALE trees (e.g. axon-ascent -> axon-development/axon; axon-tests -> /mnt/c) — verify against new-axon, not the stale path. HOW TO APPLY: per workstream, run a quick reality audit first (grep/ls/run the tool), reconcile tracking, only then implement. Relates to [[canonical-axon-tree-is-new-axon]] [[autonomous-loop-wired-resume-pointer]].
