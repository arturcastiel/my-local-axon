# code-dev — CORE / LIFECYCLE Manual

Deep-study reference for the code-dev harness CORE/LIFECYCLE neurons and their backing CLI tools. Every example below is EITHER a real `python3 axon.py …` command with output captured live against real projects, OR a labeled session-transcript for agent-interpreted `.md` neurons (which are AXON-OS interpreted instruction files, not executable scripts). No output is fabricated.

Source files (all absolute):
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev.md` (hub/router)
- `…/code-dev-new.md`, `…/code-dev-load.md`, `…/code-dev-state-status.md`, `…/code-dev-state-resume.md`, `…/code-dev-state-save.md`, `…/code-dev-study.md`, `…/code-dev-plan.md`, `…/code-dev-pr-ready.md`, `…/code-dev-journal-log.md`, `…/code-dev-safety-audit.md`, `…/code-dev-next.md`, `…/code-dev-help.md`, `…/code-dev-lifecycle-tour.md`
- Backing tools invoked via `python3 /home/arturcastiel/projects/new-axon/axon/axon.py <tool> …`

---

## 1. Mental model

code-dev is an **instruction-OS** layered over a code project. `.md` "programs" under `workspace/programs/` are NOT shell scripts — they are AXON-OS neurons the agent *interprets*. Each carries `# budget:` caps, a `# synapse:` block (domain/role/precondition/next-suggests), an `!NORM | SPAWNED → RUNNING` lifecycle marker, an `## IDENTITY LOCK` (`ASSERT(L:cognition-frame ≡ "AXON-OS")`), a `## HELP` block, and a body of pseudo-instructions (`STORE`, `RETRIEVE`, `READ`, `TOOL(...)`, `→ "..."`, `FAIL(...)`, `DONE(...)`).

The interpreted programs delegate real state to three **executable** backing tools:

| Tool | Purpose | Mutating? |
|------|---------|-----------|
| `phase-model` | Data-driven phase manifest (the 5-phase ladder; done/back/skip truth) | `init`/`advance`/`done` mutate `_phases.json`; `render`/`load`/`check`/`status`/`stale-downstream` are read-only |
| `shadow` | Shadow index (cached file digests so source is read once) | `init`/`append`/`header` mutate; `stats`/`list`/`stale`/`check`/`hash`/`coverage` are read-only |
| `study-modes` | Resolve a study profile (budget/intent tiers) | read-only (`list`, `resolve`) |

The **5-phase ladder** (canonical ids): `study → plan → pr → log → audit`. A phase is "done" only when explicitly marked via `phase-model done` — never merely because an output file exists (when a `_phases.json` manifest is present it is the source of truth).

---

## 2. The hub: `code-dev` (router) — `code-dev.md`

`code-dev [new|load|study|plan|pr|log|audit|status|...]`. Stores `W:active-program`, scans `{W:myaxon-dev-projects}` for `_meta.md` (depth 2), then dispatches on `W:code-dev-cmd`. With no cmd it renders the dashboard.

Key router facts (load-bearing):
- **SHADOW GATE** fires before `study|plan|pr|log|audit|explain` when the loaded project has a `codebase`: it runs `shadow stats`, stores `W:shadow-stats`, and if `stale > 0` emits `⚠ SHADOW GATE · N stale file(s) — run: code-dev shadow refresh`. Sets `W:shadow-gate-active=true`. Rule: every code-dev session starts from shadow, not raw source.
- `new` routes to `code-dev-new` (the v4 scaffolder). The legacy `new → code-dev-init` (v1) route was **removed** because first-match-wins shadowed v4 (every project was born v1, leaving resume/phases dark).
- All phase-touching cmds assert `project ≠ ∅` or `FAIL(... fix="Run: code-dev load [slug]")`.

### Command → subprogram dispatch table

| cmd | routes to | notes |
|-----|-----------|-------|
| `new` | code-dev-new | v4 scaffolder |
| `load [slug]` | code-dev-load | sets `W:code-dev-project` |
| `status` | code-dev-state-status | dashboard |
| `study` | code-dev-study | Phase 1 |
| `plan` | code-dev-plan | Phase 2 |
| `pr` / `pr-spec` | code-dev-pr-create | `pr-spec` sets `W:code-dev-pr-style=opm` |
| `explain` | code-dev-knowledge-explain | annotated PR deep-dive |
| `review` | code-dev-pr-review | PR review mode |
| `log` | code-dev-journal-log | Phase 4 |
| `audit` | code-dev-safety-audit | Phase 5 |
| `resume` | code-dev-state-resume | v4 only (compaction recovery) |
| `branch` / `branches` | code-dev-branch / :BRANCHES | git↔meta branch |
| `next` | code-dev-next | 10-moment classifier |
| `done` | `TOOL(phase-model, done …)` | mark current phase DONE |
| `back` | `TOOL(phase-model, advance …)` + `stale-downstream` | re-enter earlier phase, cascade-invalidate downstream |
| `skip` | `TOOL(skip-guard …)` | NO skip-by-inference; autonomous/inference≥8 → hard HALT |
| `phase new\|start\|list` | code-dev-phase-* / `phase-model render` | `phase list` renders `[{order}] {id} — {status}` |
| `tag` / `rewind` | code-dev-state-save | snapshot/restore AXON files only |
| `help [cmd]` | code-dev-help | extracts `## HELP` block |
| `tour` | code-dev-lifecycle-tour | 8-station guided tour |
| `check-structure`, `merge`, `cascade`, `changelog`, `freeze`/`thaw`, `divide`, `combine`, `preflight`, `self-review`, `scope-check`, `suggest-tests`, `review-coverage`, `review-correctness`, `diff`, `search`, `metrics`, `whatif`, `replay`, `undo`, `since`, `handoff`, `impact`, `decision`, `dont-do`, `pr-ready`, `pr-github`, `pr-respond`, `pr-link`, `reviewer`, `test-map`, `link`, `event`, `hold`, `partition`, `plan-master`, `pr-update-spec` | various code-dev-* | full long-tail surface |

### Worked example — session-transcript (interpreted `.md`, no-cmd dashboard)
```
> code-dev
▶ AXON / code-dev
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CODE DEVELOPMENT HARNESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WORKFLOW
  1 · study   ──▶ Ingest material (URLs, PDFs, code), define goal + confidence
  2 · plan    ──▶ Semantic codebase search, high-level plan, numbered PR list
  3 · pr [N]  ──▶ Per-PR spec: files, changes, acceptance criteria, context
  4 · log     ──▶ Human implements; AXON tracks what was done vs planned
  5 · audit   ──▶ Cross-reference log vs specs; surface gaps and drift
  ...
```
(Dashboard text is emitted verbatim by the `→ "..."` lines in `code-dev.md`. When a project is loaded it adds PROJECT / PHASE STATUS / V4 COMMANDS sections, with branch-drift and stale-session-marker banners for v4 projects.)

---

## 3. `code-dev new` — scaffold a v4 project (`code-dev-new.md`)

Interactive: `slug` (must match `^[a-z0-9-]+$`), display `name`, absolute `codebase` path (must exist), `first-phase` (default `study`). Asserts project dir does not already exist.

Creates (17 outputs): `_meta.md` (`schema-version: v4`), `_profile.md`, `_dont-do-seeds.md`, `masterplan.md`, `04-log.md` (with `## SESSION START` marker), `05-branches.md`, `03-prs/`, `shadow/`, `phases/{first-phase}/` with 9 stubs (`_meta.md`, `_files.md`, `_dont-do.md`, `_decisions.md`, `_deviations.md`, `reviewer-state.md`, `01-study.md`, `02-plan.md`, `02-prs.md`). **Crucially seeds the phase manifest at creation** via `TOOL(phase-model, init, "--project {proj-dir}")` — `_phases.json` is the single source of phase truth.

Backing tool used at scaffold time:
```
python3 axon.py phase-model init --project <proj-dir>
```
`init` writes a fresh `_phases.json` (the default 5-phase ladder, all `pending`). To see what a freshly-rendered ladder looks like, see the live `render` output in §6.

### Worked example — session-transcript (interpreted `.md`)
```
> code-dev new
Project slug … : my-cool-app
Project display name : My Cool App
Absolute path to codebase : /home/me/repos/cool
First phase name [study] : study
▶ AXON / code-dev new  ·  [PROJECT: my-cool-app]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ v4 project scaffolded
    {myaxon-dev-projects}/my-cool-app
  Schema:       v4
  First phase:  study  (build)
  NEXT
  · code-dev study     populate first-phase 01-study.md
  · code-dev plan      generate 02-plan.md + PR list
  · code-dev resume    if returning to this project later
```

---

## 4. `code-dev load [slug]` (`code-dev-load.md`)

Sets `W:code-dev-project`, reads `_meta.md`, asserts dir exists. With no slug it lists every project (`· {slug} · schema: {v} · status:`). Runs the **C1 split-brain guard**:
```
TOOL(phase-model, check, "--project {proj-dir}")
```
If `ok ≠ true` it loudly surfaces `⚠ PHASE SPLIT-BRAIN: _meta.phase '…' is not a manifest phase`. This is the detector for a `_meta.phase` value the manifest cannot resolve.

### Real backing-tool example (read-only) — `phase-model check`
Run live against the real project (note `_meta.phase` is the scaffold form `3-pr`, which the normalizer resolves to canonical `pr`):
```
$ python3 axon.py phase-model check \
    --project /home/arturcastiel/projects/axon-sections/my-axon/dev-projects/axon-plus
{
  "ok": true,
  "meta_phase": "3-pr",
  "resolved": "pr",
  "status": "pending"
}
```
A v4 project with a manifest resolves cleanly too:
```
$ python3 axon.py phase-model check \
    --project .../dev-projects/axon-new-doc
{
  "ok": true,
  "meta_phase": "study",
  "resolved": "study",
  "status": "active"
}
```

---

## 5. `code-dev status` (`code-dev-state-status.md`)

`code-dev status`. Requires `W:code-dev-project`. Renders a multi-section dashboard: PROJECT (schema/status/phase/workflow-step/branch+git/codebase), PHASE (workflow-step/current-pr/dont-do count/decisions count), PRs (spec count), REVIEWER (open objections, counted via `\| open \|` rows), SHADOW (`fresh`/`stale`/`branch-stale` from `shadow stats`).

The SHADOW block is driven by:
```
TOOL(shadow, stats, "--shadow-dir {proj-dir}/shadow")
```

### Real backing-tool example (read-only) — `shadow stats`
Empty / absent shadow index returns the same canonical structure:
```
$ python3 axon.py shadow stats \
    --shadow-dir .../dev-projects/axon-plus/shadow
{
  "total": 0,
  "stale": 0,
  "fresh": 0,
  "no_source": 0,
  "summary": "Shadow index is empty."
}
```
(`status` reads `fresh`/`stale`/`branch-stale` off this; absent dir → still empty struct, never an error.)

---

## 6. Phase ladder commands: `done` / `back` / `phase list`

These dispatch directly to `phase-model` from the hub:
- `code-dev phase list` → `phase-model render` → prints `[{order}] {id} — {status}`.
- `code-dev done [--phase P]` → `phase-model done --phase P` → "✓ PHASE … marked DONE".
- `code-dev back P` → `phase-model advance --phase P` then `phase-model stale-downstream --phase P` → re-opens upstream and reports `Downstream is now STALE … {staled}`.

### Real backing-tool example (read-only) — `phase-model render`
Live against the real `axon-plus` project (v1, **no `_phases.json`** → default ladder, all `pending`):
```
$ python3 axon.py phase-model render \
    --project .../dev-projects/axon-plus
[
  { "id": "study", "name": "Study",    "order": 1, "status": "pending" },
  { "id": "plan",  "name": "Plan",     "order": 2, "status": "pending" },
  { "id": "pr",    "name": "PR-specs", "order": 3, "status": "pending" },
  { "id": "log",   "name": "Log",      "order": 4, "status": "pending" },
  { "id": "audit", "name": "Audit",    "order": 5, "status": "pending" }
]
```
A v4 project mid-flight (`super-polish`: study+plan done, pr active):
```
$ python3 axon.py phase-model render \
    --project .../dev-projects/super-polish
[
  { "id": "study", "name": "Study",    "order": 1, "status": "done"    },
  { "id": "plan",  "name": "Plan",     "order": 2, "status": "done"    },
  { "id": "pr",    "name": "PR-specs", "order": 3, "status": "active"  },
  { "id": "log",   "name": "Log",      "order": 4, "status": "pending" },
  { "id": "audit", "name": "Audit",    "order": 5, "status": "pending" }
]
```

### Real backing-tool example (read-only) — `phase-model status`
Requires both `--project` AND `--phase` (omitting `--phase` is exit-2):
```
$ python3 axon.py phase-model status \
    --project .../dev-projects/axon-plus --phase study
{"phase": "study", "status": "pending"}

$ python3 axon.py phase-model status --project .../axon-plus
usage: phase_model.py status [-h] --project PROJECT --phase PHASE
phase_model.py status: error: the following arguments are required: --phase   # exit 2
```

### Real backing-tool example (read-only) — `phase-model load`
Full manifest dump with `deps` chain. Note: `schema` reads `"v1"` for projects without a recorded schema in the manifest, regardless of `_meta` schema-version:
```
$ python3 axon.py phase-model load --project .../axon-plus
{
  "schema": "v1",
  "phases": [
    { "id": "study", "order": 1, "deps": [],         "status": "pending" },
    { "id": "plan",  "order": 2, "deps": ["study"],  "status": "pending" },
    { "id": "pr",    "order": 3, "deps": ["plan"],   "status": "pending" },
    { "id": "log",   "order": 4, "deps": ["pr"],     "status": "pending" },
    { "id": "audit", "order": 5, "deps": ["log"],    "status": "pending" }
  ],
  "updated": null
}
```

### Real backing-tool example (read-only) — `phase-model stale-downstream`
Empty when nothing downstream is done; non-empty when re-opening an upstream done phase. Live against `super-polish` (study+plan done):
```
$ python3 axon.py phase-model stale-downstream \
    --project .../super-polish --phase study
{"ok": true, "staled": ["plan", "pr"]}

$ python3 axon.py phase-model stale-downstream \
    --project .../super-polish --phase plan
{"ok": true, "staled": ["pr"]}

# axon-plus (nothing done) → nothing to stale:
$ python3 axon.py phase-model stale-downstream \
    --project .../axon-plus --phase plan
{"ok": true, "staled": []}
```

### `phase-model` full surface
```
$ python3 axon.py phase-model --help
usage: phase_model.py [-h] {load,render,init,check,status,advance,done,stale-downstream} ...
Data-driven phase manifest for code-dev/workflows.
```
All subcommands take `--project PROJECT`; `status`/`advance`/`done`/`stale-downstream` additionally require `--phase PHASE`. `render` is the dashboard read; `init` creates the manifest; `advance` re-enters a phase (used by `back`); `done` marks done; `check` is the split-brain detector (read-only).

---

## 7. `code-dev resume` (`code-dev-state-resume.md`) — compaction recovery (v4 only)

`code-dev resume`. v1/legacy projects short-circuit with `⚠ Legacy v1 project — resume not available`. Performs a fixed **10-layer read** (profile → masterplan → log+session anchor → project/phase meta → prohibitions → decisions → current PR spec → reviewer state → shadow health) and **appends a `## SESSION RESUME — {iso}` marker to `04-log.md`** (this is the program's only mutation; it also calls `TOOL(session, recover/checkpoint)`).

Derives `IMMEDIATE NEXT ACTION` from `workflow-step`:
- `build` → implement next item from current PR spec
- `re-implementing` → re-address reviewer feedback
- `review` → wait for reviewer / `code-dev reviewer track`
- `merged` → `code-dev cascade` → `code-dev changelog`
- `frozen` → `code-dev thaw` when unblocked

Shadow health line is `shadow stats` (`fresh`/`stale`/`branch-stale`); if stale or branch-stale > 0 → `⚠ Run: code-dev shadow refresh`.

### Worked example — session-transcript (interpreted `.md`)
```
> code-dev resume
▶ AXON / code-dev resume  ·  [PROJECT: my-cool-app]
  WHERE YOU ARE
  Project        my-cool-app  ·  schema: v4
  Phase          study
  Workflow-step  build
  Branch         main  (git: main  ✓)
  PR             —  (no active PR)
  ...
  SHADOW HEALTH
  Shadow index not yet built. Run: code-dev study  to seed it.
  IMMEDIATE NEXT ACTION
  ▶ implement next item from current PR spec
```

---

## 8. `code-dev tag` / `code-dev rewind` (`code-dev-state-save.md`)

`code-dev tag "<label>"` (label `^[a-zA-Z0-9_-]+$`), `code-dev tag list`, `code-dev rewind "<label>"`. **Scope: only AXON project files — never the user codebase (that is git's job).** Snapshots `_meta.md`, `phases/`, and root mutable state (`04-log.md`, `05-branches.md`, `_actions.log`) into `archive/tags/{label}/` plus a `_tag.md` descriptor. `rewind` requires typed `yes` confirmation, overwrites `_meta`+`phases`+logs, and appends a `tag rewind` log entry.

---

## 9. `code-dev study` (`code-dev-study.md`) — Phase 1

```
code-dev study [--mode=overview|subsystem|deep|targeted|audit|compare|onboard|goals]
               [--target=<path|glob>] [--lens="topic"] [--ref=<path>]
               [--output=engineering|executive|machine] [--input=<path>]
```
- `--mode` budget tiers override the blanket `# budget:` caps. `overview` (default), `subsystem`, `deep` set distinct input/output caps. `subsystem`/`deep`/`targeted`/`compare` dispatch to `code-dev-study-area`; `goals` dispatches to `goal-define`; `overview`/`audit`/`onboard` run the overview body.
- `--target` accepts path or glob (≤200 files, `--force` to override).
- `--output`: engineering (full) / executive (≤2k tok) / machine (YAML front-matter).
- The mode is resolved by the backing tool, which fails loudly on unknown mode or missing required option (`targeted`→lens, `compare`→ref).
- It also seeds the **shadow index** and (advisory) a repo graph at `graph/graph.json` via `graphify-bridge`.

### Real backing-tool example (read-only) — `study-modes list`
```
$ python3 axon.py study-modes list
{
  "overview":  {"kind":"budget","summary":"Fast orientation (default — refactors today's behavior)."},
  "subsystem": {"kind":"budget","summary":"One subsystem in focus (routes to code-dev-study-area)."},
  "deep":      {"kind":"budget","summary":"Thorough line-level study of code you'll change."},
  "targeted":  {"kind":"intent","summary":"Study only what matches a lens/query (one question)."},
  "audit":     {"kind":"intent","summary":"Hunt risks/gaps/debt across the tree (e.g. the stub census)."},
  "compare":   {"kind":"intent","summary":"Study this codebase against a reference implementation."},
  "goals":     {"kind":"intent","summary":"Goal-define interrogation … (routes to the goal-define program; axon-plus pr-12)."},
  "onboard":   {"kind":"intent","summary":"Explain-to-a-newcomer orientation of a codebase."}
}
```

### Real backing-tool example (read-only) — `study-modes resolve`
`resolve [--mode MODE] [--lens LENS] [--ref REF]`. Returns the full profile (kind/depth/breadth/input_cap/output_cap/requires/questions/summary/mode). Default (no `--mode`) is `overview`:
```
$ python3 axon.py study-modes resolve --mode deep
{
  "kind": "budget", "depth": "line-level+architecture", "breadth": "narrow",
  "input_cap": 32000, "output_cap": 12000, "requires": [],
  "questions": ["Which code will you change heavily?", "Invariants? What could a change break?"],
  "summary": "Thorough line-level study of code you'll change.", "mode": "deep"
}

$ python3 axon.py study-modes resolve --mode targeted --lens "error handling"
{ "kind":"intent","depth":"focused","breadth":"filtered","input_cap":8000,"output_cap":4000,
  "requires":["lens"], "summary":"Study only what matches a lens/query (one question).",
  "mode":"targeted", "lens":"error handling" }

$ python3 axon.py study-modes resolve --mode compare --ref /tmp/refrepo
{ ... "requires":["ref"], "mode":"compare", "ref":"/tmp/refrepo" }
```
Caps by mode (captured live): overview 8000/4000 · subsystem 16000/6000 · deep 32000/12000 · targeted 8000/4000 · audit 16000/8000 · compare 16000/8000 · goals 8000/6000 · onboard 8000/6000.

Error paths (loud, exit 1):
```
$ python3 axon.py study-modes resolve --mode targeted
{"error": "mode 'targeted' requires option(s): lens (e.g. --lens ...)"}

$ python3 axon.py study-modes resolve --mode compare
{"error": "mode 'compare' requires option(s): ref (e.g. --ref ...)"}

$ python3 axon.py study-modes resolve --mode bogus
{"error": "unknown study mode 'bogus'. valid: overview, subsystem, deep, targeted, audit, compare, goals, onboard"}
```

---

## 10. `code-dev plan` (`code-dev-plan.md`) — Phase 2

```
code-dev plan [--mode=tactical|strategic|operational|decision] [--budget N] [--rule "<text>"]
```
- `tactical` (default) → `02-plan.md` + `02-prs.md` + `02-phases/phase-N-<slug>.md`.
- `strategic` → `02-plan.md` + `02-roadmap.md` (tier-1 vision + plan index).
- `operational` → `02-plan.md` (flat run-book: ordered steps + time/token est).
- `decision` → `02-plan.md` + a new `03-decisions/adr-NNN-<slug>.md` (repeatable; auto-increments NNN).
- `--budget N` caps PR count; overflow → `02-prs.deferred.md` (real example: `axon-plus` has a populated `02-prs.deferred.md`).
- Per-mode budget tiers override blanket caps. Asserts `01-study.md` exists. Constraints checklist rendered at entry via `TOOL(constraints, list, "--scope phase:plan")`.

---

## 11. `code-dev pr-ready` (`code-dev-pr-ready.md`) — pre-push gate

`code-dev pr-ready [PR-NNN] [--strict] [--strict-explain]`. Gate checks: working tree clean (`git status --porcelain`), preflight delegate (`code-dev-safety-preflight` check-only). On pass it prints the **HUMAN-run** push command — `git -C {codebase} push -u origin {branch}` — and **never executes git push itself**. `--strict`/`--strict-explain` run `TOOL(rules, evaluate …)` against the resolved PR spec and block on failing gates.

---

## 12. `code-dev log` (`code-dev-journal-log.md`) — Phase 4

`code-dev log` (interactive add) · `code-dev log view [PR-N]` · `code-dev log drift`. Append-only to `04-log.md`, timestamped, auto-linked to PRs. **AXON never implements** — the human implements; AXON observes, compares against the PR spec, flags drift, and offers to update plan/spec. Asserts `02-prs.md` exists.

---

## 13. `code-dev audit` (`code-dev-safety-audit.md`) — Phase 5

`code-dev audit` (all PRs) · `code-dev audit [PR-N]` · `code-dev audit diff` (only PRs with issues). Cross-references every PR spec vs log entries → completion table (done/partial/missing/drifted) written to `05-audit.md`. Non-destructive. Asserts `02-prs.md` exists.

The companion **PR↔shadow coverage** check is a real read-only tool:
```
$ python3 axon.py shadow coverage \
    --project-dir .../dev-projects/axon-plus
{
  "ok": true,
  "shadow-coverage": { "covered": 0, "total": 19, "percent": 0.0, "threshold": 100.0, "pass": false },
  "by_phase": [ { "phase": "(legacy-root)", "covered": 0, "total": 19, "percent": 0.0,
    "missing": [ {"pr":"PR-001","pr_spec":"03-prs/PR-001.md","expected_shadow":"shadow/PR-001.findings.md"}, … ],
    "applicable": true } ]
}
```
`coverage` flags: `--project-dir` (required), `--phase` (restrict to one phase slug), `--threshold` (pass % default 100).

---

## 14. `code-dev next` (`code-dev-next.md`) — 10-moment classifier

`code-dev next [--no-study-suggest]`. Inspects state and emits ONE recommended command + rationale. Honors a cached `meta.next-action` (<24h, same workflow-step). Surfaces stale studies + in-progress PRs (cap 2). Then the **10 moments, first match wins**:

1. branch-drift → `code-dev branch sync`
2. session-stale (>2h / never) → `code-dev resume`
3. open objections → `code-dev pr-respond {pr}`
4. workflow-step=merged → `code-dev cascade`
5. frozen → `code-dev hold release`
6. shadow stale >5 → `code-dev shadow refresh`
7. re-implementing → `code-dev preflight`
8. build + active diff → `code-dev review`
9. no active PR → `code-dev pr`
10. catch-all → `code-dev log`

---

## 15. `code-dev help` / `code-dev tour`

- `code-dev help` lists all `code-dev-*.md` programs (`{name:22s}  {desc}`); `code-dev help <cmd>` extracts that program's `## HELP` block.
- `code-dev tour` (`code-dev-lifecycle-tour.md`) walks 8 stations: 1 start, 2 status, 3 next, 4 build+review, 5 record (log/decision/dont-do), 6 ship (pr-ready/pr-github — "You push manually — code-dev never executes git push"), 7 reviewer cycle, 8 mine history; plus a Safety net (whatif/undo/tag/rewind).

---

## 16. `shadow` full surface (read-only subset)
```
$ python3 axon.py shadow --help
usage: shadow [-h] {hash,check,init,header,append,list,stats,stale,coverage} ...
```
| sub | read-only? | key flags |
|-----|-----------|-----------|
| `stats` | yes | `--shadow-dir` |
| `list` | yes | `--shadow-dir` → `{"files":[…],"count":N}` |
| `stale` | yes | `--shadow-dir [--codebase]` |
| `check` | yes | `--file --shadow-dir` |
| `hash` | yes | `--file` |
| `coverage` | yes | `--project-dir [--phase] [--threshold]` |
| `header` | yes | `--shadow-path` |
| `init` | **mutating** | `--file --shadow-dir --hash [--force --branch --commit --commit-msg --caller-program --caller-project]` |
| `append` | **mutating** | `--shadow-path --section {summary,structures,dependencies,arch-role,findings} --content [--context]` |

Live `list` (empty index): `{"files": [], "count": 0}`.

---

## 17. Traps & gotchas (verified)
- `phase-model status` **requires `--phase`** — omitting it is argparse exit-2, not an empty result.
- `phase-model load` returns `"schema": "v1"` for projects whose manifest has no recorded schema, even if `_meta.md` says `schema-version: v4`. Don't infer project schema from this field — read `_meta.md`.
- `phase-model render` of a project with **no `_phases.json`** still returns the full default 5-phase ladder (all `pending`) — it never errors. `axon-plus` (real) demonstrates this.
- The scaffold phase vocabulary (`3-pr`) differs from canonical ids (`pr`); `check`/`load` normalize it (`meta_phase: "3-pr"` → `resolved: "pr"`). A value the normalizer can't resolve is the "split-brain" `code-dev load` warns about.
- `shadow stats` on an absent OR empty shadow dir both return `{"total":0,...,"summary":"Shadow index is empty."}` — never an error.
- `study-modes resolve` for `targeted`/`compare` without `--lens`/`--ref` returns `{"error": …}` and exit 1.
- `code-dev resume` is v4-only; on v1/legacy it short-circuits.
- The harness **never runs `git push`**, **never implements code**, and **never touches the user codebase for tag/rewind** — all three are explicit, load-bearing contracts.
