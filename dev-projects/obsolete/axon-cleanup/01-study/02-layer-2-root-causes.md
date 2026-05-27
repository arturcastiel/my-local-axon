# L2 — Root causes + dependency edges

For each L1 item: *why is it like this?* and *who depends on it?*

---

## A · Testing-failure root causes

### A-RC1 · Program-corpus drift (273 / 281 failures)

**Root:** the structural linter `tools/test.py` enforces a contract
(must have `## OUTPUT`, `▶` banner, `DONE(<prog>)`, priority flag) that
was tightened *after* most `workspace/programs/code-dev-*.md` and
`workspace/programs/library-dev-*.md` were authored. The corpus and
the linter disagree.

**Evidence:** `authoring-guide.md` has literal `DONE({program-name})`
placeholder text — template artefact never replaced. `code-dev-audit.md`
is missing OUTPUT entirely. `auto-improve.md` missing OUTPUT. The 199
program files split ~90 % conformant / 10 % not.

**Edges:**
- `test_programs_md.py` parametrises over every `workspace/programs/*.md`
  → fails 202 times (multiplier: 2 layers × 199 programs ≈ 398 cases).
- `test_compiled_regression.py` runs the same linter on the compiled
  copy under `generated/compiled/programs/` → fails 71 times.
- `test_tools_kernel.py::test_test_all` calls `tools/test.py --all`
  which counts the 18 failing programs and asserts `'ALL_PASS'`.
- `test_integration.py::test_section_1a_healthy` calls axon-audit
  which surfaces the same `Unresolved EXEC` warnings → 83 WARNs.

**Why it persists:** there's no CI gate today — `tests-full` aborts at
the first failure (`--maxfail=1`) so the program-quality regressions
were invisible. Authors wrote new programs without running the linter.

### A-RC2 · `test_budget_lint` JSONDecode (2 failures)

**Root:** `tools/test.py` writes nothing to stdout when called on a
synthetic tmp_path that lacks `workspace/programs/`. Test expects JSON
and calls `json.loads("")`.

**Fix scope:** either ensure `tools/test.py` always emits valid JSON
(`{"valid": false, "issues": [...]}`) or have the test build a complete
minimal workspace.

**Edges:** only `test_budget_lint.py` calls `tools/test.py` against an
isolated tmp_path; production callers always pass a real workspace.

### A-RC3 · `test_session::test_recover_active_session` (1 failure)

**Root:** session-recovery return tuple shape drifted. Test does
`assert recovered and is_active is False` — value of `is_active` flipped
or recovery dict missing the key.

**Edges:** isolated to `tools/session.py` + this single test.

### A-RC4 · `test_rename_safety::test_diff_identity_is_clean` (1 failure)

**Root:** rename-safety diff returns non-clean for the identity case
(no-op rename). Likely identity gate program (`axon/programs/identity.md`)
got edited and now its diff is non-trivial against the snapshot.

**Edges:** isolated; touches `tools/rename_safety.py` + identity.md
snapshot.

### A-RC5 · `test_plan_dag::test_real_axon_master_dag` (1 failure)

**Root:** test does `result["..."]` on a `subprocess.CompletedProcess`
object. The tool was refactored to return JSON via stdout; the test
still treats the returned object as a dict. **Test bug**, not a
production bug.

**Edges:** isolated to this one test.

### A-RC6 · `test_call_graph::test_cycle_detected` (1 failure)

**Root:** `tools/call_graph.py` output schema renamed/removed `cycles`
key. Test references `result["cycles"]`. Either restore the key or
update the test to read the new key.

**Edges:** `tools/call_graph.py` + this test only.

### A-RC7 · `--maxfail=1` in CI

**Root:** CI was tuned in early development when the suite was small
and a single fail was always the new fail. With 1929 cases and a
known-buggy program corpus, this prevents the rest of the gate
(including the new coverage check) from running. **My fault — PR-001
inherited that flag.**

**Edges:** `.github/workflows/ci.yml` only.

---

## B · `requirements.txt` root causes

### B-RC1 · ML / embedding experiments left behind

**Root:** at some point AXON experimented with semantic memory backed
by `sentence-transformers` + `chromadb`. The experiment lives somewhere
in `tools/` (likely `tools/memory.py` or `tools/semantic_*.py`) but
none of it is actively used in any program file today (`grep` shows
zero imports for `torch`, `transformers`, `sentence_transformers` in
the current repo).

**Evidence:** the only direct import of `chromadb` is also a stub —
need L3 to confirm whether it's reachable from any active program.

**Edges:** `chromadb` is the keystone — drop it and the entire CUDA /
torch / opentelemetry / kubernetes / grpc / onnxruntime chain
becomes garbage-collectable.

### B-RC2 · `requirements.txt` is a frozen pip-freeze, not a curated list

**Root:** the file looks like the output of `pip freeze` after a
one-shot install on a dev box. Every transitive dep is pinned (e.g.
`certifi==2026.4.22`, `idna==3.13`). Maintenance cost is high —
pin updates land for packages we don't even use.

**Fix shape:** split into:
- `requirements.txt` — top-level *intent* (≈18 packages, looser pins).
- `requirements.lock` (optional) — `pip-compile`-style hash-locked
  resolution for reproducibility.

### B-RC3 · No declared install profile

**Root:** there's no signal which packages are runtime vs dev vs
optional. `pytest` and `pytest-cov` are mixed with `chromadb`.

**Fix shape:** in `pyproject.toml` declare `[project.optional-dependencies]`
groups: `dev`, `semantic` (chromadb stack, if kept), `tests`.

---

## C · Usefulness audit — root causes

### C-RC1 · 50× `Unresolved EXEC('workspace/programs/code-dev-*.md')`

**Root:** `workspace/programs/code-dev-flow.md`,
`code-dev-knowledge.md`, `code-dev-state.md` etc. invoke sibling
programs that don't exist — `code-dev-cascade.md`, `code-dev-changelog.md`,
`code-dev-finalize.md`, `code-dev-merge.md`, `code-dev-plan.md`,
`code-dev-test-map.md`, etc.

Either (a) those programs were planned but never authored, or (b) they
existed and got renamed/deleted without sweeping the callers.

**Edges:** breaks at runtime when a user invokes any of the parent
"router" programs.

### C-RC2 · 30× `Unknown TOOL('shell')`

**Root:** many programs `TOOL(shell, cmd=...)` but `shell` is not in
`REGISTRY.json`. Either it should be (genuine missing entry) or it's a
deprecated invocation pattern that should be rewritten to `TOOL(bash)`
or `TOOL(run)`.

**Edges:** every program with a CI-touching step (review, preflight,
PR-ready) is affected.

### C-RC3 · Compiled snapshot in `generated/`

**Root:** `generated/compiled/programs/` mirrors the source corpus and
is shipped into the repo. `test_compiled_regression.py` lints the
compiled copy. When source is broken, the compiled copy is broken
twice — and the compile step likely never re-ran since the most recent
authoring.

**Fix shape:** either delete the compiled snapshot (and the test) or
regenerate it as part of CI.

### C-RC4 · `tools/turn_log.py` missing

**Root:** referenced in older docs / programs but the file was never
shipped (or was renamed to `tools/log.py`). Caught by axon-tests
PR-017 — already patched there.

### C-RC5 · Behavioural test fixtures empty

**Root:** `tests/test_behavior.py` parametrises over 5 fixture
directories under `tests/fixtures/programs/{plan,study,pr-ready,
resume,migrate}/` — they exist but contain no `responses.jsonl` /
`expected.md`. SKIP semantics keep CI green; reality is none of the
mock-model behavioural cases actually run.

**Edges:** any future contract change to those 5 programs goes
uncaught.

---

## Dependency summary

```
A-RC1 (program corpus)  →  A-RC2, A-RC3, A-RC4 secondary failures
                       →  C-RC1 (unresolved EXEC) overlaps strongly
                       →  C-RC2 (unknown TOOL shell) overlaps strongly
                       →  C-RC3 (compiled snapshot is downstream)

B-RC1 (chromadb)        →  ~70 of 99 unused packages
B-RC2 (frozen pin file) →  maintenance cost only
B-RC3 (no profiles)     →  cosmetic but blocks B-RC2 fix

A-RC7 (--maxfail=1)     →  blocks all gates running today
```

The single highest-leverage fix is **A-RC1 + C-RC1 + C-RC2 together** —
they describe one underlying problem: *the program corpus needs a
quality sweep against its own linter.*

The second highest-leverage fix is **B-RC1 + B-RC3** — *drop the
embedding experiment and rewrite `requirements.txt` as intent + dev
profile.*

---

## Next layer

L3 — concrete fix shapes, implications, and what each change cascades.
