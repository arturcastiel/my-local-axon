# 05 — Cross-reference: how DP/DK σ-NNCs interact with fault NNCs

> Companion to `eclipse-dual-porosity/`. Read that library first if you're new to DP/DK.

## The two NNC species in a DP/DK run

A DUALPORO or DUALPERM run can have **both** kinds of NNC simultaneously. They are *architecturally identical* (rows in the same Jacobian, same solver) but *user-facing distinct* (different keywords edit them, different formulas built them).

| Property | σ-NNC (DP/DK matrix↔fracture) | Fault NNC (corner-point geometry) |
|----------|-------------------------------|-----------------------------------|
| Built by | DUALPORO / DUALPERM + SIGMA(V) | COORD/ZCORN overlap |
| Formula | `T = CDARCY · σ · K · V` (Kazemi) | `T = CDARCY · TMLT / (1/T_i + 1/T_j)` (NEWTRAN) |
| Direction | "Vertical" between co-located matrix and fracture cells | "Horizontal/lateral" between offset adjacent cells |
| Crosses lateral faults? | No — σ-NNC is in-place | Yes — that's the whole point |
| Edited by | SIGMAV, MULTSIG(V), SIGMAGD(V), MULSGGD(V) | MULTFLT, EDITNNC, EDITNNCR, MULTREGT |
| EDITNNC applies? | ✗ (RM p.724) | ✓ |
| Appears in RPTGRID ALLNNC? | ✓ | ✓ |
| Removed by inlining? | ✗ (always present) | ✓ (can be inlined when geometry collapses) |

## Geometric picture

```
                          Physical reservoir
              ┌────────────────────────────────────────────┐
              │              fault plane                   │
              │   ┌─────────┐ ┃ ┌─────────┐                │
              │   │   M     │ ┃ │   M     │                │
              │   │ matrix  │ ┃ │ matrix  │                │
              │   │ block   │ ┃ │ block   │                │
              │   └─────────┘ ┃ └─────────┘                │
              │   ┌─────────┐ ┃ ┌─────────┐                │
              │   │   F     │ ┃ │   F     │                │
              │   │fracture │ ┃ │fracture │                │
              │   │ block   │ ┃ │ block   │                │
              │   └─────────┘ ┃ └─────────┘                │
              └────────────────────────────────────────────┘

  (i,j,k_matrix)  ──── σ-NNC ────  (i,j,k_fracture)        ← in-place coupling
   (left col)                       (left col)

  (i,j,k_fracture)  ── fault NNC ── (i+1,j,k_fracture)     ← across the fault
   (left col)                        (right col, offset by throw)

  (i,j,k_matrix)  ──── fault NNC ── (i+1,j,k_matrix)        ← under DUALPERM only
   (left col)                        (right col)
```

So in a 2-column DUALPERM model with one fault:
- 2 σ-NNCs (one matrix↔fracture per column)
- 1 fracture-fracture fault NNC (across the offset)
- 1 matrix-matrix fault NNC (DUALPERM only — across the offset)

All four show up in `RPTGRID ALLNNC`.

## Implication 1 — Sealing a fault in DP vs DK

Under **DUALPORO**: matrix cells already have no neighbours. Sealing the fault only affects the *fracture* fault NNCs. Specifying `FAULTS` with K covering all layers (matrix half + fracture half) is harmless but ineffective on the matrix side — the matrix cells have no matrix-matrix Tx to multiply.

Under **DUALPERM**: matrix-matrix Tx is real. The fault must seal *both* matrix and fracture. Specify the FAULTS K range over the full NDIVIZ:

```
DUALPERM
...
FAULTS
   'F1'   10 10   1 50   1 8   X /        -- NDIVIZ = 8: layers 1-4 matrix, 5-8 fracture
/
MULTFLT
   'F1'   1e-4 /
/
```

If you accidentally only cover K=5..8 (fracture half), DK matrix flow leaks across the fault → fault doesn't really seal → reservoir pressures equalise → wrong production curves.

## Implication 2 — `EDITNNC` cannot touch σ-NNCs

If you want to override the σ-NNC transmissibility for specific (i,j,k) matrix cells:
- **Wrong tool**: `EDITNNC` — will be silently ignored (RM p.724)
- **Right tool**: `SIGMAV` for per-cell shape factor, or `MULTSIGV` for a per-cell multiplier

```
GRID
  SIGMAV
    -- NX*NY*(NDIVIZ/2) values, in matrix layers only:
    100*0.12   100*0.30   100*0.08   100*0.50 /
/
```

or:
```
GRID
  SIGMA  0.12 /
  MULTSIGV
    -- multiplier per cell:
    100*1.0   100*2.5  ...  /
/
```

## Implication 3 — `MULTFLT` doesn't touch σ-NNCs

`MULTFLT` applies to "transmissibilities across named fault faces." σ-NNCs are *not* across a fault face — they connect matrix cell (i,j,k) to fracture cell (i,j,k+NDIVIZ/2), which lie in the same (i,j) column, just in different K-layers. They are not on any face designated as X/Y/Z. So MULTFLT silently has no effect on σ-NNCs.

If you want to modify σ-coupling along a fault trace, you have to spatially define a region and use `MULTSIGV` per cell in that region. Or use `BTOBALFA`/`BTOBALFV` if the goal is to add block-to-block connections (different thing).

## Implication 4 — Pinch-outs and DP

`PINCH` bridges across vanished layers via geometric NNCs in the *fracture* grid (since the fracture grid is what behaves like a regular reservoir). Pinch-out logic doesn't directly affect σ-NNCs.

If a matrix layer pinches out, its corresponding fracture layer might still be active (or vice versa) — Eclipse handles this via the standard PINCH machinery on the fracture half. Just be aware that the NDIVIZ-doubling assumption can get awkward in heavily pinched corner-point grids.

## Implication 5 — LGRs and DP

Within an LGR under DUALPORO:
- σ-NNCs are built between matrix and fracture sub-cells of the LGR (NDIVIZ/2 rule applies *inside* the LGR — `CARFIN` item 10)
- Fault NNCs across the LGR ↔ parent boundary use NEWTRAN
- The two NNC families coexist as usual

Restriction: discretized matrix (`NMATRIX`) is incompatible with LGRs (see DP library notes).

## Implication 6 — Block-to-block (BTOBALFA) is *not* a fault NNC

`BTOBALFA` enables a connection between *lower matrix* and *upper fracture* cells when they're physically co-located but normally disconnected. This is a DP-specific feature, not a fault feature. The Tx formula:

```
T_b2b  =  α · CDARCY · 2·A_ij / (DD_i/K_i + DD_j/K_j)
```

where α is the BTOBALFA contact-area multiplier and the rest is standard spatial Tx. NOT a fault NNC. Activated by including `BTOBALFA` (default value α else activates with the input value).

Confusingly *also* lives in RPTGRID ALLNNC output. Cross-check the NNC table against the keyword list to identify which species each NNC is.

## Implication 7 — `RPTGRID ALLNNC` shows everything

When you print all NNCs, expect to see a *lot*:
- Every σ-NNC (one per matrix cell × NDIVIZ/2 layers)
- Every fault NNC
- Every pinch-out NNC
- Every aquifer NNC
- Every BTOBALFA NNC
- Plus any user-defined NNC keyword entries

In a 100×100×10 DUALPORO model (NDIVIZ=20, so 100×100×10 matrix cells + 100×100×10 fracture cells), you'll see ~100,000 σ-NNCs even before any faults. Filter the .PRT output for the cell ranges you care about; don't try to read the whole table.

## When to consult both libraries simultaneously

| Question | Both libraries |
|----------|---------------|
| How do I model a fractured reservoir with sealing faults? | Yes |
| How do I seal a fault in a DP/DK model? | Yes (this note section) |
| How do I add a bypass channel inside a DP/DK fracture network? | Yes (use `NNC` keyword from this library; geometry from DP) |
| How do I edit per-cell matrix-fracture coupling along a fault? | Yes (use `SIGMAV` or `MULTSIGV`, never `EDITNNC`) |
| How do I model a discrete fault inside a DP fracture continuum? | Yes — the fault may need separate `CONDFRAC` handling if it's larger than the DP fracture-network scale (see DP library notes on single-medium conductive fractures) |

## Three-scale fracture taxonomy (recap)

1. **DP fractures**: statistical continuum, σ-coupled, every cell pair, NDIVIZ-doubled → `DUALPORO`/`DUALPERM` + this library for any fault editing
2. **Single-medium conductive fractures**: m-scale, individually mapped, single-grid → `SCFDIMS` + `CONDFRAC` (see DP library notes)
3. **Faults**: geometric displacements, named, transmissibility-edited → `FAULTS` + `MULTFLT` (this library)

These can coexist. A real field model might have all three: a fractured carbonate (DP) cut by a discrete conductive fracture (SCFDIMS) and crossed by a major sealing fault (FAULTS + MULTFLT). Eclipse can do it. But you must understand which scale your "fracture" is at and use the right keyword family.
