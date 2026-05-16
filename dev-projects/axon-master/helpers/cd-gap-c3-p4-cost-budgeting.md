# CD·GAP·C3·P4 — unified token/cost budgeting (U-8)

> Token & cost concerns appear in R2 (compile compression), R3 (router sizes), R4 (workflow overhead), R5 (per-mode budgets). Unify into one framework.

## What we know about token costs today

| Source                            | Datum                                          |
|-----------------------------------|------------------------------------------------|
| R2 (`cd-c3-p1-tokens.md`)         | code-dev-pr-review.cmp.md at -1% (NEGATIVE)    |
| R2                                | static-prefix discipline matters for cache     |
| R3                                | router stubs proposed at < 2 KB each           |
| R4                                | end-to-end flow may chain 5-8 programs          |
| R5                                | per-mode budgets proposed: quick=1k, standard=5k, deep=15k tokens |
| Kernel                            | KERNEL-SLIM is ~5 KB target                    |
| `tools/tokenizer.py`              | exists                                         |

## Cost composition (per turn)

```
turn_tokens =
    + system_prompt        # AGENT/COPILOT instructions (~3-5 KB)
    + kernel_anchor        # KERNEL-SLIM injected (~5 KB)
    + memory_load          # user memory top section (~1-2 KB)
    + program_compiled     # current program (~3-25 KB)
    + project_context      # _meta.md, recent _actions, study/_index (~2-10 KB)
    + chat_history         # conversation, compacted (~5-50 KB)
    + tool_results         # variable
    + user_message         # variable
    + model_response       # output (we pay for this too)
```

Naïve estimate: 20-100 KB ≈ 5k-25k tokens per turn before reasoning.

## Budget framework (proposed)

Three levels of budget, with caps:

### L0 — per-turn ceiling (hard cap)
- Set per project: `_meta.md` field `token-ceiling: 32000`.
- Agent runs cost-estimator pre-call (`tools/usage.py`).
- If projected > ceiling → HALT + offer modes (compact context, shorter program, etc.).

### L1 — per-program budget (advisory)
- Each compiled program declares (in frontmatter):
  ```yaml
  budget:
    input-cap: 8000     # input tokens to model
    output-cap: 4000    # max response
    cache-prefix: 2048  # static prefix in tokens
  ```
- `tools/compile-write.py` enforces output-cap during compile.
- Runtime: agent self-budgets (no oracle; uses tokenizer).

### L2 — per-mode budget (R5 alignment)
- `study --quick`: 1k tokens output, 4k input.
- `study --standard`: 5k / 16k.
- `study --deep`: 15k / 40k.
- `plan` modes: similar.
- Mode picks an effective program variant (or single program with mode-gated sections).

### L3 — session-level budget (envelope)
- Per session: target total tokens (e.g. 200k).
- `tools/usage.py` tracks; warns at 80%.
- Auto-checkpoint at 90%; suggest handoff at 95%.

## Cache strategy

LLM prompt caching (Anthropic, OpenAI) caches static prefixes. To maximize hits:
- Kernel anchor: PURE STATIC. Never include date/user info inline.
- Compiled programs: PURE STATIC body; dynamic vars passed via separate "user-message" turn.
- Memory load: HIGH-CHURN content goes in user-prompt-tail, not anchor.

### Static-prefix discipline checklist
- [ ] No timestamps in compiled programs.
- [ ] No user-specific info in compiled headers.
- [ ] Programs reference variables via `{W:...}` symbols, expanded at runtime.
- [ ] `tools/compile-write.py` rejects headers with dates, paths from `$HOME`, etc.

## Measurement plan

`tools/usage.py` should emit, per turn:
```json
{
  "ts": "...",
  "session": "...",
  "program": "code-dev-plan",
  "input_tokens": 12450,
  "output_tokens": 3200,
  "cache_hit_rate": 0.84,
  "cost_usd": 0.12
}
```

Aggregator: `code-dev meta usage [--by program | --by session | --by day]`.

## Reduction levers

| Lever                                | Estimated saving |
|--------------------------------------|------------------|
| Cache-prefix discipline               | 40-70% on input  |
| Router stubs (R3 W1) replacing fat programs | 20-40% per dispatch |
| Mode-gated programs (R5)              | 30-60% on output |
| Compaction summaries vs full transcript | 50-80% on long sessions |
| Compile-gate (T-A3) blocking negative compressions | direct: prevents future bloat |
| Memory tier: only top-200 lines auto-loaded | already in effect |

## Cost dashboards (proposed UX)

- `code-dev meta cost today`           → total tokens, USD, vs ceiling.
- `code-dev meta cost program <name>`  → per-program averages.
- `code-dev meta cost session`         → current session burn.

Backed by `tools/usage.py` JSONL log at `my-axon/log/usage/<date>.jsonl`.

## Wave plan

| Wave | Deliverable                                          |
|------|------------------------------------------------------|
| BW1  | `token-ceiling` field in `_meta.md` (default 32k)    |
| BW2  | Static-prefix lint in `compile-write.py`             |
| BW3  | `usage.py` per-turn logging                          |
| BW4  | `code-dev meta usage` aggregator                     |
| BW5  | Per-program `budget:` block in frontmatter           |
| BW6  | Per-mode caps (R5 integration)                       |
| BW7  | Session-level budget tracker + checkpoint trigger    |
| BW8  | Cache-hit-rate measurement (if API exposes it)        |

## Open questions
- Anthropic's caching API exposes `cache_creation_input_tokens` & `cache_read_input_tokens` — we should log both.
- How to estimate tokens for non-text content (file reads of large code)? — by char/4 approximation; refine with tokenizer.
- Should budget overshoot HALT or just WARN? — start WARN; ratchet to HALT in strict mode.

## Acceptance criteria
- `_meta.md` carries `token-ceiling`.
- All compiled programs have `budget:` block.
- usage.py logs hit rate.
- One pass of cost-per-program emitted.
- `AXON-DOCS-COMPILER.md` documents the framework.

→ consolidated goal tree: `cd-gap-c4-p1-goal-tree.md`.
