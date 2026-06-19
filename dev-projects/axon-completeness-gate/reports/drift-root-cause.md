# Why AXON Drifts — Heavy Root-Cause Report

**Council:** AXON Advisory Council (full-form, 4 sealed seats + deliberator)
**Charge:** Heavy root-cause analysis — why does AXON drift (trackers diverge from ground truth, state goes stale, persona / cognition-frame slips)? Is this an ARCHITECTURE flaw or a MODEL limitation? Enumerate ALL possibilities with evidence, mechanism, and likelihood; do not prematurely converge.
**Status:** Round-1 synthesis. Advisory only. Read-only investigation of the live tree.
**Date:** 2026-06-19

---

## 1. Executive Summary

AXON drift is **not one failure; it is a layered stack of independent failures** that happen to produce the same symptom (trackers diverge, state goes stale, persona slips). The four seats investigated the real repo read-only and converged on a striking, non-trivial conclusion: **the architecture-vs-model dichotomy in the charge is a false binary.** The drift is real, but its dominant causes are neither "the model can't keep state" nor "the architecture is broken by design" in the simple sense — they are, in descending order of evidentiary weight:

1. **Uninstrumented detectors.** The flagship drift tracker (`tools/drift.py`) is fed by a `record` call that **almost nothing in the codebase invokes**. Its state file does not exist in the live workspace. Empty `actual` sequence → score `0.0` → "stable" *by construction* (`tools/drift.py:116`). Much of what looks like "drift" is an instrument reading an empty wire. **(All four seats independently confirmed this — the single most-corroborated finding in the council.)**

2. **Self-report-driven safeguards that decay with the model.** Turn-count, context-pressure, and the drift trace are all advanced by **markdown ops the model must choose to execute** (e.g. `STORE(W:turn-count, turn + 1)` at `KERNEL-SLIM.md:137`). The faculty that compaction degrades is the same faculty the safeguards depend on. Under context pressure the counters freeze *exactly when drift is worst* — a self-defeating loop.

3. **Enforcement that is OFF by design.** Every substantive runtime rule is gated behind an opt-in `L:*-required` flag. **Zero such flag files exist on disk** (verified: `ls workspace/memory/longterm/*required*` → none). The hooks are installed but the activation flags were never flipped (`scripts/enable-enforcement.sh` step 4, never executed). "AXON drifts in default mode" largely means "AXON was configured advisory."

4. **Hand-maintained doc / self-model rot.** The clearest, ground-truth-checkable divergences in the whole repo are in the OS's own documents: `VERSION` = `3.8.0` but `KERNEL-SLIM.md:2` still declares `AXON v1.1.7` (verified). Capability self-model (`host-cap-enforce="self"`) is now false because hooks are live. This is documentation drift (the repo's own taxonomy: `AXON-DOCS-FAILURE-MODES.md` Class F), authored by humans/tools — not model cognition.

5. **A narrow, real, compaction-driven model-consistency window.** `KERNEL-SLIM.md:168` admits compaction can clear `L:cognition-frame` mid-loop, and re-assertion fires only every 5th turn (`:167`) — leaving a genuine window where persona/cognition-frame slip is a true model-side phenomenon nothing on disk can fully fix. **This is the irreducible residue.** Its severity is *unquantified* precisely because of cause #1 (the detector records nothing).

**Probability-weighted verdict:** The drift is **~60% architecture/process (causes 1–4) and ~40% model (cause 5 plus the amplification of model self-report dependence)** — but the two clean dichotomies the charge offers both overclaim. The honest framing is: *AXON routed around model statelessness by putting state in files, then re-introduced model dependence by routing its own safeguards through model-executed ops and leaving enforcement off by default.* Even a flawless model would let trackers go stale here, because nothing **feeds** them. A weaker model amplifies it, because the un-enforced per-turn loop is exactly where capability variance shows.

---

## 2. Detailed Findings (file-cited)

Findings are organized by causal layer. Each carries mechanism, evidence, likelihood, and the seat(s) that raised it. **[★]** marks claims the deliberator independently re-verified against the live tree during synthesis.

### Layer I — The detector is structurally blind (instrumentation drift)

**F-I.1 — No auto-recording of the `actual` tool sequence. (CRITICAL)** **[★]**
`tools/drift.py` scores drift as edit-distance (real Levenshtein) between an `expected` sequence statically extracted from the program (`extract_expected`, ~lines 69-87) and an `actual` sequence that must be appended one call at a time via `drift record --tool X` (`cmd_record`, ~lines 165-181). **Nothing appends to `actual`.** Grep across `workspace/programs/`, `axon/`, and `tools/hooks/` finds no program/hook caller; only three files reference `drift record` at all — `KERNEL-SLIM.md` (the spec), `compiler/GRAMMAR.md`, and `code-dev-journal-log.md`. No `PostToolUse` hook records calls. **Verified:** `tools/drift.py:116` is `if not actual:` → returns `0.0`. Empty actual → score `0.0` → `classify` → `"stable"`. **The detector reports "stable" precisely because it has no data.** The live trace file does not exist on disk.
*Mechanism:* the tracker has no wire to ground truth. *Likelihood as a driver of perceived drift:* **near-certain / HIGH.** *Seats:* 1 (A1), 2 (F2), 3 (F1), 4 (Thesis A) — **unanimous.**

**F-I.2 — The fail-closed gate is discarded fail-OPEN at the real chokepoint. (CRITICAL)** **[★]**
`tools/drift.py` was deliberately hardened (PR-AUTO-213): missing / unparseable / stale trace → `_unknown_gate` returns `decision="halt", modifier=-50`. But the rule that actually gates output, `tools/rules/r_drift_gate.py`, inverts this. **Verified** (`r_drift_gate.py:62-63`):
```
if drift_state == "unknown":
    return None        # ← no Violation, render proceeds
```
Only `"diverged"` (score ≥ 0.40, positive evidence) BLOCKs. `"unknown"` — exactly the missing/stale case F-I.1 guarantees — returns `None`. The carefully-built fail-closed payload is thrown away at the consumer. Combined with F-I.1, **the drift gate can never fire in ordinary operation.** The comment at `r_drift_gate.py:58-61` rationalizes this as "the menu badge surfaces it to the user" — i.e. it is *advisory*, not blocking.
*Likelihood:* **near-certain** to permit stale-state passage. *Seats:* 1 (A2); corroborated by 4 (the fail-closed halt is a *measurement artifact* the council could misread as "drift detected").

**Tension to note:** Seat 2 (F3) calls the same fail-closed staleness logic in `drift.py` a **strength** ("where the architecture assumes the model forgot, it is robust"). Seat 1 (A2) calls its *discard at the rule layer* a critical flaw. **Both are right:** the tool computes a correct fail-closed verdict; the rule layer drops it. The defect is the *seam*, not the tool.

### Layer II — Safeguards routed through model self-report (the self-defeating loop)

**F-II.1 — turn-count is advanced only by a model-executed op. (CRITICAL)** **[★]**
`KERNEL-SLIM.md:137` — `turn ← RETRIEVE(W:turn-count) | 1; STORE(W:turn-count, turn + 1)` — lives inside the output-layer ops block. **Verified:** nothing in `boot.py` or any hook increments it mechanically; `reanchor_store.py` re-stores the prompt but does not bump turn-count. Every cadence check keys off this counter: mid-loop identity `mod 5` (`:167`), coherence guardian `mod 10` (`:192`), cognition-drift `mod 5`. If a compacted model skips the output-layer block, **the counter freezes** and every `mod N` drift check silently dies — precisely when drift is worst. Seat 3 found the live value at `2`, almost certainly undercounting a real session.
*Mechanism:* the cadence that re-anchors persona only trips when the counter advances, but advancing it is the same forgettable discipline that drifts. *Likelihood:* **HIGH.** *Seats:* 2 (F2/crux), 3 (F4) — independently identified as the decisive model-cause finding.

**F-II.2 — context-pressure gate measures a self-reported fiction. (HIGH)**
`KERNEL-SLIM.md:317-331` calls `TOOL(context, status)`; `tools/context.py status` returns `accumulated` only from prior `context record` calls (~lines 245-267). No automatic caller of `context record` exists in `KERNEL-SLIM.md`, `BOOT.md`, or `boot.py`. So `accumulated` stays `0` unless the model manually records every token — which it cannot reliably do. The gate reports "low" right up until real compaction hits, and `context.py:18-26` admits the window limit can be wrong by ~2× (gpt-4o/claude-4 mismatch). *Likelihood:* **HIGH.** *Seat:* 2 (F2/crux).

**F-II.3 — drift-trace ground truth is the model's own honesty. (HIGH)**
Even if `drift record` were wired, the `actual` sequence is whatever the model self-reports. A model under context pressure forgets to record → `actual` undercounts → edit-distance stays artificially low → "stable" while execution has diverged. The tracker's ground truth is the model's honesty, which compaction erodes. *Seat:* 2 (F2); consistent with Layer I.

**F-II.4 — reasoning-trace is self-reported by the audited entity, with no teeth. (MEDIUM-HIGH)**
Core Rule 11 requires `STORE(W:reasoning-trace, {ops})` first every turn. `tools/rules/r_reasoning_trace.py` checks it but defaults to **WARN** (because `reasoning-trace-required` is unset), and per `tools/verify.py:181-184` (F15/F16) **a WARN never fails the gate.** So the cognition-frame audit trail is (a) written by the model about itself, (b) checked post-hoc, (c) non-blocking. The entity that has drifted out of kernel-op framing is exactly the one that won't write the trace proving it. *Seat:* 3 (F6).

### Layer III — Dual encodings and mis-dispatch (schema drift)

**F-III.1 — Two unrelated "drift" tools; the kernel calls the wrong one. (HIGH)** **[★]**
Two tools share the name "drift" with incompatible CLIs:
- `tools/drift.py record` accepts only `--tool` (sequence tracker; store `working/drift-trace.json`). **Verified:** argparse defines `--tool`, no `--type`/`--detail`.
- `tools/axon_drift_log.py record` accepts `--phrase --source [--kind]` (persona/cognition violations; store `log/drift/YYYY-MM-DD.jsonl`).

**Verified:** `KERNEL-SLIM.md:188` and `:341` emit `TOOL(drift, record --type persona-bleed --detail "...")`. `drift` resolves to `tools/drift.py` in `workspace/programs/REGISTRY.json`. So `--type/--detail` hit a parser that accepts neither → **argparse error, exit 2, nothing recorded.** Every persona-bleed / cognition-frame detection the kernel claims to log is dropped on the floor; even if it parsed it would write to the *sequence* tracker, not the *violation* log the gate/summary reads.
*Mechanism:* dual-encoding of one concept with no shared schema; the kernel author conflated them. *Likelihood:* **HIGH — deterministic failure whenever the coherence guardian fires.** *Seat:* 1 (A3). This is "dual-encoding drift" in its purest form and directly explains why persona slips are detected-in-prose but never persisted.

**F-III.2 — Multiple sources of truth for registries / docs. (MEDIUM)**
Two distinct `REGISTRY.json` files exist (`tools/REGISTRY.json` reconciled by `registry_drift.py:41`; `workspace/programs/REGISTRY.json` for dispatch). The freshness thesis (`tools/freshness.py:1-15`, "every artifact is a derived, drift-checked projection of a source of truth") is sound, but it multiplies derived copies (AXON-DOCS.md, counts, anchors) that drift between weekly cron runs. *Likelihood:* **MEDIUM,** bounded by cron cadence. *Seat:* 1 (A7).

### Layer IV — Enforcement off by design / gitignored trust surface

**F-IV.1 — All per-rule enforcement flags are OFF; hooks installed, not activated. (HIGH)** **[★]**
`tools/verify.py load_state` gates every substantive rule (`R_STATE_SURFACED`, `R_REASONING_TRACE`, `R_PROJECT_ANCHOR`, `R_TOOL_RECEIPTS`, `R_ADVERSARY_SCAN`, `R_GROUNDED_CLAIMS`, `R_MENU_RENDER`, `R_TERMINAL_OUTPUTS`) behind an opt-in `L:*-required` flag. **Verified:** `ls workspace/memory/longterm/*required*` returns nothing — **every flag defaults OFF.** The hooks WERE installed (`.claude/settings.json`, Jun 18) but `scripts/enable-enforcement.sh` step 4 ("flip the activation flags") was never run. `KERNEL-SLIM.md:89-95` documents this exactly: "the response gate runs by AGENT DISCIPLINE (advisory), not mechanically… Do NOT read 'enforced' as 'cannot be bypassed.'" *Likelihood:* **HIGH.** *Seats:* 3 (F2), 4 (Thesis B) — agree this is the highest-leverage *cheap* fix.

**F-IV.2 — All trust-bearing state is gitignored; gates fail open on fresh clone / CI. (HIGH)**
`.gitignore` excludes the entire trust surface: `workspace/memory/working/`, `…/longterm/`, `…/kv-store/`, `…/episodic/`, `goals.yml`, and `axon/state/`. `tools/verify.py:291-293` admits it in its own words: "this is a LOCAL tree-state gate (load_state reads workspace/memory/working/, which is gitignored). On a fresh clone / CI that state is absent and the carried rules fail open." L:/W: cognition frame, drift verdicts, phase ledger, goals — the inputs to every gate — live only in untracked, per-machine, mutable files. **There is no ground-truth-of-record; ground truth is whatever the last writer left in a gitignored file.** State *is* the drift surface. *Likelihood:* **HIGH** for stale/divergent state; **certain** for the CI/clone blind spot. *Seat:* 1 (A4).

**F-IV.3 — The response gate is post-render and advisory; persona gate is one-turn-late. (HIGH for persona-slip)**
`KERNEL-SLIM.md:89-94` admits runtime rules "bite mechanically ONLY when a host hook runs `verify.py output` every turn." Even with the Stop hook installed, `verify_stop.py:7-9` is **LOG-ONLY and always exits 0** ("a Stop hook cannot un-send"). `R_COHERENCE` (`tools/rules/r_coherence.py`) is genuinely always-on BLOCK — but runs at Stop, after the message composes, and downgrades to "gate-on-next-turn" (`next_turn_gate.py`): the bleed ships, then the *next* turn halts. Worse, it is a **~25-phrase regex blocklist** ("as an AI", "I think", "AXON will") — blind to *semantic* assistant-frame slip that uses none of those phrases. **The cognition-frame slip in the charge is precisely the case regex cannot see.** *Seats:* 1 (A5), 3 (F3).

### Layer V — The irreducible model residue

**F-V.1 — System prompt decays from "active rules" to "inert text." (HIGH — the real model limit)**
`workspace/programs/axon-reanchor.md` header: "on harnesses without per-turn hooks… the system prompt decays from 'active rules' to 'inert text' as context compresses." `KERNEL-SLIM.md:164-172` (G-02): "compaction can clear L:cognition-frame between turns within a loop." An LLM has no privileged "rules" memory; KERNEL-SLIM is tokens. As context grows and the harness compacts, the kernel loses salience or is evicted. Persona-bleed is the visible symptom of attention decay. **This is a genuine model limitation — context-window attenuation + compaction lossiness — that no disk state fully fixes,** because re-injection is periodic (`:167`, every 5 turns) and a window of true model-driven drift exists between re-assertions. *Likelihood as a primary driver:* **HIGH,** but its *magnitude is unquantified* (see F-I.1 — the detector records nothing). *Seats:* 2 (F1, the strongest model-cause evidence), 4 (the one place the contrarian concedes consensus survives).

**F-V.2 — Dual-stored cognition frame with a 5-turn recovery window. (MEDIUM)**
Identity is encoded twice: `L:cognition-frame ≡ "AXON-OS"` and `W:reasoning-mode ≡ "kernel-ops"` (`KERNEL-SLIM.md:158-159`), in *separate* gitignored stores, each clearable independently by compaction. Re-assertion fires only `IF turn-count mod 5 ≡ 0` (`:166-168`) — a deliberate up-to-5-turn window with no check, and recovery routes through the broken F-III.1 call. The dual encoding **doubles the loss probability for no redundancy benefit** (both clear on compaction). *Likelihood:* **MEDIUM** — this is where architecture meets the model limit. *Seat:* 1 (A6).

**F-V.3 — No durable memory of its own writes (F43/F44, acknowledged, not closed). (MEDIUM)**
`my-axon/dev-projects/axon-state-singlewriter/01-study.md`: **F44** — `checkpoint._read_working` snapshotted only `.md`, "silently losing JSON W: state (intent-queue, crucible-last) on restore." **F43** — two divergent L:-writers (`memory.py` vs `session_save.py`) with different byte output, so restore can't trust round-trip equality. The fix is **in study phase, not executed** ("Execution awaits owner greenlight"). Disk state *is* durable (`memory.py:50`, `kv_store.py` real diskcache); fragility is at the boundary — the model must remember to STORE, and the key name, to read back. *Seats:* 1 (strong-list), 2 (F4).

### Layer VI — Documentation / self-model drift (the cleanest observable)

**F-VI.1 — Version self-model is ~2 major versions stale. (MEDIUM-HIGH, verifiable today)** **[★]**
**Verified:** `VERSION` = `3.8.0`; `CONTEXT.md` = `3.8.0`; **`KERNEL-SLIM.md:2` = `AXON v1.1.7`.** The one file read first every session is stale about itself. *Seat:* 4 (Thesis C).

**F-VI.2 — Capability self-model is false in the current tree. (MEDIUM-HIGH)**
`.claude/settings.json` wires four live hooks, yet `workspace/harness/claude-code.md:37` declares `L:host-cap-enforce="self"` and `KERNEL-SLIM.md:93` still says the write-gate runs by discipline "while host-cap-enforce is 'self' with no PreToolUse hook." A PreToolUse hook **is** installed. `.claude/HOOKS-README.md` is still titled "PROPOSAL — review before activating" and instructs `mv settings.json.proposed settings.json` though hooks are already active. *Mechanism:* hand-maintained parallel state always rots — any system with N copies of "what version am I / what can I enforce" desyncs. *Seats:* 3 (F5, F7), 4 (Thesis C).

**F-VI.3 — host-model slot is stale. (MEDIUM-HIGH, concrete instance)**
`workspace/memory/longterm/host-model.md` = "Claude Opus 4.7" while the live model is Opus 4.8; `operating-discipline.md:19-25` calls AXON memory "the source of truth across harnesses," yet nothing reconciles the model-id. *Seat:* 3 (F5).

---

## 3. What Is STRONG (do not break)

The council is unanimous that several controls are genuinely sound and should be preserved:

- **`next_turn_gate.py` (gate-on-next-turn)** — the correct pattern for a harness that cannot block mid-turn; converts an un-sendable Stop verdict into a pre-turn denial (exit 2). *Seats 1, 4.* (Caveat: keys off a verdict the drift path cannot generate — F-I.1/F-I.2.)
- **`enforce_pretooluse.py` write-gate** on `Write|Edit|Bash` — a real pre-action keystroke gate, identity-independent via the tracked `.axon-governed` sentinel, fresh-clone-safe. *Seats 1, 3.*
- **Fail-closed staleness logic in `drift.py:222-289` and `autonomy_cadence.py:83-90`** — correct asymmetry: where the architecture assumes the model forgot, it halts rather than reporting false "stable." *Seat 2.* (The defect is the rule-layer discard, F-I.2, not this logic.)
- **PID-mismatch compaction detection (`session.py recover`)** — a model-independent drift signal. *Seat 2.*
- **Scheduled mechanical executors actually run** — `workspace/scheduler/cron.json` shows real `last_run` timestamps for freshness-reconcile, structural self-audit, registry refresh, episodic compaction. `tools/freshness.py` has real teeth for *artifact* staleness. *Seat 3.*
- **`workflow_run.advance` anti-skip guard** (`tools/workflow_run.py:206-281`) — real teeth, but only on 2 of 174 programs. *Seat 3.*
- **`self_care.persistence_check`** — detecting "declared-but-not-wired" reanchor hooks is exactly right. *Seat 2.*
- **The repo's self-honesty** — `axon-workflow-discipline/05-audit.md`'s 3-tier ENFORCEMENT-REALITY legend (MECHANICAL / WARN→BLOCK-pending-hook / ADVISORY-program) is the correct framework and names "activation depends on the owner" as the biggest "not yet real" item. *Seat 3.*

---

## 4. Prioritized Recommendations

Ordered by leverage (cheap-and-decisive first). The council strongly agrees: **adopt the cheap truth before the expensive theory.**

**P0 — Instrument before you conclude (resolves the unfalsifiability).**
Wire `drift record` from a real interceptor — a `PostToolUse` hook (or `tools/run.py`, where `usage.py` already auto-records per `KERNEL-SLIM.md:513`) appending `--tool <name>` to `working/drift-trace.json`. **Until `drift-trace.json` carries real `actual` sequences, every drift claim is unfalsifiable** (F-I.1). *If you will not wire it, stop citing `tools/drift.py` as a tracker — it is currently decorative.* *Seats 1, 2, 3, 4.*

**P1 — Flip the activation flags now (zero new code).**
The hooks are installed (F-IV.1). Set `L:state-surfaced-required`, `L:reasoning-trace-required`, `L:workflow-node-order-required`, `L:no-orphan-tools-required` = true. Converts ~4 silent rules to live BLOCK. This is literally step 4 of `scripts/enable-enforcement.sh`, never done — the single highest-leverage action. *Seats 3, 4.*

**P2 — Make counters mechanical, not model-driven.**
Increment `W:turn-count` in `reanchor_store.py` (UserPromptSubmit) instead of relying on `KERNEL-SLIM.md:137`; feed real harness token counts into `context record` from a hook. This re-arms *every* `mod N` cadence check and the context-pressure gate at once (F-II.1, F-II.2). Low risk, high impact. *Seats 2, 3.*

**P3 — Close the drift-gate seam, or delete the gate.**
Either make `r_drift_gate.py` treat `"unknown"` as the fail-closed BLOCK that `drift.py` already returns (F-I.2), or add a turn/token-based staleness dimension alongside the 2h wall-clock TTL (a 40-turn burst in 10 minutes never trips it — F-I.2/Seat 2 F3). Shipping a "stable"-by-emptiness detector is worse than none — it manufactures false assurance. *Seats 1, 2.*

**P4 — Unify the dual "drift" encoding (F-III.1).**
One schema, one tool, one store. Fix `KERNEL-SLIM.md:188,341` to call the tool that actually has `--phrase/--kind` (`axon_drift_log.py`), or merge the two tools. Add a conformance test asserting every `TOOL(drift, …)` in the kernel parses against the resolved tool's argparse. *Seat 1.*

**P5 — Reconcile the OS's own documents — free and verifiable today (F-VI).**
`KERNEL-SLIM.md:2` `v1.1.7 → 3.8.0`; `claude-code.md:37` / `KERNEL-SLIM.md:93` `host-cap-enforce="self"` is now false (hooks live); re-title `.claude/HOOKS-README.md`; self-heal `host-model.md` on boot by comparing `L:host-model` to runtime. Add the discipline docs to the freshness reconciler. *Seats 3, 4.*

**P6 — Collapse the dual cognition frame to one per-turn-asserted key (F-V.2).**
One authoritative identity key, asserted every turn (not `mod 5`). The dual `L:cognition-frame` / `W:reasoning-mode` encoding doubles loss probability for no redundancy. *Seat 1.*

**P7 — Land the state-singlewriter F43/F44 fixes (F-V.3).**
Until then every compaction-recovery risks dropping JSON W: state — "no durable memory of its own writes" made literal. *Seats 1, 2.*

**P8 — Extend the persona gate beyond lexical regex (F-IV.3).**
The dangerous cognition-frame slips use no trigger phrase; add a semantic assistant-frame check, and move the gate pre-send if/when the harness exposes the API. *Seats 1, 3.*

**P9 — Make ground truth tracked-or-derivable (F-IV.2).**
Guarantee every gate fails *closed* on absent state (invert the CI/clone default), or commit a redacted canonical snapshot. Right now "no state" = "all clear." *Seat 1.*

---

## 5. Open Questions / Dissent (preserved)

The seats did **not** fully agree. The deliberator preserves the live disagreements rather than flattening them.

**D1 — Is the fail-closed staleness logic a strength or a flaw?**
Seat 2 (F3) calls `drift.py`'s fail-closed TTL a clear **strength** ("where it assumes the model forgot, it is robust"). Seat 1 (A2) calls the system's handling of `unknown` a **critical flaw**. *Resolution offered:* both are correct at different layers — the tool computes a sound fail-closed verdict; `r_drift_gate.py:62` discards it. The defect is the seam. **Open:** was the rule-layer discard a deliberate "advisory, surface via badge" choice (the comment at `r_drift_gate.py:58-61` suggests yes) or an oversight? This changes whether P3 is a bug-fix or a policy reversal.

**D2 — Architecture flaw, or deliberate operating setting?**
Seats 1 and 3 frame default-OFF enforcement as a flaw/gap. **Seat 4 dissents hard:** it is an architecture *setting*, not a *defect* — the owner chose advisory-first to avoid bricking sessions on false positives (`verify_stop.py` docstring). "AXON drifts in default mode" = "AXON was configured advisory." **Open and unresolved:** the council cannot, from the tree alone, determine owner *intent*. The verdict's weighting of cause #3 hinges on this.

**D3 — Do more guardrails reduce or CAUSE drift?**
The other three seats lean toward closing gaps (more/better enforcement). **Seat 4 (Thesis D) steelmans the opposite:** KERNEL-SLIM is 757 lines / ≥14 per-turn gates; every ceremony token is context budget and attention not spent on the task, and the kernel itself concedes compaction erodes the frame (`:168`) — so the heavy apparatus may *manufacture* the cognition-frame slips it then flags. **This is a testable null hypothesis the council has NOT resolved:** *a thinner kernel drifts less.* Seat 4's recommendation #3 — run heavy-ceremony OFF vs ON and compare task outcomes — is endorsed as an open experiment. No seat produced data either way.

**D4 — Is the binding constraint the model or the harness?**
Seat 2 emphasizes model context-attenuation as primary. **Seat 4 (Thesis E) counters:** AXON already routed around model statelessness (file-backed state + hook re-injection); residual drift is largely *harness API surface* (no pre-send block hook → `verify_stop.py` "cannot un-send"), not model cognition. The shipped fix (`next_turn_gate.py`) exists *because* of a harness limit. **Open:** how much of F-V.1 (true compaction-driven slip) survives once P0 instrumentation lets us actually measure it? Currently unknowable.

**D5 — The magnitude of the irreducible model residue is unmeasured.**
All seats agree a real compaction-driven model-consistency window exists (F-V.1, F-V.2). **None can quantify it,** because the detector that would measure it records nothing (F-I.1). This is the central epistemic gap: **the council cannot currently distinguish "AXON drifts because the model can't hold state" from "AXON drifts because nobody plugged in the meter."** P0 is the prerequisite for ever closing this question.

**D6 — Weighting.**
Seat 1: architecture-flaw first, model second. Seat 2: predominantly model, architecture amplifies. Seat 3: ~70% process/discipline, ~30% model. Seat 4: neither dichotomy holds; instrument-artifact + doc-rot + off-by-design dominate. The deliberator's synthesized ~60/40 (architecture-process / model) is a *reconciliation*, not a consensus — the spread itself is a finding: **the cause is genuinely multi-factorial, and premature convergence on either pole of the charge would be wrong.**

---

*End of Round-1 synthesis. Advisory only. The single most important next action is P0 — instrument `actual` — without which every other finding about model-side drift remains unfalsifiable.*
