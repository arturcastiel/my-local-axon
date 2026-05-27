# AXON Programs Inventory — Reference Catalog

> Reference document for AXON v3.7.0 (codebase: `/home/arturcastiel/projects/axon-development/axon`).
> Counts cross-checked against disk on 2026-05-21. `workspace/programs/REGISTRY.json`
> ships at `count: 65` but is stale — the real disk count is **183 workspace-tier
> programs + 29 kernel-tier programs = 212 program files**, plus 188 compiled outputs.

---

## 1. TL;DR

- **183 workspace programs** (`workspace/programs/*.md`) + **29 kernel-tier programs**
  (`axon/programs/*.md`) ≈ **212 program files**. The shipped `REGISTRY.json` lists
  only 65 — it is severely out of date (3:1 under-reporting).
- **Five families dominate the workspace tier**: `code-dev-*` (118 files, 64 % of catalog),
  `library-dev-*` (9), `workflow-*` (6), `axon-*` (4), `igap-*` (1). The remaining
  ~45 are single-file commands (menu, help, stats, status, gain, …) plus
  system/meta plumbing (output-layer, mode-detect, mode-router, chat-input, etc.).
- **Dispatch order** (per `axon/COMMANDS.md` line 46 and `KERNEL-SLIM.md` line 689):
  `mode-shortcut → {W:ws-os}/programs/{cmd}.md → {W:ws-programs}{cmd}.md → addons/*/`.
  Kernel files (boot, identity, mode-*) live in the first segment; user-facing
  commands live in the second.
- **Status taxonomy** (axon-polish F-D2-003, F-D2-005, F-D5-003 reconciled
  2026-05-21): **ACTIVE** (real implementation) · **STUB** (placeholder marked
  in `synapse.status`) · **ALIAS** (forwards via EXEC to canonical) · **DEPRECATED**
  (alias with removal flag) · **`autogen-stub`** (53 files with `!NORM | autogen-stub`
  marker; 16 carry the placeholder `# desc: (autogen-stub — needs description)`)
  · **`alias-stub`** (24 files; absorbed into another program but kept for back-compat)
  · **`orphan-stub`** (3 files referenced by other programs but never implemented;
  PR-119 follow-up never closed).
- **Health snapshot**: 23 % of the catalog is dead or half-alive
  (42 alias/DEPRECATED/orphan + 53 autogen-stub overlap); **154 of 188 compiled
  outputs are quarantined** (82 %, mostly 1:1 source copies from PR-121 to satisfy
  `test_every_program_has_compiled_output`); the 7 kernel `mode-*` programs are
  orphaned (per axon-polish F-D1-005 — `mode-router.md` calls `EXEC(menu)` only).

---

## 2. Program shape

A program file is a Markdown document with a fixed header layout and a
side-effect-free body of pseudocode-like instructions interpreted by the agent.
Every program lives at `[axon|workspace]/programs/<name>.md` and the
**filename is the canonical program name** (caller dispatches by base name).

### v4 schema (current; see `_code-dev-schema-v4.md`)

```markdown
# PROGRAM: <name>                       ← MUST equal filename stem
# budget:                               ← optional; token caps for cache layer
#   input-cap:    8000
#   output-cap:   2000
#   cache-prefix: 2048
# desc:    <one-line description>       ← shown by menu / find-program / list-programs
# synapse:                              ← static metadata block (PR-108 bulk infer)
#   domain: <code-dev | library-dev | workflow | …>
#   family: [<family-tag>]
#   role: <reader | mutator>
#   status: <ACTIVE | STUB | ALIAS | …>
#   invocation_source: [<program | user>]
#   precondition: "<L:/W: assertions>"
#   inputs-count: <N>
#   outputs-count: <N>
#   next-suggests: [<successor1>, <successor2>, …]
#   contract-version: neuron-contract v1.1
#   glossary: AXON-GLOSSARY v2
#   inferred-by: synapse-infer (PR-108 bulk migration)


!<CRIT|NORM> | <SPAWNED → RUNNING | read-only | autogen-stub>

## HELP                                 ← human-readable manpage
# desc:   …
# usage:  …
# inputs: W:foo / W:bar
# example: …
# outputs: …
# next:   …
# tips:   …

## IDENTITY LOCK                        ← mandatory boot-time guard
ASSERT(L:cognition-frame ≡ "AXON-OS") | HALT("Identity lost — run: boot axon")
STORE(W:active-program, "<name>")
LOG(DEBUG, "program-entry: <name>")

## LOAD CONTEXT                         ← RETRIEVE() the working keys it needs
…

## ROUTE / DISPATCH                     ← IF/EXEC chains, GOTO sections, etc.
…

## OUTPUT → PYTHON_FAST · doc           ← render-mode declaration
→ "▶ AXON / <name>"                     ← banner: required first line
→ "━━━…"
→ …

CLEAR(W:active-program)
DONE(<name>)                            ← MUST match # PROGRAM: name
```

**Mandatory pieces** (per `axon/programs/PROGRAMS.md` and the
`PROGRAM-TEMPLATE.md` checklist):

1. `# PROGRAM:` header equal to filename.
2. `# desc:` one-liner consumed by `find-program`, `list-programs`, `menu`.
3. The `▶ <name>` banner as the first rendered line.
4. Plain-English `FAIL(<name>, "Problem / Cause / Fix")` messages.
5. A trailing `Next:` hint line in the output.
6. `DONE(<name>)` matching the filename.

**Legacy (v1–v3) format** appears in older files — it used explicit
`Version:`, `Author:`, `Tools:`, `Deps:`, `Priority:`, `Model:` fields plus
`## PURPOSE / INPUTS / INSTRUCTIONS / OUTPUTS / ERROR HANDLING / EXAMPLE`
sections. v4 keeps the spirit but compresses the metadata into the `synapse:`
block and moves the human help into the `## HELP` block.

**Additive v4 fields** introduced in PR-10 (see `_code-dev-schema-v4.md`):
`schema-version`, `next-action`, `last-program`, `last-ts` in project `_meta.md`;
typed `[scope]/[pattern]/[process]` prefixes in `_dont-do.md`; ADR supersession
markers in `_decisions.md`; the `_actions.log` universal-undo file;
the `_events.log` state-change journal; `_pr-links.md` and `_links.md` tables;
`proof:` lines in spec `## Acceptance` blocks. All additive — readers ignore
unknown fields.

---

## 3. Status taxonomy

Status appears in **three places** that don't always agree:

1. **`!NORM | <flag>` line** in the body — e.g. `!NORM | autogen-stub`,
   `!NORM | SPAWNED → RUNNING`, `!NORM | read-only`, `!CRIT | read-only`.
2. **`synapse.status:`** field — `ACTIVE`, `STUB`, `ALIAS`, `DOC`, `DEPRECATED`.
3. **`# desc:` text** — frequently carries a free-form qualifier such as
   `DEPRECATED — alias for X; removed next release`.

| Status        | Where marked                             | Count* | Meaning                                                                                       |
| ------------- | ---------------------------------------- | ------ | --------------------------------------------------------------------------------------------- |
| `ACTIVE`      | `synapse.status: ACTIVE`                 | 139    | Real, runnable program. Body has substantive logic.                                            |
| `STUB`        | `synapse.status: STUB`                   | 25     | Placeholder. Inferred metadata only; body is `LOG(WARN…) + DONE`.                              |
| `ALIAS`       | `synapse.status: ALIAS` + `canonical:`   | 18     | Forwards via `EXEC(<canonical> $@)` to the renamed canonical. Kept for back-compat.            |
| `DOC`         | `synapse.status: DOC`                    | a few  | Reference / cheat-sheet program. No mutating side-effects (e.g. `help`, `faq`, `glossary`).    |
| `DEPRECATED`  | `# desc:` prefix + body alias            | 15     | Shipped alias whose removal release "never landed" (per axon-polish F-D2-005).                 |
| `autogen-stub`| `!NORM | autogen-stub` marker            | 118+   | Body shape generated by PR-108 / PR-119 bulk migration; not finished. Inside file (kernel and  |
|               |                                          |        | compiled). 53 are the *workspace-tier source* form; the rest are compiled-tier duplicates.     |
| `orphan-stub` | `# desc: orphan-stub` text               | 3      | Referenced by other code-dev programs but never implemented (`code-dev-actions.md`,            |
|               |                                          |        | `code-dev-dry-run.md`, `code-dev-examples.md`). Crashes / no-ops on dispatch.                  |
| `alias-stub`  | `# PROGRAM: alias-stub` header           | 24     | Absorbed into another program (`code-dev-review --mode=…`) but kept as forwarder. The body     |
|               |                                          |        | `LOG(WARN, "alias-deprecated: use X") → STORE(...sub) → EXEC(canonical) → DONE`.               |

*Counts via `grep -l` on disk 2026-05-21. The "ACTIVE = 139" figure includes
all programs whose synapse block is tagged ACTIVE — note that some of those
are *also* tagged `DEPRECATED` in `# desc:` or `autogen-stub` in `!NORM`,
because the synapse tag was inferred by PR-108 bulk migration before the
text-tier markers were added. This is the source of the apparent discrepancy:
ACTIVE in synapse doesn't always mean ACTIVE in practice.

### How a program gets each label

- **`autogen-stub`** — created by PR-108 / PR-119 batch jobs that synthesized
  missing program files to satisfy referenced-but-missing names found by the
  shadow scanner. Body is uniformly `LOG(WARN, "called — stub only.
  See axon-cleanup PR-119.") → DONE`.
- **`orphan-stub`** — special case of autogen-stub for the **three** programs
  that *other code-dev programs reference by name* but were never given a real
  implementation. PR-119 was supposed to close these; never did.
- **`alias-stub`** — created when a feature was renamed or consolidated (e.g.
  `code-dev-scope-check` → `code-dev-review --mode=scope`) and the old name
  was preserved as a thin EXEC-forwarder.
- **`DEPRECATED`** — manually flagged in `# desc:` when a name is officially
  superseded (e.g. `code-dev-log` → `code-dev-journal-log`). Marked "removed
  next release" but the release has not landed.

---

## 4. Dispatch order

From `axon/COMMANDS.md:46` and `axon/KERNEL-SLIM.md:689`:

```
shortcuts → {W:ws-os}/programs/{cmd}.md → {W:ws-programs}{cmd}.md → addons/*/
```

Where:

- `{W:ws-os}` = the AXON-OS source tree (`axon/` in the repo).
  Set by boot from `WORKSPACE.md`.
- `{W:ws-programs}` = the user-editable program directory
  (`workspace/programs/`). Note: the path is stored with a trailing
  slash, so concatenation is `{W:ws-programs}{cmd}.md`.
- `addons/*/` = self-contained add-on packages under `workspace/addons/<pkg>/`.

Resolution rules:

1. **Identity gate** runs first — `axon/COMMANDS.md:6-18` lists identity
   triggers ("what are you", "what model", "who made you", …) that
   short-circuit to `EXEC(axon/programs/identity.md)` before token parsing.
2. **Mode shortcuts** (`1`–`7`, `D`, `0`, `menu`) — direct routes in
   `COMMANDS.md:31-40`. They set `W:current-mode` and re-`EXEC(menu)`.
3. **Kernel-tier lookup** — `{W:ws-os}/programs/<cmd>.md`. This is how
   `identity`, `menu` (the kernel build's), `mode-build`, `dev-mode`,
   `list-chats`, `plan-new`, etc. resolve. **29 files** here.
4. **Workspace-tier lookup** — `{W:ws-programs}<cmd>.md`. This is the
   183-file pool that contains `code-dev*`, `library-dev*`, `workflow-*`,
   `axon-*`, and the single-file utilities.
5. **Add-on lookup** — `workspace/addons/*/programs/<cmd>.md`.
6. **Fuzzy match fall-through** — `axon/COMMANDS.md:64-87`
   builds `FUZZY_MATCH(input, all-names, threshold=0.6, max=3)` and renders
   a "did you mean" list against the union of all three layers.
7. **Smart-dispatch pre-flight** — `COMMANDS.md:89-120` calls
   `TOOL(dispatch, match, --query <input>)` to see if a *compiled* program
   matches with high enough confidence; if so, the compiled `.cmp.md` is
   `EXEC`'d directly. Compiled runs use ~30 % of interpreted tokens.

Examples of each path being hit:

| Input          | Where it lands                                              | Why                                                                  |
| -------------- | ----------------------------------------------------------- | -------------------------------------------------------------------- |
| `what are you` | `axon/programs/identity.md`                                 | identity-gate matches "what are you".                                |
| `menu`         | `axon/programs/menu.md` (kernel) **or** workspace version   | Same name shadowed — `{W:ws-os}/programs/menu.md` wins per dispatch. |
| `1`            | `axon/programs/mode-chat.md` (via shortcut + ws-os lookup)  | Shortcut sets `W:current-mode`. (axon-polish F-D1-005: mode-*        |
|                |                                                             | programs are orphaned in practice — `mode-router` only EXECs `menu`.)|
| `code-dev`     | `workspace/programs/code-dev.md`                            | No kernel `code-dev.md` exists; falls through to workspace.          |
| `dev-mode`     | `axon/programs/dev-mode.md`                                 | Owner-only tier, kernel-resident.                                    |
| `auto-improve` | `workspace/programs/auto-improve.md`                        | Workspace-only program.                                              |

The shadowing is one-way: **workspace cannot override kernel**. If a user
adds `workspace/programs/identity.md`, the kernel version still wins. To
override, the user must work in dev-mode and edit `axon/programs/`.

---

## 5. Families

### 5.1 `code-dev-*` — the bulk of the catalog

118 files (64 %). The 5-phase development workflow for large codebases:
**study → plan → PR specs → log → audit**. Plus state, safety, knowledge,
journal, review, meta, flow, shape, lifecycle, and 21 `pr-*` sub-programs.

| Sub-cluster                  | Count | Purpose                                                                | Notable entries                                                                                                          |
| ---------------------------- | ----- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **`code-dev` (root)**        | 1     | Dispatch hub — `code-dev [new\|load\|study\|plan\|pr\|log\|audit\|…]`. | `code-dev.md` routes via giant IF/EXEC chain.                                                                            |
| **`code-dev-pr-*`**          | 21    | PR lifecycle: spec → review → ready → respond → merge.                 | `code-dev-pr-create` (canonical), `code-dev-pr-ready`, `code-dev-pr-respond`, `code-dev-pr-github`, `code-dev-pr-review` |
| **`code-dev-pr-review-p1…p9`**| 9    | Split phases of the giant `code-dev-pr-review` (PR-20.8).              | All `autogen-stub` in the current build; quarantined when compiled.                                                      |
| **`code-dev-knowledge-*`**   | 5     | Knowledge: study, shadow index, deep-dive explain, impact.             | `code-dev-knowledge` (router), `-knowledge-shadow`, `-knowledge-explain`, `-knowledge-impact`, `-knowledge-reviewer-track`|
| **`code-dev-state-*`**       | 7     | Project state: status, save, restore, undo, metrics, resume, handoff. | `code-dev-state` (router), `-state-save` (canonical for `tag`), `-state-undo` (canonical for `undo`), `-state-resume`     |
| **`code-dev-safety-*`**      | 5     | Phase freezes, governance, preflight gates, dont-do, audit.            | `code-dev-safety` (router), `-safety-freeze`, `-safety-preflight`, `-safety-audit`, `-safety-audit-structure`             |
| **`code-dev-journal-*`**     | 5     | Journal: log entries, decisions (ADR), events, search.                 | `code-dev-journal` (router), `-journal-log` (canonical for `log`), `-journal-decision`, `-journal-event`, `-journal-search`|
| **`code-dev-review-*`**      | 7     | PR review: coverage, diff, scope, self-review, tests, plus root.       | `code-dev-review` (root), `-review-coverage`, `-review-diff`, `-review-scope`, `-review-self`, `-review-tests`, `-reviewer-track`|
| **`code-dev-meta-*`**        | 6     | Meta: board (kanban), context (multi-project), dispatch-stats, usage, igap. | `code-dev-meta` (router), `-meta-board`, `-meta-context`, `-meta-dispatch-stats`, `-meta-igap`, `-meta-usage`             |
| **`code-dev-flow-*`**        | 1     | Multi-PR sequencing, merges, releases router.                          | `code-dev-flow` (router only).                                                                                            |
| **`code-dev-shape-*`**       | 1     | Plan-shape router — restructure phases and PRs.                        | `code-dev-shape` (router only).                                                                                           |
| **`code-dev-lifecycle-*`**   | 2     | Lifecycle router + onboarding tour.                                    | `code-dev-lifecycle`, `code-dev-lifecycle-tour`.                                                                          |
| **Phase entry points**       | 3     | Phase 1/2/3/4/5 starters; legacy names.                                | `code-dev-study`, `code-dev-plan`, `code-dev-plan-master`, `code-dev-phase-new`, `code-dev-phase-start`                   |
| **Top-level utilities**      | many  | Diff, search, branch, tag, freeze, link, event, etc. — many are alias-stubs. | `code-dev-init`, `code-dev-load`, `code-dev-new`, `code-dev-branch`, `code-dev-link`, `code-dev-cascade`, `-changelog` … |

**Health note**: Of the 118 code-dev programs, 53 have the `!NORM | autogen-stub`
marker, 24 are `alias-stub`, 15 are DEPRECATED. Even accounting for overlap,
the family carries the bulk of the project's "vocabulary debt" (axon-polish
F-D2-006: "User must internalize 118 names. Menu surfaces ~10 of them.").

**Canonical-name map** (DEPRECATED → ACTIVE):

```
code-dev-log         → code-dev-journal-log
code-dev-decision    → code-dev-journal-decision
code-dev-event       → code-dev-journal-event
code-dev-search      → code-dev-journal-search
code-dev-explain     → code-dev-knowledge-explain
code-dev-impact      → code-dev-knowledge-impact
code-dev-shadow      → code-dev-knowledge-shadow
code-dev-status      → code-dev-state-status
code-dev-metrics     → code-dev-state-metrics
code-dev-handoff     → code-dev-state-handoff
code-dev-resume      → code-dev-state-resume
code-dev-undo        → code-dev-state-undo
code-dev-tag         → code-dev-state-save
code-dev-freeze      → code-dev-safety-freeze
code-dev-tour        → code-dev-lifecycle-tour
code-dev-pr          → code-dev-pr-create
```

### 5.2 `library-dev-*` — academic library / PDF ingest

9 files. Workflow: **new → ingest → explain → intersect → search → report → cite**.

| Program                  | Status    | Purpose                                                                  |
| ------------------------ | --------- | ------------------------------------------------------------------------ |
| `library-dev`            | ACTIVE    | Router — `library-dev [new\|ingest\|…\|status] [--library name]`.        |
| `library-dev-new`        | ACTIVE    | Create a new library workspace (under `workspace/libraries/<slug>/`).    |
| `library-dev-ingest`     | ACTIVE    | Scan article folder, shadow new PDFs/TXTs, update INDEX.                 |
| `library-dev-explain`    | ACTIVE    | Generate annotated explained doc for one or all shadowed articles.       |
| `library-dev-status`     | ACTIVE    | Show library index, coverage, and next actions.                          |
| `library-dev-cite`       | STUB      | Generate bibliography from all shadowed articles. PLANNED-only.          |
| `library-dev-intersect`  | STUB      | Find themes, overlaps, contradictions across explained articles. PLANNED.|
| `library-dev-report`     | STUB      | Generate structured report — certainty-gated, gap-aware. PLANNED.        |
| `library-dev-search`     | STUB      | Search online for articles related to library topics. PLANNED.           |

**Health note**: 4 of 9 are STUB / PLANNED-only (per axon-polish F-D5-004).
Libraries live in `workspace/libraries/<name>/` and are gitignored —
never pushed to the backup remote.

### 5.3 `workflow-*` — generic workflow runtime

6 files. The newer (PR-100+) DAG-based workflow engine, separate from
the 5-phase `code-dev` pipeline.

| Program             | Status | Purpose                                                                                |
| ------------------- | ------ | -------------------------------------------------------------------------------------- |
| `workflow-list`     | ACTIVE | List every workflow file under `workspace/workflows/` with one-line summary.           |
| `workflow-new`      | ACTIVE | Conversational author (per `conversational-author-v1.md`). Phases A→E dialog.          |
| `workflow-run`      | ACTIVE | Execute a workflow file end-to-end — walks synapse DAG, dispatches by predicates.      |
| `workflow-edit`     | ACTIVE | Interactive editor for an existing workflow file. Validates before save.               |
| `workflow-simulate` | ACTIVE | Dry-run a workflow file. No side effects.                                              |
| `workflow-validate` | ACTIVE | Schema-validate against `workspace/schemas/workflow-file.schema.json` (PR-105).        |

**Note**: The menu surfaces a special `workflow run adaptive-free-text` mode,
which is the orchestrator-driven "FREE MODE". axon-polish F-D4-003 flags
this as an infinite loop in current form (not the 25-bounded one
the docs claim).

### 5.4 `axon-*` — meta tooling for AXON itself

4 workspace-tier files. Used by maintainers to audit and re-document AXON.

| Program          | Status | Purpose                                                                                                                  |
| ---------------- | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| `axon-audit`     | ACTIVE | Two-pass: (1a) structural integrity — boot, refs, internals; (1b) usefulness — health, coverage, token-savings potential. |
| `axon-compare`   | ACTIVE | Web-search AXON's online presence; compare against similar agent orchestration / harness frameworks.                      |
| `axon-docs-gen`  | ACTIVE | Regenerate AXON documentation with architecture diagrams and relationship maps.                                           |
| `axon-reanchor`  | ACTIVE | Per-turn kernel re-load + cognition-frame restore + persona-bleed scan.                                                   |

### 5.5 `mode-*` — kernel-tier mode shells

7 kernel-tier files in `axon/programs/`. Each renders a mode-specific menu
when the user enters that mode (`1`–`7` shortcuts).

| Program       | Tier   | Purpose                                                            |
| ------------- | ------ | ------------------------------------------------------------------ |
| `mode-chat`   | kernel | CHAT mode — manage conversation threads and project folders.       |
| `mode-build`  | kernel | BUILD mode — create and register new AXON programs.                |
| `mode-run`    | kernel | RUN mode — launch installed programs and add-ons.                  |
| `mode-memory` | kernel | MEMORY mode — browse what AXON knows and remembers.                |
| `mode-system` | kernel | SYSTEM mode — tools, output mode, session, and health.             |
| `mode-plan`   | kernel | PLAN mode — goals and multi-step task tracking.                    |
| `mode-dev`    | kernel | DEV mode — kernel editing, system programs, AXON authoring.        |

**Health note (axon-polish F-D1-005)**: All 7 are **orphaned**. The mode
shortcut handler in `axon/COMMANDS.md:31-40` sets `W:current-mode` and
re-EXECs `menu` — it does *not* call `mode-chat`, `mode-build`, etc.
And the workspace `mode-router.md` only EXECs `menu` when a mode is
active. So these 7 kernel programs exist as files but **no live caller
dispatches to them**. They are dead code in the current routing.

The corresponding workspace-tier programs `mode-detect`, `mode-router`,
`mode-suggest` (in `workspace/programs/`) are different and *are* live —
they classify free-text, route to the active mode's handler, and surface
related-program suggestions after 3 turns in a mode.

### 5.6 `igap-*` — inference-gap reporting / improvement

1 file in the workspace tier (`igap-improve.md`), plus the `igap` *tool*
that backs it (in `axon/tools/`).

| Program        | Status | Purpose                                                                                  |
| -------------- | ------ | ---------------------------------------------------------------------------------------- |
| `igap-improve` | ACTIVE | Review logged inference gaps; drive study→plan→execute cycle to close them. Dev-mode.   |

The igap concept: AXON logs each time it had to guess or do a web-search
to fill a knowledge gap. `igap stats` / `igap report` use the tool;
`igap-improve` is the human-driven loop that closes them. Inside
`code-dev-meta` there's also a `code-dev-meta-igap` (autogen-stub) wrapper.

### 5.7 Single-file commands (workspace tier)

~40 files. The "everything else" bucket — top-level utilities, dashboards,
discovery, and self-observation tools.

| Category           | Programs                                                                                                              |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **Home & menus**   | `menu`, `status`, `stats`, `quickstart`, `help`, `faq`, `glossary`                                                    |
| **Discovery**      | `find-program`, `list-tools`, `explain`, `simulate`, `discover`, `gain`, `deps`, `versions`                           |
| **Memory**         | `show-memory`, `memory-compact`, `undo`, `handoff`, `resume`, `session-summary`, `turn-log`                           |
| **System / health**| `health-check`, `run-tests`, `register-tool`, `output-layer`, `translate`                                             |
| **Self-improve**   | `auto-improve`, `auto-actions`, `meta`, `orchestrator`, `compile-optimizer`, `suggest-compile`, `shadow-retroactive-bulk`|
| **Workspace ops**  | `migrate-workspace`, `my-axon-init`, `workspace-backup`                                                               |
| **Mode plumbing**  | `mode-detect`, `mode-router`, `mode-suggest`, `chat-input`                                                            |
| **Authoring**      | `authoring-guide`, `harness-builder`                                                                                  |
| **Privacy**        | `prompt-log-consent`                                                                                                  |
| **Cleanup**        | `_code-dev-schema-v4` (reference, prefixed with underscore for non-dispatch)                                          |

### 5.8 System / meta (cross-tier)

These straddle kernel and workspace:

| Program          | Tier      | Status     | Purpose                                                                                  |
| ---------------- | --------- | ---------- | ---------------------------------------------------------------------------------------- |
| `identity`       | kernel    | !CRIT       | AXON identity response — fires on any "what are you / who are you" meta-question.        |
| `boot`           | built-in  | meta-prog   | Full kernel boot sequence (KERNEL.md STEPS 1–11). Defined in BOOT.md, not a single file. |
| `output-layer`   | workspace | ACTIVE      | Toggle / configure confidence bar, drift indicator.                                      |
| `axon-reanchor`  | workspace | ACTIVE      | Per-turn kernel re-load + cognition-frame restore + persona-bleed scan.                  |
| `dev-mode`       | kernel    | ACTIVE      | Toggle owner developer mode on or off (persists).                                        |
| `dev-new`        | kernel    | ACTIVE      | Scaffold a new program from template — workspace or addon.                               |
| `register-tool`  | workspace | ACTIVE      | Guided wizard to add a new tool entry to REGISTRY.json (dev-mode required).              |

### 5.9 Kernel-tier programs in full (`axon/programs/`, 29 files)

For completeness, here is the kernel directory:

| Area                     | Programs                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------- |
| Identity & contract       | `identity`                                                                                          |
| Modes                     | `mode-chat`, `mode-build`, `mode-run`, `mode-memory`, `mode-system`, `mode-plan`, `mode-dev`        |
| Chats (sessions)          | `_chat-checkpoint`, `chat-folder`, `list-chats`, `new-chat`, `open-chat`, `switch-chat`             |
| Plan workflow             | `plan-add`, `plan-done`, `plan-list`, `plan-new`, `plan-view`                                       |
| Preferences               | `register-preference`, `show-preferences`                                                           |
| Dev-mode & extension       | `dev-mode`, `dev-new`                                                                              |
| Discovery                 | `_index`, `interactive`, `list-programs`                                                            |
| Reference (not programs)  | `PROGRAMS`, `PROGRAMS-SLIM`, `PROGRAM-TEMPLATE`                                                    |

`PROGRAMS.md`, `PROGRAMS-SLIM.md`, `PROGRAM-TEMPLATE.md` are not dispatchable —
they are documentation files that happen to live in the programs/ dir.

---

## 6. Top-30 programs by likely usage

Ranked by **menu prominence + entry-point status + cross-referenced by
other programs**. This is judgment-based; the dispatch-stats tool can
produce an empirical ranking from `usage` logs once the workspace has run.

| Rank | Program             | Family       | Why high usage                                                                                    |
| ---- | ------------------- | ------------ | ------------------------------------------------------------------------------------------------- |
| 1    | `menu`              | system       | Home screen. Re-shown on `0`, `menu`, mode entry. Workspace overlay over the kernel `menu`.        |
| 2    | `status`            | system       | Live OS dashboard. One of the three footer commands.                                              |
| 3    | `help`              | system       | Universal program manpage. `help [name]` before any unfamiliar command.                           |
| 4    | `code-dev`          | code-dev     | Top-level router for the entire 5-phase development workflow.                                     |
| 5    | `code-dev-init` / `code-dev-new` | code-dev | Create a new dev project. Required first call in the workflow.                              |
| 6    | `code-dev-load`     | code-dev     | Switch active project — second-most-frequent code-dev invocation.                                 |
| 7    | `code-dev-study`    | code-dev     | Phase 1 — shadow-first file ingestion + goal definition.                                          |
| 8    | `code-dev-plan`     | code-dev     | Phase 2 — codebase-grounded plan + numbered PR list.                                              |
| 9    | `code-dev-pr-create`| code-dev     | Phase 3 — per-PR spec (canonical). Old name `code-dev-pr` is now a DEPRECATED alias.              |
| 10   | `code-dev-journal-log` | code-dev  | Phase 4 — log implementation entries. Canonical (old: `code-dev-log`).                            |
| 11   | `code-dev-safety-audit` | code-dev | Phase 5 — audit log vs PR spec. Canonical (old: `code-dev-audit`).                                |
| 12   | `code-dev-state-status` | code-dev | What's the current state of the active project. Canonical (old: `code-dev-status`).               |
| 13   | `code-dev-state-resume` | code-dev | Reconstruct context after compaction or session break. v4 critical-path command.                  |
| 14   | `code-dev-state-handoff` | code-dev | Single-file briefing for next session/person (post-compaction or human handoff).                  |
| 15   | `code-dev-knowledge-shadow` | code-dev | Inspect / refresh the shadow index. The shadow gate is enforced before every read.            |
| 16   | `find-program`      | discovery    | Capability search over all 183 programs. Surfaced on menu and every mode banner.                  |
| 17   | `list-tools`        | discovery    | Browse all registered tools (~86 active per REGISTRY.json).                                       |
| 18   | `simulate`          | discovery    | Dry-run any program. Strongly recommended before irreversible operations.                         |
| 19   | `explain`           | discovery    | Plain-English program walkthrough.                                                                |
| 20   | `library-dev`       | library-dev  | Top-level router for academic library / PDF ingest.                                               |
| 21   | `library-dev-ingest`| library-dev  | Scan article folder, shadow new PDFs/TXTs.                                                        |
| 22   | `library-dev-explain` | library-dev | Generate annotated explained doc for shadowed articles.                                           |
| 23   | `workflow-run`      | workflow     | Execute a saved workflow YAML end-to-end.                                                         |
| 24   | `workflow-new`      | workflow     | Conversational workflow author.                                                                   |
| 25   | `auto-improve`      | self-improve | Daily orchestrator — closes auto-applicable improvement loops.                                    |
| 26   | `auto-actions`      | self-improve | Render a recap of recent auto-edits from the audit ledger.                                        |
| 27   | `axon-audit`        | axon-meta    | Structural + usefulness integrity audit.                                                          |
| 28   | `axon-docs-gen`     | axon-meta    | Regenerate AXON-DOCS.md.                                                                          |
| 29   | `igap-improve`      | igap         | Close logged inference gaps (dev-mode).                                                           |
| 30   | `workspace-backup`  | workspace    | Push workspace to private GitHub remote.                                                          |

---

## 7. Stub / alias inventory

### 7.1 Autogen-stubs (~118 files carry the marker; **53 are the workspace-tier
*source* form**, the rest are compiled duplicates)

These are the source-tier `autogen-stub` files (PR-108 / PR-119 batch). They
are visible in `find-program`, listed in catalogs, and increment the "183
programs" count, but their bodies are placeholder logs.

```
_code-dev-schema-v4              code-dev-pr-export                code-dev-pr-respond
auto-improve                     code-dev-pr-github                code-dev-pr-review-p1
code-dev-actions                 code-dev-pr-link                  code-dev-pr-review-p2
code-dev-audit                   code-dev-pr-list                  code-dev-pr-review-p3
code-dev-branch                  code-dev-pr-ready                 code-dev-pr-review-p4
code-dev-cascade                 code-dev-pr-suggest-reviewer      code-dev-pr-review-p5
code-dev-changelog               code-dev-pr-sync                  code-dev-pr-review-p6
code-dev-chats                   code-dev-pr-update-spec           code-dev-pr-review-p7
code-dev-combine                 code-dev-replay                   code-dev-pr-review-p8
code-dev-divide                  code-dev-resume                   code-dev-pr-review-p9
code-dev-dont-do                 code-dev-review                   code-dev-self-review
code-dev-event                   code-dev-review-coverage          code-dev-since
code-dev-events-emit             code-dev-review-diff              code-dev-state
code-dev-explain                 code-dev-review-scope             code-dev-state-handoff
code-dev-explain-reviewer        code-dev-review-self              code-dev-state-metrics
code-dev-flow                    code-dev-review-tests             code-dev-state-save
code-dev-freeze                  code-dev-reviewer-track           code-dev-state-status
code-dev-handoff                 code-dev-rules-audit              code-dev-state-undo
code-dev-help                    code-dev-safety                   code-dev-test-map
code-dev-hold                    code-dev-safety-audit-structure   code-dev-tour
code-dev-impact                  code-dev-safety-freeze            code-dev-undo
code-dev-init                    code-dev-safety-preflight         code-dev-whatif
code-dev-journal                 code-dev-scope-check              code-dev-shape
code-dev-journal-decision        code-dev-search                   code-dev-shadow
code-dev-journal-event           code-dev-suggest-tests            igap-improve
code-dev-journal-log             code-dev-tag                      library-dev
code-dev-journal-search          code-dev-knowledge                library-dev-cite
code-dev-knowledge-impact        code-dev-knowledge-reviewer-track library-dev-explain
code-dev-knowledge-shadow        code-dev-lifecycle                library-dev-ingest
code-dev-lifecycle-tour          code-dev-link                     library-dev-intersect
code-dev-load                    code-dev-log                      library-dev-report
code-dev-merge                   code-dev-meta                     library-dev-search
code-dev-meta-board              code-dev-meta-context             library-dev-status
code-dev-meta-dispatch-stats     code-dev-meta-igap                migrate-workspace
code-dev-meta-usage              code-dev-metrics                  my-axon-init
code-dev-migrate                 code-dev-new                      workspace-backup
code-dev-next                    code-dev-partition                code-dev-phase-new
code-dev-phase-start             code-dev-plan-master              code-dev-pr
code-dev-pr-drift
```

Many entries carry the placeholder `# desc: (autogen-stub — needs description)` —
16 are explicit per axon-polish F-D2-003 (code-dev-pr-review-p1..p9 plus the 7
`code-dev-meta-*` programs).

> Note: An `autogen-stub` marker means *the !NORM line still says so*. Some
> of these files have substantial bodies under the marker (the marker was
> auto-applied during synthesis and never cleared after real code landed).
> To know if it's truly stub, check the body — `code-dev-state-resume.md`
> is real code despite the marker.

### 7.2 Alias-stubs (24 files)

Absorbed into another program; kept as forwarders.

```
code-dev-self-review        →  code-dev-review --mode=self
code-dev-scope-check        →  code-dev-review --mode=scope
code-dev-diff               →  code-dev-review --mode=diff
code-dev-suggest-tests      →  code-dev-review --mode=tests
code-dev-check-structure    →  code-dev-safety-audit --structure
```
(plus 19 more — axon-polish counted 24 total via `# PROGRAM: alias-stub` header)

### 7.3 DEPRECATED (15 files — marked "removed next release" but never removed)

| Old name              | Canonical replacement      |
| --------------------- | -------------------------- |
| `code-dev-log`        | `code-dev-journal-log`     |
| `code-dev-decision`   | `code-dev-journal-decision`|
| `code-dev-event`      | `code-dev-journal-event`   |
| `code-dev-search`     | `code-dev-journal-search`  |
| `code-dev-explain`    | `code-dev-knowledge-explain`|
| `code-dev-impact`     | `code-dev-knowledge-impact`|
| `code-dev-shadow`     | `code-dev-knowledge-shadow`|
| `code-dev-status`     | `code-dev-state-status`    |
| `code-dev-metrics`    | `code-dev-state-metrics`   |
| `code-dev-handoff`    | `code-dev-state-handoff`   |
| `code-dev-resume`     | `code-dev-state-resume`    |
| `code-dev-undo`       | `code-dev-state-undo`      |
| `code-dev-tag`        | `code-dev-state-save`      |
| `code-dev-freeze`     | `code-dev-safety-freeze`   |
| `code-dev-tour`       | `code-dev-lifecycle-tour`  |

(Plus `code-dev-pr` → `code-dev-pr-create`, which is tagged as "alias stub" via
`# desc:` rather than "DEPRECATED" — boundary is fuzzy. Per axon-polish, the
combined alias+DEPRECATED+orphan count is 42 files = 23 % of the catalog.)

### 7.4 Orphan-stubs (3 files — never implemented; PR-119 follow-up)

```
code-dev-actions     — referenced by other code-dev programs, no body
code-dev-dry-run     — referenced by other code-dev programs, no body
code-dev-examples    — referenced by other code-dev programs, no body
```

Each has the placeholder body:
```
LOG(WARN, "code-dev-<name> called — stub only. See axon-cleanup PR-119.")
→ "▶ code-dev-<name>  ·  stub (not yet implemented)"
DONE(code-dev-<name>)
```

Any program that dispatches to them effectively no-ops with a warning.

---

## 8. Compiled programs

### What the compiler does

`compile-optimizer` (`workspace/programs/compile-optimizer.md`) scans every
program and produces a compressed `.cmp.md` variant under
`workspace/programs/compiled/`. The compiled form is meant to:

- Strip comments, banner text, and HELP blocks.
- Pre-resolve `RETRIEVE()` chains where possible.
- Trim repeated boilerplate to ~30 % of source size.
- Land on a token budget given by the `# budget:` header
  (`input-cap`, `output-cap`, `cache-prefix`).

The dispatch tool (`axon/tools/dispatch.md`) prefers a `.cmp.md` over the
source `.md` when it exists *and* is not quarantined — a "compiled hit"
costs ~30 % of the interpreted run.

### Compiled directory

`workspace/programs/compiled/` contains **188 `*.cmp.md` files** + one
`_quarantine.md` register. Naming: `<program-name>.cmp.md`.

### Quarantined: 154 of 188 (82 %)

Per `compiled/_quarantine.md`, two quarantine classes ship:

1. **Negative-compression (1 program)** — `code-dev-pr-review` (source
   22,856 B → compiled 23,056 B, ratio 1.01). Tracked by PR-20.8 (split into
   `p1..p9`). The PR-2 audit gate caught it.
2. **Verbatim-copy bulk quarantine (153 programs)** — every entry with
   reason `verbatim copy (no compression applied)` and ratio `1.00`,
   added 2026-05-17 by PR-121 to satisfy the
   `test_every_program_has_compiled_output` test. These were never run through
   the real compressor; the `.cmp.md` is literally `cp src dst`.

**What "quarantined" means at dispatch**: per the `_quarantine.md` header,
"Dispatch loader skips these." So the smart-dispatch pre-flight in
`COMMANDS.md` will not pick a quarantined compiled program even if it scores
high — it falls through to the interpreted source.

**Practical impact (axon-polish F-D3-007)**: "AXON-DOCS-COMPILER claims real
compression; 82 % of compileds are byte-equal placeholders. The compiler
subsystem produces meaningful output for only ~18 % of the catalog." So most
"compiled" runs in practice are actually running the source.

### Non-quarantined compileds (~34 files)

These are the ones genuinely compressed. Sampling:
`auto-actions`, `axon-audit`, `axon-compare`, `axon-docs-gen`, `axon-reanchor`,
`chat-folder`, `chat-input`, `code-dev-actions` (the orphan stub trivially
compresses), `code-dev-audit`, `code-dev-init`, `code-dev-pr-review-p*` (all 9
phases), plus the smaller utilities. These actually save tokens at dispatch
time.

### Compile-on-demand

`suggest-compile` surfaces programs run often enough to deserve compilation.
`compile-optimizer status` shows current coverage. Dev-mode required to
write compiled outputs.

---

## 9. Naming inconsistencies

### `-new` vs `-create` vs `-init`

Three near-synonyms used for "create new instance". No documented rule.

| Program             | Verb     | What it creates              |
| ------------------- | -------- | ---------------------------- |
| `code-dev-new`      | new      | a new code-dev project       |
| `code-dev-init`     | init     | same — alias of `code-dev-new` (both run on `code-dev new`)|
| `code-dev-phase-new`| new      | a new phase within a project |
| `code-dev-pr-create`| create   | a new PR spec (canonical for old `code-dev-pr`)|
| `library-dev-new`   | new      | a new library workspace      |
| `workflow-new`      | new      | a new workflow YAML          |
| `new-chat`          | new (prefix)| a new chat thread        |
| `plan-new`          | new      | a new plan                   |
| `my-axon-init`      | init     | the my-axon user-data folder |
| `dev-new`           | new      | a new program from template  |

Pattern: `<thing>-new` is the most common (5 of 10). `<thing>-init` shows up
on root/setup operations (`my-axon-init`, `code-dev-init`). `<thing>-create`
appears only in `code-dev-pr-create`, which itself supersedes the old
`code-dev-pr` (so the suffix was added during rename to disambiguate). The
two `new` prefixes (`new-chat`) are kernel-tier holdovers — workspace
gravitates to suffix form.

### Sub-noun ordering — `<verb>-<noun>` vs `<noun>-<verb>`

The kernel uses prefix verbs:

```
new-chat       open-chat       switch-chat       list-chats
plan-new       plan-add        plan-done         plan-view       plan-list
```

But the workspace uses noun-then-verb:

```
code-dev-new   code-dev-load   code-dev-status   code-dev-init
library-dev-new   library-dev-ingest   library-dev-status
workflow-new   workflow-run   workflow-edit   workflow-validate
```

Result: kernel says `new-chat` (verb-first), workspace says `code-dev-new`
(noun-first). Same operation, opposite ordering. axon-polish does not
explicitly flag this but it is reflected in the vocabulary debt
(F-D2-006). The list-form is also mixed: kernel uses both `list-chats`
(plural verb) and `plan-list` (singular noun + verb suffix).

### Family-name re-use as routing prefix

`code-dev <subcommand>` resolves to `code-dev-<subcommand>.md`. The
top-level `code-dev` program contains a giant `IF cmd ≡ "X" → EXEC(code-dev-X)`
chain. The same pattern holds for `library-dev` and `workflow`. But:

- `code-dev branches` (plural) jumps to a section inside `code-dev.md` rather
  than dispatching to a file. The implicit naming would be
  `code-dev-branches`, but the file `code-dev-branch.md` (singular) handles
  individual branch operations. The mismatch between menu plural and
  file singular is silent.
- `code-dev pr` and `code-dev pr-spec` both dispatch to `code-dev-pr.md`,
  which is itself an alias for `code-dev-pr-create.md` — three names for
  one operation.
- `code-dev review` dispatches to `code-dev-pr-review.md` (not
  `code-dev-review.md`). The file `code-dev-review.md` exists separately
  as the "consolidated review" surface (P7), with sub-modes like
  `--mode=scope`, `--mode=tests`, etc.

### Compound prefixes — `state-` vs `safety-` vs `journal-` etc.

The newer convention (post-PR-14) groups programs under named umbrella
routers:

| Umbrella                  | Sub-area covered                                                  |
| ------------------------- | ----------------------------------------------------------------- |
| `code-dev-state`          | status / next / resume / handoff / metrics / save / restore / undo |
| `code-dev-safety`         | freeze / thaw / dont-do / preflight / audit                       |
| `code-dev-journal`        | log / decision / event / search                                   |
| `code-dev-knowledge`      | study / shadow / explain / impact / reviewer-track                |
| `code-dev-lifecycle`      | new / init / load / tour                                          |
| `code-dev-flow`           | plan / merge / cascade / changelog / test-map / finalize          |
| `code-dev-shape`          | combine / divide / partition / phase / plan-master / link         |
| `code-dev-meta`           | whatif / help / actions / context / cheatsheet / dry-run / examples|

But not all old top-level names were migrated. Result: `code-dev-init` exists
in parallel with `code-dev-lifecycle` (which says "use lifecycle for new/init"),
and `code-dev-resume` exists in parallel with `code-dev-state-resume` (the
canonical) — both as files, both dispatchable. The user is exposed to both
naming systems simultaneously.

### Misc

- **Singular vs plural** — `list-chats` (kernel) vs `library-dev-cite` (no
  plural form), `code-dev-chats` (sub-program, plural). `axon-audit` (sub
  results in plural usage). No rule.
- **Hyphenation in compound nouns** — `code-dev-pr-update-spec` (4 hyphens),
  `code-dev-pr-suggest-reviewer` (4 hyphens), `code-dev-phase-new` (3 hyphens).
  Length scales with sub-cluster depth.
- **Underscore prefix** — `_chat-checkpoint.md`, `_code-dev-schema-v4.md`,
  `_index.md`, `_quarantine.md`. Convention: leading underscore means
  "internal / reference / not user-invokable". `_chat-checkpoint`
  explicitly says "Not user-invokable" in its `# desc:`.

---

## Cross-references

- **Kernel-tier source** — `axon/programs/` (29 files), `axon/PROGRAMS-INDEX.md`
  (curated grouping by area).
- **Workspace-tier source** — `workspace/programs/` (183 files),
  `workspace/programs/REGISTRY.json` (stale; 65 of 183 entries).
- **Compiled outputs** — `workspace/programs/compiled/` (188 files +
  `_quarantine.md` for 154 quarantined entries).
- **Dispatch contract** — `axon/COMMANDS.md:44-46`, `axon/KERNEL-SLIM.md:689`.
- **Authoring template** — `axon/programs/PROGRAM-TEMPLATE.md`,
  authored against `axon/programs/PROGRAMS.md` and
  `axon/programs/PROGRAMS-SLIM.md`.
- **v4 schema** — `workspace/programs/_code-dev-schema-v4.md` (additive
  fields for `_meta.md`, `_dont-do.md`, `_decisions.md`, `_actions.log`,
  `_events.log`, `_pr-links.md`, `_links.md`).
- **Health findings** — `my-axon/dev-projects/axon-polish/_flaws.md` and
  `_verified-findings.md` (reconciled 2026-05-21). Key:
  F-D1-005 (modes orphaned), F-D2-003 (53 autogen-stubs), F-D2-005
  (42 alias/DEPRECATED/orphan files), F-D2-006 (118 code-dev names),
  F-D3-007 (154/188 quarantined), F-D5-003 (3 orphan-stubs), F-D5-004
  (4 library-dev planned-only).

---

## Counts at a glance

```
Total program files     : 212    (183 workspace + 29 kernel)
Workspace programs      : 183
  code-dev-*            : 118    (64 %)
    code-dev-pr-*       :  21    (incl. 9 review-p1..p9)
    code-dev-state-*    :   7
    code-dev-safety-*   :   5
    code-dev-journal-*  :   5
    code-dev-knowledge-*:   5    (incl. root)
    code-dev-review-*   :   7
    code-dev-meta-*     :   6
    code-dev-flow/shape :   2    (routers only)
    code-dev-lifecycle  :   2
  library-dev-*         :   9    (4 STUB / PLANNED-only)
  workflow-*            :   6
  axon-*                :   4
  igap-*                :   1
  single-file commands  :  ~45
Kernel programs         :  29    (incl. 7 mode-* — orphaned in routing)
REGISTRY.json count     :  65    (stale — 35 % of true count)

Status distribution:
  ACTIVE (synapse tag)  : 139
  STUB                  :  25
  ALIAS                 :  18
  DOC                   :   a few
  autogen-stub (!NORM)  : 118 files share the marker (53 sources, 65 compileds)
  alias-stub            :  24
  orphan-stub           :   3
  DEPRECATED            :  15

Combined dead / half-alive workspace surface (axon-polish):
  42 of 183 = 23 %      (alias+DEPRECATED+orphan)
  +53 autogen-stubs (overlapping) = larger dead surface

Compiled outputs        : 188
  quarantined           : 154    (82 % — 1:1 source copies, PR-121 placeholder)
  effective compiled    :  34    (~18 % of catalog)
```
