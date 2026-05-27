# 05 — Discretized matrix ("Russian doll") and multi-porosity

## The motivation
Traditional dual-porosity assumes the matrix→fracture flow is in *quasi-steady state* — the matrix cell behaves as a single lumped reservoir at all times. This works when matrix-fracture timescales are short compared to the simulation timescale.

But for:
- Well tests (early-time transients matter)
- Tight matrix with slow internal pressure equilibration
- Capturing the saturation profile *inside* a matrix block during gravity drainage

…the single-cell matrix is wrong. We need to resolve the transient inside the matrix.

## The solution: nest sub-cells inside the matrix
Each simulation matrix cell is internally subdivided into N concentric sub-cells. The sub-cells communicate vertically with their neighbours; only the *outermost* sub-cell talks to the fracture (NMATOPTS != VERTICAL).

In E100 this is the "discretized matrix model" (Russian doll). In E300 it's part of the "multi-porosity" framework with the same NMATRIX keyword.

```
              ┌──────────────┐
              │   fracture   │
              │              │
              │  ┌─────────┐ │
              │  │  N=N    │ │   ← outermost sub-cell, connects to fracture
              │  │ ┌─────┐ │ │
              │  │ │ N=2 │ │ │
              │  │ │┌───┐│ │ │
              │  │ ││N=1││ │ │   ← innermost sub-cell, only sees N=2
              │  │ │└───┘│ │ │
              │  │ └─────┘ │ │
              │  └─────────┘ │
              └──────────────┘
```

## Activation
- `NMATRIX` in RUNSPEC sets N (number of sub-cells inside each matrix cell)
- `NMATOPTS` in GRID sets geometry: `LINEAR` (1D), `RADIAL` (2D cylindrical), `SPHERICAL` (3D), `UNIFORM` (E300 only — uniform sub-cell size), or `VERTICAL` (vertical-stack mode, for gravity drainage; requires GRAVDRB)
- Outer sub-cell size: NMATOPTS item 2 is the fraction of fracture pore volume (default 0.1) — controls how thin the outer sub-cell is
- E300: NMATOPTS item 3 chooses `FPORV` (size from fracture pore volume) or `MBLKV` (size from matrix block volume); FPORV is default

## How sub-cell sizes are computed (TD pp.125-127)
Let `V_n` be the volume of the nth sub-cell (n=1 outermost, n=N innermost). Let `V_T = Σ V_n` be total matrix region volume.

The growth factor `f` is set such that:
```
f = (X/X1)^(1/(N-1))     where X = matrix half-thickness, X1 = outer cell thickness
```

Sub-cell distances from the fracture grow logarithmically:
```
X_n = f^(n-1) · X1                  (TD p.127)
```

For LINEAR geometry, sub-cells are *slabs* parallel to the fracture; volumes scale linearly with `X`.
For RADIAL (cylindrical) and SPHERICAL, sub-cells are shells; volumes scale with shell formulas.

Transmissibilities between sub-cells use the interface area and the centre-to-centre distance. The original matrix-fracture Tx (from SIGMA) is scaled to the sub-cell-to-sub-cell connection by:
```
T_n = T · (A_n/A_T) · (2X / (X_n − X_{n-1}))            (TD p.127)
```

The outer sub-cell connects to the fracture with scale factor `2X/X1`.

## What this buys you
- Matches the early-time pressure transient (well test) accurately
- Captures intra-block saturation profile (when combined with VERTICAL option)
- Reports per-sub-cell quantities: BPR, BRS, BRV, BOSAT, BWSAT — append ring number: `BOSAT7` for sub-cell #7

## What it doesn't buy you
- Sub-cell properties can't be specified independently in E100; all sub-cells get the matrix cell's property (copy)
- In E300 multi-porosity you have more freedom, but it's still uncommon to vary properties per sub-cell

## Computational cost
Discretizing the matrix adds N matrix cells per original matrix cell. *Total* cell count grows.

But: the sub-cell equations form 1D tri-diagonal systems connected to the fracture only at the outer cell. The nested-factorization solver *eliminates the tri-diagonals before solving the fracture system*. So the actual incremental cost is much lower than naive N-fold cell scaling would suggest. Typical N: 4–8.

## Reporting (TD p.128)
Set the first 5 RPTSCHED data items to 2 → sub-cell solutions output as arrays over the simulation grid.

For time-series, use mnemonics with a ring number suffix:
```
BOSAT7
  1 1 2 /
/
```
→ oil saturation for sub-cell 7 of cell (1,1,2). Ring 1 = outer (next to fracture); higher rings move inward.

## Restrictions (E100 discretized matrix)
- Not with gravity drainage models GRAVDR or GRAVDRM (use VERTICAL option instead with GRAVDRB)
- Not with LGRs
- Not with the parallel solver
- Not with DUALPERM
- Must use EQUIL for initialisation (cannot explicitly initialise sub-matrix cells)

## E300 differences
- Uses the multi-porosity infrastructure
- DIMENS must include all porosities in Z (NZ multiple of NMATRIX+1)
- LINEAR, RADIAL, SPHERICAL geometries — same as E100
- Plus UNIFORM (uniform sub-cell sizes) and VERTICAL (gravity-drainage variant)
- Partitioning of bulk and pore volumes via FPORV or MBLKV (NMATOPTS item 3)
- Permeabilities default to copies of the primary matrix cell unless PERMMF is set
- Use ROCKFRAC + PORO inputs (not PORV) when switching between instant and time-dependent adsorption models

## VERTICAL option specifics (gravity drainage with discretized matrix)
- Activated by NMATOPTS VERTICAL + GRAVDRB in RUNSPEC
- All matrix sub-cells connect directly to the fracture (not just the outer one)
- Sub-cells are vertical stack inside the matrix block, total height = DZMTRX
- Fracture properties altered per-NNC to reflect the local gravitational potential at each sub-cell height
- Useful when DZ_matrix is large and the gravity-induced saturation profile inside the block matters

## Multi-porosity (E300, NMATRIX > 1 or TRPLPORO) — context
- N > 2 porosities — typically: bulk matrix + micro-fracture + macro-fracture
- Layers in DIMENS must be NZ multiple of N
- BTOBALFA / BTOBALFV not allowed
- DPNUM single-porosity regions not allowed
- TRPLPORO is a specific 3-porosity keyword used for triple-porosity (NMATRIX with value > 1 is the general N-porosity case)

This is beyond the scope of the current library — extract to a separate study if needed.

## Sanity checks
1. `RPTGRID` after first run: are the matrix sub-cells where you expect?
2. Compare to a finely-gridded single-porosity reference: does discretized DP recover the same transient?
3. Outer-cell size (NMATOPTS item 2): if it's too thick, you miss the early transient. If too thin, you waste sub-cells. 0.05–0.1 is typical.
4. Growth factor: max/min reported in PRT — large spread means uneven resolution.
