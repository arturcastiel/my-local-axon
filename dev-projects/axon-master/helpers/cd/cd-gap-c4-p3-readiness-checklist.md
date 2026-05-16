# CD·GAP·C4·P3 — pre-plan readiness checklist

> Use this as the gating checklist when the user runs `code-dev plan`. R6 ends with all items either [x] (in-evidence) or marked as known-deferred. If anything is missing, the plan should HALT and QUERY.

## Evidence base
- [x] R2 baseline study (10 helpers, 4 cycles)
- [x] R3 tools umbrella (4 helpers)
- [x] R4 workflows + roadmap (16 helpers + roadmap appendix)
- [x] R5 study/plan modes (16 helpers + targets/next-study)
- [x] R6 gap-closure (this round) — 16 helpers + goal tree

## Coverage check (per area)
- [x] Schema (G.inf.*) — covered in R5 + U-2
- [x] Compiler & tokens (G.tok.*) — covered in R2 + U-1 + U-8
- [x] Umbrella & naming (G.umb.*) — covered in R3
- [x] Workflows (G.wf.*) — covered in R4
- [x] Study mode (G.study.*) — covered in R5
- [x] Plan mode (G.plan.*) — covered in R5
- [x] Governance (G.gov.*) — covered in U-5
- [x] Session model (G.sess.*) — covered in U-6
- [x] Testing (G.test.*) — covered in U-3
- [x] Documentation (G.doc.*) — covered in U-7
- [x] Observability / cost (G.obs.*) — covered in U-8
- [x] Failure modes / safety (G.safe.*) — covered in U-4
- [ ] Team / multi-actor (G.team.*) — DEFERRED to v5, NOT in this plan's scope

## Goal-tree integrity
- [x] 91 goals enumerated.
- [x] Every goal has a source helper.
- [x] P0/P1/P2/P3 levels assigned.
- [x] Wave-1 / Wave-2 / Wave-3 / later candidates identified.
- [x] Critical path documented.
- [x] Effort × impact scatter sketched.

## Constraints captured (governance inputs the plan must consume)
- [x] Kernel rules (axon/KERNEL-SLIM.md) — non-negotiable.
- [x] User-memory operational-safety rules (`/memories/operational-safety.md`).
- [ ] `workspace/safety/rules.md` — SCHEMA defined (G.gov.01), file not yet populated by user. Plan SHOULD proceed and emit empty governance-trace, not HALT.
- [ ] `workspace/dont-do.md` — same status.
- [x] AGENT contract (AGENTS.md, .github/copilot-instructions.md).

## Known-unknowns the plan must respect
- Actual token costs per program — measurement deferred to G.tok.01 (in plan).
- Real failure-rate baseline — no telemetry yet (G.obs.01 will produce).
- Whether centralized `docs/` tree or scattered workspace docs (U-7 open question).
- v5 schema final shape — deliberately deferred.

## Risk register (top items)
| Risk                                                | Likelihood | Damage | Mitigation in plan |
|-----------------------------------------------------|------------|--------|--------------------|
| Migrator regression breaks live project state       | low        | HIGH   | dry-run + backup + tests (G.inf.02, G.test.01) |
| Compile gate too strict, blocks normal compiles     | medium     | MED    | start at 95% threshold; ratchet later |
| Renames (R3 W4) break dispatch                       | medium     | MED    | TW8 harness blocks W4 (G.umb.04) |
| Governance precedence ambiguous on edge cases       | medium     | LOW    | HALT+QUERY on contradiction (G.gov.03) |
| Sessions/checkpoints add overhead                   | low        | LOW    | opt-in initially                  |

## Non-goals (explicit)
- Multi-user / team mode.
- Library-dev parallel program family.
- Visual UI for AXON.
- Network sync of `my-axon/` (beyond manual git push).
- Replacing kernel rules with anything.

## Outputs available to the plan
The plan can read freely:
- All R2-R6 helpers (`my-axon/dev-projects/axon-master/helpers/*.md`).
- `01-study.md` (overview).
- `04-log.md` (round-by-round changes).
- `_meta.md` (project state — v1 currently).
- `INDEX.md` (helper index).
- Workspace AXON-DOCS-*.md as they exist.

## Recommended plan modes
- **Wave-1** ← `plan --mode=tactical --rule "no new top-level deps until measured"`.
- **Wave-2** ← `plan --mode=tactical --depends-on wave-1`.
- **Wave-3+** ← `plan --mode=strategic` (rough sequence; not detailed).

## What the plan should EXPLICITLY answer
1. Which wave-1 goals (subset of P0) ship first?
2. For each: PR list (`pr-N`), acceptance, owner (HUMAN / agent / hybrid), risk note.
3. Dependencies between PRs (DAG).
4. Token / time budget per wave (cumulative).
5. Gate criteria to move wave-1 → wave-2.
6. Rollback strategy per PR.
7. Documentation deliverables per wave.
8. Test deliverables per wave.

## Signal of readiness
ALL boxes above are checked or explicitly deferred. R6 ends here.

→ closure: `cd-gap-c4-p4-closure.md`.
