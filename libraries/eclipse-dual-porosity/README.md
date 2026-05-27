---
name: eclipse-dual-porosity-library
description: Deep study library on Eclipse 2025.4 dual-porosity and dual-permeability modeling — physics, math, keywords, gaps, and self-exam
metadata:
  type: library
  created: 2026-05-22
  owner: arturcastiel
  scope: ECL 2025.4 manuals + literature triangulation
---

# Eclipse 2025.4 — Dual Porosity / Dual Permeability Study Library

> Goal: Understand DP/DK *deeply* — math, keywords, implementation, when to use each,
> what is approximated, what is exact, and where my knowledge stops. Library is structured
> so a future session (or another engineer) can pick up and continue.

## Why this library exists
- ECL DP/DK modeling is foundational for naturally fractured reservoirs (carbonate, shale, CBM).
- Most users learn keywords by example but skip the math and the implicit assumptions.
- Production decisions (waterflood, gas injection, gravity drainage) depend on understanding which mechanism dominates and which keyword controls it.

## Scope (what is in / out)
- IN: DUALPORO, DUALPERM, NMATRIX (discretized matrix / multi-porosity Eclipse 300), all matrix-fracture transfer keywords (SIGMA family, LTOSIGMA, GRAVDR/GRAVDRM, INTPC, DPKRMOD), block-to-block (BTOBALFA/V), partial fracturing (DPNUM).
- IN: Mathematical formulation — Kazemi shape factor, Quandalle-Sabathier gravity drainage, viscous displacement (Gilman-Kazemi), integrated capillary pressure.
- IN: Recovery mechanisms — expansion, imbibition, gravity drainage, diffusion, viscous displacement.
- IN: Implementation — Z-doubling rule, fracture permeability multiplier semantics (NODPPM), linear solver structure.
- OUT (separate library later): Multi-porosity > 2 (TRPLPORO/NMATRIX > 1), single-medium conductive fractures (SCFDIMS), Shale Gas adsorption model, CBM (CBMOPTS).

## Deliverables (this folder)
```
README.md                            ← you are here
sources/                             ← raw text pulled from PDFs
  td-ch-dual-porosity.txt            ← TD pp.100-124
  td-ch-dual-porosity-part2.txt      ← TD pp.125-131
  td-ch-multi-porosity.txt           ← TD pp.132-138 (adjacent, useful context)
  refman-keywords.txt                ← Reference Manual keyword anchor pages
notes/                               ← my own synthesized notes
  01-overview.md                     ← what DP/DK is and why
  02-math-transfer-function.md       ← Eq.2.54 onwards, Kazemi sigma
  03-recovery-mechanisms.md          ← expansion / imbibition / gravity / diffusion / viscous
  04-gravity-drainage-models.md      ← GRAVDR vs GRAVDRM vs VERTICAL discretized
  05-discretized-matrix.md           ← Russian-doll model (Eclipse 100) + multi-porosity (E300)
  06-dual-permeability-vs-dp.md      ← what changes when DUALPERM replaces DUALPORO
  07-numerical-implementation.md     ← Nested factorization, Jacobian structure
  08-special-options.md              ← INTPC, DPKRMOD, BTOBALFA, NODPPM, VISCD, DIFFDP
  math-model.tex                     ← full 1-to-1 LaTeX mathematical model (every TD eq.)
  math-model.pdf                     ← compiled PDF (9 pages)
keywords/
  index.md                           ← every keyword: section, mandatory/optional, syntax, example, gotchas
  decision-matrix.md                 ← "I want to model X → which keywords do I need?"
gaps/
  knowledge-gaps.md                  ← what I don't know yet (igap-style)
  questions-to-ask.md                ← phrased questions, ranked by importance
exam/
  self-test.md                       ← questions I should be able to answer
  self-test-answers.md               ← my own answers + confidence
online-research/
  references.md                      ← Warren-Root, Kazemi, Quandalle-Sabathier, Gilman-Kazemi
  modern-papers.md                   ← shape factor improvements, MINC, Lim-Aziz
```

## How to use this library
1. New to DP/DK? → `notes/01-overview.md` then `notes/02-math-transfer-function.md`.
2. Building a deck? → `keywords/decision-matrix.md` then `keywords/index.md`.
3. Debugging recovery profile? → `notes/03-recovery-mechanisms.md` + `notes/04-gravity-drainage-models.md`.
4. Reviewing my own understanding? → `exam/self-test.md` (close the file; answer; then check).
5. Onboarding someone else? → README + overview + decision-matrix.

## Status of this library
- Sources extracted: ✓ (33 keywords + full TD chapter)
- First-pass synthesis: in progress
- Cross-validation with literature: pending
- Self-exam written and answered: pending
- Confidence to deploy a real DP/DK study: 60% (will be ≥85% when gaps closed)

[[eclipse-dp-mathematics]] · [[eclipse-dp-keywords]] · [[eclipse-dp-gaps]]
