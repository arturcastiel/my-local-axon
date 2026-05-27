# CD·TOOLS·P1 — inventory + overlap matrix

> Re-classify the 57 code-dev programs as "tools" and find functional overlaps. The question this study answers: *what would code-dev look like if we organized by user verb rather than by file?*

## Two ways to view the surface

**Today (file-centric):** 57 programs, one verb per file. `code-dev-pr-respond.md`, `code-dev-pr-update-spec.md`, etc.

**Proposed (verb-centric):** ~10 top-level verbs, each with `--mode` / `subcommand`. `code-dev pr respond`, `code-dev pr update-spec`, `code-dev pr review`, …

This helper inventories overlaps. Umbrellas + merges are in `cd-tools-p2-umbrella.md`. Migration is in `cd-tools-p3-migration.md`.

## Functional clusters (proposed)

| Cluster        | Programs today                                                | What they share |
|----------------|---------------------------------------------------------------|-----------------|
| **lifecycle**  | new · init · load                                              | scaffold or switch project context |
| **state**      | status · next · resume · handoff · tour · metrics              | read-only dashboards / briefings |
| **journal**    | log · decision · event · since · search · replay               | append/query the project's audit trail |
| **pr**         | pr · pr-update-spec · pr-ready · pr-link · pr-github · pr-respond · pr-review · pr-explain (= explain N) | manipulate a single PR spec + its review state |
| **review**     | review · scope-check · self-review · suggest-tests · diff · explain-reviewer · reviewer-track | inspect implementation vs spec |
| **shape**      | combine · divide · partition · link · phase-new · phase-start · plan-master | mutate the phase/PR graph |
| **safety**     | freeze · hold · dont-do · tag · undo · preflight · check-structure | guard or rewind mutations |
| **knowledge**  | study · shadow · explain · impact                              | extract/cache structured knowledge from sources |
| **flow**       | plan · merge · cascade · changelog · audit · test-map         | drive a phase/PR forward (or close it out) |
| **meta**       | whatif · help · code-dev (router)                              | introspection / dispatch |

10 clusters × ~5 programs = ~50 active. The other 7 are noise (router itself, schema doc, etc.).

## Overlap matrix (high-overlap pairs)

| A                  | B                       | Overlap | Merge candidate? |
|--------------------|-------------------------|---------|------------------|
| combine            | partition (`split` mode)| same op, v4 unifies them | **YES — fold** |
| divide             | partition (`merge` mode)| same op, v4 unifies them | **YES — fold** |
| hold               | freeze + thaw            | hold is an alias            | **YES — fold** |
| check-structure    | audit (`--structure` mode)| both audit folders          | **YES — fold as sub-mode** |
| diff               | review (`--mode=diff`)   | review already routes others | **YES — fold as sub-mode** |
| since              | search (`--since` flag)  | timeline filter              | **YES — fold as flag** |
| replay             | search (`--patterns` mode)| pattern mining over history  | **YES — fold as mode** |
| explain-reviewer   | reviewer-track (`--reviewer X --history`) | per-reviewer view | **YES — fold as flag** |
| pr-link            | link (`--pr` flag)       | both maintain link tables    | partial — keep both for now |
| tag                | undo                     | both snapshot/restore         | **YES — fold into `state`** |
| init               | new                       | both scaffold project         | partial — new is user-facing, init is library |
| log + decision + event | (one verb "journal")  | three different append-only logs | **YES — group as `journal log|decision|event`** |
| reviewer-track     | pr-respond / pr-review    | view vs mutate reviewer-state | keep separate, group under `pr review` |

## Pure redundancies (safe to retire)

| Program            | Reason | Action |
|--------------------|--------|--------|
| `code-dev-combine` | superseded by `partition merge` | retire, alias-stub for 1 release |
| `code-dev-divide`  | superseded by `partition split` | retire, alias-stub for 1 release |
| `code-dev-hold`    | alias for `freeze` (per source) | retire, alias-stub |
| `code-dev-since`   | becomes `search --since` | retire, flag-rewrite |
| `code-dev-replay`  | becomes `search --patterns` | retire, flag-rewrite |
| `code-dev-diff`    | becomes `review --mode=diff` | retire, flag-rewrite |
| `code-dev-check-structure` | becomes `audit --structure` | retire, flag-rewrite |
| `code-dev-explain-reviewer` | becomes `reviewer-track --reviewer X --history` | retire, flag-rewrite |

**Surface reduction:** 8 programs retired → 49 programs (was 57).

## Near-duplicates with distinct concerns (keep, but co-locate)

| Pair                  | Why distinct | Co-locate as |
|-----------------------|--------------|--------------|
| pr · pr-update-spec   | create vs amend; both touch spec | `pr create N` / `pr update-spec N` |
| pr-ready · preflight  | wrapper vs gates                  | `pr ready` invokes `preflight --quick` |
| pr-link · link        | PR-level vs project-level         | `pr link` / `link` (keep parallel) |
| tag · undo            | user save vs system step-back     | `state save <label>` · `state undo` |
| new · init            | interactive vs library            | `new` calls into `init` (already does) |
| log · decision · event| user log vs ADR vs typed-event    | `journal log|decision|event` |
| freeze · dont-do      | phase pause vs prohibition       | both under `safety` but distinct verbs |

## High-traffic single-purpose programs (do NOT merge)

These are too central or too distinct to bundle:
- `code-dev` (router) — keep as-is.
- `code-dev study` — Phase-1 ingestion is its own domain.
- `code-dev plan` — Phase-2 planning is its own domain.
- `code-dev shadow` — content-addressed index; the substrate.
- `code-dev audit` — Phase-5 cross-reference is its own domain.
- `code-dev preflight` — 11 gates; load-bearing.

## Quantified overlap summary

- 57 programs today
- 8 retire candidates (pure redundancy) → 49
- 7 near-duplicates kept but grouped under top-level verbs
- New top-level verbs proposed: `pr`, `review`, `journal`, `state`, `safety`, `shape`, `flow`, `knowledge`, `lifecycle`, `meta` (10)

## Cost of NOT consolidating
- Discoverability: `code-dev list` shows 57 items; users (and `next`) must rank them.
- Dispatch: free-text routing to "review my pr" has to discriminate among `review`, `pr-review`, `self-review`, `pr-respond`, `reviewer-track`, `explain-reviewer`, `diff`.
- Maintenance: 8 programs that are aliases/redundant carry their own `## HELP`, identity-lock blocks, etc. Each is ~80 lines of duplication.
- Token spend: every retire candidate loads ~3–8 KB of source. Eliminating 8 saves ~30–50 KB of source from the workspace surface area.

## What this study is NOT proposing
- Not renaming `code-dev-*.md` files randomly.
- Not breaking the user CLI surface (aliases stay 1 release).
- Not merging programs that have distinct *concerns* even when their *implementations* overlap.
- Not introducing dynamic dispatch in the kernel — verbs are still files.

→ proposed umbrella naming + new verb shapes in `cd-tools-p2-umbrella.md`.
→ migration steps in `cd-tools-p3-migration.md`.
→ external alignment in `cd-tools-p4-prior-art.md`.
