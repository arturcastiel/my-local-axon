# AXON Council Report — Program & Workflow Naming

**Council:** Program & Workflow Naming
**Role:** Deliberator (synthesis of 4 sealed seat opinions)
**Date:** 2026-06-19
**Status:** ADVISORY ONLY — no files renamed; this report proposes a renaming + migration plan
**Scope:** `workspace/programs/*.md` (174 files; registry indexes 173), `axon/programs/*.md` (28–29 kernel programs), `workspace/programs/help/*.md` (8 cards), workflows under `workspace/workflows/`, `workspace/domains/*/workflows/`, `.claude/workflows/`, plus `REGISTRY.json` and `authoring-guide.md`.

Seat lenses synthesized:
- **Seat 1** — Consistency / Convention
- **Seat 2** — Clarity / Discoverability
- **Seat 3** — Collision / Ambiguity
- **Seat 4** — Challenger (worst-named programs)

All seat claims below were spot-verified against the live tree by the deliberator; verification notes are inline where a claim was checked.

---

## 1. Executive Summary

AXON's naming is **strong at the mechanical layer and unowned at the policy layer.** The single most important convention — filename equals the `# PROGRAM:` header — holds for 172/174 files, kebab-case is universal, and there are **zero basename collisions between kernel (`axon/programs/`) and workspace (`workspace/programs/`)** and **zero `dispatch-phrase` collisions** in the natural-language routing layer. Renames are therefore mechanically cheap (one header, one filename) and the natural-language surface is clean. The damage is concentrated in the *canonical names* and in the *absence of a governing rule.*

The root cause is unanimous across all four seats: **`authoring-guide.md` has no program-naming section.** Its only naming rule is line 164 — "Event naming convention: kebab-case, program-scoped" — which governs *events*, not program names (verified: lines 1–20 are the program header, line 164 is the sole naming mention). Names are unowned, so every drift below is the predictable consequence: split verb/noun ordering, five synonyms for "create," metaphor names (`crucible`, `gain`, `keystone`), abstract grab-bag umbrellas (`flow`/`shape`/`meta`), and a flat 174-entry directory simulating a directory tree (`code-dev-*` is 87 of 174 = 50%, nesting up to 5 dot-levels).

The highest-severity defects — agreed by 3 of 4 seats independently — are:

1. **`code-dev` / `library-dev` are overloaded across program, domain, AND workflow** with no namespace qualifier (Seats 1, 2, 3). A user saying "run code-dev" cannot be routed deterministically.
2. **The registry lies about status.** `REGISTRY.json` records only `ACTIVE` (167) and `DOC` (6) — it has **no STUB / ALIAS / DEPRECATED field at all**, despite the synapse contract defining that enum (`authoring-guide.md:225`) and despite two files carrying `-ALIAS` *inside their header* and twelve marked STUB in their bodies (Seats 1, 4 — verified: registry status values are exactly `ACTIVE`×167, `DOC`×6; no `alias_of`/`supersedes` keys exist).
3. **`workflow-run --name <name>` is broken by a naming/placement mismatch.** The resolver (`workflow-run.md:76`) looks up `workspace/workflows/{name}.yml`, but the canonical workflows live at `workspace/domains/*/workflows/{name}.canonical.yml` — so `workflow-run --name code-dev` resolves to a nonexistent path and FAILs (`workflow-run.md:77`) (Seat 3 — verified: line 76 path template + line 41 doc comment confirm the disjoint namespace).

**Recommended sequencing:** fix the registry status model FIRST (it is the enabler — once `alias_of`/`status` exist, every later rename ships as a backward-compatible alias instead of a breaking change), then land the C1/C2 workflow-namespace + resolver fix as a paired change, then the high-ROI single renames (`discover`, `stats`), then the systemic policy fix (a NAMING section in the authoring guide) that prevents regression.

---

## 2. Detailed Findings (file-cited)

Findings are grouped by severity. Each carries the seat(s) that raised it and a verification note where the deliberator confirmed it.

### CRITICAL — genuine breakage, not style

**CR-1 — `code-dev` / `library-dev` overloaded across program + domain + workflow.**
*(Seats 1-D1, 2-D1, 3-C1 — three independent seats.)*
`code-dev` is simultaneously a program (`workspace/programs/code-dev.md`, `# PROGRAM: code-dev`), a domain (`workspace/domains/code-dev/`), an 88-member prefix (`code-dev-*`), and a workflow (`workspace/domains/code-dev/workflows/code-dev.canonical.yml`, `name: code-dev`). `library-dev` is program + domain + workflow. `COMMANDS.md:122-124` dispatches free text against "known program name" with no namespace tag, so the identifier cannot disambiguate program-vs-workflow.

**CR-2 — `workflow-run --name` lookup namespace is disjoint from where workflows live.**
*(Seat 3-C2 — verified.)*
`workflow-run.md:76`: `IF path ≡ ∅ AND name ≠ ∅ → path ← "workspace/workflows/{name}.yml"`, then `ASSERT(FILE-EXISTS(path)) | FAIL(...)` (line 77). But the real canonical workflows are `code-dev.canonical.yml` / `library-dev.canonical.yml` under `workspace/domains/*/workflows/` — wrong directory AND the `.canonical` infix breaks the `<name>.yml` pattern. Only `adaptive-free-text.yml` and `multiple-code-dev.yml` (the two files actually in `workspace/workflows/`) resolve. `workflow-run --name code-dev` is therefore dead on arrival. This is a naming-induced bug, not cosmetic.

**CR-3 — The registry has no status enum for STUB / ALIAS / DEPRECATED.**
*(Seats 1-B3, 4-#1 — verified.)*
`REGISTRY.json` status values are exactly `ACTIVE` (167) and `DOC` (6); there are **zero** `alias_of` or `supersedes` keys. Yet `authoring-guide.md:225` defines `status ∈ {ACTIVE, OPTIONAL, STUB, ALIAS, DEPRECATED, ARCHIVED}`. Two files carry `-ALIAS` *inside* their `# PROGRAM:` header — `code-dev-preflight.md` → `# PROGRAM: code-dev-safety-preflight-ALIAS` and `code-dev-reviewer-track.md` → `# PROGRAM: code-dev-knowledge-reviewer-track-ALIAS` (verified) — and their registry descriptions literally say "alias stub … superseded … remove," yet the registry records them `ACTIVE`. **Naming-as-status (the `-ALIAS` suffix) is a workaround for a missing structural field, and it is invisible to every registry consumer.** These two files are also the *only* cases where filename ≠ header.

### HIGH — discoverability / ambiguity defects

**H-1 — `discover` is a false friend.**
*(Seat 2-D2 — verified.)* `discover.md` desc = "Find context **waste** — programs and tools consuming excessive context window space." It is a context-hygiene linter, NOT a program finder. The actual finder is `find-program.md`. The single most intuitive verb for "show me programs" points at the wrong tool — new users misfire 100% of the time. **Highest-ROI single rename in the report.**

**H-2 — Bare-verb vs family-verb shadow collisions.**
*(Seats 2-D3, 3-A3.)* Eight global bare verbs silently shadow scoped family verbs with *different behavior*: `status` (OS dashboard) vs `code-dev-state-status` (project/phase); `undo` (rolls back L: memory) vs `code-dev-state-undo` (reverses `_actions.log`); `resume` (episodic) vs `code-dev-state-resume` (compaction recovery); `handoff` (session serialize) vs `code-dev-state-handoff` (single-file briefing); `simulate` (any program) vs `workflow-simulate`. They are genuinely distinct, but the bare name wins at the prompt — a user typing `undo` after a code-dev write gets the wrong undo.

**H-3 — The `status` / `stats` / `state-status` / `state-metrics` / `dispatch-stats` near-homonym cluster.**
*(Seats 1-B4, 2-D4, 3-A2, 4-C.)* Five dashboard-ish programs separated only by `status` vs `stats` (one character) vs `metrics`: `status.md` ("Live OS dashboard"), `stats.md` ("Workspace health dashboard"), `code-dev-state-status.md`, `code-dev-state-metrics.md`, `code-dev-meta-dispatch-stats.md` (autogen-stub). `COMMANDS.md:123` hard-codes `status` as a direct (non-dispatched) command, guaranteeing `stats`/`status` confusion. A typo lands you in a different program.

**H-4 — `meta` means two unrelated things.**
*(Seat 3-A1 — verified.)* `meta.md` = "Generalized critique engine — evaluate / improve / audit / scrutinize / review." `code-dev-meta.md` = "Meta umbrella — whatif / help / actions / context / cheatsheet / dry-run / examples (PR-14)." One is a critique engine, one is a command hub. `*-meta` carries no signal which sense applies.

**H-5 — Help-card name collisions (8 names → 2 files each).**
*(Seat 3-C3 — verified: `workspace/programs/help/` contains `crucible, health-check, help, list-tools, menu, show-memory, status, translate`, all of which also exist top-level.)* The cards are different artifacts (a `help/menu.md` 9-line card vs the 399-line top-level `menu.md`). The registry silently indexes only the top-level version, so the `help/` copies are shadow files with colliding invocable names the registry cannot represent — either dead (latent rot) or loaded by another path (then the name is ambiguous).

### MEDIUM — consistency issues that feed the ambiguity

**M-1 — Verb/noun ordering is split with no rule.**
*(Seats 1-B1, 3-M1/M2.)* Two grammars coexist: noun-first (`code-dev-pr-create`, `goal-audit`, `mode-detect`) and verb-first (`find-program`, `list-tools`, `show-memory`, `run-tests`, `new-chat`, `audit-to-study`). The 88-file `code-dev-*` majority is noun-first, so noun-first should win. The `audit` verb appears in both positions (`audit-to-study` leads; `goal-audit`, `axon-audit`, `code-dev-safety-audit` trail) — you cannot enumerate "all audits" by prefix.

**M-2 — Five synonyms for "create."**
*(Seats 2-D7, 4-#8.)* `new` (`code-dev-new`, `library-dev-new`, `workflow-new`, `code-dev-phase-new`), `init` (`code-dev-init`, `my-axon-init`), `create` (`code-dev-pr-create`), `define`/`set` (`goal-define`, `goal-set`). Worst pair: **`goal-define`** ("Harden raw goals by interrogation … measurable acceptance criteria") **vs `goal-set`** ("Capture or refresh the Main Goal record") — the interrogate-vs-capture distinction is invisible from the names. `new` is already the plurality; it should be the canonical verb.

**M-3 — Broken umbrella hierarchy (2 of ~13 parents missing).**
*(Seat 1-B2 — verified.)* Parent index programs exist for `state, review, meta, safety, knowledge, journal, study, plan, lifecycle, flow, shape` but **`code-dev-pr.md` and `code-dev-phase.md` are both MISSING** despite `code-dev-pr-*` having 12 children and `code-dev-phase-*` having children. The "parent index" convention is 11/13 followed — `pr` and `phase` are the two holes.

**M-4 — `_`-prefix convention applied inconsistently.**
*(Seats 1-B... , 3-M3, 4-#1.)* `_chat-checkpoint, _index, _code-dev-schema-v4, _reservoir-manifest` use the "private/special" underscore, but **only `_code-dev-schema-v4` appears in REGISTRY.json**; the others are excluded. So `_` does not reliably mean "not a runnable program" — a quiet ambiguity for any tool filtering on it.

**M-5 — `mode-*` prefix split across two unrelated concepts.**
*(Seat 3-A6.)* Kernel `axon/programs/mode-{build,chat,dev,memory,plan,run,system}.md` = UI mode *switching*. Workspace `workspace/programs/mode-{detect,router,suggest}.md` = mode *inference/routing*. Same prefix, orthogonal purpose, different directories.

**M-6 — `auto-*` vs `autonomy-*` near-collision, and the `reanchor` pair.**
*(Seats 1-B4, 3-A4/A5, 4-#3.)* `auto-actions`, `auto-improve` vs `autonomy-contract`, `autonomy-reanchor` — eyeballing/tab-completing "auto" returns four items in two unrelated families. `axon-reanchor` (per-turn kernel reload) vs `autonomy-reanchor` (which *calls* `axon-reanchor`) — confirmed wrapper relationship, but the names give no clue which is primitive and which is composite.

### LOW — long-tail and cosmetic

**L-1 — Prefix sprawl / singleton namespaces.** *(Seats 1-B5, 2-D8, 4-A.)* After `code-dev` (87–88), `library` (9), `workflow` (7), `axon` (5), there are ~50 singleton prefixes (`gain`, `handoff`, `crucible`, `deps`, `resume`, `undo`, `versions`…). The namespace system effectively exists only for `code-dev`; the other ~85 programs are a flat bag. Eight programs literally call themselves "umbrella" and enumerate their children in their desc — the codebase admitting it wants sub-namespaces.

**L-2 — Metaphor / mystery-meat names.** *(Seat 4-#4/#5.)* `crucible` ("control + test gate — CI, but harder"), `gain` ("Longitudinal session analytics"), `keystone` — none guessable from their job. `crucible`/`keystone` also collide with same-named tools.

**L-3 — Abstract grab-bag umbrellas.** *(Seat 4-#6.)* `code-dev-flow` / `code-dev-shape` / `code-dev-meta` are three near-synonymous abstract nouns routing to arbitrary membership (why is `merge` under "flow" but `partition` under "shape"?). Buckets named after vibes.

**L-4 — Overlapping operation vocabularies.** *(Seat 4-#7.)* `code-dev-partition` ("split, merge, undo") overlaps `code-dev-divide` ("split") + `code-dev-combine` ("combine") — three names, two operations, fully overlapping. Pick one vocabulary (recommend `split`/`merge`).

**L-5 — Implementation artifacts leaking into user-facing text.** *(Seat 4-E — verified: `code-dev-meta.md` desc ends "… (PR-14)".)* `(PR-14)`, `(P10)`, `-v4`, `-schema-v4` leak commit/PR/version provenance into names and descriptions users read.

**L-6 — Two per-program describers.** *(Seat 2-D6.)* `explain` ("plain-English walkthrough") vs `help` ("uniform program guide — WHAT/HOW/INPUTS/OUTPUTS") — overlapping intent, no signal which to use.

**L-7 — Workflow naming is a third, inconsistent grammar.** *(Seats 1-B7, 2-D9, 4-D.)* `multiple-code-dev.yml` (unique `multiple-` quantifier prefix), `code-dev.canonical.yml` (compound `.canonical.yml` extension), `cpp-code-dev.yml`/`python-code-dev.yml` (language as *prefix*, not the dotted suffix style), `adaptive-free-text.yml` (no domain anchor). `.claude/workflows/` cloud jobs embed transient labels: `wave-c-pr11-design-study.js`, `axon-cgate-study.js`. A reader cannot predict whether a variant is `<qualifier>-code-dev` or `code-dev-<qualifier>`. Separately, `workflow-new-questions.yml` is a YAML config sitting among `.md` programs.

### Program ↔ tool stem collisions (flagged, decision needed)

16 names exist as both a program and a `tools/*.py` tool: `auto-improve, autonomy-contract, autonomy-reanchor, axon-audit, crucible, deps, hr-team, meta, quality-loop, rag-maturity-audit, retrieval-eval, self-care, simulate, translate, undo, workflow-run`. Seat 1 verified that for `crucible`(5×), `deps`(4×), `simulate`(1×) the thin program **wraps the same-named tool via `TOOL(<self>,…)`** — that is the intended pattern. But `meta`, `translate`, `undo` programs do **not** call their same-named tool, so those three collisions are *coincidental*, not architectural. `workflow-run` (program) vs `workflow_run.py` (tool) is the most dangerous: same name, same domain, different layer.

---

## 3. Prioritized Recommendations

Ordered by sequencing dependency, not just severity. **P0 items unblock everything else.**

### P0 — Enablers (do these first; they make later renames non-breaking)

| # | Action | Fixes | Files |
|---|--------|-------|-------|
| **P0-1** | Add real `status` enum (`ACTIVE/OPTIONAL/STUB/ALIAS/DEPRECATED/ARCHIVED`) + `alias_of` + `supersedes` fields to `REGISTRY.json`, mirroring the synapse block. Stop flattening STUB/ALIAS to ACTIVE. | CR-3 | `REGISTRY.json`, registry generator, `authoring-guide.md:225` (already defines the enum) |
| **P0-2** | Add **Section 13 "NAMING"** to `authoring-guide.md`: kebab-case; shape `<domain>-<area>-<action>` with **action a verb, domain/area nouns**; verb-LAST; max depth 3; one canonical create-verb (`new`); banned synonym sets (new/init/create/define/set → `new`); no version/PR suffixes in names; "must be guessable from the job." | M-1, M-2, L-2, L-5, and prevents all regression | `authoring-guide.md` (currently no naming section) |

### P1 — Critical breakage (paired changes)

| # | Action | Fixes |
|---|--------|-------|
| **P1-1** | Namespace workflows away from programs so program `code-dev` ≠ workflow `code-dev`. Recommend the workflow `name:` field become `code-dev.wf` / `library-dev.wf` (or `wf:code-dev`). **Land together with P1-2.** | CR-1 |
| **P1-2** | Fix the `workflow-run --name` resolver to index canonical workflows by their `name:` field and search `workspace/domains/*/workflows/` + `workspace/workflows/` (not just `workspace/workflows/{name}.yml`). | CR-2 |
| **P1-3** | Delete the two `-ALIAS` files (`code-dev-preflight.md`, `code-dev-reviewer-track.md` — registry already says "remove") and move alias resolution into the new `alias_of` field. | CR-3, kills the only filename≠header cases |

### P2 — High-ROI single renames (each ships with a one-release alias via P0-1)

| # | Current | Proposed | Fixes |
|---|---------|----------|-------|
| **P2-1** | `discover` | `context-audit` (and alias the word "discover" → `find-program`) | H-1 — highest ROI |
| **P2-2** | `stats` | `workspace-status` (or `workspace-health`, matching its own desc) | H-3 |
| **P2-3** | `status` | `os-status` | H-2, H-3 |
| **P2-4** | `meta` | `critique` (matches "critique engine"; keep `code-dev-meta` as the hub) | H-4 |
| **P2-5** | `code-dev-meta-igap` (STUB, autogen desc) | Delete; canonicalize on `igap-improve` — OR finish the desc and fold `igap-improve` into it | Seat 4-#2, duplication |
| **P2-6** | Move help-card collisions to `<name>.card.md` or fold into parent | H-5 |

### P3 — Systemic consistency (sweep after P0-2 lands the rule)

- **P3-1** Apply verb-LAST + canonical `new` across the tree: `new-chat`→`chat-new`, `find-program`→`program-find`, `list-tools`→`tools-list`, `show-memory`→`memory-show`, `run-tests`→`tests-run`; retire `init`/`define`/`set`/`create` as create-verb suffixes (merge or differentiate `goal-define`/`goal-set`). *(M-1, M-2)*
- **P3-2** Create the two missing umbrella parents `code-dev-pr.md` and `code-dev-phase.md` (additive, zero-risk). *(M-3)*
- **P3-3** Split the `mode-*` prefix: kernel UI switches stay `mode-*`; inference programs → `mode-infer-*` or `dispatch-*`. Reserve `auto-` for autonomy (`auto-actions`→`hook-actions`, `auto-improve`→`self-improve`). *(M-5, M-6)*
- **P3-4** Disambiguate the `reanchor` pair by hierarchy: primitive `reanchor`, wrapper `reanchor-autonomous`. *(M-6)*
- **P3-5** Collapse `divide`/`combine`/`partition` onto `split`/`merge`. *(L-4)*
- **P3-6** Reclassify `_code-dev-schema-v4` out of `programs/` (it is a schema changelog, not a program) or give it `status: DOC` and drop the `-v4`. Fix `_`-prefix indexing consistency. *(M-4, Seat 4-#1)*
- **P3-7** Strip `(PR-14)`/`(P10)`/version artifacts from descriptions and names. *(L-5)*

### P4 — Workflow files (low consumer count, do anytime)

- `cpp-code-dev.yml`→`code-dev.cpp.yml`, `python-code-dev.yml`→`code-dev.python.yml`, `multiple-code-dev.yml`→`code-dev.multi.yml` (domain-prefix + variant-suffix, consistent with `.canonical.yml`). `wave-c-pr11-design-study.js`→`design-study.js` (drop transient PR/wave labels). *(L-7)*
- **Note (Seat 2 vs Seat 1 dissent on direction — see §4).**

### Migration mechanics (applies to all renames)

Programs are dispatched by name via `find-program`, `menu`, `help`, `COMMANDS.md:122-124`, and `REGISTRY.json`, and cross-referenced in `Deps:` / `next-suggests` / `next-conditional` / `dispatch-phrases` / `EXEC(...)` fields (`authoring-guide.md:234` warns these "must point to REAL programs — no dangling"). Every rename requires: (a) `git mv` file; (b) update `# PROGRAM:` header; (c) regenerate `REGISTRY.json` and the `compiled/*.cmp.md` artifacts; (d) grep-sweep inbound `Deps:`/`next-suggests:`/`next-conditional:`/`dispatch-phrases:`/`EXEC(...)`/`TOOL(...)` references; (e) sweep hardcoded names in `menu.md` (lines ~344-347, 384), `orchestrator.md`, `workflow-run.md`, umbrella child-lists (`code-dev-state.md` etc.), `axon/PROGRAMS-INDEX.md`, `axon/programs/_index.md`; (f) update workflow `name:` fields and the test suite (`tests/test_workflows_catalogued.py`, `tests/test_workflow_list.py`); (g) add a one-release `alias_of` entry so old invocations resolve. The repo already has a deprecation pattern (`discover.md:64-67` "deprecated (axon-cleanup PR-142)"). **CR-1 and CR-2 must migrate together** or `workflow-run --name` stays broken.

---

## 4. Open Questions / Dissent (preserved)

The four seats agree on the diagnosis but diverge on several prescriptions. These are unresolved and flagged for the synthesizer/owner to decide.

**OQ-1 — Verb position: noun-first vs verb-LAST.** All seats want *one* rule; they phrase it differently. Seat 1 says **noun-first** ("`<domain>-<area>-<action>`, action is a verb" — but recommends `program-find`, `tools-list`, i.e. noun-first ordering). Seat 3 says **verb-LAST** (`chat-new`, `study-from-audit`). These are the *same* target (qualifier precedes verb) described from opposite ends — but the labels conflict and must be stated once, unambiguously, in the NAMING section. **Resolve the wording before sweeping.**

**OQ-2 — Bare-verb shadows: rename vs reserve-by-scope.** Seat 2 offers two mutually exclusive fixes for H-2: (a) rename the global verbs (`status`→`os-status`, `undo`→`mem-undo`, `resume`→`session-resume`) so no bare verb shadows a family verb; OR (b) *reserve* bare verbs for global scope and *require* the family prefix inside a domain (no renames, a routing rule instead). Seat 3 implicitly favors (a). **Pick one; (b) is cheaper but relies on disciplined invocation.**

**OQ-3 — Workflow variant position: prefix vs suffix.** Direct dissent. Seat 1 wants the **dotted suffix** style (`code-dev.cpp.yml`, `code-dev.multi.yml`) to match `.canonical.yml`. Seat 2 wants the **dash-suffix** style (`code-dev-cpp`, `code-dev-python`, `code-dev-multiple`), reserving prefixes only for cross-domain workflows. Both agree the *qualifier should trail the domain*; they disagree on the separator (`.` vs `-`) and whether `.canonical` should remain a compound extension at all. **Owner must choose one separator convention for workflow files.**

**OQ-4 — `code-dev-meta-igap`: delete vs finish.** Seat 1 and Seat 4 split: delete the stub and canonicalize on `igap-improve` (Seat 1's R6 option A), OR rename `igap-improve`→`code-dev-meta-igap` and fill the description (Seat 1's R6 option B, Seat 4's "promote the description"). One home must win; the choice depends on whether igap is conceptually a `code-dev-meta` child or a top-level capability.

**OQ-5 — Umbrella promotion: physical subdirs vs index-only.** Seat 2 (D8) proposes either *physical* sub-namespaces (`workspace/programs/code-dev/state/status.md`) or, at minimum, an index per umbrella. Physical subdirs would be the deepest structural fix for L-1 sprawl but would touch the registry generator, every dispatch path, and the filename=header invariant (the header would need a path-qualified name). No seat fully costed the physical-subdir option. **Open: is the flat namespace a constraint of the dispatch model, or just inertia?**

**OQ-6 — Program↔tool stem collisions: namespace-separate vs document.** Seat 4 wants a decision (namespace-separate or accept the layer disambiguation in docs). Seat 1 showed ~13 of the 16 are the intended wrap-the-tool pattern and only `meta`/`translate`/`undo` are coincidental. **Narrow open question:** rename only the 3 coincidental collisions, or impose a blanket program-vs-tool naming separation? Seats lean toward "rename only the 3," but this was not put to consensus.

**OQ-7 — Scope of the `discover` reassignment.** Seat 2 wants the *word* "discover" aliased to `find-program` after `discover.md` is renamed to `context-audit`. Seat 3 is silent on whether the alias is worth the indirection. Minor, but it determines whether "discover" becomes a live alias or a retired token.

---

*Prepared by the Deliberator. Advisory only — no renames executed. All file/line citations verified against the working tree at `/home/arturcastiel/projects/new-axon/axon` on 2026-06-19.*
