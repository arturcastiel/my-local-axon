# Project: AXON Cleanup — testing-error + requirements-bloat study

slug:            axon-cleanup
schema-version:  v4
status:        obsolete
legacy:          false
phase:           3-implement
workflow-step:   implement
branch:          main
codebase:        /mnt/c/projects/axon
parent:          (none)
sub-projects:    []
created:         2026-05-17
updated:         2026-05-17
predecessor:     axon-tests (test battery shipped; surfaced the failures
                 + bloat this project addresses)

## Working Context

Three concurrent goals, studied through three iteration layers each.

**Goal A — Testing errors.** 281 failures remain on `main` after the
axon-tests battery merged. Cluster, root-cause, propose surgical fixes,
flag implications.

**Goal B — Requirements bloat.** `requirements.txt` ships 117 packages
totalling ~3.8 GB pip cache (torch + CUDA + transformers + chromadb +
opentelemetry stack). Only 18 packages have a direct `import` in the
repo. Identify which can be removed safely and what becomes lighter.

**Goal C — Usefulness audit.** For every tool, program, doc, and test —
is it called from somewhere? Is its API still aligned with its callers?
Anything orphaned can be archived or deleted.

## Iteration layers

- **L1 — Surface inventory.** What's broken / unused / bloated? Pure
  enumeration, no opinions yet.
- **L2 — Root cause + dependency edges.** Why is each L1 item the way
  it is? Who depends on it?
- **L3 — Solution shapes + implications.** For each proposed fix or
  deletion: what cascades, what's safe, what needs a guard.

## Output

After L3 the user reviews `01-study/03-final-findings.md`, then we
start the plan (PRs, sequencing, deviation table). NO plan/PR work
this phase.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
