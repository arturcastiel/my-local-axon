# Project: AXON Copilot Anchor — keep GitHub Copilot CLI in AXON persona
slug:            axon-copilot-anchor
schema-version:  v4
status:        active
legacy:          false
phase:           2-design
workflow-step:   design
branch:          main
codebase:        /mnt/c/projects/axon
parent:          axon (root)
sub-projects:    []
created:         2026-05-19
updated:         2026-05-19
predecessor:     none
seed-audit:      phases/1-study/01-drift-vectors.md

## Working Context

GitHub Copilot CLI drifts out of AXON character more readily than Claude Code does. Observed this session: subject-form prose in cognition-frame ("I'll examine...", "The user is asking me to..."), occasional Copilot-branded signatures in commit messages, and harness-emitted intent-summary lines that bypass the kernel's output gate.

This project studies *why* the drift happens and *what mechanisms* (analogous to Claude Code's Output Style + UserPromptSubmit hook + subagent) Copilot exposes to anchor a persona. Output of phase-1 = a build plan for phase-2.

## Goal

Reduce Copilot persona drift to ≤ Claude Code's baseline. Concretely:
1. **Cognition-frame leaks** (subject-form prose) → ≤ 1 / 100 turns.
2. **Brand self-references** ("As an AI", "GitHub Copilot says ...") → 0.
3. **Commit/PR sign-offs** as Copilot instead of AXON → 0.
4. **Identity-gate responses** sourced ONLY from the gate program, never improvised.

## Out of scope (v1)

- Switching harness (would defeat the purpose — the study's value is making Copilot work, since it's free for OSS contributors and pre-installed in IDE).
- Replacing Copilot's underlying model.
- Per-keystroke / per-completion gating (not a Copilot CLI feature).

## Phase plan

| Phase | Status | Output |
|---|---|---|
| 1-study | active | `01-drift-vectors.md` (this), `02-anchoring-surface.md` (Copilot mechanisms) |
| 2-design | TBD | spec for new anchoring artifacts |
| 3-build | TBD | implement the spec |
| 4-validation | TBD | drift-rate measurement |

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.

> **RE-OPENED 2026-05-27** — audit found OPEN work; restored from `obsolete/` as a workstream under **axon-improvements**. See `axon-improvements/masterplan.md` status board.
