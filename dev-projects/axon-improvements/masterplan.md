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
| **dag-consistency/** | 1-gate | build `R_DAG_CONSISTENT` → 2-cascade → 3-nest | — |
| **axon-viz/** | ✓ (a) MERGED (PR-1) | `project-graph` generator landed (MR !1). (b) nested view after dag-consistency | dag-consistency *(for (b))* |
| **axon-tests/** | enforce | battery shipped; **confirm green CI on main → flip enforcement** | green CI |
| **axon-ascent/** | 3-safety-budget | eval/benchmark maturation (seeds + CIs + scoring) → feeds axon-million P3 | — |
| **axon-memory/** | 2-plan | core shipped; **open: #96 load-wire + 4 deferred follow-ups** | — |

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
- **🔒 SAFETY FINDING · compiled-mirror staleness is ungated (HIGH).** Discovered 2026-05-27: editing a source program does NOT regenerate its `.cmp.md`; with `prefer-compiled: true`, dispatch then runs the STALE compiled logic. PR-0 left `code-dev-safety-preflight.cmp.md` serving the old advisory Gate 3 (fixed in MR !4 by regenerating). **Systemic:** 138/187 compiled mirrors are 0.0%-ratio passthroughs (zero token benefit) — "compiled coverage 187/211" is largely illusory. *Fix idea:* a crucible control `R_COMPILED_FRESH` (mtime/hash of `.cmp.md` vs source → BLOCK if stale) + prune/skip 0%-benefit passthroughs. Sibling of `dont-do-enforce`/`dag-consistency` (mechanical truth).
- **🔒 SAFETY FINDING · glab squash-message bypasses the commit-trailer hook (MED).** `lint_commit_trailer.py` runs at the local `commit-msg` stage; `glab mr merge --squash --squash-message` is applied SERVER-SIDE, so PR-N / brand leaks in a squash message reach `main` unchecked (e.g. earlier squash commits carry "(PR-N)"). *Fix idea:* wire `lint_commit_trailer --head` as a standing crucible control over the merge-base..HEAD commit messages, or sanitize squash messages mechanically before merge. (The local hook DID correctly block PR-1's local commit — the gap is only the server-side path.)
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
