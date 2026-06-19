# AXON Re-Arm — Plan Review (Kernel Engineer seat / Python & systems-implementation specialist)

**Seat:** kernel-engineer (catalog: software/systems), acting as the **Python / systems-implementation**
specialist — the catalog is language-agnostic and kernel-engineer is the closest seat: an OS that gates,
hooks, classifies paths, and resolves changesets is a syscall-boundary / enforcement-floor problem in
Python. I review **concrete implementability + quality** of the first-sprint PRs against the *live tree*,
not the plan's prose.
**Mode:** with-context, ADVISORY ONLY. Read-only: I read source, ran read-only `git blame`/`grep`, and did
**not** run pytest, builds, or modify anything.
**Scope of charge:** CR-13 resolver fix (PR-T1-1), gate impls (PR-T2-1/T2-2), rule wiring
(PR-T0-2/T3-1/T3-4), drift instrumentation (PR-T0-1) — plus the rest of the first sprint
(T0-2a/T0-3/T1-2) since they share state-planes with the above.

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence HIGH (0.8).**

The plan is correctly *aimed*. The diagnosis (disarmed + uninstrumented, fix-by-config-and-wiring not
redesign) survives contact with the code: I independently confirmed zero `*-required` flags on disk, the
dual drift tools, the absent PostToolUse hook, and the changeset/output dual flag-plane. The remediation
*style* (fix consumers/joins, don't rewrite engines) is the right one for this codebase.

But several first-sprint PRs are written against a **stale or imprecise model of the current tree**, and the
two highest-leverage PRs (T1-1, T0-2) hide real implementation hazards the spec does not name:

- The CR-13 fail-open the plan treats as *open* is **already half-closed** in the live tree
  (`crucible.py:148 _changeset_base` + the fail-closed guard at `:189`, committed `1c7c9d50` 2026-06-03).
  PR-T1-1's framing ("the duplication IS the root cause") is partly **out of date** — there is now a
  fail-closed backstop, and the test the plan says "enshrines the bypass" actually asserts the *fix*.
- PR-T0-2 ("flip the flags") underspecifies the **two flag-planes** with **different file parsers** and a
  **polarity split** across the 15 `*-required` rules. Flipping naively will arm inconsistently.
- PR-T0-1 ("wire `drift record`") omits the **`drift init` precondition** and the fact that **no
  PostToolUse hook event exists** in `settings.json` at all — the interceptor is a new hook, not a handler.

None of these is fatal. All are addressable by tightening the spec before execution. Hence
SOUND-**WITH-RISKS**, not NOT-SOUND. Residual uncertainty: I did not execute the suite, so claims about
*which tests go red* are inferred from reading test bodies, not observed (flagged inline).

---

## 2. What the plan gets right (verified against the tree)

- **Tier-0-first sequencing is correct and load-bearing.** The drift meter genuinely reads an empty wire:
  `drift.py:cmd_record` exists and works, but **nothing calls it** (`grep` for a `drift record` caller in
  `tools/hooks/` → none). Until a hook feeds `actual`, every later "did drift drop?" claim is unfalsifiable.
  The plan's epistemic ordering is sound.
- **The "fix the seam, not the engine" thesis holds in code.** `drift.py` computes a real verdict;
  `r_drift_gate.py:62` discards `unknown`. `r_new_needs_test.py` is well-built (BF-004 substring bypass
  already closed via `_credible_reference`, `crucible.py:185`+). The defects really do live at the joins.
- **The changeset-plane rules already parse both flag file forms.** `r_workflow_node_order._required`,
  `r_no_orphan_tools._required`, and `r_phase_tracked._is_required` each fall back to reading the longterm
  `*-required.md` from disk and accept **both** bare `true` **and** `value: true` front-matter. So
  PR-T0-2 flipping those files *will* bite at the crucible gate. This is a real positive the plan can lean on.
- **Path classifier is genuinely consolidated.** `_axon_paths.is_axon_path` (`:42`) is realpath-based,
  cwd-independent, symlink-following, and already the SSOT (replaced 3 divergent impls). PR-T2-2's
  "extend `is_axon_path` → `is_protected_path`" is therefore a *clean* extension point — low structural risk.
- **`enforce_pretooluse.py` already does identity-independent R9 with a dev-mode gate** (`:233`+), so
  PR-T2-1/T2-2 extend a working, fresh-clone-safe gate rather than building one from scratch.
- **Dependency DAG is broadly right.** T0-2a→T0-2 (seed before flip), T1-1→{T1-2..5} (shared resolver),
  T0-1→T3-2/T6-exp (meter before consumer/experiment) all match the real coupling.

---

## 3. Ranked risks / gaps (with the PR ids they touch)

### R1 — PR-T1-1 is specified against a stale tree; the "root cause" is already partly fixed. **[HIGH]**
The plan (and the source handoff §B1) say `changed_files()` (`:131`) "lacks `2>/dev/null`" and that the
`:131`/`:155` duplication "IS the root cause." On the **live tree**:
- `crucible.py:131` **does** have `2>/dev/null` on the merge-base clause; it lacks it only on the
  `|| git rev-parse HEAD~1` fallback. The asymmetry the plan describes is *narrower* than stated.
- A second resolver `_changeset_base()` (`:148`) **already exists**, and `run_changeset` (`:189`) **already
  fails CLOSED** with `R_CHANGESET_BASE` when the base is unresolvable AND the diff is empty (commit
  `1c7c9d50`, 2026-06-03). The catastrophic vacuous-pass is **already closed** for the empty-diff case.
- The residual real defects are: (a) genuine *duplication* — `changed_files` still inlines its own base
  resolution (`:128-134`) independent of `_changeset_base`, so the two can still disagree on *non-empty*
  diffs and on stderr noise; (b) `changed_files` swallows git errors and returns `[]` (`:138-139`), which
  combined with `base` defaulting can still produce an empty changeset on some shallow checkouts.
- **PR-T1-3's premise is wrong about the test.** `tests/test_crucible_failopen.py` does **not** "enshrine
  the bypass" — it asserts the *fixed* behavior (`test_run_changeset_fails_closed_on_unresolvable_base`,
  `:18-25`, asserts `ok is False`). PR-T1-3 says to "re-point `test_crucible_failopen.py` which currently
  enshrines the bypass." That instruction would **damage a correct regression test.**
**Implementability impact:** PR-T1-1 is still worth doing (collapse to one resolver, kill the duplication),
but its **claim, test target, and acceptance criteria must be rewritten** against the current code. As
specced, an executor following T1-3 literally would revert a fix. *Confidence HIGH — I read both files in full.*

### R2 — PR-T0-2 underspecifies the dual flag-plane and the polarity split. **[HIGH]**
There are **two independent planes** that read `*-required` flags, with **different parsers**:
- **Output/Stop plane** — `verify.py:load_state` (`:35-130`) reads each `*-required.md` with
  `open(p).read().strip().lower() == "true"`. This parser does **NOT** understand the `value: true`
  front-matter form. It also **hardcodes** which flags it surfaces and **omits** `phase-tracking-required`,
  `workflow-node-order-required`, and `no-orphan-tools-required` entirely.
- **Changeset/crucible plane** — each rule's own `_required`/`_is_required` reads the longterm file directly
  and accepts **both** `true` and `value: true`.
Consequence: if PR-T0-2 writes the flags in `value: true` front-matter form (the form `read_myaxon_pointer`
and the rule fallbacks favor), the **changeset plane arms but the output plane stays inert** — silent,
plane-dependent enforcement. If it writes bare `true`, both planes agree but you've diverged from the
front-matter convention used elsewhere in `longterm/`.
Additionally, the 15 `*-required` rules have a **polarity split** I confirmed by grep:
- **default-ON** (`!= "false"`, armed unless explicitly disabled): `r_autonomy_breaker`,
  `r_code_change_requires_pr_phase`, `r_autonomy_cadence`.
- **default-OFF** (`== "true"`, inert unless explicitly enabled): the other 11, incl. all six PR-T0-2 names.
PR-T0-2 lists six flags to flip but says nothing about (a) which plane(s), (b) which file format, (c) the
polarity asymmetry, or (d) that three of its six flags are **invisible to `verify.py:load_state`** and so
will only ever bite at the crucible gate, never at the output gate. **The test ("each rule BLOCKs a
violating fixture") must be run in the correct plane per rule, or it will pass-by-plane and give false
confidence.** *Confidence HIGH.*

### R3 — PR-T0-1 omits the `drift init` precondition and the missing hook event. **[HIGH]**
`settings.json` wires only `UserPromptSubmit`, `PreToolUse`, `Stop`. **There is no `PostToolUse` event at
all.** So PR-T0-1 must (a) add a new hook *event* to `settings.json` — which is itself a Tier-2 protected
file once PR-T2-2 lands (ordering coupling, see R6), and (b) the handler must call `drift record`. But
`drift.py:cmd_record` (`:165-180`) returns error and records **nothing** if no trace is initialized
(`"No trace initialized. Run: drift init --program <path>"`). A PostToolUse hook that blindly calls
`drift record --tool X` will **silently no-op** whenever no program is active or `drift init` was never run —
which is most of the time. The plan's test ("hook fires → trace gains the actual call") will pass only on a
pre-initialized fixture and mask the empty-by-default reality. **PR-T0-1 needs an explicit init/ensure-trace
step and a test that the un-initialized path is handled (create-on-first-call or documented no-op).**
*Confidence HIGH.*

### R4 — PR-T3-2 (drift-gate unknown→fail-closed) collides with a *documented design decision*, not a bug. **[MED-HIGH]**
`r_drift_gate.py:57-63` is explicitly annotated **PR-AUTO-213**: `unknown` means "no/stale trace — can't
verify"; at the response gate this is **deliberately silent** ("the menu badge surfaces it, auto-action
layers do their own widened predicate"). This is precisely OD-2's "bug vs policy" fork — and the **code
currently encodes the policy answer, with a rationale.** Flipping it to fail-closed is defensible *after*
PR-T0-1 makes `unknown` rare, but **before** the meter is fed, `unknown` is the *normal* state, so
fail-closing it would **BLOCK essentially every output** in a fresh/un-initialized session. The DAG
(T0-1→T3-2) is right to gate T3-2 on T0-1, but the plan must add an explicit acceptance gate: *T3-2 only
arms once a meaningful fraction of sessions produce a non-unknown trace*, else it's a session-bricking change.
The plan should also stop calling it a "bug" — the owner already RESOLVED OD-2 as "treat unknown as
fail-closed," but the implementer must know they are **reversing a commented, tested design choice**
(`tests/test_rules/test_r_drift_gate.py` asserts the current passes), not patching an oversight.

### R5 — PR-T0-2's reference to "Step 4 of `scripts/enable-enforcement.sh`, never run" is inaccurate. **[MED]**
`enable-enforcement.sh` has **no step 4** and does **not flip flags**. It only checks three wrappers exist
and `cp`s `.claude/settings.json.proposed` → `.claude/settings.json` under `--apply`. Two problems for an
executor who trusts the plan: (a) there is **no `settings.json.proposed` on disk** (the script `exit 1`s
without it — the active `settings.json` is already installed), so the script is partly vestigial; (b) the
flag-flip is a **separate manual `memory.py set --scope L --key X-required --value true`** step the script
only *prints*. PR-T0-2 should specify the flag-flip mechanism directly (write the longterm files / call
`memory.py set`), not delegate to a script that doesn't do it. *Confidence HIGH — I read the script in full.*

### R6 — Ordering coupling: PR-T2-2 protects `settings.json`, which PR-T0-1 must edit. **[MED]**
PR-T2-2 brings `.claude/settings.json` under `is_protected_path` (gated like `axon/`, dev-mode required to
write). PR-T0-1 must **add a PostToolUse block to `settings.json`**. If T2-2 lands first, T0-1's edit to
`settings.json` now requires dev-mode + the new gate — fine if sequenced, but the first-sprint set runs
T0-1 *and* T2-2 together with no stated edge between them. **Add an explicit ordering note:** land the
`settings.json` hook wiring (T0-1) before, or in the same change as, the protection (T2-2); otherwise T0-1
trips the gate T2-2 just installed. Same hazard for any later PR that must touch `settings.json`.

### R7 — PR-T3-4 (R_PHASE_TRACKED → crucible runner) risks a mass false-positive at a biting gate. **[MED]**
The plan itself notes "100/105 ownership programs violate the ledger contract today." Moving
`R_PHASE_TRACKED` onto the `crucible` biting runner with `phase-tracking-required` armed means **the gate
goes from 0 to ~100 BLOCKs on the first run** unless the N/A path (no `STORE(W:active-program)` → not
applicable) is *proven* sound first. `r_phase_tracked._is_required` reads the flag fine, but the plan must
sequence: (1) confirm the N/A predicate, (2) seed/grandfather the 100 violators (mirrors the OD-5
grandfather pattern), (3) *then* arm. As written, T3-4 + an armed flag is a foot-gun. The plan gestures at
"after confirming its N/A path" but gives no grandfather story for the 100 — without it the gate is
un-shippable (it would block every existing ownership program). *Confidence MED — depends on N/A path I
did not exhaustively trace.*

### R8 — PR-T3-1 (prose↔wiring meta-rule) has an import/registration cycle hazard. **[MED]**
The meta-rule must, for "every `r_*.py` is registered," import or introspect all rule modules. Several rules
do **module-load-time work** (`r_drift_gate.py:33` mutates `sys.path` at import; `crucible.run_changeset`
does `sys.path.insert(0, cwd)` then imports 9 rule modules). A meta-rule that imports the whole `tools/rules`
package to check registration can (a) trigger those import side-effects, (b) hit partial-import states if any
rule imports back from the registry, and (c) be sensitive to which checkout is on `sys.path` (the
editable-install-vs-this-checkout problem `crucible.py:184` already documents). The plan must specify
**static introspection (parse/AST or filename glob vs `REGISTRY`/`ALL_RULES`), not live import**, to avoid an
import cycle and checkout-ambiguity. *Confidence MED — inferred from the import patterns I saw, not from a
built meta-rule.*

### R9 — Under-specified acceptance tests across the sprint (the "redo-until-closed" bar is not met by the specs). **[MED]**
The owner's hard constraint is "STRONG automated test; security/gate PRs reproduce-then-block; no
fingerprint-only closure." Several first-sprint test claims, as written, **would pass without proving the
claim**: T0-2's "each rule BLOCKs a fixture" doesn't say *which plane*; T0-1's "trace gains the actual call"
passes only on a pre-init fixture (R3); T1-3 targets the wrong file (R1). The plan needs per-PR
*reproduce-the-failure-on-the-real-tree-first* steps, not synthetic-fixture-only assertions, or it will
green PRs that don't move the live enforcement surface.

### R10 — Dual `drift.py` (`tools/` vs `workspace/tools/`) not addressed in the first sprint. **[LOW-MED]**
`tools/drift.py` (Jun 19, `--tool`) and `workspace/tools/drift.py` (May 26) both exist; the kernel's
`TOOL(drift,…)` literals call a third encoding (`axon_drift_log.py`, `--phrase/--kind`). PR-T0-1 wires "the"
drift tool but doesn't say **which** of the three. If the PostToolUse hook calls the wrong file (the stale
`workspace/tools/drift.py`), the meter reads empty *even after T0-1 ships*. Pin the exact module path in
T0-1; don't leave it to "drift record." (T3-3/T5-x address the dual encoding later, but T0-1 must not pick
the wrong one now.)

---

## 4. Specific changes to the plan before execution

1. **Rewrite PR-T1-1, T1-3, T1-4 against the current `crucible.py`.** Acknowledge `_changeset_base` (`:148`)
   and the `:189` fail-closed guard already exist. Re-scope T1-1 to: *collapse `changed_files`' inline base
   resolution (`:128-134`) to call the single `_changeset_base`, add `2>/dev/null` to the fallback clause,
   and stop returning `[]` on git error without distinguishing "no diff" from "git failed."* **Delete the
   T1-3 instruction to "re-point `test_crucible_failopen.py`"** — that test already asserts the fix; keep it,
   add the new end-to-end test alongside it.

2. **Split PR-T0-2 into plane-explicit sub-steps and resolve the file format.** State: (a) write flags in a
   format **both** planes parse — i.e., **bare `true`**, because `verify.py:load_state` does not understand
   `value: true`; OR fix `load_state` to use the canonical `_longterm.read_longterm_value` reader (it already
   imports it for dev-mode at `:32`) so both planes agree. (b) Enumerate, per flag, **which plane(s)** it
   bites and **per-plane test** it there. (c) Note the **polarity split** so nobody "arms" a default-ON rule
   redundantly or misreads a default-OFF one as broken. (d) Flag that `phase-tracking`, `workflow-node-order`,
   `no-orphan-tools` are **invisible to `load_state`** — either add them there or document that they are
   crucible-plane-only by design.

3. **Add the `drift init` precondition + the missing-hook fact to PR-T0-1.** Specify: add a **new
   `PostToolUse` hook event** to `settings.json` (it does not exist today); make the handler **ensure a trace
   exists** (create-on-first-call or guarded no-op) before `drift record`; **pin the module to
   `tools/drift.py`** (not `workspace/tools/drift.py`); and test the **un-initialized path** explicitly.

4. **Add an explicit edge T0-1 → T2-2 (settings.json wiring before protection).** Land the PostToolUse hook
   in `settings.json` before — or atomically with — bringing `settings.json` under `is_protected_path`, so
   T0-1 doesn't trip the gate T2-2 installs.

5. **Re-label OD-2/PR-T3-2 as a *policy reversal of a documented choice*, gated on meter health.** Note the
   PR-AUTO-213 rationale at `r_drift_gate.py:57-63`. Add an acceptance precondition: T3-2 arms only after
   T0-1 makes `unknown` the exception, not the rule — otherwise it BLOCKs every fresh session. Update the
   test target: the current `test_r_drift_gate.py` cases that assert pass-on-no-decision will need conscious
   re-pointing.

6. **Give PR-T3-4 a grandfather story for the 100 violators** (mirror OD-5's frozen shrink-only list) and
   make "confirm the N/A path" a hard gate, not a parenthetical. Do not arm `phase-tracking-required` on the
   crucible runner until the existing corpus is either grandfathered or compliant.

7. **Constrain PR-T3-1 to static introspection.** Forbid live-importing the rules package to check
   registration (import side-effects + checkout ambiguity at `crucible.py:184` + `sys.path` mutation at
   `r_drift_gate.py:33`). Use AST/filename-glob vs the registry manifest.

8. **Correct the PR-T0-2 reference to `enable-enforcement.sh`.** It has no "step 4," doesn't flip flags, and
   needs a `settings.json.proposed` that isn't present. Specify the flag-flip mechanism directly
   (`memory.py set --scope L` or writing the longterm files) and treat the script as install-only/vestigial.

9. **Raise the per-PR test bar to "reproduce-on-the-real-tree-then-block."** For every gate/security PR
   (T1-*, T2-*, T3-2, T3-4), require the failing case be demonstrated on an un-mocked fixture that mirrors the
   live defect before the fix, per the owner's own "no fingerprint-only closure" constraint.

---

## 5. Residual uncertainty (what would change this review)

- I did **not** run pytest/builds (charge: read-only). Claims about *which tests go red/green* are read from
  test bodies (`test_crucible_failopen.py`, `test_r_drift_gate.py`), not observed. If the suite is run and
  `test_crucible_failopen.py` already passes green (as its asserts imply), R1 is confirmed.
- I traced the flag-planes through `verify.py:load_state`, `crucible.run_changeset`, and three rule
  `_required` fallbacks, but not all 15 rules' load paths exhaustively. The polarity grep is complete; the
  per-rule plane mapping for the non-first-sprint rules is sampled, not exhaustive.
- R7/R8 severities depend on the `R_PHASE_TRACKED` N/A predicate and the future meta-rule's import strategy,
  neither of which exists yet — these are *design-time* hazards to pin in the spec, not observed failures.
- The owner has already RESOLVED OD-2/OD-5/OD-6 etc.; my R4/R7 do not dispute those decisions — they flag
  that the *implementation* reverses commented/tested behavior and needs sequencing, which is an
  engineering concern, not a re-litigation of intent.

**Bottom line for the seat:** the plan is the right plan, aimed correctly, with a remediation style that
suits the codebase. Before execution, refresh T1-1/T1-3/T1-4 against the *current* `crucible.py`, make
PR-T0-2 plane- and format-explicit, give PR-T0-1 its `drift init` + new-hook reality, and sequence
T0-1↔T2-2 and T3-2/T3-4 against the meter. Do those and the first sprint is sound to execute.
