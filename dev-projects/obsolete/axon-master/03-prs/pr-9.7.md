# pr-9.7 — `meta context use <slug>`

**Wave**: W2 · **Goals**: G-I10 (R4), G-M1 · **Depends-on**: PR-3

## Why (problem statement)
Today the active project is implicit: `code-dev load <slug>` is the only switch, and it does not auto-save the current session before switching (F-G3). With multiple projects (axon-master, smo-faults, others in `my-axon/dev-projects/`), the user routinely loses state when context-switching mid-flow. R4 ranks `meta context use <slug>` as G-I10. R4 cookbook documents the "switch projects safely" recipe but the verb itself is missing.

## Evidence (from studies)
- `helpers/cd-wf-c2-p1-industrial-gaps.md` → G-I10 "multi-project context management".
- `helpers/cd-wf-c1-p3-cookbook.md` → recipe 7: "switch projects mid-day"; documents the need for auto-save.
- `helpers/cd-gap-c2-p4-failure-modes.md` → F-G3 "context-switch loses unsaved state".
- `helpers/cd-tools-p2-umbrella.md` → `meta` umbrella; `context use|list` subcommands.

## Design notes
- New program `workspace/programs/code-dev-meta-context.md`. Subcommands:
  - `use <slug>`: validate target project exists; check if current `_session.md` state is `active` AND has uncommitted journal events (= "dirty"); if dirty, warn and `QUERY` user; on confirm, run `code-dev handoff` first then switch.
  - `list`: enumerate `my-axon/dev-projects/*` with state per project.
  - `current`: print currently active project (from `W:code-dev-project`).
- `tools/prefs.py` modified: switching `W:code-dev-project` goes through `meta_context.use()` which centralizes the auto-save logic.
- Switch sequence:
  1. `tools/session.py.checkpoint("context-switch")` on current.
  2. If dirty → `EXEC(code-dev-handoff)` first.
  3. `STORE(W:code-dev-project, <new-slug>)`.
  4. `EXEC(code-dev-load)` on new slug.

## Pitfalls (from failure-mode catalog)
- **F-G3 context-switch loses unsaved state** → auto-save before switch.
- **F-G2 stale `W:code-dev-project`** → `list` shows project existence; `use` validates path.
- **F-G1 duplicate slug** → checked in `use` (refuses non-unique target).

## Interface sketch
```text
$ code-dev meta context list
  axon-master   (active session, 32 turns)  ← current
  smo-faults    (frozen)
  experiments   (closed)

$ code-dev meta context use smo-faults
warning: axon-master session is dirty (3 journal events since last handoff)
auto-save? [Y/n] y
✓ code-dev handoff (axon-master)
✓ active project → smo-faults
✓ code-dev load (smo-faults)
```

## Spec (canonical)
- **Files**:
  - new: `workspace/programs/code-dev-meta-context.md`.
  - modified: `tools/prefs.py`, `tools/REGISTRY.json`.
- **Acceptance**:
  1. `meta context use <slug>` validates project path exists.
  2. Writes `W:code-dev-project`; persists across sessions.
  3. Auto-saves current session (warns + prompts if dirty).
  4. `meta context list` shows all projects + state.
  5. `meta context current` prints active slug.
  6. `tools/lint_paths.py` clean.
- **Rollback**: revert; users fall back to `code-dev load <slug>` (no auto-save).
- **Owner**: AGENT writes; HUMAN tests dirty-switch path.

## Codebase grounding
- **new**: `workspace/programs/code-dev-meta-context.md` — sub-program of new `meta` umbrella (PR-14). Subcommands: `list`, `use <slug>`, `current`.
- **modify**: [`tools/prefs.py`](../../../../tools/prefs.py) — currently 45 lines aggregating `workspace/preferences/*.md`; extend to also write workspace prefs via new helper `set_pref(key, value)` (calls `_axon_io.atomic_write`).
- **target W: key**: `W:code-dev-project` (already used by `code-dev-load.md` per [`workspace/programs/code-dev-load.md`](../../../../workspace/programs/code-dev-load.md) pattern).
- **dirty-switch check**: read `_session.md` state; if `active` and not `tagged` within last 5 min → WARN before switch.
- **validate slug**: ensure `{W:myaxon-dev-projects}/<slug>/_meta.md` exists.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 2 / PR-9.7.
- Helpers: `helpers/cd-wf-c2-p1-industrial-gaps.md` (G-I10), `helpers/cd-wf-c1-p3-cookbook.md` recipe 7, `helpers/cd-gap-c2-p4-failure-modes.md` (F-G3).
