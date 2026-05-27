# 02 — NNC mechanics: when, why, and how Eclipse builds them

## What an NNC actually is

A Non-Neighbour Connection is a row in Eclipse's connection list (and a band in the Jacobian) that links **two cells that are not adjacent in the (i,j,k) indexing grid** — but are physically connected.

Internally Eclipse doesn't distinguish "normal" neighbour connections from NNCs at the *solver* level — every connection is just `(cell_i, cell_j, transmissibility, sat_table, ...)`. The "non-neighbour" label is about the *indexing*, not the *physics*.

This is important because it means **the linear solver doesn't care** whether a connection comes from corner-point geometry, dual porosity, an aquifer, or your explicit `NNC` keyword. They all participate in the same Newton iteration, the same nested factorisation. *User-facing* keywords differ — solver behaviour does not.

## Five sources of NNCs

Eclipse generates NNCs automatically from these mechanisms (RM p.1466):

### 1. Corner-point fault offsets (the canonical case)
When `COORD` + `ZCORN` show that adjacent column cells have offset Z-coordinates, partial vertical overlap creates NNCs. See `notes/01-corner-point-grids.md`. **One physical fault generates anywhere from a few to many thousands of NNCs** depending on fault length, throw, and layer count.

### 2. Pinch-out bridges
Where `PINCH` is active and a layer pinches out (thickness < threshold), Eclipse can build NNCs from the cells above to the cells below, bridging across the absent layer. `PINCH` items control the bridge transmissibility calculation:
- Item 4 = TOPBOT (default): pinchout Tx = half-cell harmonic of the two active cells (above and below the gap)
- Item 4 = ALL: harmonic average of every cell in between (matters when MULTZ is used in the gap layers)

### 3. Local grid refinements (LGRs)
Where a `CARFIN`/`RADFIN` block creates a finer sub-grid inside a coarse parent cell, NNCs connect:
- Parent cells around the LGR boundary ↔ corresponding fine cells on the LGR boundary
- Adjacent LGRs ↔ each other (if "in-place" LGRs)
Not covered in this library — see separate LGR study.

### 4. Numerical aquifers
`AQUNUM` + `AQUCON` create explicit aquifer cells and their NNCs to the reservoir. Each aquifer connection is an NNC because the aquifer cell isn't in the (i,j,k) reservoir indexing space.

### 5. Dual porosity / dual permeability
`DUALPORO` / `DUALPERM` create one NNC per (i,j) column for every K-layer pair (matrix layer K ↔ fracture layer K+NDIVIZ/2). Transmissibility uses the **σ-K-V formula** (Kazemi), not the NEWTRAN geometric formula. See `notes/05-cross-reference-dp.md`.

## NNC lifecycle

```
GRID section:
   COORD/ZCORN → Eclipse computes overlaps → AUTO-NNC list built
   DUALPORO/DUALPERM → σ-NNCs added
   PINCH → pinchout NNCs added
   NNC keyword → user-defined NNCs added
   AQUNUM/AQUCON → aquifer NNCs added
                                  ↓
   MULTFLT (GRID): named-fault multiplier applied to face Tx and any crossing NNCs
                                  ↓
   FAULTS+MULTFLT in EDIT section: further multiplication
                                  ↓
   EDITNNC: per-NNC transmissibility multiplier
   EDITNNCR: per-NNC transmissibility replacement (E300 / E100, ordering differs)
                                  ↓
   Final NNC list built; Tx < 1e-6 silently dropped; Tx < 1e-20 dropped with a warning
                                  ↓
   Solver sees a unified connection list (neighbours + NNCs, no distinction in math)
                                  ↓
SCHEDULE section:
   MULTFLT can be re-applied each step (cumulative)
```

## NNC "inlining" — a quiet optimisation

When Eclipse finds that an NNC can be **represented as a regular neighbour connection** (e.g. an entire layer between two cells has been deactivated, so the NNC bridging them is effectively a vertical neighbour connection), the simulator **silently converts it back to a regular face connection** to improve solver efficiency. RM p.1468:

> "Where the simulator finds that non-neighbor connections can be represented internally as neighbor connections, for instance where an entire layer has been deactivated, it will replace NNCs with neighbor connections to improve solver efficiency. These connections will no longer be represented as NNCs in the output files."

**Implication**: if you EDITNNC an inlined connection, Eclipse can't find it and *warns + ignores*. Use `RPTGRID ALLNNC` to see the inlined list ("IN-LINE CELLS" in E100, "Removed non-neighbor connections (inline)" in E300).

## NNC pitfalls

| Symptom | Cause |
|---------|-------|
| EDITNNC silently ignored | NNC was inlined, dropped (Tx < 1e-6), or never generated (e.g. between inactive cells) |
| Faults not sealing despite MULTFLT 0 | FAULTS segments don't cover all layers; for DK, matrix layers also need sealing |
| "Phantom" NNCs in PRT report | NEWTRAN + DX/DY/DZ input (mismatched geometry assumptions) — TD p.34 warning |
| Material balance drift | Inlined NNCs you forgot about, or duplicate NNC keyword entries (Eclipse adds the Tx values) |
| Sealing fault doesn't kill DP runs | DP σ-NNCs are vertical, don't cross lateral faults — sealing the fracture half is what matters |

## Reporting NNCs

| Mnemonic | Where | What |
|----------|-------|------|
| `RPTGRID FAULTS` | GRID | Print the FAULTS keyword data + segment count |
| `RPTGRID ALLNNC` | GRID | Print every NNC (including inlined and DP NNCs) |
| `RPTGRID NNC` | GRID | Print only explicit NNCs (not inlined, not DP) |
| `RPTGRID MULTX, MULTY, MULTZ` | GRID | Print transmissibility multipliers per cell |
| `RPTSCHED MULT` | SCHEDULE | Print effective multipliers during run |
| `RPTRST FLOWS` | restart | Per-step flows across every connection — useful for diagnosing where fluid is actually going |
| `DEBUG3` item 167 = 1 | EDIT | Print which EDITNNC records were applied (as EDITNNCR equivalents) |

## NNC keyword data items (RM p.1466-1469)

For `NNC` (manual definition):
- 1-3: I,J,K of first cell
- 4-6: I,J,K of second cell
- 7: TRAN (transmissibility) — REQUIRED
- 8-9: saturation table numbers (E100) / deprecated in E300
- 10-11: pressure table numbers (E100)
- 12-13: VE faces ZF1, ZF2 (only used with VE option)
- 14: DIFF (diffusivity) — for DIFFUSE or TRDIF options
- 15: thermal conduction Tx (E300, THERMAL option) / 1/(area·porosity) (E100, DISPERSE option)
- 16-17: area + linking permeability (for non-Darcy VDFLOW option)

For `NNCGEN` (cross-grid NNCs):
- 1: grid of first cell (default GLOBAL)
- 2-4: I,J,K
- 5: grid of second cell
- 6-8: I,J,K
- 9: TRAN
- 10: DIFF
- 11: thermal Tx

For `EDITNNC` (multiply existing):
- 1-6: I,J,K of both cells
- 7: TRANM (multiplier, default 1.0; can be 0 but not negative)
- 8-13: sat/pressure tables + VE faces (optional)
- 14: DIFFM (diffusivity multiplier)

For `EDITNNCR` (replace existing):
- 1-6: cell coords
- 7: TRANS (new transmissibility) — REQUIRED, cannot be defaulted
- 8-13: optional table/face overrides
- 14: DIFF replacement

## Why these distinctions matter

- `EDITNNC` multiplies → use for percentage tweaks
- `EDITNNCR` replaces → use when you have an authoritative Tx value from analysis
- `NNC` adds → use to *create* a connection that geometry didn't auto-generate (e.g., bypass channel)
- `MULTFLT` applies along a named fault → use for systematic fault editing
- `MULTREGT` applies between two regions → use for systematic across-region barriers

In a real history match you'll often combine these: corner-point geometry gives you the initial NNCs; MULTFLT sets the fault-sealing strength globally; EDITNNC tweaks individual problematic connections; MULTREGT enforces region-to-region barriers regardless of fault definition.
