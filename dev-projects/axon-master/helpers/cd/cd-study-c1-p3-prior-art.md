# CD·STUDY·C1·P3 — prior art (industrial code-study tooling)

> What mature systems do for codebase comprehension. Each row maps to a study mode.

## Tool-to-mode mapping

| Industrial tool    | What it does                          | Our mode it informs       |
|--------------------|---------------------------------------|---------------------------|
| Sourcegraph        | Code intelligence, symbol search      | `overview`, `dataflow`    |
| Glean (Meta)       | Indexed semantic queries              | `overview`, `subsystem`   |
| tree-sitter        | Syntax-aware parsing                  | `subsystem`, `naming`     |
| Semgrep            | Pattern-based static rules            | `security`, `naming`      |
| CodeQL             | Semantic queries over code            | `security`, `dataflow`    |
| Snyk / Dependabot  | Dependency vulnerabilities            | `dependencies`            |
| OWASP ZAP / Bandit | Security scanners (dynamic / static)  | `security`                |
| py-spy, async-profiler | Sampling profilers                | `performance`             |
| flame graphs       | Stack visualization                   | `performance`             |
| coverage.py / lcov | Coverage instrumentation              | `tests`                   |
| go-callvis, pycg   | Call-graph generators                 | `subsystem`, `dataflow`   |
| `git-quick-stats`  | Repo churn / hotspot                  | `history`                 |
| `git log --since`  | Time-windowed history                 | `history`                 |
| ts-prune, vulture  | Dead-export / dead-code detectors     | `dead-code`               |
| Stylelint, ruff    | Lint surface                          | `naming` (partial)        |
| OpenAPI extractors | API surface mapping                   | `api-surface`             |
| Alembic, Liquibase | Migration introspection               | `data-model`              |
| OpenTelemetry      | Tracing instrumentation               | `observability`           |

## Workflow patterns from prior art

### Pattern A — "Scan everything, summarize per file" (Sourcegraph)
- Build symbol index across repo.
- Surface symbols by query.
- Mapping: our `overview` mode should emit a per-file *one-liner* with main symbols.

### Pattern B — "Pattern-based rules" (Semgrep, CodeQL)
- Author rules in DSL → run over codebase → produce findings.
- Mapping: our `security` and `naming` modes should support a *rule pack* directory (`workspace/study-rules/`).

### Pattern C — "Coverage on PR" (codecov)
- Read coverage JSON → compute delta vs baseline.
- Mapping: our `tests` mode reads `coverage.json` (HUMAN runs pytest --cov first).

### Pattern D — "Hotspot from churn × complexity" (Adam Tornhill, *Your Code as a Crime Scene*)
- Combine git-log churn with file complexity → identify risk-prone files.
- Mapping: our `history` mode should multiply churn × LOC and flag top-N.

### Pattern E — "Dependency BOM" (CycloneDX, SPDX)
- Emit a Software Bill of Materials.
- Mapping: our `dependencies` mode emits a markdown BOM.

### Pattern F — "Architecture decision audit" (ADR + cog. complexity)
- Walk ADRs; cross-reference against actual code; find drift.
- Mapping: NEW mode `architecture` (post-MVP).

### Pattern G — "What changed since v?" (release notes generators)
- Diff two commits, classify changes.
- Mapping: our `--diff --since` flag.

### Pattern H — "Trace a value through code" (CodeQL data-flow queries)
- Source→sink dataflow.
- Mapping: our `dataflow --from --to` mode.

### Pattern I — "Owner mapping" (CODEOWNERS + git log)
- Compute who-owns-what by commit count per file.
- Mapping: our `history` mode subset.

### Pattern J — "Code climate / radon" (complexity metrics)
- Cyclomatic complexity, maintainability index.
- Mapping: enrichment for `subsystem` and `history` modes.

## What we should NOT replicate

- Real-time IDE indexing (out of scope; VS Code does it).
- Auto-fixing (mode = read-only).
- Build/test execution (HUMAN's job).
- Network calls (kernel rule).

## Constraint: programs are LLM-driven markdown

Most prior-art tools are deterministic binaries. Our study modes are **LLM-driven prompts** with structured outputs. Implications:

- Token budget per mode is a *hard* limit; can't process gigabytes.
- Determinism is bounded (LLM stochasticity); freeze settings (temperature, model) in mode header.
- Outputs are markdown; downstream programs parse via fixed section headers.

## Bridge pattern: external tool + mode

```
HUMAN runs:    pytest --cov --cov-report=json
HUMAN runs:    coverage json -o coverage.json
HUMAN feeds:   code-dev knowledge study --mode=tests --input coverage.json
```

The mode reads the JSON (deterministic) and composes the markdown report (LLM-aided). HUMAN still owns execution.

→ how to compose modes into workflows: `cd-study-c1-p4-mode-composition.md`.
