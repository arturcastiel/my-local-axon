# 03 — Transmissibility math: OLDTRAN, NEWTRAN, OLDTRANR, HALFTRAN, NNC formula

> Every Eclipse connection (face neighbour, NNC from fault, NNC from pinch-out, dual-porosity NNC) has a transmissibility computed by one of these formulas. Master these and the rest is just bookkeeping.

## The Darcy constant

```
CDARCY =  0.00852702  (E300, METRIC)   = 0.008527  (E100, METRIC)
       =  0.00112712  (E300, FIELD)    = 0.001127  (E100, FIELD)
       =  3.6         (LAB, both)
       =  0.00864     (PVT-M, both)
```

Units of TRANX/Y/Z: `cP·rm³/day/bars` (METRIC), `cP·rb/day/psi` (FIELD), `cP·rcc/hr/atm` (LAB).

## Symbols recap

| Symbol | Meaning |
|--------|---------|
| `i`, `j` | two cells being connected |
| `A` | mutual interface area between the cells |
| `B` | sum of half-cell flow resistance terms (1/permeability × length) |
| `DIPC` | dip correction factor (horizontal vs vertical separation) |
| `RNTG` | net-to-gross ratio (PERMX/PERMY transmissibility only; PERMZ is unaffected) |
| `TMLT` | transmissibility multiplier (MULTX/MULTY/MULTZ + MULTFLT product) |
| `DX_i`, `DY_i`, `DZ_i` | cell dimensions |

## OLDTRAN (block-centred default for DX/DY/DZ grids)

X-direction transmissibility between cell `i` and its neighbour `j` to the +X side:

```
                 CDARCY · TMLTX_i · A · DIPC
TRANX_i  =  ─────────────────────────────────                                (TD Eq. 2.1)
                          B
```

with
```
        DX_i · DY_j · DZ_j · RNTG_j + DX_j · DY_i · DZ_i · RNTG_i
A  =  ──────────────────────────────────────────────────────────             (TD Eq. 2.2)
                              DX_i + DX_j
```
```
        DX_i / PERMX_i  +  DX_j / PERMX_j
B  =  ─────────────────────────────────                                       (TD Eq. 2.3)
                       2
```
```
                DHS
DIPC  =  ───────────────────                                                  (TD Eq. 2.4)
            DHS + DVS

DHS = ((DX_i + DX_j) / 2)²
DVS = (DEPTH_j − DEPTH_i)²
```

Z-direction transmissibility (no dip correction, no RNTG):
```
                CDARCY · TMLTZ_i · A
TRANZ_i  =  ─────────────────────────                                         (TD Eq. 2.5)
                       B
```
```
        DZ_i · DX_j · DY_j + DZ_j · DX_i · DY_i
A  =  ─────────────────────────────────────────                               (TD Eq. 2.6)
                  DZ_i + DZ_j
```
```
        DZ_i / PERMZ_i  +  DZ_j / PERMZ_j
B  =  ────────────────────────────────                                        (TD Eq. 2.7)
                      2
```

Y-direction is analogous to X with permuted indices.

## OLDTRANR (alternative block-centred, different A/B combination)

```
                CDARCY · TMLTX_i · DIPC
TRANX_i  =  ─────────────────────────                                         (TD Eq. 2.8)
                       B
```

with
```
        DX_i                       DX_j
B  =  ─────────────  +  ─────────────                                         (TD Eq. 2.9)
        A_i · PERMX_i      A_j · PERMX_j
            2                         2
```
where `A_i = DY_i · DZ_i · NTG_i` and `A_j = DY_j · DZ_j · NTG_j`.

Difference from OLDTRAN: the cross-sectional area is on a per-cell basis (computed from each cell's own DY·DZ·NTG), not averaged across the face. **Tends to behave better when cell sizes vary across the face.**

Z-direction:
```
                CDARCY · TMLTZ_i
TRANZ_i  =  ─────────────────                                                 (TD Eq. 2.11)
                    B
```
with the same per-cell-area form (Eq. 2.12).

## NEWTRAN (corner-point default — the workhorse)

This is the formula that handles **fault NNCs**. It uses *true* geometric projections from corner-point geometry.

```
                            CDARCY · TMLTX_i
TRANX_ij  =  ─────────────────────────────────                                (TD Eq. 2.13)
                  1/T_i  +  1/T_j
```

where
```
                                A · D_i
T_i  =  PERMX_i · RNTG_i · ───────────────
                                D_i · D_i
```
with
```
A · D_i  =  A_x · DX_i + A_y · DY_i + A_z · DZ_i
D_i · D_i  =  DX_i² + DY_i² + DZ_i²
```

Here:
- `A_x, A_y, A_z` are the **X-, Y-, Z-projections of the mutual interface area** between cells i and j. For a regular face neighbour with axis-aligned cells, two of these are zero. For an NNC across a fault with a tilted overlap, all three may be nonzero.
- `DX_i, DY_i, DZ_i` are the **X-, Y-, Z-components of the vector from cell i's centre to the centre of the relevant face**. Not the cell side lengths! These are face-centre offsets.

**Why this works for NNCs**: the formula doesn't assume cells are axis-aligned neighbours. Given the overlap area projections and the vector to the face centre, it computes the harmonic-mean transmissibility between any two cells that share *some* interface, even if they're geometrically offset.

The dot product `A · D_i / (D_i · D_i)` is essentially a *dip-corrected, projected* area. For axis-aligned faces it reduces to the simple area / centre-distance form.

## HALFTRAN (Eclipse 100 — six permeabilities per cell)

Lets you specify *six* effective half-block permeabilities per cell (`Kx_left, Kx_right, Ky_back, Ky_front, Kz_top, Kz_bot`) — useful for upscaling from a fine geocellular model with directional permeability heterogeneity.

In NEWTRAN form, the half-block X-direction transmissibilities are:
```
T_il  =  K_xil · RNTG_i · (A · D_i)/(D_i · D_i)                               (TD Eq. 2.14)
T_ir  =  K_xir · RNTG_i · (A · D_i)/(D_i · D_i)                               (TD Eq. 2.15)
```

With HALFTRAN active, you set `MULTX = K_xir / PERMX` and `MULTX- = K_xil / PERMX`, then enter PERMX as normal. Internally Eclipse multiplies through to recover the six per-cell K values. Requires `GRIDOPTS YES` in RUNSPEC to enable MULTX- etc.

Typical workflow: FloGrid or a custom upscaler computes the six values, writes MULTX/MULTX-/MULTY/MULTY-/MULTZ/MULTZ- arrays, the deck enables HALFTRAN.

## Radial transmissibility (DR/DTHETA/DZ grids)

For radial grids:
```
                       CDARCY · TMLTR_i · DIPC
TRANR_i  =  ────────────────────────────                                       (TD Eq. 2.16)
                  1/T_i  +  1/T_j
```

with pressure-equivalent-radius formulas for T_i, T_j (TD p.39).

Less common in practice; reserve for near-wellbore radial sub-grids.

## NNC transmissibility — same formula, different interface

When Eclipse builds an NNC from corner-point geometry (fault), it uses **the same NEWTRAN formula (Eq. 2.13)** with `A_x, A_y, A_z` being the projections of the *partial* overlap area between the two cells.

For an NNC defined manually with the `NNC` keyword, the user enters Tx directly (item 7) and Eclipse skips the geometric calculation. Optionally:
- Item 16: area `A`
- Item 17: linking permeability `K`

then Eclipse back-computes the half-cell distances (RM p.1467):
```
DX_i  +  DX_j  =  (2 · A · K) / T                                             (RM Eq. derived)
```
splitting the harmonic mean evenly. The back-computed distances are used in non-Darcy flow (`VDFLOW`) only.

## Dual-porosity matrix-fracture transmissibility (different formula!)

For DP/DK σ-NNCs:
```
T_mf  =  CDARCY · σ · K · V                                                   (TD Eq. 2.54)
```
This is NOT the NEWTRAN formula. It uses:
- σ: shape factor (1/L², from SIGMA or LTOSIGMA)
- K: matrix X-perm by default (override via PERMMF, E300)
- V: matrix cell bulk volume (no porosity factor)

See `../../eclipse-dual-porosity/notes/02-math-transfer-function.md` for the full derivation.

## Composing transmissibility multipliers

For a single connection between cells i and j across face F, the final Tx is:
```
T_final  =  T_base × MULT_face_i × MULT_face_j × MULTFLT × MULTREGT × multipliers_from_EDITNNC
```
where:
- `T_base` is the geometric Tx from NEWTRAN/OLDTRAN
- `MULT_face_i`, `MULT_face_j` come from MULTX/Y/Z applied to cells i and j (TMLT in TD equations)
- `MULTFLT` applies if the face is on a named fault
- `MULTREGT` applies if cells i and j are in different MULTNUM regions and an inter-region multiplier is defined
- `EDITNNC` is a final per-NNC multiplier (or `EDITNNCR` replaces outright)

Order of operations matters when MULTFLT and MULTX are both set on the same face: they multiply (per RM p.1387 MULTFLT note 3). If you want one to override the other, use TRANX/Y/Z keywords in EDIT — these *replace* the Tx and bypass MULTFLT for face Tx (but MULTFLT in EDIT still applies to NNCs across the fault, per the same note).

## Dip correction `DIPC`

Used in OLDTRAN and OLDTRANR for X and Y directions (not Z). Formula (TD Eq. 2.4 / 2.10):
```
            DHS
DIPC = ────────────────
       DHS + DVS

DHS = ((DX_i + DX_j) / 2)²       horizontal-separation-squared between centres
DVS = (DEPTH_j − DEPTH_i)²       vertical-separation-squared
```

For a horizontal layer, DVS = 0 → DIPC = 1. For a steeply dipping layer, DIPC < 1, reducing the effective Tx. Captures the projection of the flow path onto the horizontal axis.

NEWTRAN doesn't need DIPC because the corner-point geometry already includes the true dip information in the cell-to-face-centre vectors.

## Cheat sheet: which formula is used

| Grid input | Default Tx | When? |
|------------|------------|-------|
| `DX`/`DY`/`DZ`/`TOPS` | OLDTRAN | E100 default for block-centred |
| `DX`/`DY`/`DZ`/`TOPS` + `OLDTRANR` | OLDTRANR | When per-cell areas matter (varying NTG) |
| `COORD`/`ZCORN` | NEWTRAN | E100 + E300 default for corner-point |
| `COORD`/`ZCORN` + `HALFTRAN` | HALFTRAN (NEWTRAN-based) | When per-cell directional perms are upscaled |
| `DR`/`DTHETA`/`DZ` | Radial Tx | Radial grids only |

> **Recommended**: NEWTRAN with COORD/ZCORN for real models. The other modes exist for legacy or special cases.

## Equations to remember by heart

For Newton-style debugging:
1. **Eq. 2.54** (DP): `T_mf = CDARCY · σ · K · V`
2. **Eq. 2.13** (NEWTRAN): `T_ij = CDARCY · TMLT / (1/T_i + 1/T_j)` with `T_i = K · RNTG · (A·D)/(D·D)`
3. **Eq. 2.1** (OLDTRAN X): `TRANX_i = CDARCY · TMLT · A · DIPC / B`

If a connection's Tx looks wrong by an order of magnitude, work through these formulas with actual values from the .PRT — usually the issue is RNTG, MULT, or an unintended NEWTRAN/OLDTRAN mismatch.
