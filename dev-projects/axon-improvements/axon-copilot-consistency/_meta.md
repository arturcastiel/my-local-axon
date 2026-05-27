# Project: AXON Copilot Consistency — stable behavior across turns in Copilot CLI/IDE
slug:            axon-copilot-consistency
schema-version:  v4
status:        active
legacy:          false
phase:           2-design
workflow-step:   design
branch:          feature/pr-ca-102-axon-reanchor
codebase:        /mnt/c/projects/axon
parent:          axon (root)
sub-projects:    []
sibling:         axon-copilot-anchor
created:         2026-05-20
updated:         2026-05-20
phase-1-score:   8.4 / 10
predecessor:     none

## Working Context

Sibling to `axon-copilot-anchor`. While `-anchor` focuses on *persona drift*
(cognition-frame leaks, brand bleed, commit sign-offs), this project covers the
broader **consistency** problem observed across Copilot CLI and the Copilot IDE
extension:

- **Command comprehension** — user types AXON commands (e.g. `boot axon`,
  program names, mode shortcuts) and Copilot misroutes or partially understands
  them more often than Claude Code does.
- **Tool-call gap** — Copilot has shell/Python access in agent modes, but does
  not call `python3 axon.py …` consistently for boot/health/log/etc. It tends
  to *describe* the command instead of executing it, even when the harness
  contract permits autonomous shell use for read-only state.
- **Drift across turns** — the persona slips between turns more easily.
  Re-anchor on every turn is not free; the question is what mechanism is
  cheapest and most reliable on Copilot.

Same underlying model as Claude Code (Opus), so the gap is **harness-level**,
not model-level. Phase 1 establishes what we know and what Copilot actually
exposes; phase 2 designs interventions; phase 3 builds; phase 4 measures.

The pre-existing `axon-copilot-anchor` project's phase-1 study material
(`phases/1-study/01-drift-vectors.md`, `02-anchoring-surface.md`) is **input,
not authority** — it was authored while running inside Copilot itself, so
needs re-validation from a Claude Code session before being trusted.

## Goal

Reach **parity with Claude Code** on three measurable axes inside Copilot CLI
and the Copilot IDE extension:

1. **Command routing accuracy** ≥ Claude Code baseline (per `dispatch-stats`).
2. **Tool-call rate** for boot/health/log/etc. ≥ Claude Code baseline
   (Copilot describes vs. executes ≤ 5% of agent-mode turns).
3. **Persona-drift rate** ≤ Claude Code baseline (handed off to
   `axon-copilot-anchor`; this project consumes its drift definition).

## Out of scope (v1)

- Replacing Copilot's underlying model.
- Per-keystroke / inline-completion AXON injection (not a Copilot CLI feature).
- Migrating users off Copilot — the goal is to make Copilot work, since it's
  free for OSS contributors and pre-installed in VS Code.
- Persona drift mechanisms — owned by `axon-copilot-anchor`. This project
  consumes that project's outputs; it does not duplicate them.

## Phase plan

| Phase | Status | Output |
|---|---|---|
| 1-study | ✓ CLOSED 2026-05-20 (score 8.4/10) | `phases/1-study/01-study.md` + `_audit.md` + `_closure.md` |
| 2-design | active | `phases/2-design/_meta.md` — 6-PR queue (CC-201..CC-206) with DAG + per-PR specs |
| 3-build | TBD | implement the 6 PRs; each requires reproduction transcripts in both Claude Code AND Copilot CLI |
| 4-validation | TBD | measure G-1..G-5 (routing accuracy, tool-call rate, drift rate, contradiction count, file size) |

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.

> **RE-OPENED 2026-05-27** — audit found OPEN work; restored from `obsolete/` as a workstream under **axon-improvements**. See `axon-improvements/masterplan.md` status board.
