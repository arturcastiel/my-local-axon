# Final findings — axon-cleanup study

Read these three files in order, then answer the 5 questions at the
end:

1. `01-layer-1-surface.md` — what's broken / bloated / orphaned. Raw
   numbers.
2. `02-layer-2-root-causes.md` — why each item is the way it is +
   who depends on what.
3. `03-layer-3-solutions.md` — concrete fix shapes with blast radius
   and implication for each.

---

## Executive summary (1-page TL;DR)

**Testing — 281 failures, 9 distinct modes.**
- 273 of them are *one underlying issue*: 18 program files in
  `workspace/programs/` violate the structural linter that
  `tools/test.py` enforces. (`test_programs_md.py` runs that linter
  per file; `test_compiled_regression.py` runs it on the compiled
  copies; `test_tools_kernel::test_test_all` aggregates the count.)
- 5 are isolated test/tool bugs (test_session, test_rename_safety,
  test_plan_dag, test_call_graph, test_integration).
- 2 are `tools/test.py` emitting empty stdout on a synthetic workspace.
- 1 systemic: CI runs with `--maxfail=1` so it stops at the first fail
  and the coverage gate never executes.

**Requirements — 117 packages, ~3.8 GB cache, 18 used.**
- Only 18 packages have a direct `import` anywhere in the repo.
- The remaining 99 are either (a) unused, (b) transitives of `chromadb`,
  `torch`, `transformers` (the dormant semantic-memory experiment), or
  (c) transitives of a web-server experiment that no program touches.
- Dropping `chromadb` alone cascades-out ≥ 70 packages (CUDA / torch /
  HF / opentelemetry / kubernetes / grpc).

**Usefulness — 199 programs, ~10 % failing the linter, 83 audit warns.**
- `Unresolved EXEC` warnings (50) point at programs that never got
  authored or got renamed/deleted without sweeping callers.
- `Unknown TOOL('shell')` warnings (30) — programs call a `shell` tool
  that isn't in the registry. Likely needs either registration or a
  rewrite to an existing tool.
- `generated/compiled/programs/` is a stale snapshot that doubles
  every program-corpus failure.

---

## Recommended waves (preview)

| Wave | Fixes | PR count | Goal |
|---|---|---:|---|
| **0 — CI unblock** | drop `--maxfail=1`; fix `test_plan_dag`, `test_call_graph`, `test_session`, `test_rename_safety` snapshot bump; `tools/test.py` always-JSON | 5–6 | CI runs to completion |
| **1 — Corpus sweep** | author OUTPUT/banner/DONE() for 18 programs; resolve 50 EXEC chains; resolve 30 `shell` tool refs; regenerate compiled snapshot | 10–15 | program-md tests green |
| **2 — Requirements cleanup** | drop chromadb stack; rewrite `requirements.txt` (or `pyproject.toml` extras); guard test against re-introduction | 3–4 | CI install ≥ 5× faster |
| **3 — Optional hardening** | compiled snapshot regen in CI; behavioural fixtures; deeper audit-warn cleanup | TBD | nice-to-haves |

> Numbers exclude time/date estimates per the plan-mode rule.

---

## Open questions for user (block plan-phase until answered)

1. **chromadb / semantic memory:** drop entirely, move to optional
   extra, or keep? *(Recommend: drop — no callers found, biggest win.)*

2. **Dep declaration style:** keep `requirements.txt` (B-1a) or move to
   `pyproject.toml [project.optional-dependencies]` (B-1b)?
   *(Recommend: B-1b — separates dev from runtime.)*

3. **Scope of this project:** end after Wave 1 (corpus green) and
   spin Wave 2 (deps) as a separate project? Or include both?
   *(Recommend: one project, separate waves — keeps deviation log
   coherent.)*

4. **Compiled snapshot in `generated/compiled/`:** keep it and
   regenerate in CI, or delete it and drop `test_compiled_regression.py`?
   *(Recommend: keep + CI regenerate — it's a real second-layer
   regression guard.)*

5. **Behavioural fixtures** (`tests/fixtures/programs/{plan,study,…}`):
   populate now or defer to a follow-up project?
   *(Recommend: defer.)*

---

## What is NOT in this study (so we don't slip)

- **Refactoring of working code.** Anything in `tools/` that has
  callers and passes tests is out of scope.
- **Kernel rule changes.** `axon/KERNEL-SLIM.md` is untouched; this
  project only writes to `workspace/`, `tools/`, `tests/`,
  `requirements.txt`, `pyproject.toml`, CI files, top-level docs.
- **Adding new tools.** Same constraint as axon-tests — extend
  existing, no new tool scripts.
- **Performance work on `tools/test.py`.** It's slow but correct;
  performance is its own project.

---

Once the user reviews and answers Qs 1–5, we move to phase `2-plan`
and draft per-wave PR specs in `02-plan.md` + `03-prs/PR-NNN.md` exactly
the way axon-tests did.
