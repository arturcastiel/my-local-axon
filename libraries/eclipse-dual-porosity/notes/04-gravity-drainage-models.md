# 04 — Gravity drainage: GRAVDR vs GRAVDRM vs GRAVDRB

Three models, increasing complexity. Pick the simplest that explains the observed (or expected) behaviour.

## Why this matters
For a gas-cap or gas-injection scenario in a fractured reservoir, **gravity drainage is THE production mechanism from the matrix**. Without it, gas in fractures → no oil from matrix (the wetting-phase argument, see notes 03).

The pace of gravity drainage is also typically much *slower* than imbibition (the displaced fluid only moves vertically, not in all three directions), so a single σ value cannot match both processes.

## Model 1: GRAVDR — Standard gravity drainage
> "Consider each of the matrix and fracture cells as separately in vertical equilibrium, then calculate additional potential due to differences in contact heights" (TD p.104)

- Number of porosities in the grid: 2 (just like DUALPORO without gravity)
- Pseudo capillary pressures (per phase) are added to encode the gravity head between matrix and fracture (TD Eq. 2.57–2.58)
- Required input: `DZMTRX` (or `DZMTRXV`) in the GRID section — height of a typical matrix block
- Used with: SIGMA (capillary-driven flow) and optionally SIGMAGD (gravity-driven flow)
- Init issue: the initial reservoir state is computed *without* considering gravity-drainage forces. If activating gravity drainage produces a large initial transient (fluid redistribution at t=0), use OPTIONS item 11 to make the initial solution a true steady state (modifies phase pressures for the duration of the run).

### What GRAVDR is good for
- Most gas-cap or gas-injection scenarios in water-wet fractured reservoirs
- Cases where matrix block height is small compared to simulation cell height (block-averaged behaviour dominates)
- First-pass DP studies

### Limitations
- Vertical equilibrium assumption within both matrix and fracture cells is implicit — doesn't resolve the saturation profile inside a tall matrix block
- Only one sigma per cell — gas-drainage zones and water-imbibition zones share a single σ (unless SIGMAGD is also set)

---

## Model 2: GRAVDRM — Quandalle-Sabathier formulation

> Based on Quandalle and Sabathier (1989). Decomposes matrix-fracture flow into three components (TD p.107):
> ```
> q = q_h + q_up + q_down
> ```

### Equations (TD Eqs. 2.68–2.71)
- Horizontal: `q_h = T_sigma · λ_h · (Φ_f − Φ_m)` — uses SIGMA Tx, upstream mobility, no gravity head
- Up: `q_up = T_sigmagd · λ_up · ((Φ_f − Φ_m) + (ρ_oil − ρ_phase)·g·DZmat/2)` — uses SIGMAGD Tx
- Down: `q_down = T_sigmagd · λ_dn · ((Φ_f − Φ_m) − (ρ_oil − ρ_phase)·g·DZmat/2)` — uses SIGMAGD Tx

Net: horizontal flow uses one transmissibility (capillary-dominated), vertical flow uses another (gravity-dominated). The upstream direction is determined cell-by-phase using the sign of the *total* potential difference including the gravity term.

### When GRAVDRM is better than GRAVDR
- Mixed-wettability systems (some matrix is oil-wet, some water-wet)
- When a finely-gridded matrix-block reference model shows different horizontal vs vertical transfer rates
- When you want explicit independent control of vertical and horizontal sigmas

### Watch out: the re-infiltration trap
GRAVDRM has ONE input item: `Allow re-infiltration YES/NO`. With YES (default), oil that has left the matrix can flow back in. The TD warns (p.109):

> "One drawback with this formulation is that the final recovery from a block can become a function of the transmissibility in the case when the final recovery is given by q=0 when the vertical flows balance the horizontal..."

In plain English: if you allow re-infiltration, your final recovery depends on the *rate* (which is fitting-parameter-dependent), not just the *final equilibrium* (which is physically determined). Setting re-infiltration = NO eliminates this and gives a more predictable final recovery.

Practical recommendation: try NO first. Turn YES on only if you have physical reason to believe re-imbibition is real (e.g. capillary force can pull oil back into a small block).

### GRAVDRM supersedes GRAVDR
If both are present in RUNSPEC, GRAVDRM wins. So you don't have to remove GRAVDR if you want to switch.

---

## Model 3: GRAVDRB — Vertical discretized matrix
Used when the matrix block is tall enough that the *vertical saturation profile inside the block* matters. The block is subdivided into a stack of N matrix sub-cells (set by NMATRIX), each connected to the *same* fracture cell but at a different height.

### How it works
- Activate by: `NMATOPTS VERTICAL ...` + `GRAVDRB` in RUNSPEC
- NMATRIX sets N (number of vertical sub-cells)
- DZMTRX sets the *total* matrix block height; sub-cells partition this height
- For each NNC (matrix sub-cell ↔ fracture), the fracture properties are altered to reflect the gravitational potential and any phase discontinuity *at that height*
- The matrix sub-cells communicate with each other vertically as well

### When to use
- Tall matrix blocks (vertical Pc variation matters)
- Cases where the front of water/gas inside a single matrix block has a definite saturation profile that GRAVDR would homogenize away
- Eclipse 100 only

### Restrictions
- Eclipse 100 only
- Not compatible with: parallel solver, LGRs, dual permeability, classical GRAVDR/GRAVDRM
- Must use EQUIL for initialisation
- DIMENS NX ≥ 2

---

## Model selection decision tree

```
Is gravity drainage important?  (gas in fractures, gas cap, gas inj)
├── NO  → skip all of this; rely on imbibition (just DUALPORO + matrix Pc)
└── YES → 
    │
    Are matrix blocks "small" relative to simulation cells?
    ├── YES → GRAVDR + DZMTRX
    │         Consider SIGMAGD if gas-zone vs water-zone σ should differ
    │
    └── NO  →
        │
        Do you need different horizontal & vertical transfer rates?
        ├── YES → GRAVDRM (Quandalle-Sabathier)
        │         Try re-infiltration = NO first
        │
        └── NO  → Is the matrix block tall enough that intra-block saturation profile matters?
                  ├── YES → GRAVDRB + NMATRIX + NMATOPTS VERTICAL
                  └── NO  → GRAVDR (simpler, faster)
```

## DZMTRX deep dive
The KEY input for all three gravity models. Common mistakes:

1. **Setting DZMTRX = simulation cell DZ.** No. DZMTRX is the height of a PHYSICAL matrix block (the unfractured rock between two horizontal fractures), often much smaller than the simulation cell DZ. Typical values: 1–10 ft.

2. **Forgetting to set DZMTRX.** Default is 0 → no gravity drainage even though GRAVDR is on. Eclipse won't error; just won't drain.

3. **Setting DZMTRX in fracture layers.** DZMTRXV is required only in the first NDIVIZ/2 layers (matrix). Values in fracture layers are ignored. When OUTPUT is requested via RPTGRID, Eclipse copies matrix → fracture for display.

## Sigma defaults to be aware of
- SIGMA / SIGMAV: default 0 → no matrix-fracture coupling at all. Always set one or use LTOSIGMA.
- SIGMAGD / SIGMAGDV: default → fall back to SIGMA values.
- DZMTRX: default 0 → no gravity drainage.
- LTOSIGMA + LX/LY/LZ: if these are all set, ignores SIGMA/SIGMAGD explicit values.

## Eclipse 100 vs Eclipse 300 — gravity drainage differences
- E100: GRAVDR/GRAVDRM/GRAVDRB available. SIGMAGD acts as a *switch* (used when gas-drainage conditions hold).
- E300: GRAVDR/GRAVDRM available, GRAVDRB not. SIGMAGD smoothly interpolates between SIGMA and itself based on relative magnitudes of capillary vs gravity potentials (Eq. 2.60–2.61).
- E300 default permeability for SIGMAGD-based Tx is *Z*-perm (post-99A); E100 still defaults to X-perm unless OPTIONS item 70 changes it (reverse direction of the change).

## Cross-checking the gravity drainage in your model
1. Print SIGMA and DZMTRX with RPTGRID — verify reasonable values
2. Compare to a finely-gridded single-porosity reference simulation of a single matrix block
3. Match final recovery and recovery vs time using DPKRMOD if needed
4. If history match requires non-physical DPKRMOD, you may be using the wrong gravity model
