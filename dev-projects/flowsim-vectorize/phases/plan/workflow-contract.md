# Autonomous workflow contract — flowsim-vectorize

_Proposed 2026-07-03. Needs owner accept/amend on the 6 decisions marked ★._
_This document, once accepted, governs how I execute the 33 PRs in `02-prs.md`._

## The per-PR loop

```
FOR each PR in dependency order:
    1. READ the PR spec from 02-prs.md (title, deps, tests, legacy disposition)
    2. VERIFY all deps are green (their tests still pass in isolation)
    3. READ the source files the PR touches (typically 1–5 files)
    4. AUTHOR test first (if new function/module) OR test alongside (if refactor)
    5. AUTHOR the implementation
    6. RUN the targeted unit test via `tools/mrun tests/unit/unit_<name>.m`
    7. IF green → RUN smoke suite `tools/mrun tests/run_all.m` (all smoke + previous units)
    8. IF ALL green → COMMIT with structured message
    9. IF red → HALT + PRODUCE FAILURE REPORT + WAIT for owner
   10. Append entry to `phases/pr/04-log.md` (append-only, one line per PR)
```

Per-PR log entry format:
```
2026-07-03T13:40:12  PR-A1  DONE   flowsim_init.m + flowsim_deinit.m       tests: smoke_env(8/8)  commit=abc1234
2026-07-03T13:52:44  PR-A2  DONE   Metodo{MPFAH,NLFVPP,MPFAQL}.m           tests: smoke_class_hierarchy(11/11)  commit=def5678
2026-07-03T14:15:03  PR-B4  HALT   lambdaWeights.m — Frobenius 3.2e-11 > 1e-12 tol   report@log/PR-B4-halt.md
```

## HALT triggers (STOP + owner input)

| Trigger | What I do |
|---|---|
| Any test regression (previously-green test now fails) | Halt. Do not commit. Report the diff. |
| Correctness Frobenius > tolerance | Halt. Capture actual + expected + delta into a report. |
| MATLAB error I can't parse / diagnose | Halt. Dump the error verbatim. |
| Scope creep (>5 files beyond PR spec touched) | Halt. Ask for scope confirmation. |
| Need to touch `axon/` (kernel) | Halt immediately. Never happens. |
| 3 consecutive PR failures in a row | Halt. Probable systematic issue — need owner review. |
| Any PR that would DELETE >100 lines from a file I haven't fully read | Halt. Ask for delete confirmation. |
| A `deps: [X]` chain has PR X marked done but its test now fails | Halt. Rerun the base + investigate. |

## AUTONOMOUS-CONTINUE (no need to ask)

- All tests green → next PR in dep order
- Small in-scope fix discovered mid-PR (e.g., a typo in a related file that blocks compile) → fix inline, note in commit message
- MATLAB warning (not error) that doesn't affect correctness → suppress via `warning off <ID>` if noisy, note in log, continue
- Legacy code path I'm shadowing behaves oddly (but oracle diff is green) → not my problem, continue
- A commit fails to apply cleanly (rare) → rebase on latest `flowsim-artur`, re-verify tests, retry

## Reporting cadence

- **Per PR**: one line to `phases/pr/04-log.md` (mechanical), NO chat message
- **Per phase (A/B/C/D/E/F end)**: chat report — PRs landed, tests green, any surprises, blockers found, next phase preview
- **Per HALT**: chat report with the failure details + suggested fix + wait

## Commit discipline

- **One PR = one commit** on `flowsim-artur`. Never squash across PRs.
- **Commit message format**:
  ```
  PR-XX: <one-line title from 02-prs.md>

  <2-6 lines describing what changed and why>

  Tests: <test file(s) added/updated>, smoke=OK, unit=OK
  Refs: my-axon/dev-projects/flowsim-vectorize/phases/plan/02-prs.md

  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
  ```
- **Never `--amend` or `rebase -i`** — the branch history is append-only for audit.
- **Never `git push`** — owner controls when the branch goes to origin.

## Rollback

- If a landed PR is later revealed as broken (a downstream PR's test surfaces a
  regression in an earlier PR): `git revert <sha>`, add a new commit, do not
  force-push.
- If a working-tree change goes wrong before commit: `git restore .` (throw
  away, retry).
- Never `git reset --hard` on the branch.

## Turn budget (chat cadence)

- **Small PRs** (< 100 LOC added, no MATLAB probe needed): 3-5 per turn
- **Medium PRs** (100-500 LOC + tests + oracle diff): 1-2 per turn
- **Large PRs** (PR-C4 = 820 L rewrite, PR-B5 = full pipeline swap): 1 per turn
- **Phase-close report**: 1 turn per phase (A, B, C, D, E, F — 6 total)

Rough estimate: **~15–20 turns to land all 33 PRs**, assuming no HALTs.

## Test-first policy (per PR class)

| PR class | Order |
|---|---|
| Foundation (PR-A*) | Test + code together (interlocking — bootstrap moment) |
| New modules (PR-B*, C*, D*) | **Test first** (author expected outputs + capture baseline), then implementation to green |
| Reorganization (PR-E*) | Move files; smoke tests + full harness must stay green |
| Cleanup (PR-F*) | Smoke + affected units must stay green |

## Baseline capture strategy (PR-A6)

For the golden oracle:
- **Small mesh** — `M8.msh` (6 KB, ~50 elements) for fast per-PR verification
- **Large mesh** — `HermelineMeshModQuad_48_48.msh` for phase-close verification
- Both baselines captured per method (TPFA, MPFAD) per numcase (start with 439)
- Baselines stored as `tests/golden/<mesh>-num<N>-<method>.mat` (committed)
- Regeneration only via explicit `--update` flag (audit trail)

## Six decisions I need from you ★

### ★ D1 — Commit authority in flowsim-artur
Current `_policy.md` has `commit: human`. To run autonomously I need
`commit: grant` scoped to the `flowsim-artur` branch of the FlowSim repo.
Update policy? **[yes / no]**

### ★ D2 — Test-first strictness
For new modules (Phase B, C, D): should I capture the golden baseline from
the LEGACY code first, then only accept a rewrite that Frobenius-matches?
That's the plan. Alternative: write the vectorized code first + a fresh
handcrafted expected output. Choose:
**[oracle-vs-legacy (recommended) / handcrafted expected / mixed]**

### ★ D3 — HALT recovery mode
When I HALT on a failure, do I:
(a) roll back the working tree and report (safe — nothing lost, nothing gained), OR
(b) leave the partial work on disk under a `PR-X-halted/` folder for you to inspect
**[a (safe) / b (visible) / both — commit halt state to a `halted-PR-X` sub-branch]**

### ★ D4 — Turn-cadence throttle
How often do you want to see my progress? Options:
(a) Only on HALT + on phase-close (silent otherwise — check `04-log.md` for interim state)
(b) After every 3-5 PRs (chatty but visible)
(c) After every PR (very chatty — will feel like 33 turns)
**[a (silent, recommended) / b / c]**

### ★ D5 — Legacy retirement timing
When a Phase-C PR-Cn ships a vectorized twin behind a `useVect<X>` flag, do I:
(a) Leave the legacy in place, flag defaults to `false` (opt-in). You flip the flag when ready.
(b) Flag defaults to `true` (opt-out). Legacy stays but new code is default.
(c) After 2 green oracle passes on 2 different meshes, delete the legacy in a follow-up PR.
**[a / b (recommended) / c]**

### ★ D6 — Push authority
Once all PRs land on `flowsim-artur`, do I:
(a) Stop. You pull the branch and push to origin yourself.
(b) Push `flowsim-artur` to origin autonomously so you can see it in GitHub.
(c) Open a PR against `master` for you to merge.
**[a (safe) / b / c]**

## What I recommend by default (if you say "your call")

D1: **yes** (commit grant on `flowsim-artur` only)
D2: **oracle-vs-legacy** (strictest, no bugs slip in)
D3: **b (visible, in halted-PR-X sub-branch)** — you get to see the state
D4: **a (silent, check log)** — respects your directive of "don't ask, just do"
D5: **b (opt-out default, legacy stays)** — safest transition
D6: **a (stop after landing)** — you own the origin push

Answer either "your call" (I apply defaults) or list per-decision responses.
