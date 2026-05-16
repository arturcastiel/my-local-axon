# axon-master — Project Dashboard

**Generated**: 2026-05-16
**Phase**: `2-plan-complete-v5-detailed`
**Status**: active · waiting on HUMAN to start implementation
**Codebase target**: `/mnt/c/projects/axon`

---

## Numbers at a glance

| Metric | Value |
|---|---|
| PR detail files | **54** in [03-prs/](03-prs/) (53 features + 1 consistency gate) |
| PRs with Codebase grounding | **53 / 53** (PR-0 has its own grounding) |
| PRs passing schema check | **54 / 54** ✓ |
| DAG nodes ↔ files | **54 ↔ 54** ✓ |
| Functional PRs | 51 |
| Version bumps | 4 (v1, v2, v3, v4) |
| Waves | 5 (W0 consistency gate → W4 polish) |
| DAG critical path | 8 hops |
| DAG cycles | 0 (Kahn-verified) |
| Consistency check | `bash 03-prs/_check-all.sh` → exit 0 |
| Last commit | `e2d9cf0` (pushed) |

---

## Wave breakdown

| Wave | Theme | PR count | Files |
|---|---|---|---|
| **W0** | consistency gate (DAG/schema/workflow checks) | 1 | pr-0 |
| **W1** | foundation (compile gate, migrator, governance, redaction) | 8 | pr-1..7 + pr-v1 |
| **W2** | modes + sessions + routers | 15 | pr-8..17 + 9.5/9.6/9.7 + pr-16.5 + pr-v2 |
| **W3** | observability + caches + reviews | 16 | pr-15.5/15.6, pr-18..25, pr-20.5/.6/.7/.8, pr-25.5, pr-v3 |
| **W4** | renames + ergonomics + docs + 1.0 | 14 | pr-26..34 + 28.5/31.5/32.5/34.5 + pr-v4 |

---

## Critical path

```
pr-1 (T1 + lints)
  → pr-2 (compile audit gate)
  → pr-3 (v4 migrator)
  → pr-9 (_session.md)
  → pr-15 (compaction recovery)
  → pr-33 (docs wave 1)
  → pr-34 (docgen verify)
  → pr-v4 (1.0.0)
```

8 hops. See [03-prs/DAG.md](03-prs/DAG.md) for the full Mermaid graph and [03-prs/DAG.json](03-prs/DAG.json) for the machine form.

---

## Key documents

- [_meta.md](_meta.md) — project metadata (phase, status, dates)
- [01-study.md](01-study.md) — multi-cycle deep study output
- [03-plan.md](03-plan.md) — slim plan (243 lines; details delegated)
- [03-prs/INDEX.md](03-prs/INDEX.md) — per-PR file index
- [03-prs/DAG.md](03-prs/DAG.md) — dependency graph (Mermaid)
- [03-prs/DAG.json](03-prs/DAG.json) — dependency graph (machine)
- [04-log.md](04-log.md) — chronological action log

---

## Per-PR schema (each pr-*.md)

```
Header (id, slug, depends-on, blocks, wave, parallel-with)
## Why
## Evidence
## Design notes
## Pitfalls    (F-* failure mode codes)
## Interface sketch
## Spec
  - Files
  - Acceptance
  - Rollback
  - Owner
  - Parallelism
## Codebase grounding      ← added 2026-05-16
  - new:    <path> — desc
  - modify: <path> — line refs + symbols
## Cross-refs
```

---

## Recent activity (from [04-log.md](04-log.md))

- **2026-05-16** — PR detail files grounded in `/mnt/c/projects/axon`. All 53 carry concrete file paths, symbols, line refs.
- **2026-05-16** — DAG.md / DAG.json hand-built (PR-16.5 will automate).
- **2026-05-16** — 53-file per-PR restructure: 03-plan.md slimmed to 243 lines.
- **2026-05-16** — Plan v5: 48 functional + 4 version bumps (was 34+4 in v4); 14 new PRs + 11 fold-ins after cross-walking R2–R6.

---

## Next actions (suggested)

1. **HUMAN runs** `bash 03-prs/_check-all.sh` to confirm consistency baseline.
2. **Review** [pr-0](03-prs/pr-0.md) (consistency gate, must land first).
3. **Then** start implementation at pr-1 (foundation root).
4. Or run `code-dev-next` to let the dispatcher pick.

## Invariants enforced (see `_meta.md` § INVARIANTS)

- DAG integrity (node↔file bijection, topo valid, acyclic).
- PR schema completeness (9 sections per feature PR, 3 per version bump).
- code-dev program consistency (desc ≤ 60 chars, REGISTRY entry, compiles clean post-PR-1/PR-2).
- Folder layout (`NN-name.md` convention, helpers/ cycle subdirs, `_*` for tooling).
- Enforcement: `bash 03-prs/_check-all.sh` must exit 0 before any new PR lands.
