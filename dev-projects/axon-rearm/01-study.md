# Study — AXON Re-Arm

> Source of truth: the 8 sealed council reports + synthesis handoff (research/00-AXON-report-state-handoff.md,
> and axon-completeness-gate/reports/{menu,architecture,state-machine-compliance,naming,job-audit,
> state-machine-dag,non-compliance-gaps,drift-root-cause}.md). This file is the project-scoped distillation.

## Goal
Move AXON from **"disarmed and blind"** to **"armed and instrumented."** The councils found a correct,
self-honest architecture left switched off; the gap is configuration + unfinished wiring, not redesign.

## The verdict (7-of-8 council consensus, [V] = re-verified on the live tree)
- **Ships disarmed [V]** — zero `L:*-required` flags on disk → runtime BLOCK collapses to ~1 live rule (r_coherence).
- **Flagship CI gate fails open [V]** — Core Rule 13 defeated by `crucible.py:131` (missing `2>/dev/null`) vs `:155`
  resolver disagreement on shallow checkouts; the unit test mocks the defect away.
- **Instruments blind** — drift tracker reads an empty wire → "stable" by construction; `KERNEL-SLIM:2` v1.1.7 vs `VERSION` 3.8.0 [V].
- **Guard < what it guards** — `tools/`, `.claude/settings.json`, and the `dev-mode` god-flag are ungated [V].
- **Strong & real** — R9 write-gate (the Wave G classifier), registry hygiene (0 drift/0 broken jobs),
  phase_model.done(), workflow_run.advance, compaction recovery. Remediate seams + config, do not rewrite engines.

## 7 cross-cutting themes (the spine of the backlog)
T1 ships disarmed · T2 honesty ≠ enforcement · T3 seams break not engines · T4 model-executed bookkeeping is
the load-bearing weakness · T5 dual/divergent encodings · T6 marked-for-death-never-executed / policy unowned ·
T7 self-models quietly wrong.

## Drift root-cause (the owner's question, answered)
~60% architecture/process · ~30% config · ~10% irreducible model — **but the model share is unmeasured and
over-attributed because the meter records nothing.** Falsifiable prediction: instrument (A1) + arm (A2) +
mechanical counters (A3); if drift subsides, it was process/architecture wearing a model costume. Do Tier 0 first.

## OWNER DECISIONS — RESOLVED 2026-06-19 (baked into 02-prs.md)
- **OD-1 (posture): ARM IT.** Flip the `-required` flags in a governed profile. Seed `# emits:`/`outputs:` first
  (A2a) so terminal-outputs has something to bite. → PR-T0-2, PR-T0-2a.
- **OD-2 (drift-gate): BUG.** `r_drift_gate.py` must treat `unknown` as the fail-closed BLOCK drift.py already
  computes. → PR-T3-2.
- **OD-3 (state graph): TYPE BOTH, GATE ON EXEC.** Persist a typed multi-relation graph; body-`EXEC` is the
  authoritative transition layer, `next-suggests` the suggests layer. → PR-T5-4.
- **OD-4 (29 legacy + dead DAG): INVESTIGATE FIRST.** The pr-phase opens with an audit of the 29 `axon/programs/`
  nodes (live? dead? duplicated?) → then migrate-or-retire decision recorded as an ADR. → PR-T4-shadow (study sub-step).
- **OD-5 (grandfather): ADOPT** a frozen, shrink-only `test-grandfather.txt` (mirrors `liveness-allow.txt`).
  Conservative (never bricks) + important (monotonic coverage). → PR-T1-5.
- **OD-6 (clone fail-open): CLOSE IT.** Merge/`-required` checks fail CLOSED or loud-N/A when state is absent;
  must distinguish "no active project" (legit) from "state suppressed" (block). Heavily tested. (Wave G G3-D2.) → PR-T2-clone.
- **OD-7 (naming): DECIDE NOW.** Conventions: verb-first; reserve bare-verb shadows by scope; `-` workflow
  separator; flat `code-dev-*` namespace; add a NAMING section to authoring-guide. → PR-T4-naming + PR-T5-3.
- **OD-8 (thin-kernel): RUN IT.** A controlled heavy-ceremony OFF-vs-ON drift comparison. Sequence AFTER A1
  (needs a real meter). The one place "more enforcement" might be wrong — highest variance, cheap to test. → PR-T6-exp.

## Method (owner: conservative, test-more, redo-until-closed)
Each PR ships with a STRONG automated test that proves its claim (not fingerprint-only); a PR is not DONE
until the test is green AND, for security/gate PRs, the failure mode is reproduced-then-blocked. Tier 0 is
non-negotiable first (without A1/A2 the system can't tell whether later fixes worked). First sprint =
A1, A2, A2a, A3, B1, B2, C1, C2.

## Open experiment (preserved dissent, not resolved by the backlog)
OD-8 thin-kernel null hypothesis: the 757-line kernel with ≥14 per-turn gates may itself manufacture the
cognition-frame slips it flags. Tracked as PR-T6-exp; result may re-scope the whole "add enforcement" thrust.
