# AXON Reference Documentation

> A working set of reference docs for AXON v3.7.0. Produced from a code audit
> (project: `axon-polish`). Each doc is grounded in the actual codebase with
> file:line citations. Audience: developers who need to explain AXON to others.

**Source code location**: `/home/arturcastiel/projects/axon-development/axon`
(byte-identical to `/mnt/c/projects/axon`; both at git HEAD `97c29c3`).

**Documentation date**: 2026-05-21 onwards (sourced during audit `axon-polish`).

## Layout

```
axon-reference/
├── README.md                                  ← you are here
│
├── kernel/                                    ← the OS core
│   └── 01-kernel-architecture.md
│
├── tools/                                     ← Python tools layer
│   └── 01-tools-inventory.md
│
├── programs/                                  ← workspace/programs catalog
│   └── 01-programs-inventory.md
│
├── workflows/                                 ← composition path + DAG
│   └── 01-workflows-and-dag.md
│
├── memory/                                    ← W: / L: / E: / local model
│   └── 01-memory-and-state.md
│
├── compliance/                                ← Core Rules + enforcement
│   └── 01-compliance-and-gates.md
│
└── identity/                                  ← cognition-frame + harness contracts
    └── 01-identity-and-harness.md
```

## Reading order

For a developer new to AXON:
1. **kernel/** — start here. What AXON is, the layered architecture, Core Rules.
2. **identity/** — how AXON stays in character; how the cognition-frame works.
3. **memory/** — how state persists across turns; W: vs L: vs E: vs local/.
4. **programs/** — what programs exist and what they do.
5. **tools/** — Python tools that programs call.
6. **workflows/** — composition path, orchestrator, DAG.
7. **compliance/** — the gates that enforce Core Rules.

## Audit context

These docs were produced during the `axon-polish` Phase 1-audit + iteration sweeps. Each doc has an "Audit-notes" appendix noting any audit findings cross-referenced.

- Full audit catalog: `/mnt/c/projects/axon/my-axon/dev-projects/axon-polish/_flaws.md` (137 flaws) and `_demands.md` (48 demands)
- ADRs: `_adrs.md` (ADR-001..007)
- Prior-work cross-reference: `_prior-work-crossref.md`
