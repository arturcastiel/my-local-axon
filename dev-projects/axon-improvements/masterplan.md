# AXON Improvements — the umbrella (single status board + plan)

> ONE place for all internal AXON improvement work. Open this to follow everything up.
> **RULE:** new improvement work = a workstream/item HERE — never a new top-level project.
> Updated 2026-05-27 (post evidence-audit + canonical cutover to new-axon).

## ▶ STATUS BOARD — 12 active workstreams

**⚠ PRIORITY**
| Workstream | Phase | Next action | Blocked by |
|---|---|---|---|
| **dont-do-enforce/** | 1-design | build `R_DONT_DO` (PR-0…6 per `dont-do-enforce/01-study.md`) — fail-closed | — |

**Active build**
| Workstream | Phase | Next action / open items | Blocked by |
|---|---|---|---|
| **dag-consistency/** | 1-gate | build `R_DAG_CONSISTENT` → 2-cascade → 3-nest | — |
| **axon-viz/** | 1-proto (a) | `tools/project_graph.py` + `viewer.html` (tolerant) | dag-consistency *(for (b))* |
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
