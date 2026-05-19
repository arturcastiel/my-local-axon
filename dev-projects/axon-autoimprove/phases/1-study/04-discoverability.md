# Discoverability audit — "the infrastructure is there but the menu doesn't surface it"
> Date: 2026-05-19. Scope: `workspace/programs/menu.md` + adjacent user-facing surfaces.
> Repo: `/mnt/c/projects/axon` · 182 programs · 77 ACTIVE tools.

## 0. Executive summary (TL;DR)

The thesis is **TRUE — and the gap is severe.** AXON ships **182 programs** (`workspace/programs/*.md`) and **77 ACTIVE tools** (`tools/REGISTRY.json`), but the menu's two render branches (`menu.md:135–322` non-dev, `menu.md:417–529` dev) name **only ~22 programs** by directly typeable command. Roughly **17 more** are mentioned only in the randomised `tips ← RAND(tips)` list (`menu.md:107–130` / `379–411`), where the user sees **exactly one tip per render** — i.e. ~1 in 22 odds per session. The "new AXON" capabilities shipped by `axon-synapse` — orchestrator, synapse ranker, ephemeral suggestions, DAG planning, code-dev pseudo-state-machine, dispatch-stats, board, telemetry, output-layer — are **almost entirely absent from the menu surface** (orchestrator appears only as a *data source* for the suggestions footer, never as a typeable command). **Discoverability coverage ≈ 12 %** (§9). Highest-leverage single fix: add a `DISCOVER / META` section to the menu that names `orchestrator`, `find-program`, `board`, `dispatch-stats`, `auto-improve`, `handoff`, `simulate`, `explain`, `gain`, `discover` as first-class commands, the way `igap` already is.

---

## 1. Inventory — what AXON HAS

### 1.1 Programs — categories vs surface

Total `workspace/programs/*.md` (excluding `compiled/`): **182**. Of those, menu.md **names by typeable command** ~22 programs; tips reference ~17 more; remaining ~143 are reachable only via `find-program`, `help`, `list-programs`, or filesystem browse.

| Family | Examples | Count | Surface in menu.md |
|---|---|---|---|
| Mode router | chat / build / run / memory / system / plan / programs / dev | 8 | direct (`[1]..[7]` + `[D]`) — `menu.md:223–231,468–484` |
| Core meta | menu · quickstart · status · stats · help · health-check · session-summary | 7 | direct — footer `menu.md:307,514` |
| code-dev (umbrella) | code-dev + 65 sub-programs (`code-dev-*.md`) | 66 | umbrella only — 6 subcommands named at `menu.md:236–239,490–492` |
| code-dev-state-* (resume / handoff / undo / save / metrics / status) | 6 files | 6 | **0** — invisible at top level (only inside `code-dev state ...` router) |
| code-dev-meta-* (board / dispatch-stats / igap / usage / context) | 5 files | 5 | **0** — stub `desc:    (autogen-stub — needs description)` (`code-dev-meta-board.md:?`) |
| code-dev-pr-review-p1..p9 | review pipeline | 9 | **0** |
| library-dev | library-dev + 8 subs | 9 | direct — `menu.md:241–246,494–499` |
| workflow-* | new / edit / list / run / simulate / validate | 6 | **0** |
| Synapse / orchestrator era | orchestrator · auto-improve · auto-actions · output-layer · mode-detect · mode-router · mode-suggest | 7 | partial — `auto-actions` direct (`menu.md:297`), `auto-improve` only inside SELF-IMPROVEMENT panel when toggle is ON (`menu.md:272–274`), `orchestrator` **invisible as a command** (only its tick is read: `menu.md:34`) |
| Discoverability helpers | find-program · discover · gain · explain · simulate · authoring-guide · glossary · faq · list-tools · translate · versions · resume · undo · handoff · harness-builder · deps · memory-compact · show-memory · register-tool · my-axon-init · workspace-backup · prompt-log-consent · run-tests · turn-log · session-summary · meta · status · stats | ~28 | **mixed** — `quickstart · status · stats · help · undo --list · my-axon-init · workspace-backup · auto-actions · axon-audit · compile-optimizer · axon-docs-gen · lint-paths` are direct; the rest (~17) are **tips-only** at `menu.md:107–129,379–411` |
| Library-of-AXON-itself | axon-audit · axon-compare · axon-docs-gen · compile-optimizer · suggest-compile · shadow-retroactive-bulk · migrate-workspace · register-tool | 8 | partial — META TOOLS `menu.md:294–299,(no dev mirror)` |
| Long tail (chat-input · explain · simulate · translate · turn-log · ...) | misc | ~16 | tips-only or invisible |

**Programs surfaced in menu (direct, name-as-command):** ~22 of 182 ≈ **12 %**.
**Programs surfaced in tips only (1-in-N visibility):** ~17 of 182 ≈ **9 %**.

### 1.2 Tools — what's wired but invisible

Source: `tools/REGISTRY.json`, 77 ACTIVE.

| Tool | One-line value | Menu mention |
|---|---|---|
| synapse-suggest | ranks the next program against state/goal/history (`tools/synapse_suggest.py:1`) | **none** — used internally by orchestrator only |
| synapse-infer | emits neuron-contract records from program metadata | **none** |
| synapse-validate | validates a neuron contract against the v1.1 schema | **none** |
| dispatch | TF-IDF match free-text → compiled program (`tools/dispatch.py:1`) | only the count `dispatch: N entries` at `menu.md:158` — no command verb |
| dispatch-stats | weekly token savings, accuracy, top dispatched programs | **none** |
| drift | edit-distance drift gate (`tools/drift.py`) | shown only when state ≠ stable (`menu.md:177–178,276–280`); no `drift check` discoverable when stable |
| igap | inference gap tracker | direct — `menu.md:250–251,503–504` ✓ |
| board | ASCII Kanban over PR aggregate (`tools/board.py`) | **none** |
| plan_dag | Plan DAG emitter + critical path | **none** |
| pr_aggregate / pr_drift / pr_export / pr_sync | PR pipeline | **none** |
| auto-audit | append-only ledger of auto-edits | indirect — drives `unread-rows` counter (`menu.md:184–188`); no command surfaced |
| auto-improve | daily orchestrator (`tools/auto_improve.py`) | only inside SELF-IMPROVEMENT panel `menu.md:271–274` |
| usage | tracks calls + suggests compile candidates | **none** (the `find-program` tip references nothing usage-related) |
| pattern | TF-IDF cluster prompt log → compile candidates | **none** |
| predicate | evaluate AXON predicate v1.1 | **none** |
| context | context-pressure estimator | **none** (also OUTPUT-LAYER:`axon/OUTPUT-LAYER.md` admits it is PLANNED in render — see line "Context-pressure tool is PLANNED") |
| simulate | dry-run a program | tips-only |
| pack / events / hooks / cron / queue | infra | tips-only or none |
| All 15 code-dev / shadow tools | indexing, idempotence, cd_cache, study_evals... | **none** |

**ACTIVE tools surfaced in menu (typeable):** ~6 of 77 ≈ **8 %**.

### 1.3 Capabilities introduced by axon-synapse (the "new AXON")

| Capability | Where it lives | How a user observes/invokes it today |
|---|---|---|
| Synapse ranker | `tools/synapse_suggest.py` — `rank()` at line 338 | **invisible**; only emergent in suggestions footer if `orchestrator-last-tick` happens to be populated (`menu.md:34,311–316`) |
| Suggestions footer | `menu.md:311–317` (non-dev), `menu.md:518–524` (dev) | **conditional render only** — `IF sugg-on ≡ true AND COUNT(sugg-cands) > 0`; toggle `L:suggestions-enabled` is mentioned inline but never explained |
| Ephemeral suggestions | spec: `axon/OUTPUT-LAYER.md` (output-layer footer) | not addressable from menu; no `--why` or `--explain-suggestion` verb |
| DAG planning | `tools/plan_dag.py`, `workspace/tools/dag.md`, `code-dev-plan-master.md` | **invisible** — no menu hint, no `plan dag` command in CODE DEVELOPMENT section |
| Code-dev pseudo-state-machine | `code-dev-state.md` umbrella + 6 `code-dev-state-*.md` files + `_actions.log` | not on menu — must type `code-dev state status` blindly. The phase tag `proj-phase` *is* shown (`menu.md:165`) but no link to `state next` / `state resume` |
| Drift gate | `tools/drift.py` + `axon/OUTPUT-LAYER.md` gather block | shown only when `drift-state ≠ stable` (`menu.md:175–178`); discoverable only by misbehaving |
| Orchestrator loop | `workspace/programs/orchestrator.md` | **never named as a command** anywhere in menu — only its output key is consumed |
| Dispatch + dispatch-stats | `tools/dispatch.py`, `tools/dispatch_stats.py` | dispatch count number visible (`menu.md:158`); `dispatch-stats` is unreachable from menu |
| Telemetry counters | `tools/usage.py find-program` (per autoimprove _goal #6) | only "find-program" appears in tips |
| Output-layer receipt | `axon/OUTPUT-LAYER.md` + program `workspace/programs/output-layer.md` | rendered every turn but never explained on the menu |

---

## 2. Inventory — what MENU SHOWS

Source: `workspace/programs/menu.md`. The file has two render branches that diverge significantly.

### 2.1 Non-dev render (lines 132–322)

| Section | Lines | What appears |
|---|---|---|
| Header | `135–142` | banner, ws name, date, author byline |
| OS STATE panel | `144–196` | Health · Inference · Compiled (`dispatch: N entries`) · Tools · Memory · Project · Library · Queue · Cron · Infer gaps · Drift (only when ≠ stable) · Prompt-log consent (conditional) · Auto-actions unread count (conditional) · Backup |
| Active mode badge | `198–203` | shows current mode if any |
| Active context | `205–221` | chat · plans-active · plans-done · resumed · resumable |
| MODES menu | `223–231` | `[1] CHAT [2] BUILD [3] RUN [4] MEMORY [5] SYSTEM [6] PLAN [7] PROGRAMS [D] DEV` (D only if dev-mode) |
| CODE DEVELOPMENT | `234–246` | `[8] code-dev` (subcommands listed) · `[9] library-dev` (subcommands listed) |
| QUALITY / SELF-IMPROVEMENT | `248–258` | `igap report` · `igap stats` · `igap improve` |
| SELF-IMPROVEMENT panel (conditional) | `260–289` | renders only IF `auto-improve-on ≡ true OR drift-state ≠ stable OR audit-7d.total > 0`. Lists: `auto-improve · auto-actions · undo · auto-audit · drift` |
| META TOOLS | `292–299` | `axon-audit · compile-optimizer status · axon-docs-gen · auto-actions · undo --list <path> · lint-paths` |
| Backup prompt (conditional) | `301–304` | `workspace-backup push` |
| Footer line | `307` | `quickstart · status · stats · help [program]` |
| Suggestions footer (conditional) | `311–317` | top-3 ranked candidates IF `sugg-on AND COUNT(cands)>0` |
| Tip | `319` | one random tip from 22-entry list (`menu.md:107–129`) |

### 2.2 Dev render (lines 326–529)

Roughly the same skeleton, **but the dev branch is missing the META TOOLS, SELF-IMPROVEMENT panel, and the Backup prompt** that the non-dev branch has. Notable differences:

- No OS STATE panel block (no Health line, no Compiled coverage line, no Auto-actions unread, no Drift badge in passing — drift-state isn't even computed in this branch).
- No META TOOLS block (`axon-audit`, `axon-docs-gen`, `compile-optimizer`, `lint-paths` are **not surfaced in dev render**) — this is upside-down: dev users are exactly the audience for those.
- Tips list is longer (33 entries, `menu.md:379–411`) but still RAND-sampled to 1.

### 2.3 Programs/tools surfaced by direct command (union of both branches)

```
DIRECT:  menu · quickstart · status · stats · help · health-check
         code-dev (+6 sub forms) · library-dev (+5 sub forms)
         igap report · igap stats · igap improve
         axon-audit · compile-optimizer · axon-docs-gen · auto-actions
         undo --list · lint-paths · workspace-backup · my-axon-init
         drift check (conditional only) · resume (conditional only)
         auto-improve toggle (panel only, kv-store form, not as program)
TIPS:    plan new · simulate · explain · session-summary · cron add · pack
         deps check · undo · find-program · hooks add · handoff
         memory-compact · glossary · faq · gain · discover · harness-builder
         authoring-guide · list-programs
```

---

## 3. The gap — what's IN §1 but NOT in §2

Severity legend: `!CRIT` = power feature invisible · `!HIGH` = usable but undiscoverable · `!NORM` = nice-to-find · `!LOW` = deeply niche.

| Item | Category | Menu absent? | Quickstart absent? | Glossary absent? | Only discovery path | Severity |
|---|---|---|---|---|---|---|
| `orchestrator` | synapse / new AXON | ✓ | ✓ | ✓ | filesystem / docs | **!CRIT** |
| `synapse-suggest` (typeable) | synapse / new AXON | ✓ | ✓ | ✓ (no synapse entry) | tools/REGISTRY.md | **!CRIT** |
| `dispatch-stats` | synapse / new AXON | ✓ | ✓ | ✓ | registry | **!CRIT** |
| `dispatch` (verb) | synapse / new AXON | ✓ (count only) | ✓ | partial | registry | !HIGH |
| `plan_dag` / `code-dev plan dag` | planning / new AXON | ✓ | ✓ | ✓ | code-dev-plan-master.md | **!CRIT** |
| `board` (meta board) | observability / new AXON | ✓ | ✓ | ✓ | REGISTRY.md | **!CRIT** |
| `auto-improve` (as command) | self-improvement | partial (panel only when ON) | ✓ | ✓ | autoimprove _goal.md | **!CRIT** |
| `code-dev-state-resume` | code-dev state machine | ✓ | ✓ | ✓ | help only | **!CRIT** |
| `code-dev-state-handoff` | code-dev state machine | ✓ | partial (`handoff` mentioned QS:345) | ✓ | help | !HIGH |
| `code-dev-state-undo` | code-dev state machine | ✓ | ✓ | ✓ | help | !HIGH |
| `code-dev-state-metrics` | code-dev state machine | ✓ | ✓ | ✓ | help | !HIGH |
| `code-dev-state-status` | code-dev state machine | ✓ | ✓ | ✓ | help | !HIGH |
| `code-dev-state-save` | code-dev state machine | ✓ | ✓ | ✓ | help | !HIGH |
| `code-dev-meta-board` | meta | ✓ | ✓ | ✓ | filesystem (stub desc) | !HIGH |
| `code-dev-meta-dispatch-stats` | meta | ✓ | ✓ | ✓ | filesystem (stub desc) | !HIGH |
| `code-dev-meta-igap` | meta | ✓ | ✓ | ✓ | filesystem (stub desc) | !HIGH |
| `code-dev-meta-usage` | meta | ✓ | ✓ | ✓ | filesystem (stub desc) | !HIGH |
| `output-layer` (program) | new AXON | ✓ | ✓ | partial | OUTPUT-LAYER.md | !HIGH |
| `find-program` | discovery | tips-only | ✓ | ✓ | tip 1-in-22 | **!CRIT** |
| `discover` (context waste) | discovery | tips-only | ✓ | ✓ | tip | !HIGH |
| `gain` (session analytics) | discovery | tips-only | ✓ | ✓ | tip | !HIGH |
| `handoff` (top-level) | session | tips-only | direct (QS step 7) | ✓ | tip / quickstart | !NORM |
| `simulate` (top-level) | safety | tips-only | ✓ | ✓ | tip | **!CRIT** (irreversible-ops safety) |
| `explain` (top-level) | discovery | tips-only | ✓ | ✓ | tip | !HIGH |
| `list-tools` | discovery | ✗ | ✓ | ✓ | filesystem | !NORM |
| `list-programs` | discovery | tips-only (`find-program` adjacent) | ✓ | ✓ | tip | !NORM |
| `glossary` | docs | tips-only | ✓ | n/a (is the file) | tip | !HIGH |
| `faq` | docs | tips-only | ✓ | ✓ | tip | !HIGH |
| `authoring-guide` | docs | tips-only | ✓ | ✓ | tip | !NORM |
| `harness-builder` | meta | tips-only | ✓ | ✓ | tip | !NORM |
| `pack` / `deps check` | infra | tips-only | ✓ | partial | tip | !NORM |
| `mode-detect` / `mode-suggest` / `mode-router` | mode router | ✓ | ✓ | ✓ | filesystem | !NORM (used internally) |
| `workflow-new` / `-edit` / `-list` / `-run` / `-simulate` / `-validate` | workflow authoring | ✓ | partial | ✓ | filesystem | !HIGH |
| `register-tool` | extensibility | ✓ | ✓ | ✓ | filesystem | !NORM |
| `versions` / `chat-input` / `turn-log` | meta | ✓ | ✓ | ✓ | filesystem | !LOW |
| `memory-compact` / `show-memory` | memory | tips-only | partial | partial | tip | !NORM |
| `prompt-log-consent` | privacy | conditional badge only | ✓ | ✓ | conditional menu badge | !NORM |
| `usage` tool (verb) | telemetry | ✓ | ✓ | ✓ | none | **!CRIT** (autoimprove acceptance #6 depends on it) |
| `pattern` tool | telemetry | ✓ | ✓ | ✓ | none | !HIGH |
| `pr_*` tools (board, drift, export, sync) | code-dev | ✓ | ✓ | ✓ | inside code-dev-pr-* programs | !HIGH |
| `shadow-retroactive-bulk` | maintenance | ✓ | ✓ | ✓ | filesystem | !NORM |
| `events` / `hooks` / `cron` / `queue` (verbs) | reactive infra | tips-only | partial | partial | tip | !HIGH |
| `compile` / `compile-write` / `compile_optimizer` (full surface) | compilation | partial (`compile-optimizer status` only) | partial | partial | filesystem | !HIGH |

**Totals by category:**

- new-AXON / synapse capabilities missing: **9 of 10** (only the suggestions footer renders, and only conditionally).
- code-dev state-machine surface missing: **6 of 6** (umbrella router hidden behind the `code-dev` keyword, no top-level access).
- code-dev-meta-* missing: **5 of 5** (and their `desc:` is the literal string "autogen-stub — needs description" — see `code-dev-meta-board.md`).
- workflow-* missing: **6 of 6**.
- Discovery helpers tips-only: **~10 of ~14**.
- Total severity-!CRIT: **8**.

---

## 4. Failure-mode walkthroughs

### (a) "I want suggestions about what to do next" → synapse ranker
- **Menu suggests**: the suggestions footer at `menu.md:311–317` — but it renders **only if** `sugg-on ≡ true AND COUNT(sugg-cands) > 0`. The user doesn't know what enables it, what `L:suggestions-enabled` is, or that running `orchestrator` populates `W:orchestrator-last-tick`.
- **Capability lives at**: `workspace/programs/orchestrator.md:1`, `tools/synapse_suggest.py:338` (`rank()`).
- **Hops**: 3+ (read footer hint → search docs → discover orchestrator → run it).
- **Verdict**: **undiscoverable** unless the orchestrator has already fired in this session.

### (b) "I want to see my recent auto-improve actions" → `auto-actions`
- **Menu suggests**: `auto-actions  ▶ N unread — run: auto-actions` (`menu.md:188`) — but ONLY if `unread-rows > 0`. Also lives in META TOOLS (`menu.md:297`) in the **non-dev render**.
- **Capability lives at**: `workspace/programs/auto-actions.md`.
- **Hops**: 1 if unread; ∞ in dev render (META TOOLS block is missing from `menu.md:417–529`).
- **Verdict**: **discoverable in non-dev, undiscoverable in dev mode** — inverted from intent.

### (c) "I want to plan a feature with dependencies" → `plan_dag` / DAG
- **Menu suggests**: `plan new` is mentioned in tips (`menu.md:111`), and `[6] PLAN` mode says "break down big goals into tracked steps" (`menu.md:374`). No mention of DAG, dependencies, or critical path.
- **Capability lives at**: `tools/plan_dag.py:1`, invoked by `code-dev-plan-master.md`.
- **Hops**: 4+ (enter PLAN mode → realise it's flat → read code-dev-plan → discover plan_dag).
- **Verdict**: **undiscoverable** — the feature exists at tool level but no program names DAG planning in menu, quickstart, or glossary.

### (d) "I want to resume a half-done code-dev project" → `code-dev-state-resume`
- **Menu suggests**: When `loaded-project ≠ ∅`, line `menu.md:165` renders `Project ▶ {slug} · phase: {phase} · {codebase}` — but **no link to `code-dev state resume`**. If `resumable ≠ ∅`, line `menu.md:219` says `resume` (the top-level `resume.md` program), which is **different** from the code-dev state machine resume.
- **Capability lives at**: `workspace/programs/code-dev-state-resume.md:8` ("Compaction recovery — read 10 layers, render fixed briefing").
- **Hops**: 3 (type `code-dev` → discover `state` subcommand exists by reading help → type `code-dev state resume`).
- **Verdict**: **discoverable-but-mislabeled** — `resume` at top level is a different program from the project-state recovery user needs.

### (e) "I want to undo the last L: change" → `undo`
- **Menu suggests**: `undo --list <path>` in META TOOLS (`menu.md:298`) — non-dev only. Tips also say "Type 'undo' after a program run" (`menu.md:396`).
- **Capability lives at**: `workspace/programs/undo.md`, `tools/undo.py`.
- **Hops**: 1 in non-dev render; 1-in-33 in dev render (tips-only).
- **Verdict**: **discoverable-but-asymmetric** — dev users see it less than novice users.

### (f) "I want to see how AXON measures itself" → `dispatch-stats` / `drift` / `igap`
- **Menu suggests**: `igap report/stats/improve` are direct (`menu.md:250–256`). `drift` shows only when degraded (`menu.md:177`). `dispatch-stats` is **completely absent**.
- **Capability lives at**: `tools/dispatch_stats.py:1`, `tools/drift.py`, `tools/igap.py`.
- **Hops**: 1 for igap, 3+ for drift in stable state, ∞ for dispatch-stats.
- **Verdict**: **partially discoverable** — only igap is consistently surfaced.

### (g) "I want to know which programs are popular" → `usage.py find-program`
- **Menu suggests**: a tip "Type 'find-program [description]' to search by capability" (`menu.md:397`) — 1-in-33 odds in dev tips, 1-in-22 in non-dev.
- **Capability lives at**: `tools/usage.py` (top/suggest/record), `workspace/programs/find-program.md`.
- **Hops**: 1 if tip fires, else search.
- **Verdict**: **undiscoverable** in practice — autoimprove acceptance #6 depends on this counter, but no menu surface counts down to it.

### (h) "I want to handoff this session to another agent" → `handoff`
- **Menu suggests**: tip-only (`menu.md:122,401`).
- **Capability lives at**: `workspace/programs/handoff.md`, quickstart STEP 7 (`quickstart.md:345`) mentions it.
- **Hops**: 1 if user is in quickstart, else 1-in-22+ random tip.
- **Verdict**: **discoverable-but-only-via-quickstart**.

### (i) "I want to inspect the pseudo-state-machine board" → `board.py` / `code-dev-meta-board`
- **Menu suggests**: nothing.
- **Capability lives at**: `tools/board.py:1`, `workspace/programs/code-dev-meta-board.md` (description: `(autogen-stub — needs description)`).
- **Hops**: ∞ — even if the user finds the program, its own description is unhelpful.
- **Verdict**: **undiscoverable AND mislabeled at source**.

---

## 5. The cause — why does the gap exist?

**H1: menu.md hasn't kept pace with synapse landings.** `git log --oneline -- workspace/programs/menu.md` shows the last menu touches were PR-112 (`3f2d35d` — added the suggestions footer), PR-108 (metadata migration), PR-018 (self-improvement panel), PR-015 (auto-actions badge), PR-013, PR-012 (drift badge). The orchestrator program (PR-111), synapse-suggest (PR-110-ish), plan_dag, board, dispatch-stats, code-dev-state-* family, and the code-dev-meta-* family **never received a menu PR**. Each piece of infrastructure was integrated *as a data source* (e.g. `W:orchestrator-last-tick` is read at `menu.md:34`) but never *as a typeable command*. **Strong evidence.**

**H2: no menu-update checklist in synapse PRs.** The synapse-goals project shipped 10 acceptance criteria (per `axon-autoimprove/_goal.md`) but none of them mention "menu surface". The author's own thesis confirms this — infrastructure was prioritised over surfacing. **Strong evidence.**

**H3: meta programs are deliberately dev-gated.** Partly true: `igap improve` is dev-gated (`menu.md:252–258`), the `[D] DEV` mode badge appears only when `dev ≡ true` (`menu.md:229–231,482–484`). But `auto-actions`, `axon-audit`, `compile-optimizer`, `axon-docs-gen` live in META TOOLS which is in the **non-dev render only** (`menu.md:292–299` has no mirror in lines 417–529). This is **upside-down**, not "intentionally hidden". **Refuted as a complete explanation — partial evidence of confusion.**

**H4: suggestions footer was supposed to bridge the gap.** Examining `tools/synapse_suggest.py:338–401` (`rank()`) + `menu.md:33–35,311–317`: the footer renders top-N candidates from `W:orchestrator-last-tick.candidates`. But that key is only populated by `orchestrator.md:127` after the orchestrator program has run. **The user must already know about / have run the orchestrator for suggestions to appear** — circular discoverability. **Confirmed: the bridge is one-way.**

**H5: quickstart / glossary / faq are stale.** `grep` confirms: `quickstart.md` mentions `synapse` only in its own header metadata; no step explains the orchestrator, the ranker, the suggestions footer, DAG planning, state-machine, or dispatch-stats. `glossary.md` defines `drift`, `confidence`, `output layer`, `harness`, `compile` (line 40) but has **no entry for synapse, orchestrator, ranker, ephemeral, DAG, board, dispatch-stats, auto-improve, igap-improve, ephemeral-suggestion**. `faq.md` covers `undo`, `drift`, `output-layer` — no synapse-era Q&A. **Strong evidence.**

---

## 6. Proposed remedy — concrete menu redesign

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AXON · {ws} · {ts.date}                       ⚙ DEV
  by Dr. Artur Castiel Reis de Souza · arturcastiel.github.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  OS STATE
  ─────────────────────────────────────────────
  Health        ●●●●○ 78/100 · Inference 5/10 (balanced)
  Compiled      42/182 programs · Tools 77 · Memory 14W/233L
  Project       ▶ auth-redesign · phase: 03-plan · py · ⟲ state resume
  Drift         ✓ stable    Auto-improve  OFF (kv-store set L:auto-improve true)
  Suggestions   ▶ ON · last tick {sugg-tick.ts[:16]} · {COUNT(sugg-cands)} cand.
  Igap          {igap-total} today · Auto-actions {N} unread
  Backup        ✓ {backup-url[:40]} · last: {backup-last}

  MODES                                  CODE & LIBRARY
  ─────────────────────────────────────  ──────────────────────────────
   [1] CHAT      ask & explore             [8] code-dev  study→plan→PR
   [2] BUILD     write programs                · state status|resume|undo|handoff
   [3] RUN       launch programs               · plan dag (deps + critical path)
   [4] MEMORY    browse & manage              · meta board | dispatch-stats
   [5] SYSTEM    tools, output, cron       [9] library-dev  ingest→shadow→cite
   [6] PLAN      break goals down              · intersect | report | search
   [7] PROGRAMS  search & explain          [D] DEV       (if dev-mode)

  DISCOVER  (find what AXON can do)
  ─────────────────────────────────────────────
  find-program <text>    — search 182 programs by capability
  list-tools             — 77 active tools, by category
  explain <program>      — plain-English walkthrough
  simulate <program>     — dry-run before irreversible
  discover               — find context waste in your workspace
  gain                   — session analytics & efficiency trend

  SELF-OBSERVE  (how AXON measures itself)
  ─────────────────────────────────────────────
  orchestrator           — rank next step against current state ✦new
  synapse-suggest --top 5 — raw ranker output (debug)             ✦new
  dispatch-stats         — weekly token savings & accuracy        ✦new
  igap report | stats | improve   — inference gaps
  drift check            — tool-call drift score
  board                  — ASCII Kanban over PR pipeline          ✦new
  auto-improve [--dry-run]  — daily self-improvement loop         ✦new
  auto-actions           — review recent auto-edits
  undo --list <path> | undo <key>   — roll back L:/file changes

  META  (the AXON of AXON)
  ─────────────────────────────────────────────
  axon-audit · axon-docs-gen · compile-optimizer · lint-paths
  handoff · session-summary · pack · workspace-backup push
  authoring-guide · glossary · faq · quickstart

  ─────────────────────────────────────────────
  suggestions  (live · toggle: L:suggestions-enabled)
  ▶ {c0.name}   reason: {c0.reason}   conf: {c0.score}
     {c1.name}  reason: {c1.reason}   conf: {c1.score}
     {c2.name}  reason: {c2.reason}   conf: {c2.score}
  ─────────────────────────────────────────────
  tip: {tip}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Highest-leverage 3 if only 3 can land:**

1. **Add a `SELF-OBSERVE` section** naming `orchestrator`, `synapse-suggest`, `dispatch-stats`, `drift check`, `board`, `auto-improve` as direct commands. Closes 6 of the 8 !CRIT gaps in one edit. Pure menu.md change.
2. **Add a `DISCOVER` section** naming `find-program`, `simulate`, `explain`, `discover`, `gain`, `list-tools`. Demotes the random `tips` block from "primary discovery mechanism" to "trivia". Closes 4 !CRIT/!HIGH gaps.
3. **Mirror META TOOLS into the dev render** (fix the asymmetry from §2.2 / §4(b),(e)). One-line copy. Zero new programs, just stops penalising power users.

---

## 7. PR plan

| PR | Title | Files touched | Test surface | Reversibility | Depends on |
|---|---|---|---|---|---|
| PR-A | `menu: add SELF-OBSERVE section` | `workspace/programs/menu.md` (both branches) | `tests/test_menu_render.py` — assert literal strings `orchestrator`, `dispatch-stats`, `board`, `auto-improve`, `drift check` in both render branches | revert single file | — |
| PR-B | `menu: add DISCOVER section + demote tips` | `menu.md` (both branches), keep `tips ← RAND(tips)` but trim by removing items now in DISCOVER | `tests/test_menu_render.py` — assert `find-program`, `simulate`, `explain`, `discover`, `gain`, `list-tools` present; tips count = new total | revert single file | PR-A |
| PR-C | `menu: mirror META TOOLS into dev render` | `menu.md:417–529` only | extend `tests/test_menu_render.py` with `--dev-mode` fixture asserting `axon-audit`, `axon-docs-gen`, `compile-optimizer`, `lint-paths`, `auto-actions`, `undo --list` all render | revert single file | — |
| PR-D | `glossary/faq: cover synapse-era terms` | `workspace/programs/glossary.md`, `faq.md` — add entries: synapse, orchestrator, ranker, ephemeral suggestion, DAG plan, board, dispatch-stats, auto-improve, drift gate | `tests/test_glossary_coverage.py` — assert each of the 9 terms has a definition | revert two files | — |
| PR-E | `code-dev-meta-*: fix autogen-stub descriptions` | `code-dev-meta-board.md`, `code-dev-meta-dispatch-stats.md`, `code-dev-meta-igap.md`, `code-dev-meta-usage.md`, `code-dev-meta-context.md` | `tests/test_program_metadata.py` — assert no `desc: (autogen-stub` strings remain in workspace/programs | revert per-file | — |

Dependency order: PR-A → PR-B (both touch the same blocks; rebase friendly). PR-C, PR-D, PR-E independent and can land in parallel.

---

## 8. New demands for axon-autoimprove

| ID | Title | Description | Acceptance |
|---|---|---|---|
| `D-A20` | discoverability-coverage tool | New `tools/discoverability.py coverage` walks `workspace/programs/*.md` and `tools/REGISTRY.json`, reads `workspace/programs/menu.md`, computes `(programs_named_in_menu / total_programs) × 100`. Reports per-category breakdown. | running `python3 tools/discoverability.py coverage` prints JSON `{total: N, surfaced: M, pct: X, missing: [...]}` and exits 0; exits 2 if pct < 50 |
| `D-A21` | menu-coverage CI lint | A program lands without a menu entry (or a `# menu-exempt: true` front-matter directive) → CI fails. Wired into `lint-paths`-style pre-push hook. | new test `tests/test_menu_coverage.py` asserts every ACTIVE program either appears in menu.md by name OR has `# menu-exempt:` in its header; PR template includes a "menu surface?" checkbox |
| `D-A22` | synapse-suggest debug surface | `synapse-suggest --explain --recent` reads current `W:orchestrator-last-tick` and prints the top-N candidates + per-signal score breakdown without re-running orchestrator. Lets the user *see* why a suggestion fired. | running it after any orchestrator tick prints a non-empty ranked list; closes the orchestrator-circular discoverability loop noted in H4 |
| `D-A23` | menu surfaces the autoimprove counter | Whenever `tools/usage.py find-program` baseline (acceptance #6) reaches ≥ 7 days, menu OS STATE renders one line: `Baseline ✓ {days}d · hit-rate {pct}%` — gives the user evidence that auto-improve is collecting data. | line renders in both menu branches when `E:baseline-YYYY-MM` exists; test asserts presence |

---

## 9. Discoverability-coverage metric

Define: `discoverability_coverage = (programs_named_directly_in_menu / total_programs) × 100`.

**Math from §1 and §2:**

- Programs named directly (typeable from menu): ~22 (8 mode tokens + code-dev/library-dev umbrellas + igap×3 + meta-tools×6 + footer×4)
- Programs surfaced only via random tips: ~17
- Total `workspace/programs/*.md` excluding `compiled/`: **182**

`coverage_strict = 22 / 182 ≈ 12.1 %`
`coverage_loose (incl. tips) = 39 / 182 ≈ 21.4 %` — but with `tip ← RAND(tips)`, expected per-render visibility of any single tip ≈ `1/22 ≈ 4.5 %`, so amortised coverage of tip items is `17 × (1/22) / 182 ≈ 0.4 %` per render.

**Verdict: coverage is well below 50 %.** Recommendation: ship **D-A21** (menu-coverage CI lint with `# menu-exempt:` opt-out). Without the lint, every new program post-PR-A will silently re-create the gap.

---

## 10. Confidence summary

**HIGH-confidence findings (cite-backed, reproducible):**

1. Menu names only ~22 of 182 programs directly. (`menu.md:135–322,417–529`)
2. Orchestrator program is referenced as data (`menu.md:34,340`) but never as a typeable command.
3. Dev render is **missing** the META TOOLS section that non-dev render has (`menu.md:292–299` has no analogue in lines 417–529).
4. `code-dev-meta-*` programs ship with `desc: (autogen-stub — needs description)` — confirmed for `code-dev-meta-board.md`, `-dispatch-stats.md`, `-igap.md`, `-usage.md`.
5. Suggestions footer is circular: requires `orchestrator` to have run, but orchestrator is itself undiscoverable from the menu.
6. Glossary defines `drift`, `confidence`, `output layer`, `harness`, `compile` (`glossary.md:40`) — has **no synapse / orchestrator / ranker / DAG / board / dispatch-stats / auto-improve** entry.
7. Quickstart 7-step tour never mentions synapse, ranker, orchestrator, state-machine, DAG, board, or dispatch-stats. (`quickstart.md` grep confirmed.)
8. `git log workspace/programs/menu.md` last seven commits show no synapse-feature surfacing PR — last menu touch was PR-112 (suggestions footer plumbing).

**MED-confidence findings:**

1. Severity scores in §3 reflect my judgment of "is this a power feature?" — debatable at the !HIGH/!NORM boundary for `workflow-*`, `mode-*`, `pr_*` tools (would need usage-log data from `tools/usage.py` to ground-truth).
2. The "22 directly named" count counts mode tokens `[1]..[7]` as 8 but does not de-duplicate `igap report` / `igap stats` / `igap improve` as one program — different counting choices yield 18–26.
3. Tips list visibility math assumes uniform `RAND()` and one render per session, which is approximate.

**Skipped areas (and why):**

- I did not audit the **CLI bindings** (`axon.py`) — outside the menu UX scope and likely covered by the bug-hunt audit.
- I did not check whether `dispatch.py` actually routes free-text `orchestrator` to the orchestrator program (correctness, not discoverability — synapse-goals scope).
- I did not assess the `tools/REGISTRY.md` markdown index file's UX — it's a developer artifact, not user-facing.
- I did not audit `workspace/programs/compiled/` because by design it mirrors source programs.
- I did not score the dev-only DAG/board sub-tooling in code-dev-meta-* deeper than confirming the stub descriptions, because that's already a !HIGH finding on metadata alone.