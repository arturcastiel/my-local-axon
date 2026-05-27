# 06 — Debugging NNCs and fault transmissibilities

## When to suspect NNC trouble

| Symptom | First suspect |
|---------|--------------|
| Production rates don't match a known fault-compartmentalised history | MULTFLT didn't apply (wrong fault name, K range, or section) |
| Massive initial pressure transient at t=0 | Geometry-driven NNCs with very high or very low Tx, or duplicate NNC entries |
| Unphysical cross-fault drainage | FAULTS K range missing layers (especially under DK), or MULTFLT zero dropped the NNC |
| EDITNNC ignored | NNC was inlined, dropped, or never built (silent) |
| MULTREGT not working | NRMULT in GRIDOPTS not set or MULTNUM regions not defined |
| Solver convergence issues | Bad NNC Tx (1e10+ or negative would-be values) |

## Step 1 — Inventory NNCs in the .PRT file

Add to GRID section:
```
RPTGRID
  FAULTS  ALLNNC  /
```
This prints:
1. The FAULTS table (the labels and cell ranges)
2. Every NNC (geometric fault NNCs, pinch-out NNCs, DP σ-NNCs, aquifer NNCs, user NNCs, BTOBALFA NNCs)
3. "IN-LINE CELLS" section (E100) or "Removed non-neighbor connections (inline)" (E300) — NNCs that the solver merged back into regular face connections

Grep the .PRT for keywords:
- `Number of non-neighbor connections` — total NNC count
- `Non-Neighbor Connections` — start of the NNC table
- `IN-LINE CELLS` — inlined NNCs (gone from solver, still listed for reference)
- `Total fault segments` — FAULTS keyword sanity check

## Step 2 — Verify FAULTS records were parsed

The fault table should appear in .PRT with all your records and their cell ranges. If a record is missing:
- FAULTDIM too small (segments exceeded the reserved count)
- Typo in fault name (compare names listed in FAULTS vs MULTFLT exactly — case-sensitive in some workflows)
- Wrong section (FAULTS must be in GRID; MULTFLT can be in GRID, EDIT, SCHEDULE)
- I/J coordinate constraint violated (e.g. IX1≠IX2 with face=X — silent rejection)

## Step 3 — Check effective transmissibility multipliers

Add to GRID section (and/or SCHEDULE):
```
RPTGRID
  MULTX  MULTY  MULTZ  /
```
or in SCHEDULE:
```
RPTSCHED
  MULT  /
```

Print the per-cell multiplier arrays *after* MULTFLT has been resolved. Pick a cell on each side of your fault and verify:
- Before fault: MULT should be 1.0
- On the fault face: MULT should match what MULTFLT applied (× any MULTX you also set)

## Step 4 — Check actual face Tx values

`RPTRST FLOWS` outputs per-step inter-cell flows to the restart file. Use any post-processor (or floedit, or write a Python script using ecl/sunbeam) to:
- Plot Tx histogram for all face connections (most should cluster around the geological mean)
- Highlight outliers (very low → suspected unintended sealing; very high → suspected bypass)
- Plot Tx along fault traces (should match your MULTFLT pattern)

## Step 5 — When EDITNNC is silently ignored

If you wrote:
```
EDITNNC
  12 20 3   13 20 3   0.0 /
/
```
and the .PRT shows a warning like "NNC not found" or no change in production, possible causes:
1. **NNC was inlined**: Eclipse merged it into a regular face connection (visible only via ALLNNC). Use MULTX/MULTY/MULTZ on the originating cell instead.
2. **NNC was dropped (Tx < 1e-6)**: Already gone before EDITNNC runs. Use `NNC` keyword in GRID to add it back with a non-zero base Tx.
3. **It's a DP σ-NNC**: Forbidden territory for EDITNNC (RM p.724). Use SIGMAV or MULTSIGV.
4. **Wrong cell coords**: Off-by-one, transposed I/J, swapped first/second cell. Eclipse warns but you might miss it in a large .PRT.

Enable diagnostic output:
```
EDIT
  DEBUG3
   -- item 167 = 1 → print which EDITNNC records were applied as EDITNNCR equivalents
   166*0  1  /
```

## Step 6 — When MULTFLT silently doesn't work

Check the .PRT for "MULTFLT". If the keyword was parsed but had no effect:
- The named fault doesn't exist in FAULTS (typo)
- The FAULTS cell range doesn't actually contain any geometric NNCs (no offset cells along that face)
- Another MULTFLT later in the deck overrode it (last entry wins)
- In E300, `OPTIONS3` item 248 might be hiding a double-application bug

For DP/DK: remember MULTFLT doesn't touch σ-NNCs (see `notes/05`). The fault face only carries matrix-matrix and fracture-fracture Tx, both standard NEWTRAN.

## Step 7 — Material-balance and "phantom" NNCs

Spurious NNCs from `NEWTRAN + DX/DY/DZ` (the mismatched combination):
- Show up in ALLNNC table
- Often have small but non-zero Tx
- Cause subtle material-balance drift

Cure: use NEWTRAN only with COORD/ZCORN; OLDTRAN with DX/DY/DZ.

Duplicate NNC keyword entries:
- RM p.1468: "A non-neighbor connection between two cells which are actually neighbors (or between which the simulator would form a non-neighbor connection in the absence of the NNC keyword) is allowed: this simply adds to the existing transmissibility."
- So if you accidentally specified the same NNC twice in two NNC blocks, the Tx values add.

## Step 8 — Validating numerically

Sanity test for a sealing fault:
1. Run a short simulation (e.g. 100 days)
2. Plot pressure on either side of the fault
3. Plot cumulative oil/water production across the fault (RPTRST FLOWS)
4. For a fully sealed fault (MULTFLT = 1e-4), cross-fault cumulative flow over 100 days should be < 1% of the same-compartment flow

If pressure equilibrates rapidly across a fault that should be sealing → MULTFLT didn't apply correctly.

## Diagnostic deck template

Put this at the *end* of GRID section to dump everything:

```
RPTGRID
  ALLNNC  FAULTS  TRANX  TRANY  TRANZ  MULTX  MULTY  MULTZ  NTG  PERMX  PORO  /
```

Run; grep the .PRT for:
- `Number of active cells:` — sanity check
- `Number of non-neighbor connections` — total NNCs
- `Non-Neighbor Connections` — the full NNC table
- `IN-LINE CELLS` / `Removed non-neighbor connections` — what got merged

Specific search patterns (using shell):
```bash
grep -i "non-neighbor" model.PRT | head -50
grep -i "MULTFLT" model.PRT
grep -i "FAULT" model.PRT | head -30
```

## When all else fails

1. Print everything to a separate run with no time steps (just initialisation) — `TSTEP /` with zero steps in SCHEDULE
2. Compare .PRT outputs between this debug run and your production run — geometry must match
3. Visualise the model in a 3D viewer (Petrel, Floviz, Resinsight) with NNCs displayed
4. Build a *minimum* reproducer (small grid with one fault) and compare to your full model

Eclipse's geometry processing is mostly deterministic — given the same COORD/ZCORN, the same NNCs are built. So divergent NNC counts between expected and actual means there's an input that changed (or a `NUMRES`/`COORDSYS` / `GRIDOPTS` setting that's modifying behaviour).
