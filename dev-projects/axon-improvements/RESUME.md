# RESUME — axon-improvements (session handover, updated 2026-05-28)

> Open this first on resume. Autonomous dev loop wired + PROVEN.
>
> **2026-05-28 SESSION (21 PRs, MR !3..!23; tags v3.8.0 + 7 dev checkpoints):** safety core
> (dont-do-enforce x3 · dag-consistency 1-gate · compiled-mirror shrink + `prefer-compiled:false`
> · commit-trailer `--range`/`--stdin`) → **v3.8.0 release** → **axon-million WEDGE feature-complete**
> (axiom coherence + enforcement-gaps + portability + `report`) → boot-reminder panel → **META-FIXES**
> from the concerns review: **project-refresh** (tracking drift, MR !15) + **metric-integrity**
> (hollow self-metrics, MR !16) → **PROOF MACHINERY**: methodology (MR !17) + sandbox (!18) +
> MMS oracle (!19) + **B2.5 objective grader wired into the harness (!20)**. my-axon `/mnt/c`
> routing fixed; 7 codebase refs repointed.
>
> **NEXT = CONCERN 1, the PROOF live-run** (axon-million bottleneck, HUMAN: API key + budget).
> The benchmark is now RUNNABLE END-TO-END + OBJECTIVE: `dual_agent_eval.py run-mms` (NOT the old
> self-graded prose `run.sh`) presents an MMS PDE goal (no u*), runs both arms, extracts the
> produced solver, and grades it for convergence — a win is an oracle pass, never a say-so.
> PROOF TARGET COMPLETE: `preflight` (B4, cost + price-independent conclusiveness gate) + `prereg`
> (B5, locked bar + git-commit/sha256-pinned grader, commit before running) both MERGED (tag
> `v3.8.0-dev-proof-target`). The flow is `preflight --n K` → `prereg --seeds 0..K` (commit it) →
> `run-mms --backend anthropic --goals heat:0,advdiff:0,... --model <m>`. BREADTH SHIPPED (tag
> `v3.8.0-dev-proof-spectrum`): a 2nd MMS field — advection-diffusion/transport — + operator
> dispatch (`operator:seed` ids; `--goals` on run-mms/preflight/prereg). 12 mixed goals (6 heat +
> 6 advdiff), all reference solvers order ~2; preflight(12) is conclusive-capable at win-rate 0.85.
> REMAINING for the live NUMBER: **B3** full-AXON-over-MCP arm (today the AXON arm is an AXON-
> discipline *prompt* via make_operator, not full AXON+tools — todo 43b4bf4b, owner-steered
> fidelity) · OPTIONAL more breadth (Buckley-Leverett analytical oracle / 3rd MMS field) · then
> HUMAN: cheap pilot → confirm → scale → headline (Opus) → read CI.
>
> **PAUSED 2026-05-28 pending an internal TNO discussion on HOW to run it.** TWO backends now merged
> (MR !20–!25): `--backend anthropic` (pay-per-token API key, bare-model base = the locked design) and
> `--backend claude-cli` (Pro/Max SUBSCRIPTION via `claude -p`, no API key, agent-with-tools base = a
> real-world H1 variant). Colleague explainer kept OUT of the repo (owner's request):
> `/home/arturcastiel/projects/new-axon/AXON-benchmark-guide.md`. **Loadable resume anchor = todo
> `cbe1b46d`** (the boot menu surfaces it). AFTER the discussion: pick option+model → prereg → run-mms
> → interpret. While on hold, safe autonomous proof-strengthening = the Buckley-Leverett analytical oracle.
> See `dev-projects/axon-million/proof-design.md` +
> `04-log.md` (2026-05-28) + general memories `session-state-2026-05-28-proof-next` +
> `proof-pillar-is-the-bottleneck`. Other open human item: X1 Stop-hook (signature prereq +
> ~/.claude, supervised).

## Resume in 3 steps
1. `load axon`  → boots **canonical new-axon** (output-style was repointed 2026-05-27).
2. `code-dev load axon-improvements`  → this umbrella.
3. Read `masterplan.md` STATUS BOARD → continue the backlog (next item below).

## Autonomy state (wired + working — don't re-derive)
- **Grant ACTIVE** on `artur.castiel-tno/axon` (ops: commit, push, pr-create, merge-squash; deny: kernel-edit, force-push, reset-hard, branch-delete). Check: `python3 axon.py autonomous-mode status`.
- **AEGIS** `_policy.md` (repo root, **LOCAL/uncommitted**): develop/pr-create=grant, test-execution/merge=**green-only**, build=human. Verify: `python3 axon.py aegis-policy resolve --capability merge --policy _policy.md --grant --gate`.
- **glab** authed to `ci.tno.nl` at the **/gitlab subpath** (`api_host=ci.tno.nl/gitlab`; token in glab config). Push = SSH.
  - ⚠ NEVER run `glab auth login` — it rebuilds the URL without `/gitlab` → 404. Set the token via `glab config set --host ci.tno.nl token <PAT>`.
- **The loop**: branch → draft → **FULL** `python3 axon.py crucible gate` (never a subset) → green → `git push` (SSH) → `glab mr create --repo artur.castiel-tno/axon -s <branch> -b main ...` → `glab mr merge <iid> --squash --remove-source-branch`.
  - Commits **REQUIRE** the trailer `Co-authored-by: AXON <axon@arturcastiel.github.io>` (a pre-commit hook blocks otherwise). NEVER a Claude trailer.
  - **Fail-closed**: red gate → no push/merge.

## Merged this session (TNO `main`)
- **PR-1** `axon-viz` — `project-graph` generator (DAG from `_meta.md` → `graph.json` + cytoscape `viewer.html` + gaps report). MR !1, squash `edb74fda`.
- **PR-2** `dont-do-enforce` — `R_DONT_DO` mechanical fail-closed prohibition gate (dormant until a repo-root `_dont-do.md` exists; wired into `crucible run_changeset`). MR !2, squash `91ee027`.
- **PR-0** `dont-do-enforce capture gate` — `dont-do-lint` tool + mechanical preflight **Gate 3** (was advisory) + born-enforceable `code-dev dont-do add --match` + tripwire tests. MR !3, squash `f5fa76f`.
- **match-gate** `dont-do-enforce` — `match:` schema + `R_DONT_DO_LINT` (lint every `_dont-do.md` in a change-set, BLOCK on prose-only) + `dont-do-lint lint-dir` + regenerated a stale mirror. MR !4, squash `c3a0528`.
- **semantic-class** `dont-do-enforce` — `review:` marker (un-tokenizable → R_DONT_DO flags for human review, BLOCK-in-autonomous); 3-way classify (tokenized/semantic/prose, only prose fails); `code-dev dont-do add --semantic`. MR !5, squash `9f70c0a`. **dont-do-enforce INFRASTRUCTURE now complete.**

## Next backlog (post-2026-05-27 safety session — 6 PRs merged: MR !3–!8)
**Done this session:** dont-do-enforce infra (capture/match/semantic — MR !3/!4/!5), dag-consistency 1-gate (MR !6) **+ 2-cascade (verified already wired + functional, 25 dag tests green)**, compiled-mirror shrink + `prefer-compiled:false` (MR !7), commit-trailer `--range` BLOCK + `--stdin` (MR !8), my-axon `/mnt/c` routing fix, axon-tests enforcement confirmed live (crucible). Checkpoint tag `v3.8.0-dev-safety-2026-05-27` + backup branch.

**REMAINING — all large / deferred-value / owner-steered (the clean present-value safety work is DONE):**
- **dont-do PR-5 backfill** — classify the 98 prose prohibitions across 14 my-axon `_dont-do.md` (`match:` | `review:`). DATA work (no OS-repo gate; verify `lint-dir`→0). DEFERRED VALUE: the blocked projects are inactive (cross-host studies in design); only bites when they're worked. Do for ACTIVE projects on resume.
- **dont-do PR-6** — review-diff §3 backtick-grep → `match:`. LOW value (the gate already enforces robustly; §3 is the advisory human view) + a KERNEL note (HUMAN-ONLY).
- **dag-consistency 3-nest** — phase-graph DAG.json + neuron `dag:` field. LARGE + LOW-LEVERAGE (only 4 DAG.json exist, mostly dead; gate scans OS-root only). Defer until DAG.json usage justifies it.
- **compiled-mirror freshness follow-up** — source-hash `R_COMPILED_FRESH` + semantic auto-regen → re-enable `prefer-compiled:true` for the 49 savers. (Already de-risked via `prefer-compiled:false`.)
- **cross-host X1** (4 projects) — needs `~/.claude/` host-wiring edits (owner posture: autonomous + snapshot-`~/.claude`-first). Feeds axon-million.
- **axon-memory #96**, **axon-ascent** eval maturation — large.
- **axon-viz (b)** nested view — after 3-nest.

**HUMAN-ONLY:** any KERNEL-SLIM / `axon/` edit (e.g. the dont-do PR-6 kernel note) needs dev-mode + owner.

## Gotchas (learned this session)
- CANONICAL = `/home/arturcastiel/projects/new-axon/axon` (TNO). `/mnt/c` is STALE code; `my-axon` is symlinked-shared (physical under `/mnt/c` — do NOT delete `/mnt/c`).
- Verify git push via `PUSH_RC`, never a background exit code (it reports the last echo, not git).
- Pre-existing doc-counts drift can red the gate → `python3 tools/doc_counts.py fix`.
