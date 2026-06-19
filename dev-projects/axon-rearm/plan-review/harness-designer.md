# Plan Review — AXON Re-Arm

**Reviewer seat:** Harness Designer (AXON hr-team catalog · `professions/ai-ml/harness-designer.md`)
**Lens:** LLM runtime harness — context assembly, tool adapters, enforcement/verification gates, persistence, replay.
**Mode:** architecture-review + pre-mortem. Advisory only. Read-only verification performed on the live tree `/home/arturcastiel/projects/new-axon/axon` on 2026-06-19.
**Scope reviewed:** `HANDOFF.md`, `01-study.md`, `02-plan.md`, `02-prs.md`, `03-prs/DAG.json`, `research/00-AXON-report-state-handoff.md`, plus the load-bearing source files (`tools/crucible.py`, `tools/drift.py`, `tools/rules/r_drift_gate.py`, `tools/rules/r_terminal_outputs.py`, `tools/rules/r_reasoning_trace.py`, `tools/hooks/{verify_stop,enforce_pretooluse,reanchor_store}.py`, `tools/verify.py`, `.claude/settings.json`, `scripts/enable-enforcement.sh`).

Role-lock note: I evaluate this plan strictly as a harness-design problem — *where is enforcement mechanically real vs prose-only, where can the harness see/replay what it claims to enforce, and what do the tool/gate contracts actually return*. I distinguish prompt-level intent from harness-level enforcement throughout.

---

## 1. VERDICT

**SOUND-WITH-RISKS — confidence HIGH (0.82).**

The plan is architecturally correct, dependency-honest, and aimed at exactly the right seam: it re-arms enforcement through **configuration + finishing existing wiring**, not redesign, which the code confirms is the right diagnosis. Tier-0-first is the correct ordering and the DAG (`03-prs/DAG.json`) encodes the real dependencies I can verify in the source. I downgrade from SOUND only because of three under-specified harness risks that touch live-session safety and gate-contract correctness, all of which are fixable *in the plan* before a single PR lands (Section 4). None of them invalidate the backlog; they sharpen its sequencing and its test claims.

The single biggest correction I can offer is **good news that the plan under-claims**: the OD-1 "arming bricks sessions" dissent is *much weaker than the plan treats it*, because the harness topology already routes the to-be-armed rules through gates that cannot brick a live turn. I verified this in the hooks. The plan should bank that and redirect the brick-risk worry to the one hook that *can* brick (PreToolUse) and the one new merge-time BLOCK that arming actually creates (terminal-outputs).

---

## 2. WHAT THE PLAN GETS RIGHT

**R1 — The diagnosis matches the wiring; "config not redesign" is verified, not asserted.**
The `-required` flag mechanism is real and reads from two sources: rule `state` or `workspace/memory/longterm/<key>-required.md`, defaulting to **WARN when absent** (`r_reasoning_trace.py:46-53`, `r_terminal_outputs.py:11-13`). Zero such flags exist on disk (`ls workspace/memory/longterm/*required*` → none; confirmed). So `PR-T0-2` genuinely converts ~6 silent rules to live BLOCK with zero new rule code — the highest-leverage action in the corpus, exactly as claimed. `scripts/enable-enforcement.sh` only installs the hook payload and explicitly does *not* flip flags ("then flip activation flags" is a manual step) — so `PR-T0-2`'s premise ("step 4, never run") is accurate.

**R2 — The CR-13 fail-open root cause is real and the fix is correctly scoped.**
Verified at the line level: `changed_files()` (`crucible.py:131`) runs `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` — the second clause **lacks `2>/dev/null`** — while `_changeset_base()` (`crucible.py:155`) has `2>/dev/null` on *both* clauses. The two resolvers can disagree on a shallow/single-commit checkout. `PR-T1-1`'s "collapse to one resolver — one resolver can't disagree with itself" is the correct structural fix, not a patch. The "no monkeypatching" test claim in `PR-T1-1`/`PR-T1-3` is the right harness discipline: the existing `test_crucible_failopen.py` enshrines the defect, and a real throwaway-repo end-to-end test is what would have caught it.

**R3 — Tier-0-first respects the actual measurement dependency.** The instrument-before-you-act ordering is sound harness epistemics: `drift.py` computes a verdict over `workspace/working/drift-trace.json`, but **nothing writes `actual`** — there is no `PostToolUse` hook in `.claude/settings.json` (confirmed: `grep -c PostToolUse` → 0). So every model-side drift number today is unfalsifiable, and `PR-T3-2` (drift-gate fail-closed) and `PR-T6-exp` (thin-kernel experiment) genuinely cannot be evaluated until `PR-T0-1` exists. The DAG edges `PR-T0-1 → PR-T3-2` and `PR-T0-1, PR-T0-3 → PR-T6-exp` encode this correctly.

**R4 — Dependency DAG is honest and matches the code seams.** The four critical chains in `02-plan.md` are all reflected in `03-prs/DAG.json` edges and survive source inspection: `PR-T0-2a → PR-T0-2` (emits SSOT before flag bite), `PR-T1-1 → {T1-2..T1-5}` (one shared resolver underneath all CR-13 work), `PR-T0-1 → {T3-2, T6-exp}` (live meter), `PR-T4-4 → {T4-5, T5-3}` (registry status enum enables naming). I could not find a missing or inverted edge among the ones asserted.

**R5 — Re-arming respects what works (the kernel-floor / dogfooding constraints are honored).** The plan flags every KERNEL-SLIM edit for per-change dev-mode + owner confirm (`02-plan.md` Method; `02-prs.md` PR-T3-3, PR-T5-1), keeps the human in the kernel-write loop, and does NOT touch the proven engines (R9 write-gate, `phase_model.done()`, `workflow_run.advance`, registry hygiene) — it fixes *consumers and joins* (theme T3), e.g. `PR-T3-2` fixes the drift-gate *consumer* not `drift.py`. This is the correct "verified-output-gate at the boundary, don't rewrite the engine" posture.

**R6 — The verification-gate philosophy is right: BLOCK lives at the merge boundary.** `PR-T1-3`/`PR-T1-4` re-point tests that *enshrine* bypasses rather than only patching code — that is the correct harness discipline (a guardrail asserted-as-intended by a passing test is worse than no test). `PR-T1-5`'s frozen shrink-only `test-grandfather.txt` (mirroring the existing `tools/liveness-allow.txt`, which I confirmed exists) is a sound monotonic-coverage primitive that never bricks.

---

## 3. RANKED RISKS / GAPS

### RISK-1 (HIGH) — The OD-1 brick analysis is mis-aimed; the plan should re-target it, and `PR-T0-2` lacks a staged-rollout + one-command rollback contract.
**Touches:** `PR-T0-2`, `PR-T0-2a`; informs `PR-T6-exp`.
The dissent fears that flipping `-required` flags bricks live sessions. I verified the harness topology and **for the response-layer rules this fear is largely unfounded, which the plan should exploit rather than carry as unbounded risk**:
- The Stop hook is **LOG-ONLY and ALWAYS exits 0** by explicit design — `verify_stop.py:5-9`: *"a Stop hook cannot un-send, and exit-2-blocking would risk bricking a session on a false positive, so the crucible MERGE gate is where rules BLOCK."* So arming `reasoning-trace-required`, `state-surfaced-required`, etc. changes WARN→BLOCK **only at gates that cannot brick a live turn** (Stop logs; crucible runs at merge).
- The one hook that *can* brick mid-session is **PreToolUse** (`enforce_pretooluse.py`), which `sys.exit(2)` denies on R9 axon/ writes and tokenized `r_dont_do` matches (`:229,:242,:251`). `PR-T0-2` does **not** add anything to PreToolUse — so it carries near-zero live-brick risk for the response rules.
- **The real new BLOCK that arming creates is at merge:** `verify.py:300-301` shows the crucible MERGE gate carries `r_terminal_outputs.check`. Flipping `terminal-outputs-required` after `PR-T0-2a` seeds `# emits:` will cause a **merge-time BLOCK** if any seeded declared output is absent at `:done`. That is the genuine blast surface, and it is a *merge* gate (loud, recoverable), not a live-session brick.

**Gap:** despite this, `PR-T0-2` has no explicit *staged rollout* (arm one flag, observe a turn-window, then the next) and no *one-command disarm* contract. Arming is a config flip; the plan must make the inverse equally mechanical and tested. I found **no governed-profile / canary / staged-arm mechanism** anywhere in `tools/` or `scripts/` (searched). The plan says "governed profile" (`02-prs.md` PR-T0-2) but no such artifact exists yet — that profile *is* unbuilt scope hiding inside a one-line PR.
**Fix → Section 4.1.**

### RISK-2 (HIGH) — `PR-T0-2a` inverts a fail-open default to fail-closed; this is the actual brick vector and its test claim doesn't cover it.
**Touches:** `PR-T0-2a` → `PR-T0-2`.
`r_terminal_outputs.py:15-16` fails **OPEN** when emits can't be resolved ("Programs without a `# emits:` header are unguarded — safe default"). This means the DAG edge `PR-T0-2a → PR-T0-2` is about *bite/efficacy*, not safety: flipping the flag without seeding no-ops (correct). **But the inverse is the danger:** the moment `PR-T0-2a` adds a `# emits:` header to a program, that program flips from fail-open to **fail-closed** at the crucible gate once `PR-T0-2` arms the flag. If a seeded output legitimately doesn't exist at every `:done` (optional artifacts, conditional outputs, outputs written by a *later* phase), the seed itself manufactures a false BLOCK. Only **6** programs declare `# emits:` today (confirmed `grep -rl '# emits:' workspace | wc -l` → 6); seeding the rest is a large surface. `PR-T0-2a`'s test claim only asserts "declared-outputs set is non-empty and drift-lock (⊇) holds" — it does **not** assert that every seeded program actually produces every declared output at `:done` on a clean run. That is the missing reproduce-then-confirm.
**Fix → Section 4.2.**

### RISK-3 (MED-HIGH) — OD-2 / `PR-T3-2` is being executed as a bug-fix, but the code reads as deliberate policy — the plan must resolve bug-vs-policy *with evidence* before flipping.
**Touches:** `PR-T3-2` (and the `PR-T0-1 → PR-T3-2` chain).
`r_drift_gate.py:56-62` returns `None` on `state == "unknown"` with an explicit, dated rationale: *"PR-AUTO-213: distinguish positive divergence from evidence absence … At the response gate this is silent (no rule fire) — the menu badge surfaces it."* This is not an oversight in the code's own telling — it is a documented design choice with a provenance tag. `01-study.md` OD-2 resolves it as "BUG → fail-closed," but the plan should not flip a gate whose comment argues the opposite without (a) confirming the menu-badge surface is real and (b) confirming `drift.py` actually returns a *trustworthy* `unknown` only on staleness, not on the empty-wire-by-construction state that exists **today** pre-`PR-T0-1`. If `PR-T3-2` lands and `unknown→BLOCK` while the wire is still empty for any subset of sessions, **every such session merge fail-closes** — a self-inflicted brick. The `PR-T0-1 → PR-T3-2` edge is necessary but **not sufficient**: it guarantees a meter *exists*, not that the meter reads non-`unknown` for legitimate sessions.
**Fix → Section 4.3.**

### RISK-4 (MED) — `PR-T0-3` (mechanical counters) edits a hot per-turn hook with no guard against the inverse failure (over-counting / double-fire), and its dependency on the meter is unstated.
**Touches:** `PR-T0-3`; downstream `PR-T6-exp` depends on it.
`reanchor_store.py` runs on **every** `UserPromptSubmit` and today does **not** touch turn-count (confirmed). `PR-T0-3` adds a `W:turn-count` increment there. Two harness hazards the PR doesn't address: (1) the hook is best-effort/`|| true` in `.claude/settings.json`, so a partial run could increment-then-fail or fail-then-retry, **double-counting**; (2) every `mod N` cadence gate (identity re-anchor, coherence guardian, cognition-drift) re-arms *simultaneously* the instant this lands — a step-change in per-turn gate pressure with no canary. The PR's test ("two simulated turns → turn-count advances") tests the happy path only; it does not test idempotency under hook re-entry or the cadence-gate cascade. Also: `PR-T6-exp` depends on `PR-T0-3`, but `PR-T0-3` re-arming all cadence gates at once is *itself* a heavy-ceremony change that confounds the very OFF-vs-ON measurement `PR-T6-exp` wants — a measurement-contamination ordering issue.
**Fix → Section 4.4.**

### RISK-5 (MED) — Tier-2 (`PR-T2-1`, `PR-T2-2`, `PR-T2-clone`, `PR-T2-3`) is the only wave that touches the live-brick hook (PreToolUse) and the plan correctly flags it "own review," but the ordering relative to Tier-0 arming is unstated.
**Touches:** `PR-T2-1`, `PR-T2-2`, `PR-T2-3`, `PR-T2-clone`.
`PR-T2-2` extends `is_axon_path → is_protected_path` to cover `tools/` and `.claude/settings.json` — this *adds new deny paths to PreToolUse* (`enforce_pretooluse.py`, the one hook that `sys.exit(2)`). This is the genuine live-brick surface in the whole backlog (a mis-scoped `is_protected_path` could deny the harness's own legitimate writes to `tools/` during *this very project's* PRs — a dogfooding self-lock). The plan flags Tier-2 as "highest blast radius, own review" (correct) but does not state whether Tier-2 lands before or after Tier-0 arming, nor whether the first-sprint set (which includes `PR-T2-1`, `PR-T2-2`) means the security floor is being armed *concurrently* with the enforcement flags. Concurrent arming of both the response-rule flags *and* new PreToolUse deny-paths maximizes the surface where a single bad interaction bricks the session running the project.
**Fix → Section 4.5.**

### GAP-6 (LOW-MED) — No replay/audit artifact spec for the arming events themselves.
**Touches:** `PR-T0-2`, `PR-T0-2a`, `PR-T0-3`, `PR-T3-2`.
As a harness designer my standing objection: every one of these is a *state mutation that changes enforcement behavior* (flipping a flag, seeding a header, fail-closing a gate). The plan tests each rule's BLOCK/PASS but specifies no **replayable record of the arming event** — which flag was flipped, by whom/what, at what commit, and the verdict-before/verdict-after on a fixed fixture. Without it, if drift *increases* after Tier-0 you cannot cleanly attribute it to a specific arming step (which is the entire falsifiable-prediction premise of `01-study.md` §Drift and `PR-T6-exp`). This is cheap to add and makes the headline experiment trustworthy.
**Fix → Section 4.6.**

### GAP-7 (LOW) — `PR-T4-shadow` and `PR-T2-3` are "investigate / build-or-delete" PRs with no DONE-criterion that the redo-until-closed method can check.
**Touches:** `PR-T4-shadow`, `PR-T2-3`.
The owner's method is "a PR is DONE only when a STRONG automated test proves its claim." `PR-T4-shadow`'s deliverable is an ADR ("no silent merge/ignore") and `PR-T2-3` is "build G1c OR strike the claim" — neither has a *binary, test-checkable* DONE gate compatible with the stated method. `PR-T2-3` in particular touches the OS write-barrier (`chattr`/`0o444`) which, if built wrong, is a far worse brick than any flag (it can make `axon/` un-writable to the legitimate dev-mode path). I confirmed the legacy population is **31** `axon/programs/` entries (study says 29 — minor count drift, itself an instance of theme T7 the plan is trying to fix).
**Fix → Section 4.7.**

---

## 4. SPECIFIC CHANGES TO THE PLAN BEFORE EXECUTION

**4.1 (RISK-1) — Make `PR-T0-2` a staged-arm PR with a tested one-command disarm, and split the "governed profile" out as real scope.**
Add to `PR-T0-2`'s change: a `tools/enforcement_profile.py` (or equivalent) that arms flags **one at a time** with a recorded order, and a `disarm` inverse that clears all `*-required.md` in a single command. Add to its test claim: *"arming flag X, then `disarm`, returns the longterm dir to byte-identical pre-arm state; a deny-fixture that BLOCKed under X PASSes after disarm."* In `02-plan.md`, rewrite the OD-1 risk note to state the verified fact: response-rule arming changes behavior only at Stop (log-only) and crucible (merge) — **not** PreToolUse — so the live-brick fear applies to Tier-2, not Tier-0. This banks the good news the plan currently leaves on the table.

**4.2 (RISK-2) — Strengthen `PR-T0-2a`'s test to the actual fail-closed inversion it creates.**
Change the test claim from "non-empty declared set + ⊇ holds" to add: *"for every program that gains a `# emits:` header, a clean end-to-end run to `:done` produces every declared output on disk (reproduce-then-confirm the crucible `r_terminal_outputs` gate PASSes)."* Any program where a declared output is optional/conditional/late-phase must be excluded from the seed or carry a documented conditional-emits annotation — otherwise `PR-T0-2` arms a false-BLOCK. Make `PR-T0-2a` strictly land, be verified green at the crucible gate with the flag *temporarily* armed in a throwaway profile, then disarm — before `PR-T0-2` arms for real.

**4.3 (RISK-3) — Gate `PR-T3-2` on a "wire-is-live" precondition, not just "meter exists."**
Add a hard precondition to `PR-T3-2`: it may only flip `unknown→BLOCK` after a measurement window proves `drift.py` returns `unknown` **only** on genuine staleness (not on the empty-wire-by-construction state). Add to its test: *"a fresh, actively-traced session returns state ∈ {stable, diverged} (never unknown); only a stale/absent trace returns unknown → BLOCK."* Also: the plan must consciously record the bug-vs-policy decision against the `PR-AUTO-213` comment in `r_drift_gate.py:56-62` — either delete that comment as superseded or the PR is editing past a live design rationale silently (a theme-T2 violation the plan elsewhere fixes). Keep the menu-badge surface working so `unknown` is never *silently* dropped.

**4.4 (RISK-4) — Make `PR-T0-3` idempotent-by-construction and decouple it from the cadence cascade.**
Add to `PR-T0-3`'s change: increment keyed by a per-turn idempotency token (e.g. the `UserPromptSubmit` event/session-turn id) so a hook re-fire cannot double-count. Add to its test: *"a re-fired UserPromptSubmit for the same turn does not advance W:turn-count."* Sequencing: because `PR-T0-3` re-arms every `mod N` cadence gate at once and `PR-T6-exp` depends on it, add a note that `PR-T6-exp`'s OFF-vs-ON protocol must treat `PR-T0-3`'s cadence gates as part of the "heavy ceremony" under test — otherwise the experiment measures a confounded baseline.

**4.5 (RISK-5) — Sequence Tier-2 *after* Tier-0 is observed stable, and split the first sprint.**
The first-sprint set currently mixes Tier-0 arming (`T0-1/2/2a/3`) with Tier-2 PreToolUse changes (`T2-1`, `T2-2`). Recommend: land and observe Tier-0 for a turn-window first; land Tier-2 PreToolUse deny-path changes (`PR-T2-2`) in a *separate* sprint with its own dev-mode-on canary, because it is the only change that adds live-brick deny-paths. Add to `PR-T2-2`'s test: *"a legitimate dev-mode-on Write to `tools/rules/r9_axon_write.py` during an active project PR is ALLOWED (no dogfooding self-lock); the same Write with dev-mode off is BLOCKED."* This directly guards the project from locking itself out while editing the enforcement core.

**4.6 (GAP-6) — Add an arming-event audit record to every Tier-0 / Tier-3 arming PR.**
Specify a single append-only `workspace/working/enforcement-arming-log.jsonl` (or reuse the episodic log) recording `{ts, commit, flag/seed/gate, verdict_before, verdict_after}` for each arming step, written by the arming tool itself. This makes the `01-study.md` falsifiable-prediction and `PR-T6-exp` attributable: drift deltas can be tied to a specific arming event. Add it as a one-line addendum to `PR-T0-2`, `PR-T0-2a`, `PR-T0-3`, `PR-T3-2`.

**4.7 (GAP-7) — Give the investigate/build-or-delete PRs a binary DONE gate.**
For `PR-T4-shadow`: the DONE test = "a reachability report exists AND a registry/CI lint asserts every one of the (verified) 31 `axon/programs/` nodes is either referenced by a live caller or moved to a declared out-of-graph manifest — the lint fails if a node is in neither set." For `PR-T2-3`: split into `PR-T2-3a` (decide+ADR) and `PR-T2-3b` (build), and if built, the DONE test must include the *negative* safety case: "a dev-mode-on write to `axon/state/` still succeeds after the write-barrier is applied" — proving the barrier didn't brick the legitimate write path.

---

## 5. ONE-PARAGRAPH SUMMARY FOR THE COUNCIL

The plan is sound and well-sequenced: it correctly diagnoses AXON as armed-in-prose / disarmed-in-config, fixes joints not engines, and puts the meter before the measurement. I verified its three headline claims in the source (the `crucible.py:131` vs `:155` resolver split, the absent `-required` flags defaulting WARN, the empty drift wire with no `PostToolUse` hook). My one structural correction is that the plan *over-fears* the OD-1 brick risk for the response-rule flags — the Stop hook is log-only by design and arming changes behavior only at non-bricking gates — and *under-specifies* the three places that genuinely can brick: the fail-OPEN→fail-CLOSED inversion that `PR-T0-2a`'s seeding creates at the crucible terminal-outputs gate, the `unknown→BLOCK` flip in `PR-T3-2` while the wire may still read empty, and the new PreToolUse deny-paths in `PR-T2-2` (the only change that can self-lock the project editing its own enforcement core). Add staged-arm + one-command disarm, a wire-is-live precondition on `PR-T3-2`, idempotent counters in `PR-T0-3`, and an arming-event audit log, and this moves from SOUND-WITH-RISKS to SOUND.
