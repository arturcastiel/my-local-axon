# CD·GAP·C1·P1 — coverage audit (what's been studied so far)

> Inventory of every helper from R2..R5. Identifies what's *deeply covered*, what's *touched*, and what's *missing entirely*.

## Studies completed (axon-master/helpers/)

### Round 2 — 4-cycle baseline study (18 helpers)
- **Programs map**, **schema map**, **tools map** (c1-p1×3)
- **Workflows** (c1-p2), **gaps** (c1-p3), **web findings** (c1-p4)
- **Deep internals** (c2-p1), **refined workflows** (c2-p2), **gap depth** (c2-p3), **prior art** (c2-p4)
- **Token hotspots** (c3-p1), **caching workflows** (c3-p2), **token backlog** (c3-p3), **caching prior art** (c3-p4)
- **Synthesis** (c4-p1), **target workflows** (c4-p2), **top-15 backlog** (c4-p3), **prior-art comparison** (c4-p4)

### Round 3 — tools umbrella (4 helpers)
- Inventory, umbrella proposal, migration plan, prior art

### Round 4 — workflow study (16 helpers)
- L1 canonical flows, entry points, cookbook, web findings
- L2 industrial gaps, CI/CD, team collab, web findings
- L3 name collisions, rename proposal, categories, web findings
- L4 synthesis, roadmap, next-study, web findings

### Round 5 — study & plan modes (16 helpers)
- L1 current state, modes taxonomy, prior art, composition
- L2 workflows, workflow gaps, plan gaps, integration
- L3 plan modes detail, study modes detail, implementation, web findings
- L4 synthesis, targets, next-study, web findings

**Total helpers so far: 54 across rounds 2–5.**

## Topic coverage matrix

| Topic                                | R2  | R3  | R4  | R5  | Coverage depth        |
|--------------------------------------|:---:|:---:|:---:|:---:|----------------------|
| 57-program inventory                 | ✓✓  |  ✓  |  ✓  |     | **deep**             |
| v4 schema                            | ✓✓  |     |     |  ~  | **deep**             |
| Tools map                            | ✓✓  |  ✓  |     |     | **deep**             |
| Compile pipeline / compression       | ✓✓  |     |     |     | **deep** (top-15 #1) |
| Compiled-program audit               |  ~  |     |     |     | **shallow**          |
| Token economics (whole flow)         |  ✓  |     |  ~  |  ~  | **medium**           |
| Workflow narrative (lifecycle)       | ✓✓  |     | ✓✓  |  ~  | **deep**             |
| Workflow gaps                        |  ✓  |     | ✓✓  |  ✓  | **deep**             |
| Naming / consolidation               |     | ✓✓  | ✓✓  |     | **deep**             |
| Industrial / CI gaps                 |     |     | ✓✓  |  ~  | **medium-deep**      |
| Team collab gaps                     |     |     |  ✓  |     | **medium**           |
| Study modes                          |     |     |     | ✓✓  | **deep**             |
| Plan modes                           |     |     |     | ✓✓  | **deep**             |
| Recipes / compositions               |     |     |     | ✓✓  | **deep**             |
| Schema migrator (v1→v4)              |  ~  |     |     |     | **shallow** (gap)    |
| Schema v5 design (stacks, sync)      |     |     |  ~  |  ~  | **shallow** (gap)    |
| Test surface for code-dev itself     |     |     |  ~  |     | **shallow** (R4-K)   |
| Failure modes / postmortems          |     |     |  ~  |  ~  | **shallow** (R4-H)   |
| Evaluation harness / idempotence     |     |     |     |  ~  | **shallow** (R5-NS-1)|
| Dispatch quality measurement         |  ~  |     |  ~  |     | **shallow** (R4-D)   |
| Documentation strategy               |  ~  |     |  ~  |  ~  | **shallow**          |
| Onboarding UX                        |     |     |  ✓  |     | **medium**           |
| Cross-cutting governance composition |     |     |  ~  |  ~  | **shallow**          |
| Session/chat/handoff model           |  ~  |     |  ~  |     | **shallow**          |
| Cost / budgeting framework           |  ✓  |     |     |  ✓  | **medium**           |
| Cross-project ergonomics             |     |     |  ✓  |     | **medium**           |
| Architecture-drift detection         |     |     |     |  ~  | **shallow**          |
| Library-dev parallel structure       |     |     |  ~  |     | **not started**      |
| Backup/sync of project state         |     |     |  ~  |     | **not started**      |

Legend: ✓✓ = full helper(s); ✓ = section; ~ = mention only; blank = not addressed.

## What "deep" means here

Deep ≡ ≥1 dedicated helper + at least one cross-reference + acceptance criteria or scored backlog items.

## Shallow / missing topics requiring this round

Eight topics are **shallow or missing** and block confident planning:

1. **Compiled-program audit** — only pr-review measured; need to audit all compiled programs.
2. **Schema migrator (v1→v4, v4→v5)** — declared gap G-CD-A1; design never written.
3. **Test surface for code-dev** — R4 Study K never executed; high risk for Round-3 W4 renames.
4. **Failure-mode catalog** — R4 Study H + R5 NS-12; we have 2+ logged incidents.
5. **Cross-cutting governance** — how `safety/rules` × `study/staleness` × `pr ready` × `plan --rule` compose.
6. **Session/chat/handoff model** — chats, handoff, freeze, undo, tag — never unified.
7. **Documentation strategy** — AXON-DOCS-WORKFLOWS.md / AXON-DOCS-STUDY.md / cheatsheet / examples.
8. **Cost / token budgeting framework** — partial across R2/R5; needs unification.

→ catalog of undercovered topics: `cd-gap-c1-p2-undercovered.md`.
→ cross-round goal extraction: `cd-gap-c1-p3-goals-extracted.md`.
→ external references: `cd-gap-c1-p4-web-findings.md`.
