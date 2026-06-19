# AXON Report-State Handoff — Synthesis of the Completeness-Gate Council

**Author:** Synthesis Council (Deliberator over eight sealed council reports)
**Date:** 2026-06-19
**Status:** AUTHORITATIVE HANDOFF. Advisory only — no code, programs, or workspace state were modified in producing this document. Read-only verification was performed on the live tree at `/home/arturcastiel/projects/new-axon/axon`.
**Integrates:** `menu.md`, `architecture.md`, `state-machine-compliance.md`, `naming.md`, `job-audit.md`, `state-machine-dag.md`, `non-compliance-gaps.md`, `drift-root-cause.md`.

---

## 0. How to read this document

Eight councils, each a 4-seat advisory body, audited AXON from a different lens. They were run independently and sealed before synthesis. This handoff does four things the individual reports could not: it (1) gives one state-of-AXON verdict, (2) names the themes that recur across reports — the strongest signal in the corpus, because independent councils converged on them, (3) produces a single fix-first backlog so the owner is not reconciling eight separate P0 lists, and (4) takes a position on the drift root-cause question that the drift council deliberately left open.

Where a fact was independently re-verified during this synthesis, it is marked **[V]**.

---

## 1. Overall State-of-AXON Assessment

**AXON is a genuinely strong, unusually self-honest design whose enforcement layer is, in this checkout, almost entirely dormant — and whose dormancy is invisible because the instruments that would reveal it are themselves unplugged.**

That single sentence is the synthesis. Expanded:

**What is real and good (consensus across all eight councils).** AXON is not vaporware and not a thin prompt wearing an OS costume. The councils independently affirmed a substantial, working substrate:

- **One boundary has true mechanical enforcement.** Core Rule 9 (the `axon/` write-gate) is real: a PreToolUse hook denies writes to `axon/`, identity-independent via the git-tracked `.axon-governed` sentinel, fresh-clone-safe, closing the historical `echo x > axon/...` Bash bypass through a single realpath classifier (`tools/_axon_paths.py`). The Architecture, State-Machine-Compliance, Non-Compliance, and Drift councils all cite this as the model of what AXON enforcement *should* be. **[V]** `enforce_pretooluse.py` is wired in `.claude/settings.json`.
- **Registry/disk hygiene is airtight.** The Job-Audit council verified live `registry_drift.py check` → `registered:178 / on_disk:178 / drift:0`; reachability is machine-enforced (`liveness` at BLOCK severity); all 174 programs are structurally wired-checked. Near-zero true rot — the challenger seat found *zero broken jobs*.
- **The deprecation/anti-drift discipline is excellent.** A SSOT tool registry, a parity-locked rule manifest (fixes F38), a path-resolution consolidation (`_axon_paths`), a QUARANTINE ledger, and a de-install manifest all exist and are well-reasoned.
- **The best machinery is genuinely strong.** `phase_model.done()` (deps + on-disk output verification), `workflow_run.advance` (real `WorkflowJumpError` teeth), `session.py` compaction recovery, and the `next_turn_gate.py` gate-on-next-turn pattern are all cited by multiple councils as sound.
- **Rare self-honesty.** Five councils independently quote `KERNEL-SLIM.md:89-95` — the kernel openly states its rules are advisory until hooks + flags are active. This is an asset; it is also, as three councils note, *the tell*.

**What is broken or dormant (also consensus).** The strength is narrow and the enforcement around it is soft:

- **The OS arrives disarmed. [V]** Zero `L:*-required` activation flags exist on disk (`ls workspace/memory/longterm/*required*` → none; the directory holds only host-cap/cognition/host-model state and `dev-mode.md`). Six councils independently rest on this fact. The runtime BLOCK surface collapses to essentially one live rule — `r_coherence`, a ~20-phrase regex blocklist.
- **The flagship "mechanical" gate fails OPEN in CI. [V]** Core Rule 13 (new neurons require tests) — the one rule the kernel elevates to fail-closed pre-merge BLOCK — is defeated by a resolver bug: `changed_files()` (`crucible.py:131`) lacks `2>/dev/null` on its `git rev-parse HEAD~1` clause while `_changeset_base()` (`:155`) has it on both, so on a shallow/single-commit checkout the two functions disagree, the fail-closed guard never fires, and a new untested neuron passes. The unit test that should catch this mocks the defect away.
- **The guard is less protected than what it guards.** `tools/` (the entire enforcement engine) and `.claude/settings.json` (which installs the hook) belong to no layer and are gated by nothing. The dev-mode god-flag that authorizes kernel writes lives in ordinary `L:` memory, ungated. **[V]** `dev-mode.md` sits in `workspace/memory/longterm/`, outside `axon/`.
- **The instruments are blind.** The drift tracker scores "stable" because nothing feeds it `actual` tool sequences; the menu renders stale-green health and an unreachable dispatch bar; the kernel's own version self-model says `v1.1.7` while `VERSION` says `3.8.0` **[V]**.

**The verdict in one line:** AXON has built the right architecture and then left it switched off, uninstrumented, and self-documenting-as-such. The gap between AXON-as-specified and AXON-as-running is the entire finding. The good news — emphasized below — is that the largest share of that gap is closeable with configuration and a handful of small fixes, not a redesign.

**Maturity scorecard (synthesized):**

| Dimension | State | Evidence council |
|---|---|---|
| Architecture / layering | **Strong design, soft center** | architecture |
| `axon/` write-gate (R9) | **Real enforcement** | architecture, non-compliance, drift |
| Runtime rule enforcement | **Dormant (0 flags)** | non-compliance, drift, state-machine-compliance |
| Core Rule 13 (test gate) | **Inert in CI (resolver bug)** | non-compliance |
| Job/registry health | **Excellent (near-zero rot)** | job-audit |
| State-machine compliance | **Specified, 5% observed** | state-machine-compliance |
| Program graph integrity | **Real but cyclic/sparse, unchecked** | state-machine-dag |
| Drift instrumentation | **Unplugged (unfalsifiable)** | drift-root-cause |
| Menu / discoverability | **Strong dashboard, weak index** | menu |
| Naming / policy ownership | **Mechanically clean, policy-unowned** | naming |
| Self-honesty | **Exceptional** | all |

---

## 2. Cross-Cutting Themes (the high-confidence signal)

A finding that one council raised is a hypothesis. A finding that *independent* councils reached from different lenses is close to fact. Seven themes recur across the corpus; they are the spine of the backlog in §3.

### T1 — The OS ships disarmed: prose says HALT, wiring says WARN, flags say OFF. *(7 of 8 councils)*
The single most-corroborated theme. Non-Compliance, Drift, State-Machine-Compliance, Architecture, Menu, and Job-Audit all land on it from different angles. The kernel labels rules `!CRIT` / `HALT` / "cannot be bypassed," but they are wired into the advisory `lint`/`audit` tiers and gated behind `L:*-required` flags **that do not exist on disk [V]**. Core Rule 11 (cognition language — "the kernel's loudest rule") has no BLOCK path *anywhere*. The practical runtime enforcement surface today is `r_coherence` (a phrase regex) plus the R9 write-gate — everything else observes after the fact, on a 1-hour timer, or not at all. *This is a configuration/posture gap, not a code defect — which is why it is also the cheapest to close.*

### T2 — Honesty is not enforcement. *(5 councils, explicit)*
Every council praises `KERNEL-SLIM.md:89-95` and then refuses to let it earn credit. Documenting a load-bearing gap (the dormant flags, the non-existent G1c OS write-barrier, the fail-open CI base, the decorative drift tracker) does not close it. The kernel's integrity is real and rare; it is also a standing invitation to mistake *disclosed* risk for *managed* risk. Several "controls" are asserted-in-comments but absent in code: G1c (no chattr/immutable/`0o444` anywhere), the drift `actual` wire, the `tests:` path-existence check.

### T3 — The seam is where AXON breaks, not the components. *(6 councils)*
Almost nothing AXON builds is itself broken. The failures live at the joins:
- Menu: every `TOOL()` resolves — the rot is the menu↔reality seam (stale counts, stale-green health).
- Drift: `drift.py` computes a correct fail-closed verdict; `r_drift_gate.py:62` *discards* it (`unknown → return None`). The defect is the consumer, not the tool.
- Non-Compliance: `R_NEW_NEEDS_TEST` is well-tested; the *gate that invokes it* fails open on a shallow checkout.
- State-Machine: `phase_model.done()` is excellent; only `code-dev.md` routes through it — the *transition* is not self-gating.
- Naming: `workflow-run --name` is broken because the lookup namespace is disjoint from where workflows live — a seam, not a logic bug.
This theme dictates a remediation style: **fix consumers and joins, audit cross-references; do not rewrite engines.**

### T4 — Model-executed bookkeeping is the load-bearing weakness. *(4 councils, and the crux of the drift verdict)*
AXON routed around model statelessness by putting state in files — then routed its own safeguards back through markdown ops the model must *choose* to run. `turn-count` advances only via `STORE` in the output block (`KERNEL-SLIM.md:137`); `context record` and `drift record` have no automatic caller; the reasoning-trace is written by the audited entity about itself. The faculty compaction degrades is the same faculty the safeguards depend on — the counters freeze exactly when drift is worst. Phase-ledger compliance is the same disease at the program layer: 105 programs take the lock, only 5 record to the ledger.

### T5 — Dual / divergent encodings of one concept. *(5 councils)*
Repeated structural smell: two representations of one thing, allowed to disagree.
- Two `drift` tools with incompatible CLIs; the kernel calls the wrong one (`--type/--detail` hits the parser that wants `--tool` → exit 2, nothing logged).
- Two cognition-frame keys (`L:cognition-frame` + `W:reasoning-mode`) that double loss probability for no redundancy.
- Nine tool files committed in both `tools/` and `workspace/tools/` with multi-week mtime drift (`drift.py` Jun 19 vs May 26 **[V]** confirmed in architecture report).
- Two program populations (174 workspace + 29 `axon/programs/` legacy with zero synapse frontmatter).
- `next-suggests` (UX hint, ~133 edges) vs body `EXEC` (the real transition set, ~159 edges) disagreeing by ~69 edges.
- A static `menu.md` vs an existing auto-generator nothing calls.

### T6 — Marked-for-death but never executed; policy is unowned. *(3 councils, sharply)*
AXON is excellent at *marking* dead things and slow at *removing* them. The QUARANTINE ledger, 8 self-identified `-ALIAS` stubs, 7 autogen-stubs, 3 orphan gate-tools wired into no runner, and a fully-orphaned doc all persist with the removal procedure already written. The same unownership appears in naming (`authoring-guide.md` has no program-naming section — names drift because nothing governs them) and in the registry (no STUB/ALIAS/DEPRECATED status enum, so `-ALIAS` is smuggled into filenames). The missing artifact is not code; it is a *trigger* and an *owner*.

### T7 — Counts and self-models are quietly wrong. *(5 councils)*
The OS misreports itself in small, compounding ways: menu program-count overcounts by 2 (can never read 100%) while ignoring 29 OS programs; `KERNEL-SLIM.md:2` = `v1.1.7` vs `VERSION` = `3.8.0` **[V]**; `host-cap-enforce="self"` is now false (hooks are live); `host-model` says Opus 4.7 while running 4.8; menu synapse metadata claims `inputs-count:30 / outputs-count:0` on the densest output program in the OS. None is individually fatal; together they mean the system cannot be trusted to describe its own state — which is corrosive in an OS whose memory claims to be "the source of truth across harnesses."

---

## 3. Single Prioritized Action Backlog (fix-first ordering)

This merges the eight P0/P1 lists into one sequence. Ordering is by **leverage (impact ÷ change-size) with dependency respected** — enablers that unblock later items come first. Each item names its source council(s) and rationale. Severity tags: **[CRIT]** = correctness/security floor, **[HIGH]**, **[MED]**.

### Tier 0 — Turn the lights on and plug in the meters (cheap, decisive, unblock everything)

| # | Action | Sev | From | Rationale |
|---|--------|-----|------|-----------|
| **A1** | **Wire `drift record` from a real `PostToolUse` interceptor** so `working/drift-trace.json` carries real `actual` sequences. | CRIT | drift | *Do this first.* Until the meter is plugged in, every model-side drift claim is **unfalsifiable** and `drift.py` is decorative. This is the prerequisite for ever answering §4's magnitude question. |
| **A2** | **Flip the activation flags** (`state-surfaced`, `reasoning-trace`, `phase-tracking`, `terminal-outputs`, `workflow-node-order`, `no-orphan-tools` `-required` = true) — step 4 of `scripts/enable-enforcement.sh`, never run. | CRIT | drift, non-compliance, state-machine | Hooks are *installed*; zero flags are *set* **[V]**. This converts ~6 silent rules to live BLOCK with **zero new code** — the single highest-leverage action in the corpus. *Caveat: see A2a.* |
| **A2a** | **Before flipping `terminal-outputs-required`, seed `# emits:` / `outputs:`** — only 5 programs declare `# emits:` and 13/16 real `_phases.json` lack `outputs:`. | HIGH | state-machine | Flipping the flag with no SSOT bites nothing (97% of transitions stay unguarded); seed first so the dormant-but-tested gate has something to enforce. |
| **A3** | **Make counters mechanical:** increment `W:turn-count` in `reanchor_store.py` (UserPromptSubmit) and feed real harness token counts into `context record` from a hook. | HIGH | drift | Re-arms *every* `mod N` cadence check (identity re-anchor, coherence guardian, cognition-drift) and the context-pressure gate at once. Removes the T4 self-defeating loop at its root. |

### Tier 1 — Restore the flagship gate's bite (the one place the kernel promises mechanical enforcement and it does not hold)

| # | Action | Sev | From | Rationale |
|---|--------|-----|------|-----------|
| **B1** | **Collapse `changed_files()` and `_changeset_base()` to one shared base resolver** using `git rev-parse --verify HEAD~1` (fails silently, prints nothing) so the fail-closed guard fires. | CRIT | non-compliance | **[V]** The two functions provably disagree (`:131` lacks `2>/dev/null`, `:155` has it). The duplication *is* the root cause — one resolver can never disagree with itself. |
| **B2** | **Set `fetch-depth: 0` and fetch `origin/main`** in the crucible/test CI jobs. | CRIT | non-compliance | A corrected resolver still needs history to compute a real merge-base; without it the gate can only fail-closed-on-every-PR (too blunt). This is the actual enable-condition for Core Rule 13 in CI. |
| **B3** | **Add a real end-to-end test**: throwaway single-commit repo + new untested `tools/X.py` + `run_changeset(base=None)` with **no monkeypatching**, assert `ok is False`. | HIGH | non-compliance | The existing `test_crucible_failopen.py` mocks the defect away; this is the test that would have caught B1. |
| **B4** | **Close the R13 coverage loopholes** (~5-line fixes): resolve `tests:` paths with `os.path.exists`; tighten `_credible_reference` to require a `test_*` token co-located with the stem; gate `status in {A,R,C}` (not `A`-only); extend `_classify` to addon neurons. Re-point the three tests that currently *enshrine* the bypasses. | HIGH | non-compliance | Even with B1 fixed, the gate today reduces "ship tests" to "type a plausible filename." The bypasses are asserted-as-intended by tests — they must be re-pointed, not just patched. |

### Tier 2 — Protect the guard and the god-flag (security floor)

| # | Action | Sev | From | Rationale |
|---|--------|-----|------|-----------|
| **C1** | **Gate the dev-mode toggle itself.** Deny any Write/Edit/Bash setting `dev-mode=true` without a human-controlled out-of-band token. | CRIT | architecture | **[V]** `dev-mode.md` lives ungated in ordinary `L:` memory. The capability that authorizes kernel writes must not be writable without authorization — *the lock and key are in the same unlocked drawer.* |
| **C2** | **Bring `tools/` and `.claude/settings.json` under protection** — extend `is_axon_path` to an `is_protected_path`, or declare a "Layer 0 — enforcement core" gated identically to `axon/`. | CRIT | architecture, job-audit | A plain Write to `tools/rules/r9_axon_write.py` or `.claude/settings.json` neutralizes R9 globally with no rule firing. The guard must be at least as protected as what it guards. |
| **C3** | **Build G1c or delete the claim.** Implement the OS write-barrier (`chattr +i` / read-only mount) the comments promise, or strike "closed by G1c" from `shell.py`. | HIGH | architecture | A control asserted in comments that the code does not implement is worse than an acknowledged gap (theme T2). |

### Tier 3 — Close the prose↔wiring rule gap and the drift seam

| # | Action | Sev | From | Rationale |
|---|--------|-----|------|-----------|
| **D1** | **Add a meta-rule/test:** every `tools/rules/r_*.py` is registered, and every BLOCK rule *named* in `KERNEL-SLIM.md` resolves to a wired, reachable predicate. Fix or delete the 14 unregistered rule files. | HIGH | architecture, non-compliance | The 14-of-37 unregistered files are "the single most damning fact" (architecture). Never let prose-vs-wiring drift recur silently. |
| **D2** | **Close the drift-gate seam:** make `r_drift_gate.py` treat `unknown` as the fail-closed BLOCK that `drift.py` already returns, OR consciously document it as advisory-by-design. | HIGH | drift | A "stable-by-emptiness" detector manufactures false assurance. *Note: this is the §4 D-decision — bug-fix vs policy reversal — flag for owner (see §5).* |
| **D3** | **Unify the dual `drift` encoding:** fix `KERNEL-SLIM.md:188,341` to call `axon_drift_log.py` (which has `--phrase/--kind`), and add a conformance test asserting every `TOOL(drift,…)` in the kernel parses against the resolved tool's argparse. | HIGH | drift, naming | Persona-bleed is currently detected-in-prose but **never persisted** — `--type/--detail` hits the wrong parser → exit 2. Deterministic failure whenever the coherence guardian fires. |
| **D4** | **Move `R_PHASE_TRACKED` to a biting runner** (add `crucible`), after confirming its N/A path (no `STORE(W:active-program)` → not applicable) is sound. | HIGH | state-machine | 100 of 105 ownership-taking programs violate the ledger contract; `["lint","audit"]`-only guarantees it is never surfaced at a gate that bites. |

### Tier 4 — Execute the deletions and fix the broken front doors

| # | Action | Sev | From | Rationale |
|---|--------|-----|------|-----------|
| **E1** | **Fix the dead `resume` program** — rewrite `resume.md:27-28` to read `W:active-phase` + `session.py` recovery + the *real* event names (`checkpoint`/`restore`); add a contract test that the filtered event names are a subset of emitted names. | HIGH | state-machine | Highest-ROI smallest change in the state-machine report: the user-facing resume front door reports "No interrupted sessions" ~always because it filters on events no writer emits. |
| **E2** | **Run the QUARANTINE prune** (`_reservoir-manifest.md`) and **wire-or-drop the 3 orphan gates** (`axon_io_lint`, `emit_listener_lint`, `domain_validate`). | MED | job-audit | Owner-approved, removal procedure already written; only the trigger is missing (theme T6). A gate nobody runs is worse than no gate. |
| **E3** | **Test or delete the two below-radar drift tools** — `_axon_rollback.py` (a recovery primitive, unregistered + zero tests = highest single risk) and `queue_tool.py` (invoked in 5 files, unregistered). | HIGH | job-audit | An untested *recovery* primitive is the worst-placed gap in the repo. |
| **E4** | **Add a STUB/ALIAS/DEPRECATED status enum + `alias_of`/`supersedes`** to `REGISTRY.json`, then delete the two `-ALIAS` files. | HIGH | naming, job-audit | **This is the naming-report enabler:** once status/alias fields exist, every later rename ships as a backward-compatible alias instead of a breaking change. Today `-ALIAS` is smuggled into filenames because the structural field is missing. |
| **E5** | **Fix `workflow-run --name`** to index canonical workflows by their `name:` field across `domains/*/workflows/` + `workflows/`; namespace the workflow `name:` away from the program name (paired change). | HIGH | naming | `workflow-run --name code-dev` is dead on arrival — a naming-induced bug, not cosmetics. Must migrate together with the namespace change or it stays broken. |

### Tier 5 — Honesty, counts, and self-model reconciliation (free, verifiable today)

| # | Action | Sev | From | Rationale |
|---|--------|-----|------|-----------|
| **F1** | **Reconcile the OS's own documents:** `KERNEL-SLIM.md:2` `v1.1.7 → 3.8.0`; correct `host-cap-enforce="self"` (now false); re-title `.claude/HOOKS-README.md` ("PROPOSAL"); self-heal `host-model` on boot. Add discipline docs to the freshness reconciler. | MED | drift, non-compliance | **[V]** The first file read every session is stale about itself. Free, verifiable, and corrosive to a memory-as-source-of-truth OS (theme T7). |
| **F2** | **Add an audit/CI rule: every command literal in `menu.md` and `quickstart.md` resolves** to a program/tool/help target; fix `total-progs` to consume `snap.programs_total`; surface health-score and dispatch-index staleness. | MED | menu | Catches the whole dead-link + stale-green-dashboard class at once; the menu is the most-edited, most-seen file in the OS. |
| **F3** | **Add a NAMING section to `authoring-guide.md`** (the root cause of all naming drift — there is no program-naming rule today) + a corpus-compliance reporter that scorecards every lint/audit rule across the full corpus. | MED | naming, non-compliance | Prevents regression of the naming drift and makes identity/cognition/phase compliance *measurable in aggregate* for the first time. |
| **F4** | **Generate the program graph** (don't transcribe): run the existing parser + a body-`EXEC` extractor, persist a typed multi-relation graph, add reachability/orphan/cycle checks to `dag_consistency.py`, and fix the 2 self-loop bugs (`quickstart`, `workspace-backup`). | MED | state-machine-dag | Closes the gap between "0 errors" and "~38% of programs isolated"; the cycle check is the one structural property the validator does not enforce. |

**Synthesis note on ordering:** Tier 0 is non-negotiable and must come first — *without A1/A2 the system cannot even tell you whether the other fixes worked.* Tiers 1–2 are the correctness/security floor. Tiers 3–5 are the long tail. A defensible "first sprint" is **A1, A2, A2a, A3, B1, B2, C1, C2** — eight changes, mostly small, that move AXON from "disarmed and blind" to "armed and instrumented," after which the remaining work can be measured rather than guessed.

---

## 4. Drift Root-Cause Verdict — Architecture vs Model vs Process

The drift council was charged not to prematurely converge and honestly did not. The synthesis council is charged to **take a position**, and does:

> **The drift is predominantly PROCESS and ARCHITECTURE, not MODEL. Best synthesized estimate: ~60% architecture/process, ~30% process/configuration, ~10% irreducible model — and the model share is currently *unmeasured and almost certainly over-attributed* because the instrument that would size it records nothing.**

The reasoning, taking a firmer stance than the source report's hedged ~60/40:

1. **The architecture-vs-model dichotomy in the charge is a false binary, and the evidence does not split evenly.** All four drift seats and this council agree the dominant, most-corroborated cause (F-I.1, unanimous) is *instrumentation*: the drift detector reads an empty wire and reports "stable" by construction. That is neither a model limitation nor a deep architectural flaw — it is **an unfinished wiring/process gap**. The second cause (enforcement OFF by default, zero flags **[V]**) is a *configuration* state. The third (doc/self-model rot — `v1.1.7` vs `3.8.0` **[V]**) is *hand-maintained process rot*, authored by humans/tools, explicitly not model cognition. The fourth (dual-encoding mis-dispatch sending persona-bleed logs to the wrong parser) is an *architecture seam*. Four of the five causal layers are non-model.

2. **Where the model genuinely contributes, AXON re-introduced the dependence itself.** The real model-side residue (F-V.1: system prompt decays from "active rules" to "inert text" under compaction; the up-to-5-turn cognition-frame window) is real and irreducible *in principle*. But AXON amplified it by routing its own safeguards back through model-executed ops (T4): turn-count, context-pressure, and drift-trace all advance only if the model chooses to run a markdown op — and that choice is exactly what compaction erodes. So even the "model" share is partly an **architectural decision to trust model bookkeeping**, not a pure model ceiling. A mechanical turn-counter (A3) converts a chunk of the apparent model-cause into a fixed process-cause.

3. **The decisive epistemic point: the model share cannot currently be measured, and unmeasured causes inflate toward the convenient explanation.** The detector that would quantify compaction-driven slip records nothing (F-I.1). "The model can't hold state" is the *unfalsifiable* hypothesis right now; "nobody plugged in the meter" is the *demonstrated* one. Sound epistemics assign the demonstrated cause the larger weight until the meter exists. This is precisely why **A1 (instrument) is the top of the backlog** — it is the prerequisite for ever revising this verdict upward toward "model."

4. **The falsifiable prediction.** If the owner executes Tier 0 (instrument + flip flags + mechanical counters) and drift symptoms substantially subside, the verdict is confirmed: the drift was process/architecture wearing a model costume. If symptoms persist *after* the meters read real data and the counters are mechanical, *then and only then* is the residual genuinely model-side — and the F-V.1 compaction window is the place to look. AXON cannot currently tell these apart; Tier 0 is what makes the question answerable.

**Position stated plainly for the owner:** Do not spend effort hardening against model statelessness yet. AXON already routed around model statelessness with file-backed state; the live drift is overwhelmingly that *the routing is half-finished, switched off, and uninstrumented*. Finish the wiring, flip the flags, mechanize the counters — *then* measure what model-side drift remains. The honest expectation is that it is small.

**Preserved dissent (do not flatten):** Seat 4 of the drift council raised a genuine null hypothesis this council cannot refute — that the heavy 757-line kernel with ≥14 per-turn gates may itself *manufacture* the cognition-frame slips it flags (every ceremony token is attention not spent on the task, and the kernel concedes compaction erodes the frame). *A thinner kernel might drift less.* No data exists either way. This is the one place where "more enforcement" might be the wrong direction, and it is testable: run heavy-ceremony OFF vs ON and compare outcomes. It is logged as an open experiment in §5, not resolved.

---

## 5. Open Decisions for the Owner

These require *intent* the councils cannot read from the tree. They block or shape specific backlog items and should be decided before the corresponding fix lands.

**OD-1 — Default enforcement posture: armed or advisory?** *(blocks A2; raised by drift, non-compliance, architecture)* Is shipping rules labeled `MANDATORY/!CRIT` while disabled-by-default a deliberate "ship dark, enable later" choice, or an oversight? Seat 4 of the drift council argues advisory-first is a legitimate setting (avoid bricking sessions on false positives); Seats 1/3 call the spec-vs-enforcement mismatch a coherence violation. **Decide:** either flip the flags in a governed profile (A2), or soften the kernel prose to match reality and reference `:89-95` inline from Core Rules 6/11/12. You cannot leave the kernel reading two ways about the same rules.

**OD-2 — The drift-gate `unknown` seam: bug or policy?** *(blocks D2)* Is `r_drift_gate.py:62` returning `None` on `unknown` an oversight, or a deliberate "advisory, surface via menu badge" choice (the comment suggests the latter)? This determines whether D2 is a bug-fix (make it fail-closed) or a policy reversal (document it as intended).

**OD-3 — Which relation is the state machine?** *(blocks F4 / completeness-gate scope)* `next-suggests` (the only relation AXON's tooling parses/validates/ranks) or the body-`EXEC` call-graph (the real runtime transitions)? They disagree by ~69 edges. The completeness gate cannot assert "every node reachable" until this is chosen. Synthesis recommendation: type both, gate on `transition`.

**OD-4 — The two shadow populations.** *(blocks F4, T5)* The 29 `axon/programs/` legacy programs (zero synapse frontmatter) and the dead `DAG.json` layer (`dag_files:0`): migrate into the graph, or formally declare out-of-graph? Do not let them be silently merged or silently ignored.

**OD-5 — Grandfather glide-path.** *(shapes B4/E-tier)* ~35–90% of the corpus is grandfathered out of the test requirement. Adopt a named, frozen `test-grandfather.txt` that can only shrink (mirroring `liveness-allow.txt`)? Who owns shrinking it, and to what target?

**OD-6 — `my-axon` symlink + clone fail-open.** *(architecture, drift)* All trust-bearing state is gitignored, so every state-driven gate fails *open* on a fresh clone / CI. Is that acceptable, or should the merge/`*-required` checks fail *closed* (or loudly N/A) when state is absent? Separately: is `my-axon` crossing the repo boundary via an external symlink (with an already-dangling `.venv` sibling) a deliberate scoping choice or portability debt?

**OD-7 — Naming policy decisions** *(block the naming sweep)*: verb-first vs verb-last ordering (OQ-1); bare-verb shadows — rename vs reserve-by-scope (OQ-2); workflow variant separator `.` vs `-` (OQ-3); flat namespace vs physical subdirs for the 87-member `code-dev-*` family (OQ-5). All four are one-time conventions that, once chosen, the NAMING section (F3) freezes.

**OD-8 — The thin-kernel experiment.** *(the §4 dissent)* Will the owner run the heavy-ceremony-OFF-vs-ON comparison? If the heavy apparatus manufactures the slips it flags, the entire "add more enforcement" thrust of this backlog needs re-examination. This is the highest-variance open question — cheap to test, expensive to ignore.

---

## 6. Closing synthesis

AXON is much closer to its own promise than its current running state suggests. The councils did not find a broken architecture — they found a **correct architecture left switched off, uninstrumented, and honestly self-documented as such.** The single most important realization for the owner is that the gap between AXON-as-designed and AXON-as-running is dominated by *configuration and unfinished wiring*, not by deep design error or model limitation. That is the optimistic reading, and it is earned: the first-sprint set in §3 (eight mostly-small changes) moves the system from "disarmed and blind" to "armed and instrumented," after which — for the first time — AXON could *measure* its own compliance and drift instead of asserting them. Do Tier 0 first. Everything else, including the model-vs-architecture question itself, becomes answerable only after the meters are reading real data.

---

*Synthesized by the Synthesis Council from eight sealed council reports. Load-bearing cross-report facts (zero `*-required` flags, the `crucible.py:131/:155` resolver disagreement, `KERNEL-SLIM.md:2` v1.1.7 vs VERSION 3.8.0, ungated `dev-mode.md`, R9 hook installed) were independently re-verified against the live tree on 2026-06-19 and are marked [V]. Advisory only — no code, programs, or workspace state were modified.*
