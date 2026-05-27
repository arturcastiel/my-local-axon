# Modern research directions (2010+)

> Beyond the Eclipse standard model: where does the academic literature go,
> and which improvements might motivate future Eclipse features?

---

## 1. Shape-factor improvements

### Heinemann & Mittermeir (2012)
"Derivation of the Kazemi-Gilman-Elsharkawy Generalized Dual Porosity Shape Factor"
Transport in Porous Media, 91(1), 123–132.

Rigorous derivation of σ for irregular blocks. Confirms Kazemi's formula for rectangular blocks; extends it to irregular shapes by summing over the actual matrix-block surfaces. Useful if you have fracture-network geometric data showing non-cuboidal blocks.

### Fractal shape factors (2020+)
Sun & Lu (2020): "Fractal analysis of shape factor for matrix-fracture transfer function in fractured reservoirs" — argues σ should be a function of time as fluid penetrates the matrix. Not implementable in standard Eclipse but motivates the use of DPKRMOD as a time-varying tuner.

### Sub-face transfer functions
Penuela, Idem, Wattenbarger (2009) "SubFace Matrix-Fracture Transfer Function: Improved Model of Gravity Drainage/Imbibition." Track saturation on each face of the matrix block independently. More accurate gravity drainage in mixed-wettability systems. Not in Eclipse.

---

## 2. Embedded Discrete Fracture Networks (EDFM)

Alternative philosophy to DP/DK. Idea: discrete fractures (the dominant ones) are mesh-embedded as 1D line elements or 2D triangles, with transmissibilities computed analytically to the host matrix cells. Background matrix uses upscaled effective properties.

Strength: captures the *connectivity* of an actual fracture network (which DP/DK averages away). Weakness: gridding overhead, harder to integrate with reservoir-engineering workflows.

Eclipse partial alternative: CONDFRAC + SCFDIMS — single-medium conductive fractures (van Lingen et al. 2001). Not full EDFM but addresses the same problem class (fractures too large to homogenize). Documented in TD pp.129-131.

---

## 3. Multi-porosity for unconventionals

For shale and tight gas, two porosities aren't enough. Coal-bed methane needs:
- Bulk matrix (storage)
- Micro-cleats (intermediate transport)
- Macro-cleats / fractures (high-perm conduit)

In Eclipse: NMATRIX > 1 (with multi-porosity framework, E300) or TRPLPORO (triple porosity).

Recent work explores:
- *Continuous* multi-porosity (N → ∞, effectively MINC)
- *Adaptive* sub-cell sizing (Pruess et al. 2020s)

---

## 4. Coupled geomechanics

Pressure changes deform fractures, changing σ and fracture permeability. Coupled flow + geomechanics is a major area. Eclipse has rock-compaction tables (ROCK, ROCKCOMP) that approximate this in 1D pressure; full coupling requires VISAGE or a coupled toolchain.

For DP/DK specifically: the questions of "how does σ evolve as fractures close under depletion?" and "how does PERMX_frac depend on effective stress?" are open in production code. Standard practice: history-match σ(t) approximately via MULTSIGV per region per time step.

---

## 5. Verification benchmarks

Several SPE community benchmarks for DP/DK simulators exist:
- Kazemi single-block benchmark (canonical test case)
- SPE10 dual-porosity (variation on SPE10 single-porosity test)
- Single-block gravity drainage (Sonier et al.)

Modern papers using these as verification cases:
- Pourafshary, Gerami, Yousefi-Sahzabi (2019) — review of transfer functions including Eclipse comparison
- Lemonnier & Bourbiaux (2010) — "Simulation of Naturally Fractured Reservoirs. State of the Art - Part 1 – Physical Mechanisms and Simulator Formulation," OGST IFPEN

---

## 6. Practical history-matching of σ

### Range of values from field studies
From the modern literature (extracted from various review papers):
- Carbonate reefs: σ_eff often 0.01–1.0 ft⁻² (corresponding to 2–20 ft blocks)
- Naturally fractured sandstone: 0.001–0.1 ft⁻² (larger blocks)
- Shale: 1–100 ft⁻² (sub-foot blocks)
- CBM: similar to shale

Tuning multiplier MULTSIG typically falls in 0.5–2.0 — beyond 5× is a red flag that something else is wrong.

---

## 7. Where the field is going

Three threads:
1. **More porosities** — multi-porosity > 2 becoming standard for unconventionals
2. **Discrete fracture representation** — EDFM and friends, gradually replacing pure DP for shale
3. **Coupled physics** — geomechanics, thermal, geochemistry — DP/DK is the *flow* layer of a larger stack

Eclipse 2025.4's DP/DK model is mature: the 1976–1989 generation. The newer features (CONDFRAC, multi-porosity > 2, etc.) bring it closer to current research but the core σ-based formulation is unchanged.

---

## Reading list (next-step prioritisation)

Highest ROI:
1. **Kazemi 1976 SPE-5719-PA** — read the original to understand the factor of 4
2. **Lim & Aziz 1995** — see how the "right" coefficient compares
3. **Quandalle & Sabathier 1989** — understand what GRAVDRM is doing
4. **Lemonnier & Bourbiaux 2010 (OGST)** — modern review tying it all together

Lower priority but worth it:
5. **Gilman & Kazemi 1988** — for the VISCD derivation
6. **Pruess & Narasimhan 1985** — for MINC
7. **Coats 1989** — for compositional DP/DK and the σ = 8/L² alternative

Background:
8. **Warren & Root 1963** — historical context, π² shape factor for well tests
9. **Heinemann & Mittermeir 2012** — modern shape-factor rigour
