# CD·STUDY·C3·P4 — web findings (codebase study tooling)

> External references for each proposed study mode.

## For `overview` and `subsystem`
- **Sourcegraph** docs on "code intel" and indexing.
- **Glean** (Meta) overview + open-source release notes.
- **Codebase summarization with LLMs** — papers on hierarchical chunking.
- **`tree-sitter`** grammars for parsing.
- **`ast-grep`** for AST-level rule matching.

## For `security`
- **OWASP Top 10** (current revision).
- **Semgrep registry** rules for common Python / JS / Go.
- **CodeQL examples** (taint tracking).
- **Bandit** (Python), **gosec** (Go), **brakeman** (Rails) — class of tools.
- **Anthropic / OpenAI guidance** on AI-assisted security review limitations.

## For `performance`
- **Brendan Gregg's performance methodologies** (USE method).
- **py-spy**, **async-profiler**, **`perf record`** — for HUMAN-runnable profilers.
- **N+1 query detection** patterns (Django, SQLAlchemy, ActiveRecord).
- **flame graphs** for visualization (HUMAN side).

## For `dependencies`
- **CycloneDX**, **SPDX** SBOM formats.
- **Snyk**, **Dependabot**, **Renovate** — class of tools.
- **OSV.dev** open-source vulnerability database.
- **`pip-audit`**, **`npm audit`**, **`cargo audit`** — HUMAN-runnable feeders.

## For `tests`
- **`coverage.py`** JSON output spec.
- **`pytest-cov`** options.
- **`jest --coverage`** report shape.
- **lcov** format.
- **`hypothesis`** / property-based testing patterns.

## For `api-surface`
- **`griffe`** (Python) — public API extraction.
- **`api-extractor`** (TypeScript).
- **`cargo-public-api`** (Rust).
- **`pkg-diff`** / **`tomato`** for API diffing.
- **Semantic Versioning** spec for the verdict logic.

## For `data-model`
- **`alembic`** revision history.
- **`pgdiff`** / **`schema diff`** tools.
- **`pydantic`** model introspection.
- **OpenAPI** spec inspectors.

## For `dead-code`
- **`vulture`** (Python).
- **`ts-prune`** / **`knip`** (TypeScript).
- **`rust-analyzer` dead-code lint**.
- **Class of `unimport`-style** tools.

## For `naming`
- **`flake8-naming`** / **`pep8-naming`**.
- **eslint naming-convention** plugins.
- **`semantic-naming`** research (less mature; LLM-friendly).
- **Spell-checkers**: `cspell`, `typos`.

## For `observability`
- **OpenTelemetry** instrumentation guides.
- **Honeycomb** "wide events" doctrine.
- **`structlog`**, **`zap`**, **`tracing-rs`** — language-level libraries.
- **Sampling and cardinality** anti-patterns.

## For `error-handling`
- **`failure`**, **`anyhow`**, **`Result`** patterns (Rust).
- **`returns`** library (Python).
- **Erlang-style supervision** for inspiration.
- **`circuit-breaker`** libraries (`pybreaker`, `resilience4j`).

## For `dataflow`
- **CodeQL data-flow queries** (literature).
- **`pysa`** (Facebook).
- **`SonarQube` taint analysis**.
- **LLM-augmented data-flow** (recent arXiv).

## For `history`
- **Adam Tornhill** — *Your Code as a Crime Scene*, *Software Design X-Rays*.
- **`code-maat`**, **`hercules`** — open-source repo-mining tools.
- **`git-quick-stats`** for fast aggregations.

## For `architecture` (post-MVP)
- **C4 model** (Simon Brown).
- **arc42** template.
- **Structurizr** for code-defined diagrams.
- **fitness functions** (Ford et al., *Building Evolutionary Architectures*).

## For plan modes
- **`linear`** prioritization heuristics.
- **MoSCoW** (Must / Should / Could / Won't).
- **Cost of Delay** prioritization (Reinertsen, *Principles of Product Development Flow*).
- **WSJF** (SAFe framework, despite the org-process baggage the formula is useful).
- **OKR alignment** practices.

## For recipes / playbooks
- **`runbooks`** practice (PagerDuty, GitHub Engineering Handbook).
- **`ansible playbooks`** — composition language inspiration.
- **`tekton pipelines`** — declarative steps.

## Internal references in our backlog
- Round-2 cd-c4-p3-improvements.md → top-15 baseline.
- Round-3 cd-tools-p2-umbrella.md → verb routing.
- Round-4 cd-wf-c2-p2-ci-cd-integration.md → input JSON plumbing.
- Round-4 cd-wf-c3-p3-categories.md → `knowledge` umbrella defines this verb home.

→ synthesis & targets: `cd-study-c4-p1-synthesis.md`.
