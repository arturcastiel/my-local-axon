# CD·STUDY·C3·P1 — plan modes: full design

> Concrete design for each of the 10 plan modes, including inputs, outputs, and ranking rules.

## Mode 1 — `execution` (default)

**Purpose:** Ship-ordered list of PRs with dependencies.
**Inputs:** `study/*.md`, `_meta.goals`, `safety/rules.md`.
**Ranking:**
1. Hard-block items (security CRITICAL, broken build).
2. Items unblocking other items (deps).
3. Items with smallest blast radius first.
4. Items with declared goal alignment.
5. Cleanup last.

**Output skeleton:**
```
# 02-prs.md (execution mode)
| PR | Title | Touches | Depends | Severity | Est | Goal |
|----|-------|---------|---------|----------|-----|------|
| 1  | ...   | src/x   | —       | high     | M   | A    |
```

## Mode 2 — `risk-first`

**Purpose:** Maximum-severity-first.
**Ranking:** sort by `severity DESC, blast-radius ASC`.
**Distinct output:** flags severity prominently.
**Used by:** WF-S2, WF-S3.

## Mode 3 — `budgeted`

**Purpose:** Cap to top-N items.
**Flag:** `--budget N` (or `--budget hours=20` or `--budget tokens=40000`).
**Output:** `02-prs.md` truncated; overflow in `02-prs.deferred.md`.
**Used by:** WF-S9.

## Mode 4 — `constrained`

**Purpose:** Honor explicit rules.
**Flag:** `--rule "<text>"` (repeatable).
**Logic:** plan reasoning is prefixed with the rules. Items violating rules are filtered with a note.
**Output:** `02-prs.md` with a "Rules honored" section.
**Used by:** WF-S5.

## Mode 5 — `multi-dev`

**Purpose:** Parallelize.
**Flag:** `--multi-dev K`.
**Logic:** partition by file-set isolation; minimize cross-track deps.
**Output:** K tracks (`02-prs.track-A.md`, etc.).
**Used by:** team workflows.

## Mode 6 — `replay`

**Purpose:** Re-evaluate prior plan.
**Flag:** `--replay [--from <commit-or-date>]`.
**Logic:** read prior 02-prs.md; for each entry, compute current state (`MERGED`, `IN-FLIGHT`, `OUTDATED`, `DROPPED`, `STILL VALID`).
**Output:** annotated copy; can be re-promoted with `--commit` flag.
**Used by:** WF-S2, audit.

## Mode 7 — `cost`

**Purpose:** Cheapest-first.
**Logic:** sort by `est-tokens ASC, est-hours ASC`.
**Use case:** budget-constrained sprints.

## Mode 8 — `alignment`

**Purpose:** Rank by stated goals.
**Logic:** read `_meta.goals: ["perf", "security"]`. Score each PR's match.
**Output:** column `goal-fit` (0..1) per entry.
**Used by:** leadership review.

## Mode 9 — `exploratory`

**Purpose:** Cast wide net; minimal filtering.
**Logic:** include all plausible items, even contradictory ones; group by theme; let user prune.
**Output:** thematic groupings rather than ranked list.
**Used by:** WF-S6 (brownfield).

## Mode 10 — `dry`

**Purpose:** Preview without writing.
**Flag:** `--dry`.
**Logic:** echo to stdout/chat only; no `02-prs.md` mutation.
**Used by:** anyone exploring.

## Cross-mode rules

- All modes emit a **"STUDIES SUGGESTED NEXT"** footer.
- All modes honor `--budget` even when the mode has another primary criterion (cap is universal).
- All modes write a `journal event plan.<mode>` entry.
- All modes accept `--dry` as a meta-flag.
- All modes accept `--rule` (constraint injection).

## Mode interaction matrix

| Combinable?    | exec | risk | budget | constr | multi-dev | replay | cost | align | explore |
|----------------|:----:|:----:|:------:|:------:|:---------:|:------:|:----:|:-----:|:-------:|
| `--budget`     | ✓    | ✓    | (self) | ✓      | ✓         | ✓      | ✓    | ✓     | ✓       |
| `--rule`       | ✓    | ✓    | ✓      | (self) | ✓         | ✓      | ✓    | ✓     | ✓       |
| `--dry`        | ✓    | ✓    | ✓      | ✓      | ✓         | ✓      | ✓    | ✓     | ✓       |
| `--multi-dev`  | ✓    | ✓    | ✓      | ✓      | (self)    | ✗      | ✓    | ✓     | ✓       |
| `--replay`     | ✓    | ✓    | ✓      | ✓      | ✗         | (self) | ✓    | ✓     | ✗       |

`✗` = explicit incompatibility (e.g., `replay` + `multi-dev` would split history into tracks — unsupported).

## Output format

Each plan output is a single markdown file with a fixed top section:

```
# 02-prs.md (<mode>)
> Generated 2026-05-16T10:00Z by code-dev flow plan --mode=<mode>
> Inputs: study/* (<n> files), _meta.goals=[...], safety/rules=<n>

## Summary
<paragraph>

## PRs (ordered)
| ... |

## Rules honored
- ...

## Studies suggested next
- ...

## Deferred (if any)
- see 02-prs.deferred.md
```

## Migration story

- `flow plan` (no args) defaults to `--mode=execution` (matches today's behavior).
- `flow plan --epic` ≡ today's `plan-master`.
- All new modes are additive.
- Existing tests of `plan` continue to pass.

→ next: study mode definitions in detail: `cd-study-c3-p2-study-modes-detail.md`.
