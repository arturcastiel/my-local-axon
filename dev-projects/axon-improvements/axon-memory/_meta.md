# Project: AXON Memory — native, harness-portable memory + reminders subsystem
slug:            axon-memory
schema-version:  v4
status:        active
legacy:          false
phase:           2-plan
workflow-step:   plan
branch:          main
codebase:        /home/arturcastiel/projects/axon-development/axon
parent:          (none)
sub-projects:    []
created:         2026-05-24
updated:         2026-05-24
next-action:     WAVE COMPLETE — AM1-AM6 merged (#89/#90/#91/#92/#93/#95). Only #96 (load-wiring, kernel, CI-green) awaits USER merge. Deferred: code-dev-load project-load, green-mode cron, todo/digest boot-surface, Claude Stop-hook.
last-program:    (kickoff)
last-ts:         2026-05-24

## Working Context
- Goal: an AXON-native, harness-portable MEMORY + to-do/reminder subsystem that stays
  scalable in any real workflow — never bulk-loaded, never rotting, never leaking,
  never interrupting. Replaces reliance on the Claude Code harness auto-memory.
- Origin: promoted from the axon-ascent candidate `_candidate-agent-memory.md` (scope
  outgrew an axon-ascent phase). Study + plan were done in-conversation on 2026-05-24,
  so the project opens at plan-complete / build-ready.
- Architecture + every decision: see masterplan.md (the harmonized spec). PR roadmap:
  02-prs.md. Build order: 03-dag.md.
- Grounding (design verified against existing primitives): memory.py (L/W/E scopes),
  dispatch.py (TF-IDF ranked recall), events.py + cron.py (green-mode scheduling),
  undo.py/_axon_rollback.py (reversible quarantine), KERNEL-SLIM boot-load step,
  copilot-instructions.md (cross-harness).
- Sequencing: this is the axon-core wave AFTER reservoir-eng cluster D. Cluster-N
  (neuron-contract conformance) FOLLOWS and absorbs the memory-graph declaration layer
  (the `memory-reads:`/`memory-writes:` synapse fields + neuron-audit checks).
- Privacy invariant: all memory writes default PRIVATE (my-axon); workspace only when
  explicitly shareable. No personal info reaches axon.git.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.

> **RE-OPENED 2026-05-27** — audit found OPEN work; restored from `obsolete/` as a workstream under **axon-improvements**. See `axon-improvements/masterplan.md` status board.
