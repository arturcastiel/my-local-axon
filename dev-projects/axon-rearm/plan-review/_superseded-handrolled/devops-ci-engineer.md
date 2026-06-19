# AXON Re-Arm — Plan Review: CI / DevOps / Release Engineering

**Reviewer role:** CI / DevOps / Release Engineer
**Scope of charge:** PR-T1-1 / PR-T1-2 (resolver fix + `fetch-depth: 0`), the crucible merge gate, PR-T2-clone (fail-open-on-clone / OD-6), the enforcement-flag flip (PR-T0-2), the fail-closed-on-absent-state decision (OD-6), and the rollout/rollback + missing-CI-piece questions.
**Method:** read-only. Read all plan files + source handoff; verified the crucible resolver (`tools/crucible.py`), the live CI config (`.github/workflows/ci.yml`), the GitLab remote, git history, the enforcement hooks (`tools/hooks/*`), and reproduced the shallow/detached-HEAD CI checkout behavior in a throwaway repo. No code, programs, or workspace state modified.

---

## 1. VERDICT

**SOUND-WITH-RISKS** — confidence **HIGH**.

The plan's *diagnosis* is accurate (I re-verified the `crucible.py:131` vs `:155` resolver disagreement, the zero `-required` flags, the fail-open paths). The *fixes* (PR-T1-1 collapse-to-one-resolver, OD-6 fail-closed-on-absent-base) are the right code changes. But the plan rests on a **false premise about where these gates run**, and that premise is load-bearing for PR-T1-2 and the entire "armed in CI" objective. The single most important finding of this review:

> **There is no CI runner on the authoritative remote.** The remote is GitLab (`git@ci.tno.nl:artur.castiel-tno/axon.git`). The only CI config in the repo is `.github/workflows/ci.yml` (GitHub Actions), which **GitLab does not read.** Git history shows `.gitlab-ci.yml` was added (`42553cc`), then **deliberately removed** (`053391c ci: remove .gitlab-ci.yml — gates run locally now (no runner)`). So the crucible gate — the flagship pre-merge BLOCK this whole tier is built to re-arm — **fires only when a human or agent runs `python3 tools/crucible.py gate` by hand.** PR-T1-2 patches `fetch-depth` in a workflow file that never executes.

The plan is sound as a set of *code* fixes; it is not yet sound as a *release-engineering* plan, because it never establishes the execution substrate those fixes need. Fixable with the changes in §4, but this must be resolved before PR-T1-2 is scheduled.

---

## 2. WHAT THE PLAN GETS RIGHT

- **The resolver root-cause is real and correctly identified (PR-T1-1).** Confirmed on the live tree: `tools/crucible.py:131` runs `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` — the `rev-parse` clause is **not** silenced; `:155` (`_changeset_base`) silences **both** clauses. On a shallow/no-`origin/main` checkout the two provably diverge: `:131` returns the literal string `"HEAD~1"`, `:155` returns `""` → `None`. Collapsing to one resolver is exactly the right move; "one resolver can't disagree with itself" is correct.
- **"No monkeypatching" test mandate (PR-T1-3) is the right call.** The current `tests/test_crucible_failopen.py:21-23` monkeypatches *both* `_changeset_base` and `changed_files`, so it asserts the *intended* fail-closed behavior while the *real* `:131` defect goes untested. The plan's meta-assert ("no R13 test monkeypatches both resolvers") is a genuinely good regression guard.
- **OD-6 / PR-T2-clone fail-closed-on-absent-base is already partially shipped and the design is sound.** `run_changeset` (`crucible.py:189-196`) already returns `R_CHANGESET_BASE` BLOCK when base is unresolvable. The plan correctly insists on distinguishing "no active project" (legit) from "state suppressed" (block) and on heavy testing.
- **Tier-0-first sequencing is correct from a release standpoint.** You cannot certify that a gate fix works without a meter. Instrument (PR-T0-1) before flipping flags (PR-T0-2) is the right dependency order.
- **The `.bak` rollback reflex already exists.** `scripts/enable-enforcement.sh:21` snapshots `.claude/settings.json` before overwriting — a good instinct the plan can build the formal rollback story on.
- **The grandfather glide-path (PR-T1-5) mirrors a real, working precedent.** `tools/liveness-allow.txt` exists; the shrink-only/append-forbidden pattern is proven in-tree, so PR-T1-5 is low-risk.

---

## 3. WEAKNESSES / RISKS / GAPS (ranked by severity)

### S0 — CRITICAL — There is no CI runner; the gate's execution substrate is undefined. (PR-T1-2, PR-T1-1, crucible-gate, the whole Tier-1 objective)
`git@ci.tno.nl` is GitLab; `.github/workflows/ci.yml` is GitHub Actions and is **inert on that remote**. `.gitlab-ci.yml` was removed on purpose (`053391c`, "gates run locally now (no runner)"). Consequences:
- **PR-T1-2 as written is a no-op.** It sets `fetch-depth: 0` on `.github/workflows/ci.yml` jobs that never run. Even if you point it at a real `.gitlab-ci.yml`, that file does not exist.
- The crucible gate is currently **advisory-by-absence** — it only blocks a merge if someone remembers to run it locally. Re-arming the *resolver* (PR-T1-1) hardens a gate that nothing automatically invokes. The plan's headline ("restore the flagship gate's bite") is half-true: the bite is restored only for manual invocations.
- The plan's own §Method says "crucible-green before test-execution" and "gates cannot be broken (no --force)" — but with no server-side runner and no protected-branch rule, **nothing mechanically enforces crucible-green.** This is the T2 theme ("honesty ≠ enforcement") reappearing one level up: the gate is real, its *invocation* is dormant.

**This must be decided before PR-T1-2 runs.** Either (a) restore `.gitlab-ci.yml` with a live runner and protected-branch "pipeline must succeed to merge," or (b) consciously adopt a local/pre-push/pre-merge-hook enforcement model and rewrite PR-T1-2 to target *that* (e.g. a `pre-push` hook or a `crucible gate` step in the merge program), and strike the CI framing. Right now the plan assumes (a) without verifying it exists.

### S1 — HIGH — `fetch-depth: 0` does NOT guarantee a usable `origin/main` ref on a GitLab runner. (PR-T1-2, PR-T2-clone)
Reproduced: with `GIT_STRATEGY=fetch` fetching only the pipeline branch ref (GitLab's common default), `refs/remotes/origin/main` is **absent** even at unlimited depth, so `git merge-base HEAD origin/main` **fails** regardless of `fetch-depth`. `fetch-depth: 0` fixes *shallowness*; it does not fix *which refs were fetched*. On GitLab the merge-base of an MR is typically `$CI_MERGE_REQUEST_DIFF_BASE_SHA` (or you must explicitly `git fetch origin main`). The interaction with OD-6 is the dangerous part:
- PR-T1-1 + OD-6 make an unresolvable base **fail closed**.
- If the runner doesn't have `origin/main`, the base is unresolvable on **every** MR.
- Result: **every MR pipeline blocks** with `R_CHANGESET_BASE` — a self-inflicted hard-stop on all merges (the false-positive storm, but at the merge gate rather than per-turn). The plan flags fetch-depth but **not** the ref-availability problem, which is the actual failure mode on this remote.

PR-T1-2's change spec must be: `fetch-depth: 0` **and** an explicit `git fetch origin main:refs/remotes/origin/main` (or resolve the base from `$CI_MERGE_REQUEST_DIFF_BASE_SHA` on GitLab), with the resolver preferring an env-provided base before falling back to `merge-base`.

### S2 — HIGH — A second fail-open path in `changed_files()` survives PR-T1-1 as scoped. (PR-T1-1, PR-T1-3)
`changed_files()` (`crucible.py:128-145`) uses the *`:131*` form and then runs `git diff --name-status {base}...HEAD`. I reproduced that when `base` is the literal `"HEAD~1"` (the `:131` fallback on a shallow clone), `git diff ... HEAD~1...HEAD` **exits 0 with empty stdout** (the fatal goes to stderr, which the code does not check) → `changed_files` returns `[]` → the gate sees an empty change-set. The OD-6 guard at `:189` only fires when `_changeset_base` *also* returns `None`; but `changed_files` and `_changeset_base` use **different** base-resolution code, so they can disagree about whether a base exists. PR-T1-1's "one resolver" must be the resolver used by **both** `changed_files` *and* the empty-diff guard, and the resolver must treat a `git diff` that errors (nonzero, or stderr-fatal) as unresolvable — not as "empty diff." The plan says "collapse to one resolver" but the test (PR-T1-3) only covers `base=None`; add a fixture for the `base="HEAD~1"-literal-on-shallow-clone` case explicitly.

### S3 — MEDIUM/HIGH — PR-T0-2's false-positive blast radius is mis-located in the plan; the real risk is the merge gate, not live sessions. (PR-T0-2, PR-T0-2a)
Good news the plan undersells: I verified the live per-turn hooks. `tools/hooks/enforce_pretooluse.py` invokes only **R9 + R_DONT_DO** (not the six `-required` rules), and `tools/hooks/verify_stop.py` is **LOG-ONLY and always `sys.exit(0)`** (its own docstring: "exit-2-blocking would risk bricking a session on a false positive, so the crucible MERGE gate is where rules BLOCK"). So flipping the `-required` flags **does not brick interactive sessions** — that fear, as the plan frames it, is largely unfounded. But the flip *does* arm those rules at the **crucible changeset/merge gate**, and that's where the real false-positive storm lands:
- `r_terminal_outputs` BLOCKs on any `:done` token whose program declares `# emits:` artifacts that aren't on disk. PR-T0-2a seeds `# emits:`/`outputs:` *first* — correct — but seeding **expands** the set of programs that now gate. If the seeded `outputs:` don't perfectly match what programs actually emit, every affected merge blocks. The dependency `PR-T0-2a → PR-T0-2` is right, but **PR-T0-2a needs its own pre-flight: run the gate in report-only mode against the current corpus and count would-be BLOCKs before flipping.** The plan has no canary/dry-run step.
- The plan should state explicitly that the flip is at the merge gate, so reviewers don't over-engineer a session-bricking defense that isn't needed, and instead build the dry-run the merge gate *does* need.

### S4 — MEDIUM — Rollout is all-or-nothing; there is no canary, no report-only mode, and no staged flag enablement. (PR-T0-2, PR-T1-1, PR-T1-2)
`run_changeset`/`verdict` are binary pass/fail. There is no "shadow"/"report-only" severity that runs a newly-armed rule and *records* its verdict without blocking — the standard way to introduce an enforcement gate without a merge freeze. Flipping six flags at once (PR-T0-2) means the first MR after the flip eats the combined false-positive surface of all six. Recommend a `CRUCIBLE_REPORT_ONLY=1` env (or a per-control `severity: SHADOW`) so each flag can ride one or more MRs in observe-mode, then be promoted to BLOCK. This is cheap and turns a risky big-bang into a measured rollout — which is also exactly what the project's own A1 "meter-first" philosophy implies.

### S5 — MEDIUM — Rollback story is implicit, not specified. (PR-T0-2, PR-T1-1, PR-T2-clone)
The only rollback artifact is `enable-enforcement.sh`'s `.bak` copy of `settings.json`. There is no documented procedure to *disarm* a flag once flipped (the flag is a `-required.md` file in `workspace/memory/longterm/`, which is gitignored per the handoff OD-6 note → **not version-controlled, so a flag flip isn't revertible via git revert**). For a gate that can block all merges, you need a one-command, owner-runnable disarm (`set --scope L --key <rule>-required false`) and it must be documented in each Tier-0/Tier-1 PR's rollback section. The "no --force / gates cannot be broken" constraint makes a fast, *legitimate* disarm path essential — otherwise a false-positive storm has no exit except `--force`, which the constraint forbids.

### S6 — LOW/MEDIUM — Crucible `gate` runs the *full pytest suite* on every invocation; CI cost/latency unaddressed. (crucible-gate)
`crucible.json` shows `gate` runs `pytest tests/ -q` plus several full sub-suites *and* the changeset control. On a real runner this is minutes per MR. The plan adds more controls (D1, D3, D4 conformance gates) without a word on runtime, caching (`cache: pip` exists in the GH file but won't carry to GitLab), or parallelization. If/when a runner is restored, this becomes the merge-latency budget. Note it now.

### S7 — LOW — Detached-HEAD `HEAD~1` semantics differ from MR-diff semantics. (PR-T1-1)
Even with history, `merge-base HEAD origin/main` (three-dot intent: "changes since the branch point") and `HEAD~1` (literal previous commit) answer **different questions**. On a squash-merge or multi-commit MR, `HEAD~1` under-reports the change-set (misses all but the last commit), letting an untested neuron added two commits back slip the gate. The resolver should prefer the merge-base / MR-base and treat `HEAD~1` strictly as a last-resort single-commit-repo fallback, never as the MR base. PR-T1-1's spec ("`git rev-parse --verify HEAD~1` (silent)") risks enshrining `HEAD~1` as a co-equal base; tighten the spec to "merge-base preferred; `HEAD~1` only when no base ref exists AND the repo is genuinely single-commit."

---

## 4. SPECIFIC CHANGES I WOULD MAKE BEFORE EXECUTION

1. **Insert a new PR-T1-0 (CRITICAL, blocks PR-T1-2): "Establish the gate's execution substrate."** Decide and record (ADR) whether the crucible gate runs (a) server-side on GitLab via a restored `.gitlab-ci.yml` + live runner + protected-branch "pipeline must pass," or (b) locally via a `pre-push`/merge-program `crucible gate` step. Delete or relocate the dead `.github/workflows/ci.yml` so it stops implying CI that doesn't run. **Until this lands, PR-T1-2 cannot be specified correctly.**

2. **Rewrite PR-T1-2's change spec** from "set `fetch-depth: 0`" to: ensure a usable diff base on the chosen runner — `fetch-depth: 0` **plus** an explicit `git fetch origin main:refs/remotes/origin/main` (GitHub) or prefer `$CI_MERGE_REQUEST_DIFF_BASE_SHA` (GitLab); have the resolver accept an env/`--base` override **before** falling back to `merge-base`. Add a test that asserts the gate computes a non-empty change-set on a *ref-incomplete* fetch (not just a *shallow* one).

3. **Extend PR-T1-1's scope** so the single resolver is used by **both** `changed_files()` and the empty-diff guard, and treats any `git diff` that errors (nonzero exit *or* stderr-fatal) as `unresolvable → fail closed`, not "empty diff → pass." Add the `base="HEAD~1"-on-shallow-clone` fail-open fixture to PR-T1-3 explicitly (today it exits 0 with empty output — a live second fail-open path).

4. **Add a report-only/shadow mode (new PR-T1-2b or fold into PR-T0-3 tooling)** — `CRUCIBLE_REPORT_ONLY=1` or per-control `severity: SHADOW` that runs a control and records its verdict without blocking. Make it the default first step when arming any new BLOCK (PR-T0-2, D1, D3, D4). This converts every flag-flip from a big-bang into a measured rollout and gives PR-T0-2a its missing pre-flight count.

5. **Add an explicit dry-run/canary step to PR-T0-2a and PR-T0-2:** before flipping each `-required` flag, run the gate in report-only mode over the full corpus and record the would-be-BLOCK count; flip only when that count is zero (or each is triaged). Sequence the six flags individually, not as one flip.

6. **Add a "Rollback" section to every Tier-0 and Tier-1 PR.** For flag flips: the exact disarm command (`<tool> set --scope L --key <rule>-required false`) and a note that flags live in gitignored state (so disarm is a command, not a git revert). For the resolver: the gate must be runnable in a "diagnose base" mode that prints what base it resolved and why, so an all-MRs-blocked incident is debuggable in seconds.

7. **Correct the plan's false-positive framing (01-study §Method, 02-prs PR-T0-2):** state that the `-required` rules bite at the **crucible merge gate**, not the per-turn hooks (`verify_stop.py` is log-only; `enforce_pretooluse.py` runs only R9 + R_DONT_DO). This both calms the "bricks live sessions" fear and redirects test effort to the merge gate, where the real risk is.

8. **Tighten PR-T1-1's base-selection spec** so merge-base is strictly preferred and `HEAD~1` is a genuine single-commit fallback only — never the MR diff base on a multi-commit/squash MR (S7).

9. **Add a CI-runtime note to the plan** (S6): the `gate` control runs the full pytest suite; if a runner is restored, budget merge latency and add pip/test caching to the GitLab config (the GH `cache: pip` does not port).

---

## Appendix — evidence (live tree, 2026-06-19)

- Remote: `git@ci.tno.nl:artur.castiel-tno/axon.git` (GitLab). Only CI file: `.github/workflows/ci.yml` (GitHub Actions). `.gitlab-ci.yml`: absent on disk and in HEAD; history `42553cc` add → `053391c` remove ("gates run locally now (no runner)").
- `tools/crucible.py:131` — `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` (rev-parse **not** silenced). `:155` — both clauses silenced. Verified divergence on a reproduced shallow/detached clone: `:131` → literal `"HEAD~1"`; `:155` → `None`.
- Reproduced shallow depth-1 detached clone: `HEAD~1` fails (no parent), `origin/main` ref absent, `merge-base` fails. `git diff HEAD~1...HEAD` with non-existent `HEAD~1` → exit 0, empty stdout, fatal on stderr (a second fail-open).
- Reproduced GitLab-style single-ref fetch at full depth: `origin/main` still absent → `merge-base` fails → OD-6 fail-closed would block every MR.
- `tools/hooks/enforce_pretooluse.py` invokes R9 + R_DONT_DO only. `tools/hooks/verify_stop.py` is LOG-ONLY, always `sys.exit(0)` (docstring: "the crucible MERGE gate is where rules BLOCK").
- `crucible.json` `gate` controls: full `pytest tests/`, `crucible.py changeset`, plus library/study/aegis/dual-agent/axiom sub-suites — all `BLOCK`.
- Zero `*-required` flags on disk (`workspace/memory/longterm/*required*` → none). `scripts/enable-enforcement.sh` is a `settings.json` installer with a `.bak` snapshot; flags themselves are gitignored state (not git-revertible).
- `tools/liveness-allow.txt` exists (the shrink-only precedent PR-T1-5 mirrors).
