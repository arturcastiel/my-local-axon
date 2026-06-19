# AXON Re-Arm — Plan Review: Release Engineer (CI / Release lens)

**Seat:** Release Engineer (ops/devops, senior) — sourced from the AXON hr-team catalog
(`workspace/hr-team/catalog/professions/ops/release-engineer.md`).
**Scope of charge:** Will the fixed CR-13 gate (PR-T1-1) + `fetch-depth:0` (PR-T1-2) work on a *real*
GitLab runner (shallow checkout, detached HEAD, merge-base)? Operational risk of flipping the enforcement
flags (PR-T0-2). Does "fail-closed on absent state" (OD-6 / PR-T2-clone) brick clean CI? Rollout/rollback
story + the missing CI piece.
**Posture:** ADVISORY ONLY. Read-only verification on the live tree at `/home/arturcastiel/projects/new-axon/axon`
(branch `fix/wave-g-residual-hardening`). No code, tests, or state were modified. Empirical reproductions
below were run in disposable `mktemp` repos, never against the working tree.

Grounded in: Humble & Farley *Continuous Delivery* (deploy ≈ enable-condition, not just code merge);
*Accelerate* / DORA (change-failure-rate and MTTR over cadence); feature-flag lifecycle discipline
(LaunchDarkly model: a flag is a deploy you can roll back without a revert).

---

## 1. VERDICT

**SOUND-WITH-RISKS — confidence HIGH (0.85).**

The plan's diagnosis is correct and I re-verified its load-bearing facts on the live tree. PR-T1-1's
`git rev-parse --verify HEAD~1` choice is not cosmetic — it is the *exact* fix the current bug needs, and
I proved why (§2.1). PR-T1-2 is correctly identified as a hard dependency, not an optional follow-up. But
the plan is written against a **GitHub Actions** pipeline (`.github/workflows/ci.yml`) while the authoritative
remote is **GitLab** (`git@ci.tno.nl:artur.castiel-tno/axon.git`, with `glab`-resolved MR refs in git config).
That mismatch is unresolved in the backlog and is where the "real GitLab runner" risk concentrates. Three
additional release-grade gaps (rollback story, the T0-2↔OD-6 fail-open/fail-closed collision over gitignored
state, and a pre-existing CI fragility the plan doesn't name) keep this from a clean SOUND.

None of these are redesigns. All are pre-execution plan edits. With the §4 changes folded in, this is a SOUND
release plan.

---

## 2. WHAT THE PLAN GETS RIGHT (verified, not asserted)

### 2.1 The CR-13 root-cause is real, and PR-T1-1's fix is the correct one — confirmed empirically
The report (research/00 §1, T3) and PR-T1-1 (02-prs.md) claim `changed_files()` (`crucible.py:131`) and
`_changeset_base()` (`:155`) disagree because `:131`'s fallback `git rev-parse HEAD~1` lacks `2>/dev/null`.
I read the live source and confirmed the asymmetry exactly:
- `crucible.py:131` → `"git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1"` (no redirect on the fallback)
- `crucible.py:155` → `"... || git rev-parse HEAD~1 2>/dev/null"` (both clauses guarded)

But the *mechanism* is subtler and more dangerous than "stderr noise," and it makes PR-T1-1's specific fix
load-bearing. In a single-commit repo I reproduced: `git rev-parse HEAD~1` **prints the literal string
`HEAD~1` to STDOUT** (and exits 128). Because `subprocess(shell=True)` captures only stdout:
- `changed_files()` resolves `base="HEAD~1"` (the literal), then `git diff --name-status HEAD~1...HEAD` fails
  → returns `[]` → **empty change-set → vacuous PASS (fail-OPEN)**.
- `_changeset_base()` *also* returns the literal `"HEAD~1"` (truthy), **not `None`** — so the fail-closed guard
  at `run_changeset` (`crucible.py:189`, `_changeset_base(base, cwd) is None`) **never fires**.

This means today's "fail-closed" guard is itself defeated on a single-commit checkout. PR-T1-1's choice of
`git rev-parse --verify HEAD~1` is precisely right: I confirmed `--verify` prints *nothing* on a single-commit
repo, so the base resolves to empty → `None` → the guard fires and the gate fails CLOSED. **The plan picked the
correct primitive; it is not interchangeable with the current `rev-parse HEAD~1`.** This is a strong call and
the plan deserves credit for it.

### 2.2 PR-T1-2 is correctly scoped as a CRIT *dependency* of PR-T1-1, not a nice-to-have
02-plan.md §Critical path and 02-prs.md both gate `PR-T1-2` on `PR-T1-1` and tag both CRIT. I verified why
this ordering is mandatory (§3.1 below): with T1-1 alone on a default shallow GitLab checkout, the gate
fails-closed on *every* MR. T1-2 is the enable-condition. The plan understood that a resolver fix without
history is "too blunt" (research/00 B2 rationale) — that judgment is correct.

### 2.3 The fail-open test is correctly identified as enshrining the bypass (PR-T1-3)
I read `tests/test_crucible_failopen.py`. It monkeypatches **both** `_changeset_base` and `changed_files`
(lines 21-22) and exercises only `run_changeset` in isolation — it never runs the real resolver against a real
git repo. So the `:131`/`:155` divergence is genuinely untested, exactly as PR-T1-3 states. The plan's
insistence on a no-monkeypatch end-to-end test (02-prs.md PR-T1-3, "NO monkeypatching") is the right release
discipline: the gate must be tested through the same code path CI runs.

### 2.4 Tier-0-first sequencing is the correct release instinct
"Don't change the pipeline you can't measure" is the core of this seat's craft. The plan's non-negotiable
Tier-0-first ordering (HANDOFF, 01-study, 02-plan all repeat it) — instrument (PR-T0-1) before arming
(PR-T0-2) before the experiment (PR-T6-exp) — is textbook progressive delivery: establish the meter, then move
the flag, then measure the delta. The falsifiable-prediction framing (01-study §Drift root-cause) is exactly
how a change-failure-rate loop should be set up.

### 2.5 The reproduce-then-block method is the right bar for gate PRs
The owner constraint (HANDOFF §Hard constraints; 02-prs.md preamble) that security/gate PRs must
**reproduce-then-block** the failure — no fingerprint-only closure — is the correct standard for a pipeline
change. A gate fix is only proven when the pre-fix failure is demonstrated red and the post-fix is demonstrated
green through the production code path.

---

## 3. RANKED RISKS / GAPS (with the PR ids they touch)

### R1 — CI HOST MISMATCH: the plan is written for GitHub Actions; the live remote is GitLab. [CRIT] — PR-T1-2, PR-T1-1
**Evidence.** The only CI config in the repo is `.github/workflows/ci.yml` (GitHub Actions, `actions/checkout@v4`).
But `git remote -v` → `git@ci.tno.nl:artur.castiel-tno/axon.git` (a GitLab instance), and `git config` carries
`remote.origin.glab-resolved-head/base` (the `glab` MR CLI). There is **no `.gitlab-ci.yml`** anywhere in the
tree (verified via `ls-files` and a content grep for `stages:`/`gitlab`).
**Why it matters (release lens).** PR-T1-2's change text says "set `fetch-depth: 0` and fetch `origin/main` in
the crucible/test CI jobs." `fetch-depth: 0` is the **GitHub `actions/checkout`** input key. On a GitLab runner
the equivalent is `GIT_DEPTH: 0` (or `"0"`) as a CI/CD variable, plus the runner's own clone behavior — a
different knob entirely. If the team executes PR-T1-2 against `.github/workflows/ci.yml` but merges land through
GitLab MR pipelines, **the fix lands in a pipeline that may not be the gating one.** Conversely if no
`.gitlab-ci.yml` exists, the GitLab side may not be running the crucible gate *at all* — meaning CR-13 is
unenforced on the path that actually merges code.
**Severity rationale.** This is the single most likely way the "fixed gate" silently doesn't gate. The whole
Tier-1 thrust hangs on it.

### R2 — Default GitLab shallow + detached HEAD makes the *corrected* gate fail-closed on EVERY MR. [CRIT] — PR-T1-1 → PR-T1-2 (ordering is mandatory)
**Evidence (reproduced).** I simulated a GitLab MR checkout: shallow fetch of only the feature SHA, then
`git checkout -f <sha>` → **detached HEAD**, `origin/main` not fetched. Result:
- `git merge-base HEAD origin/main` → `fatal: Not a valid object name origin/main` (rc 128).
- fallback `git rev-parse --verify HEAD~1` → `fatal: Needed a single revision` (rc 128, depth-1).
- → base = `None` → **with PR-T1-1's fix, the gate fails CLOSED and BLOCKS the MR.**

So PR-T1-1 *without* PR-T1-2 converts a fail-OPEN gate into a **fail-on-everything gate** — a blocked-merge
storm. The plan's DAG already orders T1-2 after T1-1, but **they must ship in the SAME change/MR**, never as
two separately-mergeable PRs: merging T1-1 alone wedges the pipeline closed. The 02-prs.md "depends" edge does
not encode "co-merge"; make it explicit.
**With the fix (reproduced).** `GIT_DEPTH: 0` + an explicit `git fetch origin main:refs/remotes/origin/main` →
`merge-base` resolves and `git diff --name-status <base>...HEAD` correctly emits `A tools/X.py`. **The gate
bites correctly on a real GitLab MR.** So the fix *works* — but only with the explicit `origin/main` fetch,
which leads to R3.

### R3 — "fetch origin/main" is underspecified for detached-HEAD GitLab pipelines. [HIGH] — PR-T1-2
**Evidence.** On GitLab, `fetch-depth: 0` (or `GIT_DEPTH: 0`) gives full history of the *checked-out ref*, but
a single-branch/MR pipeline still may not have a local `origin/main` ref unless it is explicitly fetched into
the remote-tracking namespace. In my reproduction, `git fetch origin main` alone is not enough for the
resolver — the crucible code reads `origin/main` (a remote-tracking ref), so the fetch must be
`git fetch origin main:refs/remotes/origin/main` (or configure the refspec). PR-T1-2's one-line "fetch
origin/main" hides this. On detached HEAD, also confirm `git rev-parse --verify HEAD~1` is *not* relied on as
the primary path (it is the wrong base for an MR — you want the merge-base with the target branch, not the
parent commit). The resolver already prefers `merge-base`, which is correct; just ensure the ref it needs is
present.

### R4 — T0-2 (arm flags) ↔ OD-6 (fail-closed on absent state) collide over gitignored trust state. [HIGH] — PR-T0-2, PR-T2-clone, plus verify-carriage control
**Evidence.** The `-required` flags live at `workspace/memory/longterm/*-required.md`, and
`workspace/memory/working/` holds the live state. I confirmed via `git check-ignore` that **both paths are
gitignored** (rc 0). Therefore:
- **On any CI checkout the flag files are ABSENT.** I read `r_no_orphan_tools._required` (`:36-41`) and
  `r_workflow_node_order._required` (`:33-40`): both default to `False`/WARN when the flag file is missing. So
  PR-T0-2 "arming" the flags is **invisible to CI** — the rules the crucible `changeset` control runs
  (`crucible.py:186-187`) stay WARN in CI even after T0-2. *Good news:* **T0-2 alone does not cause a
  false-positive storm in CI.** *Bad news:* T0-2's enforcement is also unmeasured by the merge gate — the flag
  bites only at the local PreToolUse hook, never at the gate that actually merges code. The plan does not state
  this; it should, or the team will believe arming is enforced in CI when it is not.
- **OD-6 / PR-T2-clone directly opposes this.** `verify.py cmd_merge` (the `verify-carriage` BLOCK control in
  the crucible gate, `crucible.json` #3) documents in its own docstring (`verify.py:291-293`): *"On a fresh
  clone / CI that state is absent and the carried rules fail open — closing that allow-all-on-clone gap is
  PR-12's domain."* PR-T2-clone is that closure. **But the very gate it would harden runs on every CI push
  against a checkout where `working/` is ALWAYS absent.** If PR-T2-clone flips absent→BLOCK without the "no
  active project (legit-empty → allow)" vs "state suppressed (→ block)" discrimination it promises (02-prs.md
  PR-T2-clone), it **bricks every clean CI run** — a fail-closed regression that blocks all merges.
**Verdict on the charge's question — "does fail-closed on absent state brick clean CI?":** *It will, unless
PR-T2-clone's sentinel-based discrimination is correct AND is explicitly tested at the crucible-gate level on a
no-`working/` checkout.* The plan's PR-T2-clone test bullet names a "fresh-clone fixture (no working/) with the
sentinel present → fail-closed; no-active-project → loud N/A." That is the right idea, but the test must run
through `crucible.py gate` end-to-end (the path CI uses), not just `run_changeset`/`cmd_merge` in isolation —
otherwise it repeats the PR-T1-3 mistake of testing around the integration.

### R5 — Pre-existing CI fragility on shallow checkout that the plan never names. [HIGH] — affects crucible gate; should be folded into PR-T1-2
**Evidence.** The crucible registry (`crucible.json`) contains `lint-commit-trailer`, a **BLOCK** control whose
cmd is `python3 tools/lint_commit_trailer.py --range origin/main..HEAD`. This needs a local `origin/main` ref.
On a default shallow MR checkout (R2), `origin/main` is absent → this control errors → crucible's fail-closed
semantics (`run_control` returns `ok:False` on exception, `crucible.py:96-98`) → **the whole gate fails closed
regardless of CR-13.** So even before T1-1, the gate likely mis-behaves on shallow GitLab checkouts via *this*
control. PR-T1-2's `fetch origin/main` would incidentally fix it — but only if the fetch lands the
remote-tracking ref (R3). The plan treats CR-13 as the sole shallow-checkout victim; it is not. Audit every
control that references `origin/main` and bring them under the same fetch contract.

### R6 — No rollback / kill-switch story for the gate changes. [HIGH] — PR-T1-1, PR-T1-2, PR-T0-2, PR-T2-clone, PR-T2-1, PR-T2-2
**Evidence.** The backlog (02-prs.md) and master plan (02-plan.md) specify tests-to-green but **no revert or
disable path** for a gate that starts over-blocking in production. This seat's first principle: a gate is only
safe to tighten when you can loosen it fast (MTTR before cadence). Today the only documented rollback is "no
`--force`, gates cannot be broken" (HANDOFF §Hard constraints) — which is correct for *bypass* but means there
is **no legitimate fast off-ramp** if T1-1+T1-2 wedge the pipeline on a runner edge case, or if PR-T2-clone
false-blocks. Flags (T0-2) are inherently reversible (delete the `-required.md` file), and the plan should lean
on that: gate-tightening PRs should ship behind a documented, owner-controlled disable (an env var / flag that
forces a control to WARN, recorded and time-boxed), with the disable itself audited. Without this, change-
failure on the gate has no bounded blast radius.

### R7 — `HEAD~1` fallback is the wrong base semantics for MRs; keep it only as a last resort. [MED] — PR-T1-1
**Evidence.** `git rev-parse --verify HEAD~1` returns the *first parent of HEAD*, which on an MR branch with
multiple commits is **not** the divergence point from `main` — it under-reports the change-set (only the last
commit's files). The resolver correctly prefers `merge-base HEAD origin/main` first, so this is a fallback-only
concern, but PR-T1-1 should document that `HEAD~1` is a degraded last resort (single-commit local dev), and
that CI must always satisfy the `merge-base` path via R3's fetch — never silently rely on `HEAD~1` in CI.

### R8 — The "first sprint" mixes a fail-closed gate fix with flag-arming without a measurement gate between them. [MED] — PR-T0-1, PR-T0-2, PR-T1-1, PR-T1-2, PR-T2-1, PR-T2-2
**Evidence.** The first sprint (02-plan.md §First sprint) ships T0-1, T0-2a, T0-2, T0-3, T1-1, T1-2, T2-1, T2-2
together. T1-1+T1-2 change merge-blocking behavior; T2-1/T2-2 add new BLOCK paths on `tools/` and
`.claude/settings.json`. Landing several merge-gate-affecting changes in one sprint without a canary/soak
between them violates the change-coordination principle (isolate one pipeline variable at a time, observe,
then proceed). Recommend a defined order *within* the sprint with an observation window (§4.4).

---

## 4. SPECIFIC CHANGES TO THE PLAN BEFORE EXECUTION

### 4.1 Resolve the CI-host question FIRST, as a study sub-step ahead of PR-T1-2. (fixes R1, R5)
Add a one-line investigation gate to 02-plan.md / 02-prs.md: *"Determine the authoritative gating pipeline:
does merge happen via GitLab MR pipelines (`ci.tno.nl`) or GitHub Actions, or both (mirror)? Is there a
`.gitlab-ci.yml` that runs `crucible.py gate`? If GitLab gates merges, author the GitLab job; `fetch-depth:0`
becomes `GIT_DEPTH: "0"` and the checkout must `git fetch origin main:refs/remotes/origin/main`."* PR-T1-2's
acceptance test must run on the **same runner type that gates merges** — not only the GitHub job. This is the
"missing CI piece" the charge asks for: **the gate may not exist on the pipeline that actually merges.**

### 4.2 Co-merge PR-T1-1 and PR-T1-2; encode "co-merge," not just "depends." (fixes R2)
Annotate the DAG edge `PR-T1-1 → PR-T1-2` as **atomic co-merge**. Merging the resolver fix without the fetch
contract wedges every MR closed. Add an explicit acceptance criterion to PR-T1-1: *"On a detached-HEAD shallow
checkout with no `origin/main`, the gate's behavior is verified ONLY in combination with PR-T1-2's fetch; T1-1
is never merged independently."*

### 4.3 Make PR-T1-2's fetch contract precise and test it on detached HEAD. (fixes R3, R7)
Change PR-T1-2's change text from "fetch origin/main" to the exact contract:
`git fetch origin main:refs/remotes/origin/main` (so the resolver's `origin/main` remote-tracking ref exists),
plus `GIT_DEPTH: 0`/`fetch-depth: 0` per host. Add a test fixture that reproduces **detached HEAD** (not just a
checked-out branch) — my reproduction shows the branch-checkout case can accidentally pass while the real MR
detached-HEAD case fails. Assert the resolved base equals `merge-base`, not `HEAD~1`.

### 4.4 Sequence and gate the T0-2 / OD-6 collision; test PR-T2-clone through the real gate. (fixes R4, R8)
- State explicitly in 02-prs.md (PR-T0-2 and PR-T2-clone) that flag/working state is **gitignored and absent in
  CI**, so (a) T0-2 arming is enforced at the local hook but **NOT at the crucible merge gate**, and (b)
  PR-T2-clone MUST land its "no active project → loud N/A → allow" vs "state suppressed → block" discrimination
  *before* any absent→BLOCK flip, or it bricks every CI run.
- PR-T2-clone's acceptance test must invoke `python3 tools/crucible.py gate` (and `verify.py merge`) end-to-end
  on a checkout with no `workspace/memory/working/` — the exact CI condition — and assert: clean clone (no
  active project) → gate PASS with a loud N/A line; suppressed-state fixture → gate BLOCK. Isolation-only tests
  (the PR-T1-3 anti-pattern) are insufficient here.
- Within the first sprint, order: **T0-1 (meter) → T0-3 (counters) → observe → T1-1+T1-2 (co-merge, gate fix) →
  observe → T0-2a → T0-2 (arm) → observe → T2-1/T2-2 (new BLOCK paths) → T2-clone (fail-closed, last, after its
  end-to-end test is green).** One merge-gate variable at a time, with a soak window between.

### 4.5 Add a rollback / kill-switch sub-task to every gate-tightening PR. (fixes R6)
Add to the method section (02-plan.md §Method) a hard requirement: *"Each control that newly BLOCKs (PR-T1-1,
PR-T2-1, PR-T2-2, PR-T2-clone, PR-T3-2, PR-T3-4) ships with a documented, owner-controlled, time-boxed
downgrade path (force the control to WARN via an audited flag/env var) so an over-blocking gate can be loosened
without a `--force` bypass and without a revert. The downgrade event is itself recorded."* Lean on the fact
that the `-required` flags are already file-toggle reversible — make that the sanctioned rollback for T0-2, and
document it. This gives the change-failure a bounded MTTR.

### 4.6 Add a CR-13 gate-coverage assertion to the crucible registry audit. (hardens R5, R1)
Add a sub-task (extend PR-T3-1's meta-rule, or a new tiny PR): a conformance test asserting that the crucible
`changeset`/`verify-carriage` controls actually execute on the gating CI runner and that every control
referencing `origin/main` (`lint-commit-trailer`, the changeset resolver) has its ref-fetch precondition met.
This closes the "the gate is green because it errored-into-fail-closed, or skipped, not because it passed"
class — the most insidious release failure mode (DORA: a gate that doesn't run is worse than no gate, because
it manufactures false confidence).

---

## 5. SUMMARY TABLE

| # | Risk | Sev | PRs touched | Pre-exec fix |
|---|------|-----|-------------|--------------|
| R1 | CI host mismatch: plan = GitHub Actions, remote = GitLab; no `.gitlab-ci.yml` | CRIT | T1-2, T1-1 | §4.1 resolve gating pipeline first |
| R2 | T1-1 alone fails-closed on every shallow detached-HEAD MR | CRIT | T1-1→T1-2 | §4.2 co-merge, not just depends |
| R3 | "fetch origin/main" underspecified for detached HEAD | HIGH | T1-2 | §4.3 exact refspec + detached-HEAD test |
| R4 | T0-2 arm vs OD-6 fail-closed collide over gitignored state; clone fail-closed can brick CI | HIGH | T0-2, T2-clone, verify-carriage | §4.4 sequence + real-gate test |
| R5 | Pre-existing shallow-checkout fragility (`lint-commit-trailer --range origin/main..HEAD`) | HIGH | (crucible gate) T1-2 | §4.1/§4.6 audit origin/main deps |
| R6 | No rollback / kill-switch for tightened gates | HIGH | T1-1, T1-2, T0-2, T2-* | §4.5 audited downgrade path |
| R7 | `HEAD~1` is wrong base for multi-commit MRs (fallback only) | MED | T1-1 | §4.3 document degraded last-resort |
| R8 | First sprint changes multiple merge-gate variables at once | MED | T0-1/2, T1-1/2, T2-1/2 | §4.4 one variable + soak |

---

## 6. CLOSING (release-engineer judgment)

The plan diagnoses the gate correctly and — verified empirically — picks the *correct* primitive in PR-T1-1
(`--verify` is load-bearing, not interchangeable) and correctly makes PR-T1-2 a hard dependency. The Tier-0-
first / instrument-before-arm sequencing is exactly how a release-governance change should be staged. What
keeps this from a clean SOUND is not the code fixes but the **delivery surface**: the backlog is written for
the wrong CI host (GitHub vs the real GitLab merge path), it does not encode that the resolver fix and the
fetch contract must co-merge (T1-1 alone wedges every MR closed — reproduced), it leaves the T0-2-arm /
OD-6-fail-closed collision over gitignored CI state untraced (which can brick clean CI), and it ships no
rollback. All four are pre-execution plan edits in §4, none a redesign. With them folded in, this is a sound,
reversible, measurable re-arming of the pipeline. **Who owns the change-failure after this lands must be named
before T1-1 merges** — because the first runner edge case that fails-closed will block every merge until someone
can loosen it, and right now no one is designated to pull that lever.

— Release Engineer seat, AXON hr-team council. Advisory only.
