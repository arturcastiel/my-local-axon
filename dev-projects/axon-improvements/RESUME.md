# RESUME — axon-improvements (session handover, 2026-05-27)

> Open this first on resume. The autonomous dev loop is fully wired and PROVEN
> (2 PRs merged this session). Everything below is the state to pick up from.

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

## Next backlog (priority order)
1. **dont-do-enforce** — infrastructure ✓ DONE (4 PRs). Remaining is lower-leverage: **PR-5 backfill** the 98 prose prohibitions across 14 my-axon files (DATA hygiene, not an OS-repo PR — classify tokenized/semantic, verify `lint-dir`→0, commit via workspace-backup; needed because strict Gate 3 now blocks those active projects' preflight) · **PR-6** review-diff §3 → `match:` (OS-repo loop) + KERNEL note (HUMAN-ONLY).
2. **dag-consistency** — ✓ **1-gate DONE** (MR !6): `R_DAG_CONSISTENT` is a fail-closed BLOCK crucible control (`dag-consistent`), verified clean (146 edges/507 neurons). NEXT = **2-cascade** (wire the 7 mutation programs to call `dag.py` ops — substantial) → 3-nest.
3. **axon-tests** — ✓ enforcement already SATISFIED by crucible (`pytest` BLOCK + `R_NEW_NEEDS_TEST` BLOCK; no separate CI exists). Remaining = doc co-outputs only (lower priority).
4. **🔒 compiled-mirror subsystem** (NEW workstream, HIGH) — measured 121/187 stale + 13 orphaned + 138 0%-passthroughs; `prefer-compiled` serves stale logic. Needs prune + content-staleness check + `R_COMPILED_FRESH`. **Owner decision:** keep the compiled layer at all (74% give 0 benefit)? See masterplan finding.
5. Larger remaining: cross-host **X1** (4 projects, some need `~/.claude/` host wiring), **axon-memory** #96, **axon-ascent** eval maturation, dont-do **PR-5 backfill** (98 prose, my-axon data) + **PR-6** (review-diff §3 + human-only KERNEL note), **squash-message PR-N leak** (standing `lint_commit_trailer --head`).
2. **axon-tests**: confirm green CI on main → flip enforcement.
3. **X1 cross-host**: claude-code-consistency (Stop hook), copilot-anchor (4 PRs), copilot-consistency (CC-202..206), copilot-deviation-study (run it).
4. **axon-memory**: #96 load-wire + 4 deferred follow-ups.
5. **axon-viz (b)**: nested project⊃phase⊃PR view — AFTER `dag-consistency` lands 3-nest schema.
- **HUMAN-ONLY** (kernel-edit inviolable): any KERNEL-SLIM doc note (dont-do-enforce PR-6) needs dev-mode + owner.

## Gotchas (learned this session)
- CANONICAL = `/home/arturcastiel/projects/new-axon/axon` (TNO). `/mnt/c` is STALE code; `my-axon` is symlinked-shared (physical under `/mnt/c` — do NOT delete `/mnt/c`).
- Verify git push via `PUSH_RC`, never a background exit code (it reports the last echo, not git).
- Pre-existing doc-counts drift can red the gate → `python3 tools/doc_counts.py fix`.
