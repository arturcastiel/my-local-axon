# 03 — Recovery mechanisms from a matrix block

The matrix holds the oil. The fracture network sweeps fluids past the matrix but does *not* directly displace its contents — the matrix is a stationary source. So what gets the oil out?

Eclipse enumerates five mechanisms (TD pp.103-110, fig 2.18):

1. Oil expansion
2. Imbibition (water-wet, capillary-driven)
3. Gravity imbibition / drainage
4. Diffusion
5. Viscous displacement (Eclipse 100, VISCD keyword)

Each is a different physical process. The dominant one depends on fluid system, wettability, fracture-network pressure gradient, and whether gas or water is in the fracture.

---

## 1. Oil expansion
**Mechanism**: as pressure drops in the fracture (production), oil flows out of the matrix to equilibrate pressure with the surrounding fracture. Conceptually: expansion of the oil column inside the matrix block. Above the bubble point: pure expansion. Below: solution-gas drive within the matrix.

**No special keyword.** Always active — it's just the standard matrix-fracture flow driven by pressure difference, mediated by the SIGMA transmissibility.

**Limit**: produces only a few percent recovery; pressure drop alone is rarely enough to evacuate a matrix block.

---

## 2. Imbibition (capillary-driven)

### Water-wet system, water-oil
Water in the fracture sees a *positive* matrix water-oil capillary pressure and is sucked into the matrix, displacing oil. This is the "water imbibition" recovery mechanism — typically the strongest in a waterflood of a water-wet fractured reservoir.

Modelled via SATNUM regions:
- Matrix SATNUM → has water-oil Pc curve (typical)
- Fracture SATNUM → has zero Pc (open fractures don't hold capillary forces)

**Without gravity drainage**, production continues only until matrix oil saturation reaches Sor. There's no extra mechanism to pull out the rest.

### Gas-oil systems (still water-wet rock)
Oil is the *wetting* phase relative to gas — oil tends to imbibe INTO the matrix. So **a fracture cell full of gas produces zero oil from the associated matrix cell** if the gravity drainage model is inactive.

This is a critical pitfall: in a gas-cap or gas-injection scenario, you must activate GRAVDR or GRAVDRM, or the gas-swept zones will produce nothing from the matrix.

### Optional matrix-fracture saturation table
`KRNUMMF` (REGIONS section): specifies a SEPARATE relative permeability table for matrix-fracture flow. Use when fracture-to-matrix flow should not use the fracture's own kr (e.g. so the maximum kr is the matrix kr at residual displaced phase). Companion: `IMBNUMMF` for the imbibition table (when hysteresis is active).

`DPKRMOD` item 3 (`YES`) is a simpler approach that scales the fracture kr to the matrix kr_max at the displaced-phase residual saturation — no separate table needed.

---

## 3. Gravity imbibition / drainage

Density contrasts produce a pressure differential between fluid in the matrix vs fluid in the fracture. Even after capillary forces have done their work, gravity continues to drain dense fluid down and let light fluid (gas) up.

The pressure difference due to gravity (TD Eq. 2.57):
```
Δp = ρw·g·DZmat · (Xf − Xm)
```
- ρw — water density
- DZmat — vertical height of a typical matrix block (NOT the simulation cell DZ!) — set via `DZMTRX` or `DZMTRXV`
- Xf — fractional height of the water table inside the fracture
- Xm — fractional height of the water front inside the matrix

Eclipse implements this by *pseudo capillary pressures*. For each phase and each cell (matrix or fracture), an additive Pc term is computed (TD p.105):
```
Pc_pseudo (frac) = DZmat · (Xf − Xm) · (ρ_phase − ρ_oil) · g     [or similar per phase]
Pc_pseudo (matrix) = DZmat · (Xf − Xm) · (ρ_phase − ρ_oil) · g
```
These get added to the saturation-function Pc when computing the matrix-fracture flow.

### Three flavours of gravity drainage

| Keyword | Method | Use when |
|---------|--------|---------|
| `GRAVDR`  | Standard model — matrix and fracture each in vertical equilibrium, single sigma | Default; good first try |
| `GRAVDRM` | Quandalle & Sabathier (1989) — flow decomposed into horizontal + up + down components, separate vertical & horizontal sigmas | Mixed-wettability systems, or when a fine-grid matrix-block reference gives different vertical vs horizontal transfer |
| `GRAVDRB` | Vertical discretized matrix — chain of matrix sub-cells connected to one fracture, each at a different vertical position | When matrix block is *tall* and vertical Pc variation matters |

**`DZMTRX` / `DZMTRXV` is REQUIRED in the GRID section when any of these is active.** Default 0 disables the effect. Strength scales linearly with DZmat.

### GRAVDRM — Quandalle & Sabathier
The matrix-fracture flow is split into three pieces (TD p.107-108, Eqs. 2.68-2.71):
```
q = q_h + q_up + q_down
```

- Horizontal: `q_h = T_sigma · λ_h · (Φ_f − Φ_m)` — uses the **SIGMA**-based Tx
- Vertical (up and down): use the **SIGMAGD**-based Tx, plus an explicit gravity head term

No interpolation between SIGMA and SIGMAGD in this model (unlike E300 with GRAVDR).

The model has one input item: `Allow re-infiltration YES/NO`. YES (default) → oil can flow back into the matrix (re-imbibition). NO → oil only flows out. Setting NO gives a more predictable final recovery (TD p.109): with re-infiltration on, the final recovery depends on transmissibility, which is generally not what you want as a physical answer.

### GRAVDRB — Vertical discretized (Eclipse 100, NMATOPTS = VERTICAL)
Each matrix block is sub-divided vertically into a stack of N matrix cells (set by NMATRIX). ALL N cells connect to the same fracture cell, but each at a different height. The fracture properties (potential, saturations) are altered per-NNC to reflect the local conditions at each height. Net effect: the matrix block has a *resolved* vertical saturation profile, capturing the segregation that occurs in a tall block.

**Restrictions**: cannot be used with regular gravity drainage models (GRAVDR/GRAVDRM), with LGRs, with parallel solver, or with dual permeability. Initialisation MUST use EQUIL.

---

## 4. Diffusion
Molecular diffusion of gas and oil components between matrix and fracture. Important when:
- Component contrasts are large (e.g. gas injection — light components diffuse into oil)
- Matrix permeability is so low that pressure-driven flow is negligible
- Long residence times (production over decades)

Activated by the standard Eclipse diffusion option. For DP runs:
- `DIFFDP` (RUNSPEC): restrict diffusion calc to matrix-fracture flow only (assume fracture diffusion is negligible compared to fracture pressure flow). Speed optimisation.
- `DIFFMMF` (GRID and SCHEDULE): multiplier on the matrix-fracture diffusivity itself.

---

## 5. Viscous displacement (Eclipse 100, VISCD keyword)

**Mechanism**: when the fracture has a significant pressure gradient (G), the matrix doesn't just see the *average* fracture pressure — it sees a *gradient*. If `P_m` is between `P1` (upstream fracture pressure) and `P2` (downstream), oil can flow *into* the matrix at one end and *out* at the other end. This is viscous "sweeping" of the matrix by the fracture pressure gradient.

Gilman & Kazemi (1988) showed this can be written as a standard matrix-fracture flow with modified upwinding plus an extra viscous term:

```
q = (T/2)·λ_f·(Φ_f − P_m2) − (T/2)·λ_m·(P_m2 − Φ_f) + (L/4)·T·λ·(λ_f − λ_m)        (TD Eq. 2.77)
```

The fracture potential gradient G is estimated from adjacent-cell potential differences (using last timestep's values).

### Setup
- `VISCD` in RUNSPEC
- `LX`, `LY`, `LZ` in GRID — representative matrix block sizes
- `LTOSIGMA` in GRID — computes σ from L_x,y,z (any explicit SIGMA values are then ignored)

### When to use
When the fracture-network effective permeability is *moderate* rather than infinite — there's a real fracture pressure gradient that can sweep the matrix. Often for tight or partially-fractured systems.

---

## Mechanism × wettability decision table

| Reservoir state | Dominant mechanism | Required keywords |
|-----------------|--------------------|--------------------|
| Water-wet, waterflood, water in fracture | Imbibition (capillary) | DUALPORO + SATNUM (matrix kr/Pc) |
| Water-wet, gas cap, gas in fracture | Gravity drainage | DUALPORO + GRAVDR + DZMTRX |
| Water-wet, mixed wetting (some matrix oil-wet) | Mixed; gravity dominant in oil-wet zones | DUALPORO + GRAVDRM + DZMTRX (consider re-infiltration=NO) |
| Tight matrix, long residence | Diffusion | DUALPORO + DIFFUSE option + DIFFDP |
| Partially fractured | Viscous displacement | DUALPORO + VISCD + LX/LY/LZ + LTOSIGMA |
| Composite (multiple processes) | Possibly all of the above; sigma is a fitting parameter | Match σ to history, consider SIGMAGD for gas-zone vs water-zone differentiation |

---

## Modifying the recovery-vs-time response: DPKRMOD
The *shape* of the recovery curve between t=0 and t=∞ is governed by the matrix relative permeability function for the matrix-fracture flow. To match a finely-gridded single-porosity reference model, the simplest knob is `DPKRMOD`:
- 1st item: `mw` — modification parameter for oil-in-water kr (range -1 to 1)
- 2nd item: `mg` — same for oil-in-gas kr
- 3rd item: `YES`/`NO` — scale fracture kr for fracture-to-matrix flow to reflect matrix kr at residual displaced-phase saturation

The function is a quadratic that preserves end-points and the midpoint value but bends the curve. `m > 0` boosts kr at low oil saturation; `m < 0` lowers it.

**Warning**: this is a tuning parameter, not a physical quantity (TD p.116 — "not a physical quantity and should be regarded only as a tuning parameter").

---

## Integrated Pc option (INTPC)
A subtle but important option for gravity-drainage cases: the rock Pc curve (single-saturation-point function) does not exactly determine the *average* recovery from a block of finite height. Eclipse integrates the rock Pc over the matrix block height to produce a *modified* Pc curve such that:
- the equilibrium saturation produces a Pc = the gravity head for that height
- final recovery from the dual-porosity matrix cell matches the continuous matrix medium answer

Activated by `INTPC` in PROPS section with one argument: `WATER`, `GAS`, or `BOTH` (default). Modified curves can be inspected via SWFN/SGFN mnemonics in RPTPROPS.

Required only in DUALPORO + GRAVDR/GRAVDRM runs. Was discouraged for GRAVDRM in pre-2007.1 versions, now safe.
