# CD·PLAN·I2·A — audit (iteration 2)

> Audit plan v1 with the I2·S changes applied. Same lens as I1·A but tighter.

## Sanity checks (post-I2 changes)

| Check                                                       | Pass |
|-------------------------------------------------------------|:----:|
| All 7 W1 PRs map to ≥1 P0 goal                              | ✔    |
| No PR depends on a later-wave PR                            | ✔    |
| MUST set is self-sufficient (W2 can start with only MUST)   | ✔    |
| Migrator does NOT modify compiled programs without gate     | ✔ (gate ships first) |
| T1 tests run BEFORE migrator edits resume                    | ✔    |
| Empty rules file is non-fatal                                | ✔    |
| Redact has allowlist                                         | ✔    |
| Cheatsheet acknowledges bitrot risk                          | ✔    |
| Gate has floor for tiny programs                             | ✔    |

## Token-cost sanity for plan execution
- 7 PRs × ~2-4 chat turns per PR ≈ 20-30 turns to ship W1.
- Each turn ~5-25 KB context (per U-8 estimate).
- W1 fits in a single session if focused; otherwise handoff at PR-4'.

## Cross-reference with R5 NS targets
- NS-1 (evals) maps to wave-2 PR-13 (usage logging) + wave-3 (dispatch corpus).
- NS-2 (idempotence) maps to wave-3 (idempotence test).
- Both are queued; deferred until token framework is real (W2).

## Cross-reference with R4 roadmap
- R4 roadmap had 11 releases. Cross-walking:
  - R4-R1 (umbrella) → W2 PR-14 (router stubs, partial) + W4 (renames).
  - R4-R2 (test surface) → W1 PR-1' (T1) + W2 (TW2, deferred to W3).
  - R4-R3 (governance) → W1 PR-4' + W2.
  - R4-R4 (sessions) → W2 PR-9.
  - R4-R5 (cost) → W2 PR-13.
  - R4-R6+ → W3+.

All R4 roadmap items have a wave home. No orphan.

## Cross-reference with operational-safety memory
| Rule                                          | Plan respects? |
|-----------------------------------------------|----------------|
| No push without explicit consent              | ✔ — each PR notes |
| Compaction = cold boot                        | ✔ — W2 PR-9 hardens |
| Identity gate stability                        | ✔ — kernel-managed |
| Never fabricate tool output                    | ✔ — agent-runtime |
| No write to axon/ without dev-mode             | ✔ — plan never touches axon/ |

## Missed items found (audit corrections)

### Audit miss 1 — `tools/lint_paths.py` runs against new tools we add (migrate_meta.py, audit_compiled.py, etc.).
- Per `.github/copilot-instructions.md`, every new tool MUST use `_axon_paths.py`. Add to every PR's acceptance.

### Audit miss 2 — PR-3' migrator edits `code-dev-resume` program file. That file may also be referenced by `code-dev-tour`. Renaming/refactoring resume can break tour.
- Add to PR-3' acceptance: T1 tests pass post-edit (verifies cross-refs).

### Audit miss 3 — PR-4' (governance schema) introduces `tools/rules.py`. Not yet listed in `tools/REGISTRY.json`.
- Add to PR-4' deliverable: update REGISTRY.json.

### Audit miss 4 — Backup file glob `_meta.md.bak.<ts>` is now in `my-axon/dev-projects/*/`. Gitignore?
- Per existing `my-axon/` git config, the entire folder is its own repo. Check `.gitignore`. Add ignore rule for `*.bak.*` if absent.

### Audit miss 5 — Cheatsheet (PR-6') links to docs not-yet-existing (AXON-DOCS-WORKFLOWS.md is W3).
- Resolution: cheatsheet links to existing docs (HOWTO.md, COMMANDS.md, README) for W1; updates in W3 when new docs exist.

## Audit verdict
- v1 + I2·S fixes = healthy.
- 5 audit misses → fold into PR specs.
- DAG remains acyclic.
- Wave-1 MUST set = 4 PRs (PR-1', PR-2', PR-3', PR-4').
- All top-10 failure modes covered ≤ W3.

## Items requiring user decision (escalate or pick defaults?)

| # | Question                                              | Default                                  |
|--:|-------------------------------------------------------|------------------------------------------|
| 1 | Migrate ALL old projects at once or one-at-a-time?    | one-at-a-time; `--all` is opt-in.        |
| 2 | Tokenizer: anthropic vs tiktoken?                      | anthropic (matches deployment).          |
| 3 | Cheatsheet hand vs auto?                               | hand W1, hybrid W3.                      |
| 4 | Strict-mode stub message (where)?                      | print warning, exit 1.                   |
| 5 | Backup retention default?                              | 3.                                       |

All defaults picked. No HALT.

→ plan v2: `cd-plan-i2-p-v2.md`.
