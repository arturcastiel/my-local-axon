# CD·WF·C4·P4 — web findings (workflow research seeds for next round)

> Pointers for whichever next-study is chosen. Each entry is a search lead, not a direct citation.

## For Study H — failure modes / postmortems
- Google SRE Book: "Postmortem Culture: Learning from Failure" (free chapter).
- AWS post-event review (PER) template (public on AWS blog).
- John Allspaw "Blameless PostMortems and a Just Culture".
- Etsy's debriefing facilitation guide.
- ChatGPT/Claude prompt-injection incident reports (HiddenLayer, Pillar reports).

## For Study K — testing program-as-prompt
- `promptfoo` (npm) — prompt regression testing.
- `langfuse` evaluation harness.
- `chainforge` for visual prompt-eval.
- Anthropic "Building evaluations" docs.
- DSPy programmatic prompt tests.

## For Study D — dispatch quality measurement
- BEIR benchmark for IR.
- TF-IDF + bm25 evaluations (sklearn `feature_extraction.text` + `pytrec_eval`).
- "Routing-aware LLM CLI" papers (limited; search recent NeurIPS/arXiv).
- gh `--help` rendering / fuzzy matchers (fzf, peco).

## For Study C — compiled-program ROI
- LLM context-cache documentation (Anthropic prompt caching; OpenAI cached prompts).
- Token-counting libraries: `tiktoken`, `anthropic.tokenizers`.
- Static prefix discipline blog posts (Anthropic engineering).

## For Study M — compile-write regression gate
- pre-commit framework patterns.
- `pytest-benchmark` for performance gates.
- GitHub Actions size-limit action (frontend prior art).
- `gha-size-limit` config patterns.

## For Study A — library-dev harmonization
- Internal scan: `workspace/programs/library-dev*.md`.
- Compare against `code-dev*.md`.
- Look for shared verbs (any?).

## For Study B — schema migrators
- Django migrations.
- Alembic for SQLAlchemy.
- liquibase patterns.
- Rust serde-with versioned variants.
- The general "tag your version, write upgrader" pattern.

## For Study I — backup hardening
- git-crypt, git-secret for encrypted-in-repo secrets.
- BFG repo-cleaner.
- gitleaks pre-push hook.
- "monorepo backup strategy" articles.

## For Study E — token economics
- Anthropic billing docs.
- `tiktoken` for OpenAI.
- LangSmith / langfuse token-tracing.
- Run a baseline measurement now (cost ~0).

## For Study F — knowledge subsystem
- Code intelligence: tree-sitter, ast-grep, Glean (Facebook).
- LSP for IDE-grade symbol info.
- Sourcegraph's batch-changes (workflow over code-graph).

## For Study G — multi-project ergonomics
- VS Code multi-root workspaces.
- `tmux` session manager.
- `direnv` / `mise` for context switching.
- `gh repo set-default` flow.

## For Study J — team mode
- Aviator MergeQueue docs.
- Graphite team flow docs.
- Github CODEOWNERS spec.

## For Study L — prompt-engineering as a sub-mode
- Lilian Weng's "Prompt Engineering" overview.
- DSPy "Programming, not prompting".
- Anthropic "Long context" docs.
- OpenAI prompt-engineering guide.

## For Study N — AXON observability
- OpenTelemetry markdown / JSONL trace format.
- jaegertracing examples.
- `langsmith` LLM tracing.
- AXON's existing `LOG` ops as a starting point.

## Common references applicable to multiple
- "Command Line Interface Guidelines" (clig.dev).
- Heroku CLI Style Guide.
- "The Pragmatic Programmer" (workflow chapters).
- `awesome-clis` GitHub list for inspiration.

## Action item if next-study = H
Walk through:
1. `igap.py` outputs from 2026-05-15 incident.
2. `workspace/log/entries/2026-05-15.md`.
3. axon-master `_meta.md` schema mismatch traces.
4. Any `LOG(ERROR|WARN|CRITICAL)` entries from the last 30 days under `workspace/log/`.

Compose a postmortem template at `workspace/templates/postmortem.md` based on findings.

---

## End of Round 4

Round 4 produced **16 helpers** across 4 layers:
- L1 (canonical-flows, entry-points, cookbook, web-findings)
- L2 (industrial-gaps, ci-cd-integration, team-collab-gaps, web-findings)
- L3 (name-collisions, rename-proposal, categories, web-findings)
- L4 (synthesis, roadmap, next-study, web-findings)

**Headline:** Round-3 (umbrella) + Round-4 (workflow) compose into one coherent reorganization plan that closes 14 of 22 identified gaps and resolves all top-15 name collisions.

**Recommended next study:** **Study H — Failure modes / postmortem patterns** (see `cd-wf-c4-p3-next-study.md` for full slate of 14 candidates).
