# DP/DK keyword decision matrix
> "I want to model X → which keywords do I need?"
> Stop hunting through the manual. Look up your scenario, get the deck recipe.

---

## Minimal DP deck (waterflood, water-wet, capillary imbibition)
```
RUNSPEC
  DUALPORO
GRID
  ...DX DY DZ... for matrix layers, then fracture layers (or use DPGRID)
  ...PERMX PERMY PERMZ... for matrix layers, then fracture layers
  ...PORO... for both
  SIGMA   0.12 /
PROPS
  -- two SATNUM tables: one for matrix (with Pc), one for fracture (Pc=0)
  ...
REGIONS
  SATNUM ...    matrix → table 1, fracture → table 2
SCHEDULE
  COMPDAT  -- wells in fracture layers only
```

## Add gravity drainage (gas cap or gas injection)
Add to RUNSPEC: `GRAVDR` (or `GRAVDRM` if mixed wettability or fine-grid match needs separate horizontal/vertical sigmas).
Add to GRID: `DZMTRX  <matrix-block-height> /`.
Optionally add: `SIGMAGD  <different-sigma-for-gas-drainage> /` (E100 switches, E300 interpolates).
Optionally add to PROPS: `INTPC BOTH /` to match final recovery of an equivalent continuous matrix.

## Mixed wettability / oil-wet zones
- Use GRAVDRM instead of GRAVDR
- Consider re-infiltration = NO: `GRAVDRM NO /`
- Use SIGMA (horizontal) and SIGMAGD (vertical) independently

## Partial fracturing (some regions single porosity)
- Stay with DUALPORO (not DUALPERM — DPNUM forbidden there)
- Add `DPNUM` in GRID: 0 for single-porosity cells, 1 for DP cells

## Need matrix-matrix flow (or wells perforated in matrix)
- Switch RUNSPEC `DUALPORO` → `DUALPERM`
- COMPDAT can now reference matrix layer K-indices
- No DPNUM, no NMATRIX, no GRAVDRB

## Need transient inside matrix (well test, tight rock)
- Add `NMATRIX 6 /` (or 4, 8 — try a few) in RUNSPEC
- Add `NMATOPTS LINEAR 0.1 /` (or RADIAL/SPHERICAL) in GRID
- For E100: NDIVIZ stays even (matrix + fracture only); sub-cells are internal
- For E300: NDIVIZ must be a multiple of (NMATRIX+1)
- Cannot use DUALPERM, GRAVDR, GRAVDRM, LGRs, or parallel

## Need vertical saturation profile in tall matrix blocks
- Add `NMATRIX 6 /` + `NMATOPTS VERTICAL 0.1 /` + `GRAVDRB /` in RUNSPEC
- Add `DZMTRX  <tall-block-height> /` in GRID
- Cannot use DUALPERM, LGRs, parallel, GRAVDR, GRAVDRM

## Need viscous displacement (fracture pressure gradient sweeps matrix)
- Add `VISCD /` in RUNSPEC
- Add `LX`, `LY`, `LZ` arrays in GRID
- Add `LTOSIGMA 4.0 4.0 4.0 /` (or your coefficients) in GRID
- This will REPLACE any SIGMA(V) you've entered explicitly

## Compute SIGMA from physical block dimensions (per cell)
- Add `LX`, `LY`, `LZ` per-cell arrays in GRID
- Add `LTOSIGMA 4.0 4.0 4.0 /` in GRID
- Optional: 4th coefficient for SIGMAGD, 5th: XONLY|ALL transmissibility option

## Fracture perm: use input value directly (no φ multiplier)
- Add `NODPPM /` in GRID

## Block-to-block (lower matrix ↔ upper fracture)
- Add `BTOBALFA  <area-multiplier> /` in GRID (single value)
- OR `BTOBALFV` for per-cell area multipliers
- Activates the additional Tx
- Required when matrix block size ≈ grid cell size
- Not compatible with multi-porosity

## Match recovery curve shape to a single-porosity reference
- Add `DPKRMOD  mw  mg  YES /` in PROPS (per SATNUM table)
- mw, mg: tuning params in -1 to 1; iterate

## Different matrix-fracture flow Kr
- Add `KRNUMMF` in REGIONS to map cells to a dedicated kr table
- Imbibition equivalent: `IMBNUMMF`

## Adjust matrix-fracture coupling perm (E300 only)
- Add `PERMMF` in GRID (replaces default matrix X-perm for Tx)
- Add `MULTMF` for a multiplier on top
- Especially: 1D Y/Z global grid with X-extending LGR (otherwise default X-perm=0 → no Tx)

## Diffusion: matrix-fracture only (speed-up)
- Add `DIFFDP /` in RUNSPEC (DIFFUSE option must be active)
- Add `DIFFMMF` in GRID for per-cell diffusivity multipliers

---

## Common mistakes and how to spot them

| Symptom | Likely cause |
|---------|--------------|
| All matrix oil stays put, no production | σ defaulted to 0 (no SIGMA, no LTOSIGMA), or DZMTRX = 0 in gravity-drainage run |
| Fracture porosity error / unrealistic recovery | NODPPM missing — φ_frac multiplied your effective perms |
| Wells produce nothing | Wells perforated in matrix layers under DUALPORO (allowed only in DUALPERM or DPNUM single-porosity zones) |
| Massive initial fluid redistribution at t=0 with gravity drainage | Initialisation didn't account for gravity drainage; set OPTIONS item 11 to make initial solution true steady state |
| Final recovery depends on time-step or σ value (not physical) | GRAVDRM with re-infiltration = YES; try NO |
| Sub-cell quantities (BOSAT7) report nothing | NMATRIX not active, or ring number > NMATRIX |
| "X-permeability is zero" warning, DP NNCs missing | 1D global grid + LGR extending in X; need PERMMF |
| INTPC ignored | DUALPORO + GRAVDR/GRAVDRM not both active |
| "DPNUM forbidden" error | You set DUALPERM; can only use DPNUM with DUALPORO |
| Slow DK convergence | OPTIONS item 60 > 0 to fall back to pre-97A solver |

---

## Common combinations

| Use case | Keywords (minimal) |
|----------|--------------------|
| Naturally fractured carbonate, waterflood, water-wet | DUALPORO + SIGMA + 2 SATNUM tables |
| Same + gas cap | + GRAVDR + DZMTRX |
| Same + complex (mixed wettability) | + GRAVDRM (instead of GRAVDR) + DZMTRX + SIGMAGD |
| Partial fracturing | DUALPORO + SIGMA + DPNUM (mark dense regions as 0) |
| Heavily fractured (matrix has continuity) | DUALPERM + SIGMA (no DPNUM, no NMATRIX) |
| Well test in tight matrix | DUALPORO + SIGMA + NMATRIX + NMATOPTS RADIAL/SPHERICAL |
| Tall matrix block gravity drainage | DUALPORO + NMATRIX + NMATOPTS VERTICAL + GRAVDRB + DZMTRX |
| Tight oil with diffusion | DUALPORO + SIGMA + DIFFUSE + DIFFDP + DIFFMMF |
| CBM with instant adsorption (E300) | DUALPERM + CBMOPTS + SIGMA |
| CBM with time-dep adsorption (E300) | NMATRIX + multi-porosity (one sub-porosity is the conductive matrix) |

---

## Section-by-section quick reference
| Section | What goes here (DP/DK) |
|---------|------------------------|
| RUNSPEC | DUALPORO/DUALPERM, GRAVDR/GRAVDRM/GRAVDRB, NMATRIX, DIFFDP, VISCD |
| GRID    | SIGMA(V), SIGMAGD(V), MULTSIG(V), MULSGGD(V), LTOSIGMA, LX/LY/LZ, DZMTRX(V), NMATOPTS, DPGRID, DPNUM, NODPPM, PERMMF, MULTMF, BTOBALFA(V), DIFFMMF, ROCKSPLV |
| PROPS   | INTPC, DPKRMOD |
| REGIONS | KRNUMMF, IMBNUMMF, SATNUM (different per matrix/fracture) |
| SOLUTION | EQUIL is mandatory with NMATRIX |
| SCHEDULE | COMPDAT (wells in fracture cells only under DP; matrix OK under DK) |
