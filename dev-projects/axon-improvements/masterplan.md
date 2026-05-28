# AXON Improvements — the umbrella (single status board + plan)

> ONE place for all internal AXON improvement work. Open this to follow everything up.
> **RULE:** new improvement work = a workstream/item HERE — never a new top-level project.
> Updated 2026-05-27 (post evidence-audit + canonical cutover to new-axon).

## ▶ STATUS BOARD — 12 active workstreams

**⚠ PRIORITY**
| Workstream | Phase | Next action | Blocked by |
|---|---|---|---|
| **dont-do-enforce/** | ✓ INFRASTRUCTURE COMPLETE (MR !2/!3/!4/!5) | `R_DONT_DO` gate + capture gate + `match:`/`R_DONT_DO_LINT`/`lint-dir` + **semantic class** (`review:` marker → human-review/BLOCK-in-autonomous) all merged. Every prohibition is now tokenized/semantic/prose; only prose fails. **REMAINING (lower-leverage):** (a) **PR-5 backfill** — `lint-dir my-axon/dev-projects` = **98 prose across 14 files** (mostly recurring boilerplate; classify tokenized vs semantic). NOTE: this is my-axon DATA hygiene (NOT an OS-repo gated PR; verify via `lint-dir`→0 prose; commit via workspace-backup). My PR-0 made preflight Gate 3 strict, so active projects' prose now BLOCKs preflight until backfilled. (b) **PR-6** upgrade review-diff §3 to use `match:` (OS-repo, proven loop) + KERNEL note (HUMAN-ONLY). | — |

**Active build**
| Workstream | Phase | Next action / open items | Blocked by |
|---|---|---|---|
| **dag-consistency/** | ✓ 1-gate + 2-cascade DONE | 1-gate: `R_DAG_CONSISTENT` BLOCK control merged (MR !6). 2-cascade: VERIFIED ALREADY DONE 2026-05-27 — all 7 mutation programs (pr-create/pr-link/phase-new/divide/combine/plan/plan-master) carry substantive `TOOL(dag,…)` cascade ops; functional smoke (bootstrap→add-node→add-edge→verify) + 25 dag tests green. The project `04-log.md` "REMAINING: 2-cascade" was STALE. NEXT: **3-nest** (phase-graph DAG.json + neuron `dag:` field + infinite nesting) — LARGE + LOW-LEVERAGE: only 4 DAG.json exist (mostly obsolete/finished), OS repo has none, and the gate scans OS-root only (my-axon project DAGs ungated). Recommend deferring 3-nest until DAG.json usage justifies it. | — |
| **axon-viz/** | ✓ (a) MERGED (PR-1) | `project-graph` generator landed (MR !1). (b) nested view after dag-consistency | dag-consistency *(for (b))* |
| **axon-tests/** | ✓ enforcement SATISFIED by crucible | "5-enforce" goal (mandatory tests for axon/tools changes) is already live: `pytest` is a BLOCK crucible control + `R_NEW_NEEDS_TEST` BLOCK + full gate fail-closed pre-merge. NO separate CI exists (TNO shows "no pipeline") — the local `crucible gate` IS the gate. Remaining = the doc co-outputs (Goal B, lower priority); not an enforcement gap. *(stale `_meta.codebase=/mnt/c` — cosmetic)* | — |
| **axon-ascent/** | 3-safety-budget | eval/benchmark maturation (seeds + CIs + scoring) → feeds axon-million P3 | — |
| **axon-memory/** | 2-plan | core shipped; **open: #96 load-wire + 4 deferred follow-ups** | — |

**Mechanical-truth — self-knowledge integrity (QUEUED 2026-05-28, owner-approved — fixes the drift/hollow-metrics concerns; siblings of dag-consistency/dont-do)**
| Workstream | Phase | Next action | Blocked by |
|---|---|---|---|
| **project-refresh/** | ✓ v1 MERGED (MR !15) | `tools/project_refresh.py reconcile <proj>` — checks `codebase:` exists+canonical (`--fix` repoints) + flags `R_*`/`tools` refs in the plan that already exist (marked-remaining-but-done; rule = `r_*.py` OR registered crucible control). 10 tests. NEXT (v2, optional): "PR-N merged" vs squash history · stale-done todos · run it across all sub-projects to reconcile this board · `R_PROJECT_FRESH` WARN control. | — |
| **metric-integrity/** | ✓ v1 MERGED (MR !16) | `tools/metric_integrity.py audit` + `metrics_manifest.json` — every headline self-metric must carry a falsifying tripwire test (mechanism #1). Seeded 4 real (compiled-coverage, dual-agent-h1, dag-consistency, coverage-floor); WARN crucible control. NEXT (v2): mechanisms #2–#5 (presence-vs-effect flag, n/CI convention, freshness, control-delta) · grow the manifest · promote WARN→BLOCK. | — |

**Cross-host coherence (X1 — feeds axon-million P3 goal #4 + Axiom portability)**
| Workstream | Phase | Open items | 
|---|---|---|
| **axon-claude-code-consistency/** | 2-design | CD-202, CD-203 + the Stop-hook (headline goal, unbuilt) |
| **axon-copilot-anchor/** | 2-design | PR-CA-101/103/104/105 (4 of 5 unshipped) |
| **axon-copilot-consistency/** | 2-design | CC-202…206 (5 of 6 open); resume at CC-204 |
| **copilot-deviation-study/** | 1-design | run the study (scaffolded, never executed) |

**Deferred / small**
| Workstream | Phase | Open item |
|---|---|---|
| **axon-gap-closure/** | PR-F | alias cleanup — *needs a rename tool, not regex* (handoff written) |
| **axon-wiring-gaps/** | 1-design | wire unwired memory keys + zero out broken programs (build never started) |

**Critical path:** `dont-do-enforce` + `dag-consistency` + `axon-tests` → **bug-free** ; `dag-consistency` → `axon-viz(b)` ; `axon-ascent`(E1) + X1 → feed **axon-million** (product, separate).

---

## Backlog (inline items — not yet broken into sub-projects)
- **🔒 SAFETY FINDING · compiled-mirror — ✓ DE-RISKED 2026-05-27 (MR !7); freshness-gate follow-up open.** DONE: pruned the 138 zero-benefit passthroughs (kept 49 savers), flipped `prefer-compiled:false` (source is truth → stale mirrors harmless), regenerated REGISTRY.json (0 dangling), + invariant test forbidding 0%-passthroughs. Owner chose "shrink to where it pays." **REMAINING follow-up** (deferred, needs the harder mechanism): a source-hash freshness gate `R_COMPILED_FRESH` + semantic auto-regen for the 49 compressed savers, then re-enable `prefer-compiled:true`. Deep study showed compressed-mirror freshness can't use body-equality (savers ≠ source) and regen needs the semantic compiler — a real follow-up, not a quick gate. Original measurement for reference: editing a source program does NOT regenerate its `.cmp.md`; with `prefer-compiled: true`, dispatch runs the STALE compiled logic. **Measured scope:** of 187 mirrors — **121 STALE** (source mtime newer than the mirror), **13 ORPHANED** (`.cmp.md` with no source `.md`), and **138 are 0.0%-ratio passthroughs** (zero token benefit; "compiled 187/211" is largely illusory). PR-0 left `code-dev-safety-preflight.cmp.md` serving the old advisory Gate 3 (fixed MR !4); the semantic PR likewise needed `code-dev-dont-do.cmp.md` regen (done). **This is a dedicated workstream, NOT a quick gate** — a BLOCK `R_COMPILED_FRESH` would fail on 121 items today. *Plan:* (1) content-based staleness check (mirror body vs source body, not just mtime — many passthroughs may be mtime-stale but content-identical); (2) prune the 13 orphans + the 0%-passthroughs (they add risk, not savings); (3) regenerate genuinely-stale mirrors; (4) THEN add `R_COMPILED_FRESH` (WARN→BLOCK) + auto-regen-on-edit. Sibling of `dont-do-enforce`/`dag-consistency` (mechanical truth). *Owner decision needed:* is the compiled-mirror layer worth keeping given 74% are 0%-benefit?
- **🔒 SAFETY FINDING · commit-trailer leak — ✓ FIXED 2026-05-27 (MR !8).** `lint_commit_trailer.py` gained `--range origin/main..HEAD` (lint every new commit, leaks-only; the `lint-commit-trailer` control is now BLOCK, scoped to new commits so merged history never trips it — also killed the perennial pre-commit false-warning) + `--stdin` (lint a squash message before merge). Squash messages are now linted via `--stdin` pre-merge (closes the server-side path the local commit-msg hook can't see). Existing leaked history left as-is (no force-push). The local commit-msg hook also correctly blocked a live PR-N slip this session.
- **F0 · canonical tree — LARGELY RESOLVED 2026-05-27.** Canonical = `new-axon/axon` (TNO); persona repointed; `my-axon` symlink-shared. *Remaining:* retire/relocate the stale `/mnt/c` code; reconcile the `axon-development` checkout + its forked `my-axon.git`.
- **F6 · artifact brand-guard — CLOSED 2026-05-27 (owner): obsolete.** Superseded by the shipped `PR-CD-204` + commit-msg artifact-identity gate; no separate `R_NO_BRAND_IN_ARTIFACTS` lint needed. *(folder stays in ../obsolete/)*
- **F5 · cleanup — DONE** (`axon-cleanup` shipped + closed, 2880/0 tests). ✓
- **idea · structural-coherence lint** — promote from parked `coherence-v2`: `R_FSM_TRANSITION` + `R_NEURON_EXISTS` (sibling of `dont-do-enforce`/`dag-consistency`).
- **idea · bounded ranker controller** — promote from parked `ranker-v2`: cap/floor/decay + per-program accounting + SELF-OBSERVE row.
- **Tier-4 distribution enablers:** onboarding `[lab2-15]` · prefs-doctor `[lab2-14]` · tool-help `[lab2-08]` · cron-runner `[lab2-07]` · progs-index `[lab2-13]` (ideas captured; stubs disposable).
- **D1 · docs** — future AXON-DOCS regen (axon-docs project already shipped its sweep).
- **persona×workflow friction harness** — from `axon-user` (findings stale; harness idea already consumed by axon-polish); optionally fold into E1.

## Scope
- **In:** kernel · quality/bug-free gates · tooling · cross-host consistency · memory · docs · distribution.
- **Out (separate top-level projects):** `axon-million` (product/proof — consumes E1 + X1) · `reservoir-eng` · `cpg-to-unstructure` · `lab2-*` elifoot.

## Archives (verified 2026-05-27)
- **Finished** (`../finished/`, 4): `axon-audit-2026` (verdict ✓) · `axon-synapse` (20/20 merged) · `axon-polish` · `axon-autoimprove` (1 trailing cron PR-211).
- **Obsolete** (`../obsolete/`, 19): truly dead/superseded/never-started — `firing-dag-missing` (superseded by dag-consistency) · `axon-master` (delivered + superseded) · `axon-docs`/`axon-cleanup` (shipped, no open work) · `coherence-v2`/`ranker-v2`/`axon-user` (ideas promoted above) · 10 lab2 stubs · `axon-artifact-guard` (F6 closed — superseded by PR-CD-204).
