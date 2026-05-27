# Faults & NNCs decision matrix

> "I want to model X → use these keywords." Recipes for common scenarios.

---

## Minimal corner-point deck with one fault

```
RUNSPEC
  DIMENS         50  50  10 /
  FAULTDIM        5 /
  ... oil/water/gas etc. ...

GRID
  ... COORD, ZCORN, PORO, PERMX/Y/Z from Petrel ...
  
  FAULTS
    'F_main'  10 10   1 50   1 10  X /
  /
  
  MULTFLT
    'F_main'  0.001 /
  /

PROPS / REGIONS / SOLUTION / SCHEDULE ...
```

This:
- Uses NEWTRAN by default (COORD/ZCORN present)
- Eclipse builds geometric NNCs along the I=10 column where layers offset
- Names them collectively as 'F_main'
- Reduces their Tx by 1000× → sealing

## Sealing fault with cell coverage gotcha

Pillar at I=10 from J=1..50, K=1..10:
```
FAULTS
  'F_main'  10 10   1 50   1 10  X /     -- ALL K layers covered
/
```
NOT
```
FAULTS
  'F_main'  10 10   1 50   3 7  X /      -- only K=3..7
/
```
unless you really mean for the fault to only seal layers 3-7.

## Multi-segment fault (e.g. listric or curving)

```
FAULTS
  'F_curved'   10 10   1 20   1 10   X /
  'F_curved'   11 11  20 30   1 10   X /     -- jogs to I=11
  'F_curved'   11 11  30 30   1 10   Y /     -- becomes a Y-trending segment
  'F_curved'   12 12  30 40   1 10   X /     -- back to X-direction
/
MULTFLT
  'F_curved'  0.05 /                          -- one multiplier applies to all four
/
```

All four records share the name `'F_curved'` and are treated as one fault by MULTFLT.

## Wildcards for fault families

If you have many faults of one geological type:
```
FAULTS
  'F_NS_1'  ... /
  'F_NS_2'  ... /
  'F_NS_3'  ... /
  'F_EW_1'  ... /
/

MULTFLT
  'F_NS*'  0.001 /          -- all NS-trending: strongly sealing
  'F_EW*'  0.3   /          -- all EW-trending: leaky
/
```

## Variable sealing along strike

Different segments need different multipliers → name them differently:
```
FAULTS
  'F_seal'   10 10   1 25   1 10  X /
  'F_leak'   10 10  26 50   1 10  X /
/
MULTFLT
  'F_seal'   0.001 /
  'F_leak'   0.3   /
/
```

## Re-activating a fault over time (depletion)

```
SCHEDULE
  -- initial period
  TSTEP  10*30 /
  
  -- fault re-opens after pressure drops:
  MULTFLT
    'F_main'  100 /         -- multiplies current Tx by 100
  /
  
  TSTEP  10*30 /
```

Cumulative — so if MULTFLT in GRID set it to 0.001, after this step the effective multiplier is 0.001 × 100 = 0.1.

## Sealing fault in a DUALPORO model

`NDIVIZ = 8` (4 matrix + 4 fracture layers):
```
RUNSPEC
  DUALPORO
  DIMENS  50 50 8 /
  FAULTDIM 5 /

GRID
  -- ... COORD, ZCORN, SIGMA, etc. ...
  
  FAULTS
    'F1'  10 10  1 50  1 8  X /         -- COVER ALL 8 K-LAYERS
  /
  
  MULTFLT
    'F1'  1e-4 /
  /
```

Under DUALPORO, matrix has no lateral flow, so only the fracture-fracture face Tx is affected — but specifying the full K range is harmless and future-proofs the model if you later switch to DUALPERM.

## Sealing fault in a DUALPERM model (critical!)

Under DUALPERM, matrix-matrix flow IS active. Must seal both:
```
DUALPERM     -- not DUALPORO

FAULTS
  'F1'  10 10  1 50  1 8  X /           -- MUST cover all 8 K-layers
/
MULTFLT
  'F1'  1e-4 /
/
```

If you missed the matrix half (`K = 1..4`), matrix fluid leaks across the fault and the model gives wrong production.

## Region-to-region barrier (stratigraphic, not geometric)

```
RUNSPEC
  GRIDOPTS  YES  3  /                    -- enable, reserve 3 MULTNUM regions

GRID
  MULTNUM
   -- per cell, label 1, 2, or 3:
   ... NX*NY*NZ values ... /
  
  MULTREGT
    1   2   0.001   XYZ   ALL   M /     -- regions 1↔2: TX·0.001 all dirs
    1   3   0.5     Z     ALL   M /     -- regions 1↔3: TXZ only ×0.5
  /
```

Region map can be from a stratigraphy interpretation, not necessarily a fault.

## Adding a bypass channel (high-perm conduit)

```
GRID
  NNC
  --   IX  IY  IZ      JX  JY  JZ      TRAN
       12  20   3      14  20   3      1500.0  /     -- connect (12,20,3)↔(14,20,3) with high Tx
       12  20   4      14  20   4      1500.0  /
       12  20   5      14  20   5       800.0  /     -- weaker further down
  /
```

Adds Tx between cells that are not geometric neighbours. If they *are* neighbours, Tx ADDS to the existing value.

## Individual NNC tweaks (history match outlier)

You found that one specific NNC needs adjustment from a sensitivity study:
```
EDIT
  EDITNNC
  --  IX  IY  IZ    JX  JY  JZ      TRANM
      9   10  3     11  10   3      5.0    /       -- × 5
      15  25  6     16  25   6      0.0    /       -- kill
      12  30  4     12  31   4      0.25   /       -- ×0.25
  /
```

## Replace an NNC outright

If your analysis gives you an authoritative Tx value:
```
EDIT
  EDITNNCR
    12  20   3     12   21   3     75.4 /
  /
```

Replaces the geometric Tx with 75.4 regardless of what the formula computed.

## Direct face Tx (import from external tool)

```
EDIT
  TRANX
    -- one value per cell ...
  /
  TRANY
    ... /
  TRANZ
    ... /
```

Overrides face transmissibilities. Place MULTFLT BEFORE TRANX/Y/Z if you want the multiplier to still apply.

## Pinchout bridging (typical stratigraphic model)

```
GRID
  PINCH
   0.001   GAP   1e20   TOPBOT  /
```

- Threshold: cells thinner than 0.001 are pinched out
- GAP: even if pinched cells are MINPV-inactive, NNCs are built across them
- 1e20: no maximum gap distance
- TOPBOT: pinchout Tx = half-cell harmonic of the cells above and below

## High-quality diagnostic recipe

```
GRID
  ... your geometry ...
  RPTGRID
    FAULTS  ALLNNC  TRANX  TRANY  TRANZ  MULTX  MULTY  MULTZ  /

EDIT
  -- ... no edits, just inspect ...

SCHEDULE
  TSTEP  /                              -- zero time steps
END
```

Run this; check the PRT file for:
- Total NNC count (should match the visual estimate)
- Fault segments parsed correctly
- Multipliers along the fault have the expected values

---

## Anti-recipes (don't do this)

### Don't combine block-centred input with NEWTRAN
```
GRID
  DX 100*50 / DY 100*50 / DZ 100*30 / TOPS 100*2000 /
  NEWTRAN /     -- ← WRONG: assumes flat blocks; creates many spurious NNCs
```
Use OLDTRAN with DX/DY/DZ, or switch to COORD/ZCORN for NEWTRAN.

### Don't use MULTFLT = 0
```
MULTFLT 'F1' 0 / /        -- ← causes Tx < 1e-6 → NNC dropped silently
```
Use `1e-4` instead — keeps the connection in the solver, you can change later.

### Don't use FAULTS to "define" a fault that isn't in ZCORN
```
GRID
  -- block-centred DX/DY/DZ grid (no offset cells)
  FAULTS  'F1' ... /        -- ← labels nothing; MULTFLT has nothing to multiply
```
Faults must already exist as ZCORN offsets.

### Don't EDITNNC a DP σ-NNC
```
DUALPORO
...
EDIT
  EDITNNC  5 5 3   5 5 7   0.5 /        -- ← silently ignored (E100 may warn)
/
```
Use `SIGMAV` or `MULTSIGV` instead.

### Don't apply MULTFLT after TRANX in EDIT
```
EDIT
  TRANX ... /
  MULTFLT  'F1' 0.001 /                 -- ← MULTFLT applies to NNCs but not to face Tx already set by TRANX
```
Place MULTFLT *before* TRANX (or use TRANX values that already include the desired reduction).

### Don't forget GRIDOPTS YES when using MULTX-
```
GRID
  MULTX-  ...  /                        -- ← rejected unless GRIDOPTS YES in RUNSPEC
```
