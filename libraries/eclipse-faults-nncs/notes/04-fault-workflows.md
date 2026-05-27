# 04 — Fault workflows: sealing, leaky, time-varying, region barriers

## The mental model

```
   GEOMETRY                NAMING                EDITING
   (where is the fault)    (label it)            (set its strength)
   COORD/ZCORN             FAULTS                MULTFLT / MULTREGT
                                                 EDITNNC for outliers
```

Three independent decisions, in this order. Most workflow problems trace back to mixing them up — particularly defining a fault in `FAULTS` without realising the *geometry* has to already exist in COORD/ZCORN (`FAULTS` doesn't create offset cells, it just labels existing faces).

## Workflow 1 — Sealing fault (most common)

```
RUNSPEC
  FAULTDIM  10 /                  -- max 10 fault segments across all FAULTS keywords
GRID
  -- ... COORD, ZCORN from pre-processor ...
  
  FAULTS
    'F_main'  10 10   1 50   1 8  X /
  /
  
  MULTFLT
    'F_main'  0.0001 /             -- 4 orders of magnitude → effectively sealed
  /
```

**Why 0.0001 not 0**: a true zero would mean Tx < 1e-6 and Eclipse silently drops the NNC. With 1e-4 the connection still exists in the solver but transfers negligible fluid — keeps your material-balance accounting clean and lets you re-enable it later by changing the multiplier.

## Workflow 2 — Leaky fault (varying along strike)

Use multiple FAULTS records with different names if different segments have different sealing strengths:

```
GRID
  FAULTS
    'F_seal'   10 10   1 20   1 8  X /
    'F_leak'   10 10  21 50   1 8  X /
  /
  
  MULTFLT
    'F_seal'   0.001 /
    'F_leak'   0.3   /             -- 30% transmissive
  /
```

Or use a wildcard root name (RM p.1387) to apply one multiplier to a family:
```
  FAULTS
    'F_N_1'  ... /
    'F_N_2'  ... /
    'F_N_3'  ... /
  /
  MULTFLT
    'F_N*'   0.05 /                 -- all three faults get 0.05
  /
```

## Workflow 3 — Time-varying fault (re-activation / re-sealing)

`MULTFLT` is allowed in the SCHEDULE section; its effect is **cumulative** (RM p.1388 — multiplies the *current* Tx each time it appears).

```
SCHEDULE
  -- ... initial wells, tsteps ...
  
  TSTEP  10*30 /                    -- 300 days, then
  
  -- A previously sealing fault re-activates due to pressure depletion:
  MULTFLT
    'F_main'  100 /                  -- multiplies current Tx by 100 (back toward 0.01)
  /
  
  TSTEP  10*30 /
```

**Gotcha**: if you've already applied `MULTFLT F_main 0.0001` in GRID, the SCHEDULE multiplication is on top of that. To "set" rather than multiply, compute the right factor or use `EDITNNCR` (replace) on individual NNCs.

## Workflow 4 — Sealing fault in a DUALPORO / DUALPERM model

The fault must cut **both** matrix and fracture layers. Under DUALPORO with NDIVIZ=8 (4 matrix + 4 fracture layers):

```
GRID
  FAULTS
    'F1'  10 10  1 50  1 8  X /     -- K = 1..8 covers BOTH halves
  /
  
  MULTFLT
    'F1'  0.0001 /
  /
```

If you only specified `K = 5..8` (fracture half), the fault would seal the fracture network but matrix-matrix flow under DUALPERM would still cross the fault — almost certainly wrong.

Under DUALPORO (no matrix-matrix flow), specifying K = 5..8 alone *would work* (matrix is already disconnected from neighbours). But it's safer to always cover the full K range — your model might be converted to DUALPERM later.

Reminder: `MULTFLT` does NOT touch the σ-driven matrix↔fracture NNCs (those are vertical, in-place, and don't cross lateral faults anyway). They're controlled separately by `SIGMA`/`SIGMAV`/`MULTSIG`.

## Workflow 5 — Region-to-region barrier (FLUXNUM / MULTNUM + MULTREGT)

When you want a barrier *not* aligned with a single fault — e.g. separating two stratigraphic compartments, or matching a sealed boundary that doesn't follow column lines — use:

```
GRID
  GRIDOPTS  YES  3  / -- enable MULTREGT, reserve 3 MULTNUM regions
  
  MULTNUM
    -- region labels per cell:
    -- 1 = upper compartment, 2 = lower, 3 = central
    ...values for every cell... /
  
  MULTREGT
    1  2  0.001  XYZ  ALL  M  /     -- region 1 ↔ region 2: TX·0.001 in all directions
    2  3  1.0    XYZ  ALL  M  /     -- region 2 ↔ region 3: full Tx
  /
```

MULTREGT items (RM p.1414):
1. Source region
2. Target region
3. Transmissibility multiplier
4. Direction: X, Y, Z, or XYZ
5. NNC handling: ALL (incl. NNCs), NONNC (faces only), NOAQUNNC
6. Plus / Minus / Both face

Doesn't replace MULTFLT — these tools coexist. MULTFLT is for *named* fault segments; MULTREGT is for *categorical* boundaries between region types.

## Workflow 6 — Explicit NNC injection (bypass channel, conduit)

Sometimes a geological feature isn't an offset face but a *bypass channel* connecting two cells that aren't geometric neighbours — e.g. a karst conduit, a high-perm streak, a fault-zone damage zone. Use the `NNC` keyword:

```
GRID
  NNC
  --   IX  IY  IZ    JX  JY  JZ      TRAN
       12  20  3     14  20  3       500.0  /        -- bypass channel at K=3
       12  20  4     14  20  4       500.0  /
  /
```

If `(12,20,3)` and `(14,20,3)` already had an NNC from corner-point overlap, this **adds** to the existing Tx (RM p.1468). To override entirely, use `EDITNNCR` in EDIT section.

## Workflow 7 — Individual NNC editing (history match outlier)

When a single NNC is clearly mis-calibrated (production data shows leakage where the model says none, but only at one specific connection):

```
EDIT
  EDITNNC
  --  IX  IY  IZ    JX  JY  JZ    TRANM
      12  20  3     12  21  3     5.0     /            -- multiply that NNC by 5
      15  25  6     16  25  6     0.0     /            -- kill that NNC
  /
```

Or replace outright (E100 / E300, with the EDITNNCR-vs-MULTFLT ordering caveat from `notes/02`):
```
EDIT
  EDITNNCR
      12  20  3   12  21  3   75.4 /                   -- set Tx = 75.4 exactly
  /
```

## Worked example: combining everything

A 20×20×10 corner-point reservoir with:
- A fault along I=10 sealing layers 1-5
- A leaky fault along J=15 in layers 6-10
- Stratigraphic barrier between MULTNUM regions 1 and 2
- A specific bypass NNC between (5,5,3) and (5,5,6)

```
RUNSPEC
  FAULTDIM  10 /
  
GRID
  -- ... COORD, ZCORN, PERMX, PERMY, PERMZ, PORO ...
  
  GRIDOPTS  YES  2  /
  MULTNUM
    -- ... 2-region map ...
  /
  
  FAULTS
    'F_seal'  10 10   1 20   1 5   X /
    'F_leak'  20 20   15 15  6 10  Y /
  /
  
  MULTFLT
    'F_seal'  0.0001 /
    'F_leak'  0.20   /
  /
  
  MULTREGT
    1  2  0.05  XYZ  ALL  M  /
  /
  
  NNC
    5 5 3   5 5 6   1200.0 /          -- bypass channel: high Tx
  /

EDIT
  EDITNNC
    -- targeted history-match tweaks on individual fault NNCs:
    9  10  3   11  10  3   3.0  /     -- this segment leaks more than the average
  /
```

## Numbers that work in practice

| Sealing strength | Multiplier | Interpretation |
|------------------|-----------|----------------|
| Fully sealing (chalk gouge, cemented) | 1e-6 .. 1e-4 | Effectively no flow on production timescales |
| Strongly sealing (clay smear) | 1e-3 .. 1e-2 | Slow equilibration over years |
| Partially sealing (juxtaposition seal) | 1e-2 .. 0.1 | Real but reduced communication |
| Leaky / partially transmissive | 0.1 .. 0.5 | Often the history-match landing |
| Open / no fault sealing | 0.5 .. 1.0 | Effectively no barrier |
| Conductive fault (damage zone, high perm channel) | 1.0 .. 100+ | Higher than the unfaulted Tx (drainage channel) |

Practical range for history matching: 1e-4 to 10. Below 1e-4 you're outside the precision the solver cares about (and risk NNC drop-out below 1e-6); above 10 you're modelling a *channel*, not a fault.

## Anti-patterns

| Pattern | Why it's wrong |
|---------|----------------|
| Using `FAULTS` without `COORD`/`ZCORN` (block-centred grid) | FAULTS just labels existing offset NNCs; with DX/DY/DZ there are no offset NNCs to label |
| Multipliers stacked accidentally | `MULTFLT` in GRID + `MULTX` on the same face + `EDITNNC` on the NNC → final Tx is the product of all four. Print MULTS to verify. |
| Forgetting to cover all K layers under DK | Matrix-matrix flow defeats the fault seal |
| `MULTFLT 0` | Drops the NNC silently below 1e-6 — can't be re-enabled. Use 1e-4 instead. |
| Defining FAULTS after-the-fact in EDIT to "fix" geometry | FAULTS only modifies multipliers; you can't introduce a new geometric offset this way. The geometry must already be in ZCORN. |
| Editing DP σ-NNCs with EDITNNC | Not allowed (RM p.724). Use SIGMAV or MULTSIGV. |
| Negative MULTFLT | Not allowed (RM warns; would create non-physical flow direction). |

## When the simple approach fails

If your reservoir has many faults with complex geological controls:
- Pre-process MULTFLT values from a fault-seal analysis tool (Knipe, Yielding, etc. → SGR/Allan-diagram → multipliers)
- Use the wildcard `'F*'` family naming to group related faults
- Use MULTREGT for stratigraphic barriers that *aren't* geometric faults
- Use EDITNNC only as a last-resort point fix; if you're editing >10% of NNCs individually, your geological model is wrong

## What to do at runtime
After a run with faults:
1. Check the .PRT for "Number of non-neighbor connections" — sanity-check the count
2. `RPTGRID FAULTS` — confirm your FAULTS records were parsed
3. `RPTGRID ALLNNC` — print every NNC; spot-check a few against the ZCORN geometry
4. `RPTSCHED MULT` — confirm the running multipliers each report step
5. Plot pressure on either side of a sealing fault — should diverge over time; if not, the seal isn't working
