# Audit — Fault SMO Mesh Adaptation

**Date:** 2026-07-28 · **Method:** every claim below is checked against the plan
(`02-prs.md`) and against a measurement, not against memory.

---

## 1. Delivery against plan

17 PRs planned. **15 delivered, 1 superseded, 1 deferred with a study.**

| PR | Planned | Outcome |
|----|---------|---------|
| 000a | gate setup, cpg2python | **done** — PR #38, CI green |
| 000b | gate setup, fault-projections | **done** |
| 001 | `write_grid_include` | **done** — 35 tests |
| 002 | pillar lattice + validity | **done** — 27 tests |
| 003 | segment provenance through `project_polyline` | **superseded** — D20 made targets read the lattice directly, so provenance is native |
| 004 | `morph_pillars` core | **done** — 25 tests |
| 005 | bisection validity repair | **done** |
| 006 | `targets_from_polyline` | **done** |
| 007 | stage-1 end to end | **done** — 22 adapt tests |
| 008 | FAULTS regeneration + invariance | **done** |
| 009 | `targets_from_polygon` (stage 2) | **done** |
| 010 | rim taper | **done** |
| 011 | slanted-pillar fold detection | **done** |
| 012 | curved/faceted faults end to end | **done** |
| 013 | Norne via `build_topology` | **deferred** — `06-study-pr013.md`; three defects found, staged plan produced |
| 014 | `projected_topology` on slanted pillars | **done** — pillar-identity collapse |
| 015 | Norne benchmark | **done** — and it found two real bugs |

## 2. Objective — met?

**Stated:** minimise the distance of the selected points to the fault line, target 0.

| case | before | after | verdict |
|------|-------:|------:|---------|
| synthetic, `free` boundary | 40 m | **3.2e-09 m** | target reached exactly |
| synthetic, `slide` | 40 m | 2.03 m (94.9%) | outline preserved |
| interior fault, `pinned` + rings=1 | — | 98.8% closer | fixed boundary viable |
| Norne, real `m_east` fault | 14.48 m | **7.52 m** | 48.1% closer, zero folds |
| stage 2, dipping plane | — | **≤8e-09 m at every depth** | F5 exactness confirmed |

The hard constraint (D7 — no broken cells) held in **every** reported run.

## 3. Decisions honoured

All 24 decisions (ADR-001/002/003) are implemented, with three corrected by
measurement and recorded as such:

- **D6 → D15** smoothness became the *change* in differential coordinates, then the
  Dirichlet energy, then linear elasticity. Each change was forced by a measurement,
  not a preference.
- **D11** one residual per `(pillar, segment)` — later refined by consolidation once
  Norne showed the conflict floor.
- **F7** "single plane suffices for stage 1" was wrong: real pillars are slanted, so
  both planes are always checked.

## 4. Quality of the delivered result

```
cpg2python         ruff ✓  mypy ✓ (22 files)   402 passed   (baseline 277)
fault-projections  ruff ✓  mypy ✓ (16 files)   144 passed   (baseline  88)
```

Cell quality, 12×12 grid with a kinked diagonal fault:

| operator | cells below SJ 0.3 | non-orth p95 |
|----------|-------------------:|-------------:|
| Laplacian (first working version) | 16 | 72.8° |
| elastic | 5 | 65.7° |
| elastic + 2 stiffness iterations | **2** | **54.6°** |

## 5. Defects found in the host libraries — 9

Not planned work; found while building and each verified by measurement.

| # | Defect | Where | Evidence |
|---|--------|-------|----------|
| 1 | int64 csgraph indices rejected by scipy | cpg `graph.py` | 6 tests failed on scipy 1.14 |
| 2 | same bug, separate CSR | fp `graph.py` | 7 failed + 4 errors |
| 3 | `is_vertical` used a relative tolerance | cpg `pillars.py` | 469 "vertical" pillars vs true 7 |
| 4 | biharmonic smoothness, near-singular | cpg `morph.py` | 577 m displacements for 13.5% gain |
| 5 | fold test missed single-corner inversion | cpg `validity.py` | "0 folds" with SJ −0.23 |
| 6 | separation checked only adjacent pillars | cpg `validity.py` | 3.1 m gaps on a 100 m grid |
| 7 | elastic stiffness unnormalised (`\|detJ\|`) | cpg `morph.py` | same `w` over-smoothed by ~1e4 |
| 8 | plan view silently wrong on tilted pillars | cpg `planview.py` | 245 nodes where 49 expected |
| 9 | `build_topology` bypasses fault-aware finders | cpg `unstructured.py` | 12 vs 14, 24 vs 27 faces — **silent** |

Defects 8 and 9 are the significant ones: both produce **wrong answers without
raising**, and both had been present long before this project.

## 6. Where the project's own claims were wrong

Recorded because the corrections are the useful part.

- **"94.9% closer"** was reported from a synthetic grid before Norne. The field model
  gave 13.1% until three separate bugs were fixed. Synthetic grids hid a conditioning
  bug, a scaling bug and a target-conflict ceiling.
- **PR-013 estimated L, then XL, then S+S.** The XL estimate would have funded a
  ragged-face rewrite for a problem a routing change likely solves.
- **The FAULTS face-set invariance oracle** was claimed to hold generally. It holds
  only for small moves; it fires exactly when the feature works best.
- **`depth_crossings` was expected to be redundant** with the two-plane test.
  Measurement showed a reversed edge need not flip its column's signed area, so it is
  load-bearing.

## 7. Outstanding

| item | owner | note |
|------|-------|------|
| merge cpg #38, cpg #39, fp #1 | **owner** | all CI-green; #39 is large and warrants review |
| PR-013 Step A | owner decision | study complete, staged plan ready |
| quality options 2–3 (post-smoothing) | optional | iterated stiffness already delivered |
| `stiffness_power > 1` folds silently | documented | noted as a trap in `docs/mesh-morphing.md` |

## 8. Verdict

The feature is **delivered and works**, on a real field model as well as synthetics,
with the hard validity constraint never violated. Documentation (`docs/mesh-morphing.md`)
covers method, every control, and the traps.

The honest caveat: fidelity and cell quality trade against each other, and the defaults
lean toward quality. That is a modelling choice, exposed and reversible, not a hidden
one.
