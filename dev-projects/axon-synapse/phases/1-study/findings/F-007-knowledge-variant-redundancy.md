# F-007: `code-dev-knowledge-X` variants exist alongside `code-dev-X` — taxonomy needs reconciliation

**Severity:** medium
**Track:** T-A
**Date:** 2026-05-17

## Evidence

Programs come in apparent pairs:

| Action | Direct variant | Knowledge variant |
|--------|----------------|-------------------|
| shadow | `code-dev-shadow.md` | `code-dev-knowledge-shadow.md` |
| impact | `code-dev-impact.md` | `code-dev-knowledge-impact.md` |
| reviewer-track | `code-dev-reviewer-track.md` | `code-dev-knowledge-reviewer-track.md` |
| explain | `code-dev-explain.md` | `code-dev-knowledge-explain.md` |
| (no direct) | — | `code-dev-knowledge.md` |

Additional self-review collision:

| `code-dev-self-review.md` | `code-dev-review-self.md` |
|---|---|
| (likely user-facing) | (likely internal naming convention) |

Other suspected redundant pairs (not confirmed without reads):

- `code-dev-init.md` vs `code-dev-new.md` (already known: init = v3, new = v4)
- `code-dev-safety-audit.md` vs `code-dev-safety-audit-structure.md`
- `code-dev-pr-review.md` vs `code-dev-review.md`

## Hypothesis

The `code-dev-knowledge-*` family is likely the **read-only indexer / shadow
side** of a write-or-mutate action — same problem domain, different role.
E.g. `code-dev-shadow` *captures* a shadow file (writes); `code-dev-knowledge-shadow`
*indexes / queries* existing shadow files (reads). If true, the naming pattern
is semantically meaningful but the convention is not documented.

This must be verified by reading each pair's source.

## Why this matters for the synapse model

The suggester ranker (D-010) cannot disambiguate two programs with similar
names without role metadata. A user typing free-text "shadow this" needs to be
routed to *the writer*; a user typing "what did the last shadow find?" needs
*the reader*. Without `role:` declared per synapse (`mutator | reader | gate |
renderer`), the orchestrator will mis-route.

This connects to F-003 (single-axis category drift) — `role` is one of the
multi-axis tags proposed there.

## Implication for Phase 2 / Phase 3

- The synapse contract must include a `role:` field with a fixed vocabulary.
- Migration audit: every program with a `code-dev-knowledge-X` counterpart must
  declare its role + reference its sibling.
- Naming convention: codify whether `knowledge-` is the canonical reader prefix
  or migrate to a clearer pattern (e.g. `code-dev-shadow-read.md` / `code-dev-shadow.md`).

## Suggested action

- **T-A batch 2 follow-on.** Pair-by-pair read of the 5 known pairs above.
  Document each in `helpers/program-pairs.md` with declared vs actual role.
- **Phase 2 design Q.** Role taxonomy + naming convention. Resolve self-review
  collision (pick one canonical name; the other becomes a forwarder).
- **Phase 3 PR seed.** `code-dev-program-pair-audit` — extends `axon-audit` to
  detect future pairs and require `role:` declarations.
