# CD·GAP·C2·P3 — test surface for code-dev programs (U-3 / R4-K)

> Programs are markdown. How do we regression-test them? This designs the surface before Round-3 W4 (file renames) goes live.

## What exists today

- `tests/test_programs_md.py` — checks frontmatter & section presence per program.
- `tests/test_compiled_regression.py` — compares compiled output stability.
- `tools/test_runner.py` — invokes tests.
- No semantic test of program *behavior* (i.e. "given this state, code-dev X should produce that").

## What's missing

| Test type                                  | Status today        |
|--------------------------------------------|---------------------|
| YAML/header validity                       | partial via existing tests |
| Required sections (`HELP`, `STEPS`)        | partial             |
| Dispatch `# desc:` quality                 | absent              |
| End-to-end "given fixture, run program, check output" | absent   |
| Per-mode golden output (R5 study modes)    | absent              |
| Determinism / idempotence (R5 target)      | absent              |
| Token-budget compliance                    | absent              |
| Cross-program contract checks (router → child) | absent          |
| Rename safety (Round-3 W4)                  | absent              |

## Test taxonomy (proposed)

### T1 — Structural tests (already partial)
- Every program has frontmatter with `# PROGRAM:`, `# desc:`.
- Every program has `## STEPS` or `## HELP` (depending on type).
- No dangling cross-references (broken `EXEC(code-dev-...)`).
- All referenced programs exist.

### T2 — Dispatch quality tests
- A golden corpus: 50 user prompts → expected verb.
- `tools/dispatch.py` runs over corpus; precision/recall measured.
- Threshold: ≥ 0.8 P@1, ≥ 0.95 P@3.
- New corpus entries on every PR (drift gate).

### T3 — Behavioral tests (program-as-prompt)
- Per program: at least one `tests/fixtures/<prog>/<case>.input.md` + `<case>.expected.md`.
- Test runner sets up fixture, invokes program in a sandbox project, compares output.
- Comparison: structural (sections present) + content (key facts) + budget (tokens within cap).

### T4 — Golden outputs for study modes
- Per study mode: 1-3 sample codebases (synthetic, small).
- Run mode against sample; compare to expected sections.
- LLM stochasticity tolerance: structural match strict, content match fuzzy (e.g., ≥ 70% sentence overlap).

### T5 — Idempotence tests (R5 NS-2)
- Run program twice; diff outputs.
- Target ≥ 80% identical (allow timestamps, ordering).
- Output to `_trace/<prog>-idem.json`.

### T6 — Token-budget tests
- Run program with synthetic worst-case input.
- Assert output token count ≤ declared budget.
- Assert HALT-with-partial behavior when input forces overflow.

### T7 — Cross-program contract tests
- Routers forward correctly (Round-3 W1).
- Stubs print deprecation + delegate correctly (R3 W2).
- Schema migrator + schema readers contract.

### T8 — Rename safety tests (Round-3 W4)
- Pre-rename snapshot of every program's `# desc:`.
- Post-rename: deprecation stubs respond; new names dispatch.
- Diff snapshots.

## Test infrastructure

### Fixtures layout
```
tests/
├── fixtures/
│   ├── projects/
│   │   ├── tiny-py-cli/        # small Python CLI codebase
│   │   ├── tiny-ts-lib/        # small TS library
│   │   └── tiny-empty/         # empty codebase
│   ├── dispatch-corpus.jsonl
│   └── programs/<name>/
│       ├── case-1.input.md
│       └── case-1.expected.md
```

### Sandbox project
- Each behavioral test creates a temp `my-axon/dev-projects/test-<n>/` via fixture copy.
- Test runs program against it; tears down on exit.
- No mutation of real project state.

### LLM mocking
- Programs that call into the model are mocked via a frozen-response harness (`tests/_mock_model.py`).
- Real-LLM tests run nightly (slower lane).
- Mock tests run on every PR.

## Wave plan

| Wave | Deliverable                                              |
|------|----------------------------------------------------------|
| TW1  | T1 structural — already partial; finish coverage          |
| TW2  | T2 dispatch corpus + harness                             |
| TW3  | T6 token budget — wired into compile-write gate          |
| TW4  | T3 behavioral — start with 5 critical programs           |
| TW5  | T7 cross-program contracts (routers + stubs)             |
| TW6  | T5 idempotence — measurement + ratchet                    |
| TW7  | T8 rename-safety harness — ships *before* R3 W4           |
| TW8  | T4 study-mode golden outputs (post R5 mode rollout)      |

## Critical-path subset for R3-W4

To unblock the file-rename wave safely:
- TW1 (full structural).
- TW2 (dispatch golden corpus).
- TW7 (rename snapshot diff).

Without these three, R3-W4 is high-risk.

## Acceptance criteria

- Each test type runs in `tools/test_runner.py`.
- CI-equivalent: HUMAN can run `pytest tests/ --md-tests` and see green.
- Test inventory dashboard via `code-dev meta tests` (new sub-cmd, optional).
- Per-program coverage tracked in `tests/coverage.json`.

## Open questions
- Where does the dispatch-quality corpus live? Probably `tests/fixtures/dispatch-corpus.jsonl`. Versioned with the code.
- Who curates the corpus? HUMAN initially; later semi-automated from `prompt_log.py` (real usage).
- How to handle LLM upgrades (model changes break determinism)? Tag corpus entries with model expected; allow drift report.

→ failure-mode catalog: `cd-gap-c2-p4-failure-modes.md`.
