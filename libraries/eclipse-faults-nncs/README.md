---
name: eclipse-faults-nncs-library
description: Deep-study library on Eclipse 2025.4 fault representation and non-neighbour connections (NNCs) — geometry, transmissibility math, keyword workflows
metadata:
  type: library
  created: 2026-05-23
  owner: arturcastiel
  scope: ECL 2025.4 manuals + classical reservoir-engineering practice
sibling: eclipse-dual-porosity
---

# Eclipse 2025.4 — Faults & Non-Neighbour Connections (NNCs)

## Why this library
Faults and NNCs are the connective tissue of any non-trivial Eclipse model. Mis-handle them and you get
silently wrong production (a sealing fault that isn't, a leaky fault that should seal, an NNC that
got dropped because TR < 1e-6). This library is the deep-dive companion to `eclipse-dual-porosity`.

## Conceptual map — three scales of "fracture" in Eclipse

| Scale | Eclipse representation | Library |
|-------|------------------------|---------|
| Pervasive fracture network (mm-cm, thousands per cell) | DP/DK continuum — every cell has a fracture cell | `eclipse-dual-porosity/` |
| Discrete large fractures (m-scale, individually mappable) | `CONDFRAC` + `SCFDIMS` (single-medium conductive fractures) | TD pp.129-131 (covered briefly in DP library) |
| Faults (displacement discontinuities, geometric features) | Corner-point `ZCORN` offsets + `FAULTS` + `MULTFLT` | **THIS library** |

## Scope (this library)
- IN: How Eclipse builds the grid geometry (`COORD`/`ZCORN`/corner-point) and where fault offsets come from
- IN: How NNCs are auto-generated (faults, pinchouts, LGRs, numerical aquifers, DP coupling)
- IN: Transmissibility formulas (OLDTRAN, NEWTRAN, OLDTRANR, HALFTRAN, the corner-point overlap calc)
- IN: User-facing fault/NNC keywords: FAULTS, FAULTDIM, MULTFLT, MULTX/Y/Z, MULTREGT, NNC, NNCGEN, EDITNNC, EDITNNCR, GRIDOPTS, PINCH family, MINPV family
- IN: Sealing-vs-leaky-fault workflows and history-matching practice
- IN: Cross-reference to DP/DK: how σ-NNCs coexist with fault NNCs (see `notes/05-cross-reference-dp.md`)
- OUT: Local grid refinement details (`CARFIN`/`RADFIN`) — a separate library
- OUT: Numerical aquifer transmissibilities (`AQUNUM`/`AQUCON`) — separate library

## Deliverables
```
README.md                              ← you are here
sources/                               ← raw text from PDFs
  refman-keywords.txt                  ← 30 keyword pages from Reference Manual
  td-transmissibility.txt              ← TD pp.33-51 (transmissibility calcs)
notes/                                 ← synthesised notes
  01-corner-point-grids.md             ← COORD/ZCORN, pillars, fault throw
  02-nnc-mechanics.md                  ← auto-generation rules, inlining, lifecycle
  03-transmissibility-math.md          ← OLDTRAN, NEWTRAN, OLDTRANR, HALFTRAN, NNC formula
  04-fault-workflows.md                ← FAULTS+MULTFLT recipes (sealing, leaky, time-varying)
  05-cross-reference-dp.md             ← how DP σ-NNCs interact with fault NNCs
  06-debugging-nncs.md                 ← RPTGRID FAULTS / ALLNNC, .PRT inspection
  math-model.tex / .pdf                ← 1-to-1 LaTeX with TD Eq. 2.1-2.16
keywords/
  index.md                             ← every keyword with section, syntax, defaults, gotchas
  decision-matrix.md                   ← "I want X → use these keywords"
gaps/
  knowledge-gaps.md                    ← unresolved questions (igap-style)
  questions-to-ask.md                  ← ranked questions for a senior reservoir engineer
exam/
  self-test.md / self-test-answers.md  ← self-assessment
online-research/
  references.md                        ← Hearn 1969, Coats, Heinemann (corner-point standards)
```

## Reading order
1. `notes/01-corner-point-grids.md` — understand where the geometry comes from
2. `notes/02-nnc-mechanics.md` — what an NNC is, when Eclipse builds one
3. `notes/03-transmissibility-math.md` — equations, with NEWTRAN as primary
4. `notes/04-fault-workflows.md` — practical sealing/leaky recipes
5. `notes/05-cross-reference-dp.md` — only if you also work with DP/DK
6. `notes/06-debugging-nncs.md` — for when something goes wrong

[[eclipse-dual-porosity-library]]
