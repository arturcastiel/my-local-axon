# code-dev — JOURNAL / KNOWLEDGE / STATE neurons

## 0. Runtime model (read this first — it is the #1 trap)

These are **agent-interpreted AXON-LANG `.md` neurons**, NOT Python subcommands.
They live in `workspace/programs/code-dev-*.md` and run **inside a booted AXON
session**, dispatched by the `code-dev` router as `code-dev <verb> [args]`.

**VERIFIED — they are not `axon.py` tools:**
```
$ python3 axon.py code-dev-journal
{"error": "Unknown tool 'code-dev-journal'. Did you mean: code-symbols, code-graph? Run: python3 axon.py help"}
$ python3 axon.py code-dev-since
{"error": "Unknown tool 'code-dev-since'. ..."}
$ python3 axon.py code-dev-replay
{"error": "Unknown tool 'code-dev-replay'. ..."}
$ python3 axon.py code-dev-state-undo
{"error": "Unknown tool 'code-dev-state-undo'. ..."}
$ python3 axon.py code-dev-test-map
{"error": "Unknown tool 'code-dev-test-map'. ..."}
```
`axon.py` only dispatches **registered Python tools** (REGISTRY.json). The neurons
below CALL such tools (`clock`, `shadow`, `code-symbols`, `session`, `calculator`,
`graphify-bridge`) via `TOOL(...)`, but are themselves run by the model after
`boot axon`. **Worked examples for them are session-transcripts; only the
underlying tool runs are reproducible CLI.**

Dispatch (from `code-dev.md`): `code-dev <verb>` → `EXEC(code-dev-<neuron>.md)`.
Args are not argparse flags — the router stores them into `W:` scratch vars that the
leaf neuron `RETRIEVE`s.

| Verb | Neuron file | Role |
|------|-------------|------|
| `journal [log\|decision\|event\|search]` | code-dev-journal.md (umbrella) | router |
| `log` / `decision` / `event` / `search` | code-dev-journal-{log,decision,event,search}.md | mutator |
| `changelog` | code-dev-changelog.md | mutator |
| `since` | code-dev-since.md | mutator |
| `reviewer` | code-dev-knowledge-reviewer-track.md (alias: code-dev-reviewer-track.md, STUB) | mutator |
| `test-map` | code-dev-test-map.md | mutator |
| `link [declare\|list\|check]` | code-dev-link.md | mutator |
| `replay` | code-dev-replay.md | mutator |
| `metrics` | code-dev-state-metrics.md (via `state metrics`) | mutator |
| `handoff` | code-dev-state-handoff.md (via `state handoff`) | mutator |
| `undo` | code-dev-state-undo.md (via `state undo`) | mutator |
| `impact` | code-dev-knowledge-impact.md | mutator |

Umbrellas: `code-dev journal <sub>` (default `log`), `code-dev knowledge <sub>`
(default `study`), `code-dev state <sub>` (default `status`). All require
`L:cognition-frame ≡ "AXON-OS"` (HALT → `boot axon`) and most require an active
project `W:code-dev-project` (FAIL → `code-dev load [slug]`).

---

## 1. Command reference

### JOURNAL family

#### `code-dev journal <log|decision|event|search>`  (umbrella)
Router (code-dev-journal.md). `CASE sub: log|decision|event|search`, default `log`,
unknown → FAIL. Stores `W:active-program`, then `EXEC`s the leaf.

#### `code-dev log` — implementation log + drift detection
- Subcommands (via `W:code-dev-log-cmd`): `log` (interactive add, default), `log view`,
  `log view [PR-N]`, `log drift`.
- Precondition: project loaded AND `{project-dir}/02-prs.md` exists (else "Complete Phase 2").
- Effects: appends a timestamped block to `04-log.md`; appends `log  pr={pr} drift={level}`
  to `_events.log`; records a pre-append size row in `_actions.log` (op=`append`, for undo);
  updates `shadow/{file}.findings.md` for each changed file (TOOL shadow init/append);
  refreshes `05-branches.md` row keyed `{git-branch} | {pr-id}`.
- Drift: EVAL over the divergence text → `none|noted|minor|significant`; ≥2 signals =
  significant → offers [1] update PR spec, [2] set `W:code-dev-replan-flag`, [3] note only.
- Open-PR list derives done-PRs from `pr-merged` rows in `_events.log` (canonical), not log markers.

#### `code-dev decision ["<title>"]` — ADR (architecture decision record)
- Scoped to active phase. Writes `## ADR-NNN · <title>` (auto-numbered) to
  `phases/{phase}/_decisions.md`; appends a one-line note to project `_meta.md`;
  appends `decision  {adr-id} :: {title}` to `_events.log`.
- **Undo-safe by design:** snapshots the *whole* `_decisions.md` to
  `archive/snapshots/{action-id}/` and logs `_actions.log` op=**replace** (NOT append),
  so undo COPY-FILEs it back instead of truncating.

#### `code-dev event <kind> "<detail>"` — internal state-change emitter
- Inputs via `W:code-dev-event-kind` (required) + `W:code-dev-event-detail`.
- Single effect: appends `{iso}  {kind}  {detail}` to `_events.log`. Called by other
  write programs (log, decision, freeze, merge, branch); rarely user-typed.

#### `code-dev search "<query>" [--in <scope>]` — full-text grep over project artifacts
- Scopes (`W:code-dev-search-in`, default `all`): `log` (04-log.md), `specs`
  (03-prs/*.md + phases/*/03-prs/*.md), `decisions` (phases/*/_decisions.md),
  `dont-do` (phases/*/_dont-do.md + _dont-do-seeds.md), `reviewers`
  (phases/*/reviewer-state.md), `all` (**/*.md).
- Mechanism: `grep -nFi` per file (literal, case-insensitive); read-only.

#### `code-dev changelog` — draft a changelog from merged PRs
- Reads `phases/{phase}/02-prs.md`, filters rows where col5=`merged`, pulls each spec's
  `## Summary` first paragraph.
- Target = `{meta.codebase}/{profile.changelog | "CHANGELOG.md"}` (the **user repo**, not project dir).
- On `yes`: `PREPEND-AFTER-HEADER` (FAILs closed if target missing). On `no`: WRITEs
  `phases/{phase}/changelog-draft.md`.

### STATE family

#### `code-dev since` — delta since last invocation
- Per-project baseline `W:code-dev-since-ts-{project}`. First run → "No baseline", seeds it.
- Reports: new git commits (`git log --since=<baseline>`), new `04-log.md` entries,
  reviewer-state files changed (by mtime), shadow stale count (TOOL shadow stats), then
  updates baseline to now.

#### `code-dev metrics` — self-observability (`state metrics`)
- Per-phase aggregates from `phases/*/`: PRs (rows `| PR-N |`), reviewer rounds (reviews/round-*.md),
  open/resolved objections (reviewer-state.md), ADRs + superseded (_decisions.md), active/retired
  prohibitions (_dont-do.md `^- ` vs `^- ~~`).
- Project rollup: totals + `avg-rounds/PR` (TOOL calculator) + most-cited prohibitions (count of
  each rule's text appearing in 04-log.md).

#### `code-dev handoff` — single-file briefing (`state handoff`, WRITER)
- TOOL(session) checkpoint + transition→`frozen`. Gathers identity, working contexts, last 10 log
  entries, open objections, active prohibitions, ADR count, shadow stats, git branch/dirty.
- WRITEs `phases/{phase}/handoff.md` with a "How to resume" block (`boot axon` → `code-dev load` →
  `code-dev resume`).

#### `code-dev undo [list|<id>]` — reverse last `_actions.log` write (`state undo`)
- `undo list` → last 10 entries. `undo` → LAST entry; `undo <id>` → first matching.
- Per op: `write`/`replace` → COPY-FILE snapshot back; `append` → TRUNCATE to recorded byte
  size (field 5); `mkdir` → DELETE-DIR; else FAIL. Confirms, then logs an `undo-<id> reverse` row.
- `_actions.log` row format: `<iso-ts>  <action-id>  <op>  <target-path>  <snapshot-path-or-size>`.

### KNOWLEDGE family

#### `code-dev reviewer [--open|--pr PR-N|--reviewer <h>|--round N]` — reviewer dashboard
- Live neuron = code-dev-knowledge-reviewer-track.md (the bare `code-dev-reviewer-track.md` is a
  deprecated STUB that just re-EXECs it). Reads `phases/{phase}/reviewer-state.md` table; filters via
  `W:code-dev-reviewer-{open,pr,name,round}`; groups by (PR, reviewer); prints per-group rows +
  open/re-implementing/resolved summary. Read-only over project files.

#### `code-dev test-map [<PR-NNN>]` — map changed source → test files
- Files from PR spec `## Files` (if PR given) else `git diff --name-only {base}...HEAD`.
- Uses `_profile.md`: `test-dir`, `test-prefix`, `test-glob`, `base-branch`.
- Graph mode if `{project}/graph/graph.json` exists → graphify-bridge call-verified covering tests;
  else filename heuristic (`{prefix}{base}.cpp` + `*base*` via `find`). Emits gap warnings →
  suggests `code-dev review tests`.

#### `code-dev impact [--cross-repo]` — API blast-radius for the phase
- Per file in `phases/{phase}/_files.md`: `code-symbols exports` (ast=EXTRACTED / regex=INFERRED);
  empty set → skipped (never greps `\b()\b`). Callers via `git grep -E '\b(sym1|sym2)\b'`; optional
  graphify-bridge EXTRACTED callers if graph present; `--cross-repo` also greps `_profile.cross-repo`
  siblings. WRITEs `phases/{phase}/impact.md`.

#### `code-dev link <declare|list|check>` — cross-project dependency links
- `W:code-dev-link-sub` (default `declare`) + `W:code-dev-link-arg`. Storage `{project}/_links.md`
  table `| Target project | Phase | Reason | Declared |`. `declare` ASSERTs the target project dir
  exists; `check` reads each target's `_meta.md` and reports phase/status/workflow-step (✗ MISSING if absent).

#### `code-dev replay [<PR-NNN>]` — mine history for repeated lessons
- Global: most-cited `_dont-do.md` rules (counted in 04-log.md, only count>1), and "expensive PRs"
  (≥3 reviewer rounds, bucketed from reviews/round-*.md). Per-PR: renders each round file's
  `## Summary`. Reads `_events.log`/_dont-do/reviews; read-only.

---

## 2. Verified examples (hybrid contract)

### 2a. REAL tool runs (reproducible CLI — actually executed)

These are the read-only TOOL(...) calls the neurons make. Output captured live:

**`clock` — the `ts ← TOOL(clock)` used by every journal/state write:**
```
$ python3 axon.py clock
{"timestamp": "2026-06-17 14:48:46", "iso": "2026-06-17T14:48:46.999280Z", "date": "2026-06-17", "time": "14:48:46", "unix": 1781700526, "source": "ntp"}
```

**`shadow stats` — the `TOOL(shadow, stats, ...)` used by `since` and `handoff`:**
```
$ python3 axon.py shadow stats --shadow-dir <project>/shadow
{
  "total": 5,
  "fresh": 1,
  "stale": 4,
  "no_source": 0,
  "summary": "Shadow index: 5 files (1 fresh, 4 stale, 0 source not found)"
}
```

**`code-symbols exports` — the symbol set `impact` greps callers for:**
```
$ python3 axon.py code-symbols exports --file tools/clock.py
{
  "file": "tools/clock.py",
  "lang": "python",
  "confidence": "EXTRACTED",
  "exported": [
    "main"
  ]
}
```

**Real `_events.log` (canonical source for `since`/`replay`/`metrics`) — format `<iso>␠␠<kind>␠␠<detail>`:**
```
$ cat <project>/_events.log
2026-06-09T10:31:00Z  project-created   axon-resilience — cron-contract robustness (A) + identity persistence/self-care (B)
2026-06-09T11:10:00Z  pr-merged         PR-1 cron-contract gate → origin/main f99f5f8 (MR !150), crucible green 4566 tests
2026-06-09T12:05:00Z  pr-merged         PR-2 self-care + identity-persistence → origin/main b55c85f (MR !151), crucible green 4579 tests
2026-06-09T12:20:00Z  project-closed    autonomous scope complete; both PRs tested-green pre-merge + merged.
```

### 2b. Labeled SESSION-TRANSCRIPTS (agent-interpreted neurons — illustrative, faithful to each neuron's exact OUTPUT strings; not fabricated tool stdout)

**`code-dev journal decision` — record an ADR**
```
[session-transcript · after: boot axon ; code-dev load axon-resilience]
> code-dev decision "use atomic_write everywhere"
  Context: what problem prompted this?         > partial writes corrupted _meta.md on crash
  Decision: what was chosen?                    > wrap every state write in atomic_write()
  Alternatives considered (comma-separated)?    > fsync-then-rename, file-lock, sqlite
  Consequences / trade-offs?                    > +1 tmp file per write; eliminates torn writes
▶ AXON / code-dev decision  ·  [ADR-001]
  ✓ Recorded in phases/1-impl/_decisions.md
  ✓ Appended to project Working Context
# side effects: _decisions.md snapshot → archive/snapshots/act-...; _actions.log op=replace; _events.log += "decision  ADR-001 :: use atomic_write everywhere"
```

**`code-dev search "atomic" --in decisions`**
```
[session-transcript]
> code-dev search "atomic" --in decisions
▶ AXON / code-dev search  ·  [axon-resilience]  scope: decisions
  Query: "atomic"
  📄 phases/1-impl/_decisions.md  (2 hits)
      12:## ADR-001 · use atomic_write everywhere
      18:### Decision\n wrap every state write in atomic_write()
  Total: 2 hit(s) across 1 file(s)
```

**`code-dev since` — first run vs subsequent**
```
[session-transcript · first time for this project]
> code-dev since
▶ AXON / code-dev since
  No baseline — this is your first `since` for axon-resilience.
  Run again later to see changes.
  Baseline updated to: 2026-06-17T14:48:46.999280Z
```
```
[session-transcript · later]
> code-dev since
▶ AXON / code-dev since
  Baseline: 2026-06-17T14:48:46Z  (3h ago)
  GIT COMMITS  (2)
    · b55c85f PR-2 self-care + identity persistence
    · f99f5f8 PR-1 cron-contract gate
  LOG ENTRIES  (1)
    · ## Entry — 2026-06-17T17:30:00Z
  REVIEWER STATE  (changed: 0 phase(s))
    (no changes)
  SHADOW   stale-now: 4
  Baseline updated to: 2026-06-17T17:51:00Z
```

**`code-dev undo list` then `code-dev undo`**
```
[session-transcript]
> code-dev undo list
▶ AXON / code-dev undo list  ·  [axon-resilience]
  2026-06-17T17:30:00Z  act-2026-06-17T173000Z  append   .../04-log.md  41822
  2026-06-17T17:31:00Z  act-2026-06-17T173100Z  replace  .../_decisions.md  .../snapshots/act-.../_decisions.md
> code-dev undo
▶ AXON / code-dev undo
  Action: 2026-06-17T17:31:00Z  act-... replace  .../_decisions.md  .../_decisions.md
  Reverse this action? [yes / no]  > yes
  ✓ Restored .../_decisions.md from .../snapshots/act-.../_decisions.md
```

**`code-dev reviewer --open`**
```
[session-transcript]
> code-dev reviewer --open
▶ AXON / code-dev reviewer  ·  [PROJECT: axon-resilience / 1-impl]
  Filters:
    open-only: true   pr: —   reviewer: —   round: —
  PR-002  ·  alice  (1 entries)
    [open] round 2: widen API surface — reject
  SUMMARY (all rows)
    open: 1   re-implementing: 0   resolved: 4
```

**`code-dev link declare` / `link check`**
```
[session-transcript]
> code-dev link declare graphify-obsidian/2-bridge
  Reason for link (one line)?  > test-map graph mode depends on the bridge
  ✓ Linked axon-resilience → graphify-obsidian/2-bridge
> code-dev link check
▶ AXON / code-dev link check  ·  [axon-resilience]
  · graphify-obsidian  phase:2-bridge  status:active  workflow:build
```

**`code-dev changelog` (declines → draft saved)**
```
[session-transcript]
> code-dev changelog
▶ AXON / code-dev changelog  ·  [1-impl]
  DRAFT
  ## 1-impl — 2026-06-17
  - **PR-001** cron-contract gate
    Adds a fail-closed merge gate proving every cron job satisfies the runner contract.
  Append to /repo/CHANGELOG.md? [yes / no]  > no
  Draft saved to phases/1-impl/changelog-draft.md. Append manually when ready.
```

---

## 3. File-effect cheat sheet (what each neuron touches)

| Neuron | Reads | Writes / appends |
|--------|-------|------------------|
| journal-log | 02-prs.md, _events.log, PR spec, shadow | 04-log.md, _events.log(`log`), _actions.log(append), shadow findings, 05-branches.md |
| journal-decision | _decisions.md | _decisions.md(ADR), _meta.md, _events.log(`decision`), _actions.log(replace)+snapshot |
| journal-event | — | _events.log(`{kind}`) |
| journal-search | **/*.md (scoped) | — (read-only) |
| changelog | 02-prs.md, specs, _profile | {codebase}/CHANGELOG.md *or* changelog-draft.md |
| since | git, 04-log.md, reviewer-state, shadow | W:code-dev-since-ts-{project} (baseline) |
| reviewer-track | reviewer-state.md | — (read-only) |
| test-map | git diff / PR spec, _profile, graph.json | — (render only) |
| impact | _files.md, code-symbols, git grep, graph | phases/{phase}/impact.md |
| link | _links.md, target _meta.md | _links.md |
| replay | _events.log, _dont-do, reviews, 04-log.md | — (read-only) |
| state-metrics | phases/*, 04-log.md | — (render only) |
| state-handoff | meta, log, reviewer-state, dont-do, decisions, shadow, git | phases/{phase}/handoff.md + session checkpoint/freeze |
| state-undo | _actions.log, snapshots | restores target file; _actions.log(`undo-`) |

