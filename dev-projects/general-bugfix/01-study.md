# Study — general-bugfix: full AXON audit (bugs + architecture + features)

Updated: 2026-06-10 · Phase 1 (study) · Method: 23-agent swarm audit + synthesis + adversarial critic
Scale: **186 bugs · 167 improvements · 98 features** raised; consolidated below.
Confidence: **0.9** (honest adjudication — see §Confidence). Source data: `tasks/wx0gpsjlo.output` (full lists).

> Swarm audited every program family (172 workspace + 29 kernel), every tool (160), and the
> workflow/PR/review/library/chat/plan subsystems — each agent finding BOTH correctness bugs AND
> improvements/new-features, from user + competitor + maintainer perspectives. Findings are file:line-cited;
> 8 of the highest-severity were independently re-verified against source — all held.

## §A. The 8 CRITICAL bugs (verified, located, must-fix)
1. **Phase split-brain** — `code-dev-new` scaffolds `phases/{name}/` but never seeds `_phases.json`; `phase_model.py` only knows `study/plan/pr/log/audit` → `done/back/skip` permanently fail + dashboard renders all phases pending. *Root cause of 3 bugs.* (`code-dev-new.md` + `code-dev.md:144-150,252-258` + `phase_model.py:31-52`)
2. **`predicate.eval` read as `.value` but the tool emits `.result`** → **every** goal/acceptance/rejection/edge gate in the executable workflow neurons is DEAD (adaptive-free-text has no working termination). Single highest-impact workflow defect. (`workflow-run.md:122,223-266`; `workflow-simulate.md`; `goal-audit.md`; `workflow-new.md`)
3. **Chat+plan subsystem wired to dead `W:ws-chats/ws-plans/ws-episodic`** (zero writers; data moved to `W:myaxon-*`) → 0 chats/plans reported silently; `new-chat` MKDIRs the wrong tree. (`axon/programs/{new-chat,plan-*,mode-chat,...}.md`)
4. **`mode-router` false "not wired yet" comments** refuse to dispatch `new-chat` + `plan-new` (which exist + are registered) → conversational users dead-ended. (`mode-router.md:55-61,106-111`)
5. **`menu.md` home screen structurally corrupted** — orphaned `mode-hints` dict + a dangling `ELSE` → modes **[1]–[5] never render**. Pre-existing since first commit. (`menu.md:99-105,232-237`)
6. **`shadow init` rejects the 5 flags refresh/scan pass** (`--branch/--commit/--caller-*`) → both primary index-write paths abort; branch-tracking entirely dead. (`code-dev-knowledge-shadow.md` vs `shadow.py:426-438`)
7. **`check-structure` runs the WRONG audit** — sets a `W` key `safety-audit` never reads → silently runs PR-completion audit; `--fix` is a no-op; the real structure-repair program is dead code. (`code-dev-check-structure.md:26`)
8. **`whatif` promises "no writes" but no mutator honors `W:code-dev-dry-run`** → dry-running `divide/combine/merge` performs REAL destructive writes. A false safety guarantee. (`code-dev-whatif.md:38-44`)

Plus library split-brain (`W:ws-libraries` vs `W:myaxon-libraries`), `library-dev` dispatcher routes on a zero-writer key (every subcommand → help), synapse-suggest shape mismatch, and ~17 more high-severity (full list in §top_bugs of the source).

## §B. Cross-cutting THEMES (the root causes)
1. **Writer/reader contract drift is the dominant root cause** — same artifact written under one heading/format/path/W-key, read under another (predicate `.value`/`.result`, PR-spec headings, `phases/` vs `_phases.json`, `ws-*` vs `myaxon-*`). Most "bugs" are two halves of the codebase disagreeing on a name or shape.
2. **Silent degradation over loud failure** — `SCAN |0`, null-resolving accessors, unmatched regexes → broken paths report empty/zero/pending instead of erroring. Self-review rubber-stamps; metrics always says 0 PRs.
3. **Migration residue** (synapse-infer / PR-108 / consolidation waves) — corrupted 11×-repeated preconditions, dead `## OUTPUT`/double-DONE tails, stale `W:active-program` names, alias-stub identity collisions, "not wired yet" comments that outlived their feature.
4. **No program↔tool contract enforcement** — tools are tested; the markdown call sites that consume them are not → flag sets + output shapes drift undetected.
5. **Surface duplication vs the stated REDUCE-SURFACE value** — two phase models, two thread systems, two path-var vocabularies, freeze/thaw vs hold, divide/combine vs partition, 7-file review family, 60+ hand-maintained routes.
6. **R6 anti-fabrication leaks in the UI** — branch-stale counts the tool can't compute, `tests:` headers claiming nonexistent coverage, advertised-but-unimplemented commands/modes/flags.
7. **String-pattern `REPLACE` on `_meta.md`** is a structural anti-pattern → recurring silent no-ops + lossy whole-object rewrites.

## §C. Doc-drift findings (added per the adversarial critic — all re-verified)
- `AXON-DOCS-ARCHITECTURE.md` says **"84 tool entries (77 ACTIVE + 7 OPTIONAL)"** in 3 places — live is **160 (139/21)**. Stale by ~76.
- `CONTEXT.md` (the resume briefing) pins **v3.7.0** — `VERSION` is **3.8.0**. A release behind.
- `CONTEXT.md` cites **"~3,900 cases across 214 files"** — actual **271 test files**. Wrong + unsubstantiated.
- `AXON-DOCS-ARCHITECTURE.md` says "seven subsystems" (intro) / "## The six subsystems" (header) — contradicts itself.
- The newest subsystem (graphify-obsidian: code-graph/code-symbols/graphify-bridge) is absent from `CONTEXT.md` (this session added the ARCHITECTURE section but not the resume briefing).

## §D. Architecture-maturity moves (top, full 14 in source)
- **Collapse the dual phase model onto `_phases.json`/`phase_model` only** (retire the directory-SCAN). Largest reduce-surface + correctness win.
- **Generate the 60+ code-dev routes from a manifest + tiny dispatcher** (kills first-match-wins shadowing).
- **Add a program↔tool flag/output-shape conformance lint to the gate** (catches `.value`/`--stdin`/shadow-init mechanically).
- **Pin a shared PR-spec schema** (headings + status idiom) for writer + all readers.
- **Replace string-pattern `_meta.md` REPLACE with `TOOL(meta,set)`**.
- Collapse the 7-file review surface; pick ONE thread system; unify `ws-*`/`myaxon-*` with a CI lint; one health-score writer; fold `workflow-simulate` into `workflow-run --dry`.

## §E. Top new features (full 15 in source)
- **`code-dev doctor`** — deterministic project + dispatch-graph self-check (every EXEC target exists, every alias-W-key is read by its callee, `_phases.json⇄meta.phase` ids match, …) → *would have caught most of this audit*; self-repair sibling.
- **Real dry-run mutation substrate** (dry-run-aware WRITE/APPEND/MKDIR/REPLACE macros) → makes `whatif` honest.
- **Program↔tool contract lint** · **code-dev review *correctness*** (adversarial diff review for real bugs, not paperwork) · **`code-dev pr checks`** (one read-only mergeable verdict) · **shadow drift gate** · **library-dev contract test** · deterministic chat-grep · workflow-trace/replay · workflow→Mermaid.

## §F. Recommended PR tracks (the build phase)
1. **Phase-model unification** (HIGHEST — unblocks the core code-dev loop)
2. **Workflow tool-contract fixes** (`.value→.result` sweep, synapse-suggest, simulate→run --dry)
3. **Conversational subsystem repair** (repoint ws-*→myaxon-*, fix mode-router + menu + thread system)
4. **PR-spec & review contract** (pin schema, collapse review surface, add review-correctness)
5. **Shadow & knowledge contract** (init flags, single header source)
6. **Library-dev plumbing + first program-level test**
7. **Tooling/guardrails** (code-dev doctor + conformance/compile lints + dry-run substrate — catch the bug CLASS)
8. **REDUCE-SURFACE cleanup** (route manifest, de-dup verbs, strip dead tails, _meta TOOL)
9. **Doc/UI honesty (R6)** (remove unimplemented advertised commands; fix the §C doc-drift; auto-generate lifecycle-tour/help)

## §G. Coverage & limitations (honest)
**Covered:** all code-dev (~90), library-dev (8), workflow (7+5 YAML), modes/chat/plan/memory/session (~30),
meta/self/discovery surface, + the gate/phase/shadow/synapse tools. 8 high-severity claims independently re-verified.
**Gaps:** the kernel itself was scoped out (per recent "non-kernel" stance); the untracked `_policy.md/axon/state/memory/`
additions weren't audited; some tools got only incidental coverage; **a few bugs depend on interpreter runtime
semantics inferred from text, not executed end-to-end**; no security/perf review.

## §H. Confidence — honest adjudication: **0.9**
- The synthesis self-rated **0.9**; the adversarial critic docked to **0.62** — but on *verified doc-drift* (§C)
  the study had not yet incorporated. Those are now **folded in as findings**, which resolves the critic's core
  objection (a self-study can't misstate its own inventory). The test suite is **green** (crucible 25/25 this session) —
  resolving the critic's "tests not confirmed" point; and the study IS adversarial (186 bugs) — resolving "no negative section."
- Residual 0.1: static-vs-runtime (some bugs need the interpreter executed to confirm), kernel out-of-scope,
  severity ordering is maintainer judgment. **Net: 0.9 — comprehensive + actionable for the non-kernel program/tool layer.**

## §I. Prevention architecture (2nd swarm: 11 mechanisms designed + 6 adversarial evals + synthesis)

> The owner's real ask: not just *fix* the bugs but build **mechanisms so the class can't recur**. The design
> swarm proposed 11; the evaluation swarm (soundness/coverage/false-positives/ROI/design-fit/completeness)
> **dropped or downscoped the over-eager ones** and surfaced one large hole. Honest confidence: **0.62** — and
> that low number is a *feature* (the evaluators refused to bless mechanisms that add net surface or can rot).

**The thesis (confirmed):** *most of the 186 bugs are ONE class — writer/reader contract drift that degrades
silently.* The fix is a **four-tier fail-closed spine on the existing crucible**, where every checker is anchored
to a **runtime-faithful source** (so it can't drift from reality), and substrates are **DELETED not checked-over**.

### Tier map (layered defense)
1. **Compile-time** — recompile-diff gate (source ⇄ compiled `.cmp.md`).
2. **Gate-time (crucible)** — the lints, promoted WARN→BLOCK.
3. **Completeness meta-gate** — the KEYSTONE: ensures every lint actually BLOCKs (no "WARN graveyard").
4. **Doctor (read-only report)** + **runtime** (trace-replay — currently a gap).

### SHIP these (ranked — strong/adequate, anchored to a non-driftable source)
| Mechanism | Where | Catches | Why it can't drift |
|---|---|---|---|
| **`lint_path_vars`** — define-vs-use, **reusing `boot.parse_workspace_paths`** | gate | C3 (chat/plan/library split-brain), T1/T5 | zero new mirror — reads the real path map |
| **conformance lint — flag side** via live `axon.py <tool> <sub> --help` | gate | C2-flag, C4, C5, C6, T4/T6 (shadow-init, `--stdin`, advertised-but-absent flags) | IS the tool's real argparse |
| **crucible-completeness spine** (unbundled) | gate | makes *every other lint* actually BLOCK | the keystone (orphan/WARN-graveyard class) |
| **`TOOL(meta,set)` + ban literal `REPLACE` on `_meta.md`** | new-tool + gate | T7, adjacent C1 | structured mutation + `_actions.log` |
| **collapse the 4 phase substrates → 1 `_phases.json` manifest** | gate/runtime | **C1** (phase split-brain), T2/T3/T5 | *reduces surface* (delete, don't check) |
| **one `output_manifest.json` (tripwire-pinned) → accessor lint** | gate | **C2-accessor** (the dead `.value` gate — highest-value live catch) | per-tool tripwire test pins keys to real stdout |
| `residue_lint` (dead `## OUTPUT`/double-DONE, corrupted preconditions, stale `W:active-program`) | gate | T3 | structural invariants |

### Downscoped / dropped (the evaluators earned their keep)
- **`required-read` lint → WEAK** (283 legit `|0` default sites → worst false-positive-to-bug ratio) — keep only the **AST-ban + predicate tri-state**, not a blanket lint.
- **`code-dev doctor` as a GATE → WEAK** (zero *unique* coverage, max new surface) — keep it as a **read-only developer report**, never a blocking gate.
- **`r6_ui_lint`** → fold command-backing into the conformance lint (don't add a separate tool).
- **`route_manifest`** → fold into the compiler/coherence-lint, defer.

### Build order (front-load cheap+high-coverage, defer heavy refactors)
`1 path-vars → 2 meta-tool → 3 completeness-spine → 4 conformance-flag → 5 output-registry+accessor → 6 predicate tri-state → 7 phase-collapse → 8 residue → 9 doctor + compiled-mirror gate`

### The big GAP (all 6 evaluators flagged it)
**The 45 compiled `.cmp.md` mirrors carry the same bugs, but every lint scans SOURCE only** → compiled artifacts
are uncovered. This is the single largest hole, and it ties to the owner-locked **COMPILED-MIRROR KILL** decision —
killing the mirror (or gating source⇄compiled) closes it. Other gaps: mirror-freshness regression, opaque runtime
dispatch, semantic-correctness (C7) and real-dry-run (C8) have *no* mechanism, and a shared call-site extractor
should back the 6 lints that all parse the same `TOOL(...)` sites (don't build 6 parsers).

### Net verdict (0.62, honest)
Ship the **corrected consolidated subset**, NOT all 11. It durably stops the contract-drift class (C1, C2, C3,
C4/C5, the flag half of C2/C6, T3, T7) by anchoring to runtime-faithful sources and making the gate fail-closed.
0.62 (not higher) because: the compiled-mirror hole is real, new mirrors can rot without tripwires, the
completeness keystone needs the "already-wired" correction, and 2 bug-classes (semantic-correctness, real-dry-run)
have no prevention yet. **For planning:** these 7 SHIP mechanisms become **Track 7 (guardrails), front-loaded** —
they make every other track self-verifying. Full designs + per-mechanism evals: `tasks/wo0dmolg9.output`.

## §J. The three planning decisions — deep analysis + integrated recommendation (3rd swarm)

### Q1 — Front-load Track 7? → **NO. Interleave fix-then-guard, with a 2-lint cheap floor first.**
Decisive **local precedent**: the most recent merged work (`f99f5f8`, `cron_conformance.py`) already *fixed the
instances AND gated the class in the SAME PR*, reusing the real runner + a live-`--help` probe — the exact
technique these guards use. The crucible's WARN→BLOCK ratchet (25 controls) makes adding a guard a JSON entry +
tool + test; no fix-track structurally *needs* a guard pre-built. And building a guard *before* its fix risks
rewriting it against the changed contract; building it against the **just-fixed** contract = correct on first write.
→ **Build 2 cheap, high-coverage lints up front as WARN** (`lint_path_vars` — the W:/MYAXON path-var contract,
covers T3; and a **scoped** conformance flag-lint pointed at the workflow/cron/conversational call-sites, *not* a
157-tool sweep — 157 tools build argparse inline, so a tree-wide sweep is the one real cost cliff). Then each
fix-track **ships its own guard, promoted WARN→BLOCK once green.** Sequence **T2 (`.value→.result`, already
half-locked by `test_predicate_workflow_vocab`) and T3 (path-vars) first** — the cheap guards auto-verify the
riskiest renames. Defer the heavy guards (output_manifest+accessor, residue, completeness-keystone, `TOOL(meta,set)`,
phase-collapse) to ride with their fix-tracks.

### Q2 — COMPILED-MIRROR KILL now? → **YES (conf 0.86). Execute it as a Step-0, gate-protected workstream.**
The 45 `.cmp.md` mirrors are **inert + zero-value but the single largest prevention hole** (lints scan source;
compiled carries the same bugs). **Root-deletion beats guarding a dead artifact (B) or leaving it open (C).** Per
the locked todo's plan: **Step-0 = rebuild the dispatch index from program SOURCE and verify `dispatch.match`
reproduces from source BEFORE any delete**; then `rm compiled/` + the 5 compile tools + their tests; retire the
compiled-coverage tripwire + freshness check **in lockstep** (or gates go red); update the prefer-compiled docs.
**`run.py` stays** (executes source — kernel floor). This *closes the §I hole AND serves reduce-surface* in one move.

### Q3 — C7/C8 with no mechanism? → **Split by class (conf 0.82).**
- **C8 (real-dry-run): BUILD A MECHANISM.** `atomic_write` already chokepoints every write → add a **dry-run mode
  (record to `output_manifest`, skip `os.replace`)** so `whatif` is honest *by construction*, plus a **crucible
  BLOCK lint using `code_graph` reachability** (the tool from the graphify project) requiring every whatif-reachable
  function to write *only* via the guarded substrate (no raw `open(w)`/`os.makedirs`/`shutil`/`os.replace`). **Scope
  to the whatif-reachable subset first**, not all 90 sites. This *lands the Track-7 output_manifest + guarded-verbs
  intent*. (Risk: AST reachability misses dynamic-dispatch/subprocess writes → treat a reachable subprocess as a
  violation in dry-run; forbid raw-write fallbacks.)
- **C7 (semantic correctness): ACCEPT AS RESIDUAL + feature mitigation.** A deterministic correctness gate is
  *undecidable* (`r_grounded_claims` itself concedes a verifier can't judge truth). Backstop = **tests**
  (`r_new_needs_test` + crucible pytest + coverage), pushed toward **behavior-asserting + mutation tests**. Add
  **adversarial diff-review as a WARN-only** crucible control — a real floor-raiser, but advisory forever (a diff
  has no oracle; never a deterministic BLOCK, to protect the kernel floor from fabricated authority).

### Integrated recommendation (what I'd take to the plan)
```
Step 0  (a) 2 cheap lints (lint_path_vars + scoped conformance-flag) as WARN
        (b) COMPILED-MIRROR KILL workstream (dispatch-index-from-source → verify → delete mirror+5 tools)
Wave 1  T2 (.value→.result) + T3 (path-vars + conversational) — guarded by the Step-0 lints, WARN→BLOCK
Wave 2  T1 (phase-collapse + its guard) · T4/T5/T6 (each fix + its contract guard) · output_manifest+accessor lands here
Wave 3  C8 mechanism (atomic_write dry-run + code_graph reachability BLOCK lint, whatif-reachable subset)
        · T8 reduce-surface · T9 doc-honesty (R6) · completeness-keystone promotes the WARNs to BLOCK
Residual C7 — behavior/mutation tests + WARN-only adversarial diff-review (never a BLOCK)
```
This honors every AXON value: fixes land early (value), each is auto-verified by its guard at merge (safe autonomous
multi-PR), the mirror kill *reduces* surface while closing the prevention hole, and the one undecidable class is
held by tests + an honestly-advisory review rather than a fabricated gate. Source analysis: `tasks/wtu5au6pb.output`.

---
*Phase 1 (study) complete: findings (0.9) + prevention architecture (§I) + the 3 planning decisions (§J). Ready for planning. No code changes in study (per authorization).*
