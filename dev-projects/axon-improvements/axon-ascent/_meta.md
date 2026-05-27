# Project: AXON Ascent — substrate → product maturation (axons-audit follow-up)
slug:            axon-ascent
schema-version:  v4
status:        active
legacy:          false
phase:           3-safety-budget
workflow-step:   implement
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
source-audit:    /home/arturcastiel/projects/axons-audit
parent:          (none)
sub-projects:    []
created:         2026-05-23
updated:         2026-05-23

# Linked, NOT initialized. Phases are scaffolded in `planned` state with
# scope captured in masterplan.md + each phase _meta.md. No study/audit
# has been run inside this project — the source audit already exists at
# `source-audit` above. Run `code-dev load axon-ascent` then
# `code-dev phase start 1-telemetry` to begin.

## Working Context
- Vision: take AXON from the axons-audit verdict — "promising substrate,
  immature product · HEALTHY structurally · Good (72.6/100) usefulness ·
  LOW integration surface" — to a mature, ecosystem-connected product,
  WITHOUT softening the kernel rules that are its moat.
- Source: every phase maps to levers in `/home/arturcastiel/projects/axons-audit`
  (15 improvement levers + 22 competitor features + low-hanging fruit).
  See `_source-audit.md` for the full cross-reference.
- Phase graph (6 phases, dependency-ordered):
    1-telemetry     turn the self-improvement loop ON (fruit B/C/D/F + dashboard)
    2-integration   MCP client+server, A2A handoff, SKILL.md shim
    3-safety-budget token budget gate, Docker sandbox, adversary reviewer, plan-mode default
    4-eval          reproducible eval harness (builds on axon-polish Phase-5) + replay + fix axon-compare
    5-benchmark     SWE-bench Lite → Verified (the thesis-prover; depends on 4-eval)
    6-ecosystem     plugin/registry install, subagent registry, background/remote exec, browser tool
- Baseline at link time (2026-05-23, post axon-polish): see `_baseline-2026-05-23.md`.
  Headline: 11 robustness PRs left usefulness UNCHANGED at 72.6 because the
  score is gated by runtime telemetry that is still all-zero. That is the
  single strongest argument for sequencing 1-telemetry FIRST.
- dev-mode: kernel writes permitted but always routed through PR specs.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.

> **RE-OPENED 2026-05-27** — audit found OPEN work; restored from `obsolete/` as a workstream under **axon-improvements**. See `axon-improvements/masterplan.md` status board.
