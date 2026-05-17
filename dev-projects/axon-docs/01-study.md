# axon-docs · 01-study

Mode: documentation-only · No new tools, no code changes other than `.md` doc files.

---

## Layer 1 — Inventory (raw counts)

### Programs (228 files)
- `axon/programs/` — 48 (kernel-owned, write-locked unless `L:dev-mode ≡ true`)
- `workspace/programs/` — 180 (user-extensible)
- ACTIVE: 175 · STUB: 53 · QUARANTINED: 0 · HELPER: 5 (_chat-checkpoint, _index, compiled/_index, _code-dev-schema-v4, compiled/_quarantine)
- With compiled artefacts (`.cmp.md`): 199 · without: 29
- Referenced in `workspace/AXON-DOCS-*`: 35 of 228 (**193 programs are not mentioned in any docs page**)

### Tools (75 entries in `tools/REGISTRY.json`)
- ACTIVE: 69 · OPTIONAL: 6 (compile-write, compile-suggest, compile-optimizer, hooks, rtk, shell)
- Categories: kernel · os · documentation · audit · docs · code-dev · host
- **Fully documented** (script + doc card under `axon/tools/*.md` + listed in `axon/tools/REGISTRY.md`): **10 of 75**
  - clock, calculator, tokenizer, diff, validator, notify, kv-store, document-parser, web-search, translate
- 65 tools have no human-facing doc card. Only `REGISTRY.json` + the tool's own `--help` describe them.
- 1 host-dispatched (no Python script): `shell`

### Doc surfaces (47 files, 4 tiers)
- **A — top-level repo docs (12)**: README.md, SETUP.md, CONTRIBUTING.md, CHANGELOG.md, WORKFLOW.md, COPILOT.md, AGENTS.md, CONTEXT.md, startup.md, EXAMPLE.txt, VERSION, .github/copilot-instructions.md
- **B — `axon/` core docs (15)**: KERNEL-SLIM.md, BOOT.md, COMMANDS.md, DEVELOPER.md, HOWTO.md, OUTPUT-LAYER.md, core/LANG.md, core/OUTPUT.md, core/RUN-HEADER.md, core/TRANSLATE.md, compiler/COMPILER.md, compiler/GRAMMAR.md, programs/PROGRAMS.md, programs/PROGRAMS-SLIM.md, tools/REGISTRY.md
- **C — workspace pages (10 + 10 templates)**: AXON-DOCS-{CHEATSHEET, COMPILER, FAILURE-MODES, GOVERNANCE, PLAN, SCHEMA, SESSIONS, STUDY, TESTING, WORKFLOWS}.md + WORKSPACE.md + 9 templates
- 10 `AXON-DOCS-*.md` pages have a `## Guarded by` block (enforced by `docgen-strict` CI job)

### Workflows (15 catalogued in W-01..W-15; ~30 more implicit via code-dev subcommands)
- Boot · menu · mode-router
- code-dev: new · load · study · plan · plan-master · pr (create/ready/review/respond/github/export/drift/list/link/sync/update-spec) · review (scope/self/tests/diff) · safety/freeze/preflight · journal · knowledge · meta (whatif/help/actions/context/cheatsheet/dry-run/examples/board/dispatch-stats/igap/usage) · state (status/next/resume/handoff/metrics/tag/undo/actions)
- axon-audit · axon-docs-gen · compile pipeline
- library-dev (new/ingest/explain/intersect/report/search/cite/status)
- workspace-backup · migrate · harness-builder · discover · deps · glossary · quickstart · health-check · prompt-log/show-memory/stats/status
- Pre-push hook · CI (3 jobs: lint-paths, tests-full, docgen-strict)

### Top-10 most-called programs (by inbound `EXEC()` refs)
menu(22) · code-dev-review(21) · compiler(11) · code-dev-freeze(10) · program(8) · translate(8) · code-dev-X(8) · code-dev-load(8) · code-dev-log(8) · code-dev-tag(7)

---

## Layer 2 — Gap analysis

### G1 — Stale references (concrete bugs in docs)
Multiple top-level docs still mention removed subsystems:
- `README.md` — references `semantic-search`, `requirements.txt` (now a shim)
- `CHANGELOG.md` — `semantic-search`, `requirements.txt`
- `CONTEXT.md` — `semantic-search`, `chromadb`, `sentence-transformers`, `requirements.txt`
- `AXON-DOCS-GOVERNANCE.md` — `semantic-search`, `chromadb`, `sentence-transformers`, `torch`, `requirements.txt`
- `AXON-DOCS-TESTING.md` — `requirements.txt`, references to old `tools/test.py` shape

These post-date the axon-cleanup Wave-2 removal. **Action: scrub all `semantic-search`/`chromadb`/`sentence-transformers`/`torch` mentions and replace `requirements.txt` references with `pyproject.toml`-anchored language.**

### G2 — Undocumented tools (65 of 75)
Only 10 tools have doc cards. Every other tool relies on `--help` and `REGISTRY.json` purpose strings. High-traffic missing cards:
- **kernel-critical**: boot, memory, log, queue, index, checkpoint, process, compile, prefs, enforce, test, run, verify, drift, usage, health, events, simulate, cron, pack, deps, context, prompt-log, pattern, dispatch, axon-audit, test-runner
- **os**: audit_compiled, migrate_meta, rules, redact, scan_pre_push, session, pr_aggregate, rename_snapshot, plan_dag, study_index, budget_lint, cd_cache, board, study_evals, idem_test, pr_sync, pr_drift, pr_export
- **docs/audit**: docgen, docgen_verify, cheatsheet_gen, call_graph, igap, shadow

Two unknown `TOOL()` refs in `workspace/programs/authoring-guide.md`: `my-tool`, `semantic-search` (the latter is a stale demo reference — should be replaced).

### G3 — Undocumented programs (193 of 228)
85 % of programs are not mentioned in any AXON-DOCS-* page. Most self-document via header comments, but there is no per-program reference index. The top-10 most-called programs (menu, code-dev-review, compiler, code-dev-freeze, code-dev-load, translate, …) all lack dedicated doc surfaces.

### G4 — Subject duplication (drift risk)
Same subject described in 3+ places with risk of contradiction:
- **install/setup**: README · SETUP · HOWTO · startup.md · CONTRIBUTING
- **boot/session**: KERNEL-SLIM · BOOT · CONTEXT · startup.md · AXON-DOCS-SESSIONS
- **workflow**: README · WORKFLOW · HOWTO · AXON-DOCS-WORKFLOWS
- **compiler**: axon/compiler/COMPILER · axon/compiler/GRAMMAR · AXON-DOCS-COMPILER · WORKFLOW
- **tests/quality gates**: CONTRIBUTING · AXON-DOCS-TESTING · AXON-DOCS-GOVERNANCE · CHANGELOG
- **governance/deps**: AXON-DOCS-GOVERNANCE · CONTRIBUTING · AGENTS · README
- **output/translation**: KERNEL-SLIM · OUTPUT-LAYER · axon/core/OUTPUT · axon/core/TRANSLATE

Each cluster needs **a single canonical source** with the other pages reduced to short pointer sections.

### G5 — Orphan docs (no internal link in)
33 of 47 docs receive zero inbound `.md` links. Some are entry points (README, startup.md) and OK to be unreachable from within docs. Others should be reachable:
- `axon/BOOT.md` · `axon/COMMANDS.md` · `axon/DEVELOPER.md` · `axon/HOWTO.md` · `axon/OUTPUT-LAYER.md`
- `axon/core/{LANG,OUTPUT,RUN-HEADER,TRANSLATE}.md`
- `axon/compiler/{COMPILER,GRAMMAR}.md`
- `axon/programs/{PROGRAMS,PROGRAMS-SLIM}.md`
- `axon/tools/REGISTRY.md`
- `workspace/AXON-DOCS-{CHEATSHEET, PLAN, STUDY, WORKFLOWS}.md`
- `workspace/WORKSPACE.md`

### G6 — Missing surfaces
- **No "tool reference" index** beyond `axon/tools/REGISTRY.md` (which only lists 10 of 75)
- **No "program reference" index** for the 228 programs (only auto-generated `programs/_index.md` and `compiled/_index.md`)
- **No "developer-mode FAQ"** for the `L:dev-mode` write-gate
- **No CI/coverage-gate doc** — current gate thresholds (`tools/rules/*` 100 %, `tools/*` 80 %) live only in ci.yml comments
- **No subsystem map / architecture diagram** at top level (`README.md` has a repo map but no module/responsibility diagram)
- **No "removed/deprecated tools" page** (semantic-search, optional shims)

### G7 — Tests-of-docs coverage
Only `AXON-DOCS-*` pages enforce `## Guarded by`. The 12 top-level docs (README, etc.) and the 15 `axon/` core docs have no enforcement of link freshness or factual claims. `docgen_verify` only checks the 10 `AXON-DOCS-*` pages.

---

## Layer 3 — Target state

### T1 — Single-source-of-truth (SoT) rules
| Subject              | SoT                                          | Other docs reference it (short pointer + link) |
| -------------------- | -------------------------------------------- | ---------------------------------------------- |
| Identity / kernel    | `axon/KERNEL-SLIM.md`                        | AGENTS, COPILOT, copilot-instructions, README  |
| Boot sequence        | `axon/BOOT.md` (mechanics) + KERNEL-SLIM (rules) | startup.md, README, CONTEXT, AXON-DOCS-SESSIONS |
| Install / setup      | `SETUP.md`                                   | README ("Quick start" — 6 lines max)           |
| Workflow catalogue   | `workspace/AXON-DOCS-WORKFLOWS.md`           | WORKFLOW.md (deep narrative), README           |
| Compile pipeline     | `workspace/AXON-DOCS-COMPILER.md`            | axon/compiler/*, WORKFLOW                      |
| Tests / quality      | `workspace/AXON-DOCS-TESTING.md`             | CONTRIBUTING, AGENTS, README                   |
| Governance / rules   | `workspace/AXON-DOCS-GOVERNANCE.md`          | CONTRIBUTING, AGENTS                           |
| Schema / `_meta.md`  | `workspace/AXON-DOCS-SCHEMA.md` + `templates/v4-schema.md` | WORKFLOW, CHANGELOG          |
| Sessions / recovery  | `workspace/AXON-DOCS-SESSIONS.md`            | CONTEXT, KERNEL-SLIM                           |
| Tool reference       | NEW: `axon/tools/REGISTRY.md` (regenerated)  | per-tool doc cards under `axon/tools/<tool>.md`|
| Program reference    | NEW: `axon/programs/PROGRAMS-INDEX.md`       | AXON-DOCS-WORKFLOWS                            |
| CI / coverage        | NEW: `workspace/AXON-DOCS-CI.md`             | CONTRIBUTING, AXON-DOCS-TESTING                |
| Persona / agent      | `AGENTS.md`                                  | COPILOT, .github/copilot-instructions          |

### T2 — New doc surfaces required
1. **`axon/tools/REGISTRY.md`** — regenerate from `REGISTRY.json` so all 75 entries are listed with one-line purpose + category + "see also" pointer to doc card if any. (Update existing file, do not create new.)
2. **Per-tool doc cards** `axon/tools/<tool>.md` for the high-traffic tools (boot, memory, log, queue, compile, verify, drift, usage, health, events, dispatch, axon-audit, docgen, session, rules, scan_pre_push, budget_lint, shadow, igap, prompt-log, study_index, cd_cache, plan_dag, board) — 24 new cards. Lower-priority tools deferred.
3. **`axon/programs/PROGRAMS-INDEX.md`** — auto-generatable later, hand-authored now: groups the 228 programs by area (boot, code-dev, library-dev, axon-master, meta, state, knowledge, journal, ...).
4. **`workspace/AXON-DOCS-CI.md`** — documents the 3 CI jobs, coverage gates, pre-push hook, what to do when CI fails. Add a `## Guarded by` block citing `.github/workflows/ci.yml` + `tests/test_install_hooks.py`.
5. **`workspace/AXON-DOCS-DEPRECATIONS.md`** — log of removed subsystems (semantic-search, chromadb, sentence-transformers, torch) with rationale and replacement path. Stops stale references reappearing.
6. **`workspace/AXON-DOCS-ARCHITECTURE.md`** — top-level subsystem map (kernel · compiler · programs · workspace · my-axon · tools) with a Mermaid diagram. One-page.

### T3 — Updates to existing docs (no new files)
- **README.md** — remove `semantic-search` mentions; reduce "Quick start" to 6 lines; replace `requirements.txt` references with `pip install -e ".[dev]"`; add a "Where to read more" navigation block.
- **CHANGELOG.md** — append a "3.6.1 → 3.7-pre" section reflecting axon-cleanup waves 0–3 + grooming; scrub `semantic-search` reference lines or mark them as deprecated.
- **CONTEXT.md** — full rewrite around current state: drop `chromadb`/`sentence-transformers`/`torch`; update "11 REGISTERED TOOLS" to "75 tools, 10 fully documented".
- **WORKFLOW.md** — light pass; cross-link to the AXON-DOCS-* SoT pages instead of restating.
- **HOWTO.md** — update `ADDING A TOOL` section to current `REGISTRY.json` pattern; cross-link to per-tool doc card template.
- **DEVELOPER.md** — confirm dev-mode mechanics match `axon/KERNEL-SLIM.md` (already does, just verify).
- **AGENTS.md / COPILOT.md / `.github/copilot-instructions.md`** — confirm identity gate references stay consistent; add a one-line pointer to AXON-DOCS-CI.md.
- **AXON-DOCS-TESTING.md** — refresh test count from 1929 → 2880+; refresh pre-push hook step list (smoke → tools/test.py --all → scan_pre_push) to match current `scripts/install-hooks.sh`; replace `requirements.txt` → `pyproject.toml`.
- **AXON-DOCS-GOVERNANCE.md** — drop `chromadb`/`sentence-transformers`/`torch` from the Dependencies row; replace with the 12-dep current set; cross-link to AXON-DOCS-DEPRECATIONS.
- **AXON-DOCS-WORKFLOWS.md** — extend W-01..W-15 catalogue with implicit workflows (code-dev review family, journal, knowledge, meta, state).
- **AXON-DOCS-CHEATSHEET.md** — confirm AUTO-VERBS block matches current `tools/cheatsheet_gen.py` output.
- **axon/tools/REGISTRY.md** — regen as above.
- **workspace/templates/axon-docs-page.md** — add a "Stale references" check-row to the template.

### T4 — Navigation map
Add a "Read in this order" section to README.md:
1. `README.md` — repo overview (this file)
2. `SETUP.md` — install
3. `axon/HOWTO.md` — first workflow
4. `WORKFLOW.md` — full workflow narrative
5. `workspace/AXON-DOCS-*.md` — authoritative subject pages
6. `axon/KERNEL-SLIM.md` — kernel contract (read before editing `axon/`)
7. `CONTRIBUTING.md` — for contributors

### T5 — Enforcement extensions (no new tools, only re-aiming existing ones)
- Extend `tools/docgen_verify.py --strict` invocation to also verify that A-tier docs (README, CONTRIBUTING, AGENTS, CHANGELOG) do NOT mention the deprecation list (semantic-search, chromadb, sentence-transformers, torch). Test sits in `tests/test_no_stale_subsystems.py` (new test, but no new tool; uses existing grep-as-test pattern).
- Note: this is the only test-touching item. If user wants strict "no new files at all", it can be folded into existing `tests/test_requirements_intent.py`.

---

## Open questions for user (before drafting plan)

1. **Scope of "no new tools or code modifications"** — does that include test files? T5 above is the only borderline case. **Default assumption: test additions are OK if they enforce doc correctness.**
2. **Doc-card density** — write a card for every tool (75), or just the high-traffic ones (~24)? **Default: 24 high-traffic now, defer rest.**
3. **Per-program reference** — exhaustive (228 entries) or grouped (by area only)? **Default: grouped + hand-authored top-30, full list auto-generatable later.**
4. **Dev-mode** — should `axon/` writes (regenerated REGISTRY.md, new per-tool doc cards under `axon/tools/`, new `axon/programs/PROGRAMS-INDEX.md`) require explicit dev-mode toggle for each, or one toggle for the whole documentation phase?

---

## Decisions (resolved 2026-05-17)

1. **Test files in scope?** ✓ Yes — test additions are permitted when they enforce doc correctness (T5 is in).
2. **Doc-card density?** ✓ 24 high-traffic tools now; remaining ~51 deferred to a later phase.
3. **Per-program reference?** ✓ Grouped by area + hand-authored top-30; full 228-entry list deferred (auto-generatable later).
4. **Dev-mode scope?** ✓ One phase-wide toggle for the documentation phase — not per-write. Toggle on at start of phase 3-implement, off at phase 4 close.

Study phase complete.

## Next phase

→ `02-plan.md` — translate T1–T5 into per-PR plan, sized by area (top-level docs, axon/ docs, AXON-DOCS-* refresh, new pages, per-tool cards). HALT on `docs-plan-review` for user check before any writes.
