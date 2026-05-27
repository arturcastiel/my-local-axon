# AXON Workflows + DAG Model + Composition Path

> Reference document for AXON v3.7.0 (commit `97c29c3`).
> Authoritative sources cited inline as `file:line`. This doc is descriptive
> of what is actually in the tree, not aspirational. Where claims in the
> CHANGELOG or specs diverge from the implementation, the implementation is
> treated as ground truth and the divergence is recorded under "Known issues".

---

## 1. TL;DR

- The headline shape from the v3.7.0 CHANGELOG (`/home/arturcastiel/projects/axon-development/axon/CHANGELOG.md:12-14`) is **input → ranker → orchestrator → fire/ask/surface**, implemented as `tools/synapse_suggest.py.rank()` → `workspace/programs/orchestrator.md` → `axon/OUTPUT-LAYER.md` § SUGGESTIONS FOOTER.
- Three execution modes are declared in the schema (`workspace/schemas/workflow-file.schema.json:32-33` lists five — `fixed | adaptive | hybrid | exploratory | scheduled`); only `fixed` and `adaptive` actually do something different in `workflow-run.md:69`. `hybrid` is schema-only (F-D4-004).
- The DAG (`tools/dag.py`) is the canonical graph at five levels (project / phase / plan / pr / study); `DAG.json` is the canonical file with `DAG.md` an auto-emitted human mirror.
- The two top loops — `orchestrator.md` (single tick + record) and `workflow-run.md` (per-step LOOP) — never call each other (F-D4-002). `W:orchestrator-last-tick` is the contract surface for PR-112's footer; it is not written during workflow runs, so the footer is invisible during fixed-mode workflow execution.
- `goal.acceptance.met()`, `tests.pass()`, `audit.open-findings == 0` and ~10 other identifiers used as `acceptance-criterion` / `rejection-criterion` in shipped workflow YAMLs are not in `tools/predicate.py:364-381` BUILTINS — every workflow that uses goal.* shorthand silently evaluates to null (F-D4-017). Combined with F-D4-003 (workflow-run loop has no step-count guard) and F-D4-018 (predicate eval called with no ctx), the canonical adaptive workflow is **truly infinite**.

---

## 2. Composition path overview

The CHANGELOG `3.7.0` headline (`axon/CHANGELOG.md:10-14`) prints:

```
user free-text  →  synapse-suggest.rank()  →  orchestrator loop  →  fire / ask / surface
                       (PR-109)                  (PR-111)              (PR-112 footer)
```

The mapping from arrows to files:

| Stage | File | Surface |
|-------|------|---------|
| input | host harness (Claude Code / Copilot) sets `W:recent-user-input` | `RETRIEVE(W:recent-user-input)` at `orchestrator.md:46` |
| ranker | `tools/synapse_suggest.py` | `rank(state, goal, candidates, weights, top, explain)` (line 410-471) |
| orchestrator | `workspace/programs/orchestrator.md` | ~160 lines; one OBSERVE → CANDIDATES → DECIDE → RENDER → RECORD → ACT |
| decision | local to orchestrator | `fire | ask | surface-only` per `inference-mode × confidence` ladder (lines 89-97) |
| surface | `axon/OUTPUT-LAYER.md` § SUGGESTIONS FOOTER | reads `W:orchestrator-last-tick.candidates` (line 86-92) |

### ASCII diagram — the v3.7.0 mainline composition path

```
                       ┌──────────────────────────┐
                       │ user free-text turn      │
                       │ (host stores             │
                       │  W:recent-user-input)    │
                       └────────────┬─────────────┘
                                    │
                          OBSERVE   ▼
                       ┌──────────────────────────┐
                       │ orchestrator.md          │
                       │   reads W:current-goal,  │
                       │   W:active-workflow,     │
                       │   L:inference-mode,      │
                       │   W:recent-user-input    │
                       └────────────┬─────────────┘
                                    │
                       CANDIDATES   │   IF active-workflow.exec-mode ≡ "fixed":
                                    │       candidates ← [workflow.steps[i].next]
                                    │   ELSE (adaptive | free-text):
                                    ▼
                  ┌─────────────────────────────────────┐
                  │ TOOL(synapse-suggest, rank, ...)    │
                  │                                     │
                  │ rank() in tools/synapse_suggest.py  │
                  │ ────────────────────────────────────│
                  │ filter()  → drop STUB,              │
                  │            failed precond,          │
                  │            shadow-gate failing      │
                  │ score()   → 10 signals × weights    │
                  │            additive: intent +       │
                  │            dispatch + usage +       │
                  │            pattern + next_cond +    │
                  │            goal + shadow + igap     │
                  │            subtractive: context +   │
                  │            drift                    │
                  │ norm()    → c.score = raw/max(raw)  │
                  │ FL-04 tie-break (6 levels)          │
                  │ → top-N list of {name,score,signals,│
                  │                  reason, raw}       │
                  └─────────────────┬───────────────────┘
                                    │
                          DECIDE    ▼
              ┌──────────────────────────────────────────┐
              │  decision ← f(inference-mode, top.score) │
              │                                          │
              │  inf-mode 0,1   → "ask"                  │
              │  inf-mode 2-4   → conf<0.8 ? ask : fire  │
              │  inf-mode 5     → 3-band ladder          │
              │                   (<0.7 ask /            │
              │                    <0.85 surface /       │
              │                    else fire)            │
              │  inf-mode 6,7   → conf≥0.6 ? fire : surf │
              │  inf-mode 8-10  → "fire"                 │
              └──────────────────┬───────────────────────┘
                                 │
                       RECORD    │
                                 ▼
              ┌──────────────────────────────────────────┐
              │  STORE(W:orchestrator-last-tick, {       │
              │    ts, mode, inference-mode,             │
              │    candidates, chosen, confidence,       │
              │    decision, sideband                    │
              │  })                                      │
              │  APPEND(E:orchestrator-tick, {...})      │
              └──────────────────┬───────────────────────┘
                                 │
                          ACT    ▼
              ┌──────────────────────────────────────────┐
              │  IF decision ≡ "fire":                   │
              │    CHECKPOINT                            │
              │    EMIT(axon.synapse.firing, ...)        │
              │    TOOL(dispatch, match, --query top.name)│
              │  IF decision ≡ "ask":                    │
              │    QUERY user accept/decline/alt          │
              │  IF decision ≡ "surface-only":           │
              │    (footer already rendered; wait)       │
              └──────────────────┬───────────────────────┘
                                 │
                                 ▼
                    ──── response gate ────
                                 │
                                 ▼
              ┌──────────────────────────────────────────┐
              │ axon/OUTPUT-LAYER.md § SUGGESTIONS FOOTER│
              │   tick ← RETRIEVE(W:orchestrator-last-tick│
              │   sugg-cands ← TAKE(tick.candidates, 3)  │
              │   IF drift.state ≡ "diverged":           │
              │      sugg-on ← false                     │
              │   IF format ≡ "compact" OR ctx-p ≡ "!":  │
              │      sugg-cands ← TAKE(sugg-cands, 1)    │
              │   → renders the footer block per         │
              │     OUTPUT-LAYER.md:96-103               │
              └──────────────────────────────────────────┘
```

The arrow from the orchestrator's "RECORD" stage into the OUTPUT-LAYER footer is via `W:orchestrator-last-tick` — that is the only contract surface. Anything that does not write to that key bypasses the footer (this is the root of F-D4-002).

Why "composition-only": the orchestrator program is intentionally thin (~160 lines, source-only — on `ALLOWLIST_UNCOMPILED` per CHANGELOG `axon/CHANGELOG.md:50`). Every signal function lives in `synapse_suggest.py`; the orchestrator just calls `rank()` and dispatches. RETRO.md `axon-synapse/RETRO.md:123` frames this as the design philosophy: "Composition-only beats new tools. Every ranker signal is a pure function from `(state, candidate)`. Adding a signal is one line of weights + one function; no orchestrator change."

---

## 3. Execution modes

The workflow file schema (`workspace/schemas/workflow-file.schema.json:32-33`) declares five values for `execution-mode`:

```json
"execution-mode": {
  "type": "string",
  "enum": ["fixed", "adaptive", "hybrid", "exploratory", "scheduled"]
}
```

In practice only the first three are referenced anywhere downstream. Of those three, only two are actually distinguished at runtime:

| Mode | Schema | workflow-run handling | orchestrator handling | Status |
|------|--------|----------------------|----------------------|--------|
| `fixed` | yes (schema:33) | `workflow-run.md:69` branches `≡ "adaptive"`; everything else (including `fixed`) walks declared `on-complete` graph | `orchestrator.md:60-67` reads workflow descriptor; sets `candidates ← [next-step]` | Works for shipped workflows |
| `adaptive` | yes | `workflow-run.md:69-71` emits a ranker suggestion line but still uses on-complete predicates for next-step | `orchestrator.md:68-72` calls `synapse-suggest.rank()` | Partial — observability-only in workflow-run (F-D4-010) |
| `hybrid` | yes | Same code path as fixed; the `≡ "adaptive"` branch is the only carve-out | Same as `free-text` (orchestrator has no `hybrid` branch) | Schema-only (F-D4-004) |
| `exploratory` | yes (schema) | Not handled | Not handled | Unimplemented; schema-only |
| `scheduled` | yes (schema) | Not handled | Not handled | Unimplemented; schema-only |

### Fixed mode

The workflow declares the step graph. Each synapse has an `on-complete:` list with optional `if:` predicates; the first matching predicate's `next:` is followed. Example from `workspace/domains/code-dev/workflows/code-dev.canonical.yml:48-58`:

```yaml
  - id:   s4
    name: code-dev-self-review
    role: gate
    on-complete:
      - if:   "review.passes()"
        next: s5
      - if:   "review.has-objections()"
        next: s3
```

The runner walks this graph. The orchestrator, when invoked, looks at the workflow descriptor and proposes the declared next step as the sole candidate.

### Adaptive mode

The workflow's `on-complete` graph is consulted, but the runner additionally calls `synapse-suggest.rank()` after each step (`workflow-run.md:69-71`) and emits a suggestion banner. The orchestrator's adaptive branch (`orchestrator.md:68-72`) is the one that consults the ranker.

The canonical adaptive workflow is `workspace/workflows/adaptive-free-text.yml`. It declares three synapses:

```yaml
synapses:
  - id:   s1
    name: synapse-suggest          # role: orchestrator
    on-complete:
      - if:   "goal.acceptance.met()"
        next: s3
      - if:   "goal.rejection.met()"
        next: s3
      - next: s2
  - id:   s2
    name: code-dev-flow
    on-complete:
      - if:   "goal.acceptance.met()"
        next: s3
      - next: s1
  - id:   s3
    name: code-dev-finalize
    on-complete: []
```

The intent is: s1 ranks → s2 mutates → either complete via s3 or loop back to s1. The implementation is broken (F-D4-003, F-D4-017, F-D4-018; covered in § 13).

### Hybrid

Documented as "fixed skeleton + adaptive sub-segment" in `workflow-run.md:36`. No runtime branch differentiates it. Schema-only.

---

## 4. The synapse-suggest ranker

`tools/synapse_suggest.py` is the entire ranker. It is stdlib-only. The public surface is a single function:

```python
def rank(
    state: dict,
    goal: dict | None,
    candidates: list[dict],
    weights: dict[str, float] | None = None,
    top: int | None = None,
    explain: bool = False,
) -> list[dict]:
    ...
```

Internally `rank()` does: filter → score → normalize → tie-break sort → trim → shape.

### Signals — 10, not 11

`DEFAULT_WEIGHTS` at `tools/synapse_suggest.py:42-53`:

```python
DEFAULT_WEIGHTS: dict[str, float] = {
    "intent":     0.25,
    "dispatch":   0.20,
    "usage":      0.10,
    "pattern":    0.10,
    "next_cond":  0.15,
    "goal":       0.20,
    "context":    0.05,   # subtractive
    "drift":      0.05,   # subtractive
    "shadow":    0.10,   # additive only when shadow gap exists
    "igap":      0.10,   # additive — PR-120: open inference gaps pull rank up
}
```

That is **10** keys. The CHANGELOG `axon/CHANGELOG.md:16` claims 11: "11 ranker signals: intent · dispatch · usage · pattern · next-conditional · goal-alignment · context-pressure · drift · igap · shadow · cost". The eleventh — **cost** — does not exist as a weight key; it is consumed only as a tie-break term and as the numerator in the `context_pressure_penalty` (`synapse_suggest.py:246-253`). F-D4 audit (F-D3-004 in `axon-polish/_flaws.md:330-333`) confirms: "PR-109 description doesn't match code. Users overriding `--weights` for `cost` silently no-op."

#### Per-signal source

| Signal | Where computed | Weight default | Sign | What it reads |
|--------|----------------|---------------:|------|---------------|
| `intent` | `intent_match()` synapse_suggest.py:67-72 | 0.25 | additive | Jaccard on tokens of `state.recent-input` ∩ `candidate.desc` |
| `dispatch` | `dispatch_tfidf()` synapse_suggest.py:75-92 | 0.20 | additive | weighted token overlap (name tokens 2x, desc tokens 1x) — TF-IDF placeholder |
| `usage` | `usage_frequency()` synapse_suggest.py:95-103 | 0.10 | additive | `state.usage.recent[candidate.name]` (0..1); absent → renormalize |
| `pattern` | `pattern_cluster_match()` synapse_suggest.py:106-114 | 0.10 | additive | `state.pattern.clusters[candidate.name]`; absent → renormalize |
| `next_cond` | `next_conditional_score()` synapse_suggest.py:117-135 | 0.15 | additive | Sum of confidences of `candidate.next-conditional` clauses whose `if:` evaluates true |
| `goal` | `goal_alignment()` synapse_suggest.py:225-243 | 0.20 | additive | Jaccard on `goal.statement` ∩ (candidate.desc + post-state + name) |
| `context` | `context_pressure_penalty()` synapse_suggest.py:246-253 | 0.05 | **subtractive** | `(state.context-pressure.pct/100) × (cand.cost.tokens-estimate/10000)` |
| `drift` | `drift_penalty()` synapse_suggest.py:256-257 | 0.05 | **subtractive** | 1.0 iff `state.drift-state ≠ "stable"` |
| `shadow` | `shadow_bonus()` synapse_suggest.py:260-271 | 0.10 | additive | +1 iff shadow-gap open AND candidate advances it |
| `igap` | `igap_signal()` synapse_suggest.py:274-293 | 0.10 | additive | `state.igap-signals[candidate.name]` (0..1); PR-120 |

### Combiner formula

```
raw(c) =   w.intent     × intent_match
         + w.dispatch   × dispatch_tfidf
         + w.usage      × usage_freq         # renormalized if absent
         + w.pattern    × pattern_cluster    # renormalized if absent
         + w.next_cond  × Σ next_cond
         + w.goal       × goal_alignment
         + w.shadow     × shadow_bonus
         + w.igap       × igap_weight
         - w.context    × context_pressure_penalty
         - w.drift      × drift_penalty

score(c) = max(0, raw(c) / max raw)            ∈ [0, 1]
```

When `max raw ≤ 0`, all scores collapse to 0 (synapse_suggest.py:447-452) — the orchestrator's confidence branch then degenerates to whatever the inference-mode default branch says, regardless of which candidate.

### Cold-start (FL-07) and renormalization

`renormalize_weights()` at `synapse_suggest.py:318-331` drops absent additive signals (`usage`, `pattern`) and rescales the remaining additive weights to preserve the original additive sum. This fires implicitly during `score_candidate` (line 368).

A separate function `is_cold_start()` at `synapse_suggest.py:311-315` is defined but **never called** (F-D4-013). CHANGELOG claim of "FL-07 20-fire frequency-prior cold-start bootstrap" is therefore dead-code documentation.

### Filters (pre-score)

`filter_candidate()` at `synapse_suggest.py:297-307` drops:
- `status == "STUB"` (the literal upper-case string)
- precondition evaluates false against state (via the wired `predicate.py` evaluator)
- `requires-shadow == true` AND `state.shadow-gate == "failing"`

The precondition evaluator was a regex placeholder until PR-AUTO-214 wired it to `tools/predicate.py:evaluate_expr` with symbolic-operator normalization (`synapse_suggest.py:168-200`). Fail-open on parse error (line 156-165) increments a process-local `_PREDICATE_ERRORS` counter.

### Tie-break ladder (FL-04)

When two candidates share the same `score`, `tie_break_key()` at `synapse_suggest.py:390-406` applies a 6-level ladder (lower==better):

1. canonical-rank — `ACTIVE/CANONICAL` (0) before `ALIAS/OPTIONAL` (1) before `STUB/DEPRECATED/ARCHIVED` (9)
2. recency — negated `recency.last-fired` (more recent wins)
3. role-match — does candidate role match `requires-mutation` flag
4. cost — `cost.tokens-estimate` (cheaper wins)
5. fine goal — negated `signals.goal` (more goal-aligned wins)
6. lexicographic name

### Decide ladder → `fire | ask | surface-only`

This is the part the orchestrator owns, not the ranker. `orchestrator.md:89-97`:

```
inference-mode 0,1   → "ask"
inference-mode 2-4   → confidence<0.8 ? "ask" : "fire"
inference-mode 5     → confidence<0.7 ? "ask"
                       confidence<0.85 ? "surface-only"
                       : "fire"
inference-mode 6,7   → confidence≥0.6 ? "fire" : "surface-only"
inference-mode 8-10  → "fire"  (default catch-all)
```

`L:inference-mode` is a 0-10 dial (`axon/OUTPUT-LAYER.md` references default 5). The CHANGELOG claim that "L:inference-mode selects ranker weights" is wrong — `rank()` has no `inference-mode` parameter (F-D4-005). Inference-mode only affects the orchestrator's decide step, not the candidate ordering.

### CLI surface

The ranker is invoked from AXON-LANG by:

```
TOOL(synapse-suggest, rank,
     "--state-json {state} --goal-json {goal} --top 10 --explain")
```

The Python CLI (`synapse_suggest.py:507-546`) reads `--state`/`--goal`/`--candidates`/`--registry` as file paths. When `--candidates` is omitted, it falls back to `_load_candidates_from_registry()` (line 481-504) which produces a minimal candidate record per `tools/REGISTRY.json` entry. This fallback path **bypasses synapse-infer** — candidates have empty `next-conditional`, empty `post-state`, no `precondition` beyond `"true"`, and a default cost of 1000 tokens. The richer "infer contracts" path that the docstring promises (line 13-15) is conditional on the caller providing `--candidates` pre-built.

---

## 5. The orchestrator

`workspace/programs/orchestrator.md` is the only program that wakes up between user turns to compute "what next?". It is **a single tick** — not a loop. The header header `# desc:` (line 2) says "Mainline loop (PR-111) — after a neuron fires, query synapse-suggest, walk the DAG, render the next-action set" but the body has no LOOP token. It runs once per invocation and finishes with `DONE(orchestrator)` at line 156.

### Sections of the program

```
IDENTITY LOCK   (line 35-37)   ASSERT L:cognition-frame; STORE active-program
OBSERVE         (line 39-57)   read W:current-goal, W:active-workflow,
                                W:active-workflow-step, L:inference-mode,
                                W:recent-user-input + tool stamps (clock, drift,
                                context, usage, pattern, igap, shadow)
CANDIDATES      (line 59-72)   IF workflow ≡ fixed → [next-step]
                                ELSE → TOOL(synapse-suggest rank)
ZERO-CAND       (line 74-83)   FL-05 fallback — EMIT, dispatch.match, QUERY user
DECIDE          (line 85-97)   confidence × inference-mode → fire/ask/surface
SIDEBAND        (line 99-106)  D-30 — even in fixed-mode, surface alt candidates
RENDER          (line 108-124) emit next-action block
RECORD          (line 126-139) STORE W:orchestrator-last-tick (the surface
                                PR-112 footer reads), APPEND E:orchestrator-tick
ACT             (line 141-153) fire ? CHECKPOINT + dispatch.match
                                ask ? QUERY
                                surface-only ? wait
CLEAR           (line 155)     CLEAR W:active-program
DONE            (line 156)
```

### State observed

```
goal           ← RETRIEVE(W:current-goal)
workflow       ← RETRIEVE(W:active-workflow)        | ∅
workflow-step  ← RETRIEVE(W:active-workflow-step)   | ∅
inference-mode ← RETRIEVE(L:inference-mode)         | 5
recent-input   ← RETRIEVE(W:recent-user-input)      | ""

state ← {
  recent-input,
  active-workflow,
  active-step,
  context-pressure: TOOL(context, status),
  drift:            TOOL(drift, gate),
  usage:            TOOL(usage, top, --window 1d),
  pattern:          TOOL(pattern, cluster),
  igap-signals:     RETRIEVE(W:igap-signals),
  shadow-gap:       RETRIEVE(W:shadow-gap)
}
```

### `W:orchestrator-last-tick` — the single contract surface

```
STORE(W:orchestrator-last-tick, {
  ts,
  mode,
  inference-mode,
  goal-id,
  candidates,
  chosen,
  confidence,
  decision,
  sideband
})
```

`axon/OUTPUT-LAYER.md:86-92` reads this key directly. That is the entire wiring between the orchestrator and the user-visible suggestions footer:

```
sugg-on     ← RETRIEVE(L:suggestions-enabled) | true
tick        ← RETRIEVE(W:orchestrator-last-tick) | ∅
sugg-cands  ← tick.candidates | []
IF drift.state ≡ "diverged"            → sugg-on ← false
IF format ≡ "compact"                  → sugg-cands ← TAKE(sugg-cands, 1)
ELSE IF ctx-p.icon ≡ "!"               → sugg-cands ← TAKE(sugg-cands, 1)
ELSE                                   → sugg-cands ← TAKE(sugg-cands, 3)
```

This is why F-D4-002 has the impact it does: `workflow-run.md` (§ 6) has its own LOOP that never calls the orchestrator, so during a workflow run nothing writes `W:orchestrator-last-tick`, and the OUTPUT-LAYER footer renders empty.

---

## 6. workflow-run — owns its own LOOP, parallel to orchestrator

`workspace/programs/workflow-run.md` is the program responsible for executing a workflow file end-to-end. It is **not** the orchestrator. It has its own loop:

```
cursor ← wf.synapses[0]
trace  ← []
LOOP →
  → "  → step: {cursor.name}"
  result ← EXEC({cursor.name})
  trace ← APPEND(trace, { synapse: cursor.name, ts: now, result: result.status })

  IF wf.execution-mode ≡ "adaptive" →
    ranking ← TOOL(synapse-suggest, --context {wf} --history {trace} --top-k 5)
    → "  ↑ next-step suggestions: {ranking.candidates[0].synapse}"

  next-id ← ∅
  ∀ rule in cursor.on-complete →
    IF (rule.if ≡ ∅ OR TOOL(predicate, eval --expr "{rule.if}").value ≡ true) →
      next-id ← rule.next
      BREAK
  IF next-id ≡ ∅ → BREAK
  cursor ← FIND(wf.synapses, id ≡ next-id) | ∅
  IF cursor ≡ ∅ → FAIL(workflow-run, "next-id '{next-id}' not in synapses list.")
```

(`workflow-run.md:62-81`, condensed)

### What workflow-run does not do

1. **Does not call the orchestrator.** No `EXEC(orchestrator)` anywhere in the file. The orchestrator's PR-112 footer is dark during workflow execution. (F-D4-002)
2. **Does not write `W:active-workflow` or `W:active-workflow-step`.** The orchestrator's fixed-mode branch (`orchestrator.md:60-67`) reads these keys; they are always ∅; the fixed-mode branch is unreachable dead code (F-D4-001).
3. **Does not pass `--ctx` to predicate eval** (workflow-run.md:55, 76, 84). Every `if:` clause that references `state.X` resolves to null. (F-D4-018)
4. **Has no step-count guard.** The LOOP terminates only when `next-id ≡ ∅` at the end of a step. The `steps > 25` rejection criterion in `adaptive-free-text.yml:18` is read only AFTER the loop terminates (lines 84-86 evaluate accept/reject), which never happens. (F-D4-003)
5. **Has no CHECKPOINT before each step** (F-D4-008). PROCESS.md requires it; absence means interrupted workflows can't resume.
6. **Does not STORE `W:active-phase` per step** (F-D9-002). Resume-from-interrupted shows "phase: unknown".
7. **Does not render follow-up suggestions on DONE** (F-D4-014). After the status line at line 90, control flow is `EMIT → LOG → DONE`; no next-suggests footer.

### What workflow-run does

- Validates the workflow YAML against the schema (`workflow-run.md:45-47`, calls `EXEC(workflow-validate ...)`).
- Reads YAML, resolves `path` from `--name` or `--path` (line 38-43).
- Runs the acceptance preflight — if `wf.default-goal.acceptance-criterion` is already TRUE, the run exits immediately (line 54-59). This calls predicate.eval with no ctx, so unless the criterion is a literal like `true`, the preflight always returns false and the run proceeds.
- Walks the on-complete graph; emits one suggestion line per step in adaptive mode.
- On loop exit, evaluates accept + reject; emits status: `met | failed | partial`.
- Emits `axon.workflow.completed` event.

### The orchestrator/workflow-run boundary (ASCII)

```
       Once per user turn                  Once per workflow step
       (after host turn boundary)          (inside workflow-run's LOOP)

       ┌──────────────────────┐            ┌───────────────────────┐
       │ user turn arrives    │            │ workflow-run.md       │
       │ host wires           │            │   loaded from         │
       │   W:recent-user-input│            │   workspace/workflows │
       └─────────┬────────────┘            │   /<name>.yml         │
                 │                          │                       │
                 ▼                          │ for step in graph:    │
       ┌──────────────────────┐             │   EXEC(step.name)     │
       │ orchestrator.md      │             │   → mutates W: state  │
       │ ──────────────────── │             │   IF adaptive:         │
       │ OBSERVE→CANDIDATES   │             │     EXEC(synapse-     │
       │ →DECIDE→RECORD→ACT   │             │       suggest --top-k 5)│
       │ STORE W:orchestrator-│             │     (banner-only)     │
       │   last-tick          │             │   resolve next-id via │
       └─────────┬────────────┘             │     on-complete preds │
                 │                          │   IF next ≡ ∅: BREAK  │
                 ▼                          │ ACCEPT/REJECT preview │
       ┌──────────────────────┐             │ EMIT workflow.completed│
       │ OUTPUT-LAYER footer  │             │ DONE                  │
       │ reads               │             └───────────┬───────────┘
       │   W:orchestrator-    │                         │
       │   last-tick          │                         │
       │ renders top-3        │                         │
       └──────────────────────┘                         │
                                                        │
                                ─────────────────────────────
                                     │
                                     ▼
                            No call from workflow-run
                            into orchestrator.
                            No write into W:orchestrator-last-tick.
                            ⟹ OUTPUT-LAYER footer is empty
                            during workflow execution. (F-D4-002)
```

ADR-007 in `axon-polish/_adrs.md:172` proposes the fix: a 2-line bridge in workflow-run that EXECs orchestrator before each step (observe-only mode). Not landed.

---

## 7. The workflow YAML schema

`workspace/schemas/workflow-file.schema.json` is the JSON-Schema-draft-07 contract. The mirror narrative is at `workspace/WORKFLOW-FILE.md`. Required top-level keys (schema:7):

```
name version domain execution-mode default-goal synapses start
```

Optional top-level keys:

```
triggers
allow-suggestions
allow-deviation
suggestion-channel       # subset of [footer, panel, popup]
suggestion-budget        # {sideband-per-step, sideband-per-run, dismiss-decay, rate-limit-window}
author
created
tags
parent-workflow
```

### Field semantics

| Field | Type | Meaning |
|-------|------|---------|
| `name` | lowercase-kebab string | Workflow id; matches `^[a-z][a-z0-9-]*$` |
| `version` | int ≥1 | Workflow file version |
| `domain` | string or string[] | Single domain or cross-domain (v1.1 GAP-01) |
| `execution-mode` | enum | `fixed | adaptive | hybrid | exploratory | scheduled` (only first two functional) |
| `default-goal` | object | per goal-schema-v1 (§ 12) |
| `triggers[]` | object[] | each `{kind: keyword|state|explicit|schedule, when: <string>}` |
| `allow-suggestions` | bool | gates sideband/footer surfaces during execution |
| `allow-deviation` | bool | whether ranker may propose non-graph candidates |
| `suggestion-channel` | string[] subset | which surface to use |
| `suggestion-budget` | object | rate/depth caps |
| `synapses[]` | object[] | the step graph |
| `start` | string | id of the starting synapse |
| `parent-workflow` | string | overlay base (see python-code-dev → code-dev.canonical) |

### Synapse definition

```json
{
  "id":            "s4",
  "name":          "code-dev-self-review",
  "mode":          "subsystem",
  "mode-override": "adaptive",
  "mode-switch":   ["fixed→adaptive"],
  "role":          "gate",
  "description":   "...",
  "args":          { },
  "on-complete":   [ { "if": "...", "next": "s5", "mode-override": "..." } ]
}
```

`mode-switch` enforces a regex `^(fixed|adaptive|hybrid|exploratory|scheduled)→(...)$` (schema:115). Per-synapse overrides are schema-supported but unused at runtime.

### on-complete graph evaluation

For each rule in `cursor.on-complete`:
1. If `if:` is missing, the rule matches unconditionally (`workflow-run.md:75-78`).
2. If `if:` is present, call `TOOL(predicate, eval, --expr "<if>")`. First TRUE rule wins; subsequent rules are not evaluated.
3. `next:` is the id of the next synapse. The runner does `FIND(wf.synapses, id ≡ next-id)`. Dangling refs → FAIL (line 81).

### `default-goal`

```yaml
default-goal:
  statement:            "Ship a code-dev PR end-to-end (study → plan → ...)."
  measurement:
    - "phase.has(03-prs/PR-*.md) AND all_prs_implemented()"
    - "tests.pass()"
    - "audit.open-findings == 0"
  acceptance-criterion: "audit.open-findings == 0 AND tests.pass()"
  rejection-criterion:  "tests.fail() OR audit.critical-issues > 0"
```

The `measurement[]` list is documentary (no runtime consumer); only `acceptance-criterion` and `rejection-criterion` are evaluated by `workflow-run.md:84-85`.

### Domain triggers

```yaml
triggers:
  - kind: keyword
    when: "user said one of [python pr, python code-dev, ship py pr]"
  - kind: explicit
    when: "workflow run python-code-dev"
```

The `keyword` form is parsed as a free-text rule (host harness inspects `W:recent-user-input` against the bracketed list); `explicit` form matches a literal command grammar. `state` and `schedule` kinds are schema-defined; no runtime consumer.

---

## 8. The 5 reference workflows

CHANGELOG `axon/CHANGELOG.md:45` claims "5 reference workflows shipped (code-dev + 4 others)". Inventory:

| # | Workflow YAML | Domain | Mode | Synapses | Status |
|---|---|---|---|---:|---|
| 1 | `workspace/workflows/adaptive-free-text.yml` | [code-dev, library-dev] | adaptive | 3 (s1 synapse-suggest → s2 code-dev-flow → s3 code-dev-finalize) | Infinite loop (F-D4-003) |
| 2 | `workspace/domains/code-dev/workflows/code-dev.canonical.yml` | code-dev | fixed | 7 (study → plan → pr-create → self-review → knowledge-shadow → safety-audit → merge) | Works as graph; `acceptance-criterion` silent-null (F-D4-017) |
| 3 | `workspace/domains/code-dev/workflows/python-code-dev.yml` | code-dev | fixed | 7 (overlay of #2 with `parent-workflow: code-dev.canonical`) | Same shape as #2; gate uses `ruff.passes()` + `pytest.passes()` |
| 4 | `workspace/domains/code-dev/workflows/cpp-code-dev.yml` | code-dev | fixed | 7 (overlay of #2; gate uses `build.passes()` + `ctest.passes()`) | Same shape as #2 |
| 5 | `workspace/domains/library-dev/workflows/library-dev.canonical.yml` | library-dev | fixed | 8 (adds `code-dev-changelog` between knowledge-shadow and safety-audit) | Works as graph; same silent-null caveat |

### Notes

- `workflow-list.md:39-42` hard-codes its scan to `workspace/workflows/*.yml`. It does **not** scan `workspace/domains/*/workflows/`, so 4 of these 5 workflows are invisible to the list tool (F-D4-009).
- The 3 code-dev variants share the same step graph (s1..s7) with different gate predicates at s6. The library-dev workflow inserts a `code-dev-changelog` step (s6) before the safety-audit (s7).
- `python-code-dev` and `cpp-code-dev` declare `parent-workflow: code-dev.canonical`; the schema accepts this (line 93) but no merge/inherit logic exists — the files redeclare the full synapse list.
- Every workflow except the adaptive one uses `acceptance-criterion` referencing undefined functions: `tests.pass()`, `audit.open-findings`, `ruff.passes()`, `pytest.passes()`, `build.passes()`, `ctest.passes()`, `api-diff.no-breaking-changes()`, `changelog.updated()` — none are in `predicate.py` BUILTINS (F-D4-017). They all silently evaluate to null.

### Step graph for the code-dev family

```
        s1                s2              s3                  s4
        ▼                 ▼               ▼                   ▼
  code-dev-study  →  code-dev-plan  →  code-dev-pr-create → code-dev-self-review
        reader        mutator              mutator                  gate
                                                                    │
                                                  review.passes()   │
                                                                    ▼ ─ next: s5
                                                                    │
                                                  review.has-       │
                                                  objections()      │
                                                                    ▼ ─ next: s3 (loop back)
        s5
        ▼
  code-dev-knowledge-shadow
        mutator
        ▼
        s6
        ▼
  code-dev-safety-audit
        gate
        │
        ├── audit.open-findings == 0 → next: s7
        └── audit.open-findings > 0  → next: s2 (loop back)

        s7
        ▼
  code-dev-merge
        mutator
        (terminal — on-complete: [])
```

(For library-dev, insert `code-dev-changelog` between s5 and s6, renumbering downstream.)

---

## 9. Predicate language

`tools/predicate.py` implements the AXON predicate language v1.1. Hand-rolled recursive-descent parser, stdlib-only. The grammar (precedence low→high) is:

```
implication  ::= disjunction ('->' implication)?         right-assoc
disjunction  ::= conjunction ('OR' conjunction)*
conjunction  ::= negation ('AND' negation)*
negation     ::= 'NOT' negation | comparison
comparison   ::= value (cmpop value)?                    chains forbidden
cmpop        ::= '==' | '!=' | '<=' | '>=' | '<' | '>' | 'in' | 'matches'
value        ::= call | ref | literal | '(' implication ')' | list_literal
ref          ::= ident ('.' ident)+                      e.g. state.foo, L.bar, W.baz
call         ::= ident ('.' ident)* '(' args? ')'        dotted name; e.g. file.exists("...")
literal      ::= str | int | float | 'true' | 'false' | 'null'
list_literal ::= '[' value (',' value)* ']'              constants-only
```

### Recognized scopes

`SCOPES = {"W", "L", "E", "state", "project", "phase", "workflow", "pr", "neuron"}` (predicate.py:136). A bare identifier (e.g. `foo`) is treated as `state.foo` by `Parser.ident_expr()` line 267.

### Refs vs the symbolic L:/W:/E: syntax

The AXON-LANG kernel uses memory-key syntax `L:cognition-frame`, `W:active-program`. The predicate evaluator does **not** speak that syntax directly. `synapse_suggest.py:182-201` (the wiring shim) translates:

```
L:foo-bar  →  L.foo-bar
W:foo-bar  →  W.foo-bar
E:foo-bar  →  E.foo-bar
S:foo-bar  →  state.foo-bar   (S: is a synapse-suggest extension)

≡  →  ==
≢  →  !=
∈  →  in
∉  →  not in
∧  →  AND
∨  →  OR
¬  →  NOT
```

Anything else (e.g. `goal.acceptance.met()`) is passed through as-is. Since `goal.acceptance.met` is not in BUILTINS, it raises `undefined_function`. The safe-null mode (line 49 of `predicate.md`) makes the CLI return `null` instead of erroring; `null ≡ true` is false → the predicate silently bypasses (F-D4-017).

### BUILTINS — 14 functions registered (per predicate.py:364-381)

| Name | Arity | Returns | Source |
|---|---:|---|---|
| `file.exists(path)` | 1 | bool | `_builtin_file_exists` |
| `dir.exists(path)` | 1 | bool | `_builtin_dir_exists` |
| `file.readable(path)` | 1 | bool | `_builtin_file_readable` |
| `file.writable(path)` | 1 | bool | `_builtin_file_writable` |
| `file.size(path)` | 1 | int or null | `_builtin_file_size` |
| `file.mtime(path)` | 1 | int or null | `_builtin_file_mtime` |
| `file.contains(path, needle)` | 2 | bool | `_builtin_file_contains` |
| `count(glob)` | 1 | int | `_builtin_count` |
| `glob_first(glob)` | 1 | string or null | `_builtin_glob_first` |
| `glob_all(glob)` | 1 | list[string] | `_builtin_glob_all` |
| `int(x)` | 1 | int | inline lambda |
| `float(x)` | 1 | float | inline lambda |
| `str(x)` | 1 | string | inline lambda |
| `bool(x)` | 1 | bool | inline lambda |
| `len(x)` | 1 | int or null | inline lambda |

The doc at `workspace/tools/predicate.md:62-76` lists `int / float / str` as one row; the actual table is 14 entries (`bool` is also separate). Domain-registered predicates (e.g. `code-dev.pr.has_spec(7)`) are mentioned in `predicate.md:78-79` as "forwarded to domain registries (Phase 4 work; see PR-119)" — no domain registry interface exists in `predicate.py`. So **only the 14 entries above are real**.

### What's not in BUILTINS but is used in shipped YAMLs

Every reference workflow uses functions that are not registered. From § 8 example acceptance criteria:

```
goal.acceptance.met()       # adaptive-free-text.yml
goal.rejection.met()        # adaptive-free-text.yml
tests.pass()                # code-dev.canonical.yml, library-dev.canonical.yml
tests.fail()                # rejection
audit.open-findings         # not a function call — bare ref; resolved against
                            #   ctx["state"]["audit"]["open-findings"] — but
                            #   workflow-run passes no ctx (F-D4-018)
audit.critical-issues       # same
review.passes()             # code-dev.canonical.yml on-complete
review.has-objections()     # same
all_prs_implemented()       # measurement
phase.has(...)              # measurement
ruff.passes()               # python-code-dev.yml
pytest.passes()             # python-code-dev.yml
build.passes()              # cpp-code-dev.yml
ctest.passes()              # cpp-code-dev.yml
api-diff.no-breaking-changes()                # library-dev.canonical.yml
api-diff.has-breaking-changes-without-major-bump()   # same
changelog.updated()         # library-dev.canonical.yml
```

The fix path (ADR-005b in `axon-polish/_adrs.md`) is to register a `goal.*` family in BUILTINS plus a per-step goal evaluation. Neither has landed.

### Operators in workflow YAMLs

Predicates in YAMLs use a mix of:
- ASCII (`==`, `!=`, `AND`, `OR`, `NOT`, `>`, `<`, `<=`, `>=`)
- Symbolic (`≡`, `≢`, `∈`, `∉`, `∧`, `∨`, `¬`)
- Function-call form (`tests.pass()`)
- Bare-ref comparison (`audit.open-findings == 0`)

The `synapse_suggest.py` symbol-normalizer covers the symbolic forms when synapse-suggest evaluates preconditions. `workflow-run` calls predicate.eval directly without normalization — symbolic predicates fail to parse there.

### Template interpolation

Inside a string literal, `{scope.path}` is replaced at eval time. `_interpolate()` at `predicate.py:308-320`. So `file.exists('phases/{phase.name}/01-study.md')` resolves `{phase.name}` against the ctx.

### Safe-null mode (default in CLI)

When a ref resolves to null, comparisons (`>`, `<`, etc.) raise `null_in_comparison`. In safe-null mode, the result is `False` rather than an exception. This is the mode used by both `synapse_suggest.py` and `goal.py` (both call `predicate.evaluate_expr(expr, ctx, safe_null=True)`).

---

## 10. DAG model

`tools/dag.py` implements the canonical DAG model per `workspace/DAG-SPEC.md` (mirrored from `axon-synapse/phases/2-design/specs/dag-spec-v1.md` by PR-110).

### Five levels

| Level | File path (canonical) |
|---|---|
| Project | `<project>/DAG.json` |
| Phase | `<project>/phases/{n}/DAG.json` |
| Plan | `<project>/phases/{n}/03-prs/DAG.json` |
| PR | `<project>/phases/{n}/03-prs/PR-NNN/DAG.json` (optional) |
| Study | `<project>/phases/{n}-study/DAG.json` |

`DAG.json` is canonical; `DAG.md` is a one-way auto-emit human mirror (re-rendered on every mutation).

### JSON schema (canonical shape)

```json
{
  "schema":          "axon-dag",
  "schema-version":  "v1",
  "level":           "phase",
  "owner":           "<path of owning node>",
  "generated":       "2026-05-21T00:00:00Z",
  "generator":       "tools/dag.py",
  "validated":       true,
  "critical-path":   ["n1","n3","n7"],
  "nodes": [
    { "id":"n1","kind":"synapse","name":"code-dev-study",
      "label":"Phase 1","status":"complete","child-dag":null }
  ],
  "edges": [
    { "from":"n1","to":"n2","kind":"depends" }
  ]
}
```

Constants from `tools/dag.py`:

```python
LEVELS         = ("project", "phase", "plan", "pr", "study")
NODE_KINDS     = ("synapse", "pr", "phase", "step", "question", "finding")
NODE_STATUSES  = ("pending", "active", "complete", "failed", "skipped", "merged")
EDGE_KINDS     = ("depends", "unblocks", "informs")
```

### Mutator API

Public functions in `tools/dag.py` (each has a sibling `cmd_*` CLI wrapper):

| Function | Lines | What it does |
|---|---|---|
| `make_empty(level, owner)` | 64-78 | Initial empty DAG dict |
| `add_node(dag, id, kind, name, label, status, child_dag)` | 103-116 | Append a node; raises if id exists or kind/status unknown |
| `add_edge(dag, frm, to, kind="depends")` | 119-136 | Append an edge; cycle-guard rejects depends-edges that close a cycle |
| `remove_node(dag, id)` | 139-146 | Cascading remove (node + its edges) |
| `remove_edge(dag, frm, to)` | 149-153 | Drop matching edge |
| `set_status(dag, id, status)` | 156-163 | Update node status (must be in NODE_STATUSES) |
| `merge_nodes(dag, ids, into, new_label)` | 166-185 | Redirect edges; remove sources; create merge target |
| `split_node(dag, id, into_ids, new_labels)` | 188-210 | Duplicate incoming/outgoing edges onto new ids; remove source |
| `fold_in(dag, child_id, into)` | 213-223 | Move every edge touching `child_id` to `into`, then remove `child_id` |
| `detect_cycle(dag)` | 227-250 | Kahn's algorithm |
| `critical_path(dag)` | 253-291 | Longest path by edge count over depends edges |
| `verify(dag, dag_path)` | 294-336 | schema + cycle + dangling + nested checks |
| `render_md(dag_path)` | 340-374 | Regenerate sibling DAG.md |
| `sync_project(root)` | 378-391 | Walk every DAG.json under root; verify each |
| `migrate_file(dag_path)` | 427-521 | Lossless v1 migration; preserves non-v1 keys under `_legacy` |

CLI subcommands (`tools/dag.py:646-731`): `bootstrap | add-node | add-edge | remove-node | remove-edge | set-status | merge | split | fold-in | render | verify | sync | migrate`.

### What's missing relative to the CHANGELOG claim

`axon/CHANGELOG.md:21` says PR-110 ships "Reversible operations (merge/split/fold-in/defer/cut)". The implementation has `merge`, `split`, `fold_in`, but **no `defer`, no `cut`** (F-D4-007). Running `python3 axon.py dag defer ...` returns `argparse: invalid choice`. Additionally, none of the mutators are reversible in the literal sense — there is no undo/inverse helper, no journal. Each mutation atomically rewrites `DAG.json`. (F-D4-006)

### Cycle guard

`add_edge` rejects any depends-edge that would close a cycle. From `tools/dag.py:132-135`:

```python
if kind == "depends" and detect_cycle(dag):
    edges.pop()
    raise ValueError(f"adding edge {frm}->{to} would create a cycle (CYCLE_DETECTED)")
```

Other edge kinds (`unblocks`, `informs`) do not contribute to topological order and are exempt from the cycle guard.

### Verify

`verify()` checks (`tools/dag.py:294-336`):
- `SCHEMA_VERSION_MISMATCH` — version != "v1"
- `SCHEMA_FIELD` — schema != "axon-dag"
- `NODE_MISSING_ID` — node has no id
- `DANGLING_EDGE_FROM` / `DANGLING_EDGE_TO` — edge endpoint not in nodes
- `CYCLE_DETECTED` — Kahn check fails
- `ORPHAN_NODE` (warn) — node touches no edges
- `MISSING_CHILD_DAG` — nested `child-dag` file missing

### Auto-render

`_save_and_render()` at `tools/dag.py:525-529` always rewrites both `DAG.json` (atomic tmp-rename) and `DAG.md`. The MD render emits header → bullets → nodes table → edges table. The Mermaid block described in `workspace/DAG-SPEC.md:97-101` is **not** in the current Python implementation — `render_md()` emits a Markdown table only.

### Auto-emit (the F-D4-016 issue)

CHANGELOG implies a DAG is created automatically at plan time. The actual trigger sits in `code-dev-plan.md` and fires on reading the `prs_ordered` table inside the plan file — content-coupled, not event-coupled. Multiple invocation paths skip it silently:
- Direct `_meta.md` authoring at phase-2-design
- `code-dev-resume` after a checkpoint pre-dating plan
- `code-dev-pr-create` before `code-dev-plan`

All three leave `03-prs/DAG.json` unbuilt. (F-D4-016)

---

## 11. Dispatch — TF-IDF program matching

`tools/dispatch.py` is the program-name matcher. It is independent of `synapse-suggest`: while synapse-suggest ranks candidate **synapses** for the orchestrator, `dispatch` matches a **user free-text query** to a compiled program for `EXEC`.

### Mechanism

```
query  →  TfidfVectorizer (sklearn)  →  cosine-similarity vs corpus
       →  best match + score
       →  IF score ≥ threshold  →  {action: "dispatch", program, confidence}
       →  ELSE                  →  {action: "fallback", reason, best_match}
```

Threshold default 0.65 (`tools/dispatch.py:47`). Configurable via `workspace/preferences/smart-dispatch.md:dispatch-confidence`.

### Index file

`workspace/memory/longterm/dispatch-index.json`. Populated by `compile-suggest.py` (when programs are compiled). Each entry:

```json
{
  "program-name": {
    "program":     "program-name",
    "description": "...",
    "source_file": "<path>",
    "compiled_at": "<iso>"
  }
}
```

The corpus row built for matching is `f"{program-name} {description}"` (`dispatch.py:222`).

### Subcommands

| Subcommand | Purpose |
|---|---|
| `match --query TEXT [--threshold F]` | Match query; dispatch or fallback |
| `index list` | Print the index |
| `index add --program P --desc D` | Manually register |
| `index remove --program P` | Drop entry |
| `feedback --id ID --result yes\|no` | Record dispatch outcome (jsonl-appended to `memory/longterm/dispatch-feedback.jsonl`) |
| `correlate --signal {continuation,igap-absent,drift-halt,restated}` | PR-014 implicit feedback hook |
| `stats` | Counts + accuracy |

### Auto-tune

Gated by both `L:dispatch-auto-tune` (default false) AND `feedback-adjust-threshold` preference (default true). When both agree and the last 20 dispatches have neg-rate > 0.3, threshold is bumped +0.05 (capped at 0.9). The tune writes back to `preferences/smart-dispatch.md` and uses `_loop_receipt_ctx.loop_receipt` for audit.

### How synapse-suggest and dispatch interact

The orchestrator's ACT step (orchestrator.md:142-148) calls `TOOL(dispatch, match, "--query {top.name} --top 1")` after deciding to fire. So:

1. Ranker proposes synapse names (e.g. `code-dev-plan`).
2. Orchestrator decides one wins.
3. Dispatch matches that synapse name to a compiled program file via TF-IDF.
4. Compiled program is EXEC'd.

The double-match (rank then dispatch) is by design — ranker returns names, dispatch returns paths. The dispatch step is also where the "F-D5-001 dead EXEC targets" guard lives: a name with no compiled file falls into the fallback branch.

### prefer-compiled

`workspace/preferences/smart-dispatch.md:prefer-compiled` — when true, dispatch bypasses threshold for any match > 0 if a compiled version exists.

---

## 12. Goal model

`tools/goal.py` and `workspace/templates/goal-v1.yml`. Backed by the index at `workspace/memory/goals.yml` (default).

### Levels (per `goal.py:47`)

```
{"project", "phase", "workflow", "step", "pr", "finding", "demand"}
```

### Statuses (per `goal.py:48-49`)

```
{"open", "in-progress", "designed", "met", "deferred",
 "met-with-open-children", "failed"}
```

### Sources (per `goal.py:50`)

```
{"user", "workflow-default", "inferred-confirmed", "inherited"}
```

### Goal record schema

From `workspace/templates/goal-v1.yml`:

```yaml
goal:
  id:                   goal-YYYY-MM-DD-N      # ^goal-\d{4}-\d{2}-\d{2}-\d+$
  level:                step                    # one of the 7 levels
  domain:               code-dev                # OPTIONAL, default "system"
  statement:            "<one-sentence plain-English goal>"
  rationale:            "<why this goal exists>"
  measurement:                                  # list of predicate strings
    - "file.exists('05-audit.md')"
  acceptance-criterion: "true"                  # predicate; true → MET
  rejection-criterion:  "false"                 # predicate; true → FAILED
  parent-goal:          null                    # OPTIONAL
  child-goals:          []
  source:               user                    # closed list
  inference-log:        []
  status:               open                    # closed list
  status-history:
    - { ts: "...", from: null, to: open, reason: "initial" }
  workflow:             null                    # OPTIONAL
  tags:                 []
```

Required fields enforced by `validate_record()` at `goal.py:92-106`: `id, level, statement, status`. Closed-list values are validated; `id` must match `^goal-\d{4}-\d{2}-\d+$`.

### CLI surface

| Subcommand | Purpose |
|---|---|
| `goal set --statement ... [--id ... --level ... --domain ... --acceptance ... --rejection ...]` | Create a goal record; id auto-allocated as `goal-YYYY-MM-DD-N` |
| `goal get --id <id>` | Fetch record |
| `goal confirm --id <id>` | Transition open → in-progress |
| `goal list [--level <l> --status <s>]` | List goals |
| `goal met --id <id> [--ctx <json>]` | Evaluate acceptance/rejection; exit 0 if MET (and exit code 2 if not, ok if no error) |
| `goal audit --project <path> [--ctx <json> --verbose]` | Walk a project tree; report MET vs unmet per level |

### How predicates evaluate in goal

`cmd_met()` at `goal.py:198-215`:

```python
acc = rec.get("acceptance-criterion") or "true"
rej = rec.get("rejection-criterion") or "false"
accept_v, accept_err = _evaluate(acc, ctx, default=True)
reject_v, reject_err = _evaluate(rej, ctx, default=False)
return {
    "met":      accept_v and not reject_v,
    "accepted": accept_v,
    "rejected": reject_v,
}
```

`_evaluate` (line 183-195) calls `predicate.evaluate_expr(expr, ctx, safe_null=True)`. So absent predicate → accept default True / reject default False; empty acceptance ⇒ MET vacuously. ParseError/EvalError sets `met=False` and propagates the error code.

### Project audit

`cmd_audit()` at `goal.py:327-376` traverses a project tree and pulls goal records from:

```
<root>/_goal.md                            (project)
<root>/phases/*/_meta.md                   (phase, via `goal:` block)
<root>/phases/*/03-prs/pr-*.md             (pr, via frontmatter or block)
<root>/**/workflows/*.yml                  (workflow, via default-goal)
<root>/**/F-*.md                           (finding)
<root>/_demands.md                         (demand)
```

Each record is evaluated against a merged ctx and summarized into `{met, unmet, errors}`. The `--verbose` flag includes the per-level breakdown.

---

## 13. Known issues — F-D4 audit cross-reference

Source: `/mnt/c/projects/axon/my-axon/dev-projects/axon-polish/_flaws.md` (the axon-polish audit, reconciled 2026-05-21). Numbering matches the axon-polish catalog.

### BLOCKER

| # | Finding | One-line summary |
|---|---|---|
| **F-D4-003** | adaptive-free-text infinite loop | `workflow-run.md:64-81` has NO step-count guard inside the LOOP; `state.steps > 25` rejection-criterion (adaptive-free-text.yml:18) is read only AFTER the loop terminates — which never happens. Nothing in workflow-run updates `goal.*` between iterations. Loop is **truly infinite**, not 25-bounded. Source-of-truth for "the canonical adaptive workflow is unrunnable". |
| **F-D4-017** | `goal.acceptance.met()` undefined in BUILTINS | `tools/predicate.py:364-381` has 14 entries; NONE match `goal.acceptance.met`, `goal.rejection.met`, `tests.pass`, `audit.open-findings`, `phase.has`, `all_prs_implemented`, etc. Safe-null returns null; `null ≡ true` is false → predicate silently bypassed. Every shipped workflow that uses goal.* shorthand never reports "met". |

### MAJOR

| # | Finding | One-line summary |
|---|---|---|
| **F-D4-001** | orchestrator fixed-mode is dead code (REFRAMED from BLOCKER) | `workflow-run.md` never STOREs `W:active-workflow` / `W:active-workflow-step`. Orchestrator's `mode` always resolves to `"free-text"`. The buggy line `workflow.steps[workflow-step].next | workflow.next-step` is never reached at runtime. Architecturally broken but not a user-visible crash. |
| **F-D4-002** | workflow-run never enters orchestrator loop | Two independent loops (`workflow-run.md` has its own LOOP; `orchestrator.md` has the PR-111 composition tick). They do not call each other. `W:orchestrator-last-tick` is never written during workflow runs → PR-112 suggestion footer (advertised as mainline UX) is invisible during actual workflow execution. |
| **F-D4-004** | hybrid execution mode is schema-only | Schema accepts `hybrid`; `workflow-run.md:69` only branches on `adaptive`; orchestrator knows only `fixed`/`adaptive`/`free-text`. Hybrid YAML schema-validates but executes identically to fixed. |
| **F-D4-005** | inference-mode does NOT alter ranker weights | `synapse_suggest.py:rank()` has no inference-mode parameter. L:inference-mode is only used in the orchestrator's `decide(fire/ask/surface)` branch. Documented "weighted per inference-mode" is wrong. |
| **F-D4-006** | DAG mutations are not reversible | `tools/dag.py` mutators do direct dict mutation + atomic_write. No journal, no undo cmd, no inverse helper. Workflow DAG authoring is one-way. |
| **F-D4-007** | DAG defer + cut advertised but not implemented | CHANGELOG: "Reversible operations (merge/split/fold-in/defer/cut)". Code has merge/split/fold_in but no defer, no cut. `dag defer ...` returns argparse "invalid choice". |
| **F-D4-008** | workflow-run does not CHECKPOINT before each step | No CHECKPOINT token in `workflow-run.md`. PROCESS.md violation. Workflow interrupted at step 5 cannot resume. |
| **F-D4-009** | workflow-list misses domain-scoped workflows | `workflow-list.md:39-42` hard-codes `wf-dir ← "workspace/workflows"`; never scans `workspace/domains/*/workflows/`. 4 of 6 reference workflows invisible. |
| **F-D4-010** | adaptive mode is observability-only | `workflow-run.md:69-71` emits suggestion line but ignores it; next-id still picked by on-complete predicates. "Adaptive" mode behaves identically to "fixed" with a console message. |
| **F-D4-011** | orchestrator candidates type mismatch | `orchestrator.md:64-72` + 86: fixed mode returns `[next-step]` (list of strings); adaptive returns dicts. Then `top.score` is undefined for fixed → confidence=0 → decision branch "ask" → question-spam. All fixed workflows degrade to ask-every-step at default inference-mode 5. |
| **F-D4-014** | workflow-run dead-end on COMPLETE | `workflow-run.md:84-95`: after status output, control flow is EMIT → LOG → DONE; no next-suggests rendered. User sees the workflow finish but is given no follow-up. |
| **F-D4-015** | workflow-run FAIL has no recovery suggestions | Just `"Workflow file {path} failed schema validation. Run workflow-validate for details."` — no Problem/Cause/Fix/Suggested-next block per kernel mandate. |
| **F-D4-016** | DAG auto-emit is content-coupled, not event-coupled | `code-dev-plan.md` auto-emit fires on reading `prs_ordered` from plan file. Three bypass paths leave `03-prs/DAG.json` unbuilt: direct `_meta.md` authoring, `code-dev-resume` after pre-plan checkpoint, `code-dev-pr-create` before `code-dev-plan`. |
| **F-D4-018** | workflow-run calls predicate.eval with no `--ctx` | `workflow-run.md:55, 76, 84-85` passes `--expr` but never `--ctx`. Any predicate referencing `state.*` resolves to null → safe-null returns False. No state-based termination predicate works. Hidden prerequisite for any ADR-005 step-count-guard fix. |

### MINOR

| # | Finding | One-line summary |
|---|---|---|
| **F-D4-012** | `workflow-new` ignores its own author-state JSON shape | `workflow-new.md:64,77-78,104-105` uses `APPEND` on a dict and `STORE` on dotted-keys — neither is a supported AXON-LANG form. |
| **F-D4-013** | synapse-suggest cold-start function defined but never called | `tools/synapse_suggest.py:311-315` defines `is_cold_start()`; `rank()` never invokes it. CHANGELOG claim of FL-07 cold-start bootstrap is dead code. |
| **F-D4-016 (b)** | workflow-validate skips identity-lock block | `workflow-validate.md` has no IDENTITY LOCK block on entry; every other `workflow-*` program has one. (Note: this F-D4-016 ID is a duplicate in the source audit — there are two F-D4-016 entries; this is the MINOR one.) |

### Out-of-D4 findings that touch this surface

- **F-D3-004** — CHANGELOG claims 11 ranker signals; code has 10 (`cost` is a tie-break term, not a weight). `--weights cost=...` is silently no-op.
- **F-D9-016** — workflow-run max-steps unlimited (vs simulate's 50). Malformed on-complete graph loops infinitely (this is the upstream of F-D4-003 too).
- **F-D9-002** — workflow-run never sets `W:active-phase` per step. Interrupted workflow at step 5 of 10 → boot offers no step-num.

### Severity rollup

```
BLOCKER : 2   (F-D4-003, F-D4-017)
MAJOR   : 14  (F-D4-001, -002, -004 to -011, -014, -015, -016, -018)
MINOR   : 2   (F-D4-012, -013) + 1 duplicate-ID (workflow-validate identity-lock)
```

### Cross-link to ADRs

The audit project (`axon-polish/_adrs.md`) proposes:

- **ADR-005a** (now, S) — step-count guard + ctx-passing. Closes F-D4-003 (immediate BLOCKER). ~5 LOC in workflow-run.md + same in workflow-simulate.md.
- **ADR-005b** (later, M) — register `goal.*` family in BUILTINS + per-step goal evaluation. Closes F-D4-017 + F-D4-018 broadly. Deferred pending decisions on storage location, concurrency, scope.
- **ADR-007** — workflow-run ↔ orchestrator boundary. Closes F-D4-002, F-D4-014; partial F-D4-001. Proposes a 2-line bridge (EXEC orchestrator observe-only before each step).
- **ADR-004** — Phase-transition invariants. Closes F-D4-016 (DAG-skip).

None of these ADRs are landed in the v3.7.0 tree.

---

## Appendix A — File index

Primary sources (read for this doc):

```
/home/arturcastiel/projects/axon-development/axon/
├── CHANGELOG.md                                        — § 3.7.0 mainline composition path
├── axon/OUTPUT-LAYER.md                                — PR-112 SUGGESTIONS FOOTER (line 81-103)
├── tools/
│   ├── synapse_suggest.py                              — 551 lines; 10-signal ranker
│   ├── dag.py                                          — 744 lines; mutator API + cycle guard
│   ├── dispatch.py                                     — TF-IDF program matcher
│   ├── goal.py                                         — goal-schema-v1 set/get/confirm/list/met/audit
│   └── predicate.py                                    — 519 lines; predicate language v1.1
├── workspace/
│   ├── DAG-SPEC.md                                     — DAG schema spec (mirror)
│   ├── WORKFLOW-FILE.md                                — workflow YAML spec (mirror)
│   ├── schemas/workflow-file.schema.json               — JSON-Schema draft-07 contract
│   ├── templates/goal-v1.yml                           — goal record template
│   ├── tools/predicate.md                              — predicate CLI doc
│   ├── tools/synapse-suggest.md                        — ranker CLI doc
│   ├── workflows/adaptive-free-text.yml                — the one cross-domain adaptive workflow
│   ├── domains/code-dev/workflows/
│   │   ├── code-dev.canonical.yml
│   │   ├── python-code-dev.yml
│   │   └── cpp-code-dev.yml
│   ├── domains/library-dev/workflows/
│   │   └── library-dev.canonical.yml
│   └── programs/
│       ├── orchestrator.md                             — the PR-111 single-tick loop
│       ├── workflow-run.md                             — the per-step LOOP
│       ├── workflow-new.md                             — conversational author (phases A→E)
│       ├── workflow-list.md                            — listing tool
│       ├── workflow-edit.md                            — interactive editor
│       ├── workflow-simulate.md                        — dry-run walker
│       └── workflow-validate.md                        — schema + semantic check
```

Audit + design-intent sources:

```
/mnt/c/projects/axon/my-axon/dev-projects/
├── axon-polish/_flaws.md                               — finding catalog F-D1..D9
├── axon-polish/_adrs.md                                — proposed ADRs (none landed in v3.7.0)
├── axon-polish/04-log.md                               — audit run log
└── axon-synapse/
    ├── RETRO.md                                        — design-intent retro (PR-101..120)
    └── AUDIT.md                                        — phase audit
```

---

## Appendix B — Key types referenced by the ranker

### candidate record (consumed by `synapse-suggest.rank`)

```python
{
  "name":             str,                        # synapse / program name
  "desc":             str,                        # used by intent/dispatch/goal signals
  "purpose":          str,                        # alias for desc
  "status":           "ACTIVE"|"CANONICAL"|"ALIAS"|"OPTIONAL"|"STUB"|"DEPRECATED"|"ARCHIVED",
  "domain":           str,                        # closed glossary list
  "role":             str,                        # reader|mutator|gate|orchestrator
  "precondition":     str,                        # predicate language
  "post-state":       list[str],                  # used by goal_alignment
  "next-conditional": list[{if: str, confidence: float}],
  "requires-shadow":  bool,                       # filter signal
  "requires-mutation":bool,                       # tie-break signal
  "advances-shadow":  bool,                       # shadow_bonus signal
  "recency":          {last-fired: float},        # tie-break
  "cost":             {tokens-estimate: int},     # context_pressure_penalty + tie-break
}
```

### state record (consumed by `synapse-suggest.rank` and the orchestrator)

```python
{
  "recent-input":     str,
  "active-workflow":  str | None,
  "active-step":      str | None,
  "context-pressure": {pct: float},
  "drift":            {state: "stable"|"warning"|"diverged"},
  "drift-state":      str,                        # legacy flat form
  "usage":            {recent: {name: float}},    # name → 0..1
  "pattern":          {clusters: {name: float}},
  "igap-signals":     {name: float},
  "shadow-gap":       {advances-by: str} | None,
  "shadow-gate":      "stable"|"failing",
  "fires":            int,                        # cold-start; never read
  # plus L/W/S/state nested scopes that synapse-suggest mirrors
  "L":                dict,
  "W":                dict,
  "S":                dict,
}
```

### tick record (written by orchestrator, read by OUTPUT-LAYER)

```python
W:orchestrator-last-tick = {
  "ts":             "<iso>",
  "mode":           "fixed"|"adaptive"|"free-text",
  "inference-mode": int,
  "goal-id":        str | None,
  "candidates":     [{name, score, raw, reason?, signals?}],
  "chosen":         str,                          # top.name
  "confidence":     float,
  "decision":       "fire"|"ask"|"surface-only",
  "sideband":       [{name, score, ...}]          # D-30 — fixed-mode opt-in alts
}
```

---

## Appendix C — Walk-through: the adaptive-free-text run that does not terminate

To make F-D4-003 concrete: trace what happens when a user types something matching the `adaptive-free-text` triggers (`workspace/workflows/adaptive-free-text.yml:21-24`):

1. `workflow-run --name adaptive-free-text` is invoked.
2. Workflow file is loaded; `wf.execution-mode == "adaptive"`.
3. ACCEPTANCE-PREFLIGHT (line 55): `TOOL(predicate, eval, --expr "goal.acceptance.met()")`. No `--ctx` passed (F-D4-018). `goal.acceptance.met` is not in BUILTINS (F-D4-017). predicate.py raises `undefined_function`; safe-null mode returns `null`. `null ≡ true` is false → preflight does not short-circuit.
4. LOOP enters at step `s1` (`synapse-suggest`).
5. `EXEC(synapse-suggest)` — note this is the synapse-suggest **program**, not the tool. The role is `orchestrator` in the YAML, but workflow-run does not know about that role; it just EXECs. No goal state is mutated.
6. Adaptive branch fires (line 69): `TOOL(synapse-suggest, --context wf --history trace --top-k 5)`. The ranker emits a suggestion banner. The next-id is NOT taken from the ranking — it is taken from `on-complete` (F-D4-010).
7. on-complete for s1: `if goal.acceptance.met()` → null → false; `if goal.rejection.met()` → null → false; default `next: s2`.
8. Step `s2` (`code-dev-flow`). `EXEC(code-dev-flow)`. No goal mutation.
9. on-complete for s2: `if goal.acceptance.met()` → null → false; default `next: s1`.
10. Cursor goes back to s1. Goto 5.

The loop has no escape because:
- `goal.acceptance.met()` never resolves to true (always null).
- `goal.rejection.met()` never resolves to true (always null).
- The `steps > 25` predicate from the **rejection-criterion** (line 18) is checked only at the post-loop ACCEPTANCE-CHECK (workflow-run.md:84-85), which is unreachable.
- `workflow-run` has no internal step-count guard.

The fix is ADR-005a: add a step-count guard inside the LOOP and pass a `--ctx '{"steps": <n>, "state": {...}}'` to the predicate.eval calls. ~5 LOC.

Until that lands, the adaptive workflow is effectively unrunnable.
