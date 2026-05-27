# Eclipse 2025.4 DP/DK keyword reference

> Every keyword that touches dual-porosity / dual-permeability modelling.
> Format per entry: section, purpose, syntax, defaults, gotchas, example.
> Source: Eclipse Reference Manual; anchor pages in `../sources/index.md`.

---

## Section legend
- **RS** = RUNSPEC · **G** = GRID · **E** = EDIT · **P** = PROPS · **R** = REGIONS · **SO** = SOLUTION · **SU** = SUMMARY · **SC** = SCHEDULE
- E100/E300 = simulator support

---

# RUNSPEC keywords (model selection)

## DUALPORO
- **Section**: RS · **E100**: ✓ · **E300**: ✓
- **Purpose**: Activates the dual-porosity model (matrix-fracture coupling, no matrix-matrix flow).
- **Data**: none.
- **Side effect**: Forces NDIVIZ (DIMENS item 3) to be even; first half = matrix, second half = fracture.
- **Companion required**: SIGMA / SIGMAV / LTOSIGMA in GRID.
- **Gotcha**: Without DUALPORO, all DP/DK keywords are ignored silently.

## DUALPERM
- **Section**: RS · **E100**: ✓ · **E300**: ✓
- **Purpose**: Activates dual-permeability. *Implicitly enables DUALPORO*; do not specify both.
- **Data**: none.
- **Effect**: Adds matrix-matrix transmissibilities. Wells can perforate matrix.
- **Solver**: Faster post-97A solver used by default. OPTIONS item 60 > 0 restores pre-97A solver.
- **Mutually incompatible with**: NMATRIX (discretized matrix), DPNUM (single-porosity regions), GRAVDRB.

## GRAVDR
- **Section**: RS · **E100**: ✓ · **E300**: ✓
- **Purpose**: Standard gravity drainage/imbibition between matrix and fracture.
- **Data**: none.
- **Companion required**: DZMTRX or DZMTRXV in GRID.
- **Behaviour**: Both matrix and fracture assumed in vertical equilibrium; gravity head encoded as pseudo Pc.

## GRAVDRM
- **Section**: RS · **E100**: ✓ · **E300**: ✓
- **Purpose**: Alternative gravity drainage (Quandalle-Sabathier 1989). Flow split into horizontal + vertical components.
- **Data**: 1 record: `Allow re-infiltration  YES | NO  /`
  - YES (default): oil can flow back into matrix
  - NO: oil only flows out (more predictable final recovery)
- **Companion required**: DZMTRX or DZMTRXV; SIGMAGD recommended.
- **Supersedes**: GRAVDR if both present.
- **Tip**: Try NO first. YES makes final recovery transmissibility-dependent.

## GRAVDRB
- **Section**: RS · **E100**: ✓ · **E300**: ✓
- **Purpose**: Vertical discretized gravity drainage. Matrix block split vertically into NMATRIX sub-cells, each connected to the fracture.
- **Data**: none.
- **Companion required**: NMATOPTS VERTICAL, NMATRIX, DZMTRX.
- **Restrictions**: Eclipse 100; DIMENS NX ≥ 2; not with LGRs, parallel, DK, or classical GRAVDR/M.
- **Init**: MUST use EQUIL.

## NMATRIX
- **Section**: RS · **E100**: ✓ · **E300**: ✓
- **Purpose**: Number of matrix pore systems (sub-cells per matrix cell).
- **Data**: 1 integer record: `N /`
- **E100**: Discretized matrix; sub-cells stored internally (NDIVIZ unchanged).
- **E300**: Multi-porosity; NDIVIZ must be a multiple of (N+1).
- **Restrictions**: not with BTOBALFA(V), not with DPNUM. For triple porosity use TRPLPORO.
- **Default sub-cell geometry**: LINEAR (set via NMATOPTS).
- **Example**: `NMATRIX 6 /` — six sub-cells per matrix cell.

## DIFFDP
- **Section**: RS · **E100**: ✓
- **Purpose**: Restrict molecular diffusion to matrix-fracture flow only (fracture-fracture diffusion assumed negligible).
- **Data**: none.
- **Use**: speed optimisation when DIFFUSE option is active.

## VISCD
- **Section**: RS (not extracted above, but referenced) · **E100**: ✓
- **Purpose**: Activates viscous displacement of matrix by fracture pressure gradient (Gilman & Kazemi 1988).
- **Companion required**: LX, LY, LZ; LTOSIGMA recommended.

---

# GRID keywords (matrix-fracture coupling)

## SIGMA
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Shape factor for matrix-fracture coupling — single value for entire grid.
- **Data**: 1 record: `value /`
- **Units**: m⁻² (METRIC), ft⁻² (FIELD), cm⁻² (LAB), m⁻² (PVT-M)
- **Kazemi formula**: σ = 4(1/lx² + 1/ly² + 1/lz²)
- **Reference**: σ = 0.12 ft⁻² ≈ 10 ft matrix blocks.
- **Default**: 0.0 (no coupling) — must set unless LTOSIGMA is used.
- **Example**: `SIGMA 0.12 /`

## SIGMAV
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Per-cell shape factor. Values in first NDIVIZ/2 layers only; copied to fracture half on output.
- **Data**: one value per cell in the current BOX (matrix layers only).
- **Use when**: SIGMA varies across the field (heterogeneous fracturing).

## SIGMAGD
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Alternative sigma for gravity-drainage-dominated flow.
- **E100**: switch — used when (1) gravity drainage active, (2) oil flowing matrix→fracture, (3) gas head > water head in fracture. Default K-direction: Z-perm (post-99A; OPTIONS item 70 to revert to X-perm).
- **E300**: smooth interpolation with SIGMA based on relative magnitudes of capillary vs gravity potentials (Eq. 2.60).
- **Default**: falls back to SIGMA values.
- **Companion**: SIGMAGDV for per-cell values.

## SIGMAGDV
- **Section**: G · Per-cell SIGMAGD. Same notes as SIGMAV but for SIGMAGD.

## MULTSIG
- **Section**: G · Multiplier on SIGMA, applied to entire grid.

## MULTSIGV
- **Section**: G · Per-cell SIGMA multiplier.

## MULSGGD / MULSGGDV
- **Section**: G · Multipliers on SIGMAGD (grid-wide / per-cell).

## LTOSIGMA
- **Section**: G · **E100**: ✓
- **Purpose**: Compute σ (and σ_gd) from input matrix block dimensions LX/LY/LZ.
- **Data**: up to 5 items
  1. `fx` — X-direction coefficient (default 4.0, Kazemi)
  2. `fy` — Y coefficient (default 4.0)
  3. `fz` — Z coefficient (default 4.0)
  4. `fgd` — coefficient for SIGMAGD calc (default 0.0 → skip)
  5. transmissibility option: `XONLY` (use only matrix X-perm; default) | `ALL` (use all three directional perms per Eq. 2.56)
- **Side effect**: SIGMA(V) and SIGMAGD(V) values entered explicitly are **ignored** if LTOSIGMA is used.
- **Required when**: VISCD is active.
- **Example**: `LTOSIGMA 4.0 4.0 0.0 /` — only X and Y contribute (lz defaulted/zero → that term skipped).

## LX, LY, LZ
- **Section**: G · **E100**: ✓
- **Purpose**: Representative matrix block dimensions per cell.
- **Data**: one value per cell in current BOX.
- **Used by**: LTOSIGMA (compute σ) and VISCD (viscous displacement upwinding).
- **Note**: these are *physical block dimensions*, not simulation cell sizes.

## DZMTRX
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Vertical dimension of a typical block of matrix material. REQUIRED for gravity drainage.
- **Units**: m / ft / cm.
- **Default**: 0.0 (no gravity drainage even when GRAVDR is active).
- **Note**: typically much smaller than simulation cell DZ.
- **Example**: `DZMTRX 2.0 /` — 2 ft matrix blocks.

## DZMTRXV
- **Section**: G · Per-cell DZMTRX. Values in first NDIVIZ/2 layers only; copied to fracture half on output.

## NMATOPTS
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Geometry and partitioning options for the discretized matrix / multi-porosity.
- **Data**: up to 3 items
  1. Geometry: `LINEAR` (default) | `RADIAL` | `SPHERICAL` | `UNIFORM` (E300) | `VERTICAL` (gravity drainage)
  2. Outer-sub-cell size as fraction of fracture pore volume (default 0.1; not used by UNIFORM/VERTICAL)
  3. Partition method (E300 only): `FPORV` (default) | `MBLKV`
- **VERTICAL**: requires GRAVDRB in RUNSPEC. All matrix sub-cells connect to the fracture directly.
- **Example**: `NMATOPTS RADIAL 0.05 /`

## DPGRID
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Auto-copy GRID-section keyword values from matrix to fracture cells where fracture values are absent.
- **Data**: none.
- **Affected keywords**: DX, DY, DZ, PERMX, PERMY, PERMZ, PORO, TOPS, MIDS, NTG, DZNET, ZCORN, PERMXY, PERMYZ, PERMZX. (+ DEPTH from EDIT for unstructured grids; + thermal/Pc keywords if those options active.)
- **Gotcha**: ZCORN only needs half the corner points (helpful for faulted DP runs from Petrel).
- **Important**: matrix → fracture copy happens *after* GRID is read. Data manipulation in fracture cells inside GRID section won't work.

## DPNUM
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Mark regions as single-porosity (0) inside a DUALPORO run. Defaults to dual-porosity (1).
- **Data**: 0/1 per cell in the first NDIVIZ/2 layers.
- **Restrictions**:
  - Only allowed in DUALPORO; **not allowed in DUALPERM**
  - Not allowed with NMATRIX or TRPLPORO (multi-porosity)
  - Not allowed with alternative transmissibility multipliers (GRIDOPTS item 1 = YES)
  - All values zero is forbidden (must have at least some DP)
  - For LGRs all DPNUM values inside the LGR must agree
- **Wells**: in single-porosity regions, wells connect to matrix cells.

## NODPPM
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Suppress the default `K_frac_effective = K_frac_input × φ_frac` multiplication.
- **Data**: none.
- **Use when**: input fracture permeabilities already represent the *effective* network value (post-upscaling).
- **Otherwise**: Eclipse does the φ multiplication for you; cleaner if your inputs are raw fracture-only.

## PERMMF
- **Section**: G · **E300**: ✓
- **Purpose**: Permeability used for the matrix-fracture coupling Tx (replaces default matrix X-perm).
- **Use when**: matrix internal flow and matrix-fracture coupling should use different perms (damaged matrix surfaces, coating, etc.).
- **Required when**: 1D Y- or Z-only global grid with X-extending LGR (otherwise X-perm = 0 everywhere and Tx is zero).

## MULTMF
- **Section**: G · **E300**: ✓ · Multiplier for matrix-fracture permeability.

## BTOBALFA
- **Section**: G · **E100**: ✓ · **E300**: ✓
- **Purpose**: Enable block-to-block connections (lower matrix to upper fracture) with a single contact-area multiplier.
- **Data**: 1 value (multiplier).
- **Effect**: activates additional Tx between non-co-located matrix and fracture cells (TD fig 2.16).
- **Restriction**: not with multi-porosity.
- **Use when**: physical matrix block size ≈ grid cell size.

## BTOBALFV
- **Section**: G · Per-cell block-to-block contact area multipliers.

## DIFFMMF
- **Section**: G, SC · Multiplier for matrix-fracture diffusivities (when DIFFUSE active).

## ROCKSPLV
- **Section**: G · **E300**: ✓ · Per-cell override of the rock-volume distribution between porosities (otherwise Eclipse uses the auto rules at TD p.122).

---

# PROPS keywords

## INTPC
- **Section**: P · **E100**: ✓ · **E300**: ✓
- **Purpose**: Integrated capillary pressure option. Modifies the matrix Pc curves so that equilibrium saturations match the gravity head over the block height.
- **Data**: 1 record: `WATER | GAS | BOTH /` (default BOTH).
- **Required with**: DUALPORO + GRAVDR/GRAVDRM.
- **Output**: modified curves printed to PRT via SWFN/SGFN in RPTPROPS.
- **Pre-2007.1**: INTPC with GRAVDRM was discouraged; new auto-pseudoization makes it safe now (revert via OPTIONS item 107 E100 / OPTIONS3 item 126 E300).

## DPKRMOD
- **Section**: P · **E100**: ✓
- **Purpose**: Modify matrix oil kr to match a fine-grid single-porosity recovery curve. Optionally scale fracture kr for fracture-to-matrix flow.
- **Data**: NTSFUN records, each with 3 items:
  1. `mw` — oil-in-water kr modification (-1 to 1, default 0)
  2. `mg` — oil-in-gas kr modification (-1 to 1, default 0)
  3. Scale fracture kr for F→M flow? `YES | NO` (default NO)
- **Function**: quadratic perturbation preserving end-points; sign of m flips the bias.
- **Caveat**: not a physical quantity; pure tuning parameter.
- **Example**:
  ```
  DPKRMOD
    0.0  0.9 /        -- Table 1 matrix
    /                 -- Table 2 fracture defaulted
  ```

---

# REGIONS keywords

## KRNUMMF
- **Section**: R · **E100**: ✓
- **Purpose**: Specify a separate kr table for matrix-fracture flow (independent of matrix and fracture SATNUM).
- **Use when**: F→M flow should not use the fracture's own kr (e.g., maximum kr should be the matrix kr at displaced-phase residual).

## IMBNUMMF
- **Section**: R · **E100**: ✓ · Same as KRNUMMF but for the imbibition table (with hysteresis active).

---

# Less-used / related keywords (for context)

| Keyword | Purpose |
|---------|---------|
| `SIGMATH` | Thermal-conduction matrix-fracture coupling (Thermal option) |
| `TRPLPORO` | Triple-porosity option (separate from NMATRIX>1) |
| `OPTIONS` items 11, 60, 70, 107 | Various pre-version compatibility switches (see TD references) |
| `OPTIONS3` (E300) | Same family, E300 |

---

## Output-side reporting (where to look for DP results)
| Where | What |
|-------|------|
| `.PRT` print file | RPTGRID → SIGMA, DZMTRX, modified Pc curves (with INTPC) |
| Summary mnemonics with ring number | E.g. `BOSAT7 1 1 2 /` → sub-cell #7 oil saturation in matrix cell (1,1,2) |
| RPTPROPS | INTPC-modified Pc tables |
| OPTIONS item 60 verbose output | DK linear-solver behaviour |
