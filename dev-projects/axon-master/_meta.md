# Project: AXON Master
slug:         axon-master
status:       active
phase:        2-plan-complete-v5-detailed
codebase:     /mnt/c/projects/axon
parent:       (none)
sub-projects: []
created:      2026-05-16
updated:      2026-05-16

## STUDY DIRECTIVE
Multi-cycle deep study of AXON. Each cycle = 4 phases:
  1. Study axon repo deeply (read kernel, programs, tools, structure)
  2. Brainstorm workflows axon + tools could enable
  3. Identify ways to improve axon (faster, more useful, fewer tokens)
  4. Web research — libraries, prior art, comparable systems

Repeat 4 cycles total. Each phase WRITES helper files into ./helpers/
Goal: extensive documentation + actionable improvement backlog.

## INVARIANTS (consistency-first directive — 2026-05-16)

Before ANY pr-N implementation lands, these invariants MUST be re-verified.
If any breaks, fix the inconsistency FIRST. New features wait.

1. **DAG integrity**
   - Every `**Depends-on**:` token in `03-prs/pr-*.md` exists as a node in `03-prs/DAG.json`.
   - Every file `03-prs/pr-*.md` appears in `nodes` and `topo` exactly once.
   - `topo` is a valid topological order over `edges`.
   - `acyclic: true`.

2. **PR schema completeness**
   - Every `03-prs/pr-*.md` (excluding `pr-v*.md`) has all 9 H2 sections:
     `Why · Evidence · Design notes · Pitfalls · Interface sketch · Spec ·
     Codebase grounding · Cross-refs` (Spec subsections may abbreviate).
   - `pr-v*.md` (version bumps) require `Why · Spec · Cross-refs` only.

3. **code-dev program consistency** (referenced PRs in `/mnt/c/projects/axon/workspace/programs/`)
   - Any pr-N that ships a new `code-dev-<name>.md` must:
     - declare `# desc:` line ≤ 60 chars,
     - register in `tools/REGISTRY.json` (when PR-1 lands the registry contract),
     - compile clean per PR-2 audit gate (when PR-2 lands).
   - Rename PRs (W4) MUST also update: REGISTRY.json, dispatch corpus (PR-18),
     tour cross-refs (PR-1 lint), and leave alias-stubs.
   - No new code-dev-* program lands without these four.

4. **Folder layout** (this project)
   - Numbered docs use `NN-name.md` prefix (00-dashboard, 01-study, 02-brainstorm, 03-plan, 04-log, 05-branches).
   - Per-PR specs in `03-prs/pr-<id>.md`.
   - DAG canonical sources: `03-prs/DAG.md` (human) + `03-prs/DAG.json` (machine).
   - helpers/ organized by cycle subdir: `c1/`, `c2/`, `c3/`, `cd/`.
   - Underscore-prefixed files are config/tooling (`_meta.md`, `_dag-check.py`).

5. **Enforcement**
   - PR-0 ships executable checks: `_dag-check.py`, `_schema-check.py`, `_workflow-audit.md` (auto-regenerated).
   - Every PR's Acceptance section implicitly inherits "PR-0 checks pass".
   - On first FAIL, halt; do not append features.

