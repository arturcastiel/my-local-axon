# Eclipse 2025.4 — Faults & NNCs keyword reference

> Every keyword that touches fault representation or non-neighbour connections.
> Section, syntax, defaults, gotchas. Source: Eclipse Reference Manual (RM) with page citations.

## Section legend
RS=RUNSPEC · G=GRID · E=EDIT · P=PROPS · R=REGIONS · SO=SOLUTION · SU=SUMMARY · SC=SCHEDULE

---

# Grid input

## COORD
- **Section**: G · **E100**: ✓ · **E300**: ✓ · **RM p.558**
- **Purpose**: Define pillar lines (top + bottom point of each pillar) for corner-point geometry.
- **Data**: `6·(NX+1)·(NY+1)` values: `(X_top, Y_top, Z_top, X_bot, Y_bot, Z_bot)` per pillar.
- **Side effect**: Triggers NEWTRAN transmissibility by default.
- **Companion**: `ZCORN` (required).

## COORDSYS
- **Section**: G · Defines which COORD pillar system applies to which K-layers (multi-region grids).
- **Use when**: `NUMRES > 1` is set in RUNSPEC.

## ZCORN
- **Section**: G · **E100**: ✓ · **E300**: ✓ · **RM p.2843**
- **Purpose**: Z-coordinates of all 8 corners of every cell. Where fault throw is encoded.
- **Data**: `8·NX·NY·NZ` values.
- **Note**: Top of cell K and bottom of cell K-1 are stored separately; mismatches encode pinchouts/shale gaps/faults along column boundaries.

## NUMRES
- **Section**: RS · **RM p.1503**
- **Purpose**: Reserve space for n distinct pillar systems (for cross-region grid stitching).
- **Data**: 1 integer.
- **Default**: 1.

---

# Transmissibility scheme

## NEWTRAN
- **Section**: G · **E100**: ✓ · **RM p.1453**
- **Purpose**: Activate corner-point transmissibility calc (the default with COORD/ZCORN).
- **Data**: none.
- **Use case**: any real model.

## OLDTRAN
- **Section**: G · **E100**: ✓ · **RM p.1532**
- **Purpose**: Activate block-centred transmissibility calc (the default with DX/DY/DZ).
- **Data**: none.
- **Notes**: Don't combine with COORD/ZCORN — produces spurious NNCs.

## OLDTRANR
- **Section**: G · **E100**: ✓ · **RM p.1533**
- **Purpose**: Alternative block-centred with per-cell areas (rather than face-averaged).
- **Use when**: varying NTG across faces would mis-estimate cross-section.

## HALFTRAN
- **Section**: G · **E100**: ✓ · **RM p.1080**
- **Purpose**: Allow six half-cell permeabilities per cell (one per face), enabling fine directional upscaling.
- **Companion**: `GRIDOPTS YES` to enable MULTX-/MULTY-/MULTZ- keywords used by HALFTRAN.

## GRIDOPTS
- **Section**: RS · **E100**: ✓ · **E300**: ✓ · **RM p.1006**
- **Purpose**: Enable additional grid options.
- **Data items**:
  1. `YES | NO` — enable MULTX-/MULTY-/MULTZ- and DIFFMX-/Y-/Z- keywords (default NO)
  2. `NRMULT` — number of MULTNUM regions (default 0; for MULTREGT/MULTREGP)
  3. `NRPINC` — number of PINCHNUM regions (E300, default 0)

---

# Fault definition

## FAULTDIM
- **Section**: RS · **E100**: ✓ · **E300**: ✓ · **RM p.812**
- **Purpose**: Reserve space for fault segments.
- **Data**: 1 integer (`MFSEGS` — max total segments across all FAULTS keywords).
- **Default**: 0.

## FAULTS
- **Section**: G · **E100**: ✓ · **E300**: ✓ · **RM p.813**
- **Purpose**: Label a set of cell faces as a named fault (for later MULTFLT editing).
- **Data**: any number of records, each with:
  1. Fault name (≤ 8 chars)
  2-3. IX1, IX2 (must be equal if face = X)
  4-5. IY1, IY2 (must be equal if face = Y)
  6-7. IZ1, IZ2 (must be equal if face = Z)
  8. Face: `X | Y | Z | I | J | K` (or `X-/Y-/Z-/I-/J-/K-` with GRIDOPTS YES)
- **Notes**:
  - Multiple FAULTS keywords accumulate up to FAULTDIM total
  - **FAULTS does NOT create geometry** — it just labels existing cell faces. Geometry must already be in COORD/ZCORN.
  - Output via `RPTGRID FAULTS`
- **Example**:
  ```
  FAULTS
   'F1'   1 1   1 50   1 8   X /
   'F2'   1 10  20 20   1 8   Y /
  /
  ```

---

# Fault transmissibility

## MULTFLT
- **Section**: G, E, SC · **E100**: ✓ · **E300**: ✓ · **RM p.1387**
- **Purpose**: Multiply transmissibilities across a named fault.
- **Data**: records of:
  1. Fault name (supports wildcard `'F*'`)
  2. Transmissibility multiplier (default 1.0)
  3. Diffusivity multiplier (default 1.0; only if DIFFUSE active)
- **Behaviour**:
  - GRID section: modifies the MULTX/Y/Z arrays along the fault, plus the NNCs
  - EDIT section: multiplies the resolved face Tx + NNC Tx
  - SCHEDULE section: cumulative — re-applies each time encountered
  - Last entry wins if same fault named twice in one MULTFLT
  - Two faults sharing a face → both multipliers applied
- **Gotchas**:
  - Does NOT touch DP σ-NNCs
  - With TRANX/Y/Z in EDIT placed AFTER MULTFLT, TRANX/Y/Z wins for face Tx (overrides MULTFLT)
  - With EDITNNCR: ordering differs between E100 and E300 (RM p.1388 note)
  - GSG-imported transmissibilities (TRANPORV via PETOPTS): MULTFLT in GRID is ignored, must be in EDIT

---

# Direction multipliers

## MULTX, MULTY, MULTZ
- **Section**: G, E · **E100**: ✓ · **E300**: ✓ · **RM pp.1422, 1426, 1430**
- **Purpose**: Per-cell multiplier on the transmissibility leaving that cell in +X, +Y, +Z direction.
- **Data**: one positive real per cell in the BOX.
- **Default**: 1.0.
- **Composes**: MULTX of cell i × MULTX of cell j × MULTFLT × MULTREGT → final face Tx multiplier.

## MULTX-, MULTY-, MULTZ-
- **Section**: G, E · Same as above but for -X, -Y, -Z faces.
- **Companion**: requires `GRIDOPTS YES` to enable.
- **Use when**: directional upscaling (HALFTRAN) needs different multipliers on opposite faces of the same cell.

## MULTREGT
- **Section**: G, E · **E100**: ✓ · **E300**: ✓ · **RM p.1414**
- **Purpose**: Multiplier between two `MULTNUM` (or `FLUXNUM`) regions.
- **Data**: records of:
  1. Source region
  2. Target region
  3. Multiplier
  4. Direction: `X | Y | Z | XYZ`
  5. NNC handling: `ALL | NONNC | NOAQUNNC` (default ALL)
  6. Region set: `M` (MULTNUM) or `F` (FLUXNUM)
- **Use when**: a categorical boundary that doesn't follow a single named fault.

## MULTREGP
- **Section**: G · Pore-volume multiplier between regions. Less commonly used.

---

# Explicit NNC definition

## NNC
- **Section**: G · **E100**: ✓ · **E300**: ✓ · **RM p.1466**
- **Purpose**: Define a new NNC between any two cells (or add Tx to an existing one).
- **Data items** (first 7 required):
  1-3. First cell IX, IY, IZ
  4-6. Second cell JX, JY, JZ
  7. TRAN (transmissibility; default 0; Tx < 1e-6 dropped, < 1e-20 warns and drops)
  8-9. E100: saturation table numbers (IST1, IST2). E300: deprecated, use 14/15
  10-11. Pressure table numbers (E100)
  12-13. VE faces (`X+|X-|Y+|Y-|Z+|Z-`, ZF1, ZF2) — only for VE option
  14. DIFF (diffusivity; for DIFFUSE / TRDIF)
  15. Thermal Tx (E300, THERMAL) or 1/(area·porosity) (E100, DISPERSE)
  16. Area (m² / ft² / cm²) — non-Darcy VDFLOW
  17. Linking permeability (mD) — non-Darcy VDFLOW
- **Behaviour**: between actual neighbours, the NNC Tx **adds** to the existing face Tx.

## NNCGEN
- **Section**: G · **E300**: ✓ · **RM p.1469**
- **Purpose**: NNC between any two grids (e.g. LGR ↔ parent, LGR ↔ another LGR).
- **Data**:
  1. Grid name of first cell (default GLOBAL)
  2-4. IX, IY, IZ
  5. Grid name of second cell
  6-8. JX, JY, JZ
  9. TRAN
  10. DIFF
  11. Thermal Tx

---

# NNC editing

## EDITNNC
- **Section**: E · **E100**: ✓ · **E300**: ✓ · **RM p.723**
- **Purpose**: Multiply an existing NNC's transmissibility.
- **Data items**:
  1-6. IX/IY/IZ + JX/JY/JZ (REQUIRED, cannot be defaulted)
  7. TRANM (multiplier; default 1.0; cannot be negative; can be 0)
  8-9. Saturation table numbers
  10-11. Pressure table numbers
  12-13. VE faces
  14. DIFFM (diffusivity multiplier)
- **Cannot edit**: DP σ-NNCs (RM p.724 — use SIGMAV)
- **LGRs**: cannot edit NNCs inside an LGR

## EDITNNCR
- **Section**: E · **E100**: ✓ · **E300**: ✓ · **RM p.725**
- **Purpose**: Replace an NNC's transmissibility outright.
- **Data items**:
  1-6. IX/IY/IZ + JX/JY/JZ (REQUIRED)
  7. TRANS (replacement value; REQUIRED)
  8-13. Optional table/face overrides
  14. DIFF replacement
- **Note**: E300 applies MULTFLT before EDITNNCR (EDITNNCR wins). E100 applies MULTFLT after EDITNNCR (MULTFLT wins). Avoid using both on the same NNC.

---

# Pinchouts and minimum pore volume

## PINCH
- **Section**: G · **E100**: ✓ · **E300**: ✓ · **RM p.1727**
- **Purpose**: Generate NNCs across pinched-out layers.
- **Data**:
  1. Threshold thickness (default 0.001 in all units)
  2. `GAP | NOGAP` — allow NNCs across MINPV-inactive cells beyond threshold (default GAP)
  3. Max empty gap allowed (default infinity)
  4. Tx calculation: `TOPBOT` (default) or `ALL` (harmonic average through all pinched-out cells)
  5. MULTZ accounting through pinched columns (TOPBOT mode only)

## PINCHNUM
- **Section**: G · Region-specific PINCH thresholds.

## PINCHOUT
- **Section**: G · Deactivate pinched-out cells.

## PINCHXY
- **Section**: G · Control of horizontal NNC generation across pinched-out neighbours.

## MINPV
- **Section**: G · Minimum pore volume for active cells. Below → deactivated.

## MINPVV
- **Section**: G · Per-cell minimum pore volume.

---

# Direct Tx specification

## TRANX, TRANY, TRANZ
- **Section**: E · **E100**: ✓ · **E300**: ✓ · **RM p.2354-2356**
- **Purpose**: Set the X/Y/Z direction transmissibility outgoing from each cell explicitly.
- **Use when**: importing pre-computed transmissibilities (e.g. from a GSG file).
- **Side effect**: Overrides the geometric Tx for that face. If placed AFTER MULTFLT in EDIT, MULTFLT is bypassed for face Tx (but NNCs still respect MULTFLT).

---

# Reporting

## RPTGRID (mnemonics)
- `FAULTS` — print the fault table
- `ALLNNC` — print every NNC including inlined and DP
- `NNC` — print only user-defined NNCs (no inlined, no DP)
- `MULTX, MULTY, MULTZ` — multiplier arrays
- `TRANX, TRANY, TRANZ` — computed face transmissibilities
- `PERMX, PERMY, PERMZ` — permeability arrays

## RPTSCHED
- `MULT` — current effective multipliers per cell

## RPTRST
- `FLOWS` — per-step flows across every connection
- `RFIP` — fluid in place by region

## DEBUG3 / DEBUG (E100)
- `DEBUG3` item 167 = 1 → print which EDITNNC records were applied as EDITNNCR equivalents

---

# Quick lookup table

| Task | Keywords (in order of section) |
|------|--------------------------------|
| Build a fault geometry | COORD, ZCORN (preprocessor output) |
| Label a fault for editing | FAULTDIM (RS), FAULTS (G) |
| Seal a fault | FAULTS + MULTFLT (G or E or SC) |
| Time-varying fault | MULTFLT in SCHEDULE (cumulative) |
| Region-to-region barrier | GRIDOPTS YES NR, MULTNUM, MULTREGT |
| Bypass channel (manual NNC) | NNC (G) |
| Cross-grid NNC | NNCGEN (G) |
| Multiply individual NNCs | EDITNNC (E) |
| Replace individual NNCs | EDITNNCR (E) |
| Per-cell multipliers | MULTX/Y/Z + MULTX-/Y-/Z- (with GRIDOPTS YES) |
| Direct Tx import | TRANX/Y/Z (E) |
| Pinchouts | PINCH (G) + PINCHNUM/PINCHXY for refinement |
| Diagnostics | RPTGRID FAULTS ALLNNC, RPTSCHED MULT, RPTRST FLOWS |
