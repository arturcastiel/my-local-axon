# Orchestrator Composition Spec (v1)

> glossary: SYNAPSE-GLOSSARY v1
> resolves: F-014, D-003, D-007, D-010, D-013, D-017
> serves: D-7, D-8, D-11, D-12, D-13, D-14, D-18, D-21, D-22, D-29, D-30

## Purpose

Specify the orchestrator loop and how it composes existing kernel tools
(per F-014) into a goal-aware synapse suggester. No new ranking algorithm
— pure composition + thin glue.

## The loop

```
WHILE not (goal.met OR user.interrupt OR error.fatal):
    state    = observe()                          # snapshot of W:/L:/files/events
    goal     = retrieve(W:current-goal)           # always set per D-007
    workflow = retrieve(W:active-workflow) | null
    history  = recent-events-and-fires(window=10)

    IF workflow != null AND workflow.execution-mode == "fixed":
        candidates = [workflow.next-step(state)]
        # sideband suggestions still computed (see § Sideband below)
    ELSE IF workflow != null AND workflow.execution-mode == "adaptive":
        candidates = rank-candidates(state, goal, history)
    ELSE:
        # No workflow active — pure free-text dispatch
        candidates = rank-candidates(state, goal, history)

    IF len(candidates) == 0:
        EMIT axon.orchestrator.stuck
        QUERY user: "I don't see a next step. What would you like to do?"
        continue

    top = candidates[0]
    confidence = top.score

    decision = decide(confidence, L:inference-mode)
    # decision ∈ {fire, ask, surface-only}

    IF decision == "fire":
        result = fire(top.synapse, top.mode, top.args)
        observe-result(result)
    ELIF decision == "ask":
        choice = QUERY user with candidates[:3]
        IF choice == accept-top OR specific-index:
            fire(...)
        ELIF choice == decline:
            EMIT axon.orchestrator.declined
            wait for next user input
    ELIF decision == "surface-only":
        render-suggestion-footer(candidates[:3])
        wait for next user input

    record-fire(synapse, score, outcome)
    re-check goal.met
```

The loop is single-threaded, single-session. State updates are sequential.

## Function: `observe()`

Returns the STATE snapshot:

```python
state = {
    "W": dict(all W: keys),
    "L": dict(all L: keys),
    "active-program": W:active-program,
    "active-phase":   W:active-phase,
    "active-project": W:code-dev-project | W:library-dev-active | ...,
    "active-workflow": W:active-workflow,
    "current-goal": W:current-goal,
    "recent-events": E:session-log tail-100,
    "recent-fires":  E:fire-log tail-20,
    "files": {
        "exists": <set of files relevant to active project>,
        "mtimes": <map>
    },
    "context-pressure": TOOL(context, status).level,
    "drift-state":     TOOL(drift, gate).state,
    "shadow-coverage": (per active phase),
    "tests-status":    last run-tests result | null
}
```

Cached per-loop-iteration. Re-fetched on each iteration.

## Function: `rank-candidates(state, goal, history)`

Returns ordered list of `{synapse, mode, args, score, reason}`.

### Signal sources (composition per F-014)

| Signal | Tool / source | Weight (default) |
|--------|---------------|------------------|
| Intent classification | `mode-detect` extension | 0.25 |
| TF-IDF dispatch | `dispatch` tool | 0.20 |
| Frequency prior | `usage` tool top + recent | 0.10 |
| Pattern history | `pattern` tool clusters | 0.10 |
| `next-conditional` match | synapse contract | 0.15 |
| Goal alignment | predicate match against goal | 0.20 |
| Cost penalty (context pressure) | `context` tool | 0.05 (subtractive) |
| Drift penalty | `drift` tool | 0.05 (subtractive) |
| Shadow obligation | D-23 enforcement | 0.10 if shadow-coverage-gap |

Weights in `L:ranker-weights` (defaults set above; user-tunable). Configuration
file: extends `workspace/preferences/smart-dispatch.md` (existing infra used
by `dispatch.py` for `dispatch-confidence: 0.65` etc.) — synapse-suggest adds
its own keyed entries to the same file rather than creating a parallel config.

**Threshold alignment notes (validated against tool sources):**
- `dispatch-confidence` in smart-dispatch.md defaults to 0.65 → that is the
  minimum similarity for autonomous dispatch. The orchestrator's `decide()`
  function uses 0.7 as the inference-mode-5 fire threshold so dispatch's
  similarity score must clear both (similarity ≥ 0.65 AND combined-score
  ≥ 0.7) before autonomous fire. Different layers; both checked.
- `pattern-threshold: 3` in smart-dispatch.md matches D-010's
  `suggestion-promotion-threshold` default of 3. Use the same setting key for
  both to avoid divergence.

### Combiner formula (v1, rule-based)

```
raw-score(c) =
    w.intent * intent-match(state.recent-input, c.synapse.purpose)
  + w.dispatch * dispatch.tfidf(state.recent-input, c.synapse.name)
  + w.usage * usage.frequency-recent(c.synapse.name)
  + w.pattern * pattern.cluster-match(history, c.synapse.name)
  + w.next-cond * sum(c.next-conditional[].confidence
                     for each clause whose `if` evaluates true against state)
  + w.goal * goal-alignment(c.synapse, goal)
  - w.context * (state.context-pressure.pct / 100) * c.synapse.cost.tokens-estimate / 10000
  - w.drift * (1 if state.drift-state != stable else 0)
  + w.shadow * (1 if (shadow-obligation pending AND c.synapse advances it) else 0)

normalized-score(c) = raw-score(c) / max(raw-score(*))     # 0..1

c.score = normalized-score(c)
c.reason = "<contributing signals listed>"
```

Top-1 candidate is `argmax(score)`. Ties broken by lower `cost.tokens-estimate`.

### Filters (applied before ranking)

- `c.synapse.status == "STUB"` → exclude (per D-014 / F-012; warn if
  user-explicit invocation).
- `c.synapse.precondition` evaluates false → exclude.
- `c.synapse.requires-shadow == true AND active phase shadow gate failing`
  → exclude unless shadow is in next-conditional path.
- Sandbox / dev-mode restrictions per kernel.

## Function: `decide(confidence, inference-mode)`

```python
def decide(conf, mode):
    if mode in [0, 1]:                # ask-always
        return "ask"
    elif mode in [2, 3, 4]:           # cautious
        return "ask" if conf < 0.8 else "fire"
    elif mode == 5:                   # balanced (default)
        return ("ask" if conf < 0.7
                else "surface-only" if conf < 0.85
                else "fire")
    elif mode in [6, 7]:              # assertive
        return "fire" if conf >= 0.6 else "surface-only"
    elif mode in [8, 9, 10]:          # autonomous / full-auto
        return "fire"
```

## Function: `fire(synapse, mode, args)`

```python
def fire(syn, mode, args):
    STORE(W:active-program, syn.name)
    STORE(W:active-mode, mode)
    CHECKPOINT
    pre = evaluate(syn.precondition)
    ASSERT pre OR FAIL(syn, "precondition failed")
    EMIT axon.synapse.firing {syn, mode, args}
    try:
        result = exec(syn.body, args, mode)
    except Exception as e:
        FAIL(syn, str(e))
        return {ok: false, reason: e}
    post = evaluate(syn.post-state)
    if NOT post: LOG(WARN, "post-state predicate false after fire")
    EMIT axon.synapse.fired {syn, mode, result}
    return {ok: post, result, syn, mode}
```

## Function: `observe-result(result)`

Updates STATE, records to `E:fire-log`, updates `usage` tool counters,
updates `drift` tool with expected-vs-actual sequence comparison.

## Sideband suggestions (D-30)

Even in Fixed-mode workflows, sideband suggestions are computed:

```
sideband-candidates = rank-candidates(state, goal, history)
                       - filter out: workflow.declared-next-step
top-sideband = sideband-candidates[0]
IF top-sideband.score >= L:sideband-threshold (default 0.6):
    render-suggestion-footer([top-sideband])
```

Sideband suggestions never alter the Fixed path. User can opt in via:
- `accept sideband` — fires top-sideband, then returns to fixed path.
- `accept sideband persist` — fires AND adds it as a `mode-override: adaptive`
  edge in the workflow file (with user confirm).

## Deviation suggestions (D-30)

When state diverges from next-Fixed-step's precondition:

```
IF workflow.next-step(state).precondition evaluates false:
    deviation = rank-candidates filtered to candidates that satisfy
                 the next-step.precondition advancement
    surface as: "Current state can't satisfy next step.
                 Suggested deviation: <top-deviation>."
    QUERY user: accept | continue-anyway | abort-workflow
```

Deviations are logged with high visibility (output-layer banner).

## Ephemeral → predetermined promotion (D-010)

For ephemeral suggestions (runtime-generated, not in any
`next-conditional`):

```
record-ephemeral-suggestion(syn-from, syn-suggested, accepted: bool)
IF accept-count(syn-from, syn-suggested) >= L:suggestion-promotion-threshold (default 3):
    propose to synapse author:
        "{syn-from} → {syn-suggested} accepted N times. Add to next-conditional?"
    auto-add only if author confirms (or dev-mode + auto-improve enabled).
```

## Conversational workflow author (D-028)

Composition over orchestrator:
- Iterative `rank-candidates` calls in dialog form.
- After each user-confirmed synapse, emit a workflow file edge.
- Terminate when user types `done` OR all proposed paths terminate.

Detailed dialog script lives in `conversational-author-v1.md`.

## Event subscriptions (orchestrator hooks)

| Event | Handler |
|-------|---------|
| `axon.synapse.fired` | re-rank, surface suggestions |
| `axon.state.changed` | observe, re-rank if active workflow |
| `axon.dag.mutated` | refresh active-workflow synapse list |
| `axon.workflow.deviation-accepted` | persist if requested |
| `axon.context.pressure-high` | shorten suggestion list to top-1 |
| `axon.drift.diverged` | suppress suggestions until reset |

Subscribed via existing `events` tool (EMIT/ON).

## Output-layer suggestions section

New section in `axon/OUTPUT-LAYER.md` footer (gated by
`L:suggestions-enabled`, default true):

```
─────
suggestions
  ▶ <top-1>     reason: <signals>     confidence: 0.82
    <top-2>     reason: <signals>     confidence: 0.71
    <top-3>     reason: <signals>     confidence: 0.58
─────
```

Compact mode shows top-1 only.

## Tooling (Phase 3 deliverables)

| Tool | Purpose |
|------|---------|
| `synapse-suggest` | rank candidates; the composition entry point |
| `orchestrator` | the loop (a program, not a tool) |
| `state-snapshot` | observe() output as JSON for inspection |
| `predicate` | evaluate predicates against state |

## Measurement (per D-21)

Per turn, log: `{state-hash, goal-id, candidates[], chosen, accepted-by-user}`.
Periodic report: top-1 hit-rate vs user-acceptance. Target ≥ 90 % per D-21.

## v1.1 additions (2026-05-17)

### Tie-break ladder (FL-04)
When top-k candidates have raw-score within ±0.05:
1. higher  `canonical` status (canonical > alias > stub-never)
2. higher  `recency.last-fired` timestamp
3. better  `role-match` (mutator if state needs change; reader otherwise)
4. lower   `cost.tokens-estimate`
5. higher  `goal-alignment.score` (recomputed at finer resolution)
6. **lexicographic name** (deterministic terminal tiebreak)

Reproducibility: identical state + goal + history → identical top-1
across sessions.

### Zero-candidate fallback (FL-05)
```
IF candidates == []:
    EMIT axon.orchestrator.no-candidates
    fallback = TF-IDF match goal.statement against FULL registry → top-3
    IF fallback non-empty:
        QUERY "No declared candidates. Closest matches: [list]. Pick or describe."
    ELSE:
        QUERY "No matches. Options: register-tool / workflow-new / free text."
    log no-candidate-fallback event
```
Never hangs.

### Cold-start ranker bootstrap (FL-07)
First 20 fires of a fresh session (no dispatch/usage/pattern history):
- Frequency prior from REGISTRY `invocation_source`: program=0.5,
  cli=0.3, kernel=0.0.
- Disable absent-signal weights; renormalize remaining.
- After 20 user-confirmed fires, exit cold-start; full ranker active.

### Interrupt-gate integration (FL-09)
When KERNEL-SLIM active-program-interrupt-gate fires with
`W:active-workflow != null`:
- Continuation commands (yes/no/continue/...) → pass through gate.
- Deviation request → surface deviation suggestion; gate yields.
- Pause-and-task → CHECKPOINT workflow; route input to adaptive path.
- Abort → terminate workflow; menu.
Classification uses mode-detect with workflow-context bonus.

### Configuration home
`workspace/preferences/smart-dispatch.md` extends to include:
`synapse-suggest-weights:`, `suggestion-budget:`, `cold-start-fires: 20`.

## Version + change rule

**Version: v1.1 (2026-05-17).** v1 → v1.1 additions above. Ranker weights
live in `L:` + `preferences/smart-dispatch.md`. Schema bumps require ADR.
