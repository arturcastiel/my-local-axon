# Decisions (ADRs) — 1-study

## D-001 · 2026-05-20 · Sibling, not extension
Decision: Create `axon-copilot-consistency` as a sibling of `axon-copilot-anchor`
rather than extending the latter.

Why:
- `-anchor`'s phase-1 was authored while running inside Copilot itself, so its
  findings need re-validation before being load-bearing.
- The user does not fully trust its conclusions.
- The new symptoms (command comprehension, tool-call gap) are not in `-anchor`'s
  scope — that project is strictly about persona drift.

Consequence:
- This project consumes `-anchor`'s drift definition as input, not authority.
- The two projects coexist; persona drift work continues in `-anchor`.
