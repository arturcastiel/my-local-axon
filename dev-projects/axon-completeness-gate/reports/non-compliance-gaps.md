# AXON Advisory Council — Non-Compliance & Gaps

**Council:** Full-form AXON advisory council
**Topic:** Programs/tools that do NOT comply with AXON's own rules (Core Rules, Neuron Contract, the test requirement Core Rule 13, state-surfacing), plus gaps in coverage and enforcement.
**Charter:** READ-ONLY, ADVISORY ONLY. Findings are static-analysis / empirical-probe derived; no pytest/builds were run by the synthesizer beyond read-only verification of cited lines.
**Seats synthesized:** Seat 1 (Rule-Compliance Lens) · Seat 2 (Contract / Test-Requirement Lens) · Seat 3 (Enforcement-Gap Lens) · Seat 4 (Challenger / Most-Consequential).

---

## 1. Executive Summary

AXON's compliance **architecture is unusually rigorous and — rarer still — self-honest.** The kernel openly concedes the gap between what it asserts and what it enforces (`axon/KERNEL-SLIM.md:89-95`, the "Enforcement reality" note). The tool registry has zero orphans/zero missing scripts, phase-tracking is universal across 172 programs, the four runner lists are parity-locked by a manifest + lock-test (`tools/rules/manifest.py` + `tests/test_rules_manifest.py`), and the codebase carries a real history of named self-corrections (BF-004, C10, F38, F04). All four seats agree on this strength.

But all four seats also converge on one structural pattern and one flagship bug:

- **The recurring pattern (Seats 1, 3):** The kernel describes its loudest rules as `HALT` / `!CRIT` / "cannot be bypassed," while the live wiring runs most of them as **WARN, lint-only, or dormant-until-an-activation-flag-is-set.** On this checkout, **no `*-required.md` activation flag exists on disk**, so Core Rules 6, 11, and 12 (grounded claims, cognition language / reasoning trace, menu render) have **no live mechanical bite**. The only runtime invariant that bites unconditionally is identity/coherence (`R_COHERENCE`, empirically verified by Seat 3).

- **The flagship bug (Seat 4, the most consequential finding):** Core Rule 13 — "new programs and tools require tests," the *one* rule the kernel elevates to mechanical, fail-closed, pre-merge BLOCK status — **fails OPEN in CI.** On the single-commit / shallow checkout that `actions/checkout@v4` produces by default, the two base-resolver functions in `tools/crucible.py` **disagree**: `_changeset_base()` (line 155, `2>/dev/null` on both clauses) returns the literal string `"HEAD~1"` (truthy) instead of `None`, so the fail-closed guard at `crucible.py:189` never fires; meanwhile `changed_files()` (line 131, **missing** `2>/dev/null` on the `rev-parse` clause) diffs against the broken base, gets an empty result, and the rule sees zero changed files and returns no violation. **A new untested neuron arriving via PR passes the gate.** The unit test that should catch this (`tests/test_crucible_failopen.py:18-26`) monkeypatches *both* resolvers to the post-condition it is meant to detect, so it can never observe the real `git`-shell defect.

**Net council position:** AXON's *static/merge* enforcement of Core Rule 13 is well-designed and well-hardened *in intent*, but it is (a) defeated in the actual CI environment by a resolver bug, and (b) riddled with sanctioned coverage loopholes that reduce "tested" to "a plausible filename was typed" or "a string mentions the neuron." Its *runtime* enforcement tier is almost entirely opt-in and dormant by default. The kernel's honesty about this is a genuine asset, but **honesty is not enforcement** (Seat 3). The highest-leverage, smallest-change fixes are concrete and listed in §3.

---

## 2. Detailed Findings (file-cited)

### 2.A — What is genuinely STRONG (do not regress these)

These are affirmed across multiple seats and should be explicitly preserved by any remediation.

- **S1. The hook chain is real and exit-2 capable.** `.claude/settings.json` wires `PreToolUse → enforce_pretooluse.py` (denies axon/ writes + dont-do at the keystroke), `Stop → verify_stop.py` (honestly LOG-ONLY — "a Stop hook cannot un-send," `verify_stop.py:7-9,108-130`), and `UserPromptSubmit → next_turn_gate.py` (consumes a persisted BLOCK to `sys.exit(2)` on the next turn, `next_turn_gate.py:77-90`). Gate-on-next-turn is a legitimate, documented workaround for an unblockable surface. (Seats 1, 3)

- **S2. Tool-registry integrity is airtight.** Zero orphan `.py` tools, zero missing registry scripts (178 registered ≥ 177 on disk), 0 PLANNED tools, 160 ACTIVE, all scripts present. `R_NO_ORPHAN_TOOLS` + `registry_drift` + `R_NO_PLANNED_TOOLS` do their job. (Seat 1)

- **S3. Phase-tracking is universal.** 0/172 programs lack a phase-tracking signal (`active-phase`/`DONE`/`FAIL`/`CHECKPOINT`); the kernel's "every program MUST" (`KERNEL-SLIM.md:333-338`) holds corpus-wide. (Seat 1)

- **S4. The manifest anti-drift lock is the single best enforcement-integrity mechanism in the repo.** `tools/rules/manifest.py` + `tests/test_rules_manifest.py` lock the four disjoint runner lists (verify/crucible/lint/audit) so a rule cannot silently drop from a gate (fixes F38). (Seats 1, 3)

- **S5. Core Rule 13 has a real mechanical spine — in intent.** `R_NEW_NEEDS_TEST` (`tools/rules/r_new_needs_test.py`, STATIC/BLOCK) → `crucible.py changeset` → `changeset-rules` BLOCK control in `tools/crucible.json` → `crucible.py gate` → CI (`.github/workflows/ci.yml:127`). `tests/test_ci_runs_crucible.py` lock-tests the CI step string and asserts every BLOCK control has a runnable `cmd`. The rule itself is well-tested (14 cases). **Caveat: this spine is the very thing Seat 4 proves is defeated in CI — see 2.D.** (Seats 2, 3, 4)

- **S6. Fail-closed design is applied in the right places.** `cmd_gate` refuses to pass on empty/missing/broken registry (`crucible.py:259-273`); `run_changeset` is *intended* to fail closed on an unresolvable base (`crucible.py:189-196`). (Seats 2, 3, 4)

- **S7. BF-004 was a real fix.** The old `stem in test_corpus` substring check (which let `log`/`run`/`test`/`merge` pass on incidental substrings) was replaced by `_credible_reference` (`r_new_needs_test.py:101-112`), requiring a structured token. `test_incidental_substring_no_longer_counts` locks it. (Seats 1, 2, 3)

- **S8. `scaffold` respects the contract honestly.** `tools/synapse_scaffold.py` defaults new neurons to `STUB` (R13-exempt, not dispatched); only `--active` emits "status ACTIVE + generated contract test." It does not let you mint an ACTIVE untested neuron. (Seat 2)

- **S9. Identity/coherence bites unconditionally at runtime.** Empirically verified (Seat 3): `verify.py output --text "As an AI language model..."` returns `passed: False, blocks: 1` via `R_COHERENCE` (BLOCK, no flag required). This is the one runtime invariant that is not opt-in. (Seats 1, 3)

- **S10. The kernel is self-honest about enforcement reality.** `KERNEL-SLIM.md:89-95` explicitly states BLOCK-capable rules "bite mechanically ONLY when a host hook runs verify.py output every turn AND the per-rule `L:*-required` flags are set … Do NOT read 'enforced' as 'cannot be bypassed' until the hook + flags are active." This is rare and valuable; it should be preserved and referenced from individual Core Rules. (Seats 1, 3, 4)

---

### 2.B — The recurring pattern: prose says HALT, wiring says WARN/lint/dormant

**F-B1. Core-Rule enforcers are demoted to lint-only (advisory WARN at merge).** The rules enforcing the kernel's most absolute `!CRIT`/`HALT`-described Core Rules are wired ONLY into the `lint`/`audit` tier, never a blocking runner (`tools/rules/manifest.py`):
  - `r_cognition_language` (Core Rule 11, the `!CRIT` "critical violation") — `manifest.py:49 → ["lint","audit"]`
  - `r_identity_lock` (Identity Contract → "identity violation + HALT") — `manifest.py:51`
  - `r_inference_mode_lock` (immutable, "enforced as a Core Rule", `KERNEL-SLIM.md:306-312`) — `manifest.py:52`
  - `r_override_attempt` (the "cannot be bypassed" gate) — `manifest.py:54`
  - `r_phase_tracked`, `r_fail_format`, `r_neuron_role` — `manifest.py:50,55,53`

  All surface through `lint-summary-rules`, a **WARN** crucible control (`tools/crucible.json`, `severity=WARN`). A merge violating Core Rule 11 or the identity contract produces a *warning*, not a block. The verify response-gate runner (`registry.py::_collect_rules`) collects none of them. **Core Rule 11 — the kernel's loudest rule — has no BLOCK path anywhere.** (Seat 1)

**F-B2. `r_phase_tracked` is unreachable by its own documented activation flag.** Its docstring (`tools/rules/r_phase_tracked.py:9-17`) says "Activation: gated by `L:phase-tracking-required` → BLOCK … checked by verify.py." But it lives in `["lint","audit"]`, not in `verify`'s `_collect_rules()`, so `verify.py` never collects it and the flag it documents is never read at a blocking gate. **Doc says BLOCK; wiring says it can't.** (Seat 1)

**F-B3. Every per-turn runtime forcing-function is dormant by default.** On disk, a `find` for `*-required.md` under `workspace/memory/longterm/` returns **nothing** (verified independently by Seats 1 and 3; `verify.py status` self-reports `activation_flags_on_disk: {}`). So `R_REASONING_TRACE` (Core Rule 11 trace), `R_STATE_SURFACED`, `R_GROUNDED_CLAIMS` (Core Rule 6), `R_MENU_RENDERED` (Core Rule 12), `R_TERMINAL_OUTPUTS`, `R_TOOL_RECEIPTS`, `R_ADVERSARY_SCAN`, and the runtime path of `R_MEMORY_RESPECTED` all evaluate as WARN. A runtime WARN never fails the gate (`verify.py:259-269`, "halt-mode does NOT escalate a runtime WARN"). Empirically (Seat 3): `verify.py output` on a plain, ungrounded answer with no reasoning trace and no state block returns `passed: True`. **Net: Core Rules 6, 11, 12 have no live mechanical bite in this checkout** — directly contradicting the kernel's "MANDATORY / !CRIT — first step" labeling of the response gate. (Seats 1, 3)

**F-B4. Core Rule 9 write-gate is effectively open in this repo.** `host-cap-enforce = self`, `dev-mode = true` ("Enabled by owner"). The PreToolUse hook is installed, but with dev-mode true the axon/ write gate passes by design. Combined with F-B3, the two Core Rules the kernel treats as most sacrosanct (9 and 11) are both non-blocking in the live tree. *(Environment-specific to this checkout — see §5 caveat.)* (Seat 1)

**F-B5. The Stop-hook BLOCK is best-effort and silently expirable.** `verify_stop.py` is LOG-ONLY (always exits 0). The teeth are deferred to `next_turn_gate.py`, but `consume_pending_gate()` discards any pending BLOCK older than `_GATE_TTL = 3600` (1 hour) — "expired — let the session continue." A runtime violation at end-of-session, or before a >1h gap, **silently evaporates with no merge-time backstop** (runtime violations never reach the crucible changeset gate). Combined with F-B3, today's practical runtime enforcement surface is: `R_COHERENCE`/identity only. (Seat 3)

---

### 2.C — Core Rule 13 coverage loopholes (the contract is thinner than the prose)

**F-C1. The `tests:` contract field is never checked for existence or substance (BLOCK bypass).** `_declared_tests` (`r_new_needs_test.py:87-98`) accepts ANY value not in `_EMPTY_VALS` (`{"", "[]", "()", "none", "tbd", "todo", "n/a", "-"}`, line 38; the `not in` test is line 96). It **never calls `os.path.exists`.** Seats 2 and 3 proved a program declaring `# tests: tests/test_THIS_DOES_NOT_EXIST.py` passes the BLOCK gate (`check(...) → None`). No control closes this — `synapse_validate.py` only walks `tests/synapse/corpus/*.contract.json` (`:31,166`), never resolving `tests:` paths. This bypass is *asserted as intended* by `tests/test_rules/test_r_new_needs_test.py:79` (`test_declared_tests_field_passes`). **The kernel's "MUST ship tests" reduces to "MUST type a plausible-looking filename."** (Seats 2, 3)

**F-C2. Coverage = mention, not exercise.** `_credible_reference` (`r_new_needs_test.py:101-112`) accepts a bare `import <stem>` line anywhere in the corpus even if the tool is never called and nothing is asserted about it. Seats 2 and 3 proved `"import newtool # never called\ndef test_unrelated(): assert 1==1"` passes; this is enshrined by `test_credible_reference_still_passes` (`:113`). The rule enforces *name-linkage*, not behavioral coverage — and should be honestly relabeled as such. (Seats 1, 2, 3)

**F-C3. The gate fires ONLY on git status `A` (`r_new_needs_test.py:150`, `status != "A"` → skip; `crucible.py:149`).** Status `M`, `R`, `R100`, `C` all → "passes, no test required." This is *asserted as intended* by `test_grandfathering_only_added_status_counts` (`tests/test_rules/test_r_new_needs_test.py:72`). Two reproducible escapes:
  - **Rename/copy launder:** `git mv old.py new.py` + rewrite arrives as status `R` (copy as `C`), escaping the rule entirely. A new tool introduced via `git mv` ships with **zero test gate.** (Seats 1, 2)
  - **Stub-then-fatten:** land a trivial ACTIVE tool with a one-line passing test, then in a later commit (status `M`) replace the entire body with real, risky logic — no new test is ever required. (Seat 2)
  Enforcement inspects the *addition event*, never the *current* test state. (Seats 1, 2)

**F-C4. Scope hole — addon neurons are never classified.** `_classify` (`r_new_needs_test.py:48-62`) matches only `workspace/programs/*.md` and `tools/*.py`. Neurons under `workspace/addons/*/` (programs or Python) are never classified, so **addon neurons bypass the test requirement entirely.** (Seat 1)

**F-C5. "ACTIVE needs test" is NOT a standing invariant; the grandfather clause is enormous.** No control asserts `REGISTRY.status==ACTIVE ⟹ a real test exists`. Concretely:
  - **60 of 160 ACTIVE tools (37.5%)** and **154 of 172 programs (~90%)** have no `test_<stem>.py` file (Seat 2; Seat 1 cites 62/177, same order of magnitude — minor count discrepancy, see §5).
  - **0 of 178 tools** carry a `tests:` field; only **13 of 172 programs (~7.6%)** declare one (Seats 2, 3, 4). `tools/REGISTRY.json` entries have keys `script/status/category/purpose` — **no test field exists** — so "which ACTIVE neuron lacks a real test" is not queryable from the registry.
  - 9 fully-uncovered tools (`document_parser, notify, pack, pattern, pr_sync, queue_tool, rtk, study_evals, translate`) will never be flagged (Seat 3).
  Grandfathered untested neurons later `M`-edited never re-enter the gate (F-C3). The rule effectively governs only net-new files going forward. (Seats 1, 2, 3)

**F-C6. The Neuron Contract's `tests:` is REQUIRED on paper, aspirational in practice.** `NEURON-CONTRACT.md:59` declares `tests:` "REQUIRED (R_NEW_NEEDS_TEST)"; `:298-306` targets "≥80% of programs have at least an inferred contract." Reality: ~7.6% of programs carry it. `synapse-validate`'s own checks (`:267-291`) "flag in axon-audit output but do not block boot" (`:293`). Several Phase-3 deliverables it relies on (`predicate.py`, `synapse-validate` as a boot gate) are referenced as future work. **Strong spec, thin enforcement tail.** (Seats 2, 3, 4)

**F-C7. Programs are linted, not behaviorally tested — and the contract calls this "tests."** `tests/test_programs_md.py:83-179` checks only static structure (valid front-matter, no broken `EXEC()`/`TOOL()` refs). `program_tool_conformance.py:6-12` openly admits the asymmetry: *"Tools are unit-tested; the markdown call-sites that consume them are NOT."* A program can satisfy R13's "credible reference" via a structural-lint test that executes none of its actual logic; the contract's `tests:` field carries no obligation to exercise `post-state`/`goal-advances` — the very predicates it defines. (Seat 2)

**F-C8. `program_tool_conformance` BLOCKs only the workflow family.** A program invoking a tool flag the tool doesn't declare (e.g. `TOOL(todo, list, "--tag bug")` when only `--status` exists) only BLOCKs for the workflow family; conversational call-sites degrade to WARN (`program_tool_conformance.py:52,337`). Drift between a program's claimed tool-call and the tool's actual CLI is under-enforced outside workflows. (Seat 3)

**F-C9. No corpus-wide compliance instrument exists.** `conformance_scorecard.py list` returns 3 curated temptation scenarios (a benchmark catalogue), not a measurement of how many of the 172 programs / 160 tools comply. The only corpus instrument is the orphan/registry-drift check; identity/cognition/phase compliance is never measured in aggregate. (Seat 1)

---

### 2.D — THE MOST CONSEQUENTIAL NON-COMPLIANCE (Seat 4, empirically proven)

**F-D1. Core Rule 13's flagship BLOCK gate fails OPEN in CI on a shallow checkout.**

CI runs `python3 tools/crucible.py gate` (`.github/workflows/ci.yml`). The `gate` runs the `changeset-rules` BLOCK control, whose cmd is `python3 tools/crucible.py changeset` with **no `--base`** (`tools/crucible.json`, id `changeset-rules`). So `run_changeset(base=None)` executes, which is *supposed* to fail closed (`crucible.py:189-196`):

```python
if not changed and base is None and _changeset_base(base, cwd) is None:
    return {"ok": False, ... "R_CHANGESET_BASE" ...}
```

The two base-resolvers **disagree** (synthesizer-verified line-by-line):
- `changed_files()` (`crucible.py:131`) runs `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` — the **second clause has no `2>/dev/null`.**
- `_changeset_base()` (`crucible.py:155`) runs the same with `2>/dev/null` on **both** clauses, then `return r.stdout.strip() or None`.

On a single-commit repo (exactly what `actions/checkout@v4` produces by default — `fetch-depth: 1`, no `origin/main` ref; `ci.yml` sets no `fetch-depth`), Seat 4 confirmed empirically (`/tmp/axon_py_test`):
- `git rev-parse HEAD~1` exits 128 but **prints the literal string `HEAD~1` to stdout** (git echoes the unresolved arg).
- `_changeset_base()` therefore returns `"HEAD~1"` — **truthy, NOT None** → the `is None` guard is False → **the fail-closed path is never taken.**
- `changed_files()` uses base `"HEAD~1"`, runs `git diff --name-status HEAD~1...HEAD`, which fails rc=128 with **empty stdout** → `changed = []`.
- Falls through to `r_new_needs_test.check({"changed_files": []})` → returns **None** (no violation).

**Result: a new untested tool/program in a single-commit/shallow checkout produces ZERO violations and the gate PASSES.** The kernel's flagship BLOCK rule is bypassed by the CI runner's own checkout defaults.

**F-D2. The test suite cannot catch it because it mocks the defect away.** `tests/test_crucible_failopen.py::test_run_changeset_fails_closed_on_unresolvable_base` (`:18-26`) monkeypatches **both** `_changeset_base → None` AND `changed_files → []`. It asserts the guard fires only by hand-feeding it the post-condition it is meant to detect; it never exercises the real `git`-shell path, so it cannot observe that `_changeset_base()` returns `"HEAD~1"` (truthy) in the real single-commit case. No test runs the `changeset-rules` control end-to-end against a real shallow git tree. `tests/test_ci_runs_crucible.py` only string-matches `"crucible.py gate"` and checks every BLOCK control has a non-empty `cmd` — it proves the gate is *invoked*, not that it *bites*. This is unacknowledged: `grep` over `CHANGELOG.md`/`CONTEXT.md` for `fetch-depth|shallow` returns nothing. (Seat 4)

**Why this outranks every other finding:** Core Rule 13 is the one rule the kernel elevates to mechanical, fail-closed, pre-merge status (`KERNEL-SLIM.md` Core Rule 13: *"Enforced mechanically by `R_NEW_NEEDS_TEST` (static, BLOCK) … + the `crucible` gate before merge"*). With F-C1–F-C7 already reducing it to name-linkage and F-D1 making it inert in CI, **there is currently no mechanical floor at all** for the headline scenario — a new untested neuron arriving via PR. The corpus's compliance story is hollow at its foundation.

---

## 3. Prioritized Recommendations

Ordered by leverage (impact ÷ change-size). Recommendations converged across seats are marked.

**P0 — Restore the flagship gate's bite (Seat 4; smallest change, largest impact).**
1. **Fix the base resolver, not the symptom.** Replace the `|| git rev-parse HEAD~1` fallback in *both* `changed_files()` and `_changeset_base()` (`tools/crucible.py:131,155`) with `git rev-parse --verify HEAD~1` (the `--verify` form fails silently and prints nothing to stdout instead of echoing the arg). Then `_changeset_base()` returns `None` correctly and the existing fail-closed guard fires. **Collapse both functions to ONE shared resolver** so they can never disagree again — the duplication is the root cause.
2. **Set `fetch-depth: 0` (or `2`) and fetch `origin/main`** in the `crucible-gate`/`tests-full` jobs of `ci.yml`. Without history, even a corrected resolver can only fail closed on every PR (too blunt); the gate needs the merge-base to compute a real diff. This is the actual enable-condition for Core Rule 13 in CI.
3. **Add a real end-to-end test** that builds a throwaway single-commit git repo with a new untested `tools/X.py`, runs `run_changeset(base=None)` with **no monkeypatching**, and asserts `ok is False`. This is the test that would have caught F-D1.

**P1 — Close the Core Rule 13 coverage loopholes (Seats 1, 2, 3; ~5-line fixes each).**
4. **Close F-C1:** in `_declared_tests`, resolve each `tests:` entry against `repo_root` and require `os.path.exists` (ideally matching `tests/test_*.py`); reject a field naming zero existing files. Add a red test: declared-but-missing must BLOCK — and **re-point** `test_declared_tests_field_passes` (`:79`), which currently enshrines the bypass.
5. **Close F-C2:** tighten `_credible_reference` to require a `test_*` function token co-located with the stem reference, not a bare `import`. Until done, **relabel** the heuristic in the rule docstring as *name-linkage, not behavioral coverage* (apply the `KERNEL-SLIM.md:89-95` honesty norm here too).
6. **Close F-C3/F-C4:** gate `status in {"A","R","C"}` and re-point `test_grandfathering_only_added_status_counts` (`:72`) which enshrines the rename bypass; extend `_classify` to `workspace/addons/**/programs/*.md` and addon `.py`.

**P2 — Make "ACTIVE ⟹ tested" a standing, queryable invariant (Seats 2, 3).**
7. Add a `tests:` field to `REGISTRY.json` ACTIVE tool entries, and a **crucible BLOCK/audit control** (`active-neuron-needs-test`) that — independent of any diff — asserts every `status:ACTIVE` tool and every non-`_`/non-help ACTIVE program resolves to a real test. **Allowlist the genuine grandfathered set explicitly** in a `test-grandfather.txt` (mirroring `liveness-allow.txt`) so the ~214 untested neurons are *named and frozen*, and the list can only shrink. Backfill or explicitly mark the 9 grandfathered orphans (F-C5).
8. **Re-gate on `M`** (or a sibling rule): a substantive `M`/`R` to a neuron whose covering test file is unchanged in the same diff raises at least a WARN. Kills stub-then-fatten and rename-launder at the edit event.

**P3 — Reconcile prose vs. wiring for the runtime/Core-Rule tier (Seats 1, 3).**
9. **Promote the Core-Rule enforcers to a BLOCK surface** (F-B1): add `r_cognition_language`, `r_identity_lock`, `r_inference_mode_lock`, `r_override_attempt` to a blocking runner (e.g. `crucible.run_changeset`'s rule loop at BLOCK, or a dedicated BLOCK control). A rule described as "cannot be bypassed" must have at least one blocking surface; today none of them do.
10. **Decide and ship the default enforcement posture** (F-B3): either set the `*-required` flags ON in a governed profile (so Core Rules 6/11/12 bite out of the box) — at minimum `reasoning-trace-required` + `state-surfaced-required` while a phase is active — **or** soften the kernel's "MANDATORY/!CRIT" language so the spec matches the enforcement and reference the `:89-95` honesty note inline from Core Rules 11 and 12.
11. **Fix F-B2:** add `r_phase_tracked` to `verify`'s `_collect_rules()` so its documented `L:phase-tracking-required → BLOCK` is real, **or** correct its docstring to "lint/audit advisory only."
12. **Fix F-B5:** persist runtime BLOCK verdicts to an episodic ledger a merge-time crucible control inspects, so a runtime violation cannot expire unaddressed; make `_GATE_TTL` expiry log a WARN rather than vanish.

**P4 — Measurement & honesty (Seats 1, 4).**
13. Add a **corpus-compliance reporter** (F-C9): run all `lint`/`audit`-tier rules over the full corpus and emit one pass/fail-per-rule scorecard, so identity/cognition/phase compliance is measured in aggregate.
14. **Down-rank or back the kernel's Core Rule 13 claim:** "Enforced mechanically … + the crucible gate before merge" should either be made true (P0) or annotated with the same honesty already applied to the response/write gates. It is currently the one place the kernel claims mechanical enforcement that does not hold.

---

## 4. Open Questions / Dissent

The four seats are **strongly aligned** on the facts; disagreement is one of *emphasis and ranking*, plus two minor numeric discrepancies and several genuinely open design questions.

**D1 — What is the single most consequential gap? (ranking dissent)**
- **Seat 4** ranks the **CI fail-open (F-D1)** as #1, because Core Rule 13 is the only rule the kernel elevates to mechanical fail-closed status, and it is provably inert in CI. The challenger explicitly argues this "matters more than any prose/identity violation."
- **Seats 1 and 3** put comparable weight on the **dormant runtime tier (F-B1/F-B3)** — Core Rule 11 having no BLOCK path *anywhere* and Core Rules 6/11/12 having no live bite. Seat 1 calls Core Rule 11 "the kernel's loudest rule."
- **Seat 2** centers the **two reproducible BLOCK bypasses (F-C1 nonexistent-`tests:`-path, F-C3 add-only firing)** as the concrete, fixable holes.
- *Council note:* these are not mutually exclusive — F-D1 (gate inert) and F-C1–C3 (gate loopholes) compound: even if the gate fired, the loopholes would let neurons through; even with loopholes closed, F-D1 means the gate never fires in CI. **Fix both tiers (P0 + P1).** Whether the runtime tier (P3) is "non-compliance" or "intended opt-in" depends on D3 below.

**D2 — Numeric discrepancies (unresolved, low-stakes).**
- Untested ACTIVE tools: Seat 1 reports **62/177**; Seat 2 reports **60/160 (37.5%)**. Different denominators (177 on-disk vs 160 ACTIVE) and possibly different "covered" heuristics. Same order of magnitude (~35-37.5%); exact count should be settled by the corpus reporter (P-13).
- Tool count: "178 registered," "177 on disk," "160 ACTIVE" appear with slight variation across seats. Not material to any finding; flagged for the synthesizer's downstream audit.

**D3 — Is the dormant runtime tier a *bug* or a *deliberate opt-in default*?** The kernel's `:89-95` honesty note frames the `*-required` flags as legitimately opt-in. Seats 1 and 3 argue that shipping a rule labeled "MANDATORY/!CRIT" while disabled-by-default is *itself* a Core-Rule-coherence violation (the spec contradicts the enforcement). This is a **policy decision for the maintainers**, not a code bug: either set the flags ON in a governed profile, or soften the kernel prose. The council cannot resolve intent.

**D4 — Should the grandfather clause ever be retired?** ~35-90% of the corpus is grandfathered. Seat 2 proposes a named, frozen allowlist (`test-grandfather.txt`) that can only shrink; no seat proposes retro-gating all 214 untested neurons at once (that would be disruptive). Open question: what is the target glide-path for the grandfathered set, and who owns shrinking it?

**D5 — Structural ceiling of static-text coverage rules.** Seat 2 notes `_credible_reference` enforcing *name-linkage* is the structural ceiling of any static-text rule — it cannot distinguish a real test from a decoy import without executing tests or binding to `post-state`/`goal-advances` predicates (which depend on the not-yet-shipped `predicate.py`). Open question: is binding tests to contract post-conditions (P-rec implied) worth the Phase-3 dependency, or is honest relabeling sufficient for now?

**D6 — Read-only / environment caveats (shared by all seats).** Flag values and `dev-mode` were read from this specific checkout (`workspace/memory/longterm/*.md`, local keys); a different governed deployment could have flags set. The **wiring/structural findings (F-B1, F-B2, F-C1–C5, F-D1) hold regardless of flag state**; the *posture* findings (F-B3, F-B4) are environment-specific. No seat could run pytest/crucible (read-only charter), so heuristic-coverage results are static-analysis derived — **except F-D1, which Seat 4 verified empirically** with a throwaway git repo, and the synthesizer independently confirmed the resolver line-disagreement (`crucible.py:131` lacks `2>/dev/null`, `:155` has it).

---

*Prepared by the DELIBERATOR, Non-Compliance & Gaps council. Synthesis of 4 sealed Round-1 seat opinions. ADVISORY ONLY — no files modified except this report.*
