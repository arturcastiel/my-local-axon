# SESSION HANDOVER — 2026-05-27

> Supersedes the 2026-05-26 handover (that session's work is merged to `main`).
> Codebase worked: `/home/arturcastiel/projects/new-axon/axon` (cross-checkout —
> my-axon lives at `/mnt/c/projects/axon/my-axon`, now symlinked in; see §5).
> **Nothing this session is committed yet** — the change-set sits in the working
> tree; the commit is human-gated (§4).

## 1. What this session did

### A · Connected my-axon (cross-checkout)
- This OS checkout had an empty `my-axon/`; the real user-data repo is at
  `/mnt/c/projects/axon/my-axon` (`github.com/arturcastiel/my-local-axon`).
- **Symlinked** `~/projects/new-axon/axon/my-axon → /mnt/c/projects/axon/my-axon`
  so every future boot auto-resolves it. `.gitignore` updated to ignore the symlink
  (`my-axon` as well as `my-axon/`). Two local eval-log files were preserved into the repo.

### B · `benchmark/` folder — public home for the dual-agent eval  ✓
- `benchmark/`: `README.md`, `goals.json` (5 real goals), `run.sh` (LIVE-only — fails
  loud without `ANTHROPIC_API_KEY`; the no-key `demo` backend is **rigged** and fenced
  as "NOT a result"), `EXAMPLE-REPORT.md`, `reports/`.
- Engine stays `tools/dual_agent_eval.py` (registered tool). Fixtures moved
  `fixtures/dual-agent/goals.json` → `benchmark/goals.json`; tool default + 3 test refs updated.
- 5 goals + their AXON-pillar mapping + scoring: see `plans/mcp-dual-agent-eval.md` PROGRESS.

### C · `R_GROUNDED_CLAIMS` — mechanical anti-fabrication gate  ✓
- `tools/rules/r_grounded_claims.py` — opt-in (`L:grounded-claims-required`), BLOCK.
  In grounded mode a substantive answer must be **cited or an explicit abstention**;
  bare unsourced prose is blocked. Mirrors `R_ADVERSARY_SCAN`. 12 tests.
- Registered in `tools/rules/registry.py`; flag wired into `tools/verify.py` load_state.
- **Kernel-documented** in `axon/KERNEL-SLIM.md` (dev-mode was enabled for this edit, then
  re-locked — `workspace/memory/longterm/dev-mode.md` back to `value: false`).
- This unblocks benchmark Goal 5 (`research-me`): the AXON win is *enforced abstention*,
  not the model happening to know facts.

### D · Made the crucible gate hermetic + fixed 2 real bugs  ✓ (1 open item — §3)
- Gate was red/noisy because scanners walked gitignored content (the connected my-axon +
  runtime state). Fixes:
  - `tools/lint_paths.py` → scan **git-tracked files only**.
  - `tools/doc_anchors.py` → dropped `my-axon/**/*.md` from DEFAULT_GLOBS.
  - timing test → runs audit against an empty my-axon (`MYAXON_ROOT` env).
  - cron test → real UTC `today` (was hard-coded `2026-05-22`).
  - verify test → isolated workspace.
- Crucible registry (`tools/crucible.json`) had **5 miswired control commands** (ran tools
  with no subcommand → errored as false warnings). Fixed all 5:
  `registry_drift check`, `coherence_lint check`, `freshness check`,
  `neuron_audit --all` (new mode), `lint_commit_trailer --head` (new mode).
- **Real bug #1**: `tools/synapse_infer.py` crashed on RELATIVE paths
  (`relative_to(REPO)`), so `neuron-audit` failed 0/187 programs. Fixed (resolve first) →
  now 187/187 pass. Added `--all` standing mode + regression test.
- **Real bug #2**: `tools/freshness.py` `_strip_volatile` ignored docgen's `> Generated:`
  header but not its minute-precision **footer** timestamp → freshness falsely flapped at
  minute boundaries. Fixed + regression test.

## 2. Gate state
`crucible gate` → **passed: true, blocking_failures: [], warnings: []**. 4796+ tests green.
Fully clean — zero blocking failures AND zero warnings.

## 3. Resolved this session / open items
- **`freshness` test-leak — RESOLVED (real bug #3).** Root cause pinned via a read-only
  trap on `AXON-DOCS.md`: `tests/test_tool_invocation_smoke.py::...[docgen]` runs docgen
  with empty argv from `cwd=tmp_path`; docgen scanned a **cwd-relative** `axon/` (empty →
  "187 programs") + relative `tools/REGISTRY.json`, while `--output` defaulted to the real
  absolute `under_workspace(...)` → it corrupted the real doc (also why AXON-DOCS was dirty
  at session start). Fix: `tools/docgen.py` now resolves `--axon` + the registry path to
  ABSOLUTE roots (cwd-independent), so it scans the real tree from any cwd. Regression test:
  `tests/test_docgen_cwd_independent.py`. Freshness now stays green through the full suite.
- **Open: commit pending** (§4) — human-gated.

## 4. The change-set (uncommitted) + how to commit
Working tree (this checkout). Feature + fixes:
```
NEW benchmark/ (README, goals.json, run.sh, EXAMPLE-REPORT.md, reports/.gitkeep)
NEW tools/rules/r_grounded_claims.py        + tests/test_rules/test_r_grounded_claims.py
NEW tests/test_docgen_cwd_independent.py    (regression for bug #3)
 M  tools/rules/registry.py · tools/verify.py
 M  axon/KERNEL-SLIM.md                       (R_GROUNDED_CLAIMS doc)
 M  tools/dual_agent_eval.py · tests/test_dual_agent_eval.py   (goals-path move)
 M  tools/lint_paths.py · tools/doc_anchors.py · tools/synapse_infer.py
 M  tools/neuron_audit.py (+ --all) · tools/lint_commit_trailer.py (+ --head)
 M  tools/crucible.json (5 cmd fixes) · tools/freshness.py (footer fix)
 M  tools/docgen.py                          (cwd-independent scan roots — bug #3)
 M  tests/test_axon_audit_synapse.py · test_deprecation_log.py · test_tools_kernel.py
 M  tests/test_neuron_audit.py · test_lint_commit_trailer.py · test_freshness.py
 M  .gitignore
```
Commit is human-gated (autonomous-mode grant OFF, on `main`). The commit-msg gate
REQUIRES the AXON trailer and FORBIDS brand co-authors:
```
git checkout -b feat/grounded-claims-and-benchmark
git add tools/ tests/ benchmark/ axon/KERNEL-SLIM.md .gitignore
git commit   # message must end with exactly:
             #   Co-authored-by: AXON <axon@arturcastiel.github.io>
```
Note: `workspace/AXON-DOCS.md` etc. are generated/runtime — keep them out of the feature commit.

## 5. Key operational state
- Codebase: `/home/arturcastiel/projects/new-axon/axon` (branch `main`). Remote:
  `git@ci.tno.nl:artur.castiel-tno/axon.git`.
- my-axon: `/mnt/c/projects/axon/my-axon` — symlinked into the OS checkout.
- autonomous-mode grant: **OFF** for this repo → all git is human-gated.
- dev-mode: re-locked (`value: false`).

## 6. Resume
`code-dev load` is not used for this work (done directly). To continue:
- finish the `freshness` test-isolation hunt (§3), OR
- help the owner commit (§4), OR
- start benchmark Goal 1 (`immiscible-2d-impes`) — first real goal to actually run.
