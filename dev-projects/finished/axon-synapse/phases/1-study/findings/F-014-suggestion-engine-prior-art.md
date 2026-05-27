# F-014: Suggestion-engine infrastructure largely exists — orchestrator is composition, not greenfield

**Severity:** medium (positive — implementation cost reduced)
**Track:** T-F
**Date:** 2026-05-17
**Linked demands:** D-7 (adaptive orchestrator), D-8 (workflow generator), D-11 (suggest by goal/workflow), D-12 (pop-up Qs), D-13 (after-action suggest), D-21 (proper tool always suggested), D-27 (register), D-28 (conversational author)
**Linked decisions:** D-010, D-013, D-016, D-017

## Evidence — existing tools/programs the suggester layer can stand on

| Tool / Program | Category | Role for the synapse orchestrator |
|----------------|----------|-----------------------------------|
| `mode-detect` (program) | router | Intent classifier with 7 mode signals. Scores 0–100; auto-routes ≥ 70, suggests ≥ 40, falls to menu. **= the adaptive orchestrator's intent classifier.** |
| `mode-router` (program) | router | Routes free-text input to active mode's handler. **= the in-mode dispatcher.** |
| `find-program` (program) | search | "Search installed programs by capability, keyword, description." **= the user-facing capability lookup, mirrors what the suggester needs internally.** |
| `dispatch` (tool) | kernel | TF-IDF match free-text prompt → compiled program. Subcommands: `match / index / feedback / stats / correlate`. **= ranker substrate already shipping.** |
| `dispatch-stats` (tool) | kernel | Weekly token-savings summary, accuracy, compile candidates. **= measurement layer for D-21 success criterion.** |
| `pattern` (tool) | kernel | Cluster prompt-log entries by TF-IDF similarity; surface compile candidates. **= "after X often Y" pattern miner.** |
| `prompt-log` (tool) | kernel | Captures user inputs for pattern analysis + smart dispatch. **= signal source.** |
| `usage` (tool) | kernel | Records every program run; `top` and `suggest` subcommands. **= frequency prior for ranker.** |
| `drift` (tool) | kernel | Edit-distance: expected vs actual tool sequence; gate state (stable/drifting/diverged). **= quality signal for adaptive mode.** |
| `events` (tool) | kernel | EMIT/ON event bus; programs already EMIT phase transitions (e.g. `code-dev.pr.review.phase`). **= subscription substrate for the orchestrator loop.** |
| `context` (tool) | kernel | Context-pressure estimator. **= cost-signal for ranker tiebreaks (e.g. prefer cheap synapse near limit).** |
| `register-tool` (program) | meta | Wizard to add a new REGISTRY entry (dev-mode-gated). **= D-27 partial implementation; needs reload + suggester-consumption wire-up.** |
| `axon-audit` (program) | meta | Structural + usefulness audit (1a/1b sections). **= reference for "audit a workflow run."** |

## Reframing

The suggestion engine **does not need to be built from scratch.** Phase 3
work is **composition**:

1. **Intent classification** → use `mode-detect`'s signal model; extend to
   intent → synapse (not just intent → mode).
2. **Ranking** → combine `dispatch` (TF-IDF), `usage` (frequency), `drift`
   (quality), `pattern` (history clusters), `context` (cost-pressure).
3. **Event hooks** → subscribe to `events` for synapse-completion;
   re-rank on each event.
4. **Output channel** → the output-layer footer (already exists per
   `axon/OUTPUT-LAYER.md`) gets a `suggestions:` section.
5. **Tool registration** → `register-tool` exists; needs (a) reload-on-add,
   (b) auto-include in ranker, (c) optional inline-declaration of synapse
   contract fields (D-016).

## Gaps (what's missing)

- **`next-conditional` field on programs/tools** — required for after-X→Y
  suggestion (F-005, F-013).
- **Goal-aware ranker** — current dispatch/pattern/usage rank by similarity
  + frequency; none factor in `W:current-goal` (D-7, D-010). Combiner needed.
- **Live "you might want to: A, B, C" footer line** — output-layer code
  doesn't surface suggestions today.
- **Conversational workflow author** (D-28) — wizard pattern exists in
  `register-tool` and `harness-builder`; can be cloned for
  `workflow-new --from-description`.
- **Reload-on-tool-registration** — `register-tool` appends to REGISTRY but
  doesn't notify the live session (boot re-read needed).

## Implication for Phase 2 / Phase 3

- **Phase 2.** Spec the *composition* — which existing tool feeds which
  ranker signal, how scores combine, what threshold triggers QUERY vs
  autonomous fire (per `L:inference-mode`).
- **Phase 2.** Spec the orchestrator's event-subscription map: which events
  trigger which re-ranks. `code-dev.pr.review.phase` is the example seed.
- **Phase 3.** PR seed: `synapse-suggest` tool — wraps the composition.
  Inputs: `(state, goal, history)`. Outputs: ranked candidate list.
- **Phase 3.** PR seed: output-layer `suggestions:` section — surface top-k
  from `synapse-suggest` after every program completion.
- **Phase 3.** PR seed: `workflow-new --from-description` — interactive
  wizard, clone of `harness-builder` pattern.
- **Phase 3.** PR seed: `register-tool-reload` — wire REGISTRY append to
  in-session reload + ranker re-index.

## Audit-trail link

- D-7 partially achievable today via `mode-detect` extension.
- D-11/D-12/D-13 all rest on the composition layer above.
- D-21 ("proper tool always suggested") test bar: 90 % top-1 hit on
  a labeled fixture set, measured via `dispatch-stats` extension.

## Note (positive)

This finding **further de-risks the project** (alongside F-010, F-011).
The orchestrator is mostly a **composition layer** over existing kernel
tools. Phase 3 implementation cost is significantly lower than greenfield.
