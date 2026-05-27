# F-004: Top-20 caller list defines AXON's "core call surface" — anchor for synapse contract migration

**Severity:** low
**Track:** T-A
**Date:** 2026-05-17

## Evidence

Top 20 tools by `workspace/programs/*.md` caller count:

| Rank | Tool | Callers | Category | Role inference |
|------|------|---------|----------|----------------|
| 1 | `clock` | 64 | os | timestamp utility, ubiquitous |
| 2 | `shell` | 33 | host | shell passthrough, structural |
| 3 | `shadow` | 17 | code-dev | shadow index (code-dev family) |
| 4 | `calculator` | 13 | os | math gate (R3 rule) |
| 5 | `cd_cache` | 9 | os | code-dev cache bundle |
| 6 | `session` | 6 | os | per-chat session state |
| 7 | `web-search` | 5 | os | external search |
| 8 | `drift` | 4 | kernel | drift score tracker |
| 9 | `events` | 4 | kernel | event bus |
| 10 | `igap` | 4 | kernel | inference gap tracker |
| 11 | `memory` | 3 | kernel | W/L/E scope ops |
| 12 | `rules` | 3 | os | governance rules loader |
| 13 | `auto-audit` | 2 | kernel | auto-action ledger |
| 14 | `usage` | 2 | kernel | usage tracker |
| 15 | `pr_aggregate` | 2 | os | PR list aggregator |
| 16 | `study_index` | 2 | os | study index maintainer |
| 17 | `simulate` | 2 | kernel | dry-run program |
| 18 | `deps` | 2 | kernel | program deps graph |
| 19 | `context` | 2 | kernel | context pressure |
| 20 | `prompt-log` | 2 | kernel | session prompt logger |

## Observations

- `clock` dominates (64 callers) — almost every program timestamps something.
- `shell` is the second-most-called tool but is `category: host`, dispatched by
  the harness, no Python script. Coupling to host harness is structural.
- `shadow` ranks #3 with 17 callers — D-011 (mandatory shadowing) is reinforced
  by this real usage; shadow infrastructure is already embedded.
- A long tail begins at rank ~10: most kernel-category tools have ≤4 callers.
  Suggests sparse but specific usage patterns — synapse contract migration
  should prioritize the long-tail tools (where suggestion engine has the most
  to gain by surfacing them).

## Why this matters for the synapse model

The top-20 represents the **call surface** the orchestrator works against.
A synapse contract migration (D-005) should start here:

1. **Bulk-infer** post-state/precondition for the top-20 from their Python sources
   (high-yield: 64-caller `clock` is a no-side-effect read; 17-caller `shadow`
   produces a versioned index).
2. **Declared override** opportunity is highest for the kernel-category tools
   where author intent is most easily expressible.
3. **Suggestion-engine seed** — for free-text intent classification, the top-5
   tools (clock, shell, shadow, calculator, cd_cache) likely cover ~60 % of
   "what should run next" decisions.

## Implication for Phase 2 / Phase 3

- Phase 2 synapse-contract spec must accommodate "read-only utility" tools like
  `clock` and `shell` (precondition: ∅; post-state: ∅; next-conditional: ∅).
- Phase 3 migration order: top-20 → next-30 → long tail. Each batch produces a
  finding sub-file under `findings/T-D/`.

## Suggested action

- **Phase 2 design Q.** Synapse contract minimum-viable schema, validated against
  these 20 tools as the corpus.
- **Phase 3 PR seed.** `synapse-contract-migrate-top20` — single PR migrating
  the call-surface anchor tools.
