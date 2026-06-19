# State-Machine DAG (program-per-node) — Council Report

**Council:** AXON Completeness Gate — "State-Machine DAG (program-per-node)"
**Role:** Deliberator synthesis of 4 sealed seat opinions (Node-Enumeration, Edge/Transition, Reachability, Challenger)
**Status:** Advisory. Read-only investigation. No repo files modified except this report.
**Date:** 2026-06-19

---

## 1. Executive Summary

AXON ships with a **real, machine-readable program graph** — `# synapse:` frontmatter (`domain / family / role / status / invocation_source / next-suggests`) on each program, a parser/validator (`tools/dag_consistency.py`), an edge consumer/ranker (`tools/synapse_suggest.py`, `tools/anticipate.py`), and a self-model program (`workspace/programs/deps.md`). The council does **not** need to invent a node schema; it needs to materialize, type, and repair the one that exists.

But the honest artifact is **not a DAG and not a single graph**. The four seats converge on five hard facts, all verified live against the repo:

1. **Two un-reconciled node populations.** `workspace/programs/` holds 174 `.md` (173 named in `REGISTRY.json`, plus `_reservoir-manifest`) carrying synapse frontmatter; `axon/programs/` holds **29 legacy programs with zero synapse blocks** and zero formal out-edges. The live graph is the workspace set; the legacy set is a disconnected shadow component.

2. **The encoded edge layer is sparse.** Only **48/173 (≈28%)** workspace programs declare a `next-suggests:` block. Program→program edges number ~130–133. **37–38% of programs are fully isolated** (no in- or out-edge) under `next-suggests` alone.

3. **It is cyclic, and nothing checks for cycles.** The `next-suggests` graph contains multi-node SCCs (`workflow-*`, `hr-team-*`) and **2 self-loop bugs** (`quickstart → quickstart`, `workspace-backup → workspace-backup`). `check_synapse_graph()` validates **only dangling edges** — no cycle, reachability, orphan, or connectivity check.

4. **`next-suggests` is not the transition set.** It is a UX "what to suggest next" hint. The real state transitions are `EXEC(...)` body calls in router programs (`code-dev-flow`, `code-dev-lifecycle`, `code-dev-journal`, `code-dev-knowledge`). The two relations disagree by ~69 edges; adding body edges connects ~15 nodes that `next-suggests` orphans.

5. **Edges are tri-partite.** `next-suggests` targets mix **programs, one tool** (`reservoir-pvt`), and **modes** (`chat`, `plan`, `programs`) in one list — the validator whitelists 9 mode tokens at `tools/dag_consistency.py:37`. A flat "program-per-node" graph cannot represent these without phantom nodes.

**Deliberator ruling on naming:** per Seat 4 and Seat 3's cycle finding, the deliverable below is labeled a **typed, multi-relation, cyclic dispatch graph**, presented as a DAG only over its acyclic `transition` backbone (the phase ladder + body-call tree). The charge asked for a "DAG"; we deliver the closest honest object and flag every place it is not acyclic.

**Verified-live facts** (this session): workspace `.md` = 174; `axon/programs` `.md` = 29; `REGISTRY.json count` = 173; `next-suggests`-bearing files = 48; `MODES = {chat,build,run,memory,system,plan,programs,dev,menu}` at `dag_consistency.py:37`; `DEFAULT_PHASES = study→plan→pr→log→audit` at `phase_model.py:31`; self-loops present at `quickstart.md:12` and `workspace-backup.md:12`; `reservoir-pvt` is a tool (`tools/REGISTRY.json:228`); `check_synapse_graph` skips trailing-`-` targets and checks only `DANGLING_SYNAPSE_EDGE`; dispatch-index = 172 entries.

---

## 2. Detailed Findings (file-cited)

### 2.1 Node population — the vertex set

| Location | Files | Synapse frontmatter | In REGISTRY.json |
|---|---|---|---|
| `workspace/programs/*.md` | 174 (`.md`); 173 named + `_reservoir-manifest` dropped from registry | Yes (172/173 carry `role`) | Yes — `count: 173` |
| `axon/programs/*.md` | 29 (legacy: `mode-*`, `plan-*`, `*-chat`, `dev-*`, `identity`, `register-preference`) | **No** (0/29) | **No** |

- Canonical node list = **173 workspace programs** keyed by `workspace/programs/REGISTRY.json` (`schema_version:1`). Per-node record: `{name, file, status, area, description, tools, last_modified}` — **no edge/phase/role field**; those live only in file frontmatter.
- `_`-prefixed files (`_code-dev-schema-v4.md`, `_reservoir-manifest.md`) carry no synapse block and are skipped by the validator (`dag_consistency.py:131`). Registry/disk drift: 173 vs 174 (Seat 4 §1).
- **Per-node attributes available** (from `# synapse:`): `role` (mutator 127 · reader 40 · gate 3 · composer 2), `domain`/`family` (code-dev 88 · meta 26 · workflow 11 · system 10 · library-dev 9 · long tail), `invocation_source`, `status` (ACTIVE 167 · DOC 6), and a per-node lifecycle tag (`SPAWNED→RUNNING 87 · read-only 35 · …`) which is the **node's internal mini state-machine**, distinct from the inter-node graph (Seat 1).

### 2.2 Node classes (Challenger ruling, adopted)

The adjacency table must distinguish three node types or it will imply nonexistent program nodes:
- **program** (173) — the canonical vertices.
- **mode** (9) — `{chat, build, run, memory, system, plan, programs, dev, menu}`, whitelisted at `dag_consistency.py:37`. Appear as `next-suggests` targets and as kernel shortcut targets.
- **tool** — e.g. `reservoir-pvt` (`tools/REGISTRY.json:228`, `tools/reservoir_pvt.py`), a valid program→tool edge target.

### 2.3 The edge layers (typed)

Four edge relations exist; they are **not interchangeable**:

| Relation | Source | Count (approx) | Meaning |
|---|---|---|---|
| `suggests` | `# next-suggests:` headers | 48 sources / ~130–133 program edges | UX "offer next" hint — what `synapse_suggest`/`anticipate` rank |
| `transition` (body) | `EXEC(workspace/programs/X.md)` / `run <prog>` in CASE bodies | ~159 body edges (~69 absent from `suggests`) | The real control-flow dispatch — the actual state machine |
| `phase-dep` | `# phase:` headers bound to `phase_model.DEFAULT_PHASES` | study→plan→pr→log→audit | Linear, DONE-gated backbone; deps, not suggestions |
| `guarded` | `next-conditional:` blocks | 5 corpus contracts | `{if, suggest, confidence, reason}`, runtime-evaluated, weight 0.15 |
| `mode-shortcut` (kernel) | `[1]`–`[7]`/`[D]` in `axon/COMMANDS.md:30-40` | 9 | `menu ↔ mode-N`, not header-declared |

- **Parser:** `tools/dag_consistency.py:34` regex `^#?\s*next-suggests:\s*\[([^\]]*)\]`; `_NEXT_COND = next-conditional:|synapses:`.
- **Consumer/ranker:** `tools/synapse_suggest.py:117 next_conditional_score()` (weight `next_cond: 0.15`, line 45); wrapped per-turn by `tools/anticipate.py`.
- **Phase SoT:** `tools/phase_model.py:31 DEFAULT_PHASES`; bindings confirmed: `code-dev-study (study)`, `code-dev-plan (plan)`, `code-dev-pr-create (pr)`, `code-dev-safety-audit (audit)`. The phase backbone and declared `suggests` edges are **mutually consistent** where both exist (e.g. `code-dev-plan → code-dev-pr-create`) — a genuine strength.
- **Critical anti-pattern:** the `→` glyph in program bodies is the kernel's output/flow operator (e.g. `mode-plan.md`), **NOT** a program-to-program edge. Scraping `→` produces a garbage graph (Seat 2).

### 2.4 Entry points (DAG roots)

Two non-identical definitions; the report carries both:

- **Kernel boot root:** `menu` — `axon/BOOT.md:228` / `KERNEL-SLIM.md:658 IF W:resumed ≡ ∅ → EXEC(workspace/programs/menu.md)`; always-rendered per `KERNEL-SLIM.md:72`. `menu` is the **hub AND the dominant sink** (12+ programs declare `next-suggests:[menu]`) but has **no `next-suggests:` of its own** and does no `EXEC()` dispatch — it routes via mode shortcuts in `COMMANDS.md:30-40`.
- **Identity gate:** `identity` (`axon/programs/identity.md`), fired pre-everything (`COMMANDS.md:14`, `KERNEL-SLIM.md:52`).
- **Free-text routers:** `mode-detect` (no active mode) / `mode-router` (active mode), `KERNEL-SLIM.md:735`. `mode-router.md:12` has the widest fan-out: `[chat-input, find-program, health-check, chat, output-layer, plan, show-memory, stats, status]` — programs and modes intermixed.
- **Declared user-invocable** (`invocation_source` contains `user`): **21 programs**, incl. `goal-define, goal-set, goal-audit, workflow-*, reservoir-review, crucible, config, loop-designer, autonomy-contract, rag-maturity-audit, retrieval-eval, retrieval-reflect`. These are *intended* roots but most have **no inbound edge and are absent from `menu.md` prose**.
- **TF-IDF dispatcher** (`tools/dispatch.py`, `workspace/memory/longterm/dispatch-index.json`, **172 entries** verified): the real free-text entry layer — a content-similarity lookup, **not an edge** in any program graph. It also carries 2 phantom `*-ALIAS` nodes and omits 2 real programs (`code-dev-preflight`, `code-dev-reviewer-track`) — the entry layer's node set is itself wrong (Seat 4 §6).

### 2.5 Reachability — the encoded graph is mostly disconnected

- **~130 `next-suggests` program edges** cover only **44 of 172** programs as edge-sources.
- **64–66 of 172 (≈37–38%) are fully isolated** — zero in- and out-edge.
- The graph fragments into **~73 weakly-connected components**: one giant component of **~87 nodes** (the `code-dev*` family rooted at `code-dev.md:18`, which fans out to ~50 `code-dev-*` children), a **9-node library-dev** cluster, a **4-node hr-team** cluster, two 2-node pairs (`migrate-workspace↔my-axon-init`, `axon-audit↔axon-graph`), and **~68 singleton orphans**.
- **BFS from kernel roots reaches only ~14 nodes** via encoded edges; the other ~160 are reached **only by the kernel's free-text/sub-command parser**, invisible to the edge graph.
- **Adding body (`EXEC`) edges connects ~15 of the orphans** — proving a large share are *under-annotated*, not genuinely unreachable (Seat 3 + Seat 4 §4).

### 2.6 Cycles and self-loops

- **2 self-loop bugs** (verified): `quickstart → quickstart` (`quickstart.md:12`), `workspace-backup → workspace-backup` (`workspace-backup.md:12`) — a program declaring itself its own next step.
- **2 multi-node SCCs** (legitimate loops): `workflow-edit ↔ workflow-validate ↔ workflow-simulate ↔ workflow-run ↔ workflow-list` (5-node) and `hr-team ↔ hr-team-selector ↔ hr-team-convener ↔ hr-team-deliberator` (4-node).
- **Contract conflict:** `dag_consistency.py:11` promises "no cycle" (via `tools/dag.py:detect_cycle()` over `DAG.json` files), but `check_synapse_graph()` has **zero cycle logic** — confirmed live: it only emits `DANGLING_SYNAPSE_EDGE`. The synapse graph the programs actually use is cyclic and uncheck­ed.

### 2.7 Dangling edges — clean under the official model

Earlier naive scans flagged 6–8 dangling targets; under the validator's own rules they resolve:
- `code-dev-` (`code-dev-whatif.md:18`) and `code-dev-phase-` (`code-dev.md:18` fan-out) — **trailing-`-` placeholders, explicitly skipped** by `check_synapse_graph` (verified: `if tgt.endswith("-") … continue`). They are **edge-list hygiene defects** (prefix-glob leakage), not validator errors.
- `chat`, `plan`, `programs` (from `mode-router`, `glossary`) — kernel **modes**, whitelisted (`dag_consistency.py:37`).
- `reservoir-pvt` (`reservoir-review.md:16`) — a registered **tool** (`tools/REGISTRY.json:228`).
- `mode-router → chat/plan` legacy targets live in the *other* `axon/programs/` population (cross-population edges).

Net: **0 truly dangling edges under the official model** — but dangling-edge detection is the *only* structural property the validator enforces.

### 2.8 Naming hierarchy — the dominant invisible signal

**75 implied parent→child pairs** are encoded only in naming (`code-dev → code-dev-flow → code-dev-flow-…`; 87 `code-dev-*` programs form a sub-program tree). A flat program-per-node graph that ignores this loses the largest structural signal in the repo (Seat 1 §2, Seat 4 §6). The flat `family:[code-dev]` tag hides a real sub-phase pipeline visible in the chains: `plan → pr-create → pr-ready → safety-preflight → review-{scope,self,tests} → finalize → state-handoff/safety-audit`.

### 2.9 No persisted graph

`find` confirms **no materialized program `DAG.json`** anywhere (`dag_files: 0` from a live validator run). The only graph JSONs are per-*project* code-knowledge study graphs (`graphify-out/graph.json`), consumed by `_GRAPH_CONSUMERS` in `synapse_suggest.py:276` — **not** the program graph. The program transition graph is recomputed every turn by `anticipate.py → synapse_suggest.rank()`. The "single source of structural truth" / "infinitely nestable DAG.json" machinery (`dag_consistency.py:40-50`) is **entirely unused**.

---

## 3. The Deliverable — Node List + Edge Table

> Scope note: a complete 173-row node table and ~290-edge adjacency dump should be **generated**, not hand-transcribed — see Recommendation R1. Below is the structural skeleton (entry points, hubs, components, defects) that the generated artifact must conform to, with representative edges grounding each relation type.

### 3.1 Node list (summary by class & component)

| Class / Component | Count | Representative nodes |
|---|---|---|
| **Entry roots — kernel** | 3 | `menu` (hub+sink), `identity`, `mode-router`/`mode-detect` |
| **Entry roots — user-invocable** | 21 | `goal-define, goal-set, goal-audit, crucible, config, loop-designer, autonomy-contract, workflow-{new,edit,run,validate,simulate,list,explain}, reservoir-review, rag-maturity-audit, retrieval-eval, retrieval-reflect, …` |
| **Giant component (code-dev*)** | ~87 | rooted at `code-dev`; `code-dev-flow`, `code-dev-lifecycle` (routers), `code-dev-plan`, `code-dev-pr-*`, `code-dev-review-*`, `code-dev-safety-*`, `code-dev-state-*`, `code-dev-journal-*`, `code-dev-knowledge-*` |
| **library-dev cluster** | 9 | `library-dev*` |
| **hr-team cluster (SCC)** | 4 | `hr-team, hr-team-selector, hr-team-convener, hr-team-deliberator` |
| **workflow cluster (SCC)** | 5 | `workflow-{edit,validate,simulate,run,list}` |
| **2-node pairs** | 4 | `migrate-workspace↔my-axon-init`, `axon-audit↔axon-graph` |
| **Singleton orphans (next-suggests)** | ~64–68 | see §3.4 |
| **mode nodes** | 9 | `chat,build,run,memory,system,plan,programs,dev,menu` |
| **tool nodes (edge targets)** | 1+ | `reservoir-pvt` |
| **Legacy shadow component** | 29 | `axon/programs/*` — synapse-less, formally edgeless |
| **DOC nodes (non-executable)** | 6 | `status:DOC`, e.g. `PROGRAMS-SLIM` |

### 3.2 Edge table — representative rows (typed)

| Source | Target | Relation | Evidence |
|---|---|---|---|
| `code-dev` | `code-dev-{plan,pr-create,review,merge,…}` (~50) | suggests | `code-dev.md:18` |
| `code-dev-plan` | `code-dev-pr-create` | suggests + phase-dep | `code-dev-plan.md:24`; `phase_model.py:31` |
| `code-dev-review` | `code-dev-review-{diff,scope,self,tests}` | suggests | `code-dev-review.md` |
| `code-dev-finalize` | `code-dev-state-handoff, code-dev-safety-audit` | suggests | `code-dev-finalize.md` |
| `code-dev-flow` | `code-dev-{cascade,changelog,finalize,merge,plan,test-map}` | transition (body) | `code-dev-flow.md` EXEC — **absent from suggests** |
| `code-dev-journal` | `code-dev-journal-{decision,event,log,search}` | transition (body) | `code-dev-journal.md` EXEC |
| `code-dev-knowledge` | `code-dev-{explain,impact,shadow,study,reviewer-track}` | transition (body) | `code-dev-knowledge.md` EXEC |
| `workflow-new` | `workflow-validate` | suggests | `workflow-new.md` |
| `workflow-edit` | `workflow-validate` | suggests (SCC) | `workflow-edit.md:13` |
| `hr-team` | `hr-team-selector` | suggests (SCC) | `hr-team.md:14` |
| `goal-define` | `code-dev-plan, loop-designer` | suggests | `goal-define.md` (prose adds `code-dev`) |
| `reservoir-review` | `reservoir-pvt` | suggests → **tool** | `reservoir-review.md:16`; `tools/REGISTRY.json:228` |
| `mode-router` | `chat`, `plan`, `programs` | suggests → **mode** | `mode-router.md:12`; `dag_consistency.py:37` |
| `menu` | `mode-{1..7,D}` | mode-shortcut (kernel) | `COMMANDS.md:30-40` |
| 12+ terminals | `menu` | suggests → **mode/hub-sink** | e.g. `code-dev-flow`, `code-dev-state`, `code-dev-journal`, `code-dev-meta` |
| `quickstart` | `quickstart` | suggests (**SELF-LOOP BUG**) | `quickstart.md:12` |
| `workspace-backup` | `workspace-backup` | suggests (**SELF-LOOP BUG**) | `workspace-backup.md:12` |
| `code-dev-whatif` | `code-dev-` | suggests (**placeholder defect**) | `code-dev-whatif.md:18` |
| `code-dev` | `code-dev-phase-` | suggests (**placeholder defect**) | `code-dev.md:18` |

### 3.3 Entry points (consolidated)

- **Always-on root:** `menu` (boot; hub + dominant sink).
- **Pre-gate:** `identity`.
- **Routers:** `mode-router` / `mode-detect` (widest fan-out).
- **User-invocable (21):** the `invocation_source:[user,…]` set above — intended roots, mostly edgeless and menu-absent.
- **Free-text dispatch:** TF-IDF over `dispatch-index.json` (172 entries) — entry layer, not a graph edge.

### 3.4 Disconnected / unreachable

- **Separate component (29):** all `axon/programs/*` legacy OS programs — no synapse, no formal out-edge; reachable only via kernel mode-routing + prose `"Next:"` lines (only 8 carry even prose, e.g. `plan-done.md:37`, `chat-folder.md:22`, `register-preference.md:53`).
- **True orphans (~43):** no edge AND not in menu prose — many are *live* functionality reached only as prose-parsed sub-commands: `goal-set, goal-audit, crucible, reservoir-review, register-tool, run-tests, translate, versions, mode-suggest, memory-compact, iterate-or-stop, turn-log, retrieval-reflect, autonomy-{contract,reanchor}, axon-reanchor, shadow-retroactive-bulk, audit-to-study, axon-compare`, and the `code-dev-meta-*`, `code-dev-pr-{list,export,sync,drift,suggest-reviewer}`, `code-dev-phase-{new,start}`, `code-dev-review-{correctness,coverage}`, `code-dev-rules-audit`, `code-dev-safety-audit-structure`, `code-dev-study-area` sets.
- **Isolated-but-menu-surfaced (~23):** `config, explain, glossary, handoff, resume, undo, simulate, discover, faq, gain, self-care, harness-builder, orchestrator, auto-actions, auto-improve, axon-docs-gen, authoring-guide, list-tools, meta, prompt-log-consent, rag-maturity-audit, retrieval-eval, session-summary` — reachable by a user, but the graph cannot model "what comes after."
- **Non-executable (6):** `status:DOC` programs.

---

## 4. Prioritized Recommendations

**R1 — Generate, don't transcribe (do this first).** Materialize the graph by invoking the existing parser (`tools/dag_consistency.py` / `synapse_edges()`) plus a body-`EXEC` extractor — read-only — and reconcile against `workspace/programs/deps.md` (AXON's own dependency self-model). Persist the first snapshot as the council's deliverable. This avoids the hand-transcription errors every seat warned about and produces the missing `DAG.json` the infrastructure already expects. *(All seats.)*

**R2 — Emit a typed, multi-relation graph; do not call it a DAG.** Four labeled edge classes: `transition` (body `EXEC`/`run`, ~159 — the real state machine), `suggests` (`next-suggests`, ~133 — UX hint), `phase-dep` (`phase_model` ladder), `mode-shortcut` (kernel `COMMANDS.md:30-40`). Three node classes: program / mode / tool. Never silently merge them the way `check_synapse_graph` does. *(Seats 2 & 4; adopted by Deliberator.)*

**R3 — Fix the 2 self-loop bugs now.** `quickstart → quickstart` and `workspace-backup → workspace-backup` are unambiguous authoring errors. Also strip the `code-dev-` / `code-dev-phase-` placeholder leakage from `code-dev.md:18` and `code-dev-whatif.md:18`. Low effort, high signal. *(Seats 1, 2, 3, 4.)*

**R4 — Add reachability + orphan + cycle checks to `tools/dag_consistency.py`.** It already builds `synapse_edges()`. Add: BFS from declared roots {`menu`} ∪ {`invocation_source:user`}; report in-degree-0 non-roots; report unreachable nodes; run `dag.py:detect_cycle()` over synapse edges. This closes the gap between "0 errors" and "≈38% isolated." *(Seat 3 primary; Seats 1, 4.)*

**R5 — Encode parent→subcommand edges (close the prose-reachable gap).** Promote the ~43 prose-dispatched relations (`code-dev pr list`, `goal set`, `code-dev phase new|start`) to `next-suggests` or a `child-dag`/`parent-of` relation so the graph matches the kernel string-matcher's real reachability. This also captures the 75-pair naming hierarchy. *(Seats 1, 3, 4.)*

**R6 — Resolve the cycle-contract conflict explicitly.** Decide: either exempt `next-suggests` from the no-cycle rule (the `workflow-*` and `hr-team-*` loops are legitimate), or refactor them into a typed loop construct. Stop letting the contract and the data disagree silently. *(Seats 3 & 4.)*

**R7 — Decide the fate of the two shadow layers.** (a) The 29 `axon/programs/` legacy programs: migrate to synapse frontmatter or formally declare out-of-graph — do **not** silently merge. (b) The dead `DAG.json` layer (`dag_files:0`): populate it (per R1) or stop calling it the "single source of structural truth." Fix the registry/disk drift (173 vs 174) and the dispatch-index defects (2 alias phantoms, 2 omissions). *(Seats 1, 3, 4.)*

---

## 5. Open Questions / Dissent

**D1 — Which relation IS the state machine? (Seat 2 vs Seat 4 — unresolved).**
Seat 2 holds `next-suggests` as *the authoritative edge table* (it is the only relation AXON's tooling parses, validates, and ranks). Seat 4 holds that `next-suggests` is merely a UX hint and the **body `EXEC` call-graph** is the true transition set, disagreeing by ~69 edges. *Deliberator position:* both are right about different layers — `transition` (body) is the runtime state machine; `suggests` is the recommendation overlay. R2 keeps both, typed. The dissent is preserved because **which layer the completeness gate should enforce** is a policy choice, not a fact.

**D2 — Are the dangling targets bugs or clean? (naive scans vs Seat 3 — resolved toward Seat 3, with caveat).**
Seats 1 and 2 reported 6–8 dangling edges as defects. Seat 3 showed all resolve under the validator's own rules (modes, tool, trailing-`-` skips) — verified live: 0 `DANGLING_SYNAPSE_EDGE`. *Caveat retained:* the trailing-`-` placeholders are still **edge-list hygiene defects** (prefix-glob leakage) even though the validator deliberately ignores them. Both framings are true at different altitudes.

**D3 — Are `workflow-*`/`hr-team-*` cycles features or violations? (Seat 3 — internal tension).**
Seat 3 calls them legitimate pipeline loops *and* flags that the contract forbids cycles. Unresolved by design: needs the R6 policy decision. The 2 self-loops, by contrast, are agreed bugs by all four seats.

**D4 — What counts as an "entry point"? (Seat 3 vs Seat 4 — definitional).**
21 `invocation_source:user` programs vs 21 in-degree-0 roots vs the TF-IDF dispatcher — three overlapping-but-distinct sets. No seat claims one canonical answer. The report carries all three; the gate must pick a definition before it can assert "every entry point is reachable."

**D5 — Legacy `axon/programs/` set: in-graph, out-of-graph, or second component? (Seat 1 flagged; unresolved).**
Seat 1 explicitly refused to decide and forbade silent merging. Seats 2 and 3 treat it as a separate component. Remains a synthesizer/owner decision (R7a).

---

## 6. Files Cited (consolidated)

**Schema / index:** `workspace/programs/REGISTRY.json`, `workspace/programs/authoring-guide.md`, `axon/programs/PROGRAM-TEMPLATE.md`, `workspace/memory/longterm/dispatch-index.json`, `tools/REGISTRY.json`.
**Tooling:** `tools/dag_consistency.py` (`:34` parser, `:37` MODES, `:122` synapse_edges, `:141-157` check_synapse_graph, `:40-50` DAG.json machinery), `tools/dag.py` (`detect_cycle`, `verify`), `tools/synapse_suggest.py` (`:45,:117,:276,:538-553`), `tools/anticipate.py`, `tools/phase_model.py` (`:31`), `tools/dispatch.py`, `workspace/programs/deps.md`, `workspace/programs/axon-graph.md`.
**Kernel / boot:** `axon/KERNEL-SLIM.md` (`:52,:72,:658,:735`), `axon/BOOT.md` (`:228`), `axon/COMMANDS.md` (`:14,:30-40`).
**Programs (hubs/roots/defects):** `workspace/programs/menu.md`, `code-dev.md` (`:18`), `code-dev-flow.md`, `code-dev-lifecycle.md`, `code-dev-journal.md`, `code-dev-knowledge.md`, `code-dev-plan.md`, `code-dev-review.md`, `code-dev-finalize.md`, `code-dev-whatif.md` (`:18`), `mode-router.md` (`:12,:97-101`), `quickstart.md` (`:12`), `workspace-backup.md` (`:12`), `reservoir-review.md` (`:12-16`), `workflow-{edit,run,list,validate,simulate}.md` (`:13`), `hr-team*.md` (`:13-14`), `goal-define.md`, `axon/programs/*` (29 legacy; `plan-done.md:37`, `chat-folder.md:22`, `register-preference.md:53`).
**Tests / corpus:** `tests/synapse/corpus/*.contract.json` (5 with `next-conditional`; `code-dev-actions.contract.json` orphan-stub).
