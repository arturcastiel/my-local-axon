# Knowledge gaps and unverified assumptions

> Honest map of what I know vs what I'm asserting from documentation only.

## A. NEWTRAN geometry implementation

### A1. Exact algorithm for computing the overlap area between two offset corner-point cells
- **Claim**: Eclipse computes the partial overlap area between two adjacent column cells by intersecting their face polygons (defined by the four pillar pairs and Z-corner pairs).
- **Source**: Implicit in TD p.34 — "the mutual interface area is calculated, and this may be non-zero for non-neighboring cells at faults."
- **Confidence**: 70%.
- **Open question**: Is the intersection done by a 2D polygon-clipping algorithm (Sutherland-Hodgman, Greiner-Hormann) applied to the projected fault-face polygons, or by a different scheme? Performance implications for very large grids?

### A2. Inlining algorithm
- **Claim**: When an entire intervening layer is inactive, Eclipse merges the NNC bridging across it back into a regular neighbour connection.
- **Source**: RM p.1468.
- **Confidence**: 85%.
- **Open question**: What is the criterion for "entire layer inactive"? Per-cell inactive in the path? PORV < threshold? Does the inlining happen at grid-build or at runtime?

### A3. NEWTRAN vs OLDTRAN with the same input — quantitative difference
- **Claim**: NEWTRAN with COORD/ZCORN and OLDTRAN with DX/DY/DZ should give similar Tx for flat aligned grids, divergent for dipping or faulted grids.
- **Confidence**: 75%.
- **Open question**: For a real Petrel-exported deck, what's the typical % difference? Worth a benchmark.

## B. MULTFLT semantics

### B1. Order of operations for MULTFLT in EDIT vs TRANX/Y/Z in EDIT
- **Claim**: If TRANX/Y/Z appears AFTER MULTFLT in EDIT, it overrides MULTFLT for face Tx but MULTFLT still applies to NNCs.
- **Source**: RM p.1387 note.
- **Confidence**: 70%.
- **Open question**: Test this with a controlled deck — does it actually behave this way?

### B2. Wildcard matching in MULTFLT
- **Claim**: Trailing asterisk `'F_NS*'` matches any name starting with `F_NS`.
- **Source**: RM p.1387 — "A fault root name, ending with an asterisk (*) can also be used to refer to several faults in one record."
- **Confidence**: 90%.
- **Open question**: Are there *embedded* wildcards (like `'F_*_seal'`)? Case sensitivity?

### B3. Eclipse 100 vs Eclipse 300 in MULTFLT + EDITNNCR ordering
- **Claim**: E300 applies MULTFLT before EDITNNCR (EDITNNCR wins); E100 applies MULTFLT after EDITNNCR (MULTFLT wins).
- **Source**: RM p.1388.
- **Confidence**: 75%.
- **Open question**: Why the asymmetry between simulators? Historical accident or deliberate?

## C. DP / DK interaction with faults

### C1. Do σ-NNCs ever cross a fault line?
- **Claim**: No. σ-NNCs are *in-place* (matrix and fracture cells in the same (i,j) column but different K). Faults are lateral. So σ-NNCs don't cross faults.
- **Confidence**: 95%.
- **Open question**: Confirmed?

### C2. BTOBALFA NNCs and faults
- **Claim**: BTOBALFA connections (lower matrix ↔ upper fracture) are between cells in the *same* (i,j) column at different K. Lateral faults don't intersect them.
- **Confidence**: 80%.
- **Open question**: What if the lower matrix is in one column and the upper fracture is in a vertically offset column due to fault throw? Does BTOBALFA build the connection there?

### C3. Pinchouts in DP/DK
- **Claim**: PINCH operates on the fracture half of the grid the same way as a single-porosity grid; the matrix half is handled implicitly via SIGMA.
- **Confidence**: 60%.
- **Open question**: What if the matrix layer is pinched but the fracture layer isn't (or vice versa)? Does Eclipse handle the asymmetry? Worth testing.

## D. Numerical / solver

### D1. Cost of NNCs in the Jacobian
- **Claim**: Each NNC adds one off-diagonal entry in the Jacobian. For most NNCs the entries are small (high-perm fault) or sparse (sealing fault), so they don't dominate solver cost.
- **Confidence**: 65%.
- **Open question**: For models with thousands of NNCs (DP/DK + many faults), what's the convergence-rate penalty? Linear iterations per Newton step?

### D2. Tx < 1e-6 drop threshold
- **Claim**: Tx below 1e-6 silently dropped; below 1e-20 warns and drops.
- **Source**: RM p.1468.
- **Confidence**: 90%.
- **Open question**: What's the unit consistency? 1e-6 in METRIC is much smaller than 1e-6 in FIELD. Is the threshold actually unit-aware or absolute?

## E. Best practice / field experience

### E1. Typical MULTFLT values for real fields
- **Claim**: Sealing ~1e-4 to 1e-3; leaky ~0.01 to 0.3; conductive (rare) > 1.0.
- **Confidence**: 60% (folklore, would benefit from a survey).
- **Open question**: Is there a published study correlating MULTFLT calibration values with fault-seal analysis (SGR, Allan diagrams)?

### E2. When to use MULTREGT vs MULTFLT
- **Claim**: MULTFLT for named geometric faults; MULTREGT for stratigraphic / categorical barriers.
- **Confidence**: 80%.
- **Open question**: Hybrid approach where a fault has region-specific behaviour? Both? Or just split into named segments?

### E3. NNCGEN usage in real workflows
- **Claim**: Mostly for LGR-LGR connections in complex sub-region models.
- **Confidence**: 50%.
- **Open question**: Are there other common uses? Multi-NUMRES region stitching?

## F. Conceptual / theoretical

### F1. Half-cell harmonic mean vs arithmetic mean for Tx
- **Claim**: Eclipse uses harmonic mean of half-cell transmissibilities (in NEWTRAN form: `T = 1 / (1/T_i + 1/T_j)`). Standard for Darcy flow because rate is limited by the *worst* of the two cells.
- **Confidence**: 95%.
- **Open question**: Why does OLDTRAN seem to use arithmetic of (cross-section × NTG)? Re-read Eq. 2.2 carefully.

### F2. Why DIPC enters X/Y but not Z
- **Claim**: Z-direction is already aligned with gravity; the dip correction is for the projection of *horizontal* flow paths onto truly horizontal sections.
- **Confidence**: 80%.
- **Open question**: Does this mean OLDTRAN with very dipping layers gives wrong Z-direction Tx? Or is the OLDTRAN Z formula different in a way that handles it?

### F3. Eclipse handles fault smear / capillary entry pressure?
- **Claim**: Not directly via MULTFLT — it only scales Tx, not capillary properties. For fault-related capillary trapping, KRNUMMF + custom kr/Pc tables in a fault zone region would be needed.
- **Confidence**: 70%.
- **Open question**: Is there an Eclipse option to model fault-specific capillary entry pressure (relevant for CO2 storage)?

## G. Practical mistakes I would expect to make

### G1. Forgetting GRIDOPTS YES for MULTX-
- **Mistake**: Adding MULTX- to GRID without setting GRIDOPTS YES → parser rejects silently or with confusing error.

### G2. Defining FAULTS in a block-centred grid
- **Mistake**: FAULTS without ZCORN offsets → MULTFLT applies to nothing.

### G3. Using FAULTS K range that doesn't cover matrix layers in DK
- **Mistake**: Under DUALPERM, sealing the fracture half (K=NDIVIZ/2+1..NDIVIZ) but not the matrix half → matrix fluid leaks across.

### G4. Re-EDITNNC after the NNC was inlined
- **Mistake**: Eclipse silently ignores; pre-warning by RPTGRID ALLNNC would have caught it.

### G5. MULTFLT 0 instead of 1e-4
- **Mistake**: NNC dropped → can't re-enable, breaks subsequent EDITNNC.

## Overall confidence

| Topic | Confidence |
|-------|-----------|
| FAULTS + MULTFLT mechanics | 90% |
| NEWTRAN / OLDTRAN math | 85% |
| NNC auto-generation rules | 80% |
| Cross-reference with DP/DK | 85% |
| Debugging and diagnostics | 80% |
| Edge cases and version-specific behaviour | 50% |
| Real-field calibration values | 50% (folklore, not measured) |

Overall ~75%. To get to 90%+:
1. Run a minimum-reproducer deck with a single fault and verify the NNC mechanics empirically
2. Read Hearn (1969) and Coats's NEWTRAN papers for the original derivations
3. Build a benchmark comparing OLDTRAN, NEWTRAN, OLDTRANR results on the same dipping grid
4. Test ordering of MULTFLT vs EDITNNCR experimentally
