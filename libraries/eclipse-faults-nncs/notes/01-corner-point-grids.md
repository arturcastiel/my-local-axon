# 01 — Corner-point grids: where fault geometry comes from

## The two grid input modes

Eclipse accepts grids in **two fundamentally different ways**:

### A. Block-centred (DX/DY/DZ + TOPS)
- Each cell defined by its centre depth (TOPS only sets the top layer) and side lengths
- Cells are implicit *rectangular boxes* aligned with the Cartesian axes
- Cannot represent fault throws — every cell is a flat aligned brick
- Default transmissibility scheme: **OLDTRAN** (E100) — uses cell-centre separations
- *Use*: simple synthetic models, history-matched single-zone reservoirs

### B. Corner-point (COORD + ZCORN)
- Each cell defined by **eight corner points** in 3D
- The grid is a system of **pillars** (vertical or tilted lines) defined by `COORD`, and **Z-coordinates of cell corners along each pillar** defined by `ZCORN`
- Cells share pillars but can have *independent* Z-coordinates along that pillar → **fault throw is encoded by Z-offsets between adjacent columns**
- Default transmissibility scheme: **NEWTRAN** (E100) — uses corner-point areas and dip-corrected distances
- *Use*: any real field model. This is what Petrel, Roxar, and most pre-processors output.

> Rule of thumb (TD p.34): use NEWTRAN with COORD/ZCORN, OLDTRAN with DX/DY/DZ. Mixing them
> (NEWTRAN with DX/DY/DZ) is *strongly discouraged* — Eclipse will guess flat blocks and produce
> spurious fault NNCs everywhere because the assumed flat columns overlap their neighbours.

## How `COORD` works
The `COORD` array has `6·(NX+1)·(NY+1)` values — for every grid corner in the (i,j) horizontal grid, two 3D points: the top of the pillar and the bottom of the pillar. The 3D pillar runs vertically (or tilted) through the reservoir; every K layer's corners lie *somewhere along this pillar*.

```
For each of (NX+1)·(NY+1) pillars:
   (X_top,  Y_top,  Z_top,  X_bot,  Y_bot,  Z_bot)
```

If `X_top == X_bot` and `Y_top == Y_bot`, the pillar is vertical. Otherwise it tilts — common for steeply dipping reservoirs.

## How `ZCORN` works
The `ZCORN` array has `8·NX·NY·NZ` values — for every cell, the Z-coordinate of each of its 8 corners. The X and Y locations of the corners come from the pillars (`COORD`).

Eclipse expects the corners in a specific order — for each cell:
```
4 corners of top face (in some I/J order)
4 corners of bottom face (in same order)
```

For corners SHARED with neighbouring cells (the top of cell K = bottom of cell K-1), `ZCORN` stores them *twice* — once as "bottom of K-1" and once as "top of K". When these two values **disagree**, you have:
- a **shale gap** (if the gap is just an unmodelled layer — handled by `MULTZ-`)
- a **pinchout** (if a layer locally vanishes — handled by `PINCH`)
- or, *along a column boundary*, a **fault throw** (one column shifts relative to its neighbour)

## Faults are *implicit* in ZCORN

When two adjacent columns share a pillar, their cells along that pillar have their own ZCORN values. If column A's layer 3 has its bottom at z = -2050 and column B's layer 3 has its bottom at z = -2080, there's a 30-m throw across that face.

Eclipse, during grid initialisation, **computes the partial overlap area** between layer 3 of column A and whichever layers of column B happen to occupy the same depth range. The overlap might be:
- 100% — no fault, regular neighbour connection
- 0% — completely offset, no connection
- 30% — partial overlap, a *Non-Neighbour Connection* (NNC) is built with reduced area

```
Column A                      Column B
+----------+ z=-2000           
| Layer 1  |                  +----------+ z=-2000
+----------+ z=-2025           | Layer 1  |
| Layer 2  |                  +----------+ z=-2030
+----------+ z=-2050           | Layer 2  |   ← partial overlap with A.L2 (z=-2025..-2050) and A.L3
| Layer 3  |                  +----------+ z=-2055   creates two NNCs: A.L2↔B.L2 and A.L3↔B.L2
+----------+ z=-2080           | Layer 3  |
                              +----------+ z=-2080
```

Both NNCs use the NEWTRAN formula (TD Eq. 2.13) with the partial overlap area — Eclipse handles it the same way as full-face neighbours.

## Multi-region grids (`NUMRES`/`COORDSYS`)

For very large reservoirs with sharply different sub-regions, you can have **multiple COORD systems** stacked in a single model:
- `NUMRES n` in RUNSPEC reserves space for n distinct pillar systems
- `COORDSYS` assigns each K-layer to one of the pillar systems
- NNCs are built between adjacent sub-regions automatically by the corner overlap calculation

Rarely needed. Typical use: combining a regional model with a near-wellbore refinement, or stitching across geological domains.

## Pinch-outs are not faults
A *pinchout* is where a layer locally has zero or near-zero thickness — common in stratigraphic models where a sand lens disappears laterally. Eclipse handles it via the `PINCH` keyword family:
- `PINCH` — sets the threshold thickness below which a cell is treated as pinched out, and the maximum vertical gap for connections to bridge it
- `PINCHOUT` — deactivate cells below the threshold (alternative to PINCH)
- `PINCHNUM` — region-specific pinchout thresholds
- `PINCHXY` — control horizontal connections across pinched-out neighbours

When a layer pinches out, Eclipse may bridge the gap with an NNC connecting the cells above and below — the transmissibility is computed by either the half-cell harmonic of the top and bottom (TOPBOT option) or as an `ALL`-cell harmonic average through the pinched layers (TD p.106 family).

`MINPV` / `MINPVV`: cells below a minimum pore volume are deactivated. If you do this, the `GAP` option of PINCH determines whether NNCs bridge across them.

## Practical: what should I check on a new grid?

1. Open the .PRT print file. Look for:
   - "Number of active cells:" — does it match the count you expect?
   - "Non-neighbor connections generated:" — the count of geometric NNCs (faults + pinchouts)
   - "Total fault segments:" if FAULTS was used
2. Use `RPTGRID ALLNNC` to dump every NNC into the PRT — verify the count matches the geological story (one fault → tens to thousands of NNCs depending on fault length × #layers)
3. Visualise the grid in Petrel / Floviz / similar — most pre-processors can show NNCs as dashed lines between offset cells
4. Check transmissibility distributions: very small Tx (< 1e-6) NNCs are *dropped silently*. Use `MULTFLT` or explicit `NNC` keyword to keep them if you need them.

## Why this matters for the rest of the library
Every NNC discussion (`notes/02`, `notes/03`) starts with: "given that the geometry generates an overlap area A and a distance D...". That geometric step happens here, in COORD/ZCORN processing. Once you have A and D, the *math* of the transmissibility is uniform across faults, pinchouts, regular faces, and dual-porosity coupling — the keywords just label which subset you want to edit.
