# Plan Review — Eval Engineer seat (AXON Re-Arm)

> Council seat: **Eval Engineer** (ai-ml / evaluation). Lens: do the PRs' *tests* actually
> measure what the PRs *claim* — or can each pass while the defect survives? Is the
> grandfather a sound ratchet? How is the drift meter validated, and where will tests be
> vacuous/flaky? ADVISORY ONLY. Read-only audit of the live tree at
> `/home/arturcastiel/projects/new-axon/axon`. Sibling reviews already in this dir
> (`qa-test-architect.md`, `devops-ci-engineer.md`, etc.) — this seat does NOT re-litigate
> their ground; it adds the calibration/decision-relevance/slice-coverage layer.

---

## 1. VERDICT

**SOUND-WITH-RISKS** — confidence **HIGH** (0.85).

The method ("redo-until-closed: every PR ships a STRONG test; security/gate PRs
reproduce-then-block; no fingerprint-only") is exactly the right *rubric* and it is the single
most important thing this plan gets right. The backlog is decision-ordered (Tier 0 first,
because no later metric is trustworthy until the meter reads real data and the flags bite) —
that is textbook "what decision does this metric support?" discipline.

But the plan states test *claims*, not test *specifications*, and at the resolution it gives
them, **at least four first-sprint PRs have a test that can pass while the defect remains** —
the precise failure the report itself flagged at `test_crucible_failopen.py` (which I confirmed
monkeypatches BOTH resolvers, lines 21-22). The acceptance bar must move from "a test is green"
to "the test FAILS on the pre-fix tree and PASSES on the post-fix tree, with no mock standing in
for the code under test." Two structural gaps compound this: (a) the drift meter (PR-T0-1) has no
end-to-end fidelity validation, only a smoke test, and (b) the grandfather (PR-T1-5/OD-5) is
modeled on `liveness-allow.txt`, which I verified has **no shrink-only guard today** — so the
ratchet must be *built*, not *inherited*.

Not NOT-SOUND: every gap below is closeable by tightening a test spec, not by re-planning. The
architecture, ordering, and the "reproduce-then-block" instinct are correct.

---

## 2. WHAT THE PLAN GETS RIGHT (defend before I attack)

- **Decision-first ordering is real, not vanity.** Tier 0 before everything because "without
  A1/A2 the system can't tell whether later fixes worked" (01-study §Method). This is the
  eval-engineer's first question — *what decision does the metric inform?* — answered correctly at
  the program level. The falsifiable drift prediction in `01-study` ("instrument → if drift
  subsides it was process wearing a model costume") is a genuine hypothesis with a pre-registered
  outcome. That is good experiment hygiene.

- **"Reproduce-then-block" is the correct gate rubric** for security/gate PRs (PR-T1-1, T1-3,
  T2-1, T2-2, T2-clone, T3-2). It encodes the right ordering: the test must witness the *defect*
  before it witnesses the *fix*. PR-T1-1's "NO monkeypatching" and PR-T1-3's meta-assert ("no R13
  test monkeypatches both resolvers") are exactly the anti-mock guardrails I would demand, and the
  plan put them in unprompted. This is rare and worth crediting.

- **PR-T1-3 correctly identifies the poisoned test.** It names `test_crucible_failopen.py` as
  enshrining the bypass and re-points it. Confirmed at the source: lines 21-22 do
  `monkeypatch.setattr(crucible, "_changeset_base", lambda...: None)` AND
  `monkeypatch.setattr(crucible, "changed_files", lambda...: [])` — i.e. it asserts fail-closed
  *only because both return values are forced*. The plan saw this. Good.

- **PR-T0-2a sequenced before PR-T0-2** is the one place the plan already prevents a vacuous
  pass: flipping `terminal-outputs-required` against an empty `# emits:`/`outputs:` SSOT would
  gate nothing (the flag bites 0% of transitions). Seeding the SSOT *first* means the gate has
  something to fire on. This is slice-coverage thinking applied correctly.

- **PR-T1-4 enumerates the loophole *classes*** (add-only / rename-launder / typo-a-filename) as
  fixtures, not a single happy-path. That is stratified-eval-set design, not a pass-rate.

---

## 3. RANKED RISKS / GAPS (each tagged with the PR it touches)

### R1 — [CRIT] PR-T0-2's per-rule test is the single highest vacuous-pass risk in the sprint.
PR-T0-2's claim: "with flags on, each rule returns BLOCK on a violating fixture and PASS on a
clean one (per-rule)." Three problems make this passable while the arming is broken:

1. **No "flags OFF ⇒ no BLOCK" arm.** A real arming test is a 2×2: {flag on, flag off} ×
   {violating fixture, clean fixture}. The plan only specifies the {flag on} row. Without the
   {flag off ⇒ WARN/PASS} row, the test cannot distinguish "the flag armed the rule" from "the
   rule was already BLOCK regardless of the flag." That is the difference between testing the
   *fix* and testing the *rule*. I verified the mechanism this must exercise:
   `r_memory_respected._is_required` (lines 38-43) reads `memory_respected_required` from `state`
   first, then falls back to the on-disk flag file — so the test MUST drive both the state-injected
   path and the on-disk-flag path, and assert WARN→BLOCK *transition*, not absolute BLOCK.
2. **Six rules, one claim — no slice breakdown.** "each rule" hides six independent gates
   (state-surfaced, reasoning-trace, phase-tracking, terminal-outputs, workflow-node-order,
   no-orphan-tools). An aggregate "all green" can hide that one rule reads the flag from the wrong
   key or path. **Require a per-flag PASS/BLOCK/WARN matrix in the PR body**, one row per flag,
   or the PR is not closeable.
3. **Injected-corpus escape hatch.** `r_new_needs_test.check` (lines 137-145) accepts an injected
   `test_corpus`/`test_files` "for testability." A fixture that injects these bypasses the real
   disk resolution — the same mock-the-defect shape. The per-rule fixtures must drive the
   on-disk path for at least one rule, or note explicitly why injection is faithful here.

### R2 — [CRIT] PR-T1-1's "no monkeypatching" is necessary but not sufficient — it can still pass on a green-by-luck repo.
The defect is a *disagreement between two resolvers on a shallow/single-commit checkout*
(confirmed: `crucible.py:131` fallback `git rev-parse HEAD~1` lacks `2>/dev/null`; `:155` has it
on both clauses). PR-T1-1's test ("single-commit repo, base=None → ok is False") is correct in
spirit but under-specified in two ways that let it pass while the bug lives:

- **The fixture must reproduce the *disagreement*, not just a fail-closed.** After T1-1 collapses
  the two functions to one resolver, the *only* way to prove the collapse worked is a test that
  would have FAILED against the two-resolver tree. **Pre-register it: run the new test against the
  current `crucible.py` HEAD and confirm it goes RED, then against the patched tree and confirm
  GREEN.** A test that is green on both trees proves nothing — it is a fingerprint, not a gate.
  The redo-until-closed method demands this; the PR claim does not yet encode it.
- **Single-commit is one of three base-resolution states.** The base resolves differently for:
  (a) repo with `origin/main` + history (merge-base path), (b) repo with `HEAD~1` but no origin
  (rev-parse fallback path — *this is the leaky clause*), (c) single-commit / no `HEAD~1`
  (unresolvable → must fail closed). PR-T1-1 names only (c). **The fix lives in (b)**; the test
  set must cover all three or it will green on (c) while (b) — the actual defect surface — stays
  broken. This is a stratified-slice gap, and it is the exact slice the bug hides in.

### R3 — [HIGH] PR-T1-5 / OD-5 grandfather: the "shrink-only" ratchet is asserted as inherited but does not exist in the model it cites.
OD-5 and PR-T1-5 say the grandfather "mirrors `liveness-allow.txt`" and is "append-forbidden, can
only shrink." I read `tools/liveness-allow.txt` and its consumers (`tools/liveness.py:30`,
`tests/test_liveness.py`, `tests/test_reaudit_liveness.py`): **it is a plain newline allowlist with
NO append-forbidden / shrink-only guard anywhere.** Nothing today fails a test when an entry is
*added* to it. So:

- The ratchet PR-T1-5 promises (monotonic shrink toward zero) is a **net-new control that must be
  built**, not a pattern that exists to copy. The PR change-text ("adopt ... mirrors
  liveness-allow.txt") reads as if the ratchet comes for free. It does not.
- **The ratchet test is itself the load-bearing artifact and it has a subtle vacuity risk.**
  PR-T1-5's test ("adding an entry fails the gate; removing one passes") needs a *baseline-diff*
  mechanism: shrink-only is a property of the *delta vs the committed baseline*, not of the file
  in isolation. If the test only checks "file is well-formed," any future PR can append silently.
  **Specify the baseline source** (git-committed version? a frozen hash? `liveness-allow.txt`
  already lacks this, which is why it grew from 2 to 4 entries — see its own comments). Mirror the
  *intent*, fix the *gap*, do not inherit the gap.
- **Decision relevance check passes:** a frozen shrink-only exempt set IS decision-relevant (it
  bounds the corpus that can ship untested and forces monotonic coverage). The *concept* is sound;
  the *implementation-by-analogy* is the risk.

### R4 — [HIGH] PR-T0-1 drift meter: the validation is a liveness smoke test, not a fidelity test — the meter can read "real" data that is wrong.
PR-T0-1's test: "PostToolUse hook fires → trace file gains the actual call; drift.py computes a
non-empty verdict." This proves the *wire is connected* (non-empty trace). It does NOT prove the
meter *measures correctly*. The entire downstream verdict chain — OD-2's fail-closed gate
(PR-T3-2), the §4 drift root-cause attribution (60/30/10), and the OD-8 thin-kernel experiment
(PR-T6-exp) — rests on this meter being *calibrated*, not merely *plugged in*. An uncalibrated
meter that records real-but-misaligned `actual` sequences will produce a confidently-wrong drift
score, and every decision built on it inherits that error. Specifically:

- **The name-resolution seam is uncalibrated.** `drift.py:script_to_tool_name()` maps
  `tools/foo.py` stems to canonical registry names; `extract_expected()` and the PostToolUse
  interceptor must agree on that mapping or `expected` and `actual` are in different alphabets and
  every edit-distance is garbage. **Require a golden-trace fixture**: a known program with a known
  expected sequence, replay a known *actual* sequence through the real hook, assert the score
  equals a hand-computed value (e.g. 1 substitution over 5 calls → score 0.20 → "drift"). This is
  the LLM-as-judge-calibration analogue: the grader (drift.py) needs its own eval.
- **Three slices, hand-labeled:** (i) actual == expected → score 0.0 / stable; (ii) one
  divergence → score in the drift band; (iii) total reorder → score ≥ 0.40 / diverged. The PR
  currently asserts only "non-empty verdict" — that is the pass-rate-without-slices anti-pattern.
  Without slice (i) you cannot show a *clean* run reads stable; without (iii) you cannot show a
  *bad* run reads diverged. A meter that only proves "not empty" is decoration with a wire.

### R5 — [HIGH] PR-T3-2's "unknown→BLOCK" test must reproduce the original silent-pass, and the meter it depends on (T0-1) feeds it.
`r_drift_gate.py:62` currently does `if drift_state == "unknown": return None` (silent pass at the
response gate). PR-T3-2 flips it to BLOCK. The test ("unknown/stale → BLOCK; real stable →
PASS") is the right shape, but: (a) it must **assert the pre-fix tree returns None / no-fire** for
the same fixture (reproduce-then-block — confirm RED-before), and (b) "real stable trace → PASS"
requires a *genuinely fresh* trace, which only exists once PR-T0-1's interceptor writes one with a
current `recorded_at` — otherwise the TTL staleness path (`drift.py:273`,
`DRIFT_TRACE_TTL_S=7200`) silently routes "stable" fixtures into "unknown" and the test passes for
the *wrong reason* (flaky on wall-clock). **Pin `recorded_at` to `now()` in the fixture and
control the TTL**, or this test is time-bomb-flaky in CI.

### R6 — [HIGH] PR-T1-4's loophole fixtures are correct classes but the status-slice will be missed.
I confirmed `r_new_needs_test.check` (line 150): `if status != "A": continue` — only *Added*
files are classified. So the "rename-launder" bypass (PR-T1-4) is real: a renamed file arrives as
status `R` and is skipped entirely; the PR's own change-text says "gate status in {A,R,C} not
A-only." Good. But the **fixture must drive the rule with a status-`R` changed_files entry and
assert BLOCK**, and the *credible-reference* tightening must be tested against a `tests:` field
that points at a **non-existent path** (the `os.path.exists` fix) — `_declared_tests` currently
trusts the field's mere presence. A fixture that declares `tests: tests/test_real.py` where the
file exists will pass under both old and new code → vacuous. The negative fixture (declared-but-
missing path) is the load-bearing one and must be named.

### R7 — [MED] PR-T2-1 / PR-T2-2 security tests assert ALLOW/DENY but not "neutralization is prevented."
PR-T2-2's claim ("Write into tools/rules/*.py BLOCKED with dev-mode OFF") is necessary. But the
*decision* the test supports is "R9 cannot be neutralized." The stronger, decision-relevant test:
**after the protection lands, attempt the neutralizing write, then assert R9 still fires on a
subsequent `axon/` write** — i.e. prove the guard is intact post-attack, not merely that one
write was denied. Same for PR-T2-1: assert that a denied dev-mode toggle leaves dev-mode actually
OFF (read it back), not just that the write returned DENY. Reproduce-then-block here means
*reproduce the neutralization*, which the current claim does not.

### R8 — [MED] No regression-threshold / no-net-new-vacuous-tests meta-gate across the sprint.
The method says "no fingerprint-only" but nothing *enforces* it beyond PR-T1-3's single
meta-assert (scoped to R13 resolvers). The same "mock both sides" pattern can recur in any future
gate PR. **Generalize PR-T1-3's meta-assert into a sprint-wide lint**: a test that scans
`tests/` for any gate/security test that monkeypatches the *function under test* on both the
defect path and its resolver. This is the one control that makes "redo-until-closed" mechanically
true instead of reviewer-dependent. Cheap; high leverage; prevents the exact regression that
created `test_crucible_failopen.py`.

### R9 — [MED] PR-T6-exp (thin-kernel experiment) has no pre-registered metric, n, or stopping rule.
The OD-8 experiment is the highest-variance decision in the backlog ("may re-scope the whole
backlog"). Its test claim is "a reproducible protocol + a written verdict with drift deltas." For
an experiment that can re-scope everything, that is under-specified to the point of being
unfalsifiable: **pre-register the drift metric (which score? mean? p95?), the number of runs n,
the effect size that counts as "thin-kernel drifts less," and the stopping rule** — *before*
running, so the verdict cannot be rationalized post-hoc. And critically: this experiment's
validity is entirely downstream of R4 (an uncalibrated meter makes the OFF-vs-ON delta
meaningless). **Gate PR-T6-exp on PR-T0-1 passing the *calibration* test in R4, not just its
liveness test.**

---

## 4. SPECIFIC CHANGES TO THE PLAN (before execution)

Ordered by leverage. Each is a test-spec tightening, not a re-plan.

1. **(R8, do first — it protects all the others) Add a sprint-wide anti-mock meta-gate.**
   Promote PR-T1-3's "no R13 test monkeypatches both resolvers" into a generic lint over `tests/`
   that flags any gate/security test mocking the function-under-test on both defect and resolver
   paths. Make passing it a closure condition for every Tier 1/2/3 PR. This is what makes
   "no fingerprint-only" mechanical.

2. **(R2, R5, R7) Make "reproduce-then-block" literal: require a RED-before / GREEN-after
   transcript in every gate/security PR.** Closure condition: the new test must be shown FAILING
   on the pre-fix tree (HEAD) and PASSING on the post-fix tree. A test green on both trees does not
   close the PR. Touches PR-T1-1, T1-3, T1-4, T2-1, T2-2, T2-clone, T3-2.

3. **(R1) Rewrite PR-T0-2's test claim to a per-flag 2×2 matrix.** {flag on, flag off} ×
   {violating, clean}, one row per flag (6 flags). Closure = the WARN→BLOCK *transition* is
   demonstrated per flag, driving the on-disk-flag path for at least one rule (not only injected
   state). Forbid aggregate "all green" as closure.

4. **(R4, R9) Split PR-T0-1 into wire + calibrate.** Keep the liveness smoke test, but ADD a
   golden-trace calibration test: known program + replayed known actual sequence → assert the
   hand-computed score and band on three slices (match / one-divergence / reorder). Gate PR-T3-2
   and PR-T6-exp on the *calibration* test, not the smoke test. Pin `recorded_at`/TTL in all
   downstream drift fixtures to kill wall-clock flakiness.

5. **(R3) Rewrite PR-T1-5 to BUILD the shrink-only ratchet, not inherit it.** Specify: (a) the
   baseline source (git-committed file or frozen hash); (b) a test that diffs current-vs-baseline
   and FAILS on any added line; (c) a test that a brand-new neuron NOT in the list still BLOCKs.
   Drop the "mirrors liveness-allow.txt" framing — that file has no such guard; backport the
   ratchet to it as a stretch item so the model and the copy don't diverge further.

6. **(R6) Name the load-bearing negative fixtures in PR-T1-4.** Required fixtures: a status-`R`
   renamed file (asserts BLOCK), a `tests:` field pointing at a NON-EXISTENT path (asserts BLOCK
   via the new `os.path.exists`), and a short-stem incidental-substring case (asserts BLOCK — the
   BF-004 class). A fixture whose declared test path *exists* is vacuous and must not be the only
   one.

7. **(cross-cutting) Add a slice-reporting requirement to the method.** "redo-until-closed" should
   require, in each gate PR body, a small PASS/BLOCK/WARN table over the rule's input slices — not
   a single pass/fail. This is the cheapest way to stop aggregate green from hiding a dead slice,
   and it directly serves the §4 drift verdict, which needs slice-level drift data to be revised
   at all.

---

## 5. One-line method endorsement (for the owner)

The "redo-until-closed / reproduce-then-block / no-fingerprint" rubric is correct and rare — keep
it. The gap is that the PRs ship *test claims*, and a claim is not a spec: tighten each
first-sprint claim into a RED-before/GREEN-after, slice-reported, no-mock-of-the-thing-under-test
specification, and build (do not inherit) the drift calibration and the shrink-only ratchet. Do
that and the sprint moves from "armed and instrumented" to "armed and *measured* to be armed."

---

*Eval Engineer seat — AXON hr-team catalog (`catalog/professions/ai-ml/eval-engineer.md`).
Advisory only; read-only verification on the live tree 2026-06-19. Confirmed at source:
`tools/crucible.py:131/155` resolver disagreement; `tests/test_crucible_failopen.py:21-22`
double-monkeypatch; `tools/rules/r_drift_gate.py:62` unknown→None; `tools/drift.py` TTL/score
path; `tools/liveness-allow.txt` has no shrink-only guard;
`tools/rules/r_new_needs_test.py:150` status!="A" rename loophole. No code, programs, or state
modified.*
