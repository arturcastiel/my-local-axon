# CD·GAP·C1·P4 — external references for gap closure

> Pointers per undercovered topic (U-1..U-12). Each entry is a search lead, not a citation.

## For U-1 — Compiled-program audit
- `tools/compile.py`, `tools/compile_optimizer.py`, `tools/compile_suggest.py`, `tools/compile-write.py` (existing; baseline).
- `tools/compile.py` registry: `workspace/programs/compiled/*.cmp.md`.
- prior art: webpack/rollup size-limit, esbuild metafile; tiktoken/anthropic tokenizers for measurement.

## For U-2 — Schema migrator
- Alembic (SQLAlchemy) migrations.
- Django migration history model.
- Rust `serde-with` versioned variants.
- Prior art on idempotent file migrators: pre-commit, `tag` rewrites.
- AXON: `axon/programs/_chat-checkpoint.md`, schema doc `workspace/programs/_code-dev-schema-v4.md`.

## For U-3 — Test surface for code-dev programs
- `promptfoo`, `langfuse`, `braintrust`, OpenAI evals — eval frameworks.
- `chainforge` — visual prompt eval.
- DSPy program-level tests.
- Anthropic "Building evaluations" docs.
- AXON: `tests/test_programs_md.py`, `tests/test_compiled_regression.py`, `tools/test_runner.py` (existing).

## For U-4 — Failure-mode catalog
- Google SRE "Postmortem Culture".
- Allspaw "Blameless".
- Etsy debriefing facilitation.
- AWS PER template.
- AXON internal: `igap.py`, `workspace/log/entries/*`, operational-safety memory.

## For U-5 — Governance composition
- Policy-as-code: OPA / Rego conflict resolution.
- Linux capabilities precedence model.
- Kubernetes admission controllers (ordered, last-wins vs first-wins).
- Prior art on overlapping CSP rules.

## For U-6 — Session / chat / handoff
- LangChain memory primitives (`ConversationSummaryMemory`).
- Anthropic system-prompt caching docs.
- Continue.dev / Cursor checkpointing.
- AXON: `axon/programs/_chat-checkpoint.md`, `axon/programs/chat-folder.md`, `axon/programs/list-chats.md`, `my-axon/chats/`.

## For U-7 — Documentation strategy
- Divio's documentation system (tutorial / how-to / reference / explanation).
- Diátaxis framework (latest evolution of Divio's model).
- `mdBook`, `MkDocs`, `Docusaurus` IA patterns.
- AXON: `axon/COMMANDS.md`, `axon/HOWTO.md`, `workspace/AXON-DOCS.md`, `workspace/OBJECTIVE-FUNCTION-INTERFACE.md`.

## For U-8 — Cost / budgeting framework
- Tiktoken / anthropic.tokenizers.
- Anthropic prompt-cache pricing.
- Cost-of-Delay (Reinertsen).
- Per-step budgets in LangChain / DSPy.
- AXON: `tools/tokenizer.py`, `tools/usage.py`, `tools/benchmark.py`.

## For U-9 — Architecture-drift detection
- C4 model + Structurizr.
- ArchUnit, archlint, dependency-cruiser.
- Fitness functions (Ford et al.).

## For U-10 — Library-dev parallel
- AXON: `workspace/programs/library-dev*.md` (internal scan needed).

## For U-11 — Backup hardening
- git-crypt, git-secret.
- BFG repo-cleaner.
- Gitleaks pre-push hooks.
- AXON: `my-axon/memory/local/myaxon-backup-*.md`, `tools/session_save.py`.

## For U-12 — Dispatch quality measurement
- BEIR benchmark for IR.
- TF-IDF + BM25 eval methodology.
- `pytrec_eval`.
- AXON: `tools/dispatch.py`, `tools/dispatch_stats.py`.

## Cross-topic
- Diátaxis documentation framework (drives U-7).
- Prompt-cache discipline (drives U-1, U-8).
- SRE postmortems (drives U-4, U-6 via compaction incidents).
- Diátaxis + recipe DSL → AXON-DOCS family layout.

→ deep-dive L2 begins with `cd-gap-c2-p1-compiled-audit.md`.
