# Self-exam answers — with confidence ratings

> My own answers. Reviewed against the manual. Confidence 1–5 (5 = certain).
> Items rated 1–3 became gaps in `../gaps/knowledge-gaps.md`.

---

## Section 1 — Foundations

**1.** Matrix (low k, high storage — holds the oil) and fracture (high k, low storage — the flow paths to wells). Matrix holds the bulk. **[5]**

**2.** NDIVIZ (DIMENS item 3) must be even. The first NDIVIZ/2 layers are matrix; the second half are fracture. Eclipse enforces it because DP needs two cells per geometric block, stored as separate grid layers. **[5]**

**3.** Wells perforate fracture cells only. Exception: in single-porosity regions declared via DPNUM, wells connect to matrix cells (treated as standard single-porosity cells in that region). **[5]**

**4.** TR = CDARCY · σ · K · V (TD Eq. 2.54)
- CDARCY: Darcy unit conversion constant
- σ: shape factor (1/L²) — from SIGMA/SIGMAV/LTOSIGMA
- K: matrix permeability — X-direction by default, override with PERMMF
- V: matrix cell *bulk* volume (no porosity factor)
**[5]**

**5.** σ = 4·(1/lx² + 1/ly² + 1/lz²). For lx=ly=lz=10 ft: σ = 4·(3/100) = 0.12 ft⁻². **[5]**

**6.** SIGMA: m⁻² (METRIC), ft⁻² (FIELD), cm⁻² (LAB), m⁻² (PVT-M). Always 1/length². **[5]**

**7.** NODPPM suppresses the default `K_frac_effective = K_frac_input × φ_frac` multiplication. Use it when your input fracture permeabilities already represent the *effective* network value (post-upscaling). **[5]**

**8.** PERMMF overrides the default matrix X-direction permeability used in the matrix-fracture coupling Tx. Eclipse 300 only. Required when global grid is 1D in Y/Z but an LGR extends in X (X-perm = 0 default → no Tx). **[4]**

**9.** GRAVDR: 2 porosities (just matrix + fracture). NMATRIX + NMATOPTS VERTICAL: 2 porosities in the *grid* (still matrix layers + fracture layers), but the matrix is internally subdivided into NMATRIX vertical sub-cells, each communicating directly with the fracture. **[3]** — I was a little hazy on this; the grid layer count is unchanged in E100 but the effective number of *cells* per location is 1 + NMATRIX (sub-cells + fracture).

**10.** DUALPORO: matrix cells are not directly connected to neighbouring matrix cells (matrix A in the Jacobian is diagonal). DUALPERM: matrix cells *are* connected to neighbours via normal spatial transmissibilities (matrix A is banded). Both still have matrix-fracture NNCs. **[5]**

## Section 2 — Recovery mechanisms

**11.** Oil expansion, imbibition (capillary), gravity imbibition/drainage, diffusion, viscous displacement. **[5]**

**12.** Oil is the *wetting* phase in a gas-oil system. Oil tends to imbibe *into* the matrix by capillarity, not out. Without gravity drainage, there's no other force pulling oil into the fracture. **[5]**

**13.** DIFFDP (RUNSPEC). **[5]**

**14.** DPKRMOD applies a quadratic modification to the matrix oil kr curve to match a finely-gridded single-porosity reference. It is a tuning parameter, NOT a physical quantity (TD p.116). **[5]**

**15.** INTPC modifies the matrix capillary pressure curve by integrating the rock Pc over the matrix block height, so the equilibrium saturation matches the actual gravity head over the block. Relevant in DUALPORO + GRAVDR/GRAVDRM runs (in PROPS section). **[5]**

**16.** Water imbibition is capillary-driven, requires a positive matrix Pc (set via SATNUM tables), and does NOT require DZMTRX. Gravity drainage *does* require DZMTRX (or DZMTRXV) — the gravity head per matrix block height is the driving force. **[5]**

**17.** Gilman-Kazemi (1988) viscous displacement: when the fracture has a real pressure gradient G, the matrix is swept laterally by the gradient rather than seeing a uniform fracture pressure. Modified upwinding with an extra term proportional to G·L (TD Eq. 2.77). Activated by VISCD in RUNSPEC; needs LX/LY/LZ + LTOSIGMA. **[4]** — I had to look up which equation number.

**18.** Matrix table: full Pc curve (positive water-oil Pc in water-wet rock), curved kr. Fracture table: zero Pc, straight-line kr (channels don't have capillary forces). **[5]**

## Section 3 — Gravity drainage

**19.** GRAVDR (standard — both cells in VE, single sigma; default first try). GRAVDRM (Quandalle-Sabathier; flow decomposed into horizontal + vertical-up + vertical-down with separate sigmas; use for mixed-wettability or when vertical vs horizontal transfer rates differ). GRAVDRB (vertical discretized matrix; chain of vertical sub-cells; use when intra-block vertical saturation profile matters). **[5]**

**20.** DZMTRX (or DZMTRXV). Default 0 → no gravity drainage. **[5]**

**21.** Re-infiltration YES: oil that has left the matrix can flow back in. Re-infiltration NO: one-way flow only. NO is safer because YES makes final recovery dependent on transmissibility (i.e. on sigma, kr, etc.), not on a physical equilibrium (TD p.109). **[5]**

**22.** E100: SIGMAGD is a switch — used when (gravity drainage active) AND (oil flow M→F) AND (gas head > water head). E300: SIGMAGD is smoothly interpolated with SIGMA via the per-phase weighting ωp = Δθgd/(Δθgd + ΔΦ) (TD Eqs. 2.60-2.61). **[4]**

**23.** Item 11 makes the initial reservoir solution a true steady state by modifying the phase pressures (the modification is held throughout the run). Without it, gravity drainage triggers a t=0 fluid redistribution transient. **[4]**

**24.** Vertically — each sub-cell talks to the one above and below. Additionally, ALL sub-cells connect to the fracture (unlike LINEAR/RADIAL/SPHERICAL where only the outer sub-cell does). Fracture properties are altered per-NNC to reflect local gravitational potential at each sub-cell height. **[4]**

**25.** Nothing happens. Default DZMTRX = 0 → no gravity drainage even though GRAVDR is on. Common beginner mistake. **[5]**

**26.** Sign of the *total* potential difference between matrix and fracture cells, including the gravitational potential term (Eqs. 2.69-2.71). The upstream cell has the higher total potential. **[4]**

## Section 4 — Discretized matrix / multi-porosity

**27.** Russian doll: matrix is subdivided into N nested sub-cells. Only the outermost talks to the fracture; sub-cells communicate logarithmically inward. Solves the *transient* matrix-fracture flow problem — classical DP assumes quasi-steady state, which fails for tight matrix or well-test simulations. **[5]**

**28.** Eclipse 100: NMATRIX = 6 stores the 6 sub-cells *internally*. NDIVIZ (= matrix layers + fracture layers) is unchanged. So a single-layer reservoir is still NDIVIZ = 2. **[4]**

**29.** Eclipse 300: NMATRIX = 6 means there are 7 porosities (6 matrix sub-cells + 1 fracture). NDIVIZ must be a multiple of (NMATRIX + 1) = 7. So a single-layer reservoir needs NDIVIZ = 7. **[4]**

**30.** NMATOPTS item 2 is the fraction of fracture pore volume (or matrix block volume in E300 with MBLKV) used for the *outermost* sub-cell's volume. Default 0.1. Smaller → finer resolution of the matrix-fracture interface, better for early transient. **[4]**

**31.** LINEAR (default), RADIAL (cylindrical), SPHERICAL, UNIFORM (E300 only — uniform sub-cell sizes), VERTICAL (gravity drainage variant, requires GRAVDRB). **[5]**

**32.** Cannot be used with: GRAVDR/GRAVDRM (use VERTICAL + GRAVDRB instead); LGRs; the parallel solver; DUALPERM. Must use EQUIL for initialisation. **[5]**

**33.** `BOSAT7 1 1 2 /` — appends "7" to the mnemonic to indicate sub-cell #7 (ring 1 = outer, higher ring = deeper). Inside the SUMMARY section. **[5]**

**34.** Sub-matrix cells have no direct user-input route; you can't set PRESSURE/SWAT for ring 5 of cell (1,1,2). EQUIL initialises by gravity-pressure equilibrium computation, which Eclipse can do for sub-cells; explicit init can't. **[4]**

## Section 5 — Numerical implementation

**35.** In DUALPORO, the matrix Jacobian block A is diagonal (no matrix-matrix flow). This lets Eclipse eliminate the matrix unknowns via a Schur complement that *preserves* the fracture Jacobian's banded structure. Net effect: the problem size is effectively halved — only the fracture system is solved iteratively. **[4]**

**36.** A is diagonal because matrix cells have no transmissibilities between them. This makes A^(-1) trivial (just inverting diagonal entries), and `D·A^(-1)·C` remains diagonal, so the reduced fracture system has the same band structure as B. **[4]**

**37.** OPTIONS item 60 > 0 restores the pre-97A DK linear solver (which is less efficient but possibly more robust). Flip it if the new solver has convergence problems on your specific problem. **[4]**

**38.** Typically 2–4× slower (rough rule). The exact penalty depends on grid size and convergence rate. **[3]** — folklore; have not measured.

**39.** A 4th level of nesting (matrix vs fracture is the innermost split). The Jacobian gets 6×6 block diagonal entries (in 3-phase) and 6 off-diagonal flow bands. Approximation B is built via nested factorisation through 4 levels (Eqs. 2.85-2.86). **[3]**

**40.** σ already encodes the *intensive* surface-area-per-unit-volume of matrix-fracture contact (1/L² units). Multiplying by V = cell *bulk* volume gives the total surface area available for flow in that cell. Pore volume isn't used because σ doesn't include the porosity (it's a geometric factor for the matrix material, not for the fluid). **[4]**

## Section 6 — Block-to-block and miscellaneous

**41.** BTOBALFA enables an additional transmissibility between a lower matrix cell and the *upper* fracture cell (not just its own fracture). Physical situation: matrix block size ≈ grid cell size, so the lower matrix physically contacts more than its overlying fracture. **[5]**

**42.** Not allowed with multi-porosity (NMATRIX > 1 or TRPLPORO). Also not when in single-porosity regions via DPNUM. **[4]**

**43.** DPNUM marks cells as single-porosity (0) inside a DUALPORO run. Defaults to dual-porosity (1). NOT compatible with DUALPERM — only works with DUALPORO. Also not with NMATRIX/TRPLPORO. **[5]**

**44.** If LTOSIGMA is present, any explicit SIGMA / SIGMAV / SIGMAGD / SIGMAGDV values are IGNORED. Eclipse computes σ from LX/LY/LZ. **[5]**

**45.** DPGRID auto-copies GRID-section keyword values (DX/DY/DZ/PERMX/Y/Z/PORO/TOPS/MIDS/NTG/DZNET/ZCORN/...) from matrix to fracture cells where fracture values were not user-specified. Simplifies decks. **[4]**

**46.** KRNUMMF specifies a *separate* kr table for matrix-fracture flow (full flexibility, requires defining the table). DPKRMOD item 3 = YES is a simpler approach: scales the fracture kr to the matrix max kr at displaced-phase residual saturation, without needing a new table. **[4]**

## Section 7 — Field-application judgment

**47.** Minimum:
```
RUNSPEC
  DUALPORO
  GRAVDR
GRID
  -- standard DX/DY/DZ, PERMX/Y/Z, PORO (matrix and fracture layers)
  SIGMA  0.12 /
  DZMTRX 2.0  /
  -- consider NODPPM if fracture perms are effective values
PROPS
  -- two SATNUM tables: matrix (with Pc) and fracture (Pc=0)
  -- INTPC BOTH /        ← integrated Pc for final-recovery matching
```
plus EQUIL, SCHEDULE (wells in fracture), SUMMARY. **[5]**

**48.** DPKRMOD — adjust mw or mg in -1 to 1. Endpoints preserved; curve shape modified. **[5]**

**49.** Ask the geocellular team: are the fracture perms "raw fracture-network k" (so Eclipse multiplies by φ_frac → effective) or "already upscaled effective perms"? If effective, use NODPPM. If raw, leave NODPPM off. When in doubt, run a small test and compare results. **[4]**

**50.** First two checks: (a) is the initialisation steady-state with respect to gravity drainage? OPTIONS item 11 = 1 fixes this. (b) Are DZMTRX values sensible — not too large, and consistent with the gravity-drainage rate you expect? **[4]**

**51.** DPNUM with DUALPORO — mark the regions that need matrix-matrix flow as single-porosity (0). They will then behave like normal single-porosity cells (matrix-matrix flow via the regular Tx), but no fracture overlay. Coarser than DK but avoids the cost. **[4]**

**52.** DPKRMOD ranges -1 to 1; 0.9 is at the high end of the range. It's technically valid but a red flag that something else is wrong: maybe SIGMA is mis-calibrated (try MULTSIG), the gravity model is wrong (try GRAVDRM), or the underlying matrix kr table needs revision. Don't fix the curve shape with DPKRMOD if you can fix the upstream physical input. **[4]**

## Section 8 — Theory and literature

**53.** Kazemi (1976). Warren & Root (1963) used the analytical formula α = π² ≈ 9.87 (for a 1D slab — late-time analytical solution). Eclipse defaults to Kazemi's 4. **[5]**

**54.** Lim & Aziz (1995): the analytical "no quasi-steady-state" derivation gives σ = π²·(n_x/lx² + ...) where n_x is the number of fracture sets. So for fully-bounded blocks (n_x=n_y=n_z=1), Lim-Aziz's coefficient is π² ≈ 9.87 vs Kazemi's 4 — a ratio of ~2.47. **[4]**

**55.** MINC is implemented (NMATRIX + NMATOPTS LINEAR/RADIAL/SPHERICAL/UNIFORM). Subface and EDFM are NOT implemented in standard Eclipse. Eclipse has a related single-medium conductive fractures option (CONDFRAC/SCFDIMS) that is a different approach to dominant fractures. **[4]**

**56.** Original MINC uses an integral finite difference framework with no analytical approximation for the matrix-fracture coupling — the transient is fully numerical. Eclipse's discretized matrix uses Kazemi's σ-based transmissibility but applied between sub-cells of a partitioned matrix block. Geometrically similar (nested sub-cells of decreasing distance from the fracture); mathematically different in the coupling derivation. **[3]**

---

## Summary
- 56 questions attempted
- Average confidence: ~4.2 / 5
- Items at confidence 3: #9 (porosity count in NMATRIX), #38 (DK cost penalty), #39 (Nested Factorization details), #56 (MINC vs Eclipse mathematical difference)
- These match the items flagged in `gaps/knowledge-gaps.md`

**Verdict**: ready to deploy a supervised DP/DK study. Items at confidence 3 are addressable via either (a) a benchmark simulation or (b) the cited literature papers — both are options for the next study cycle.

## Stretch — open-ended

**A. Minimal deck for 10×10×4 fractured-carbonate gas-cap study:**

```
RUNSPEC
  TITLE
    'Fractured carbonate, gas cap, GRAVDR' /
  DIMENS
    10  10  8 /          -- NDIVIZ = 8 because matrix(4) + fracture(4)
  DUALPORO
  GRAVDR
  OIL  GAS  WATER  DISGAS
  TABDIMS  2 1 30 30 /   -- two SATNUM tables
  WELLDIMS 10 5 5 5 /
  
GRID
  DPGRID                  -- auto-copy GRID arrays matrix→fracture
  DX  400*100 /           -- 10 × 10 × 4 matrix + 4 fracture layers; DPGRID handles fracture copies
  DY  400*100 /
  DZ  400*20  /
  TOPS 100*2000 /         -- matrix layer 1 only; DPGRID copies down
  PORO -- specify matrix and fracture porosities for each layer
       400*0.15 /         -- matrix layers
       -- fracture porosity overrides only the fracture half
  PERMX 400*100 /
  -- ... PERMY, PERMZ similar
  
  -- Matrix block geometry → compute σ
  LX  400*5.0 /
  LY  400*5.0 /
  LZ  400*5.0 /           -- 5-ft cubic matrix blocks
  LTOSIGMA  4.0 4.0 4.0 /
  
  DZMTRX  5.0 /           -- gravity drainage strength = 5 ft matrix block height
  
PROPS
  -- Two SATNUM tables: matrix (with Pc) and fracture (zero Pc)
  SWFN
    -- matrix Pc and kr
    ... /
    -- fracture: Pc=0, straight-line kr
    ... /
  
  -- Tune recovery shape if needed:
  DPKRMOD
    0.5  0.0  YES /       -- matrix oil-water shape tuner + scale fracture kr for F→M flow
       /                  -- fracture defaults
  
  -- Integrate Pc curves for proper final recovery in gravity-drainage zone
  INTPC  BOTH /

REGIONS
  SATNUM   -- matrix cells → 1; fracture cells → 2
  ...

SOLUTION
  EQUIL    -- mandatory; gravity equilibration

SCHEDULE
  -- Wells in fracture layers (layers 5-8 since NDIVIZ=8)
  WELSPECS  PROD1 G 5 5 / /
  COMPDAT   PROD1 5 5 5 5  'OPEN' ... /     -- fracture layers k=5..8 only under DUALPORO
            /
  WCONPROD  PROD1 'OPEN' 'ORAT' ... /
  TSTEP 30*30 /
END
```

**B. Diagnose: "no production from matrix" — six things to check, in order:**

1. Is SIGMA actually set? (If LTOSIGMA isn't computing it and SIGMA/V defaults to 0, the matrix-fracture coupling is zero → matrix is dead weight)
2. Is the matrix actually populated? Print PORO and PORV — check the first NDIVIZ/2 layers have your matrix values, not zeros
3. Are matrix cells connecting to *active* fracture cells? An orphan matrix cell stays alive but produces nothing
4. Are wells perforated in fracture layers (under DUALPORO)? COMPDAT in matrix layers does nothing
5. Is there a recovery mechanism? If gas is in the fracture and no GRAVDR is active, water-wet matrix produces zero oil
6. Has DPGRID copied matrix → fracture correctly? Check PERMX/PORO of the fracture cells

**C. CBM with instant adsorption needs DUALPERM because:**

In an instant-adsorption coal bed model, gas is adsorbed on the matrix surface and released as a function of local pressure. The matrix needs to *flow* to neighbour matrix blocks because production in one cell drops pressure locally, releasing gas in adjacent cells through the coal cleat network — there's continuity *within* the matrix-coal system, not just via the macroscopic cleat (fracture) network. DUALPORO assumes matrix blocks are isolated islands, which breaks the physics of cleat-mediated matrix continuity. For a classical naturally fractured carbonate, by contrast, matrix blocks are fully surrounded by fractures with no matrix-matrix communication, and DUALPORO is geologically correct.
