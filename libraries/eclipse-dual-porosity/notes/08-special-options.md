# 08 — Special options: INTPC, DPKRMOD, BTOBALFA, NODPPM, VISCD, DIFFDP

> Six keywords that aren't strictly required but often matter for realistic studies.
> Each: when needed, what it does mathematically, common pitfalls.

---

## INTPC — Integrated capillary pressure
**Section**: PROPS. **Required input**: 1 record `WATER | GAS | BOTH /` (default BOTH).

### What it solves
Without INTPC, the matrix's Pc curve is used at face value. But the rock Pc curve is a *single-point function*: Pc(S) = the capillary pressure at a saturation S. For a matrix block of finite height h, the *average* saturation depends on the rock Pc *integrated over height*:
```
S̄g(h) = (1/h) · ∫₀^h Pc⁻¹(ρg·g·z) dz                 (TD Eq. 2.89)
```

INTPC constructs a *modified* Pc curve such that:
- The capillary pressure at average saturation S̄g equals the gravity drainage head for a block of height h with saturation S̄g
- The equilibrium saturation (where matrix and fracture are at the same total potential) gives the *correct* final recovery from the continuous matrix medium

### When you need it
- DUALPORO + GRAVDR or GRAVDRM
- Recovery matching with a single-porosity reference shows the DP final saturation is wrong (but the rate is fine)

### Gotcha
Pre-2007.1 versions discouraged INTPC + GRAVDRM (the pseudoisation wasn't compatible). Modern versions automatically pseudoise for GRAVDRM. To restore old behaviour: OPTIONS item 107 (E100) or OPTIONS3 item 126 (E300).

### Output
Modified Pc curves can be printed via SWFN/SGFN mnemonics in RPTPROPS — inspect to verify they look reasonable.

---

## DPKRMOD — Matrix oil-Kr modification
**Section**: PROPS. **Per-SATNUM**: NTSFUN records, each 3 items.

### What it solves
The *shape* of the recovery-vs-time curve depends on the matrix oil kr at intermediate saturations. The standard rock kr may give the right end-points but the wrong curve shape — especially when matching a fine-grid single-porosity reference.

### Mathematical form
For mw > 0:
```
k_r(s) = k_rT + g(s)·(k_M − k_rT)        (Eq. 2.79)
```
Where:
- k_rT is the table kr value
- k_M is the kr at the midpoint saturation s_mid = (SOWCR + 1 − SWCO)/2
- g(s) is a quadratic: g(s) = 4·mw·s² − 4·mw·s + 1

mw > 0: boosts kr at low S_o, lowers at high S_o.
mw < 0: same shape but axes flipped.

End-points and the midpoint kr value are preserved. The curve shape *between* them is bent.

### Three input items
1. mw — for oil-in-water (range -1 to 1)
2. mg — for oil-in-gas (range -1 to 1)
3. YES/NO — also scale fracture kr for F→M flow (so fracture kr_max = matrix kr at residual displaced phase)

### When to use
- Matching a single-block lab experiment when end-points are right but rate is wrong
- History-matching a synthetic fine-grid reference

### When NOT to use
- As a primary fitting parameter for production data. The TD calls it explicitly a "tuning parameter, not a physical quantity." Large DPKRMOD values (|m| > 0.7) are a red flag.

### Item 3 alternative
KRNUMMF (REGIONS) provides full flexibility — a separate kr table for matrix-fracture flow. DPKRMOD item 3 = YES is the cheap shortcut.

---

## BTOBALFA / BTOBALFV — Block-to-block connections
**Section**: GRID.

### What it solves
By default, fracture cells connect to ONLY their underlying matrix cell. But when physical matrix blocks are about the same size as the simulation grid cells, the lower matrix cell physically touches the *upper* fracture cell as well. This off-grid connection is missed by default.

### What the keyword does
Activates a new transmissibility between *non-co-located* matrix and fracture cells:
- BTOBALFA: single contact-area multiplier for the whole grid (1 value)
- BTOBALFV: per-cell area multiplier
- Setting *either* keyword activates the connection (otherwise it doesn't exist)
- The transmissibility uses the standard spatial Tx formula (not σ·K·V) — properties of both cells contribute (TD p.102)

### Geometry (TD fig 2.17)
- The lower matrix cell connects to the upper fracture cell with this new Tx
- A contact-area multiplier (BTOBALFA value) accounts for the partial overlap

### When to use
- Matrix block size ≈ grid cell size
- "Re-imbibition" scenarios where lower matrix should see flow from upper fracture

### Restrictions
- Incompatible with multi-porosity (NMATRIX > 1 or TRPLPORO)
- DPNUM regions: block-to-block doesn't apply

### Gotcha
Without BTOBALFA, the model artificially decouples nearest-neighbour matrix from the fracture above. With BTOBALFA, you've added unphysical connections if block size is small relative to cell size. Use only when geometrically justified.

---

## NODPPM — No dual-porosity permeability multiplier
**Section**: GRID. **No data**.

### What it solves
By default, Eclipse multiplies your fracture PERMX/Y/Z values by the fracture POROSITY:
```
K_frac_effective = K_frac_input × φ_frac
```
The intent: input is "raw fracture-only permeability" (huge — 10⁵+ md inside an actual fracture). To get the *effective* per-cell permeability, multiply by the fracture's volume fraction (φ_frac).

### When NODPPM is needed
If your input is *already the effective per-cell permeability* (e.g. from upscaling, from a geocellular model, from a previous run), the multiplication is wrong. Use NODPPM to skip it.

### How to tell which case you're in
- Fracture permeabilities ~10⁵ md, fracture porosities ~0.001 → raw (don't use NODPPM)
- Fracture permeabilities ~10² md, fracture porosities ~0.001 → effective (use NODPPM)
- Generally: ask your geomodelers what units they're shipping you

### Impact
This is a *factor of φ_frac* multiplier (typically 0.001 to 0.01). Forgetting NODPPM when needed means your fracture network has 100-1000× less permeability than intended. Wells will flow much less.

### Note on matrix-fracture Tx
NODPPM does NOT affect Eq. 2.54 (TR = CDARCY·σ·K·V) — that uses matrix permeability (PERMX) or PERMMF, not fracture. NODPPM only affects fracture-fracture transmissibility (the cells communicating laterally in the fracture half of the grid).

---

## VISCD — Viscous displacement
**Section**: RUNSPEC.

### What it solves
Standard DP assumes a single matrix pressure and a single fracture pressure per cell, and uses the difference to drive flow. But the *fracture* has a real pressure gradient (e.g. from well drawdown). If the gradient is significant, the matrix is swept laterally by the fracture pressure profile — not just drained by a uniform pressure.

### Mathematical form (Gilman-Kazemi 1988)
For a matrix at pressure P_m with the fracture pressure varying from P1 (upstream) to P2 (downstream):
- If P_m > max(P1, P2): pure matrix → fracture flow at average rate (standard DP)
- If P_m < min(P1, P2): pure fracture → matrix flow (standard DP)
- If P1 > P_m > P2: flow IN at upstream end, OUT at downstream end. Modified upwinding produces (TD Eq. 2.77):
```
q = (T/2)·λ_f·(P̄_f − P_m) − (T/2)·λ_m·(P_m − P̄_f) + (L/4)·T·λ·(P1 − P2)
```
The last term is the explicit viscous-displacement contribution: proportional to L (matrix block dimension) × G (fracture pressure gradient).

### Required inputs
- VISCD in RUNSPEC
- LX, LY, LZ in GRID (representative matrix block dimensions, per cell)
- LTOSIGMA in GRID (auto-computes σ from L_x,y,z) — if you don't add LTOSIGMA, σ defaults to 0

### When to use
- Tight matrix with moderate-permeability fracture network (the fracture isn't a "pressure short")
- Cases where fine-grid simulations show significant lateral sweeping of the matrix

### Eclipse 100 only.

### Common pitfall
Forgetting LTOSIGMA → σ = 0 → no matrix-fracture coupling → useless run. VISCD doesn't itself set σ.

---

## DIFFDP — Restrict diffusion to matrix-fracture
**Section**: RUNSPEC.

### What it does
Activates molecular diffusion *only* between matrix and fracture cells, suppressing fracture-fracture diffusion. Fracture-fracture diffusion is assumed negligible compared to fracture pressure-driven flow.

### When to use
- DIFFUSE option is active and you're modelling a tight matrix
- Performance optimisation: skip a large number of diffusion terms that are inconsequential

### Companion: DIFFMMF
A multiplier for the matrix-fracture diffusivity itself. Per-cell (GRID) or per-cell-and-timestep (SCHEDULE). Use to history-match diffusion-driven recovery.

### Common case: gas injection in fractured reservoir
- DIFFUSE on
- DIFFDP on (fracture diffusion negligible)
- DIFFMMF tuned per region if needed
- VISCD off (usually — viscous displacement is mechanical, diffusion is composition-driven)

---

## Combined option chart

| Scenario | INTPC | DPKRMOD | BTOBALFA | NODPPM | VISCD | DIFFDP |
|----------|-------|---------|----------|--------|-------|--------|
| Basic waterflood (water-wet) | – | – | – | depends on input | – | – |
| Gravity-drainage gas cap | YES | maybe | – | depends | – | – |
| Mixed-wettability gravity drainage | YES | maybe | – | depends | – | – |
| Tight matrix well test | – | – | – | depends | – | – |
| Tight matrix gas injection | – | – | – | depends | – | maybe |
| Heavily-fractured viscous-sweeping | – | – | maybe | depends | YES | – |
| EOR (compositional gas inj) | – | – | – | depends | – | YES |

(– means usually not needed; "depends" means depends on your input convention.)

---

## Lessons from the keyword set
1. **Each keyword addresses a specific physical or numerical limitation of the basic DP model.** None is a "model choice" in the abstract — each is a tool for a problem.
2. **Stack carefully.** INTPC + DPKRMOD + KRNUMMF all touch the matrix kr/Pc — they can combine in non-obvious ways. Test each in isolation first.
3. **NODPPM is the most common error source** because the convention isn't universal across teams. Always confirm.
4. **DPKRMOD is the "I have to tune something" knob** — but if you reach for it, ask whether your σ or DZMTRX or model choice (GRAVDR vs GRAVDRM) is the more honest place to adjust.
