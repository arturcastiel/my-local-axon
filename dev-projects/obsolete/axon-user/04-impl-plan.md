# 04-impl-plan.md — axon-user execution runbook

**Schema**: impl-v1 · **Status**: ready-to-execute · **For**: [03-plan-v3.md](03-plan-v3.md)
**Audience**: the agent executing the work (AGENT) + the human approving (HUMAN)
**Mode**: operational (a tactical plan re-rendered as a step-by-step run order)

This is the **execution sequencing** of the 18 PRs in plan v3. The plan
answers *what* and *why*; this file answers *in what order, by whom, with
what command, gated on what check*. Read this top-to-bottom and execute.

## 0. Pre-flight (HUMAN, one-time)

```bash
cd /mnt/c/projects/axon
git status                          # must be clean
git rev-parse HEAD                  # must equal origin/main
cat VERSION                         # must read 3.6.0
python3 tools/call_graph.py --check # must exit 0
python3 tools/budget_lint.py        # must exit 0
pytest -q tests/                    # must be green
```

If any of these fail, STOP. The errata assumes a clean W4-final baseline.

Branch:
```bash
git checkout -b axon-user-3.6.1
```

## 1. Execution order (single linear sequence)

The DAG admits multiple valid orderings; this is the one the AGENT will
execute (chosen for minimal context switches: same-tier work batched).

| step | PR    | gate before                         | gate after (acceptance from PR detail) |
|------|-------|-------------------------------------|----------------------------------------|
| 1    | U-1   | pre-flight clean                    | 24 headers match filenames; call_graph clean |
| 2    | U-2   | step 1 done                         | `session.py list` fixture test passes  |
| 3    | U-3   | step 2 done                         | grep new `--path/--state` form         |
| 4    | U-4   | step 1 done                         | state-restore.md absent; no callers    |
| 5    | U-5   | step 1 done                         | scope-check runs only SCOPE branch     |
| 6    | U-6   | step 1 done                         | one branch-sync event in pr-ready log  |
| 7    | U-7   | (independent)                       | budget_lint clean; override comment present |
| 8    | U-8   | (independent)                       | docgen_verify exits 0; cheatsheet 76-wide |
| 9    | U-9   | (independent)                       | startup gate paragraph; new defaults    |
| 10   | U-10  | step 1 done                         | 02-roadmap.md written on fixture       |
| 11   | U-11  | step 10 done                        | 02-phases/ dir + ≥1 phase file         |
| 12   | U-12  | step 11 done                        | PR template Parent-phase: header       |
| 13   | U-13  | step 1 done                         | 03-decisions/adr-NNN-*.md on fixture   |
| 14   | U-15  | steps 10, 11, 13 done               | schema mentions v4.2 + hierarchy        |
| 15   | U-16  | steps 10-13 done                    | HELP block shows per-mode artifacts    |
| 16   | U-14  | steps 10-13 done                    | docgen_verify enforces tier links      |
| 17   | (gate)| all 16 above merged                 | run `_check-all.sh` (§5 below)         |
| 18   | U-V1  | step 17 green + HUMAN approval      | VERSION=3.6.1; CHANGELOG v3.6.1 block  |
| 19   | (push)| HUMAN explicit "yes, push"          | origin/main at HEAD                    |

**Parallelism note**: steps 4-9 are independent after step 1 — AGENT *could*
batch them into one commit-cluster but will linearize for review clarity.
Steps 10-13 are partially parallel (10→11→12 chain; 13 independent).

## 2. AGENT turn-by-turn

Each step = one focused work unit. After each step, AGENT:
1. Writes the diff.
2. Runs the **fast** local checks (lint_paths, budget_lint, call_graph).
3. Runs the PR's acceptance check from the detail file.
4. Stages and commits. Does **not** push.
5. Reports to HUMAN: "step N done — please run `pytest -q tests/` to verify".
6. Waits for HUMAN green before continuing.

Commit message template:

```
U-{N}: {one-line title}

{1-2 sentence why}

Detail: my-axon/dev-projects/axon-user/03-prs/u-{N}.md
Plan: my-axon/dev-projects/axon-user/03-plan-v3.md
Acceptance: see u-{N}.md ### Acceptance
```

## 3. HUMAN responsibilities

Per AGENT contract: HUMAN runs all build / test / push commands.

- **After every step**: `pytest -q tests/` — report green/red.
- **After U-1**:
  ```bash
  for f in workspace/programs/code-dev-{state,review,safety,knowledge,journal,lifecycle,pr}-*.md; do
    base=$(basename "$f" .md)
    head -1 "$f" | grep -q "^# PROGRAM: $base$" || echo "FAIL: $f"
  done
  ```
  (must produce no output)
- **After U-4**: review `git diff` of the file deletion before committing.
- **After U-8, U-14, U-15**: `python3 tools/docgen_verify.py` exits 0.
- **After U-11, U-13**: dry-run `code-dev plan --mode=tactical` and
  `--mode=decision` against a throw-away project; eyeball outputs.
- **Step 17 (`_check-all.sh`)**: the global gate before U-V1 (§5 below).
- **Step 19**: when AGENT asks "push?", reply with explicit consent
  ("yes, push" / "push now" / "ack push"). Anything else = do not push.

## 4. Rollback policy

Each PR is one commit (or commit cluster with a `--squash` merge). To roll
back PR `U-N`:

```bash
git revert <commit-of-U-N>
```

If a step fails acceptance mid-execution, AGENT does NOT continue. Instead:
- `git reset --hard HEAD~1` (only if the failing commit is the most recent
  and unpushed)
- Report failure to HUMAN with the failing check's output
- Wait for direction

**Never amend a pushed commit. Never force-push.**

## 5. Global gate before release — `_check-all.sh`

Before U-V1, the full check matrix must be green:

```bash
# from repo root, on axon-user-3.6.1 branch
python3 tools/lint_paths.py
python3 tools/budget_lint.py
python3 tools/call_graph.py --check
python3 tools/docgen_verify.py
python3 tools/scan_pre_push.py
pytest -q tests/test_programs_md.py
pytest -q tests/test_call_graph.py
pytest -q tests/test_pr_ergonomics.py
pytest -q tests/test_integration.py
pytest -q tests/test_tools_core.py
pytest -q tests/test_tools_kernel.py
pytest -q tests/test_compiled_regression.py
echo "ALL GREEN"
```

Every command must exit 0. If any fails, STOP. The failing step's PR
must be re-opened.

## 6. Replan trigger (in-flight)

The plan v3 §8 replan triggers apply during this execution:

- **U-1**: if affected files > 30, STOP and re-survey before continuing.
- **U-11**: if phase-slug naming requires more than one interactive QUERY
  per phase, STOP and ask whether to (a) accept latency or (b) fall back
  to numeric phase IDs.
- **U-14**: if >20% of existing axon-master PR files fail the new link
  rule, downgrade the rule to a warning for legacy projects (`_meta.md`
  schema < 4.2); promote to error in a later release.

## 7. Time / size estimate (informational, not gating)

| wave         | PRs                  | est LOC | est turns |
|--------------|----------------------|---------|-----------|
| U.A          | U-1, U-2, U-3        | ~40     | 3-4       |
| U.B          | U-4, U-5             | ~25     | 2         |
| U.C          | U-6, U-7, U-8, U-9   | ~40     | 4         |
| U.E          | U-10..U-16           | ~170 + 3 templates | 7-9 |
| U.D          | U-V1                 | ~45     | 1         |
| **total**    | **18**               | **~320**| **17-20** |

(No wall-clock estimate per AGENT contract.)

## 8. Out-of-scope during execution

Things the AGENT does NOT do, even if it notices them:

- Refactor unrelated programs "while we're here".
- Add new tests beyond what each PR's acceptance specifies.
- Touch `axon/` (kernel) — `L:dev-mode` not declared.
- Run any `pytest`, `cmake`, `make`, `cargo` command — that is HUMAN's job.
- Push, create branches on origin, comment on PRs/issues.
- Modify `my-axon/` files that aren't this project's own (no cross-project leakage).

If something legitimately needs to happen and is out of scope, AGENT
writes it to [findings/out-of-scope.md](findings/out-of-scope.md) and
continues with the current step.

## 9. Definition of done (project level)

- All 18 PRs merged onto `axon-user-3.6.1`.
- Step 17 (`_check-all.sh`) green.
- HUMAN ran the v3 fixture acceptance for U-10, U-11, U-13 — outputs match
  template banners.
- VERSION == `3.6.1`.
- CHANGELOG.md has the V3.6.1 block (errata + planning-hierarchy).
- HUMAN has explicitly approved push.
- Branch fast-forward merged or PR-merged to `origin/main`.
- This file (`04-impl-plan.md`) is updated with a Status: COMPLETE
  block at the bottom and a `final-commit:` SHA.

## 10. Status (live)

```
status:        not-started
current-step:  0 (pre-flight)
last-commit:   (none on axon-user-3.6.1 yet)
human-gate:    pending pre-flight approval
```

(AGENT updates this block after every step.)
