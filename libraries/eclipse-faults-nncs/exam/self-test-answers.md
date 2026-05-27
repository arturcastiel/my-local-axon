# Self-exam answers — Faults & NNCs

> Confidence 1–5. Items below 3 → consult `gaps/knowledge-gaps.md`.

## Section 1 — Geometry

**1.** `COORD` (pillar lines — top and bottom 3D points per pillar) + `ZCORN` (Z-coordinates of all 8 corners of every cell). **[5]**

**2.** `ZCORN`. Adjacent column cells along a shared pillar can have different Z values → that's the fault throw. `FAULTS` is just a label; `MULTFLT` is just a multiplier. **[5]**

**3.** OLDTRAN: block-centred, uses cell-centre separations and averaged face areas. NEWTRAN: corner-point, uses true overlap areas and face-centre offsets. Default with COORD/ZCORN: NEWTRAN. Default with DX/DY/DZ: OLDTRAN. **[5]**

**4.** NEWTRAN assumes corner-point geometry. With DX/DY/DZ, Eclipse fabricates flat axis-aligned blocks. Adjacent columns' flat blocks then overlap each other (because they share top edges but Eclipse can't infer the real geometry) → many spurious fault NNCs are created. **[4]**

**5.** HALFTRAN allows six effective half-cell permeabilities per cell (one per face): K_xl, K_xr, K_yl, K_yr, K_zl, K_zr. Provides finer directional upscaling. Activated via the HALFTRAN keyword (E100) plus MULTX-/Y-/Z- arrays (requires GRIDOPTS YES). **[4]**

**6.** `NUMRES n` reserves space for n distinct pillar systems (`COORD` blocks). For stitching together regional + sub-region grids with independent geometries. Used with `COORDSYS` to assign K-layers to each system. **[3]**

**7.** Six values per pillar: `(X_top, Y_top, Z_top, X_bot, Y_bot, Z_bot)` — defining the top and bottom points of the tilted/vertical pillar line. Total array: `6·(NX+1)·(NY+1)` values. **[5]**

**8.** Shale gap: an unmodelled but real layer (handled with MULTZ-). Pinchout: a layer that *locally* has zero or near-zero thickness (handled with PINCH and PINCHNUM, possibly bridging via NNCs). Conceptually similar but distinguished by the geometry input — in a shale gap, the Z layers stay separated; in a pinchout, cell Z corners collapse to the same depth. **[3]**

## Section 2 — NNC mechanics

**9.** (i) Corner-point fault offsets, (ii) pinchout bridges (PINCH), (iii) LGR boundary, (iv) numerical aquifers, (v) dual porosity/permeability matrix-fracture coupling. Plus user-defined via `NNC` keyword. **[5]**

**10.** No — at the solver level all connections look the same: pairs of (cell_i, cell_j, transmissibility, ...). "Non-neighbour" is a label about indexing, not about the physics. **[5]**

**11.** When an entire intervening layer is inactive (deactivated), Eclipse merges the bridging NNC back into a regular face connection. RM p.1468. Stops being a separate row in the connection list. **[4]**

**12.** 1e-6 (silently dropped). 1e-20 (warning + dropped). **[5]**

**13.** Tx < 1e-6 → NNC silently dropped from the connection list. Can't be re-enabled by later EDITNNC (because there's nothing to edit). Use 1e-4 instead — keeps the connection in the solver. **[5]**

**14.** No. RM p.724 — "It is not possible to edit dual porosity NNCs using this keyword." Use `SIGMAV` for per-cell σ or `MULTSIGV` for a per-cell multiplier. **[5]**

**15.** No. EDITNNC cannot reach NNCs inside an LGR. Use MULTX/Y/Z or MULTREGT instead. **[4]**

**16.** The Tx values add — the second entry doesn't replace, it adds (RM p.1468). This is a common cause of subtle material-balance issues from duplicated decks. **[4]**

## Section 3 — Transmissibility math

**17.** TD Eq. 2.13:
```
TRANX_ij = CDARCY · TMLTX / (1/T_i + 1/T_j)

T_i = PERMX_i · RNTG_i · (A · D_i)/(D_i · D_i)
```
Where:
- A_x, A_y, A_z are X/Y/Z projections of the mutual interface area
- DX_i, DY_i, DZ_i are X/Y/Z components from cell-i centre to face centre
- (A · D_i) = A_x·DX_i + A_y·DY_i + A_z·DZ_i (dot product)
- TMLTX = transmissibility multiplier
**[4]**

**18.** DIPC = DHS / (DHS + DVS), where DHS is horizontal separation squared and DVS is vertical separation squared. Used in OLDTRAN and OLDTRANR for X and Y directions (not Z). NEWTRAN doesn't need it because corner-point geometry encodes dip implicitly. **[4]**

**19.** Net-to-gross is a horizontal-flow correction (only some fraction of the cell carries fluid laterally — the "net" sand within "gross" thickness). Vertical flow is between layer interfaces, which are taken as the whole face. So PERMZ × full area is the right Z transmissibility ingredient; multiplying by NTG would double-count. **[4]**

**20.** DP σ-NNC: `T_mf = CDARCY · σ · K · V` (TD Eq. 2.54). Uses shape factor σ (1/L²), matrix K, bulk volume V. NEWTRAN: `T_ij = CDARCY · TMLT / (1/T_i + 1/T_j)` (TD Eq. 2.13). Uses harmonic mean of two cells' half-transmissibilities; geometric, requires overlap area projections. **[5]**

**21.** 100 × 0.001 = 0.1. Tx is multiplied; same units. **[5]**

**22.** Multiplicative composition: T_final = T_base × MULT_face_i × MULT_face_j × MULTFLT × MULTREGT × any EDITNNC multipliers. MULTREGT applies only between cells in different MULTNUM regions; EDITNNC applies only to NNCs. **[4]**

**23.** Required: first 7 items (IX, IY, IZ, JX, JY, JZ, TRAN). Optional: saturation table numbers, pressure table numbers, VE faces, DIFF (for DIFFUSE), thermal Tx (E300 THERMAL), area + linking permeability (for VDFLOW). **[4]**

**24.** NNCGEN allows specifying the *grid* for each cell (GLOBAL, LGR name) — for NNCs between two different grids (e.g. LGR-to-parent or LGR-to-LGR). NNC is implicit GLOBAL. E300 only. **[4]**

## Section 4 — Workflow

**25.**
```
RUNSPEC
  FAULTDIM  5 /
GRID
  ... COORD, ZCORN ...
  FAULTS
    'F1'  10 10  1 50  1 10  X /
  /
  MULTFLT
    'F1'  1e-4 /        -- strongly sealing
  /
```
**[5]**

**26.** All 8 K-layers (K=1..8). Under DUALPERM, matrix has lateral flow, so the matrix layers (K=1..4) must also be sealed — not just the fracture layers (K=5..8). **[5]**

**27.**
```
FAULTS
  'F_NS_1'  ... /
  'F_NS_2'  ... /
  'F_NS_3'  ... /
/
MULTFLT
  'F_NS*'  0.001 /    -- all matching faults
/
```
**[4]**

**28.** MULTFLT can appear in GRID, EDIT, or SCHEDULE.
- GRID: modifies the MULTX/Y/Z arrays plus NNC Tx along the fault, before the simulation starts
- EDIT: post-GRID multiplier; cumulative with GRID-section MULTFLT
- SCHEDULE: time-step level; cumulative — applies every time the keyword is encountered
**[4]**

**29.** MULTREGT applies between two MULTNUM (or FLUXNUM) *regions*, not along a single named fault. Use when:
- The barrier doesn't follow a single fault face
- You have a categorical division (zones, compartments, lithologies)
- You want to control connections by region type rather than spatial location
**[4]**

**30.** In SCHEDULE:
```
TSTEP 10*50 /        -- get to ~500 days
MULTFLT
  'F_main'  100 /     -- multiplies current Tx by 100
/
```
The effect is cumulative, so this scales whatever the current effective multiplier is. **[4]**

**31.** `NNC` keyword in GRID:
```
NNC
  i1 j1 k1   i2 j2 k2   <Tx_value> /
/
```
Or for high transmissibility through a damage zone, use a Tx significantly larger than the underlying single-porosity Tx. **[5]**

**32.** E300 ordering: MULTFLT in GRID applied first → EDITNNC multiplier applied → then EDITNNCR replaces outright. So the final Tx equals the EDITNNCR value, regardless of MULTFLT and EDITNNC. (E100 differs — EDITNNCR happens first, then MULTFLT, then EDITNNC.) **[3]** (uncertain on exact ordering; check `notes/02` and `gaps/`).

## Section 5 — Debugging

**33.**
```
RPTGRID
  FAULTS  ALLNNC  TRANX  TRANY  TRANZ  MULTX  MULTY  MULTZ  /
```
Optionally add `PORO`, `PERMX/Y/Z`, `NTG` for full context. **[5]**

**34.** Grep for "Number of non-neighbor connections" or "Non-Neighbor Connections" (case insensitive). **[4]**

**35.** Eclipse merges an NNC back into a regular face connection (because the path is geometrically equivalent — e.g. an entire intervening layer is inactive). The NNC stops being a separate row in the connection list. Visible only via the ALLNNC report under "IN-LINE CELLS" (E100) or "Removed non-neighbor connections (inline)" (E300). **[4]**

**36.** (a) The NNC was inlined back into a regular face connection → EDITNNC can't find it. (b) The NNC's Tx was below 1e-6 and was silently dropped. (c) The NNC was never created (e.g., between inactive cells, or the geometric overlap calc didn't produce one). (d) It's a DP σ-NNC (not editable by EDITNNC). (e) Wrong cell coords. **[4]**

**37.** The FAULTS K-range. Under DUALPERM, matrix flow is real. If only fracture layers (K = NDIVIZ/2+1 .. NDIVIZ) are covered, matrix-matrix flow still crosses the fault. Solution: extend K range to cover the entire NDIVIZ. **[5]**

**38.** NEWTRAN was used with DX/DY/DZ input. Eclipse fabricates flat blocks that don't quite align between columns → many spurious low-Tx NNCs. Solution: switch to OLDTRAN, or supply real COORD/ZCORN. **[4]**

**39.** Print MULTX/Y/Z arrays with `RPTGRID` (verify multipliers on each side of the fault). For dynamic MULTFLT, add `RPTSCHED MULT` to the SCHEDULE section. For NNC Tx, use `RPTRST FLOWS` to see actual inter-cell flows in the restart file. **[4]**

**40.** `RPTRST FLOWS` — outputs per-step phase flows across every connection. Combined with a visualisation tool, lets you see leak paths through faults or unintended bypasses. **[4]**

## Stretch — open-ended

**A. Deck:**
```
RUNSPEC
  TITLE
   '30x30x10 faulted carbonate' /
  DIMENS  30 30 10 /
  FAULTDIM  5 /
  OIL WATER GAS DISGAS

GRID
  ... COORD, ZCORN from preprocessor ...
  ... PORO, PERMX/Y/Z arrays ...
  
  FAULTS
    'F_seal'   15 15   1 30   1 10  X /
    'F_leak'    1 30  20 20   1 10  Y /
  /
  MULTFLT
    'F_seal'  1e-4 /
    'F_leak'  0.2  /
  /
  
  NNC
    5 5 5   7 5 5   1500.0 /         -- bypass channel
  /

EDIT
  EDITNNC
    -- specific tweak from history match
    15 15 3   16 15 3   2.5 /
  /

PROPS / REGIONS / SOLUTION / SCHEDULE ...
```

**B. Diagnostic: "Sealing fault not sealing in DUALPERM" — six checks in order:**

1. **K-range coverage**: Does FAULTS cover all NDIVIZ layers (both matrix and fracture halves)? Most common mistake.
2. **MULTFLT actually applied**: Print `RPTGRID FAULTS MULTX MULTY MULTZ` — verify the multiplier appears on the fault face.
3. **Section ordering**: Is MULTFLT in EDIT being overridden by TRANX/Y/Z placed after it? Reorder.
4. **NNC dropout**: If MULTFLT < 1e-6 (multiplied with a small base Tx), the NNC may have been dropped. Check `RPTGRID ALLNNC` for the count.
5. **Geometry mismatch**: Are there really NNCs along the fault face? `RPTGRID ALLNNC` should show them. If absent, the corner-point geometry doesn't have the offset you expect — re-check ZCORN.
6. **σ-NNCs unaffected**: MULTFLT doesn't touch σ-coupling. If the fault crosses the *fracture* network within a DP grid, that's separately controlled by SIGMA/SIGMAV/MULTSIG — but σ-NNCs are in-place, not lateral, so MULTFLT really shouldn't be the right tool there. If you're sealing DP coupling, use MULTSIGV.

**C. Why EDITNNC can't touch DP σ-NNCs:**
DP σ-NNCs are computed from the Kazemi formula `T = CDARCY · σ · K · V`, where σ comes from the SIGMA/SIGMAV/LTOSIGMA keywords. Allowing EDITNNC to modify the resulting Tx would create an inconsistency: the same matrix-fracture coupling could be modified through two independent channels (σ-controlled or Tx-controlled), with no clear precedence. Eclipse instead defines a clean single-source-of-truth: σ-controlled. To modify the coupling, modify σ via SIGMAV (per-cell shape factor) or MULTSIGV (per-cell multiplier on σ). These are the supported and consistent way to tune matrix-fracture transfer.
