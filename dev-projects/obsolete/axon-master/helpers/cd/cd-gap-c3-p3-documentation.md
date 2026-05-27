# CD·GAP·C3·P3 — documentation strategy (U-7)

> 57 verbs, 4 layers of programs, kernel + workspace + project. Docs are scattered. Apply Diátaxis (tutorial / how-to / reference / explanation).

## What exists

| File                                | Type        | Status        |
|-------------------------------------|-------------|---------------|
| `README.md`                         | overview    | exists        |
| `CONTEXT.md`                        | reference   | exists        |
| `COPILOT.md`                        | reference   | exists        |
| `SETUP.md`                          | how-to      | exists        |
| `WORKFLOW.md`                       | tutorial-ish | exists       |
| `axon/HOWTO.md`                     | how-to      | exists        |
| `axon/COMMANDS.md`                  | reference   | exists        |
| `axon/DEVELOPER.md`                 | how-to      | exists        |
| `workspace/AXON-DOCS.md`            | reference   | exists (umbrella) |
| `code-dev-help.md`, `code-dev-tour.md`, `code-dev-howto.md` | programs | runtime help |

## Missing (per Diátaxis)

| Diátaxis      | Today                                | Gap                                                            |
|---------------|--------------------------------------|----------------------------------------------------------------|
| Tutorial      | code-dev-tour (interactive)          | static "first 30 minutes" markdown tutorial                    |
| How-to        | HOWTO, DEVELOPER                     | per-workflow how-to (e.g. "how to run a study" / "how to plan") |
| Reference     | COMMANDS.md, AXON-DOCS.md            | per-area `AXON-DOCS-*.md` (workflows, study, plan, schema, governance, sessions) |
| Explanation   | sparse                               | "why" docs: design rationale per cluster                       |

## Proposed structure

```
README.md                        ← high-level (already exists)
CONTEXT.md                       ← what AXON is (exists)
docs/                            ← NEW root for organized docs (or keep at workspace/)
├── tutorial/
│   ├── first-30-minutes.md
│   ├── your-first-pr.md
│   └── your-first-plan.md
├── how-to/
│   ├── run-a-study.md
│   ├── compose-a-plan.md
│   ├── handoff-vs-freeze.md
│   ├── migrate-old-project.md
│   └── set-up-rules.md
├── reference/
│   ├── AXON-DOCS.md             ← umbrella (existing)
│   ├── AXON-DOCS-WORKFLOWS.md   ← from R4
│   ├── AXON-DOCS-STUDY.md       ← from R5
│   ├── AXON-DOCS-PLAN.md        ← from R5
│   ├── AXON-DOCS-SCHEMA.md      ← from U-2
│   ├── AXON-DOCS-GOVERNANCE.md  ← from U-5
│   ├── AXON-DOCS-SESSIONS.md    ← from U-6
│   └── AXON-DOCS-COMPILER.md    ← from U-1
└── explanation/
    ├── why-programs-are-markdown.md
    ├── why-umbrellas.md
    ├── why-study-before-plan.md
    └── why-token-budgets.md
```

Alternative: keep docs *inline* under `workspace/` (current pattern). Decision deferred to plan time; both are tenable.

## Per-area canonical doc set

After this study completes, these files should exist (regardless of location):
- `AXON-DOCS-WORKFLOWS.md` — verb taxonomy + canonical flows (from R4).
- `AXON-DOCS-STUDY.md` — modes, areas, staleness, structure (from R5).
- `AXON-DOCS-PLAN.md` — plan modes, composition with study (from R5).
- `AXON-DOCS-SCHEMA.md` — schema versions + migrator (from U-2).
- `AXON-DOCS-GOVERNANCE.md` — rules precedence (from U-5).
- `AXON-DOCS-SESSIONS.md` — session model (from U-6).
- `AXON-DOCS-COMPILER.md` — compile pipeline + token budgets (from U-1, U-8).
- `AXON-DOCS-TESTING.md` — test surface (from U-3).
- `AXON-DOCS-FAILURE-MODES.md` — catalog (from U-4).

## Cheatsheet (highest-leverage doc)

`workspace/AXON-DOCS-CHEATSHEET.md` — one page:
- 10 most-used verbs.
- 5 canonical flows.
- 3 escape hatches (handoff, freeze, undo).
- Where to find what.

This is the "start here when lost" doc.

## Tutorial: first-30-minutes.md (proposed outline)

1. Install / clone.
2. Run `axon.py` boot (HUMAN-runs).
3. `code-dev new` your first project.
4. `code-dev study` (single mode, quickest).
5. `code-dev plan` (a tiny plan).
6. `code-dev pr-1` (start the first PR).
7. `code-dev pr ready` → mock merge.
8. `code-dev handoff` → save and stop.
9. Where to go next: pointers to how-to/ and reference/.

## Examples library

`workspace/templates/examples/` — full project skeletons:
- `examples/tiny-py-cli/` — what `my-axon/dev-projects/<slug>/` looks like for a Python CLI.
- `examples/tiny-ts-lib/` — for a TS library.
- `examples/migrating-from-v1/` — a v1 project + the migration delta.

Examples are READ-ONLY; serve as `--from-template` sources.

## Cross-reference automation

- `tools/docgen.py` already exists. Extend to:
  - Parse `# desc:` from every program.
  - Auto-generate `AXON-DOCS-COMMANDS.md` index.
  - Detect broken links across docs (`docgen verify`).

## Acceptance criteria

- Diátaxis tree decision recorded (centralized vs distributed).
- Per-area DOC files identified for plan to produce.
- Cheatsheet written (one page).
- Tutorial outline approved.
- `docgen verify` lints docs.

## Open questions
- Centralize under `docs/` or scatter? Plan time decision; my recommendation: keep under `workspace/` for now since users edit; introduce `docs/` only when sharing externally.
- Auto-vs-hand-curated commands list? Auto (via docgen) for COMMANDS; hand for everything else.
- Versioning docs against AXON version? Use VERSION file as stamp at top of each doc.

→ cost / token budgeting framework: `cd-gap-c3-p4-cost-budgeting.md`.
