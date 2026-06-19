# State-Machine Compliance — AXON Advisory Council Report

**Council:** State-Machine Compliance
**Charge:** Assess how well AXON programs and tools comply with the state-machine model — phase tracking, `W:active-phase`, terminal transitions, checkpoint/resume, and the completeness gate. Identify what complies and what does not.
**Status:** ADVISORY ONLY. Findings synthesized from four sealed Round-1 seat opinions, spot-verified against the live repository at `/home/arturcastiel/projects/new-axon/axon`.
**Date:** 2026-06-19

---

## 1. Executive Summary

AXON's state-machine model is **impeccably specified, partially built, and — in the repository's current configuration — operationally dormant.** All four seats converge on the same verdict from four different lenses: the *design* is sound, several individual *engines* are genuinely strong, but the *enforcement surface that actually fires today is a sliver of the program population*, and the *live workspace is itself in an incoherent state that no mechanism detected*.

The single most important fact, confirmed on disk: **every state-machine enforcement rule is fail-OPEN by default, and not one of the five forcing flags exists in the tracked workspace.** `workspace/memory/longterm/` contains only `host-cap-enforce.md`; none of `state-surfaced-required`, `terminal-outputs-required`, `phase-tracking-required`, `workflow-node-order-required`, or `phase-gate-enforce` is present. The "BLOCK-capable" rules are, in this repo's actual state, BLOCK-*incapable*.

Three headline gaps, each independently verified:

- **Phase-ledger contract is 95% unobserved.** Of 105 programs that `STORE(W:active-program)` (take the context lock), only **5** ever call `TOOL(phase-ledger, record, ...)`. The flagship `code-dev.md` is itself a violator (owns at line 41, zero ledger calls). The rule meant to catch this — `R_PHASE_TRACKED` — is wired into the advisory `lint`/`audit` runners only, never `verify` or `crucible`, so the violation is never surfaced at a gate that bites.
- **The completeness gate is a strong lock fitted to a few doors.** `phase_model.done()` is real, output-verifying enforcement — but a phase with no declared `outputs:` is UNGUARDED by design, and 13 of 16 real `_phases.json` manifests carry no `outputs:` field. Only 5 of ~190 programs declare the `# emits:` header that the runtime complement `R_TERMINAL_OUTPUTS` needs. The generic `DONE()` shorthand that 181 programs use performs **no completeness check at all**.
- **Checkpoint/resume has three non-converging mechanisms, and the user-facing front door is dead.** `resume.md` filters `E:session-log` on event names (`session-checkpoint`, `mid-session-checkpoint`, `session-end`, …) that **no writer ever emits** — the only events written are `checkpoint`/`restore`/`session-saved`. The program therefore almost always reports "No interrupted sessions found," and no test guards the contract.

To AXON's credit, the kernel partially confesses this (`KERNEL-SLIM.md:89-95`, the "Enforcement reality" honesty fix), and the genuinely strong machinery — `phase_model.done()`, `workflow_run.advance`, `session.py` compaction recovery, the installed hooks — is real and well-reasoned. The problem is the *other* kernel claims (lines 99, 103, 333-338) that assert mechanical enforcement without the same disclaimer, while the live state proves the discipline is advisory.

**Compliance verdict:** Strong at the *boundary* (DONE/FAIL near-universally stamps a terminal phase, making programs interrupt-safe at exit). Weak in the *middle* (intermediate `:step-N` tracking barely exists; resume is binary start→done). Absent at the *gate* (no flag set; the catch-all rules never block). Compliance is real at the discipline level; mechanical enforcement is, today, dormant.

---

## 2. Detailed Findings (file-cited)

### 2.1 The model as specified

The kernel (`axon/KERNEL-SLIM.md`) defines phase tracking as the spine of resume/interrupt, with three obligations (lines 333-338, 96-106):
- **Per-program phase writes:** `STORE(W:active-phase, "{prog}:start")` on entry, `:step-N` before each side-effect, `:done`/`:failed` at exit, each `+ CHECKPOINT`. Line 338: "This makes `W:active-phase` the always-current resume pointer."
- **Ownership ⇒ phase-ledger:** any program that `STORE(W:active-program)` takes the lock and must record `start`/`step`/`done` into `E:phase-ledger` (`TOOL(phase-ledger, record, ...)`), enforced by `R_PHASE_TRACKED` (G-02 Phase Ledger Integrity).
- **Consumers:** boot resume (lines 660-698) and the interrupt gate (lines 202-258) read `W:active-phase`, split on `:`, and compute progress via `EXTRACT(READ(prog), pattern="^### Step", mode=count)`.

The authoring guide (`workspace/programs/authoring-guide.md:98-151, 244-267`) spells out the full contract correctly, including the `:step-N` requirement. The doctrine is sound; the corpus does not follow it.

### 2.2 What genuinely complies / is strong (all seats concede)

- **Terminal boundary transition is near-universal and free.** The `DONE`/`FAIL` shorthands (`KERNEL-SLIM.md:439-444`) expand to `STORE(W:active-phase, "{id}:done|failed") + CHECKPOINT`. **173/174 programs use `DONE(`; 116 use `FAIL(`.** So the resume pointer reliably lands on a terminal token at exit — even sloppy programs are interrupt-safe at their boundaries. This is the system's real strength.
- **A small set of true exemplars exist.** `workspace/programs/reservoir-review.md` is the gold standard, verified line-by-line: `STORE(W:active-program)` (49) → `:start` + `phase-ledger record start` (50-51) → intermediate `:checklist` (59) / `:render` (93) → `:done` + `phase-ledger record done` (113-114) → `CLEAR(W:active-program)` (115) → `DONE` (116). The full-compliance owners are `reservoir-review`, `authoring-guide`, `autonomy-contract`, `autonomy-reanchor`, and `workflow-run`.
- **`workflow-run.md` has its own, stronger machine.** It does not lean on `W:active-phase`; it uses `phase-ledger` + a run-trajectory store + the deterministic `advance` guard with parent/child sub-trajectory IDs (`workflow-run.md:27-201`, `tools/workflow_run.py:206-289`). `advance` genuinely raises `WorkflowJumpError` on a node-jump — the kernel's "only part of the guard with real teeth" (`:221`), and that is accurate.
- **`phase_model.done()` is the best machinery in the repo.** `tools/phase_model.py:234-253`: a code-dev phase cannot be marked `done` unless (a) deps are `done` (never bypassable) AND (b) declared `outputs:` exist on disk (`_missing_outputs`, 100-110). `--force` bypasses only the output check and is logged loud (245-250, 304-306). Cascade-invalidation (`stale_downstream`, 270-281) is real and called from `code-dev.md`'s `done`/`skip` routes (143-152, 179-188).
- **`session.py` compaction recovery is the architectural high point of resume.** Explicit `VALID_STATES` + `TRANSITIONS` map (`session.py:93-100`), run-id rotation called once per boot before `auto_recover` reads it (`session.py:72-91`, `boot.py:305-312`), legal-transition enforcement (`session.py:183`). Tested (`test_session_auto_recover.py`, `test_session_runid_rotation.py`).
- **The hooks are actually installed.** `.claude/settings.json` wires `verify_stop.py` (Stop), `next_turn_gate.py` (UserPromptSubmit, gate-on-next-turn, can block), `enforce_pretooluse.py` (PreToolUse). The response-gate machinery is live — pending only the flags. `next_turn_gate.py` exit-2 is a clever workaround for "a Stop hook cannot un-send."
- **`code-dev-state-resume.md` is the model resume program:** tracks `W:active-phase` at every boundary (`:start` L41, `:step-1` L62, `:render` L160, `:done` L245 + `CHECKPOINT` L246), calls `session recover` + `checkpoint` (L39-40), ends with an explicit IMMEDIATE NEXT ACTION.
- **Kernel self-honesty.** `KERNEL-SLIM.md:89-95` pre-empts much of the criticism with its "Enforcement reality" disclaimer. The challenger seat explicitly concedes this is more than most repos do.

### 2.3 Phase tracking — weak in the middle, dead at the gate

- **F-PT-1: `R_PHASE_TRACKED` runs in no biting runner.** `tools/rules/manifest.py:55` assigns `r_phase_tracked` to `["lint", "audit"]` only — NOT `verify` (response gate) and NOT `crucible` (merge gate). Its declared `severity = "BLOCK"` (`r_phase_tracked.py:33`) can therefore never block a compile or a merge; with the flag off it only colors an advisory summary (`r_phase_tracked.py:80`, WARN). The rule looks enforced but is structurally toothless. *(Verified: line 55 reads `"r_phase_tracked": ["lint", "audit"]`.)*
- **F-PT-2: 95% of ownership-taking programs violate the ledger contract.** **105 programs `STORE(W:active-program)`; only 5 call `phase-ledger`.** Verified counts. The 100 non-compliant include flagship `code-dev.md` (owns at line 41, zero ledger calls — verified) and the entire `code-dev-*`, `library-dev-*`, `hr-team-*` families. `E:phase-ledger` is near-empty for almost all real execution.
- **F-PT-3: Intermediate `:step-N` writes barely exist.** Only **31 of 174 programs** contain any `STORE(W:active-phase`. At least 16 multi-step programs (with step headers) carry zero phase tracking: `axon-docs-gen, deps, explain, find-program, handoff, memory-compact, meta, mode-detect, mode-router, run-tests, session-summary, simulate, stats, translate, undo, versions`. For ~160 programs `W:active-phase` is effectively **binary** — `:start`/bare → straight to `:done` — so an interrupt mid-run resumes at "start," redoing completed work. The mid-program granularity promised by `KERNEL-SLIM.md:335, 668-672` does not exist for them.
- **F-PT-4: The progress-math regex is miscalibrated to the corpus.** Boot (line 665) and the interrupt gate (line 209) count steps with `pattern="^### Step"`. Verified casings: **18** use `### Step`, **17** use `## STEP`, **1** uses `### STEP`, **5** use `## PHASE`. The regex matches only the 18; for the other ~40 multi-step programs it returns `∅`, so "Step N of M — X% complete" silently degrades to the bare "at phase: {step}" fallback. The headline progress UX misfires on more programs than it hits.
- **F-PT-5: Two parallel, unreconciled phase systems.** `W:active-phase` (string in `working/active-phase.md`, read by boot/interrupt/`R_STATE_SURFACED`) and `E:phase-ledger` (append-only log, read by `R_PHASE_TRACKED`) are independent. A program can satisfy one and violate the other; `code-dev` writes neither. No rule asserts the two agree.

### 2.4 Terminal transitions & the completeness gate — three layers, real code, narrow bite

There are **three distinct completeness gates** at three scopes (Seat 2's key clarification — council members may conflate them):

1. **L2 phase-ladder gate** — `phase_model.done()` (`tools/phase_model.py:234-253`). Deps + on-disk outputs. The one actually on the `code-dev done` path.
2. **ADR-004 closing-artifact gate** — `phase_gate.check()` (`tools/phase_gate.py:129-159`), with stub-detection (`_is_stub`, 110-126). Warn-only unless `L:phase-gate-enforce=true` (77-78). Wired only into `code-dev-phase-new.md:53-59` as a *predecessor* pre-check — despite its own docstring claiming "the phase being CLOSED" (`phase_gate.py:14`).
3. **RUNTIME terminal-outputs gate** — `tools/rules/r_terminal_outputs.py`. Any program reaching `:done` in `W:active-phase` must have its `# emits:` artifacts on disk, else BLOCK. Registered in the `verify` runner (`manifest.py:38`) — so it *does* run in the response gate — but silent until `terminal-outputs-required=true` (`:65-66`).

The workflow analogue is `workflow_run.NodeOutputsNotCompletedError` (`tools/workflow_run.py:46-55, 275-282`).

- **F-CG-1: The generic terminal transition is completeness-blind.** `DONE(id)` (`KERNEL-SLIM.md:439`) expands to `STORE(:done) + CHECKPOINT + COMPLETE + LOG + CLEAR` — **no output check.** 181 programs use `DONE(`. The only backstop is `R_TERMINAL_OUTPUTS`, which is OFF and only fires for programs declaring `# emits:`. The `code-dev done` route is safe *only because it manually routes through `phase-model` first* — a property of one program, not of the transition.
- **F-CG-2: Coverage is a sliver.** Only **5 of ~190 programs declare `# emits:`** (verified). Even if every flag were flipped ON, ~97% of terminal transitions would still pass unguarded (no emits header → "unguarded, safe default", `r_terminal_outputs.py:77`).
- **F-CG-3: The completeness gate is unadopted on 81% of real projects.** Of **16 `_phases.json` in `my-axon/dev-projects/`, only 3 carry an `outputs:` field**; a phase with no `outputs` key is UNGUARDED by design (`phase_model.py:64-67`). `seed_outputs()` exists (`phase_model.py:72`) but is not seeding manifests at creation. The gate is a strong lock fitted to 3 of 16 doors.
- **F-CG-4: `R_TERMINAL_OUTPUTS` fails open through three independent hatches** — flag set (absent), `# emits:` present (else unguarded), `code_dev_project_dir` resolves (`r_terminal_outputs.py:65, 76-77, 79-80`). Any one missing → `None`.
- **F-CG-5: The empty-`W:active-phase` hole.** A program that yields mid-task without ever stamping a phase leaves `W:active-phase ≡ ∅` — indistinguishable from "clean." The kernel admits this (`:443-444`: safety holds "only for any program that uses DONE/FAIL correctly"). No mechanical check verifies a program reaching its end actually stamped a terminal.

### 2.5 Node-order / rigid traversal — a real gate scanning an empty set

- **F-NO-1: `R_WORKFLOW_NODE_ORDER` is wired into crucible but scans zero files in normal operation.** `tools/crucible.py:185-202` imports and runs it (kernel's "merge gate" claim is structurally honest). But it is **changeset-scoped** (`r_workflow_node_order.py:68-78`) and **all 16 `_phases.json` live under `my-axon/` — a symlink, with 0 tracked in `axon.git`** (verified: `git ls-files | grep -c _phases.json` = 0). A `_phases.json` essentially never enters the changeset it scans. And the BLOCK flag `workflow-node-order-required.md` is absent (`:33-48`), so it would WARN regardless. Real code, empty set, no teeth in this config.
- **F-NO-2: The one piece with teeth governs a 4-file surface.** `workflow_run.advance` (`tools/workflow_run.py:206-289`) genuinely raises `WorkflowJumpError`, but governs only the 4 YAML workflows in `workspace/domains/*/workflows/*.yml`. The dominant surface — 174 markdown programs — bypasses it entirely and has no node-jump guard.

### 2.6 Checkpoint / resume — three non-converging mechanisms, broken front door

Three mechanisms that **share no store**: (1) `tools/checkpoint.py` (W: snapshot to `.snapshots/<label>.json`, events `checkpoint`/`restore`); (2) `tools/session.py` (per-chat `_session.md` state machine for code-dev); (3) `tools/session_save.py` (L: snapshot for cross-reboot restore). None touch `W:active-phase`.

- **F-CR-1: `resume.md` is effectively dead.** `workspace/programs/resume.md:27-28` (verified) filters `interrupted` on `event="session-checkpoint" OR "mid-session-checkpoint"` and `completed` on `"session-end"/"session-complete"/"boot-complete"`. The **only** events any writer emits are `checkpoint`, `restore`, `session-saved`, `memory-compacted`, `tool-registered`, `session-summary-saved` (verified — none match). `COUNT(interrupted)` is always 0; the program always reports "No interrupted sessions found." **No test guards this contract** — the only hits for those event strings are inside `resume.md` itself.
- **F-CR-2: Two resume front doors, neither converges with the canonical pointer.** Boot's resume UI reads `W:active-phase` (`KERNEL-SLIM.md:660`); the `resume` *program* reads `E:session-log` (wrong names); `code-dev resume` reads `_session.md`. A user told "run: resume" after a context-pressure halt (`KERNEL-SLIM.md:323`) lands in the broken `resume.md`, not the boot path that actually holds their checkpoint.
- **F-CR-3: `code-dev-state-save.md` has an unsatisfiable precondition.** Line 15 (verified literally): `... AND DIR-EXISTS(snap-dir) AND ... AND NOT DIR-EXISTS(snap-dir)` — `X AND ¬X`. It also never writes `W:active-phase` for its own steps, so a mid-`tag`/`rewind` interrupt is invisible to the boot pointer.
- **F-CR-4: phase-gate's own documented resume-bypass is unmitigated.** `phase_gate.py:6-12` lists bypass (b) "code-dev-resume from a checkpoint predating the plan." `code-dev-state-resume.md` never invokes `phase-gate` (no reference in the file). phase-gate is wired only into `code-dev-phase-new.md:53`, warn-only by default. Resuming onto a stale checkpoint can still skip the completeness gate exactly as the tool's header warns.
- **F-CR-5: `session_save.py restore` is never auto-invoked.** Boot only *reads* a summary of the L: snapshot (`boot.py:174-198`, "without restoring"). No program in `workspace/programs/` calls `session-save restore`. The captured W: state is surfaced but not reinstated on reboot.

### 2.7 The live workspace is itself incoherent — and nothing detected it

- **F-LIVE-1: All five `L:*-required` flags absent on disk** (verified: `workspace/memory/longterm/` holds only `host-cap-enforce.md`). Every state-machine rule is fail-OPEN right now.
- **F-LIVE-2: `active-phase` ↔ `active-program` divergence.** Verified live: `working/active-phase.md` = `code-dev-plan:wave-g` while `active-program.md` = `code-dev-study` — two *different* programs, a non-terminal phase sitting active. `KERNEL-SLIM.md:338` calls `W:active-phase` "the always-current resume pointer," yet it points at one program while the register names another. A resume from this state would mislead. **No `R_PHASE_PROGRAM_COHERENT` rule exists**, so nothing detected or corrected the drift. This is the strongest single piece of evidence that the discipline is advisory: the exact bug the state model exists to prevent is live and unflagged.
- **F-LIVE-3: The manifest is a "mirror," not the source.** `manifest.py:8-13` openly states the four runner lists "are disjoint … adding a rule means editing up to 4 lists and forgetting one silently drops it," and that migrating runners to actually call `rules_for_runner()` "is the follow-up; today it is the authoritative mirror." Until then, "parity-locked" means "a test turns red," not "the rule runs."

---

## 3. Prioritized Recommendations

Ordered by leverage (impact ÷ effort). Items 1-3 are high-leverage and low-cost.

1. **Fix the dead `resume` program (highest ROI, smallest change).** Rewrite `resume.md:27-28` to read the real surfaces: `W:active-phase` (canonical pointer) + `session.py auto-recover`/`list` + the *actual* event names (`checkpoint`/`restore`). Add a one-line contract test asserting the names `resume.md` filters on are a subset of names some writer emits. *(Seats 3, 4.)*

2. **Decide the flags-vs-claims question.** Either set the forcing flags (`memory.py set --scope L --key {state-surfaced,terminal-outputs,phase-tracking}-required true`) or give `KERNEL-SLIM.md:99,103,333-338` the same "advisory until flag+hook" disclaimer the kernel already carries at `:89-95`. Today the kernel reads two ways about the same rules. *(Seats 2, 4.)* If flags are turned on, **drive `# emits:` adoption first** (only 5 programs declare it) so the gate has something to bite — flipping `terminal-outputs-required` converts dormant, tested infrastructure into live enforcement with no new code, but only where the SSOT exists.

3. **Move `R_PHASE_TRACKED` to a biting runner, or grandfather honestly.** It governs a contract 100/105 programs violate; `["lint","audit"]`-only (`manifest.py:55`) guarantees the violation is never surfaced at a gate. A one-line manifest edit to add it to `crucible` makes the parity test (`test_rules_manifest`) force the lists to match, and makes a new ownership-program-without-ledger fail at merge. *(Seats 1, 4.)*

4. **Add an `active-phase ↔ active-program` coherence rule.** The live divergence (F-LIVE-2) is precisely the bug the state model exists to prevent, and nothing catches it. A trivial RUNTIME rule comparing the two registers would have flagged the current workspace. *(Seat 4.)*

5. **Make the generic terminal transition self-gating.** Have `DONE(id)` consult `R_TERMINAL_OUTPUTS`-equivalent logic inline (or have the response gate run it unconditionally when `W:active-phase` ends `:done` and the program has `# emits:`), so completeness is a property of the *transition*, not of one program's hand-wiring. Today only `code-dev.md` routes through `phase-model`; nothing guarantees the next author will. *(Seat 2.)* Pair with a **terminal-stamp obligation check**: any program that `STORE(W:active-program)` must reach `DONE(...)`/`FAIL(...)` on every exit path, closing the `W:active-phase ≡ ∅` ambiguity. *(Seat 2.)*

6. **Normalize step headings** (or widen the regex). Migrate `## STEP`/`## PHASE`/`### STEP` → `### Step`, or widen boot/interrupt `EXTRACT` to `^#{2,3}\s*(Step|STEP|Phase|PHASE)` (`KERNEL-SLIM.md:209, 665`). Until then progress % is unreliable for ~40 programs. *(Seat 1.)*

7. **Seed `outputs:` into manifests at project creation.** `phase_model.seed_outputs()` exists (`:72`) but 13/16 real manifests lack the field, making the completeness gate a no-op for 81% of projects. Make `code-dev-new`/`code-dev-init` always seed it. *(Seat 4.)*

8. **Retrofit the highest-value owners with the two-line ledger pattern** from `reservoir-review.md:51,114` — starting with `code-dev.md` and the ~10 long-running multi-turn programs where resume actually matters. Add intermediate `:step-N` writes to those same programs; binary start→done tracking defeats the resume promise for exactly the programs that take longest. *(Seats 1, 3.)*

9. **Unify resume behind one facade.** Boot's resume UI and the `resume` program should read the same union of (a) `W:active-phase`, (b) `session.py` recovered sessions, (c) L: snapshot presence. Also wire `phase-gate check` into `code-dev-state-resume.md` to close documented bypass (b). *(Seats 3, 4.)*

10. **Clarify or collapse the two code-dev phase systems.** Document `phase_model.done()` as *the* phase-closing gate and `phase_gate.py` as the *predecessor pre-check* (its actual role); fix `phase_gate.py:14`'s misleading "the phase being CLOSED" docstring. *(Seats 2, 3.)*

11. **Fix `code-dev-state-save.md:15`** precondition contradiction (drop the trailing `AND NOT DIR-EXISTS(snap-dir)` for non-create subcommands, or split preconditions per subcommand). *(Seat 3.)*

12. **Make the manifest the source, not a mirror.** Until `crucible`/`verify`/`lint`/`audit` actually call `rules_for_runner()` (`manifest.py:11-13`), parity is a red test, not a running rule. *(Seat 4.)*

---

## 4. Open Questions / Dissent

The four seats are **strongly convergent** — there is no factual contradiction among them. Every shared count cross-verifies (105 owners, 5 ledger callers, 5 `# emits:` headers, flags absent, live incoherence, 0 git-tracked `_phases.json`). What follows are points of *emphasis difference*, minor numeric discrepancies, and genuinely open design questions.

**Differences of emphasis (not disagreement):**
- **Which mechanism is "the" completeness gate?** Seat 2 insists there are *three* gates at three scopes and warns the council against conflating them — `phase_model.done()` is the closing gate, `phase_gate.py` is only a predecessor pre-check despite its docstring. Seats 3 and 4 treat `phase_model.done()` as the primary gate but note `phase_gate`'s unmitigated resume bypass. These are complementary, not conflicting; Seat 2's three-layer framing is adopted as the canonical decomposition in §2.4.
- **How fatal is the dormancy?** Seat 1 rates impact "medium" precisely *because* the flags are off — the violations are latent, not currently firing. Seat 4 (challenger) argues the live incoherence (F-LIVE-2) proves the latent risk is already realized in practice. Both are correct: the violations don't fire a gate, but the live workspace shows the discipline alone does not hold.

**Minor numeric discrepancies (do not affect conclusions):**
- **Owner-program denominator.** Seats 1 and 4 cite 105 owners (verified here); Seat 2 cites 112; Seat 3 counts 31 programs with `STORE(W:active-phase` against 172 total. The differences are grep-pattern/whitespace variants. The *ratio* — ~5 compliant owners against ~100+ violators — is robust across all framings. Verified denominators: 174 total program files, 105 `STORE(W:active-program)`, 31 `STORE(W:active-phase`, 5 `phase-ledger`, 5 `# emits:`.
- **Program total.** "~190 programs" (Seat 2) vs "174 markdown programs" (Seats 1, 4) vs "172" (Seat 3). Verified: **174** `.md` files in `workspace/programs/`. The higher figure likely counts non-`.md` or sub-directory entries.
- **`## Phase` casing.** Seat 1 reports "5 use `## Phase`"; verification shows 5 use `## PHASE` (uppercase) and 0 use `## Phase` (title-case). The count (5) and the conclusion (the `^### Step` regex misses them) stand.
- **`R_TERMINAL_OUTPUTS` runner membership.** Seat 2 correctly notes it runs in `verify` (the response gate) — verified at `manifest.py:38`. Seat 4's phrasing emphasizes it is "dormant regardless" because the flag is absent. Both are right: it is registered and *runs*, but returns `None` (silent) until the flag is set. The §2.4 text reflects the precise state: registered + running + flag-silent.

**Genuinely open questions for the synthesizer / project owner:**
1. **Is dormancy intentional staging or unfinished work?** The manifest comment (`manifest.py:11-13`) frames the runner-mirror as a known follow-up. Are the absent flags a deliberate "ship dark, enable later" posture, or an oversight? The recommendation in §3.2 (flags-vs-claims) hinges on this answer.
2. **Should `W:active-phase` or `E:session-log` be the single canonical resume source?** All seats agree the two-front-door split is a footgun, but do not agree on *which* to keep. Seat 3 leans `W:active-phase` (kernel-canonical); Seat 4 says "pick one" without preference. This is a design decision the council should resolve before §3.9 is actioned.
3. **Is the `my-axon` symlink boundary a deliberate scoping choice?** Seat 4's F-NO-1 shows `R_WORKFLOW_NODE_ORDER` scans an empty set because real `_phases.json` live outside `axon.git`. Is the intent that dev-project manifests should *never* be crucible-scanned (so the gate is correctly out-of-scope), or should crucible reach into `my-axon`? The "empty set" finding is either a bug or a non-issue depending on intent.
4. **Does enforcing `R_PHASE_TRACKED` at merge risk blocking legitimate non-owner programs?** Recommendation §3.3 assumes the rule cleanly partitions owners from non-owners. Before flipping it to `crucible`, confirm the rule's N/A path (no `STORE(W:active-program)` → not applicable) is sound, or the 69 non-owner programs could see spurious blocks.

---

*Prepared by the State-Machine Compliance council Deliberator, synthesizing four sealed seat opinions (Phase-Tracking, Terminal-Transition/Completeness, Resume/Checkpoint, Challenger). All quantitative claims spot-verified against the repository on 2026-06-19. ADVISORY ONLY — no code or workspace state was modified.*
