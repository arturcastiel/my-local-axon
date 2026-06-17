# AXON — Architecture Overview

> Foundation document for the `axon-new-doc` documentation project.
> Audience: a newcomer to the codebase, plus the doc team who will build on this map.
> Status: study-phase deliverable (Phase 1). Counts verified against the live tree on 2026-06-17.

---

## 1. What AXON is

AXON is a **Markdown-defined operating system for AI agents** (v1.1.6). The host harness (Claude Code, GitHub Copilot, or a generic shell) and the LLM it runs on are treated as a disposable **execution layer**; AXON itself is the primary identity, and *all* of its behaviour comes from a set of kernel files rather than from the model. The kernel (`axon/KERNEL-SLIM.md`) declares an identity, 13 immutable Core Rules, and a stack of compliance gates as operations in a compressed cognition language (**AXON-LANG**). Those declarations are made mechanical by ~183 standalone Python **tools** (registered in one `tools/REGISTRY.json`), orchestrated by ~170 Markdown **programs** ("neurons") in `workspace/programs/`, all isolated across a **4-layer** filesystem model (OS core / shared config / private user data / add-ons). Net: AXON behaves like a stateful OS — booting, running programs, scheduling work, protecting scoped memory, surfacing state, and failing loudly — on top of a stateless LLM turn loop.

---

## 2. Architecture map

AXON is a layered stack. The **kernel** is the constitution, **programs** are userland, **tools** are the deterministic muscle, and a **quality/enforcement spine** plus a **state/memory substrate** cut across everything.

```
                            ┌─────────────────────────────────────────────┐
   USER / FREE TEXT  ─────▶ │  COMMANDS.md routing                          │
                            │  (identity gate → mode shortcut →             │
                            │   smart-dispatch → EXEC program)              │
                            └───────────────────┬─────────────────────────┘
                                                │
   ┌────────────────────────────────────────────▼──────────────────────────────────┐
   │  PROGRAMS layer  (workspace/programs/*.md — ~170 "neurons")                      │
   │  menu.md = OS shell · code-dev.* family · workflow-* · goal-* · meta/system      │
   │  each neuron: # PROGRAM / # synapse: contract / op-body in AXON-LANG / DONE      │
   └───────┬───────────────────────────────────────────────────┬─────────────────────┘
           │ TOOL(name,args)                                     │ compose
           ▼                                                     ▼
   ┌──────────────────────────┐                  ┌──────────────────────────────────────┐
   │  TOOLS layer             │                  │  WORKFLOW + ORCHESTRATION layer        │
   │  ~183 Python scripts     │◀────ranks────────│  workflow-run.md / workflow_run.py     │
   │  REGISTRY.json (truth)   │   candidates     │  orchestrator.md / synapse_suggest.py  │
   │  axon.py + run.py        │                  │  YAML workflows (fixed/adaptive/hybrid)│
   └──────────┬───────────────┘                  └────────────────────────────────────────┘
              │ backs                                            │ gated by
              ▼                                                  ▼
   ┌──────────────────────────────────────────────────────────────────────────────────┐
   │  KERNEL / OS CORE  (axon/axon/)                                                     │
   │  KERNEL-SLIM.md (identity · 13 Core Rules · compliance gates · LOAD-ON-DEMAND)      │
   │  BOOT.md · COMMANDS.md · OUTPUT-LAYER.md · core/LANG.md (AXON-LANG) · TRANSLATE.md  │
   │  memory/ · scheduler/ · processes/ · compiler/ · programs/ (OS built-ins)          │
   └──────────────────────────────────────────────────────────────────────────────────┘

   ╔══════════════════════════════════ CROSS-CUTTING ══════════════════════════════════╗
   ║ QUALITY / ENFORCEMENT spine: crucible.py (gate) · verify.py + tools/rules/ (R_*)    ║
   ║   · enforce.py (write/source gate) · liveness · keystone · AEGIS autonomy gating    ║
   ║ STATE / MEMORY / LAYERS: W:/L:/E: + local/ scopes · boot.py · session(_save).py     ║
   ║   · harness adapters (workspace/harness/) · kv_store · 4-layer filesystem model     ║
   ╚════════════════════════════════════════════════════════════════════════════════════╝
```

**Flow of a turn (canonical):** boot bootstraps identity + paths and `EXEC`s `menu.md` → user input is routed by `COMMANDS.md` (identity gate first, then mode shortcut or smart-dispatch) → a program is `EXEC`'d → it `SPAWN`s a process → reasoning happens in AXON-LANG → state is read/written in W/L/E memory → output is rendered through `TRANSLATE.md` + `OUTPUT-LAYER.md` → every step passes the compliance gates, which only **bite mechanically** when the host harness runs `verify.py`/`enforce.py` hooks each turn (otherwise they run by agent discipline).

**The single most-confusing structural fact** for newcomers: `axon/axon/tools/*.md` are *human-readable cards only*. The actual Python scripts and the source-of-truth `REGISTRY.json` live **one level up** at `axon/tools/`. Document this trap early.

---

## 3. Subsystems

Seven subsystems, each with its purpose, the files a newcomer must read, and the concepts a doc must explain.

### 3.1 OS Core / Kernel (`axon/axon/`)

**Purpose.** The conceptual heart: the always-loaded kernel plus its load-on-demand subsystem specs (boot, commands, output, language, memory, scheduler, processes, programs, compiler, tools). The kernel declares rules and gates as AXON-LANG ops; those ops are backed by Python tools one directory up.

**Key files.**
- `axon/KERNEL-SLIM.md` — THE kernel (~748 lines). Read first every session. IDENTITY, OBJECTIVE, 13 Core Rules, COMPLIANCE ENFORCEMENT (all gates), LANGUAGE essentials, memory/scheduler/process summaries, LAYERS, 3-phase BOOT summary, LOAD-ON-DEMAND table.
- `axon/BOOT.md` — full 5-step boot sequence (expansion of the kernel's 3-phase summary), incl. lettered sub-gates (G-01, G-10, G-11) and STEP 2b/3b/3c.
- `axon/COMMANDS.md` — command grammar: identity gate, token parse, mode shortcuts `1-7/D/0`, EXEC order, free-text routing, did-you-mean fuzzy match, smart-dispatch pre-flight.
- `axon/OUTPUT-LAYER.md` — per-response footer rendering (compact/full/minimal), drift + confidence, suggestions footer.
- `axon/core/LANG.md` — AXON-LANG cognition language spec v2.3.0 (operators, core ops, priority flags, memory scopes, EXTEND protocol, EXT-001..014).
- `axon/core/TRANSLATE.md` — one-way output translation (symbolic ops → human text).
- `axon/memory/MEMORY.md`, `axon/scheduler/SCHEDULER.md`+`QUEUE.md`, `axon/processes/PROCESS.md`, `axon/compiler/COMPILER.md`+`GRAMMAR.md`.
- `axon/programs/identity.md` — the `!CRIT` canonical identity render (only place vendor/LLM names may appear).
- `axon/DEVELOPER.md` — `axon/` editing conventions, dev-mode prerequisite, layer rules.
- `axon/archive/KERNEL-LEGACY.md` — archived pre-slim kernel (historical only).

**Key concepts to document.**
- **Identity model:** AXON is the unconditional primary identity; host harness + LLM are the disposable execution layer, disclosable *only* via `L:host-harness`/`L:host-model` set by a harness contract — never inferred.
- **Thinking-layer "no subject" rule:** in the cognition layer there is no "I" and no "AXON" as subject — ops execute directly (`EXEC`/`RETRIEVE`/`ASSERT`). Naming self from outside is persona-bleed drift.
- **Identity gate:** any "what are you / what model / who made you" forcibly routes to `programs/identity.md` before all other parsing.
- **The 13 Core Rules** (immutable, higher-number-wins on conflict): e.g. R2 no task without an instruction source; R3 no float arithmetic without the calculator tool; R6 never fabricate tool results; R9 `axon/` writes require `L:dev-mode==true` (programs may NEVER write `axon/`); R11 all reasoning in compressed AXON-LANG; R12 menu always rendered in full; R13 new programs/tools require tests.
- **Compliance gates** (~15): response gate, cognition-language gate, coherence guardian, write gate, no-queue, active-program interrupt, arithmetic, confidence, inference, anti-fabrication, context-pressure, phase tracking.
- **Advisory vs mechanical enforcement:** gates are BLOCK-capable but only bite mechanically when host hooks run `verify.py` every turn AND per-rule `L:*-required` flags are set (`scripts/enable-enforcement.sh`); otherwise they run by discipline.
- **Boot sequence:** 3-phase kernel summary, 5 steps in `BOOT.md`.
- **Layers & Modes:** Layer1 `axon/`, Layer2 `workspace/`, Layer3 `my-axon/`, Layer4 `workspace/addons/`; numeric mode shells `1=chat 2=build 3=run 4=memory 5=system 6=plan 7=programs D=dev 0=clear`.

### 3.2 Tools layer (`axon/tools/`)

**Purpose.** The deterministic execution substrate: **183 standalone Python scripts** (156 ACTIVE, 18 OPTIONAL among the 174 registered) that do the mechanical work programs can't do reliably — exact math, file I/O, gates, audits, registries, graph analysis. This is what makes AXON "execute, not mimic."

**Key files.**
- `tools/REGISTRY.json` — single source of truth: nested `{schema_version, contract_version, description, tools:{name:{script,status,category,purpose}}}` for all 174 registered tools. Read by `axon.py`, `run.py`, `boot.py`, `health.py`, `verify.py`, `freshness`.
- `axon.py` — the dispatcher: `load_registry()` → ALIASES → `subprocess.run([python, script]+argv)` → `_write_receipt()` JSONL ledger.
- `tools/run.py` — executes mechanical `TOOL()/STORE()/LOG()` ops from compiled `.cmp.md` programs (the program-side invocation path).
- `tools/_axon_registry.py` — the one accessor for `REGISTRY.json`; `tools/_axon_paths.py` (repo-anchored paths), `tools/_axon_io.py` (atomic_write + R9 write-gate), `tools/_axon_response.py` (`{ok,data,error}` envelope), `tools/_longterm.py`, `tools/__init__.py` (script-mode contract).
- `tools/crucible.py`+`crucible.json` — the control+test gate hub.
- `tools/boot.py`, `tools/freshness.py`, `tools/dispatch.py`+`dispatch_index.py`, `tools/shadow.py`, `tools/code_graph.py`.
- `tools/rules/` — 32 `r_*.py` rule-predicate modules; `tools/hooks/` — harness-installed hooks.

**Key concepts to document.**
- **Tool = a registered standalone script**, invoked by NAME not path; ACTIVE vs OPTIONAL.
- **Script-mode contract (load-bearing):** every tool runs via `subprocess([python, tools/x.py])` so `sys.path[0]` is `tools/` and siblings import flat (`from _axon_paths import ...`), NOT `tools.x`. Documented only in `tools/__init__.py` today.
- **Two invocation paths:** `axon.py` (CLI/agent direct) vs `tools/run.py` (compiled-program op executor) — both resolve via `REGISTRY.json`.
- **Execution receipts** (JSONL ledger) back `R_TOOL_RECEIPTS` anti-fabrication.
- **Shared substrate** (`_axon_*` modules) — the DRY core; **the `{ok,data,error}` envelope is only ~6/174 adopted** (migration backlog).
- **Category taxonomy is loose** (kernel is a ~93-tool catch-all; audit/meta/kernel overlap) — needs a real map.
- **The two registries:** `tools/REGISTRY.json` (truth) vs `axon/tools/REGISTRY.md` (stale human mirror) need reconciling.

### 3.3 Programs layer (`workspace/programs/`)

**Purpose.** AXON's executable userland: ~170 Markdown "neurons", each a program written in AXON-LANG (`EXEC/STORE/RETRIEVE/IF/TOOL/ASSERT/DONE`). The catalog of everything the OS can DO, with `menu.md` as the home screen.

**Key files.**
- `workspace/programs/` (the ~170 `*.md` neurons) and `workspace/programs/REGISTRY.json` (flat tool-generated index — does NOT carry contract fields).
- `workspace/programs/menu.md` (OS shell / home screen), `code-dev.md` (largest; the code-dev dispatcher), `goal-define.md`, `workflow-new.md`, `authoring-guide.md`.
- `workspace/programs/compiled/` (`*.cmp.md` run.py-executable artifacts), `workspace/programs/help/`.
- `workspace/NEURON-CONTRACT.md` (authoritative `# synapse:` header spec v1.1), `workspace/DOMAIN-MANIFEST.md`.

**Key concepts to document.**
- **Neuron = one `*.md` file:** `# PROGRAM:` / `# desc:` / `# synapse:` contract block / optional `# budget:` / `!NORM`|`!CRIT` directive / op-body / `DONE(<name>)`.
- **Synapse-contract header** (now "neuron contract" v1.1): the field is still spelled `# synapse:`; authoring is **hybrid** — effective contract = inferred (static analysis of body) ⊕ declared (header), declared wins field-by-field.
- **Enums:** role (mutator/reader/gate/composer), status (ACTIVE/STUB/DOC + spec ALIAS/DEPRECATED/ARCHIVED), domain (closed list, code-dev dominant).
- **Filename-as-namespace:** `code-dev-<sub>.md` nesting; `_`-prefixed files are schemas.
- **Dispatch/EXEC:** parent programs route via `IF cmd ≡ "x" → EXEC(code-dev-x)`; free text goes through DISPATCH PRE-FLIGHT and resolves **compiled-first** (`compiled/<name>.cmp.md` before `<name>.md`).
- **Identity-lock convention**, **menu as OS shell** (mode-sticky routing), **DAG/shadow/goal obligations** validated by `synapse-validate` + crucible.
- **The REGISTRY.json trap:** its flat schema has `domain/family/role = null`; the real contract is in the file headers.

### 3.4 Code-Dev harness (study → plan → pr → log → audit)

**Purpose.** AXON's structured 5-phase workflow for feature/refactor/documentation work on a large codebase — and the very harness this doc project runs under (slug `axon-new-doc`).

**Key files.**
- `workspace/programs/code-dev.md` (router + SHADOW GATE + phase-discipline routes).
- `tools/phase_model.py` (the `_phases.json` engine), `tools/shadow.py` (shadow index), `tools/study_modes.py` (study catalog), `tools/skip_guard.py` (skip policy).
- `workspace/programs/_code-dev-schema-v4.md` (v4 file conventions), `code-dev-new.md` (v4 scaffolder), `code-dev-study.md`, `code-dev-plan.md`, `code-dev-pr-create.md`, `code-dev-journal-log.md`, `code-dev-safety-audit.md`.
- `my-axon/dev-projects/axon-new-doc/` — the live project (schema v4, `_phases.json` seeded, `phases/study/` scaffolded).

**Key concepts to document.**
- **The 5-phase ladder** (study→plan→pr→log→audit), each emitting a durable artifact.
- **`_phases.json` manifest:** `status ∈ pending|active|done|stale`; **DONE is explicit, not file-existence**; in-order gate; back/skip backward cascade-invalidation.
- **Schema name collision:** `_phases.json` internal `"schema":"v1"` vs project `_meta.md` `schema-version: v4` — a genuine trap.
- **Two shadow concepts:** file-shadow (`.findings.md`, git-hash-keyed cache) vs PR-shadow coverage (G2/G4/G5 audit gate) — easily conflated.
- **Skip discipline** (no skip-by-inference; `FORCE-SKIP` token), **study modes matrix** (budget tiers vs intent modes), **two coexisting layouts** (v4 nested `phases/` vs legacy flat root).

### 3.5 Workflow + Orchestration layer

**Purpose.** Composes individual programs into multi-step flows and decides what fires next. Two coupled halves: a declarative **YAML workflow engine** (`workflow-run`) and a per-turn **orchestrator** ranking loop (`orchestrator.md` + `synapse_suggest.py`).

**Key files.**
- `workspace/programs/workflow-run.md` (interpreted) + `tools/workflow_run.py` (the enforcement teeth, registered as `workflow-runner`).
- `workspace/programs/orchestrator.md` (OBSERVE→CANDIDATES→DECIDE→RENDER→ACT) + `tools/synapse_suggest.py` (the ranker).
- `workspace/WORKFLOW-FILE.md` (schema v1.1) + `workspace/schemas/workflow-file.schema.json`.
- `tools/dag.py`, `tools/workflow_dag.py`, `tools/plan_dag.py`, `tools/dag_consistency.py`, `tools/synapse_infer.py`, `tools/synapse_validate.py`, `tools/synapse_scaffold.py`.
- `workspace/workflows/*.yml` + `workspace/domains/<d>/workflows/*.yml`; `WORKFLOW.md` (root user guide).

**Key concepts to document.**
- **Execution-mode:** fixed (declared DAG) | adaptive (ranked top-1 each step) | hybrid (per-synapse override) (+ exploratory, scheduled).
- **on-complete predicates:** `if:` is the only branch key (NOT `when:` — a trap), evaluated by `tools/predicate.py`.
- **advance-guard / WorkflowJumpError** (anti-skip), **nested sub-workflows** + `SubWorkflowNotCompletedError`, **trajectory store** + **promote** (adaptive→fixed draft).
- **Ranker signal weights + `decide()` thresholds** (confidence × `L:inference-mode`), **bridge-mode** (observe-only).
- **Two distinct "DAG" concepts:** per-workflow synapse DAG inside a `.yml` vs the 5-level project `DAG.json` — never disambiguated in one place today.

### 3.6 Quality / Enforcement spine

**Purpose.** The fail-closed merge boundary: aggregates every test/lint/audit/conformance/rule check into one verdict (**crucible**), turns Core Rules into mechanical predicates (**verify** + `tools/rules/`), and gates autonomous self-merge behind a scoped grant × policy × green gate (**AEGIS**).

**Key files.**
- `tools/crucible.py` + `crucible.json` (the aggregator gate + ~30-control registry).
- `tools/verify.py` (kernel rule verifier, STATIC + RUNTIME), `tools/enforce.py` (write/source gates).
- `tools/rules/` (32 `r_*.py` predicates) + `registry.py` + `manifest.py` (anti-drift), `r_new_needs_test.py` (R13).
- `tools/liveness.py` (orphan gate), `tools/keystone.py` (meta-gate), `tools/aegis_policy.py`, `tools/autonomous_mode.py`, `tools/autonomy_breaker.py`, `tools/autonomy_cadence.py`.
- `tests/` (292 `test_*.py` files; `tests/test_rules/` 1:1 per-rule coverage), `.github/workflows/ci.yml` (the `crucible-gate` job).

**Key concepts to document.**
- **Crucible gate:** single fail-closed verdict; exit 0 iff every BLOCK control passes; errored/missing/broken-registry all count as FAILED.
- **Controls vs severities** (BLOCK fails, WARN never blocks); **kernel rule predicates** with phase (STATIC/RUNTIME/BOTH) + severity.
- **Activation flags / silent-until-flag** (many BLOCK rules inert until `L:*-required` set), **F15/F16 WARN semantics**, **change-set rules** (run over the git diff).
- **AEGIS triad:** GRANT × GATE × POLICY + AUDIT; INVIOLABLE ops never delegable; merge/test-execution need a green gate.
- **Manifest parity** (lock the 4 runner lists), **liveness orphan gate**, **keystone "no WARN graveyard"**.

### 3.7 State / Memory / Layer model

**Purpose.** The persistence + isolation spine: where data lives (4 layers / 4 scopes), what's gitignored vs shared, how working state survives restart/compaction, and how AXON adapts to the host harness.

**Key files.**
- `axon/KERNEL-SLIM.md` (canonical LAYERS + MEMORY RULES), `axon/memory/MEMORY.md`.
- `.gitignore` (axon.git boundary) + `workspace/.gitignore` (my-axon.git boundary).
- `tools/memory.py` (W/L/E file CRUD), `tools/kv_store.py` (diskcache K/V), `tools/session.py` (`_session.md` state machine + compaction recovery), `tools/session_save.py` (W: snapshot/restore), `tools/agent_memory.py` (tiered memory), `tools/boot.py` (the integrator).
- `workspace/harness/claude-code.md`/`copilot.md`/`generic.md` + `tier-manifest.json` + `tools/harness_conformance.py`.
- `workspace/WORKSPACE.md` (L2 paths) + `my-axon/MYAXON.md` (L3 paths).

**Key concepts to document.**
- **4-layer model** (L1 `axon/` write-gated, L2 `workspace/` shareable, L3 `my-axon/` private gitignored, L4 `addons/`).
- **4 memory scopes:** `W:` working (session-only) · `L:` longterm (persisted) · `E:` episodic (append-only) · `local/` (machine-specific, gitignored, **NOT** reachable via `RETRIEVE(L:)`).
- **Mandatory retrieval order:** `W: → L: → E: → QUERY(user)`.
- **Two storage backends for the same scopes:** file-per-key markdown (`memory.py`) vs diskcache (`kv_store.py`).
- **Two session-survival mechanisms:** reboot snapshot (`session_save.py`) vs compaction recovery (`session.py` PID-mismatch).
- **Harness adapter contract:** exactly one adapter runs at boot, sets `L:host-harness`/`L:host-model` + six `host-cap-*` keys; **tiering** (weak/standard/strong).
- **Git-boundary rule:** `my-axon/` is the only place autonomous git is permitted; kernel edits are the never-delegable floor.
- **ANOMALY to investigate/document:** `axon/state/loop-receipt.ledger.jsonl` is being WRITTEN under write-gated Layer-1 `axon/`, which appears to contradict Core Rule 9 / the LAYERS rule — either an intentional kernel-state exception or a boundary violation.

---

## 4. Documentation landscape

### 4.1 What already exists

- **Generated, drift-checked artifacts** (regenerate-and-compare against a source of truth):
  - `workspace/AXON-DOCS.md` (~63KB system doc, from `docgen.py`)
  - `workspace/DOC-INDEX.md` (navigable map of every authored `.md`, from `doc_index.py`)
  - `workspace/_dashboards/axon-code-map.md` (code graph, from `code_graph.py`)
  - `workspace/programs/REGISTRY.json` and `tools/REGISTRY.json` (registries)
  - `freshness.py` reconciles all of these (`refresh`) and gates on staleness (`check`).
- **Hand-authored reference set** — 15 `workspace/AXON-DOCS-*.md` pages: ARCHITECTURE, CHEATSHEET, CI, COMPILER, DEPRECATIONS, FAILURE-MODES, GOVERNANCE, PLAN, RAG-DEVELOPMENT, RAG-MATURITY, SCHEMA, SESSIONS, STUDY, TESTING, WORKFLOWS.
- **Authoritative specs** — `KERNEL-SLIM.md`, `core/LANG.md`, `NEURON-CONTRACT.md`, `WORKFLOW-FILE.md`, `DAG-SPEC.md`, `DOMAIN-MANIFEST.md`, `AXON-GLOSSARY.md`, plus the self-documenting `tools/REGISTRY.json` purpose strings and excellent docstrings in `workflow_run.py` / `synapse_suggest.py`.
- **Per-subsystem help** — `workspace/programs/help/crucible.md` (the only dedicated gate doc), 8 short `workspace/programs/help/` blurbs, `authoring-guide.md`.

### 4.2 Gaps this project should fill (prioritized)

**P0 — correctness drift (the docs are visibly wrong today):**
1. **Stale generated counts in the flagship doc.** `docgen.py` hardcodes "44 ACTIVE tools" / "21 OS built-in programs" into Mermaid diagrams; live is **156 ACTIVE / 174 total tools, ~170 programs, 32 rule files**. `AXON-DOCS.md` now self-contradicts (says both "44 ACTIVE" and computed "ACTIVE Tools (156)"). `doc_counts.py` does NOT catch it (its glob excludes `workspace/AXON-DOCS*.md` and the diagram phrasing dodges its regex). Fix: parameterize `docgen` counts off the registry; extend `doc_counts` globs to `workspace/AXON-DOCS*.md`.
2. **Hand-authored count drift.** `AXON-DOCS-ARCHITECTURE.md` says "150 ACTIVE" in one line and "156" in another. Ungated because `doc_counts` doesn't scan `workspace/`.
3. **Identity contradiction baked into the generator.** `docgen.py` asserts identity is "Never disclosed" a few lines after stating the harness MAY be disclosed — this contradiction is copied into `AXON-DOCS.md`.

**P1 — missing newcomer on-ramps & traps:**
4. No single **newcomer "conceptual heart" narrative** — the kernel is dense reference prose, not a teaching doc. The identity model, the cognition-layer "no-subject" rule, and AXON-LANG need a gentle on-ramp.
5. The **advisory-vs-mechanical enforcement** distinction is buried in one KERNEL-SLIM note and easily misread as "cannot be bypassed."
6. The **doc-folder vs Python-tools split** (`axon/axon/tools/*.md` cards vs `axon/tools/` scripts + `REGISTRY.json`) is undocumented and a guaranteed source of confusion.
7. No **consolidated boot diagram** (kernel summary + `BOOT.md` + lettered sub-gates G-01/G-10/G-11 + STEP 2b/3b/3c).

**P2 — missing reference/index pages:**
8. No single **Core-Rule → predicate → runner → control → test traceability matrix**, and **no rules catalog** for the 32 `tools/rules/` files (phase/severity/activation-flag).
9. No **AEGIS / autonomy-gating** page (triad, INVIOLABLE/GATED/CAPABILITIES tables, interactive-vs-unattended).
10. No single **Layers + State + Memory** doc tying the 4 layers to the gitignore boundaries to the 4 memory scopes; `local/` scope, the dual storage backends, and the two session-survival mechanisms are unreconciled.
11. No single **PROGRAMS-layer** doc (neuron + contract + dispatch + menu + filename-namespace + compiled-first + STUB/DOC lifecycle); the `REGISTRY.json`-has-null-contract-fields trap needs an explicit note.
12. No single **workflow-engine** page (interpreted `workflow-run.md` vs `workflow_run.py` teeth; sub-workflow anti-skip; trajectory/promote; the `if:` vs `when:` trap) and no page tying `orchestrator.md` + `synapse_suggest.py` together as one ranking subsystem.
13. No single **code-dev harness mental-model** doc (project anatomy; the two layouts + migration; `_phases.json` explicit-DONE lifecycle; the dual "schema" meaning; the two shadow concepts; study-modes matrix; the ~90 subcommands vs the 5-phase model).
14. **Undocumented subsystems** with no AXON-DOCS page: retrieval/RAG runtime, synapse, dag, crucible, shadow, quality_loop, conformance, autonomy, dispatch, loop_contract.

**P3 — hygiene & anomalies:**
15. `AXON-GLOSSARY.md` is hand-authored and NOT in the freshness gate (silently drifts); `AXON-DOCS-CI.md` cites a fixed test-count snapshot with no backstop.
16. The generated `AXON-DOCS.md` doesn't cross-link its 15 companion pages — only `DOC-INDEX.md` ties the corpus together.
17. Document (or fix) the `axon/state/loop-receipt.ledger.jsonl` write-under-Layer-1 anomaly.
18. `KERNEL-LEGACY.md` is archived but not clearly marked deprecated in newcomer paths.

---

## 5. Recommended documentation targets

The 5–8 highest-value docs to write, in build order. Each should end with a `## Guarded by` table naming a real test (per the existing `AXON-DOCS-*` co-output convention).

1. **AXON in 20 minutes — the conceptual heart** (newcomer narrative). What AXON is, the identity model, the cognition-layer "no-subject" rule, a gentle AXON-LANG primer, the 4 layers, and the kernel→programs→tools mental model. Fixes gaps 4, 6. *Highest leverage: nothing like it exists.*
2. **Boot & lifecycle of a turn.** Consolidated boot diagram (3-phase summary + 5 steps + G-01/G-10/G-11 + STEP 2b/3b/3c) and the end-to-end turn flow (route → EXEC → SPAWN → reason → memory → render → gates). Fixes gap 7.
3. **Enforcement & governance reference.** The advisory-vs-mechanical distinction; the Core-Rule → predicate → runner → control → test traceability matrix; the `tools/rules/` catalog; the crucible gate; the AEGIS/autonomy triad. Fixes gaps 5, 8, 9.
4. **Layers, State & Memory.** The 4 layers ↔ gitignore boundaries ↔ 4 memory scopes; `local/` semantics; dual storage backends; the two session-survival mechanisms; harness adapters + tiering; the `loop-receipt.ledger` anomaly. Fixes gaps 10, 17.
5. **The PROGRAMS layer & how dispatch works.** Neuron anatomy, the `# synapse:` contract (inferred ⊕ declared), filename-namespace, compiled-first dispatch, status lifecycle, menu-as-shell, and the `REGISTRY.json`-null-fields trap. Fixes gap 11.
6. **The code-dev harness, end to end.** Project anatomy, the two layouts + migration, `_phases.json` (explicit DONE, lifecycle, in-order gate, back/skip cascade), the dual "schema" trap, file-shadow vs PR-shadow, study-modes matrix, subcommand map. Fixes gap 13.
7. **The workflow & orchestration engine.** `workflow-run.md` (interpreted) vs `workflow_run.py` (teeth); execution-modes; `if:`-only edges; sub-workflow anti-skip; trajectory/promote; the ranker signal weights + `decide()` thresholds; the two "DAG" concepts disambiguated. Fixes gap 12.
8. **Drift-fix changeset (not prose).** Parameterize `docgen.py` counts off the registry; extend `doc_counts.py` globs to `workspace/AXON-DOCS*.md`; resolve the identity "never disclosed" contradiction; add `AXON-GLOSSARY.md` to the freshness/anchor gate; cross-link `AXON-DOCS.md` to its companions. Fixes gaps 1, 2, 3, 15, 16. *Do this early — it's the difference between docs that drift and docs that stay true.*
