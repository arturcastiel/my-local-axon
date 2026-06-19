# Plan Review — QA / Test Architect

**Reviewer:** QA / Test Architect (named specialist, advisory only)
**Scope:** Test strategy of the `axon-rearm` plan (HANDOFF.md, 01-study.md, 02-plan.md, 02-prs.md) against the source handoff `research/00-AXON-report-state-handoff.md`.
**Method of review:** READ-ONLY. Read the plan, then verified each first-sprint PR's test claim against the live tree (`tools/crucible.py`, `tools/rules/r_new_needs_test.py`, `tools/rules/r_drift_gate.py`, `tools/_axon_paths.py`, `tools/drift.py`, `tools/liveness-allow.txt`, `tests/test_crucible_failopen.py`, `.github/workflows/ci.yml`, `scripts/enable-enforcement.sh`). No pytest, no builds, no edits.
**Lens:** Is each stated test actually adversarial, or could it pass while the defect remains? Is the grandfather a sound ratchet? Where are the tests vacuous, flaky, or mocking-away-the-bug? What infrastructure is missing?

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence 0.8.**

The *test philosophy* ("redo-until-closed; every PR ships a STRONG test proving its claim; security/gate PRs reproduce-then-block; no fingerprint-only closure") is exactly right and is the single most important thing the plan gets right. The repo already carries unusually strong test infrastructure (325 test files, `conftest.py`, fixtures, a `_mock_model.py`, and a CI coverage gate of **100% on `tools/rules/` and 80% on `tools/`** — `.github/workflows/ci.yml:71-91`) that the plan's test claims can build on.

But the plan is sound *with risks* for one dominant reason that the QA charge is precisely positioned to catch: **the plan's test claims are written against the stale snapshot in the source report, and the live tree has already moved.** Several first-sprint defects the tests are supposed to "reproduce-then-block" are *already fixed or already non-existent on disk*. A test written to reproduce a bug that is already gone will pass on the first run — which under "redo-until-closed" looks like success but proves nothing (a vacuous green). This is the same failure class the report itself flagged (`test_crucible_failopen.py` mocking the defect away), reappearing one level up: the *plan* now risks asserting-the-already-true.

It is SOUND-WITH-RISKS rather than NOT-SOUND because every weakness below is fixable by a re-baseline pass and ~6 concrete test-design changes, none of which require re-architecting the plan. The waves, the Tier-0-first ordering, and the reproduce-then-block discipline are all correct.

---

## 2. What the plan gets right (from a QA lens)

1. **Reproduce-then-block is the correct gate-test contract.** For a security/gate PR, the only test that proves the claim is one that *fails on the pre-fix code and passes on the post-fix code*. The plan states this explicitly for Wave 1/2/3 (02-plan.md:38-39, 02-prs.md:4). This is the right standard and it is the standard most teams skip.

2. **The "no monkeypatching" rule for the CR-13 end-to-end test (PR-T1-3, 02-prs.md:42-46) is the correct antidote** to the exact pathology the report named. The existing `tests/test_crucible_failopen.py:21-22` monkeypatches *both* `_changeset_base` and `changed_files` — so it never exercises the real git resolver. Demanding a throwaway-repo end-to-end test is the right fix.

3. **The meta-assert in PR-T1-3 ("no R13 test monkeypatches both resolvers") is a genuinely good test-of-tests.** A lint that forbids the bypass pattern from recurring is exactly the kind of infrastructure that stops regression-by-mock. Keep it; broaden it (see §4).

4. **Tier-0-first is methodologically right for a QA program.** You cannot measure whether a fix worked without the meter (PR-T0-1) and the flags (PR-T0-2). Sequencing instrumentation ahead of the fixes whose effect it must observe is correct test-program design, not just engineering ordering.

5. **The per-rule BLOCK-on-violating / PASS-on-clean fixture pattern (PR-T0-2, 02-prs.md:20) is the right shape** — it tests both arms (true-positive *and* true-negative), which is what stops a rule from "passing" by blocking everything.

6. **The frozen shrink-only ratchet *concept* (PR-T1-5/OD-5) is sound coverage-program design** — a monotonically-shrinking exemption list is the correct way to drive coverage to zero without bricking the corpus. The concept is right; its *enforcement* is the risk (§3, R3).

---

## 3. Weaknesses / risks / gaps, ranked by severity

### R1 — CRITICAL — The CR-13 defect the tests target is ALREADY FIXED; the real current failure mode is the OPPOSITE (fail-CLOSED-on-every-PR), and no PR's test targets it. *(PR-T1-1, PR-T1-2, PR-T1-3)*
The report's load-bearing claim is `crucible.py:131` lacks `2>/dev/null` and so disagrees with `:155`, causing fail-OPEN. **On the live tree this is no longer true.** `tools/crucible.py:131` reads `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` and `run_changeset` already contains an explicit fail-CLOSED path (`tools/crucible.py:189-196`, rule `R_CHANGESET_BASE`) that returns `ok:False` when the base is unresolvable. The duplication PR-T1-1 wants to "collapse" is largely already neutralized in behavior.

Consequence for the test strategy:
- **PR-T1-1's stated test** ("single-commit repo, base=None → ok is False, NO monkeypatching") will **pass on the *current* code without the PR's change**, because the fail-closed path already exists. That is a vacuous green: it asserts a property that already holds, so it does not prove the resolver was unified. The test cannot distinguish "two resolvers collapsed to one" from "two resolvers that happen to agree today."
- **The actual live risk is now fail-CLOSED, not fail-open.** With `.github/workflows/ci.yml` using `actions/checkout@v4` at default depth-1 (no `fetch-depth: 0` anywhere — confirmed `ci.yml:113-127`), the `crucible-gate` job's checkout is shallow → `merge-base` and `HEAD~1` both fail → `_changeset_base` returns None → `run_changeset` fails CLOSED on **every** PR. So today the gate likely **blocks every PR with `R_CHANGESET_BASE`**, which is the "too blunt" failure the report itself names (handoff §3 B2). No first-sprint test asserts the *post-PR-T1-2* behavior that the gate computes a *non-trivial* changeset and does *not* force-close.

**Fix:** Re-baseline PR-T1-1/T1-3 against the current code, and make PR-T1-2's test the load-bearing one: a CI-shaped *shallow then deepened* checkout fixture that asserts (a) shallow → fail-closed (current), (b) `fetch-depth:0`+origin/main → a real merge-base → the gate evaluates rules and a clean PR PASSES, a PR adding an untested neuron BLOCKS. Without that, PR-T1-2 ships untested.

### R2 — CRITICAL — PR-T3-2 (drift-gate `unknown → fail-closed`) treats a DOCUMENTED design decision as a bug; its stated test would assert behavior the code's authors deliberately rejected. *(PR-T3-2 / OD-2)*
The plan (OD-2, 02-prs.md:87-90) says `r_drift_gate.py` "must treat `unknown` as the fail-closed BLOCK drift.py already computes," and the test is "an unknown/stale trace → BLOCK." But the live code (`tools/rules/r_drift_gate.py`) carries an explicit, dated rationale (`PR-AUTO-213`):

> `state=unknown means "no/stale trace — can't verify drift". At the response gate this is silent (no rule fire) — the menu badge surfaces it to the user, and auto-action layers do their own widened predicate.`

So `unknown → return None` is **intended** at the *response gate* (to avoid bricking every interactive turn on a stale trace), with surfacing pushed to the menu badge and to auto-action layers. The source handoff itself flags this as an *open decision* requiring owner intent ("bug-fix vs policy reversal — flag for owner", handoff §5 OD-2). The plan resolved OD-2 as "BUG" — but the QA risk is that **a test asserting `unknown → BLOCK` at the response gate would reverse a deliberate UX decision and could brick interactive sessions on stale traces**, which is exactly the false-positive bricking the kernel's advisory-first posture was avoiding.

**Fix:** The test must be scoped to the *correct layer*. The defensible claim is "at the **crucible/merge gate** (not the per-turn response gate), `unknown` fails CLOSED" — that is where empty-wire silence manufactures false assurance, and where bricking a turn is not a concern. The test should be a *gate-context* fixture (`output gate / pre-merge`), and a separate *response-context* fixture should assert the existing silent-with-badge behavior is preserved. Asserting BLOCK unconditionally is a flaky-by-design test that will fight the existing `test_drift_fail_closed.py` and the PR-AUTO-213 contract.

### R3 — HIGH — The grandfather "ratchet" (PR-T1-5/OD-5) mirrors a list that is NOT actually shrink-only-enforced; the proposed test is necessary but the report's premise ("mirrors liveness-allow.txt") points at a non-ratchet. *(PR-T1-5)*
`tools/liveness-allow.txt` is described in its own header as "a SHRINKING list," but the only test that touches it (`tests/test_reaudit_liveness.py:60-67`, `test_pinned_actives_grandfathered_not_demoted`) asserts the *opposite* direction — that pinned tools *are present* in the allow-list. **There is no test anywhere that the allow-list can only shrink** (no "append-forbidden" / monotonic check — grep for `only shrink`/`append-forbid`/`monotonic` against `liveness-allow.txt` returns nothing real). So PR-T1-5 cannot "mirror" a ratchet that does not exist; it must *build* the ratchet.

The QA risks specific to PR-T1-5's stated test ("adding an entry fails the gate; removing one passes; a new neuron not in the list still requires a test"):
- **"Adding an entry fails the gate" is only meaningful if the gate compares against a frozen baseline.** Against *what* baseline? If it's `git`-diff-based, the test is flaky in shallow CI (same fetch-depth problem as R1) and bypassable by a force-push. If it's a checked-in hash/count sentinel, that sentinel itself becomes a thing someone edits. The test must pin *how* "added" is detected and prove that detection is not itself bypassable.
- **A frozen list with no named owner and no shrink target is a ratchet with no pawl.** The handoff (§5 OD-5) explicitly asks "who owns shrinking it, and to what target?" — the plan adopted the list but did not answer the ownership/target question. Without a target, "monotonic toward zero" is aspirational, not tested. Add a test that the list's size is `<=` a checked-in ceiling that itself only ever decreases.

### R4 — HIGH — Several PR-T1-4 / first-sprint "fixes" are already implemented; their tests risk asserting-the-already-true (vacuous green) unless re-baselined. *(PR-T1-4, PR-T2-2)*
- **PR-T1-4** claims four fixes to `r_new_needs_test.py`. On the live tree, **the BF-004 substring bypass is already closed** (`_credible_reference`, `r_new_needs_test.py:101-112`, replacing the bare-substring check), and `_classify` already exists with `_` and `compiled/`/`help/` exclusions. The "tighten `_credible_reference`" sub-claim is *already done*. So a test "typo-a-filename bypass BLOCKS" may already pass — vacuous unless the PR adds a *new* tightening and the test targets *that* delta.
- **The genuinely-still-open parts of PR-T1-4 are real and the tests there are adversarial:** `check()` returns early on `status != "A"` (`r_new_needs_test.py:150`), so **rename (R) and copy (C) are NOT covered** — the "rename-launder" bypass is real; and `_classify` only matches `workspace/programs/`, **not `axon/programs/`** (the 29 shadow neurons), so "extend `_classify` to addon neurons" is real. Keep those two fixtures; drop/repurpose the substring one.
- **PR-T2-2** premise IS still real and well-targeted: `is_axon_path` (`tools/_axon_paths.py:42`) covers *only* `axon/`, never `tools/` — so "Write into `tools/rules/*.py` BLOCKED with dev-mode OFF" is a true-positive the current code fails. Good. But the test must also assert the **dev-mode-ON allow path** (stated) *and* a negative-control: a write to an unrelated path is unaffected (no over-blocking). The plan states ON/OFF but not the no-over-block control.

### R5 — HIGH — PR-T0-1's test for the drift meter does not prove the meter MEASURES drift — only that the wire carries bytes. *(PR-T0-1)*
The premise is correct and verified: there is **no `PostToolUse` interceptor anywhere** (grep `PostToolUse` over `tools/`+`.claude/` is empty; `.claude/settings.json` wires only `UserPromptSubmit` and `PreToolUse`), and `drift.py` reads `actual` from `working/drift-trace.json` (`tools/drift.py:8-12,153,170`) which nothing populates. So the wire genuinely is empty. But the stated test — "PostToolUse hook fires → trace file gains the actual call; drift.py computes a non-empty verdict" — is **necessary but not sufficient**. A trace with one appended call yields a "non-empty verdict" trivially; it does not prove the meter discriminates *drift* from *no-drift*. Because the entire rest of the plan (PR-T3-2, PR-T6-exp, the §4 root-cause verdict, the falsifiable prediction) hangs on this meter being *trustworthy*, the under-test here is the highest-leverage single weakness in the test program.

**Fix:** PR-T0-1's test must be a discrimination test: a fixture where the actual sequence *matches* expected → score below threshold (stable), and one where it *diverges* → score above threshold (diverged). Plus an ordering test (the interceptor records calls in the order they fire) and a compaction test (the interceptor still fires when the model does *not* run a markdown op — the T4 self-defeating-loop the whole instrumentation effort exists to break). Without the divergence-discrimination assertion, the meter is "plugged in" but unproven, and every downstream measurement inherits that doubt.

### R6 — MEDIUM — `PR-T0-3` (mechanical counters) "two simulated turns → turn-count advances" is a happy-path test for a mechanism whose whole point is to survive the UNHAPPY path. *(PR-T0-3)*
The defect T4 names is that counters freeze *exactly when the model is degraded/compacted and skips the markdown op*. A test that advances the counter via two clean simulated turns proves the mechanism works when nothing is wrong — the case that was never the problem. The adversarial test is: the counter advances **even when the model emits no STORE / no output block** (i.e., the hook path, not the model path), and advances **idempotently** (a re-fired hook does not double-count). The plan's stated test misses the only case that matters.

### R7 — MEDIUM — PR-T2-1 (gate dev-mode toggle) test omits the bypass-vector matrix; a single Write-deny test will mock away the Bash/Edit/append/indirect vectors. *(PR-T2-1)*
The change is "deny any Write/Edit/Bash setting dev-mode=true without an out-of-band token." The stated test ("a programmatic dev-mode=true write is DENIED; the out-of-band path is ALLOWED") tests one vector. `dev-mode.md` lives in `workspace/memory/longterm/dev-mode.md` (verified) — an ordinary memory file. The adversarial surface is wider: `Bash echo >> dev-mode.md`, `Edit` an existing line, a `memory.py`/`axon_state.py` API write, a computed-path write, and the `r_drift_gate` consumer that reads `state.dev_mode is True` (`r_drift_gate.py`). A security-floor PR must test the *matrix* of vectors, not one. This is the same "one classifier, many bypasses" lesson R9 already learned (the historical `echo x > axon/...` Bash bypass). The test must enumerate Write / Edit / Bash-redirect / API-write and assert each is denied, plus assert the out-of-band token path is the *only* allow path.

### R8 — MEDIUM — No test for the "loud N/A vs silent pass vs block" three-way distinction in the clone fail-closed PR; a two-state test will conflate the legit-empty and suppressed cases. *(PR-T2-clone / OD-6)*
The whole point of OD-6 is a *three-way* outcome: "no active project" (legit → allow/loud-N/A), "state suppressed" (→ block), and a normal resolvable state (→ evaluate). The stated test names two fixtures (fresh-clone-with-sentinel → fail-closed; no-active-project → loud N/A). It is missing the **discrimination assertion** that the gate *distinguishes* the two from each other and from the normal path — and missing the assertion that "loud N/A" is actually *loud* (surfaced/logged), not a silent pass wearing an N/A label. Without a test that the three outcomes are mutually distinguishable, the implementation can collapse two of them and still pass.

### R9 — MEDIUM — Coverage-gate interaction is unaddressed: the existing CI gate demands 100% on `tools/rules/` and 80% on `tools/`. Several PRs add code to those paths. *(cross-cutting; PR-T0-1, T0-3, T1-1, T2-1, T2-2, T3-2)*
`.github/workflows/ci.yml:71-91` fails the build if any `tools/rules/*.py` is below 100% line *and* branch coverage or any `tools/*.py` is below 80% line. New code in `r_drift_gate.py`, `r_new_needs_test.py`, `_axon_paths.py`, `crucible.py`, and any new rule file inherits this bar. The plan's per-PR test claims do not mention covering *every branch* of the new code — but CI will reject the PR if they don't. This is not a flaw so much as an unstated constraint: **every PR's test must hit 100% branch coverage of any `tools/rules/` line it touches**, or the PR cannot merge regardless of whether its claim-test is green. Make this explicit in the per-PR "done" definition.

### R10 — LOW — `_axon_rollback.py` (PR-T4-3, "highest single risk") has no dedicated test, but the plan's claim slightly overstates the gap. *(PR-T4-3)*
Verified: `tools/_axon_rollback.py` exists; there is no `tests/test__axon_rollback.py`. There *is* `tests/test_longterm_value_collision_and_rollback.py`, which exercises rollback *incidentally* via the longterm path. So the recovery primitive is not *zero-covered* but is not *directly* round-trip-tested. The plan's "real round-trip test" is the right ask; just don't claim "0 tests" in the PR body (it invites a reviewer to disprove the premise and dismiss the PR).

### R11 — LOW — `PR-T4-shadow`, `PR-T6-exp` produce ADRs, not tests — fine, but the plan should say so explicitly so "redo-until-closed" doesn't block on a non-existent test. *(PR-T4-shadow, PR-T6-exp)*
Both are correctly typed as investigation/experiment, and their "test:" lines say so. The risk is purely process: under a literal "no PR is DONE without a green test" rule, a reviewer could wrongly hold these open. The plan should state that investigation/experiment PRs close on a *reviewed artifact* (ADR + reachability report / drift-delta protocol), and that the *resulting* action PR carries the test.

---

## 4. Specific changes I would make to the plan before execution

1. **Insert a Wave-0 "re-baseline" step before any Tier-1 test is written.** Re-verify each first-sprint defect against the live tree HEAD (`6ce9bd8`), because the report's snapshot is stale: `crucible.py:131` already has `2>/dev/null`, `run_changeset` already fails-closed (`:189-196`), `r_new_needs_test._credible_reference` already closes BF-004, and `r_drift_gate` already documents `unknown→None` as intended (PR-AUTO-213). For each PR, record "defect status: present / partially-fixed / already-fixed" and **rewrite the test to target the surviving delta**. This single step prevents the entire vacuous-green class.

2. **Add a mandatory "fails-on-pre-fix" gate to every reproduce-then-block PR.** Make it a hard rule: the claim-test must be *demonstrated to FAIL on the parent commit* (pre-fix) and PASS on the PR commit. A test that passes on both commits is, by definition, not proving the fix — it is the plan-level version of the very mock-away-the-bug pathology the report flagged. This is the operational teeth behind "no fingerprint-only closure." (Touches every Wave 1/2/3 PR.)

3. **Re-scope PR-T1-2 as the load-bearing CR-13 test, not PR-T1-1.** The real, currently-broken behavior is shallow-CI fail-closed-on-every-PR. Add a CI-shaped fixture (shallow checkout → `R_CHANGESET_BASE` block; `fetch-depth:0`+origin/main → real merge-base → clean PR passes, untested-neuron PR blocks). This is the test that proves CR-13 *bites correctly* rather than *bites everything*.

4. **Re-scope PR-T3-2's test to the gate layer and add a layer-discrimination matrix.** Two fixtures: at the **merge/crucible gate** `unknown → BLOCK` (the false-assurance case), at the **response gate** `unknown → silent-with-badge` (preserve PR-AUTO-213). Assert both — so the fix closes the dangerous layer without reversing the deliberate interactive-UX decision and bricking turns. Flag OD-2 back to the owner with this nuance: "BUG at the gate, intended at the turn" — the plan's flat "BUG" is too coarse.

5. **Make PR-T0-1 a discrimination test, not a liveness test.** Required assertions: matching sequence → stable score; diverging sequence → diverged score; calls recorded *in order*; and the interceptor fires on the **model-skips-the-op** path (the T4 case). Every downstream measurement (PR-T3-2, PR-T6-exp, the root-cause verdict) is only as trustworthy as this discrimination proof.

6. **Build the grandfather ratchet's pawl and test it (PR-T1-5).** Don't "mirror" `liveness-allow.txt` (it has no shrink-only enforcement). Add: (a) a checked-in *count ceiling* that only ever decreases, (b) a test that adding any entry — or raising the ceiling — fails the gate, (c) a baseline-detection that is not git-diff-dependent (so it is not flaky in shallow CI and not force-push-bypassable), (d) a named owner and a numeric shrink target recorded in the file header (answering handoff §5 OD-5). Mirror the *concept*, fix the *mechanism*.

7. **Turn the security-floor PRs (T2-1, T2-2, T2-clone) into bypass-vector matrices.** Each must enumerate Write / Edit / Bash-redirect / API-write / computed-path and assert *every* vector is denied with the flag OFF, the sanctioned path is the *only* allow, and unrelated paths are *not* over-blocked (negative control). One-vector tests on a security floor are the report's "honesty ≠ enforcement" theme reappearing in the tests.

8. **Make the 100%/80% coverage gate an explicit per-PR exit criterion.** Add to the "done" definition: any PR touching `tools/rules/*.py` must reach 100% line+branch on the changed file and 80% on `tools/*.py`, or CI rejects it (`ci.yml:71-91`). State it so authors test the branches up front rather than discovering the gate at merge.

9. **Add three pieces of missing test infrastructure, as their own small enabler PRs (or shared fixtures):**
   - a **throwaway-git-repo fixture** (`tmp_path` + `git init` + controlled commit graph) reused by PR-T1-1/T1-2/T1-3/T1-5 and the clone PR — the resolver/changeset/fetch-depth/ratchet tests all need a *real* repo, not monkeypatched git; building it once stops each PR from re-mocking and re-introducing the bypass;
   - a **shallow-vs-deep checkout fixture** to simulate CI fetch-depth deterministically (the fail-closed-vs-bites distinction);
   - a **"model-skipped-the-op" harness** (extend `tests/_mock_model.py`) that drives hooks *without* a cooperating model output block — the only way to test that the mechanical counters / drift wire survive compaction, which is the entire premise of Tier 0.

10. **State the closure rule for investigation/experiment PRs** (PR-T4-shadow, PR-T6-exp): they close on a reviewed ADR + reachability/protocol artifact; the *follow-on* action PR carries the claim-test. Prevents "redo-until-closed" from deadlocking on a PR that correctly has no code-under-test.

---

## 5. Bottom line for the owner

The test *doctrine* is excellent and the infrastructure to execute it already exists. The danger is not weak tests — it is **strong tests pointed at a stale map**: at least four first-sprint defects are already fixed on disk, and one (drift-gate `unknown`) is a documented decision the plan is about to reverse. Without the re-baseline step (change #1) and the fails-on-pre-fix gate (change #2), several first-sprint PRs would ship green tests that prove nothing — the exact "test passes while the defect's status is unchanged" failure the QA charge exists to prevent. With those two process changes plus the six test-design re-scopes (changes 3-8) and the three fixtures (change 9), the plan's test strategy becomes genuinely adversarial and the "armed and instrumented" claim becomes *measurable* rather than asserted.
