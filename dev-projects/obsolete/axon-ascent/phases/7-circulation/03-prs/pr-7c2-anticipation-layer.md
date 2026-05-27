---
glossary:   AXON-GLOSSARY
audience:   tier-A
version:    1
---

# PR-7c2 — anticipation layer (context-aware suggest · menus · workflow guidance)

**Phase**: 7-circulation
**Depends-on**: PR-7c1 (control-strip — the surface it drives) · the synapse
            orchestrator (`tools/synapse_suggest.py`, shipped) · R_PROJECT_ANCHOR (shipped)
**Ramps-with**: 1-telemetry (usage data) + the compass (metric fix) — the *mechanism*
            ships on the existing orchestrator; *accuracy* improves as the loops are fed
**Wave**: surface · **Reversibility**: reversible (additive; default-silent)
**Domain**: system · **dev-mode required**: no · **Status**: merged (tno/main 370ff15)

## Goal
Statement:  Anticipate the user's **next step** from conversational + workflow context
            and surface the right program / menu-slice / guidance at the right density —
            reusing the orchestrator's ranker + decide-thresholds so that **silence is a
            first-class, confidence-gated output.**
Acceptance: `tools/anticipate.py` (registered) that, given {state, recent-intents,
            active-program, queue}, returns `{suggestion, confidence∈[0,1], density ∈
            fire|suggest|silent}` using the EXISTING decide-thresholds (<0.70 ask ·
            <0.85 surface · ≥0.85 fire); drives PR-7c1's strip (high→guide, medium→one
            line, low→silent); a context-aware menu call returns the relevant **category
            slice**, not the whole menu; and it is **measured** — predicted-next vs
            actual-next logged for an accuracy score. Default-silent until confident.
Rejection:  surfaces on low confidence; emits the full menu unprompted; any default-on
            or non-reversible behavior; accuracy not logged (⇒ unmeasurable ⇒ can't tune).

## Blast radius (I-05)
Affected:   `tools/anticipate.py` (new) · `workspace/tools/anticipate.md` · extend
            `tools/synapse_suggest.py` signals (additive — workflow-arc) · `tools/REGISTRY.json`
            (+1) · `tests/test_anticipate.py`. Kernel touch: the OUTPUT-LAYER strip hook only
            (shared with 7c1, human-merge). No kernel rule changes.

## Tests (mandatory)
- ranker returns (suggestion, confidence, density) for fixtures.
- density verdict matches the decide-thresholds at boundary confidences (0.69/0.84/0.85).
- low confidence → `silent` (the cardinal rule, asserted).
- menu-slice returns a single category for a focused intent.
- predicted-vs-actual logging writes a parseable record (accuracy is computable).

## Rollback (I-04)
`rm tools/anticipate.py workspace/tools/anticipate.md tests/test_anticipate.py`;
revert the synapse_suggest signal additions + the OUTPUT-LAYER hook; `git checkout tools/REGISTRY.json`.

## Notes
**Cardinal rule: wrong anticipation is worse than none** — confidence-gate AND measure
before widening. The anticipation layer is the *consumer* that makes circulation pay off:
its intelligence ramps with phase-1 telemetry (the food). Build on the orchestrator's
existing 11-signal ranker — extend, don't reinvent. See architecture-bones.md §6 + the
masterplan North Star.
