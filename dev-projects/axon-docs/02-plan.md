# axon-docs — Phase 2 PLAN

**Created:** 2026-05-17
**Phase:** 2-plan
**Source:** translates `01-study.md` Layer 3 (T1–T5) into per-PR specs.
**Constraint:** documentation-only — NO new tools, NO program-corpus edits.
Test additions allowed only when they enforce doc correctness (T5).
**Dev-mode:** one phase-wide toggle, flipped ON at start of phase 3-implement,
flipped OFF at phase 4 close. Programs never substitute owner intent for the toggle.
**HALT gate:** `docs-plan-review` — user must accept this file before any writes.

---

## Cadence & ground rules

- **Single-PR cadence** — one PR open at a time, sequential merge.
- **Co-output rule (carried from axon-tests)** — every PR ships:
  1. The doc change(s).
  2. The `## Guarded by` block, listing the test(s) or doc(s) that pin it.
  3. A `04-log.md` entry (round/PR/files-touched/deviations).
- **Agent never runs builds, tests, or `git push`.** Implementation complete → "ready for you to build and test."
- **`axon/` writes** require `L:dev-mode ≡ true`. PR-A1..A3 are gated.
- **Schema:** every new AXON-DOCS-* page uses `workspace/templates/axon-docs-page.md`.

---

## PR catalogue

15 PRs in 5 sections. `Depends-on` lines drive merge order.
"Touches axon/" = requires dev-mode for the merge window.

### Section S — Top-level docs (T3)

| PR     | Title                                         | Files touched                                                                                                | Depends on | dev-mode |
| ------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ---------- | -------- |
| PR-S01 | README refresh                                | `README.md`                                                                                                  | –          | no       |
| PR-S02 | CHANGELOG + CONTEXT refresh                   | `CHANGELOG.md`, `CONTEXT.md`                                                                                 | PR-S01     | no       |
| PR-S03 | WORKFLOW + HOWTO cross-link pass              | `WORKFLOW.md`, `axon/HOWTO.md`                                                                               | PR-S01     | axon/    |
| PR-S04 | Persona alignment pass (no rewrite)           | `AGENTS.md`, `COPILOT.md`, `.github/copilot-instructions.md`                                                 | PR-S01     | no       |
| PR-S05 | DEVELOPER + SETUP confirm-pass                | `axon/DEVELOPER.md`, `SETUP.md`                                                                              | PR-S01     | axon/    |

**Scope notes**
- PR-S01: trim Quick-Start to ≤6 lines · scrub `semantic-search` mentions · replace `requirements.txt` → `pip install -e ".[dev]"` · add "Read in this order" nav block (T4) · add CI + tests-mandatory + coverage badges (echoes PR-021).
- PR-S02: append `3.6.1 → 3.7-pre` section to CHANGELOG (axon-cleanup waves 0–3 + grooming) · scrub deprecated subsystem refs · CONTEXT.md full rewrite around current state, update tool count to "75 tools, 10 fully documented".
- PR-S03: cross-link WORKFLOW → AXON-DOCS-WORKFLOWS instead of restating · update HOWTO "ADDING A TOOL" to current `REGISTRY.json` pattern.
- PR-S04: one-line pointer to AXON-DOCS-CI · confirm identity-gate references match KERNEL-SLIM.
- PR-S05: confirm dev-mode mechanics match KERNEL-SLIM § write-gate · refresh SETUP install instructions.

### Section D — AXON-DOCS-* refresh (T3)

| PR     | Title                                              | Files touched                                       | Depends on  | dev-mode |
| ------ | -------------------------------------------------- | --------------------------------------------------- | ----------- | -------- |
| PR-D01 | AXON-DOCS-TESTING refresh (counts + hooks + deps)  | `workspace/AXON-DOCS-TESTING.md`                    | PR-S02      | no       |
| PR-D02 | AXON-DOCS-GOVERNANCE: dependency list refresh      | `workspace/AXON-DOCS-GOVERNANCE.md`                 | PR-N02      | no       |
| PR-D03 | AXON-DOCS-WORKFLOWS: catalogue extension (W-01..W-15 + implicit) | `workspace/AXON-DOCS-WORKFLOWS.md`     | PR-S03      | no       |
| PR-D04 | AXON-DOCS-CHEATSHEET reconcile vs `cheatsheet_gen` | `workspace/AXON-DOCS-CHEATSHEET.md`                 | –           | no       |

**Scope notes**
- PR-D01: test count 1929 → 2880+ · pre-push hook step list (smoke → tools/test.py --all → scan_pre_push) per current `scripts/install-hooks.sh` · `requirements.txt` → `pyproject.toml`.
- PR-D02: drop `chromadb`/`sentence-transformers`/`torch` from Dependencies row · replace with 12-dep current set · cross-link to AXON-DOCS-DEPRECATIONS (depends on PR-N02 existing).
- PR-D03: extend the catalogue to cover the implicit workflows (code-dev review family, journal, knowledge, meta, state).
- PR-D04: re-run `cheatsheet_gen` mentally and reconcile AUTO-VERBS block.

### Section N — New doc surfaces (T2)

| PR     | Title                                        | Files touched                                       | Depends on | dev-mode |
| ------ | -------------------------------------------- | --------------------------------------------------- | ---------- | -------- |
| PR-N01 | NEW `AXON-DOCS-CI.md`                        | `workspace/AXON-DOCS-CI.md`                         | –          | no       |
| PR-N02 | NEW `AXON-DOCS-DEPRECATIONS.md`              | `workspace/AXON-DOCS-DEPRECATIONS.md`               | –          | no       |
| PR-N03 | NEW `AXON-DOCS-ARCHITECTURE.md` (one-page)   | `workspace/AXON-DOCS-ARCHITECTURE.md`               | –          | no       |

**Scope notes**
- PR-N01: documents the 3 CI jobs (`lint-paths`, `tests-full`, `docgen-strict`), coverage gates (`tools/rules/*` 100 %, `tools/*` 80 %), pre-push hook, "what to do when CI fails" runbook · `## Guarded by` cites `.github/workflows/ci.yml` + `tests/test_install_hooks.py`.
- PR-N02: log of removed subsystems (semantic-search, chromadb, sentence-transformers, torch) — rationale, replacement path, "if you see this in a doc, file a bug" pointer.
- PR-N03: subsystem map (kernel · compiler · programs · workspace · my-axon · tools) with Mermaid diagram. One page max.

### Section A — `axon/` tree (T2 — dev-mode gated)

| PR     | Title                                                                  | Files touched                                                                                                  | Depends on  | dev-mode  |
| ------ | ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ----------- | --------- |
| PR-A1  | Regenerate `axon/tools/REGISTRY.md` from `REGISTRY.json`               | `axon/tools/REGISTRY.md`                                                                                       | –           | axon/     |
| PR-A2  | 24 per-tool doc cards (high-traffic tools only)                        | `axon/tools/<tool>.md` × 24 *new* (boot, memory, log, queue, compile, verify, drift, usage, health, events, dispatch, axon-audit, docgen, session, rules, scan_pre_push, budget_lint, shadow, igap, prompt-log, study_index, cd_cache, plan_dag, board) | PR-A1       | axon/     |
| PR-A3  | NEW `axon/programs/PROGRAMS-INDEX.md` (grouped + top-30 hand-authored) | `axon/programs/PROGRAMS-INDEX.md`                                                                              | –           | axon/     |

**Scope notes**
- PR-A1: regen lists all 75 entries with one-line purpose + category + "see also" pointer to doc card if any. Update existing file, do not create new.
- PR-A2: 24 cards per `templates/axon-tool-card.md` (to be added under PR-A2 itself if missing — that template lives under `workspace/templates/`, so non-gated; if it's missing, PR-A2 ships it as a sub-change). Lower-priority 51 tools deferred to a follow-up project.
- PR-A3: groups all 228 programs by area (boot, code-dev, library-dev, axon-master, meta, state, knowledge, journal, …); top-30 hand-authored with description; full list auto-generatable later.

### Section T — Enforcement extensions (T5)

| PR     | Title                                                                      | Files touched                                                                              | Depends on            | dev-mode |
| ------ | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | --------------------- | -------- |
| PR-T01 | `docgen_verify --strict` deprecation guard + supporting test               | `tools/docgen_verify.py` (extend), `tests/test_no_stale_subsystems.py` (new)               | PR-N02, PR-S01, PR-S02 | no       |

**Scope notes**
- PR-T01: extend `docgen_verify.py --strict` to assert A-tier docs (README, CONTRIBUTING, AGENTS, CHANGELOG) contain none of the deprecation list (semantic-search, chromadb, sentence-transformers, torch). New test `tests/test_no_stale_subsystems.py` codifies the rule. Single test-touching item in the whole plan (per decision Q1).

---

## DAG (merge order)

```
PR-S01 ─┬─► PR-S02 ─► PR-D01 ───────────────┐
        ├─► PR-S03 ─► PR-D03                 │
        ├─► PR-S04                           │
        └─► PR-S05                           │
                                             │
PR-N01 ──────────────────────────────────────┤
PR-N02 ──────────────► PR-D02 ───────────────┤
PR-N03 ──────────────────────────────────────┤
PR-D04 ──────────────────────────────────────┤
PR-A1  ─► PR-A2                              │
PR-A3                                        │
                                             ▼
                                          PR-T01  (closes phase 3)
```

15 PRs · acyclic ✓.
Recommended merge order: PR-S01, PR-N01, PR-N02, PR-N03, PR-S02, PR-D01, PR-S03, PR-S04, PR-S05, PR-D02, PR-D03, PR-D04, PR-A1, PR-A2, PR-A3, PR-T01.

---

## Risks

- **R1 — Tool count drift.** `REGISTRY.json` is the SoT; any tool added between phases will silently invalidate PR-A1 and PR-A2 counts. Mitigation: regenerate at start of phase 3 if `REGISTRY.json` mtime > phase-start.
- **R2 — Test count drift.** 2880+ figure in PR-D01 may move. Mitigation: read live `pytest --collect-only -q | tail -1` once at phase 3 start; cite that number with date.
- **R3 — `axon/` write gate.** PR-A1..A3 + PR-S03 + PR-S05 require dev-mode. If toggle gets flipped off mid-phase (e.g. by `boot reload`), surface and re-toggle. Phase-wide doesn't mean immune to external reset.
- **R4 — Cheatsheet generator dependency (PR-D04).** If `cheatsheet_gen.py` has changed since the last cheatsheet, the AUTO-VERBS block may need a manual reconciliation pass.
- **R5 — Mermaid rendering (PR-N03).** Markdown renderer support for Mermaid is not guaranteed; ship the diagram and an ASCII fallback in the same page.

---

## Outputs / deliverables

- 12 doc files edited (top-level + AXON-DOCS-* refresh)
- 4 new doc files created (AXON-DOCS-CI, -DEPRECATIONS, -ARCHITECTURE, PROGRAMS-INDEX)
- 1 doc file regenerated (axon/tools/REGISTRY.md)
- 24 new per-tool doc cards (axon/tools/<tool>.md)
- 1 tool extension (docgen_verify --strict)
- 1 new test file (tests/test_no_stale_subsystems.py)
- 1 `04-log.md` round entry per PR

---

## HALT — `docs-plan-review`

Phase 3-implement is blocked until the user:

1. Accepts this plan (or returns deltas).
2. Confirms phase-wide dev-mode is OK to flip ON for the duration of phase 3.
3. Confirms PR cadence: single-PR, sequential merge.

→ Next phase: `03-implement` — work through the merge order above, one PR per round, logging each in `04-log.md`.
