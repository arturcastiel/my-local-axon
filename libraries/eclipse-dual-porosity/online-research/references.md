# Literature foundations of Eclipse DP/DK

> Annotated bibliography of the papers Eclipse's DP/DK model is built on,
> and what each one actually contributes. Cross-referenced to TD sections.

---

## Tier 1 — foundational

### Warren, J.E. & Root, P.J. (1963). "The Behavior of Naturally Fractured Reservoirs". SPEJ Sept 1963, 245–255 (SPE-426-PA).
**Contribution**: The original dual-porosity concept. Two interconnected porous systems (matrix and fracture). Matrix has high storage / low permeability; fracture has low storage / high permeability. Wells produce from the fracture; matrix feeds the fracture via a *quasi-steady-state* transfer rate proportional to pressure difference, governed by a *shape factor* α (often written σ).

Warren-Root proposed α = π² for a 1D slab geometry — *different* from Kazemi's later 4·(1/lx²+...). Their formulation was for pressure-transient analysis (well tests), not full numerical simulation.

**What Eclipse inherits**: the two-cells-per-block representation. The shape factor concept.

**What Eclipse changes**: uses Kazemi's coefficient instead of Warren-Root's.

### Kazemi, H., Merrill, L.S., Porterfield, K.L. & Zeman, P.R. (1976). "Numerical Simulation of Water-Oil Flow in Naturally Fractured Reservoirs". SPEJ Dec 1976, 317–326 (SPE-5719-PA).
**Contribution**: Extended Warren-Root to a *fully discretized numerical simulator* including saturation tracking and water-oil capillary imbibition. Proposed:
```
σ = 4·(1/lx² + 1/ly² + 1/lz²)
```
The factor of 4 comes from a 1D analytical solution to the linearised pressure-diffusion equation in a slab.

**What Eclipse inherits**: the *exact* sigma formula (TD Eq. 2.55). The default σ formula in Eclipse SIGMA / SIGMAV is Kazemi's. The dual-porosity decomposition Eclipse uses is essentially Kazemi's 1976 framework.

**Notes**: Kazemi et al. published a follow-up empirical transfer function in 1992 (SPE-25415); Eclipse still uses the 1976 derivation as the base. See also Kazemi-Gilman-Elsharkawy generalized shape factor — Heinemann & Mittermeir (2012) gave a rigorous derivation.

### Gilman, J.R. & Kazemi, H. (1988). "Improved Calculations for Viscous and Gravity Displacement in Matrix Blocks in Dual-Porosity Simulators". JPT Jan 1988, 60–70 (SPE-16010-PA).
**Contribution**: Added two missing pieces to the 1976 framework:
1. **Viscous displacement** — when the fracture has a real pressure gradient, the matrix can be swept laterally, not just drained from a uniform fracture pressure. This is the basis for the modified upwinding in TD Eq. 2.77.
2. **Gravity displacement** — better treatment of gravity-driven flow within a matrix block, especially relevant in oil-wet zones.

**What Eclipse inherits**: the VISCD option implements Gilman-Kazemi's viscous-displacement formulation (TD pp.110-112, Eqs. 2.72-2.78). The matrix-block dimensions LX/LY/LZ are needed exactly because the formulation needs the *physical* block size to compute the modified-upwinding term.

### Quandalle, P. & Sabathier, J.C. (1989). "Typical Features of a Multipurpose Reservoir Simulator". SPE Reservoir Engineering, 4(4), 475–480.
**Contribution**: Proposed an alternative gravity-drainage formulation that *decomposes* matrix-fracture flow into three components — horizontal, vertical up, vertical down — each with its own transmissibility. The horizontal flow uses one sigma (capillary-dominated); the verticals use another (gravity-dominated).

**What Eclipse inherits**: the `GRAVDRM` keyword implements Quandalle-Sabathier (TD pp.107-109, Eqs. 2.68-2.71).

**Notes**: This addresses a real limitation of GRAVDR — a single sigma cannot capture the speed difference between capillary imbibition (fast, three-directional) and gravity drainage (slow, mostly vertical).

### Pruess, K. & Narasimhan, T.N. (1985). "A Practical Method for Modeling Fluid and Heat Flow in Fractured Porous Media". SPEJ Feb 1985, 14–26 (SPE-10509-PA).
**Contribution**: The **MINC** (Multiple Interacting Continua) framework. Instead of two cells (matrix + fracture), the matrix is subdivided into N nested sub-cells, each at a successively greater distance from the fracture. Transient pressure-diffusion within the matrix is then resolved.

**What Eclipse inherits**: the `NMATRIX` keyword + `NMATOPTS` (LINEAR/RADIAL/SPHERICAL geometries) is Eclipse's implementation of MINC for petroleum reservoirs (TD pp.125-127, Eclipse 100 "discretized matrix" / Eclipse 300 "multi porosity").

**Important difference**: MINC uses an *integral finite difference* method with no analytical approximation for matrix-fracture coupling; Eclipse uses the SIGMA-based Kazemi transmissibility but with sub-cell decomposition. Geometrically similar, mathematically slightly different.

---

## Tier 2 — improvements and verification

### Lim, K.T. & Aziz, K. (1995). "Matrix-Fracture Transfer Shape Factors for Dual-Porosity Simulators". J. Petroleum Sci. & Eng., 13(3–6), 169–178.
**Contribution**: Derived analytical shape factors *without* the quasi-steady-state assumption, by solving the matrix pressure-diffusion equation directly. Showed that:
- The Warren-Root shape factor (π² for 1D) corresponds to a *late-time* analytical solution.
- Kazemi's σ = 4·(1/L²) underestimates early-time transfer.
- For multiple fracture sets, the analytical formula generalises to:
  ```
  σ = π² (n_x/lx² + n_y/ly² + n_z/lz²)
  ```
  where n_x is the number of fracture *sets* in the X direction (1 for fully-bounded blocks).

**Practical implication**: Eclipse's SIGMA defaults to Kazemi's value (factor 4). If you want Warren-Root–Lim-Aziz values, multiply by π²/4 ≈ 2.47. This is a *factor of 2.5 difference in matrix-fracture transfer rate*.

### Heinemann, Z.E. & Mittermeir, G.M. (2012). "Derivation of the Kazemi–Gilman–Elsharkawy Generalized Dual Porosity Shape Factor". Transport in Porous Media, 91(1), 123–132.
**Contribution**: Rigorous derivation of the generalised shape factor for irregular matrix blocks. Confirms Kazemi's formula for rectangular and cylindrical blocks and extends it. Useful when matrix blocks are not the idealised cubes/cuboids of the original Kazemi work.

### Coats, K.H. (1989). "Implicit Compositional Simulation of Single-Porosity and Dual-Porosity Reservoirs". SPE Symposium on Reservoir Simulation, SPE-18427-MS.
**Contribution**: Compositional DP/DK formulation, used the shape factor σ = 8/L² for cubic blocks (different from Kazemi's 4·3/L² = 12/L²). This is the "Coats shape factor".

**Practical implication**: Different vendors use different defaults; you must know which your simulator uses. Eclipse uses Kazemi.

---

## Tier 3 — modern advances

### Sabathier-style "SubFace" transfer functions (de Swaan, Penuela, others, ~2009)
Improve on Quandalle-Sabathier by tracking saturations *on each face* of the matrix block independently. Not in Eclipse.

### Fractal / scale-dependent shape factors (2020+)
Shape factor is *not* a constant — it evolves as fluid penetrates the matrix. Various authors propose σ(t) or σ(S). Not in Eclipse standard model; can be approximated by DPKRMOD tuning.

### Embedded discrete fracture networks (EDFM)
Alternative to DP/DK: explicitly mesh dominant fractures, leave the rest as upscaled matrix. Not Eclipse's approach but increasingly common in shale work. Eclipse has CONDFRAC / SCFDIMS for *single-medium conductive fractures* — a partial alternative.

---

## Lineage chart

```
1963: Warren & Root  (analytical, well-test, π² shape factor)
   │
1976: Kazemi et al.  (numerical, water-oil, σ = 4·Σ 1/L²)              ← Eclipse SIGMA
   │
1985: Pruess & Narasimhan  (MINC — nested matrix sub-cells)            ← Eclipse NMATRIX
   │
1988: Gilman & Kazemi  (viscous + gravity displacement)                ← Eclipse VISCD
   │
1989: Quandalle & Sabathier  (3-component gravity drainage)            ← Eclipse GRAVDRM
   │
1989: Coats  (compositional DP/DK, σ = 8/L²)
   │
1995: Lim & Aziz  (analytical σ derivation, π² recovery)
   │
2012+: Heinemann-Mittermeir, fractal σ(t), EDFM
```

Eclipse 2025.4 implements the 1976–1989 generation as the standard model, with optional pieces from the 1985 MINC line (NMATRIX) and the Gilman-Kazemi viscous displacement.

---

## Practical implication for confidence

When the manual says "Kazemi (1976) has proposed the following form for σ":
- This is the *one specific choice* among at least 4 (Warren-Root π², Kazemi 4, Coats 8, Lim-Aziz π²·n_set)
- The factor of 4 is *not* a fundamental constant; it's a specific model assumption
- History matching σ is *expected* — the literature is unanimous that the constant prefactor is uncertain at the field scale

Practical rule: **never report σ to better than ±50% precision without an analytical or experimental justification**. The Kazemi default is a *starting point*, not a measurement.

---

## Sources
- Warren & Root paper context: [Warren and Root (1963) dual-porosity reservoir model](https://www.researchgate.net/figure/Warren-and-Root-1963-dual-porosity-reservoir-model_fig4_257668678)
- Kazemi 1976 generalisation: [Derivation of the Kazemi–Gilman–Elsharkawy Generalized Dual Porosity Shape Factor](https://link.springer.com/article/10.1007/s11242-011-9836-4)
- Shape-factor comparisons: [Matrix-fracture transfer shape factors for dual-porosity simulators](https://www.sciencedirect.com/science/article/pii/092041059500010F) (Lim & Aziz 1995)
- Quandalle-Sabathier and follow-ups: [An Improvement on Modeling of Forced Gravity Drainage in Dual Porosity Simulations](https://link.springer.com/article/10.1007/s11242-012-9999-7)
- MINC framework: [A Practical Method for Modeling Fluid and Heat Flow in Fractured Porous Media](https://onepetro.org/spejournal/article-abstract/25/01/14/72392/A-Practical-Method-for-Modeling-Fluid-and-Heat?redirectedFrom=fulltext) (Pruess & Narasimhan 1985)
- Gilman-Kazemi review context: [Simulation of Naturally Fractured Reservoirs. State of the Art - Part 1 – Physical Mechanisms and Simulator Formulation](https://ogst.ifpenergiesnouvelles.fr/articles/ogst/ref/2010/02/ogst08103/ogst08103.html)
- Review of shape factors and CBM context: [Analysis and Verification of Dual Porosity and CBM Shape Factors](https://www.academia.edu/76985974/Analysis_and_Verification_of_Dual_Porosity_and_CBM_Shape_Factors)
- Fractal/modern shape-factor view: [Fractal analysis of shape factor for matrix-fracture transfer function in fractured reservoirs](https://ogst.ifpenergiesnouvelles.fr/articles/ogst/full_html/2020/01/ogst200049/ogst200049.html)
- Verification reference: [Verification and Proper Use of Water-Oil Transfer Function for Dual-Porosity](https://inside.mines.edu/~hkazemi/Courses/620A/HW/1/Paper1_Verification%20and%20Proper%20Use%20of%20Water%20Oil%20Transfer%20Function%20for%20Dual-Porosity%20and%20Dual-Permeability%20Reservoirs.pdf)
- General review: [Gravity Drainage Mechanism in Naturally Fractured Carbonate Reservoirs; Review and Application](https://www.mdpi.com/1996-1073/12/19/3699)
