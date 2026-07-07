# ADR-001 — Metric pipeline: honest descope of agent-side usage recording

**Schema**: adr-v1 · **Status**: accepted · **Date**: 2026-07-07
**Owner**: axon-bugfix02 · **Supersedes**: —

## 1. Title
Metric pipeline: honest descope of agent-side usage recording

## 2. Status
Current: **accepted** (owner decision D2, 2026-07-07: "follow advises")

## 3. Context
dispatch-stats and gain's TOP-PROGRAMS panel join on `usage-log.jsonl` +
`dispatch-feedback.jsonl`. Neither file exists in this install despite heavy real
dispatch activity. Root cause (pinned at plan time, verified against source): AXON
programs execute AGENT-SIDE — the LLM interprets the markdown directly — while the only
`usage.py record` caller is `tools/run.py` (~line 132), the mechanical runner that is
NOT on the real execution path. The pipeline is starved at the source; its reports were
plausible zeros that read as "no activity" when the truth is "nothing measures activity."

## 4. Decision
We will NOT wire an agent-side usage recorder in this project. Instead, every consumer
states its real condition: dispatch-stats emits an `inputs` presence block + an explicit
starvation note when its inputs are missing; gain's TOP-PROGRAMS panel states that
program-run recording is not wired for agent-side execution and points here.

## 5. Alternatives
| option                          | summary                                                   | why-rejected |
|---------------------------------|-----------------------------------------------------------|--------------|
| Kernel-protocol recording       | Response gate appends a usage row on every program EXEC   | Kernel edit (owner-only, inviolable floor) + a per-turn token/latency cost forever; deserves its own project if ever |
| Turn-log derivation             | Derive per-program stats from workspace/log/turns/        | The live turn-log rows are degenerate (constant OUT text, no program attribution) — counts only; cannot back per-program metrics |
| Silent zeros (status quo)       | Keep rendering zero tables                                | Dishonest self-report — exactly the defect class this project exists to kill |

## 6. Consequences
**Positive**: the OS never claims metrics it does not have; the recorder decision is
documented, reversible, and owner-gated.
**Negative / costs**: no per-program usage analytics until a recorder exists;
`usage.py`/`dispatch-feedback` remain functional-but-unfed.
**Follow-up actions**: if per-program metrics become wanted, open a dedicated project
for kernel-protocol recording (the only honest wiring point).

## 7. Related
- Plan: [`../02-plan.md`](../02-plan.md) — decision D2, council record.
- Findings: gain C2, dispatch-stats HIGH (AUDIT-FINDINGS.md).
