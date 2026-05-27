# Phase 4 — Residual-Flaw Triage (PR-AUTO-302)

slug:            01-residual-triage
schema-version:  v4
authored:        2026-05-19
phase:           4-validation
status:          DECIDED

Purpose: for each phase-3-exit residual flaw, make a **final** disposition decision and link it to a concrete next-step artifact. After this PR lands, every open flaw from the original `02-deep-audit.md` has either been **closed**, **routed to a spinout project**, **folded into an upcoming in-project phase-5**, or **explicitly closed as won't-fix** with rationale.

This is the gate between "validation done" and "project closure".

---

## Source

`phases/1-study/02-deep-audit.md` — the original 23-flaw inventory.
`phases/3-build/_closure.md` § "Residual flaws routed forward" — preliminary routing; this document is the authoritative version.

## State at phase-4 entry

| Flaw   | Description                                                                              | Status at entry |
|--------|-------------------------------------------------------------------------------------------|------------------|
| FA-1..FA-17, FA-24 | Various                                                                       | **CLOSED** during phases 2 + 3 (see closures) |
| FA-18  | Async appends without fsync; audit/igap/dispatch logs all tearable                       | **CLOSED** by PR-AUTO-301 fault-injection harness |
| FA-19  | Auto-tune one-way ratchet; dispatch's 2nd ratchet uses different cap                     | OPEN — needs decision |
| FA-20  | `auto-improve.md` does not enforce D-A02 (opt-in HARD) / D-A17 (idle-gap re-confirm)      | OPEN — needs decision |
| FA-21  | `auto_improve.action_auto_archive` has no rate limit — D-A20 not implemented              | OPEN — needs decision |
| FA-22  | code-dev pseudo-state-machine transitions are unguarded                                   | Already routed to `axon-coherence-v2` (proposed) per audit |
| FA-23  | `synapse-validate` silently passes references to unknown neurons                          | OPEN — needs decision |

---

## Decision table

| Flaw  | Disposition       | Target                      | Rationale                                                                                                                                                                  | Skeleton created |
|-------|--------------------|------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| FA-19 | **SPINOUT**       | `axon-ranker-v2`             | The one-way ratchet is symptomatic of a deeper design gap: the dispatch threshold and the synapse-suggest score floor are both monotonic tune-up signals with no feedback loop weight-adjustment. A correct fix requires re-thinking the ranker as a closed-loop controller (P/I/D-style) — that's a project, not a patch. PR-AUTO-204 already routed the auto-tune through loop-receipt, so the substrate is in place; what's missing is the *control law*. | ✓ `dev-projects/axon-ranker-v2/` |
| FA-20 | **PHASE-5 (in-project)** | `phases/5-followon/`         | D-A02 (opt-in HARD) and D-A17 (idle-gap re-confirm) are kernel-program ASSERTs in a file we already own (`workspace/programs/auto-improve.md`). The fix is ≤ 30 LOC of ASSERT lines + 5 test cases. Folding into a follow-on phase is cheaper than a spinout. | ✓ (phase meta only — no separate project) |
| FA-21 | **PHASE-5 (in-project)** | `phases/5-followon/`         | Rate-limiting `action_auto_archive` is ~20 LOC in `tools/auto_improve.py` (read last-run timestamp from L: scope, gate on cooldown). Trivially fits a follow-on phase next to FA-20. | ✓ |
| FA-23 | **SPINOUT**       | `axon-coherence-v2`          | The audit already proposed `axon-coherence-v2` for the code-dev FSM (FA-22). `synapse-validate`'s unknown-neuron leak is in the same family — both are about **structural coherence** of program graphs (FSM transitions, neuron references). Adding FA-23 to that spinout's seed audit avoids creating a third single-flaw project. | ✓ `dev-projects/axon-coherence-v2/` |

**Summary:** 2 spinouts created · 2 flaws folded into phase-5 · 0 won't-fix decisions.

---

## Phase-5 scope (in-project follow-on)

Two flaws, two PRs:

| PR              | Scope                                                                                          | Closes      |
|-----------------|------------------------------------------------------------------------------------------------|-------------|
| **PR-AUTO-401** | `workspace/programs/auto-improve.md` — add ASSERT for `L:auto-improve ≡ true` (D-A02 HARD) and `L:auto-improve-last-confirmed-ts within 30d` (D-A17 idle-gap re-confirm). Idle-gap test in `tests/test_auto_improve_assertions.py`. | FA-20       |
| **PR-AUTO-402** | `tools/auto_improve.py::action_auto_archive` — read `L:auto-archive-last-run-ts`, skip if within 24h; write the new ts via loop-receipt (`intent=auto-update-counter`). 5 test cases. | FA-21       |

After both PRs merge → write `phases/5-followon/_closure.md` and **bump project _meta** → status: **CLOSED**.

PR-AUTO-211 (cooldown menu surface) lands when its 7-day cooldown elapses; project closure waits for it.

---

## Spinout: axon-ranker-v2

**Purpose:** redesign the ranker as a closed-loop controller. Replace the one-way ratchet (FA-19) with explicit cap + floor + decay; introduce per-program success/fail accounting; surface the controller state in SELF-OBSERVE.

**Seed audit** (in spinout's `_seed.md`):
- FA-19 details from `phases/1-study/02-deep-audit.md` § "Dispatch dual ratchet"
- PR-AUTO-204's auto-tune wrap as the substrate it builds on
- D-DISC-4 observation that ranker state is invisible to the user

Created at: `dev-projects/axon-ranker-v2/_meta.md` + `_seed.md` (skeletons; full study in phase-1 of v2).

## Spinout: axon-coherence-v2

**Purpose:** structural-coherence validation across program graphs. FSM transitions (FA-22) + neuron-reference checking (FA-23) + (likely) suggestion-graph cycle detection.

**Seed audit:**
- FA-22 from `phases/1-study/02-deep-audit.md` § code-dev FSM observations
- FA-23 from same audit § synapse-validate semantics
- PR-AUTO-212's R_TOOL_CALL_EXISTS rule as the precedent ("static lint catches latent broken calls before runtime")

Created at: `dev-projects/axon-coherence-v2/_meta.md` + `_seed.md`.

---

## Cross-references

- Phase-3 closure: `phases/3-build/_closure.md`
- Phase-4 meta: `phases/4-validation/_meta.md`
- Phase-5 entry (created in this PR): `phases/5-followon/_meta.md`
- Original audit: `phases/1-study/02-deep-audit.md`
