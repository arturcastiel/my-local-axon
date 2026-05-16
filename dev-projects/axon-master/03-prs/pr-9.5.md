# pr-9.5 — `code-dev pr list` aggregator

**Wave**: W2 · **Goals**: G-I1 (R4 top-6 industrial gap), D-B1 (R2 top-15 #4, score 4.0) · **Depends-on**: PR-3 (schema)

## Why (problem statement)
There is no way today to see every PR across phases — agent has to grep `_meta.md` by hand. R4 ranks `pr list` as the #1 industrial gap (G-I1). R2 ranks D-B1 (`code-dev pr-list cross-phase aggregator`) at score 4.0, #4 on the executive backlog. The aggregator is the substrate for PR-20.6 (`meta board` Kanban) and PR-25.5 (`state next` factors pending PRs).

## Evidence (from studies)
- `helpers/cd-c4-p3-improvements.md` Rank 4 → D-B1 score 4.0.
- `helpers/cd-wf-c2-p1-industrial-gaps.md` → G-I1 listed first; "no list/board view" called out as the largest discoverability hole for active development.
- `helpers/cd-wf-c4-p2-roadmap.md` Wave 2 PR-2.1 → "`code-dev pr list` walks `_meta`, prints table".
- `helpers/cd-tools-p2-umbrella.md` → `pr list` is a subcommand of the `pr` umbrella; this PR lands the subcommand before the umbrella router (PR-14) — old verb routing also accepted.

## Design notes
- `tools/pr_aggregate.py`: parses `_meta.md` PR blocks (regex on `pr-<N>:` followed by indented `state:`, `slug:`, `last-program:`, `updated:`) and emits a structured list.
- Program `workspace/programs/code-dev-pr-list.md` invokes the tool and formats a table:
  ```
  ID    Slug                         Phase  State              Last-program           Age
  pr-3  schema-migrator              2      ready-for-review   code-dev-pr-respond    2d
  pr-2  compile-audit-gate           1      done               code-dev-pr-github     5d
  …
  ```
- Flags:
  - `--all-projects`: iterate `my-axon/dev-projects/*`; one block per project.
  - `--state=open|done|blocked|ready-for-review`: filter.
  - `--phase=<N>`: filter by wave.
  - `--json`: emit JSONL for downstream consumers (PR-20.6 board).
- Read-only; never writes. Cached invalidation N/A (read on demand).

## Pitfalls (from failure-mode catalog)
- **F-B4 lost last-program reference** → fallback: row shows `?` and a hint to run `code-dev-resume`.
- **F-G1 duplicate slug across projects** (in `--all-projects`) → prefix slug with project to disambiguate.

## Interface sketch
```text
$ code-dev pr list --state=ready-for-review
project: axon-master
ID    Slug                  Phase  State              Last-program          Age
pr-3  schema-migrator       2      ready-for-review   code-dev-pr-respond   2d

$ code-dev pr list --all-projects --json
{"project":"axon-master","id":"pr-3","slug":"schema-migrator","phase":2,"state":"ready-for-review",…}
…
```

## Spec (canonical)
- **Files**:
  - new: `workspace/programs/code-dev-pr-list.md`, `tools/pr_aggregate.py`.
  - modified: `tools/REGISTRY.json`.
- **Acceptance**:
  1. Reads every `pr-N` block in `_meta.md`.
  2. Columns: id, slug, phase, state, last-program, age (computed from `updated`).
  3. `--all-projects` iterates `my-axon/dev-projects/*`.
  4. `--state=...` filter works.
  5. `--json` emits one JSON object per line.
  6. `tools/lint_paths.py` clean.
- **Rollback**: revert.
- **Owner**: AGENT writes; HUMAN runs.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 2 / PR-9.5.
- Helpers: `helpers/cd-c4-p3-improvements.md` (D-B1), `helpers/cd-wf-c2-p1-industrial-gaps.md` (G-I1), `helpers/cd-wf-c4-p2-roadmap.md` Wave 2.
- Consumers: PR-20.6 (board), PR-25.5 (`state next`).
