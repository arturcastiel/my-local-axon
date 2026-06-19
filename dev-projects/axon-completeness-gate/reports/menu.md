# AXON Menu — Council Report

**Subject:** `workspace/programs/menu.md` (399 lines, ~22 KB)
**Charge:** Structure, completeness, information architecture, what it surfaces vs. hides, redundancy/dead entries, UX, concrete improvements.
**Form:** 4-seat advisory council (IA lens, new-user lens, power-user/maintenance lens, challenger) synthesized by the deliberator.
**Status:** Round-1 sealed opinions synthesized. Advisory only. Selected claims re-verified by the deliberator against source (see Verification notes).

---

## 1. Executive Summary

The AXON menu is an **excellent state dashboard and a weak program index**. All four seats independently converged on the same headline: the *backing* is solid — every `TOOL()` call and almost every command literal resolves to a real script or program, drift/health/snapshot wiring is largely correct, and state-conditional rendering is disciplined. The rot is not in dead tools; it lives at **the seams between what the menu claims and what reality is**.

Three structural problems dominate:

1. **Single-layer blindness.** AXON has two program layers — the **workspace** layer (`workspace/programs/`, 172 real programs) and the **OS** layer (`axon/programs/`, 29 mode/chat/plan primitives), a union of ~201. The menu's counts, its dispatch-index denominator, and `find-program`'s advertised corpus all reflect *only* the workspace layer, and even that count is computed with a buggy SCAN that overcounts by 2 (it excludes `help/` but not the two `_`-prefixed internals). Net effect: the home screen both **undercounts what a user can reach** (omits 29 OS programs) and **overcounts the workspace layer** (174 rendered vs. 172 real), producing a dispatch progress bar that can never read 100%.

2. **Staleness blindness.** The menu is a point-in-time cache renderer with no freshness awareness. It will confidently render a 3-week-old health score as "●●●●● Excellent," show a drifted dispatch index as healthy, and never surface the OS's central freshness gate. It even has a compiled twin (`workspace/programs/compiled/menu.cmp.md`) that must stay in sync — a freshness surface the menu never checks.

3. **A learnability cliff.** The menu is a ~217-output-line dashboard presented at uniform visual weight, with no "what is AXON," no first-run gate, and an onboarding path (`quickstart`) whose first instructions point at programs that are absent from the layer a new user is in. The deliberately-authored beginner narrative in `tools/onboarding.py` / `programs_registry` is orphaned — the home screen never surfaces it.

Beyond these, the council found a cluster of smaller, individually-cheap defects: an undefined `mode-hints['dev']` render gap, `[8]/[9]/[10]` entries that mimic mode-shortcut grammar but route nowhere, two dead boot-snapshot reads pinned in place by a contract test, twin near-identically-named QUALITY/SELF-IMPROVEMENT panels, triple-rendered status signals, false synapse metadata (`inputs-count: 30`, `outputs-count: 0`), and ~13 provenance/repair comments turning the most-edited file in the OS into changelog sediment.

**The single highest-leverage fix** is a CI/audit rule that asserts every command literal the menu and quickstart print resolves to a real program/tool/help target, combined with honest cross-layer counts. The two most dangerous *latent* defects are the stale-green health dot and the test-pinned dead reads.

---

## 2. Detailed Findings (file-cited)

### 2.1 Information architecture & completeness

**STRONG — zero broken command references in the menu body.** Every bare verb the menu tells the user to type resolves to a real program (`REGISTRY.json`) or tool (`tools/*.py`): `find-program`, `gain`, `discover`, `board`, `drift`, `igap`, `synapse-suggest`, `loop-contract`, `constraints`, `token-bench`, `program-tool-conformance`, `workspace-backup`, etc. Seats 1, 3, and 4 independently audited ~25 surfaced commands and found **zero dead entries in the menu body**. This is rare and worth preserving. (Seat 1, Seat 3, Seat 4)

**STRONG — progressive-disclosure search fallback.** The 88 `code-dev` subprograms are deliberately not enumerated; `help [program]` (`help.md:26-46`) resolves through a multi-path `help/{t}.md → {t}.md → .cmp.md → fuzzy` chain, and `find-program <text>` (`find-program.md:44`) scans all program files plus `# dispatch-phrases:` vocabulary. Surfacing verbs and deferring the catalog to search is the correct IA pattern for a 200-program surface. (Seat 1)

**STRONG — disciplined state-conditional rendering.** OS STATE lines (`menu.md:181-206`), reminders (`233-237`), resumable block (`227-230`), and the entire SELF-IMPROVEMENT panel (`315`) render only when non-trivial. The menu adapts to context rather than dumping a fixed wall. (Seat 1)

**WEAK — single-layer counts misrepresent the reachable surface.** `total-progs ← COUNT(SCAN(W:ws-programs, "*.md", exclude="help/"))` (`menu.md:62`) counts only the workspace layer. `dispatch_index.py:61-64` globs only `{ws}/programs/*.md` (its docstring even says "the 170 real programs"). Consequences:
- `"Dispatch {dispatch}/{total-progs} programs indexed"` (`menu.md:167`) — denominator omits the 29 OS-layer programs.
- `"find-program <text> — search {total-progs} programs"` (`menu.md:344`) — advertises a smaller corpus than the union.
(Seat 1; Seat 4 #3/#4)

**WEAK — modes are the largest IA blind spot.** Modes [1]-[7] (`menu.md:244-257`) are the primary navigation, yet the menu never tells the user *what programs each mode contains*. The mode hints (`menu.md:107-115`) are one-line descriptions, not maps. A user in MEMORY mode has no menu-visible inventory of the 6 memory-area programs; same for SYSTEM (9) and PLAN. ~30% of the canonical taxonomy is reachable only by tribal knowledge of what to type. (Seat 1)

**WEAK — 7 stub programs pollute discovery.** `REGISTRY.json` shows 7 programs carrying `"(autogen-stub — needs description)"` (`code-dev-events-emit`, `code-dev-meta-board`, `code-dev-meta-dispatch-stats`, `code-dev-meta-igap`, `code-dev-meta-usage`, `code-dev-rules-audit`, `_code-dev-schema-v4`). They surface in `find-program`/`help` with no useful description — dead-ish from the discovery POV. (Seat 1)

### 2.2 Redundancy & naming

**Triple/double-rendered signals.** Three status signals each render in more than one panel within a single screen:
- **Drift**: OS STATE (`menu.md:187-189`) AND SELF-IMPROVEMENT (`323-330`).
- **Auto-actions / unread**: OS STATE (`198-199`) AND SELF-IMPROVEMENT (`336-337`).
- **igap total**: OS STATE "Infer gaps" (`184`) AND QUALITY `igap improve` (`301-302`), plus 2 tips (`136-137`).
A drifting + unread + gappy session shows each warning twice. (Seat 1)

**Twin near-identical panel names.** `"QUALITY / SELF-IMPROVEMENT"` (`menu.md:296`) and `"SELF-IMPROVEMENT"` (`menu.md:317`) are adjacent sections with overlapping content (both touch igap, drift, auto-improve, auto-audit). A reader cannot tell why there are two. (Seat 1)

### 2.3 New-user learnability

**STRONG — the MODES block is the one genuinely learnable surface.** `menu.md:241-260` presents 7 numbered modes with one-line hints, and the kernel wires `1`–`7` as real shortcuts (`KERNEL-SLIM.md:733`). A beginner can type one digit and land somewhere. The active-mode badge (`menu.md:209-214`: "Type naturally — or '0'/'menu' to switch") answers the #1 new-user question. (Seat 2)

**BROKEN — quickstart, the menu's headline onboarding path, references programs absent from the workspace layer.** `quickstart.md` instructs a new user to run `list-programs` (`:77`), `compile`/`suggest-compile` (`:124-126`), and `dev-new my-workflow` (`:164`). Deliberator verification:
- `list-programs` — **absent from `workspace/programs/`, present in `axon/programs/` (OS layer).**
- `dev-new` — **absent from `workspace/programs/`, present in `axon/programs/` (OS layer).**
- `compile` / `suggest-compile` — **absent from BOTH layers.** (Seat 2 is unambiguously correct on these two.)
Whether the OS-layer `list-programs`/`dev-new` resolve when typed from quickstart depends on cross-layer EXEC resolution (`KERNEL-SLIM.md:734`). This is the core inter-seat conflict; see §4. (Seat 2 vs. Seat 1)

**WEAK — two competing, disconnected onboarding systems.** `tools/onboarding.py` ("first-run Day-1 welcome") drives a curated `MENU_PHILOSOPHY` and a 9-category map via `programs_registry`. The menu references **none of it** (one incidental grep hit at `menu.md:345`). The menu's taxonomy (CODE DEVELOPMENT / HR TEAM / WORKFLOWS / QUALITY / DISCOVER / SELF-OBSERVE / META) and `programs_registry.CATEGORY_ORDER` (Build Software / Domains / Memory & State / …) disagree entirely. The better-written beginner narrative is orphaned. (Seat 2)

**WEAK — cognitive overload, guaranteed every boot.** ~217 output lines, ~64 command-like tokens. Core Rule 12 (`KERNEL-SLIM.md:73`) forbids truncation, so a beginner is *guaranteed* to see the entire expert tier (`menu.md:296-377`: `synapse-suggest --top 5`, `retrieval-eval evaluate`, `rag-maturity-audit audit`, `token-bench run`, `loop-contract list`, …) at the same visual weight as the 7 modes. There is no "new here?" framing and no de-emphasis of the expert tier. (Seat 2)

**WEAK — no "what is AXON" on the landing screen.** The header is `AXON · {ws} · {date}` + author credit (`menu.md:144-151`). The one-sentence definition a newcomer needs ("AXON is an instruction-based OS for AI agents; everything is Markdown") lives only inside `quickstart.md:47`, which they must choose to enter. (Seat 2)

**WEAK — bare `help` has a silent-redirect trap.** The menu advertises `help [program]` (`menu.md:122,384`), but `help.md:21` falls back to `EXEC(list-programs)` when no target is given. `list-programs` is absent from the workspace layer (see §4), and this single `EXEC` has no multi-path fallback guard, unlike the rest of `help.md`. A curious user who types bare `help` bounces rather than getting help-about-help. (Seat 1, Seat 2)

### 2.4 State / health / drift correctness (maintenance lens)

**STRONG — snapshot aggregation is real and correct.** `snap ← TOOL(axon-state, menu-snapshot)` (`menu.md:24`) maps to `cmd_menu_snapshot` (`tools/axon_state.py:194`). Every field read off `snap` exists in the tool output: `dispatch_index_count` (`:227`), `drift.state` (`:230`), `prompt_log.should_prompt` (`:236`), `todos_preview` (`:240`), `workflows.{total,reference,user}` (`:243`), `audit_7d_total` (`:246`). Per-field `| TOOL(...)` fallbacks (`menu.md:61,186,191,195,233,285,314`) are all valid backends. Drift surfacing is fail-closed and mirrors `drift.py`'s gate states exactly (`unknown → gate fail-closed`, `drift.py:222-281`); cron-breaker/igap/auto-audit field accesses all check out against their tools. `L:health-score` has exactly one writer (`health.py --persist`, `tools/health.py:336-350`). (Seat 3, Seat 4)

**BROKEN — dead reads pinned by a contract test.** `menu.md:312-313` read `W:boot-cron-tick` and `W:boot-last-snapshot`; lines `331-334` render them. **Deliberator-verified: nothing in the repo writes either key.** The only references are the menu, its compiled twin `menu.cmp.md:273-274`, and the contract corpus `tests/synapse/corpus/menu.contract.json:79,83` — which *pins this dead behavior in place*. The two SELF-IMPROVEMENT lines "Cron tick" and "Snapshot" are permanently null. Dead-but-test-pinned is the worst state. (Seat 3)

**BROKEN — staleness blindness on Health.** The menu renders `hscore` (`menu.md:33`) with confident dots and "Excellent/Good" (`158-162`) but **never reads `L:health-score-date`**, which `health.py:337` writes precisely so staleness can be detected. A 3-week-old score shows as "●●●●● 92/100 Excellent." This stale-green dashboard is the worst maintenance failure mode. (Seat 3)

**BROKEN — staleness blindness on Dispatch index.** `menu.md:167` prints `{dispatch}/{total-progs} programs indexed (source-built)` where `(source-built)` is a hardcoded literal. The menu throws away `missing_from_index` and `stale_extras` (returned by `dispatch_index.py:107-108`; the tool even has a `check` subcommand that exits 1 on drift). Combined with the independent `total-progs` SCAN, the ratio can read e.g. `40/47` with no explanation that programs are unindexed. (Seat 3)

**WEAK — the OS's central freshness gate is invisible.** `tools/freshness.py` is "one control point for 'nothing stale, anywhere'" (`freshness.py:4`); it reconciles docs, registries, retrieval stores, and the compiled program artifacts to source. The menu surfaces it nowhere except buried inside the `self-care` one-liner (`menu.md:354`). Ironic, given the menu itself has a compiled twin (`menu.cmp.md`) that must stay in sync. (Seat 3)

**WEAK — backup staleness partially blind.** `menu.md:201-204` shows `last: {backup-last}` but never computes age; `backup-status ≡ "ok"` with a month-old `backup-last` still renders `✓`. (Seat 3)

### 2.5 Misleading / stale metadata (challenger lens)

**`mode-hints['dev']` is undefined — live render gap.** `menu.md:107-115` defines hints for 7 keys (chat/build/run/memory/system/plan/programs). **Deliberator-verified: no `dev` key.** `[D]` DEV mode is reachable (`COMMANDS.md:38` → `STORE(W:current-mode,"dev")`); when `curmode == "dev"` the badge at `menu.md:212` renders `{mode-hints[curmode]}` → blank. Same failure class as the "C5 repair" (`menu.md:105-106`) the file already advertises fixing. (Seat 4 #1)

**`[8]/[9]/[10]` mimic mode-shortcut grammar but route nowhere.** `[1]`–`[7]` are real numeric shortcuts (`COMMANDS.md:34-40`). The menu renders `[8] code-dev`, `[9] library-dev`, `[10] hr-team` (`menu.md:265/270/279`) in the identical bracket affordance, but COMMANDS.md defines no 8/9/10. Typing `8` falls through to free-text routing — the visual grammar makes a promise the router doesn't keep. (Seat 4 #2)

**Program-count denominator overcounts by 2.** **Deliberator-verified: 172 real programs, plus `_code-dev-schema-v4.md` and `_reservoir-manifest.md`.** The SCAN at `menu.md:62` excludes `help/` but not `_`-prefixed internals, rendering **174**. Therefore `find-program` (`:344`) overstates the corpus by 2, and the dispatch bar (`:167`) can **never read 100%** (172 indexed / 174 displayed). (Seat 4 #3)

**Snapshot's `programs_total` is dead; the menu recomputes wrong.** `tools/axon_state.py:259` emits `programs_total` correctly excluding `_`-files (=172) — the whole point of `menu-snapshot`. The menu never reads `snap.programs_total`; it re-derives the buggy `total-progs` itself. The snapshot ships a correct field nobody consumes while the menu hand-rolls a wrong one. (Seat 4 #4)

**False synapse metadata.** `inputs-count: 30` (`menu.md:10`) vs. 45 actual probe lines (Seat 3 count). `outputs-count: 0` (`menu.md:11`) vs. ~176 `→` output lines — the single densest output program in the OS is tagged as emitting nothing. Both stem from `inferred-by: synapse-infer (PR-108 bulk migration)` (`menu.md:14`). Any tool trusting this metadata (dependency graphs, dead-code/altitude audits) mis-models the menu. (Seat 3, Seat 4 #5)

**Dangling `(D-8)` reference and provenance sediment.** `menu.md:292` labels `workflow new … (D-8)`; `D-8` is defined nowhere — an orphaned milestone tag leaking into a user-facing label. The file also carries ~13 internal provenance comments (`PR-108/112/AUTO-208/012/013/015/016/018`, `axon-plus pr-6`, `Goal A`, `C5 repair`, `audit 2026-06-15`). Harmless to users (comments) but the most-edited file in the OS now reads like changelog archaeology — and the repair scars are tells that this file repeatedly breaks in migrations. (Seat 4 #6/#7)

### 2.6 Nuance — looks broken but isn't (so the council does not over-correct)

- **Bare tool-commands** (`igap report`, `drift check`, `cron breaker-status`, `board`, `dispatch-stats`, `token-bench`, `loop-contract`, `constraints`, `lint-paths`, `program-tool-conformance`, `workflow list`) have no program file and work because the agent interprets them as `TOOL()` calls / fuzzy-matches `KEYS(tool-registry)`. This is by design (interpreted kernel), **not a bug** — but it is a consistency smell: program-commands and tool-commands sit in the same flat list with no typographic signal which is which. (Seat 4)
- **`ts ← snap | TOOL(clock)`** (`menu.md:35`): `ts.date` resolves because both `snap` and `clock` expose top-level `date` (`axon_state.py:222`, `clock.py:44`). Loose, works. (Seat 4)
- **`last-snap.key_count`/`last-snap.ts`** (`menu.md:334`) read `W:boot-last-snapshot`, a different object from the menu snapshot — not a field bug (though the underlying key is dead per §2.4). (Seat 4)
- **`PYTHON_FAST · doc`** is a legitimate compile directive used by 45 programs — valid, not a defect. (Seat 4)

---

## 3. Prioritized Recommendations

### P0 — Correctness defects with user-visible or test-locked impact

1. **Add an audit/CI rule: every command literal printed by `menu.md` and `quickstart.md` must resolve** to a program (either layer), a tool, or a help file. This is the single highest-leverage fix — it catches the entire dead-link class at once, including the quickstart breakage and bare-`help`. (Seats 1, 2, 3, 4 converge.)
2. **Fix `total-progs`** to consume `snap.programs_total` with an exclude-both fallback: `total-progs ← snap.programs_total | COUNT(SCAN(W:ws-programs, "*.md", exclude=["help/","_*"]))`. Restores an honest `find-program` count and a 100%-reachable dispatch bar. (`menu.md:62`; Seat 4 #3/#4, Seat 1.)
3. **Delete or wire the dead boot reads** (`menu.md:312-313, 331-334`) AND remove the matching pins in `tests/synapse/corpus/menu.contract.json:79,83`. Dead-but-test-pinned must not persist. (Seat 3.)
4. **Add `dev:` to `mode-hints`** (`menu.md:115`) — closes the live blank-badge render gap. (Seat 4 #1.)
5. **Fix the quickstart command references** (`quickstart.md:77,124-126,164`): replace `compile`/`suggest-compile` (absent from both layers) with resolvable commands; confirm `list-programs`/`dev-new` resolve cross-layer from the workspace context or replace them with `find-program`/`authoring-guide`/`harness-builder`. (Seat 2; see §4 open question.)

### P1 — Staleness surfacing (highest maintenance leverage)

6. **Health-score staleness check**: read `L:health-score-date` and never render a green dot for a stale score (`menu.md:158-162`); append `⚠ stale (N d ago) — run: health-check`. (Seat 3.)
7. **Surface dispatch-index drift** (`missing_from_index`/`stale_extras`) instead of the static `(source-built)` literal (`menu.md:167`); optionally add the fields to `menu-snapshot` to keep it one-call. (Seat 3.)
8. **Add a top-level Freshness line** to OS STATE, gated to render only when artifacts are stale (mirror the Drift pattern at `menu.md:185-189`). This also catches `menu.cmp.md` drift. (Seat 3.)
9. **Backup age check** mirroring the health-date fix (`menu.md:201-204`). (Seat 3.)

### P2 — Information architecture & learnability

10. **Per-mode program index**: when `curmode ≠ ∅`, render that mode's `area` programs from `REGISTRY.json` (cheap — already grouped by `area`). Closes the biggest "what can I do here" gap. (Seat 1.)
11. **First-run gate banner** above MODES (shown when `L:first-run-complete ≠ true`, key exists per `KERNEL-SLIM.md:486`): "New here? Type `quickstart`, or just type `1` and talk in plain English," including the one-sentence "what is AXON" from `quickstart.md:47`. (Seat 2.)
12. **Tier the expert half visually**: collapse SELF-OBSERVE/META/QUALITY (`menu.md:296-377`) behind a single `system · advanced tools → '5'` line for non-dev users; render the full list only when `dev ≡ true`. Respects Core Rule 12 (still full per active mode) while cutting overload. (Seat 2.)
13. **De-duplicate cross-panel signals**: one home per signal — operational warnings (drift/unread/gaps) in OS STATE only; SELF-IMPROVEMENT shows trends/toggles, not re-printed warnings (`menu.md:187-189 vs 323-330`, `198-199 vs 336-337`, `184 vs 301`). (Seat 1.)
14. **Merge or rename the twin panels** (`menu.md:296` and `317`) to e.g. "QUALITY (run)" vs "SELF-IMPROVEMENT (status)". (Seat 1.)
15. **Decide on `[8]/[9]/[10]`**: register them as real shortcuts in `COMMANDS.md` or change the rendering from `[N]` brackets to a non-shortcut affordance. (Seat 4 #2.)
16. **Surface the curated-subset pointer** in DISCOVER (`menu.md:342-350`): "172 workspace + 29 OS programs — `find-program` or `help <name>` to reach any," so users know the menu is a subset. (Seat 1.)

### P3 — Hygiene / metadata

17. **Correct `inputs-count` (30→45) and `outputs-count` (0→~176)** (`menu.md:10-11`) and add a regression test pinning them; add an `axon-audit` rule failing when declared counts diverge from probe/output counts. (Seat 3, Seat 4 #5.)
18. **Reconcile the two onboarding systems**: surface `tools/onboarding.py`/`programs_registry` philosophy + categories from the menu for first-run, or retire it. Today the better-written beginner narrative is orphaned. (Seat 2.)
19. **Re-sequence quickstart to teach the modes** (modes → plain-English routing → help/explain/simulate → memory → optional build); move compilation/event internals to an advanced appendix. (Seat 2.)
20. **Make bare `help` self-explanatory** (`help.md:21`): print a short "help [program] / find-program / explain" card instead of `EXEC(list-programs)`. (Seat 1, Seat 2.)
21. **Backfill the 7 stub descriptions** or mark them `status: INTERNAL` so they stop returning empty in `find-program`/`help`. (Seat 1.)
22. **Mark tool-commands vs program-commands distinctly** in the menu (small glyph or section note) to kill the consistency smell. (Seat 4.)
23. **Purge `(D-8)`** (`menu.md:292`) and relocate the ~13 PR/provenance comments to a CHANGELOG. (Seat 4 #6/#7.)

---

## 4. Open Questions / Dissent

**Primary inter-seat conflict — do `list-programs` and `dev-new` actually break, or do they resolve cross-layer?**
- **Seat 2** treats `list-programs` (`quickstart.md:77`) and `dev-new` (`quickstart.md:164`) as **broken dead-links** — "a brand-new user following the official tour hits 'No program named list-programs found' on step 1" — and calls bare `help` → `EXEC(list-programs)` a missing-program bounce.
- **Seat 1** explicitly rebuts this: the "dangling suspects (`list-programs`, `new-chat`, `plan-new`) all resolve to the OS layer" (`axon/programs/list-programs.md`, etc.), with cross-layer EXEC order defined at `KERNEL-SLIM.md:734`.
- **Deliberator verification:** `list-programs.md` and `dev-new.md` are **absent from `workspace/programs/` but present in `axon/programs/`** (OS layer). `compile`/`suggest-compile` are **absent from both layers** (Seat 2 is unconditionally correct on those two).
- **Unresolved question:** does the EXEC ORDER resolve an OS-layer program when a bare verb is typed from the workspace/quickstart context? If yes, Seat 1 is right and only `compile`/`suggest-compile` truly break. If the resolver is workspace-scoped (or `quickstart.md` runs in a context that doesn't reach the OS layer), Seat 2 is right and the headline onboarding path fails on step 1. **This must be settled by reading the actual cross-layer EXEC resolution semantics at `KERNEL-SLIM.md:734` / `COMMANDS.md` before acting on recommendation P0-5 and P3-20.** The fix is low-risk either way (point quickstart at workspace-layer `find-program`/`authoring-guide`), but the *severity* rating depends on the answer.

**Secondary — is the count fix "include the OS layer" or "honestly relabel"?**
- **Seat 1** wants `total-progs` to scan **both** dirs (union ≈ 201) so the count reflects everything reachable. **Seat 4** wants it to consume `snap.programs_total` (=172, workspace-only) and fix the dispatch denominator. These imply *different* denominators (201 vs 172). The reconciling answer depends on what `find-program` and the dispatch index actually search: if they remain workspace-only, the honest label is 172 + a pointer to the 29 OS programs (Seat 1's recommendation 5); if they are extended to both layers, 201. The two seats agree the *current* number is wrong but disagree on the target — a design decision, not a fact.

**Tertiary — Core Rule 12 vs. tiering.** Seat 2's P2 recommendation to collapse the expert tier for non-dev users (rec 12) sits against Core Rule 12 (`KERNEL-SLIM.md:73`) forbidding truncation. Seat 2 argues gating on `dev ≡ true` keeps it "full per active mode," but whether that satisfies the no-truncation mandate is a judgment call the kernel owners must make.

**Non-conflict to record:** all four seats agree the *tool backings* are sound (no dead `TOOL()` calls), the snapshot/drift wiring is largely correct, and the defects are at the menu↔reality seam — not in the underlying scripts. No seat disputes the dead boot-key finding, the metadata falseness, or the staleness blindness.

---

*Synthesized by the council deliberator from 4 sealed Round-1 seat opinions (IA, new-user, maintenance, challenger). Claims marked "Deliberator-verified" were independently checked against source; all other claims are attributed to their originating seat(s). Advisory only — no menu/program files were modified in producing this report.*
