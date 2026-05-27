# L1 — Surface inventory

Pure enumeration. Numbers verified with `pytest`, `pip`, and `grep` on
`main` at HEAD = `7262694` (axon-tests merged).

---

## A · Testing — failure landscape

Full suite: **1642 passed · 281 failed · 6 skipped** (10 min run).

### A1 · Failures clustered by file

| Count | File | Symptom (one example) |
|------:|------|-----------------------|
| 202 | `tests/test_programs_md.py` | `Missing ## OUTPUT section`, `Missing ▶ banner`, `DONE({program-name}) does not match PROGRAM:` |
| 71 | `tests/test_compiled_regression.py` | same symptoms — operates on compiled copies of the same programs |
| 2 | `tests/test_budget_lint.py` | `JSONDecodeError` — `tools/test.py` emits empty stdout on synthetic tmp_path |
| 1 | `tests/test_tools_kernel.py::test_test_all` | `assert '18_FAILED' == 'ALL_PASS'` — aggregate counter from cluster A |
| 1 | `tests/test_session.py::test_recover_active_session` | recovery returns wrong shape |
| 1 | `tests/test_rename_safety.py::test_diff_identity_is_clean` | identity diff non-clean |
| 1 | `tests/test_plan_dag.py::test_real_axon_master_dag` | `TypeError: 'CompletedProcess' object is not subscriptable` |
| 1 | `tests/test_integration.py::test_section_1a_healthy` | axon-audit returns `WARN` not `OK` (83 warns) |
| 1 | `tests/test_call_graph.py::test_cycle_detected` | `KeyError: 'cycles'` — tool output schema drift |

**Total: 9 distinct failure modes across 281 cases.**

### A2 · CI surface

`.github/workflows/ci.yml` job `tests-full` invokes
`pytest tests/ -v --maxfail=1 --durations=20 --cov ...`.
`--maxfail=1` means CI aborts at the first failure (currently
`test_budget_lint.py::test_missing_block_detected`) so it stays red as
long as **any** of the 281 cases fail. Coverage gate never runs.

### A3 · Failure provenance (which were broken before axon-tests?)

Of the 281, all 281 pre-date axon-tests:

- Cluster A1 (273) — `test_programs_md.py` + `test_compiled_regression.py`
  are pre-existing.
- Cluster B (2) — `test_budget_lint.py` is pre-existing.
- Cluster C (6) — `test_tools_kernel`, `test_session`, `test_rename_safety`,
  `test_plan_dag`, `test_integration`, `test_call_graph` — pre-existing.

No new failures came from the axon-tests battery itself (259/259 pass).

---

## B · `requirements.txt` — bloat inventory

`requirements.txt` lists **117 pinned packages**. Pip cache after
`pip install -r requirements.txt` measures **3.8 GB**.

### B1 · Direct-import audit

Top-level `import X` / `from X import …` grep across `tools/`,
`tests/`, `axon.py`, `scripts/`:

| Status | Count | Packages |
|---|---|---|
| **Directly imported** | **18** | `chromadb`, `ddgs`, `diskcache`, `importlib_metadata`, `importlib_resources`, `jsonschema`, `jsonschema-specifications`, `numpy`, `python-docx`, `pytest`, `pytest-cov`, `requests`, `requests-oauthlib`, `scikit-learn`, `simpleeval`, `tiktoken`, `typing-inspection`, `typing_extensions` |
| **No direct import** | **99** | (full list in §B2) |

Spot-check refines this slightly: `yaml`, `pydantic`, `rich`, `typer`,
`torch`, `transformers`, `sentence_transformers` — **zero** matches in
the repo. They are pure transitive deps or dead weight.

### B2 · Categories of the 99 unused-by-name packages

| Bucket | Packages | Probable origin |
|---|---|---|
| **CUDA toolchain** (12) | `cuda-bindings`, `cuda-pathfinder`, `cuda-toolkit`, `nvidia-cublas`, `nvidia-cuda-cupti`, `nvidia-cuda-nvrtc`, `nvidia-cuda-runtime`, `nvidia-cudnn-cu13`, `nvidia-cufft`, `nvidia-cufile`, `nvidia-curand`, `nvidia-cusolver`, `nvidia-cusparse`, `nvidia-cusparselt-cu13`, `nvidia-nccl-cu13`, `nvidia-nvjitlink`, `nvidia-nvshmem-cu13`, `nvidia-nvtx`, `triton` | ML experiments (`torch` cu13 wheel pulled them all) |
| **Torch / HF / ONNX stack** (~10) | `torch`, `transformers`, `tokenizers`, `safetensors`, `sentence-transformers`, `huggingface_hub`, `hf-xet`, `onnxruntime`, `mpmath`, `sympy` | semantic search / embeddings prototype |
| **Web-server stack** (~9) | `uvicorn`, `uvloop`, `httptools`, `httpx`, `httpcore`, `h11`, `watchfiles`, `websockets`, `websocket-client`, `anyio` | server experiments (not used by any CLI) |
| **Telemetry** (6) | `opentelemetry-api`, `opentelemetry-exporter-otlp-proto-common`, `opentelemetry-exporter-otlp-proto-grpc`, `opentelemetry-proto`, `opentelemetry-sdk`, `opentelemetry-semantic-conventions` | chromadb transitive — would auto-remove if chromadb goes |
| **Cloud-native** (4) | `kubernetes`, `oauthlib`, `googleapis-common-protos`, `grpcio` | chromadb transitive |
| **Markdown/CLI/UI** (~8) | `rich`, `Pygments`, `typer`, `click`, `shellingham`, `markdown-it-py`, `mdurl`, `Jinja2`, `MarkupSafe` | no code uses any of them |
| **Pydantic + friends** (5) | `pydantic`, `pydantic-settings`, `pydantic_core`, `annotated-types`, `annotated-doc`, `typing-inspection` | no code uses pydantic |
| **Truly trivial transitives** (rest) | `attrs`, `certifi`, `charset-normalizer`, `idna`, `urllib3`, `packaging`, `six`, `setuptools`, `zipp`, `tenacity`, `filelock`, `fsspec`, `tqdm`, `joblib`, `threadpoolctl`, `regex`, `lxml`, `mmh3`, `protobuf`, `flatbuffers`, `pybase64`, `orjson`, `pyproject_hooks`, `build`, `python-dateutil`, `python-dotenv`, `referencing`, `rpds-py`, `scipy`, `bcrypt`, `durationpy`, `overrides`, `primp`, `PyPika`, `PyYAML` | mix of `requests`/`scikit-learn`/`chromadb` transitives + dead weight |

### B3 · CI install cost

`pip install -r requirements.txt` in CI: downloads ~3 GB, takes ~3–5
min before pytest even starts.

---

## C · Usefulness audit — surface

### C1 · Tools

`tools/REGISTRY.json` declares **70 ACTIVE + 5 OPTIONAL = 75** tool
scripts. All 70 exist on disk (axon-audit OK).

- Some scripts are imported by other tools (e.g. `_axon_paths.py`,
  `_axon_lib.py`, `_run.py`) — internal helpers.
- `tools/test.py` exists; `tools/turn_log.py` does **not** (caught by
  the axon-tests project; replaced with `tools/log.py`).

### C2 · Programs

`workspace/programs/*.md` — **199 files** (per axon-audit).
Structural linter (`tools/test.py`) reports **18 fail / 181 pass**.

Failure modes among the 18 (and overlap into the 202 test_programs_md
parametrised cases — these include compiled copies too):

| Defect class | Approx count |
|---|---:|
| Missing `## OUTPUT` section | ~10 |
| Missing `▶` banner inside OUTPUT | ~6 |
| Unfilled `DONE({program-name})` placeholder | ~3 |
| Missing priority flag (`!NORM` / `!CRIT` etc.) | ~2 |
| Missing `DONE()` call entirely | ~1 |

### C3 · Cross-program EXEC integrity

axon-audit `internal_refs` reports **83 WARN entries**:

- ~50 `Unresolved EXEC('workspace/programs/code-dev-*.md')` —
  EXEC pointing at programs that don't exist (typos? renames? deletes
  without sweep?).
- ~30 `Unknown TOOL('shell')` — programs invoke a `shell` tool that
  isn't in `REGISTRY.json`.
- A handful of `Unknown TOOL('code-dev-meta-igap')`, `Unresolved
  EXEC('workspace-backup:push')` etc.

### C4 · Tests

`tests/` directory after axon-tests merge: **48 test files** spanning
1929 collected cases. Skipped behavioural fixtures (5) are *intentionally*
empty placeholders awaiting real fixture data.

### C5 · Docs

`workspace/AXON-DOCS-*.md` — 10 pages, all now carry a `## Guarded by`
table (axon-tests PR-021).

### C6 · Disk / repo size

```
.git/         (unmeasured)
my-axon/      private, gitignored
generated/    .copilotignored runtime artefacts
workspace/    1 MB of markdown
axon/         <500 KB of markdown
tools/        ~3500 LOC python
tests/        ~6000 LOC python (post axon-tests)
```

---

## Next layer

L2 — for each L1 item, ask *why* and *who depends on it*.
