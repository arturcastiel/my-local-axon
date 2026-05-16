# CD·GAP·C2·P1 — compiled-program audit (U-1)

> Deepens R2's spot-finding (pr-review.cmp.md at -1%) into a full plan to measure every compiled program and ship a regression gate.

## What exists today

- Programs live at `workspace/programs/code-dev*.md` (~57 source files).
- Compiled artifacts at `workspace/programs/compiled/<prog>.cmp.md` (10 known per `01-study.md`).
- `tools/compile.py` produces them; `tools/compile-write.py` writes; `tools/compile_optimizer.py` + `compile_suggest.py` advise.
- `tools/benchmark.py` exists for measurement.

## What's measured today
- ONE program: `code-dev-pr-review.cmp.md` at **22856 B source → 23056 B compiled** = **-1%** (negative).
- That measurement is in `cd-c3-p1-tokens.md`.

## What's NOT measured
- Compression ratio for the OTHER 9 compiled programs.
- Token count (vs raw byte count) — bytes ≠ tokens for LLM cost.
- Per-section breakdown of where bloat lives (header, examples, narrative, code blocks).
- Whether prompt-cache static-prefix discipline is honored (does the prefix change across runs?).

## Audit plan (deliverable: numbers table)

### Step 1 — Enumerate compiled set
```
find workspace/programs/compiled -name '*.cmp.md' -type f -print0 | xargs -0 -I{} basename {} .cmp.md
```

### Step 2 — For each program, capture:
- source bytes
- source tokens (tiktoken or anthropic tokenizer)
- compiled bytes
- compiled tokens
- compression % (bytes)
- compression % (tokens)
- static-prefix hash (first 2 KB or first N tokens)
- last-modified delta (source vs compiled)

### Step 3 — Emit `study/compiled-audit.md`
```
| program           | src B | src T | cmp B | cmp T | ratio B | ratio T | stable prefix? |
|-------------------|-------|-------|-------|-------|---------|---------|----------------|
| code-dev-pr       |       |       |       |       |         |         |                |
| code-dev-pr-review|       |       |       |       |         |         |                |
| ...               |       |       |       |       |         |         |                |
```

### Step 4 — Classify each program
- **GREEN** — ratio < 60% bytes AND < 70% tokens.
- **YELLOW** — between thresholds.
- **RED** — ratio > 95% OR negative → quarantine.
- **GREY** — stable prefix < 90% across two recompiles → cache-hostile.

### Step 5 — Decisions
- All RED: quarantine via `disabled: true` field in compiled manifest until reworked.
- All YELLOW: keep but flagged in benchmark-log.
- All GREEN: continue using.
- All GREY: re-emit with static-prefix discipline (see `axon/core/RUN-HEADER.md`).

## Regression gate (T-A3 from R2)

Implementation outline for `tools/compile-write.py`:
```
def write_compiled(prog: str, content: str) -> None:
    src = read(source_for(prog))
    if len(content) > 0.95 * len(src):
        raise CompileWriteError(f"{prog}: compiled too large ({len(content)}/{len(src)})")
    if token_count(content) > 0.95 * token_count(src):
        raise CompileWriteError(f"{prog}: token bloat")
    # static-prefix check
    prior = read_prior_compiled(prog)
    if prior and prefix_drift(prior, content) > 0.10:
        LOG(WARN, f"{prog}: prefix drift > 10%")
    write(...)
```

Threshold knobs default to 0.95 bytes and 0.95 tokens; lower over time as we tighten.

## What we expect to find (informed predictions)

Likely RED candidates (programs touched many times, large source):
- `code-dev-pr-review` — confirmed RED.
- `code-dev-pr` (creation flow) — large; deserves recheck.
- `code-dev-pr-respond` — narrative-heavy.
- `code-dev-plan-master` — plan composition reasoning is wordy.
- `code-dev-study` — overview generator, also wordy.
- `code-dev-tour` — tutorial-flavored; likely YELLOW.

Likely GREEN:
- Short routers if/when they exist (Round-3 W1).
- `code-dev-next`, `code-dev-status`, `code-dev-tag` — small surfaces.

## Output artifacts (this audit produces)

1. `my-axon/dev-projects/axon-master/study/compiled-audit.md` — numbers table + classification.
2. `tools/compile-write.py` updated with gate.
3. `tests/test_compiled_regression.py` extended with audit assertions.

## Risks
- **Token counts depend on tokenizer choice** — pick once (anthropic for AXON's deployment) and freeze.
- **Stochasticity** — same compile may yield slightly different output. Measure 3x; report median.
- **Race with R3 router rollout** — must agree which compiled set is "ours" mid-migration.

## Acceptance criteria
- All 10 (or current count) compiled programs measured.
- Numbers table committed.
- Gate active in `compile-write.py`.
- At least 1 RED quarantined (pr-review confirmed; others discovered).
- benchmark-log records initial baseline.

→ schema migrator deep dive: `cd-gap-c2-p2-schema-migrator.md`.
