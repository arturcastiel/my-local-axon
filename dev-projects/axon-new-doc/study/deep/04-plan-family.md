# PLAN family — command reference + verified examples

## 0. Critical disambiguation: two unrelated things called "plan"

| | **standalone `plan-*`** | **`code-dev-plan` (Phase 2)** |
|---|---|---|
| What | personal to-do / project tracker | one phase of the multi-phase *code-dev* engineering pipeline |
| Files | `axon/programs/plan-new\|add\|done\|list\|view.md` | `workspace/programs/code-dev-plan.md` |
| Writes to | `my-axon/plans/<name>.md` (one file/plan) | `my-axon/dev-projects/<project>/02-plan.md`, `02-prs.md`, `02-phases/phase-N-*.md`, `03-prs/DAG.json` |
| Invoked as | `plan-new`, `plan-add`, … (agent neuron) | `code-dev plan [--mode=tactical\|strategic\|operational\|decision]` |
| Precondition | none | `01-study.md` must exist (Phase 1 done) + `L:cognition-frame ≡ "AXON-OS"` |
| Purpose | track tasks for any plan | turn a code study into an ordered, dependency-sorted PR list |

They share only the word "plan." `plan-done my-feature` does NOT advance a code-dev project, and `code-dev plan` does NOT touch `my-axon/plans/`.

---

## 1. How these are executed (important)

The `plan-*` programs are **agent-interpreted `.md` neurons**, not Python CLIs. They use a DSL (`RETRIEVE`, `QUERY(user)`, `WRITE`, `COUNT(p.§TASKS, …)`, `PROGRESS_BAR`, `FIND(fuzzy=…)`). There is **no** `python3 axon.py plan-new`.

**Verified (real captured output):**
```
$ python3 axon.py plan-new
{"error": "Unknown tool 'plan-new'. Did you mean: plan_dag? Run: python3 axon.py help"}
   (exit 1)
```
`plan_dag` is a *different*, real tool (code-dev DAG emitter), unrelated to the plan-* family.

The only real tool the neurons call is the clock, for the `Created`/`Updated` date (`ts.date`):

**Verified (real captured output):**
```
$ python3 axon.py clock today
{"timestamp": "2026-06-17 14:48:52", "iso": "2026-06-17T14:48:52.979588Z", "date": "2026-06-17", "time": "14:48:52", "unix": 1781700532, "source": "ntp"}
```
So a plan's `Created:`/`Updated:` field is populated from `.date` → `2026-06-17`.

---

## 2. Standalone `plan-*` command reference

Variables: `W:myaxon-plans` resolves (via `my-axon-init`) to `{myaxon-path}/plans/` = **`my-axon/plans/`**.
NOTE: the help files wrongly say `workspace/plans/`; that directory does not exist. Trust the programs: `my-axon/plans/`.

### `plan-new [name] [goal] [tasks?]`
- Args: `name` (short, no spaces), `goal` (one sentence), optional comma-separated starting tasks.
- Guard: fails if `my-axon/plans/<name>.md` already exists.
- Effect: writes the file, appends `plan-created` to session-log, sets `W:active-plan`.
- **Writes this exact skeleton:**
  ```
  # PLAN: <name>
  Goal:    <goal>
  Created: <ts.date>
  Updated: <ts.date>
  Status:  active

  ## TASKS
  - [ ] task one
  - [ ] task two

  ## NOTES
  ```

### `plan-add [name] [task]`
- Defaults `name` to `W:active-plan`. `task` may be comma-separated for multiple.
- Inserts `- [ ] <task>` lines immediately after `## TASKS`; bumps `Updated`.

### `plan-done [name] [task|all]`
- `task` is **fuzzy-matched** against open (`- [ ]`) tasks; first match flips `- [ ]`→`- [x]`.
- `all` flips every task to `- [x]` and sets `Status: completed`, clears `W:active-plan` if active.
- Progress line uses `done = COUNT("- [x]")`, `total = COUNT("- [")`.

### `plan-list` (read-only)
- Scans `my-axon/plans/*.md` (excludes `INDEX.md`), reads first 20 lines each.
- Per plan computes `done = COUNT(§TASKS, "- [x]")`, `total = COUNT(§TASKS, "- [")`, renders `PROGRESS_BAR(done,total,width=10)` + `done/total` + goal preview. Active first, completed below.

### `plan-view [name]` (read-only)
- Defaults to `W:active-plan`. Prints Goal/Status/Updated, `done/total done`, each task as `✓`/`○`, then NOTES.
- If `total ≡ 0` prints `(no tasks yet — run: plan-add <name> [task])`.

---

## 3. ⚠ THE TRAP — plan-new format vs real on-disk plans (RESOLVED)

**Reported:** plan-new output format mismatches real on-disk plans (0/0-task bars).
**Verdict: TRUE.** Verified against the real plans in `my-axon/plans/`.

`plan-new` *writes* the `# PLAN:` checkbox-task skeleton above. But the **actual files on disk use a different, richer, checkbox-free schema:**

`my-axon/plans/mcp-dual-agent-eval.md` (real, first lines):
```
# Plan — MCP Dual-Agent Eval: does AXON make an agent measurably better?

Status:  active
Created: 2026-05-26
Kind:    eval harness (code build)
Builds-on: tools mcp-server (exposes AXON's tools), mcp-client, a2a, axon-eval
...
## PROGRESS — 2026-05-27 ...
## GOAL
## WHY
## PHASES
## PRODUCES
## KEY OPEN DECISIONS (for the owner)
## HOW TO RUN
```
`my-axon/plans/audit-million-dollar.md` follows the same `# Plan — …` / `Kind:` / `## GOAL/## WHY/## PHASES/## PRODUCES` shape.

**Differences that break the tools:**

| Field | plan-new writes | real plans have |
|---|---|---|
| Title line | `# PLAN: <name>` | `# Plan — <freeform title>` |
| Header | `Goal:` line + `Status:` | `Status:`/`Created:`/`Kind:`/`Builds-on:` (no `Goal:` line; `Updated:` absent) |
| Body | `## TASKS` + `## NOTES` | `## GOAL`/`## WHY`/`## PHASES`/`## PRODUCES` (no `## TASKS`) |
| Tasks | `- [ ]` checkboxes | **none** — prose phases instead |

**Consequence (the 0/0 bars):** `plan-list` and `plan-view` compute `total = COUNT(§TASKS, "- [")`. The real plans contain **no `## TASKS` section and no `- [` checkboxes**, so `total = 0` and `done = 0`. Every real plan therefore renders an empty `[░░░░░░░░░░] 0/0` bar in `plan-list` and `Tasks: 0/0 done · (no tasks yet …)` in `plan-view`. `plan-done` would also fail to find any open task (`FIND(status="open")` → ∅ → `No open task matching …`).

**Bottom line:** the plan-* neuron family and the hand-authored real plans speak two different schemas; the two real plans were evidently authored by hand (or an older/other generator), not by `plan-new`. The format the tools assume is the `# PLAN:` checkbox skeleton; the format on disk is the `# Plan —` phases schema. Document/expect the **on-disk `# Plan —` schema** as the real one.

---

## 4. `code-dev-plan` (Phase 2) reference

`code-dev plan [--mode=tactical|strategic|operational|decision] [--budget N] [--rule "<text>"]`
- Precondition: active project (`W:code-dev-project`) + `{project-dir}/01-study.md` exists + identity `AXON-OS`.
- Modes / outputs:
  - `tactical` (default): `02-plan.md` + `02-prs.md` + `02-phases/phase-N-<slug>.md` + bootstraps `03-prs/DAG.json` (+`DAG.md`).
  - `strategic`: `02-plan.md` + `02-roadmap.md` (tier-1 vision, no per-PR detail).
  - `operational`: `02-plan.md` only (flat run-book, time/token est.).
  - `decision`: `02-plan.md` + appends one `03-decisions/adr-NNN-<slug>.md` per call.
  - `--budget N` caps PR count; overflow → `02-prs.deferred.md` (tactical only).
- Loop: produces plan sections + ordered atomic PR list (PR-NNN, title, scope, depends-on, complexity, why), self-rates confidence, iterates until both AXON and user score ≥ 7, then writes files and advances `_meta.phase → 3-pr`.
- Real tools it dispatches: `clock`, `constraints list`, `dag bootstrap`/`dag build-from-prs`, `rules trace`, optional `graphify-bridge pr-edges`, `calculator`.

---

## 5. Verified hybrid examples

**Example A — confirm plan-new is a neuron, not a CLI tool (runnable, real output):**
```
$ python3 axon.py plan-new
{"error": "Unknown tool 'plan-new'. Did you mean: plan_dag? Run: python3 axon.py help"}
```

**Example B — the date source the plan header uses (runnable, real output):**
```
$ python3 axon.py clock today
{"timestamp": "2026-06-17 14:48:52", "iso": "2026-06-17T14:48:52.979588Z", "date": "2026-06-17", "time": "14:48:52", "unix": 1781700532, "source": "ntp"}
```

**Example C — labeled real session-transcript for the agent-interpreted `plan-view` neuron against a REAL on-disk plan (demonstrates the trap; output is the neuron's specified template, NOT a tool run):**
```
[session-transcript · agent interprets axon/programs/plan-view.md against my-axon/plans/mcp-dual-agent-eval.md]
user> plan-view mcp-dual-agent-eval
axon>
  ▶ plan-view  ·  mcp-dual-agent-eval
  ─────────────────────────────────────────────────
  Goal:    (no `Goal:` line in file — header is `# Plan — …`; field empty)
  Status:  active   Updated: (no `Updated:` field in file)
  Tasks:   0/0 done
  (no tasks yet — run: plan-add mcp-dual-agent-eval [task])
```
The `0/0` and empty Goal/Updated are the direct, predicted result of the schema mismatch documented in section 3 (real file has no `## TASKS`, no `Goal:`/`Updated:` fields).
