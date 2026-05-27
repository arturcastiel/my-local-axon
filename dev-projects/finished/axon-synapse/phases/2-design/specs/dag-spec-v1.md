# DAG Spec (v1) — 5 levels + nested sync-checker

> glossary: SYNAPSE-GLOSSARY v1
> resolves: F-015, D-006, D-009, D-2, D-3, D-4

## Purpose

Define the DAG file layout at all 5 levels, the canonical JSON shape, the
auto-renderer rules, the mutator API, and the nested sync-checker.

## Levels (per glossary)

| Level | File path |
|-------|-----------|
| **Project** | `<project>/DAG.{json,md}` |
| **Phase** | `<project>/phases/{n}/DAG.{json,md}` |
| **Plan** | `<project>/phases/{n}/03-prs/DAG.{json,md}` (or `<project>/03-prs/DAG.{json,md}` legacy) |
| **PR** | `<project>/phases/{n}/03-prs/PR-NNN/DAG.{json,md}` (optional — only if PR is subdivided) |
| **Study** | `<project>/phases/{n-study}/DAG.{json,md}` |

`DAG.json` is canonical. `DAG.md` is rendered (one-way auto-emit).

## JSON shape (canonical)

```json
{
  "schema": "axon-dag",
  "schema-version": "v1",
  "level": "phase",                              // project | phase | plan | pr | study
  "owner": "axon-synapse/phases/2-design",       // path of the owning node
  "generated": "2026-05-17T15:30:00Z",
  "generator": "plan_dag.py v1.2",               // or "manual" / "dag-bootstrap" etc.
  "validated": true,                             // last cycle-check result
  "critical-path": ["n1","n3","n7","n9"],        // computed; may be empty

  "nodes": [
    {
      "id": "n1",
      "kind": "synapse",                         // synapse | pr | phase | step | question
      "name": "code-dev-study",                  // synapse name OR PR id OR phase name
      "label": "Phase 1: study",                 // human-readable
      "status": "complete",                      // pending | active | complete | failed | skipped
      "child-dag": null                          // path to nested DAG file (or null)
    },
    {
      "id": "n2",
      "kind": "synapse",
      "name": "code-dev-plan",
      "label": "Phase 2: plan",
      "status": "active",
      "child-dag": "phases/2-design/03-prs/DAG.json"   // nested
    }
  ],

  "edges": [
    {
      "from": "n1",
      "to": "n2",
      "kind": "depends",                         // depends | suggests | sub-of | parallel
      "predicate": "phase.1-study.status == complete",
      "label": "after study"
    }
  ],

  "metadata": {
    "node-count": 2,
    "edge-count": 1,
    "cycles": []
  }
}
```

### Field constraints

- `id` is unique within the file. Format: `n<int>` or `<level>-<int>`.
- `kind: synapse` → `name` must resolve to a real synapse. `kind: pr` →
  `name` is a PR id like `PR-007`. `kind: question` → `name` is `Q11` etc.
  (study DAGs).
- `status` is updated by the orchestrator as work progresses.
- `child-dag` is a relative path to another `DAG.json`; nested-consistency
  check validates the linked file exists + its nodes appear as edges in
  this DAG.
- `edges[].kind == depends` is the default (topological ordering); other
  kinds carry meaning per the rendering rules.

## Auto-renderer (DAG.md) rules

`DAG.md` is regenerated whenever `DAG.json` changes. The renderer:

1. Emits a top header with `level`, `owner`, `generated`, `validated`,
   `critical-path`.
2. Emits a Mermaid block with the graph:
   ```mermaid
   graph LR
     n1[Phase 1: study<br/>✓ complete]
     n2[Phase 2: plan<br/>● active]
     n1 -->|after study| n2
   ```
3. Emits a flat node table (id · kind · name · status · child-dag).
4. Emits an edge table.
5. Emits warnings if nested DAGs reference nonexistent files or have
   inconsistent child-parent edges.

The renderer NEVER reads `DAG.md` to update `DAG.json` — md is read-only
output. Hand-edits to md are lost on next regeneration. (Rationale per
F-015: avoids round-trip sync complexity.)

## Mutator API (Phase 3 tool: `dag.py`)

```
python3 axon.py dag bootstrap   --level <project|phase|plan|pr|study> --path <dir>
python3 axon.py dag add-node    --file <DAG.json> --kind <k> --name <n> --label "<l>"
python3 axon.py dag add-edge    --file <DAG.json> --from <id> --to <id> --kind depends
python3 axon.py dag remove-node --file <DAG.json> --id <id>     # cascading
python3 axon.py dag remove-edge --file <DAG.json> --from <id> --to <id>
python3 axon.py dag merge       --file <DAG.json> --ids <a,b> --into <id> --new-label "<l>"
python3 axon.py dag split       --file <DAG.json> --id <id>    --into-ids <a,b> --new-labels "<a>,<b>"
python3 axon.py dag fold-in     --file <DAG.json> --child-id <id> --into <id>
python3 axon.py dag set-status  --file <DAG.json> --id <id> --status <s>
python3 axon.py dag render      --file <DAG.json>              # regenerate DAG.md
python3 axon.py dag verify      --file <DAG.json>              # cycle check + nested check
python3 axon.py dag sync        --root <project-dir>           # validate all nested DAGs in project
```

Every mutator:
1. Writes the new `DAG.json`.
2. Re-runs cycle check (Kahn).
3. Re-emits `DAG.md`.
4. Logs to `04-log.md`.
5. EMITs `axon.dag.mutated` event with details.

Atomicity is best-effort (write to `.tmp` + rename). Failure rolls back.

## Auto-generation hooks (resolves D-2)

| Trigger | Action |
|---------|--------|
| `code-dev new` | Bootstrap project DAG (empty phase graph). |
| `code-dev phase new` | Bootstrap phase DAG (empty sub-step graph) + add node to project DAG. |
| `code-dev plan` finalize | Run `plan_dag.py` over `02-prs.md` → emit plan DAG. |
| `code-dev study` finalize | Run `study-dag-emit` over Q-list + tracks + findings → emit study DAG. |
| `code-dev pr-create` | Add PR node to plan DAG. If PR is subdivided, bootstrap PR DAG. |
| `code-dev-combine A B` | `dag merge` on plan DAG. |
| `code-dev-divide A` | `dag split` on plan DAG. |
| `code-dev-fold A into B` | `dag fold-in` on plan DAG. |
| `code-dev-defer A` | `dag set-status A=skipped` on plan DAG. |

The mutator hooks ensure no mutation bypasses DAG update (resolves D-3).

## Nested DAG sync (resolves D-4)

For every node `n` with `child-dag: <path>`:

1. ASSERT `file.exists(child-dag)`.
2. ASSERT every node in `child-dag` has at least one edge in/out (otherwise
   orphan).
3. ASSERT the parent edges that touch `n` are reflected in the child-DAG's
   own predecessor/successor edges (where conceptually applicable —
   exact algorithm per `dag-sync.py`).

The `dag sync --root <project>` walks the project root, finds every
`DAG.json` recursively, and checks nesting consistency. Output:

```
DAG sync — axon-synapse
  ✓ DAG.json (project, 4 phases, 0 cycles)
  ✓ phases/1-study/DAG.json (12 questions, 7 tracks, 17 findings)
  ✓ phases/2-design/DAG.json (10 specs)
  ✓ phases/2-design/03-prs/DAG.json (0 PRs — phase has no plan yet)
  ⚠ phases/1-study/DAG.json references child-dag phases/1-study/findings/F-005-DAG.json — file missing
```

Warnings non-blocking; errors abort sync.

## Critical-path

Computed by Kahn's topological sort + longest-path-by-edge-weight.
Default edge weight = 1; synapse cost.tokens-estimate may be used in v2.

Critical path surfaces in DAG.md header + in the menu's project line
(future enhancement).

## Performance

For dev-projects with up to ~200 nodes per level: cycle check < 50ms,
render < 100ms. Larger projects may pre-compute and cache.

## Validation

`dag verify` errors:

- `CYCLE_DETECTED` — abort, surface cycle members.
- `MISSING_CHILD_DAG` — abort.
- `ORPHAN_NODE` — warn (not blocking — partial DAGs are legitimate
  during construction).
- `UNRESOLVED_SYNAPSE_NAME` — warn.
- `SCHEMA_VERSION_MISMATCH` — abort with migration hint.

## Filename convention (validated against existing plan_dag.py)

`plan_dag.py` (already shipping per F-015) walks
`<project-dir>/03-prs/pr-*.md` with **lowercase** `pr-N.md` pattern. Existing
3 dev-projects use lowercase. The v1 spec adopts lowercase as the canonical
form:

- PR-spec files: `phases/{n}/03-prs/pr-NNN.md` (lowercase)
- Internal ID in DAG.json `nodes[].name`: `pr-NNN` (lowercase, matching filename stem)
- Display label (for humans): `PR-NNN` (uppercase) — used only in
  rendered DAG.md and markdown headings.

The phase-2 DAG.json in this project currently uses uppercase `PR-NNN`
internally. **Fix:** PR-113 (plan_dag auto-emit hook) normalizes on read +
write; this project's `phases/2-design/03-prs/DAG.json` will be regenerated
in lowercase when PR-110 lands. Tracked as a Phase-3 housekeeping task.

## Migration (Phase 3)

1. `dag-bootstrap-project` — every existing project gets a project DAG
   seeded from `masterplan.md` parsing.
2. `dag-bootstrap-phase` — every phase gets a phase DAG (initially empty
   for finalized phases; populated for active).
3. `dag-bootstrap-study` — Phase-1-study phases get a study DAG seeded
   from `01-study.md` Q-list + `findings/INDEX.md`.
4. Existing plan-level DAGs (3 dev-projects) are migrated to schema v1
   (mostly identical; minor field renames).
5. PR-level DAGs are created on-demand only.

## v1.1 additions (2026-05-17)

### MD → JSON recovery (GAP-04 — addresses single-point-of-failure)

`dag recover --from-md <DAG.md>` best-effort parses md → JSON, writing
output to `DAG.recovery.json` (NEVER `DAG.json` directly). User reviews
diff with `dag verify --against <recovery>` then promotes via
`dag promote-recovery`. This is a last-resort path — primary editing
remains JSON + mutator commands.

### Mixed-case filename migration (GAP-08)

`dag normalize-pr-filenames --project <slug>` walks the project's
03-prs/ tree, case-normalizes `PR-NNN.md` / `pr-NNN.md` → lowercase
`pr-NNN.md`. Updates DAG.json node names + edges. Leaves a
backwards-compat symlink (`PR-NNN.md → pr-NNN.md`) for tooling that
still expects uppercase. Idempotent.

Existing dev-projects: axon-master = lowercase (no-op);
axon-cleanup = uppercase (normalization needed in Phase-3 housekeeping).

## Version + change rule

**Version: v1.1 (2026-05-17).** Schema-version field in every DAG.json.
Bumps require migration tool.
