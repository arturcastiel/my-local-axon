# F-016: Shadow tool is full-featured but coverage is 0 % across all 6 existing dev-projects

**Severity:** high (critical for D-23 enforcement)
**Track:** T-G
**Date:** 2026-05-17
**Linked demands:** D-23 (shadowing enforced)
**Linked decisions:** D-011

## Evidence

### Tool is built

`shadow` tool (`tools/shadow.py`) — Status ACTIVE, Category code-dev.

Subcommands declared:
- `check --file <path> --shadow-dir <dir>`
- `hash --file <path>`
- `init --file <path> --shadow-dir <dir> --hash <hash>`
- `append --shadow-path <path> --section <section> --content <text>`
- `list --shadow-dir <dir>`
- `stats --shadow-dir <dir>`
- `stale --shadow-dir <dir> --codebase <root>`

Design: content-addressed, git-hash matched, append-only findings log per
file. Zero re-analysis tokens on hash match. **High-quality plumbing.**

### Coverage in dev-projects = 0 %

| Project | PR specs | Shadow files |
|---------|---------|--------------|
| axon-cleanup | 25 | **0** |
| axon-docs | 1 | **0** |
| axon-master | 55 | **0** |
| axon-synapse | 0 | 0 (no PRs yet — expected) |
| axon-tests | 21 | **0** |
| axon-user | 17 | **0** |

**Total: 119 PR specs, 0 shadow files written.**

`shadow/` subdirectories exist in some projects (scaffolded) but contain
zero `.findings.md` files. The tool is built. The convention is documented
(per `code-dev-pr-review.md` line 95: "Shadow updated after every file edit
— never batch shadow writes"). **Nobody writes shadows.**

### Why the gap

Speculation (to verify in T-G follow-up):

1. **Discretionary, not enforced.** No gate today fires "ASSERT shadow
   exists for every source-touching PR." `code-dev-safety-audit` reads
   plans + logs but does not assert shadow coverage.
2. **`code-dev-shadow` is a DEPRECATED ALIAS** (F-012 update — same pattern
   as `code-dev-audit`, `code-dev-pr`, `code-dev-finalize`):
   ```
   # PROGRAM: code-dev-shadow
   # desc: DEPRECATED — alias for code-dev-knowledge-shadow; removed next release.
   ```
   The canonical name is `code-dev-knowledge-shadow`, but the documented
   name in `code-dev-pr-review` chains is `code-dev-shadow`. User-typed
   command flows through a deprecation alias.
3. **PR-review fires shadow** in its master logic, but if the PR-review
   FSM itself is not run (or run partially), no shadow gets written.
   The master `code-dev-pr-review.md` does CALL `TOOL(shadow, ...)`
   (17 callers per F-004), but actual usage was zero across 119 PRs.
4. **No CI gate.** `axon-audit` doesn't surface shadow coverage as a
   first-class metric.

## Why this matters

- **D-23 is the user's explicit "DON'T FORGET" directive.** Current state
  proves the directive is necessary — the tool exists, the convention is
  documented, and yet coverage is zero.
- **D-11 (mandatory shadowing per D-011)** is now backed by hard data.
  The decision is correct; enforcement is what's missing.
- **Synapse contract migration** (D-005/D-006/D-013) — if shadow files
  don't exist, the synapse can't reference findings about source files
  it touched. The post-state assertion `shadow.has({file}) == true` can't
  be checked.

## Implication for Phase 2 / Phase 3

- **Phase 2.** Spec shadow enforcement gates:
  - `code-dev pr finalize` (or its real implementation per F-012) → ASSERT
    every changed file has a shadow entry.
  - `code-dev safety-audit` → REPORT shadow coverage % per phase; FAIL if
    < threshold.
  - Synapse contract for source-touching synapses → `post-state` includes
    `shadow.contains(touched-files)`.
- **Phase 3 PR seeds:**
  - `shadow-coverage-enforce-finalize` — add the gate.
  - `shadow-coverage-report-audit` — add to `axon-audit` + `code-dev safety-audit`.
  - `shadow-retroactive-bulk` — generate shadow files for the 119 existing
    PRs across all dev-projects from git diff + finding references. Mass
    migration tool.
  - `code-dev-shadow-alias-formalize` — per F-012, alias name preserved
    permanently with explicit `# alias-of: code-dev-knowledge-shadow`.

## Audit-trail link

- D-23 met when: ∀ source-touching PR. shadow file exists AND non-empty AND
  cites ≥ 1 finding. (`_demands.md`).
- Today's audit value: 0 / 119 (0 %). Phase 3 closing PR must drive this
  to 100 % via the retroactive migration tool.
