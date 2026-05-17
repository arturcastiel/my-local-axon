# L3 — Solution shapes + implications

For each L2 root cause: candidate fix, blast radius, what depends on
it, and which guard must land alongside.

> Status legend per option:
> ✅ recommended · ⚠️ viable but with cost · ❌ rejected (reasoning given)

---

## A · Testing failures — fix shapes

### Fix A-1 · Program-corpus quality sweep (resolves A-RC1, halves A-RC3, fixes most of C-RC1/C-RC2)

**Candidate shapes:**

| Option | What | Blast radius | Verdict |
|---|---|---|---|
| **A-1a** Re-author the 18 failing programs by hand to satisfy the linter | edit ~18 files in `workspace/programs/` | content-only; no tool change | ✅ |
| **A-1b** Tag broken programs `status: draft` in frontmatter and skip them in the linter | extend linter + every broken program gets a frontmatter row | linter logic, ~18 files | ⚠️ pushes defect under the rug |
| **A-1c** Relax linter to make `## OUTPUT` + banner optional | weakens the canonical contract for *every* program | wider semantics change | ❌ erodes the structural guarantee |

**Recommendation:** **A-1a**. Implication: each program file needs a
human-readable OUTPUT block describing what the program returns. This
is also doc work — same `## Guarded by` co-output rule should apply.

**Guard:** add `tools/test.py --all` (or `pytest tests/test_programs_md.py`)
to the pre-push hook **after** the sweep so the next broken program
trips locally, not in CI.

**Implications:**
- `test_programs_md.py` goes 202 → 0 failures.
- `test_compiled_regression.py` goes 71 → 0 once the compiled snapshot
  is regenerated (see C-1).
- `test_tools_kernel.py::test_test_all` goes 1 → 0 (cluster A1
  downstream).
- `test_integration.py::test_section_1a_healthy` `WARN` count drops
  from 83 to ~30 once the EXEC chains resolve.

### Fix A-2 · `tools/test.py` always emits JSON (resolves A-RC2)

**Shape:** wrap `main()` to print `{"valid": false, "issues": [...]}`
even for "workspace looks empty" / "no programs found" / "argparse
error". One ~10-line patch.

**Blast radius:** `tools/test.py` only. Every caller already does
`json.loads(stdout)`.

**Guard:** add `tests/test_tools_test_json_shape.py` (≤ 3 cases) under
the existing axon-tests battery — meta-test on the tool itself.

✅ Recommended.

### Fix A-3 · `test_session::test_recover_active_session` (A-RC3)

**Shape:** trace the divergence. Either:
- Production bug: `tools/session.py` recovery returns wrong key →
  patch tool, keep test. **Likely correct.**
- Test bug: API legitimately changed → update test assertion.

Need a 5-min code dive into `tools/session.py` to decide. Either way
the patch is < 30 LOC.

**Guard:** the existing test already guards once the patch lands.

✅ Recommended (with L3 confirmation pending).

### Fix A-4 · `test_rename_safety::test_diff_identity_is_clean` (A-RC4)

**Shape:** investigate. The identity-program got *legitimate* edits
during axon-3.6.1 (host-harness contract). Snapshot likely needs to
be refreshed. One-line snapshot update probably.

**Blast radius:** `tests/fixtures/...` or wherever the snapshot lives.
Don't update without verifying the diff is genuinely benign.

⚠️ Viable, but **needs a human check on the diff** before the snapshot
is bumped.

### Fix A-5 · `test_plan_dag::test_real_axon_master_dag` (A-RC5)

**Shape:** test bug — change `result["..."]` to
`json.loads(result.stdout)["..."]`. Three-line patch.

✅ Recommended. Test-only.

### Fix A-6 · `test_call_graph::test_cycle_detected` (A-RC6)

**Shape:** check `tools/call_graph.py --help` output schema. If the
`cycles` key is gone, either:
- Restore it (small tool patch) — preferred, since the test name implies
  it's load-bearing.
- Migrate the test to read whatever key replaced it.

✅ Recommended.

### Fix A-7 · CI `--maxfail=1` (A-RC7)

**Shape:** drop the flag in `tests-full`. Let the suite run to
completion. Coverage gate runs after pytest exits non-zero.

**Implication:** CI is **immediately green** for the new battery once
fixes A-1..A-6 land. Until then it stays red but at least surfaces
*all* failures per run rather than just the first.

✅ Recommended — wave 0 of the implementation phase.

---

## B · `requirements.txt` — fix shapes

### Fix B-1 · Replace freeze-output with intent list (resolves B-RC1, B-RC2)

**Candidate shapes:**

| Option | What | Blast radius | Verdict |
|---|---|---|---|
| **B-1a** Hand-curated `requirements.txt` listing only direct imports | 18 packages + a few transitives that are runtime entry-points | drops ~99 lines | ✅ |
| **B-1b** Move all deps to `pyproject.toml [project.optional-dependencies]` with `core`, `dev`, `semantic` groups | semantic move; requires `pip install .[dev]` etc. in CI + SETUP.md | clean separation | ✅ + ⚠️ migration cost |
| **B-1c** Generate `requirements.lock` via `pip-compile` | adds a tool to the workflow | reproducibility + traceability | ⚠️ optional Wave-2 |

**Recommendation:** **B-1a + B-1b combined.** Top of `pyproject.toml`
becomes the source of truth; `requirements.txt` either disappears or
becomes a compatibility shim (`-e .[dev]`).

### Fix B-2 · Decide chromadb's fate (key decision)

**Question:** does any *current* program reference semantic memory?

**Probe needed in implementation:** `grep -r "chromadb\|sentence_transformers" tools/ workspace/ axon/`. Three outcomes:

| Outcome | Action | Saving |
|---|---|---|
| **B-2a** No program touches it → archive `tools/semantic*.py`, drop chromadb. | delete code + drop deps | ~3.7 GB pip cache; ~70 packages drop transitively |
| **B-2b** Exactly one tool uses it (e.g. memory) but no program wires it in → mark `OPTIONAL` in REGISTRY + move to extras | keep code, move deps to `optional-dependencies.semantic` | ~3.0 GB pip cache (user opts in) |
| **B-2c** Active program path goes through it → keep, just trim peripheral deps | trim the long tail, keep chromadb | minor |

**Likely answer (from earlier grep):** B-2a — no direct import found in
any tool or program. Need to confirm in implementation phase.

✅ Recommend B-2a pending one confirmation grep.

### Fix B-3 · Drop telemetry / kubernetes / pydantic / rich / typer (B-RC1 fallout)

Once chromadb goes, `opentelemetry-*`, `kubernetes`, `grpcio`,
`googleapis-common-protos`, `onnxruntime`, `torch`, `transformers`,
`tokenizers`, `safetensors`, `sentence-transformers`, `huggingface_hub`,
`hf-xet`, `triton`, all `nvidia-*` go automatically as transitives.

`rich`, `typer`, `click`, `shellingham`, `pydantic*`, `markdown-it-py`,
`Jinja2`, `MarkupSafe`, `Pygments` — confirm zero imports, then drop.

`uvicorn`, `uvloop`, `httptools`, `httpx`, `httpcore`, `h11`,
`watchfiles`, `websockets`, `websocket-client`, `anyio` — confirm zero
imports, drop. (Likely server experiments.)

**Final intended list (~10–14 packages):**

```
chromadb              # IF B-2c chosen, else gone
ddgs                  # external search
diskcache
jsonschema
numpy
python-docx           # if any tool reads .docx (verify)
requests
requests-oauthlib     # only if oauth flow is live
scikit-learn          # used by ???  verify usage
simpleeval
tiktoken              # used by ???  verify usage
# tests/dev:
pytest>=8
pytest-cov>=5
PyYAML                # if any tool reads .yaml (verify)
```

✅ Recommended after a single verification pass.

**Guard:** new test `tests/test_requirements_intent.py` — assert
that for every package in `requirements.txt`, **either** at least one
file in the repo imports it **or** it's whitelisted with a comment.

---

## C · Usefulness audit — fix shapes

### Fix C-1 · Regenerate / delete `generated/compiled/`

**Shape options:**

| Option | What | Verdict |
|---|---|---|
| **C-1a** Delete `generated/compiled/` and `test_compiled_regression.py` | source becomes the only truth | ⚠️ loses a regression contract |
| **C-1b** Regenerate via `tools/compile_optimizer.py` in CI; commit refresh | continual freshness | ✅ |
| **C-1c** Leave compiled snapshot but mark `test_compiled_regression.py` as `xfail` until corpus sweep done | tactical | ⚠️ short-term only |

**Recommendation:** **C-1b** post A-1. Until then, **C-1c**.

### Fix C-2 · Sweep `Unresolved EXEC` warnings (C-RC1)

For each of the 50 unresolved EXECs:
- If the target was *renamed*: fix the EXEC string in caller.
- If the target was *never authored*: either author a thin stub, or
  delete the EXEC and inline the behaviour, or comment the line out as
  `# planned: ...`.

Estimate: ~50 line-level edits across 12 program files.

✅ Recommended; co-ship with A-1 since both touch `workspace/programs/`.

### Fix C-3 · Register `shell` tool OR sweep callers (C-RC2)

Two paths:

| Option | What | Implication |
|---|---|---|
| **C-3a** Add `shell` to `REGISTRY.json` with a real handler | a new tool surface | needs a smoke test + doc |
| **C-3b** Rewrite all `TOOL(shell, ...)` invocations to use an existing tool (e.g. `bash` if it exists, or `run`) | corpus sweep | ~30 caller edits |

**Need to check:** is there a `tools/shell.py` that just isn't
registered, or does `shell` mean "use a bash one-liner" semantically?

✅ C-3a if file exists; C-3b otherwise.

### Fix C-4 · Behavioural-fixture coverage (C-RC5)

Either:
- Populate the 5 fixture dirs with real `responses.jsonl` for `plan`,
  `study`, `pr-ready`, `resume`, `migrate`. Useful but ~half a day's
  work per program.
- Or delete those parametrise entries until someone needs them.

⚠️ Defer to a follow-up project — not in scope for this cleanup unless
user wants it.

---

## Cross-cutting implications

### CI / hook layer

Once the corpus sweep lands:
- `test-full` job exit code = 0.
- `docgen-strict` already green (axon-tests).
- New: `programs-lint` job runs `tools/test.py --all` explicitly so
  any regression in `workspace/programs/` is caught up front, separate
  from the slower pytest job.
- Pre-push hook gets a third step: `tools/test.py --all` (≤ 2 s).

### Documentation co-output

Every program edited in A-1 / C-2 / C-3 needs its `## Guarded by` row
updated in the relevant AXON-DOCS page (per axon-tests PR-018 rule).

### SETUP.md / CONTRIBUTING.md

If B-1b lands, install instructions change from
`pip install -r requirements.txt` → `pip install -e .[dev]`. Both docs
need updates.

### Risk: cross-project drift

Since the program-corpus sweep is the largest single delta, deviation
log discipline matters — every program reauthored should record
*what shape changed and why* so future authors don't undo it.

---

## Recommended waves (preview; full plan in phase 2)

- **Wave 0** — CI unblock: drop `--maxfail=1`, fix A-5/A-6/A-2 (test
  bugs), regenerate compiled snapshot. ~6 PRs. Test count: 281 → ≈210.
- **Wave 1** — Program corpus sweep: A-1 + C-2 + C-3. Largest wave —
  ~10–15 PRs, one per coherent program group. Test count: 210 → < 5.
- **Wave 2** — Requirements cleanup: B-1 + B-2 + B-3 + guard test.
  3–4 PRs. CI install time drops ≥ 5×.
- **Wave 3** — Optional hardening: C-1b (compile snapshot in CI), C-4
  (behavioural fixtures), behavioural-fixture programme.

After Wave 1, CI green. After Wave 2, repo install is fast and lean.

---

## Hand-off to plan phase

This document + L1 + L2 are the design surface for the `plan` step
of code-dev. **User to review the three files** before we draft PRs.

Open questions for user:

1. **Drop chromadb entirely?** (Wave 2, B-2.) → drives ≥ 70-package
   delta in `requirements.txt`. Answer determines plan size.
2. **B-1a vs B-1b?** (Plain `requirements.txt` vs `pyproject.toml`
   extras.) → cosmetic but changes install instructions.
3. **Wave 2 in this project or split?** → if split, this project ends
   after Wave 1.
4. **Compiled snapshot kept (C-1b) or deleted (C-1a)?** → impacts
   `test_compiled_regression.py` continuity.
5. **Behavioural fixtures (C-4) — populate now or follow-up?**
