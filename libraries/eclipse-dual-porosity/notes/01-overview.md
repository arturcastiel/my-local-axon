# 01 — Overview: What is Dual Porosity / Dual Permeability?

## The physical problem
Naturally fractured reservoirs (most carbonates, some sandstones, all shales/CBM) are *bimodal*:
- **Matrix**: high storage (bulk pore volume), low permeability. Holds the hydrocarbons.
- **Fractures**: low storage (small volume), high permeability. Provides the flow paths to wells.

Treating the two as a single homogenized medium gives wrong recovery curves — the matrix-fracture transfer is a *time-lagged* coupling, not an instantaneous one. So we explicitly carry two cells per geometric block.

## Eclipse's representation
For each block in the geometric grid, Eclipse instantiates **two simulation cells**:
1. The matrix cell  → holds bulk pore volume, low k, contains most of the oil
2. The fracture cell → small pore volume, high k, where wells connect

These two cells live in the same physical location but are stored as separate grid layers. **The trick: `NDIVIZ` (number of Z layers, `DIMENS` item 3) must be even — the first half are matrix layers, the second half are fracture layers.**

If NMATRIX > 1 (Eclipse 300 multi-porosity), the rule generalises to NDIVIZ/N. In Eclipse 100's "Russian doll" discretized matrix the sub-cells are internal and NDIVIZ stays at 2.

## Two regimes — DP vs DK

| | DUALPORO (DP) | DUALPERM (DK) |
|---|---------------|----------------|
| Matrix ↔ Fracture coupling | YES (NNC, auto-built) | YES |
| Matrix ↔ Matrix flow | **NO** (matrix blocks isolated; A is diagonal) | **YES** (matrix has normal Tx between neighbours) |
| Wells connect to | fracture cells only (unless DPNUM region) | matrix *and* fracture |
| Linear solve | sequential (Schur complement, halves problem) | simultaneous, paired 6×6 Jacobian blocks |
| Cost | cheaper | more expensive |
| Physical use case | well-developed fracture network sweeps the matrix from outside | partial fracturing, matrix continuity matters, CBM with adsorption |

> Key insight (TD p.100): "If matrix blocks are linked only through the fracture system, this is dual-porosity, single-permeability. If neighboring matrix blocks can communicate, it's dual-porosity, dual-permeability."

DK is *not* a different physical model — it is DP + matrix-matrix transmissibilities turned on. Numerically the Jacobian structure changes (no Schur complement reduction), hence the cost.

## Why "dual permeability" is a misnomer
DUALPERM doesn't mean two permeabilities are used; it means *both* matrix and fracture have flow connections. The matrix already had a permeability under DUALPORO — it just had no neighbours to flow into. So "dual permeability" really means "matrix has flow paths too, in addition to fracture flow." Better mental name: *"matrix flow enabled."*

## How matrix-fracture coupling is built
Eclipse auto-generates an NNC (non-neighbour connection) between every matrix cell and its overlying fracture cell. The transmissibility of that NNC is:

```
TR = CDARCY · σ · K · V        (Eq. 2.54)
```
- `σ` — shape factor, dimensions of 1/L² — `SIGMA` or `SIGMAV` keyword
- `K` — matrix X-direction permeability by default (override: `PERMMF`)
- `V` — matrix cell bulk volume (NOT pore volume — no porosity factor here)
- `CDARCY` — Darcy unit conversion

The shape factor `σ` is the single most important DP knob: it sets *how fast* the matrix drains into the fracture. Kazemi (1976) proposed:

```
σ = 4 (1/lx² + 1/ly² + 1/lz²)
```
where `lx`, `ly`, `lz` are *physical matrix-block dimensions*, NOT simulation cell sizes. A 10-ft cube of matrix gives σ ≈ 0.12 ft⁻². Practically `σ` is often a history-match parameter — Kazemi's formula gives a starting value.

Alternative: `LTOSIGMA` + `LX`/`LY`/`LZ` lets Eclipse compute σ from input block dimensions on a per-cell basis. Required for the viscous displacement option (`VISCD`).

## Z-doubling rule (every input keyword in the GRID section must follow this)
- Layers 1 ... NDIVIZ/2 → matrix
- Layers NDIVIZ/2+1 ... NDIVIZ → fracture
- For most input arrays (DX, DY, DZ, PORO, PERMX...), set values for matrix layers, then again for fracture layers
- `DPGRID` keyword lets you skip the fracture values — Eclipse copies matrix → fracture
- For cell-by-cell GRID inputs (e.g. SIGMAV, DZMTRXV), values are required ONLY in the first NDIVIZ/2 layers; fracture half is ignored

This rule is the single biggest source of beginner mistakes. Print the grid (`RPTGRID`) to verify your matrix and fracture properties are where you think they are.

## Where each keyword section sits
| Section | DP/DK keywords |
|---------|---------------|
| RUNSPEC | DUALPORO, DUALPERM, GRAVDR, GRAVDRM, GRAVDRB, NMATRIX, DIFFDP, VISCD |
| GRID    | SIGMA(V), SIGMAGD(V), MULTSIG(V), MULSGGD(V), LTOSIGMA, LX/LY/LZ, DZMTRX(V), NMATOPTS, DPGRID, DPNUM, NODPPM, PERMMF, MULTMF, BTOBALFA(V), DIFFMMF, ROCKSPLV |
| PROPS   | INTPC, DPKRMOD |
| REGIONS | KRNUMMF, IMBNUMMF |

If you put SIGMA in RUNSPEC the parser will complain; if you put DUALPORO in GRID, ditto. Section discipline matters.

## Restrictions that catch people out (DP single-permeability case)
- Wells connect to fracture cells only (exception: DPNUM single-porosity region)
- Manual NNCs cannot involve matrix cells
- Every active matrix cell MUST connect to an active fracture cell

DUALPERM relaxes the first restriction (wells can target matrix) but the others stay.

## Reading order from here
1. `02-math-transfer-function.md` — the equations behind σ and the transfer integral
2. `03-recovery-mechanisms.md` — what physical processes produce oil from a matrix block
3. `04-gravity-drainage-models.md` — when GRAVDR is enough, when you need GRAVDRM
4. `05-discretized-matrix.md` — when steady-state matrix-fracture is wrong (e.g. well-test)
5. `06-dual-permeability-vs-dp.md` — the structural difference
6. `07-numerical-implementation.md` — how the linear solver exploits the structure
7. `08-special-options.md` — INTPC, DPKRMOD, BTOBALFA, NODPPM, VISCD, DIFFDP
