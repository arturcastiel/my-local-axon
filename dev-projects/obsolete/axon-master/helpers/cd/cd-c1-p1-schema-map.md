# CD·C1·P1 — code-dev schema map (v1 vs v4)

> Authoritative reference: `workspace/programs/_code-dev-schema-v4.md`. Files, where they live, what they hold, what's new vs v1, and the migration story.

## v4 project layout
```
my-axon/dev-projects/<slug>/
├── _meta.md                 (schema-version: v4, slug, status, phase, workflow-step,
│                              codebase, branch, current-pr, next-action, last-program, last-ts)
├── _profile.md              (reviewers, base-branch, linter, test-strategy,
│                              cross-repo siblings, changelog-path)
├── _dont-do-seeds.md        (initial prohibitions; v1 compat)
├── _actions.log             (append-only — ts, action-id, op, target, snapshot-path)  ★NEW v4
├── _events.log              (append-only — ts, kind, detail)                          ★NEW v4
├── _pr-links.md             (PR dep graph: depends-on / blocks)                       ★NEW v4
├── _links.md                (cross-project deps table)                                ★NEW v4
├── 04-log.md                (append-only impl log + SESSION START/RESUME markers)
├── 05-audit.md              (final audit output — written by code-dev-audit)
├── 05-branches.md           (branch → PR registry)                                    ★NEW v4
├── archive/                 (post-merge snapshots — automatic)
└── phases/<phase-name>/
    ├── _meta.md             (next-action, last-program, last-ts, workflow-step)
    ├── _profile.md          (per-phase overrides; optional)
    ├── _dont-do.md          ([scope] / [pattern] / [process]; ~~strike~~ for retired)
    ├── _decisions.md        (ADRs — ADR-NNN-slug sections; supersedes tracking)
    ├── _files.md            (files in scope; scope-check authoritative source)
    ├── 01-study.md          (Phase-1 study output)
    ├── 02-plan.md           (Phase-2 plan)
    ├── 02-prs.md            (Phase-2 PR list)
    ├── 03-prs/
    │   ├── PR-001.md                          (spec)
    │   ├── PR-001-explain.md                  (deep-dive annotation)
    │   ├── PR-001-github-description.md       (paste-ready GitHub body)
    │   ├── PR-001-HARMONIZATION.md            (pr-review 9-phase output)
    │   └── PR-001/reviewer-state.md           (objections table)
    ├── reviews/round-N-response.md            (response drafts to reviewer rounds)
    ├── handoff.md                              (session handoff briefing)
    ├── impact.md                               (API impact)
    ├── snapshots/                              (combine/divide; auto-archived on merge)
    └── shadow/src/<rel-path>.findings.md      (content-addressed source shadow)
```

## v4 _meta fields (full)
| Field            | Required | Type     | Notes |
|------------------|---------|----------|-------|
| `schema-version` | ✓       | string   | `v4` |
| `slug`           | ✓       | string   | dirname |
| `status`         | ✓       | enum     | `active` / `merged` / `archived` / `frozen` |
| `phase`          | ✓       | string   | active phase folder name |
| `workflow-step`  | ✓       | enum     | `study`, `plan`, `build`, `re-implementing`, `review`, `merged`, `frozen:<reason>` |
| `codebase`       | ✓       | path     | absolute path to target repo |
| `branch`         | ✓       | string   | working branch name |
| `current-pr`     | ✗       | string   | e.g. `PR-003` |
| `next-action`    | ✗       | string   | resume hint |
| `last-program`   | ✗       | string   | most recent code-dev-* invoked |
| `last-ts`        | ✗       | ISO date | last write |
| `legacy`         | ✗       | bool     | force v1 behavior |
| `parent` / `sub-projects` | ✗ | str/list | project tree |

## v1 layout (legacy)
```
my-axon/dev-projects/<slug>/
├── _meta.md                 (bare: slug, status, phase, codebase)
└── helpers/                 (free-form helper files, e.g. c1-p1-*.md)
```
- No `_actions.log`, no events, no PR specs, no reviewer-state, no shadow.
- This study project (`axon-master`) is v1.

## v4 ↔ v1 deltas
| Aspect            | v1                       | v4 |
|-------------------|--------------------------|----|
| Schema marker     | implicit                 | `schema-version: v4` |
| Workflow tracking | only `phase`             | + `workflow-step`, `next-action`, `last-program`, `last-ts` |
| Undo              | none                     | `_actions.log` + `snapshots/` + `code-dev-undo` |
| Event journal     | none                     | `_events.log` (typed kinds) |
| PR deps           | none                     | `_pr-links.md` |
| Cross-project deps| none                     | `_links.md` |
| ADR supersession  | none                     | tracked in `_decisions.md` headers |
| Session recovery  | none                     | SESSION START / SESSION RESUME markers in `04-log.md` |
| Acceptance proofs | implicit / prose         | explicit `proof:` lines, quoted in responses |
| Prohibitions tags | flat list                | `[scope]` / `[pattern]` / `[process]` typed |
| Branch registry   | none                     | `05-branches.md` |
| Resume program    | not supported            | 10-layer briefing, v4-gated |
| Shadow index      | n/a                      | per-phase `shadow/` (git-hash addressed) |

## v1 → v4 migration story
- **No automatic migrator exists.** Programs schema-gate themselves:
  - `code-dev-resume` / `code-dev-branch` / `code-dev-phase-new` / `code-dev-phase-start` ASSERT v4 → HALT on v1.
  - `code-dev.md` reads `schema-version | "v1"`; disables v4-only features.
  - `legacy: true` in `_meta.md` opts out of v4 even if marker present.
- v1 projects keep working for the older flow (`status`, helpers/, study/plan as ad-hoc docs).
- **Gap (cycle 3 backlog):** `code-dev-migrate-v4` does not exist (G-CD-M1).

## Mandatory vs optional (v4)
| File                          | Required | Creator |
|-------------------------------|----------|---------|
| `_meta.md`                    | ✓        | `code-dev-init` / `-new` |
| `phases/<phase>/_meta.md`     | ✓        | `code-dev-phase-new` |
| `_profile.md`                 | ✗        | user (defaults applied) |
| `_dont-do-seeds.md`           | ✗        | optional bootstrap |
| `_actions.log` / `_events.log`| ✗        | first write op appends |
| `shadow/`                     | ✗        | first `study` / `plan` / `pr` |
| `_pr-links.md` / `_links.md`  | ✗        | first `pr-link` / `link` invocation |

## Schema-gate inventory (programs that hard-require v4)
- `code-dev-resume`, `code-dev-phase-new`, `code-dev-phase-start`, `code-dev-branch`
- All others fall back gracefully (read `schema | "v1"` then branch behavior).

## Cross-links
- → `cd-c1-p1-program-map.md` for the program inventory by cluster
- → `cd-c1-p2-workflows.md` for the runtime narrative across these files
- → `cd-c1-p3-gaps.md`     for missing schema features + v1 migrator gap
