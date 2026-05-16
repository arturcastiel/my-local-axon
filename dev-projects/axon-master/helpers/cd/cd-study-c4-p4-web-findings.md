# CD·STUDY·C4·P4 — web findings (evaluation, idempotence, study quality)

> References for the proposed next-studies, with emphasis on NS-1 (evals), NS-2 (idempotence), and NS-3 (plan A/B).

## For NS-1 — Study mode quality measurement (evals)
- **`promptfoo`** — open-source prompt-eval harness.
- **`langfuse`** — evaluation + tracing.
- **`braintrust`** — eval-first prompt-dev.
- **OpenAI evals** repository — patterns for golden-corpus regression.
- **Anthropic "Building evaluations"** docs.
- **EleutherAI lm-evaluation-harness** for academic-rigor evals.
- **HELM (Stanford)** for holistic eval.

**Concrete recipe:** for each study mode, define 10 small sample codebases + expected output structure. Score on:
- recall: did we find what experts find?
- precision: did we hallucinate?
- token efficiency: cost per finding.

## For NS-2 — Idempotence + stability
- **`difflib`** for textual diff scoring.
- **`tree-sitter`** for structural diff (compare AST of two markdown outputs).
- **Anthropic system-prompt caching** to lock-in stable prefixes.
- **OpenAI cache invalidation** patterns.
- **Temperature / top-p settings** for deterministic-leaning outputs.
- **Research on LLM-as-judge** for measuring "semantic equality".

## For NS-3 — Plan-mode A/B vs humans
- **Recsys evaluation methodology** (NDCG, MAP).
- **`pairwise comparison`** evals (Bradley-Terry).
- **`Elo` ranking** for sequential A/B.
- **Anthropic Claude vs Claude** in-context comparisons.

## For NS-5 — `architecture` mode
- **C4 model** (Simon Brown).
- **`Structurizr`** for code-defined diagrams.
- **arc42** template.
- **fitness functions** (Ford et al.).
- **ArchUnit** (JVM), **`archlint`** (Python) for testing architecture.

## For NS-6 — Cross-language coverage
- **`tree-sitter`** parsers for ~40 languages.
- **`semgrep` rule-pack** language support.
- **Per-language idioms** for security, dead-code, naming (must be language-specific).

## For NS-7 — Adaptive budgeting
- **`tiktoken`** for OpenAI tokenization.
- **`anthropic.tokenizers`** for Claude.
- **Repo-size heuristics**: SLOC × file count × tree depth.

## For NS-8 — Plan-quality metrics
- **DORA metrics** (deployment frequency, lead time).
- **`cycle time`** measurement.
- **`PR merged on time`** rates.

## For NS-9 — Recipe DSL
- **`tekton pipelines`** YAML.
- **`ansible playbooks`** YAML.
- **`github actions`** YAML.
- **`makefile`** (simpler).
- Lesson: pick the *least* powerful DSL that fits; markdown with directives may be enough.

## For NS-12 — Failure-mode catalog
- Same references as R4-cd-wf-c4-p3-next-study Study H.
- Specifically: SRE Postmortem Culture, Allspaw "Blameless".

## For NS-13 — pr-ready + staleness tuning
- Internal: usage logs after S5 ships.
- External: GitHub branch-protection rule design.

## For NS-14 — Plan-as-Negotiation
- Research arXiv: "Dialog-based code planning" (recent).
- **Aider** and **Continue.dev** for in-IDE negotiation patterns.

## Cross-references inside our backlog
- R2 cd-c4-p3-improvements top-15.
- R3 cd-tools-p2-umbrella.md.
- R4 cd-wf-c2-p2-ci-cd-integration.md (JSON input plumbing).
- R4 cd-wf-c3-p3-categories.md (knowledge / flow umbrellas).
- R5 this round (study + plan modes).

## End of Round 5

Round 5 produced **16 helpers** across 4 layers:
- L1 — current state, modes taxonomy, prior art, composition.
- L2 — workflows, workflow gaps, plan-side gaps, integration.
- L3 — plan modes detail, study modes detail, implementation roadmap, prior art.
- L4 — synthesis, targets, next-study, web findings.

**Headlines:**
- 14 study modes proposed (overview / subsystem / security / perf / deps / tests / api-surface / data-model / dead-code / naming / observability / error-handling / dataflow / history).
- 10 plan modes proposed (execution / risk-first / budgeted / constrained / multi-dev / replay / cost / alignment / exploratory / dry).
- 7 recipes named (new-repo-onboarding, pre-release-audit, refactor-prep, perf-hunt, quarterly-health, bug-triage, brownfield-dd).
- 6 implementation waves (S0..S6) with explicit acceptance criteria per target.
- `01-study.md` monolith → `study/` folder with `_index.md`.

**Recommended next study:** **NS-1 + NS-2 joint workstream** — evaluation harness + idempotence measurement. Makes everything in R5 measurable.

**Alternative (in parallel):** **R4 Study H** — failure modes / postmortems (already recommended last round, still stands).
