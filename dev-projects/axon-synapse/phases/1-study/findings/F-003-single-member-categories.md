# F-003: Category drift — single-member categories suggest ad-hoc taxonomy

**Severity:** medium
**Track:** T-A
**Date:** 2026-05-17

## Evidence

REGISTRY.json category distribution across 75 tools:

| Category | Count |
|----------|-------|
| `kernel` | 40 |
| `os` | 29 |
| `audit` | 2 |
| `code-dev` | 1 |
| `documentation` | 1 |
| `docs` | 1 |
| `host` | 1 |

Observations:

1. **`documentation` and `docs` co-exist** — same concept, different label. Likely
   ad-hoc creation by two different authors / sessions.
2. **`code-dev` has only 1 tool** despite `code-dev` being the dominant program
   family (`workspace/programs/code-dev-*.md` = 60+ programs). Programs are
   classified informally by filename prefix; tools are not categorized to match.
3. **`host` has 1 tool** — likely something harness-specific. Unclear if a future
   harness adds more or if `host` is a permanent singleton.
4. **`kernel` vs `os`** — distinction not documented anywhere. 69 of 75 tools
   land in these two buckets with no clear principle.

## Why this matters for the synapse model

Category is one of the **ranker signals** the suggestion engine would naturally
use ("user is in code-dev workflow → boost code-dev category"). Today category
is too coarse (`kernel`+`os` = 92 % of tools) and too inconsistent
(`docs` vs `documentation`).

A program-family-aware category set would let the suggester reason about
"which tools serve this workflow."

## Implication for Phase 2 / Phase 3

- New category taxonomy needs design. Candidates:
  - **By workflow served**: `boot`, `code-dev`, `library-dev`, `journal`,
    `quality`, `meta`, `host-integration`.
  - **By layer**: `kernel`, `os`, `workspace`, `user`.
  - **By role**: `read-only`, `mutator`, `gate`, `verifier`, `renderer`.
- Multi-axis tagging (each tool has `family:`, `layer:`, `role:`) is likely the
  right answer — single-axis category is the source of drift.

## Suggested action

- **Phase 2 design Q.** Multi-axis tag schema for REGISTRY. Migration tool that
  preserves existing single category as one of the axes.
- **Phase 3 PR seed.** Merge `docs` ∪ `documentation` immediately (low-risk
  rename). Defer broader retag until Phase 2 schema lands.
