# 02 — Math: the matrix-fracture transfer function

## The single most important equation
For every (matrix, fracture) pair Eclipse builds a connection with transmissibility:

```
TR = CDARCY · σ · K · V          (TD Eq. 2.54)
```

| symbol | meaning | source |
|--------|---------|--------|
| CDARCY | Darcy unit conversion constant | built-in |
| σ      | shape factor [1/L²]              | `SIGMA` / `SIGMAV` / `LTOSIGMA` |
| K      | matrix permeability used for the M-F coupling | X-direction PERMX by default; override with `PERMMF` |
| V      | matrix cell *bulk* volume (no porosity factor)   | DX·DY·DZ of the matrix cell |

The flow between matrix and fracture is then driven by potential difference:
```
q = TR · λ · (Φ_m − Φ_f)
```
where λ is the upstream mobility and Φ includes pressure, capillary, and gravity terms. The directionality (which is upstream) is chosen by the sign of the potential difference.

## The shape factor σ — what it really is
σ has units of 1/L². It encodes *the surface area per unit volume of matrix-fracture contact, weighted by a flow-path-length factor*. Geometrically, σ is large when matrix blocks are small (more surface per volume, fluid escapes quickly) and small when matrix blocks are large.

### Kazemi (1976) formula
```
σ = 4 · (1/lx² + 1/ly² + 1/lz²)        (TD Eq. 2.55)
```
- `lx`, `ly`, `lz` are *physical* matrix-block dimensions (NOT simulation grid cell sizes).
- The factor 4 comes from 1D diffusion analysis. Other authors use different factors (Warren & Root: π² ≈ 9.87; Coats: 8 for cubic blocks).

### Practical scale
In FIELD units, σ = 0.12 ft⁻² corresponds to ~10 ft matrix blocks. For a 1 m³ block, σ ≈ 12 m⁻². So values typically fall in 0.01–1.0 in FIELD or 0.1–10 in METRIC.

### Where do you get σ?
1. **From core data / outcrop measurement** — measure block dimensions directly. Plug into Kazemi.
2. **From the LTOSIGMA + LX/LY/LZ keywords** — Eclipse computes it for you, per cell.
3. **As a history-match parameter** — calibrate to observed recovery vs time. The TD explicitly endorses this: "Alternatively, σ may be treated as a simple history matching factor."

### Custom factor with LTOSIGMA
`LTOSIGMA` lets you tune the multiplier on each direction independently:
```
σ = (fx·Kx/lx²) + (fy·Ky/ly²) + (fz·Kz/lz²)        (TD Eq. 2.56, Ref Eq. 3.116)
```
- `fx`, `fy`, `fz` default to 4.0 (Kazemi's coefficient)
- A 4th item `fgd` selects the gravity-drainage variant for SIGMAGD calculation
- Item 5: `XONLY` (default — multiply by X-perm only) or `ALL` (use all three directional permeabilities, as in Eq. 2.56)

> Note: if LTOSIGMA is used, any SIGMA(V)/SIGMAGD(V) values entered explicitly are IGNORED.

## SIGMA vs SIGMAGD — two-process modelling
A water-wet system has TWO distinct production mechanisms in different reservoir regions:
- Water-invaded zone: water imbibition (capillary-driven, *fast*)
- Gas-invaded zone: gravity drainage (gravity-driven, *slow* — fluid mostly moves vertically)

A single σ cannot match both processes — the timescales differ by orders of magnitude.

`SIGMAGD` provides a second sigma value used in gravity-drainage-dominated flow.

### Eclipse 100 semantics
In E100, SIGMAGD is *switched in* (vs SIGMA) when ALL of these hold:
1. Gravity drainage model is active (GRAVDR or GRAVDRM)
2. Oil flow is *from matrix to fracture*
3. Gravity head from gas in fracture exceeds head from water

For gas-swept zones the matrix-fracture Tx uses SIGMAGD; for water-swept zones it uses SIGMA. Default Z-perm is used for SIGMAGD (different from SIGMA's X-perm default; pre-99A used X-perm, restore with OPTIONS item 70).

### Eclipse 300 semantics (different!)
E300 uses a **smooth interpolation** between SIGMA and SIGMAGD based on the relative strength of capillary vs gravity drainage forces:
```
σ_eff,p = ωp · σ + (1 − ωp) · σ_gd                  (TD Eq. 2.60)

       Δθgd
ωp = ─────────                                      (TD Eq. 2.61)
       Δθgd + ΔΦ_ij
```
- ΔΦ_ij = pressure + capillary + gravity potential difference (TD Eq. 2.62)
- Δθgd = phase-specific gravity-drainage contribution (TD Eq. 2.63–2.65)

If gravity dominates, ωp → 0 and σ_eff → σ_gd. If capillary dominates, ωp → 1 and σ_eff → σ.

## The volume term V
V = matrix *bulk* volume = DX · DY · DZ of the matrix cell. **No porosity factor.** This is intentional: the σ already encodes the surface-area effect, and the bulk-volume scaling lets you treat σ as an intensive property.

In dual-porosity-thermal calculations and at cells where multiple porosities share a location (multi-porosity), the rock volume gets shared between cells (TD p.122). Each cell receives the same rock volume as its pore volume; remainder goes to matrix. `ROCKSPLV` keyword overrides this if needed.

## The K term — which permeability counts?
By default K = PERMX of the matrix cell. Two important wrinkles:

1. **`NODPPM` keyword** (GRID section): without it, Eclipse multiplies the input fracture PERMX/Y/Z by the fracture POROSITY to produce an *effective* fracture permeability:
   ```
   K_frac_effective = K_frac_input × φ_frac      (default)
   K_frac_effective = K_frac_input               (with NODPPM)
   ```
   Always think hard about what your input represents. If your geocellular model already gives you effective fracture-network permeabilities (post-upscaling), use NODPPM. If you have raw fracture-only permeabilities, let Eclipse do the multiplication.

2. **`PERMMF`** (Eclipse 300 only): replaces the matrix X-direction perm with a separate value *only* for the matrix-fracture coupling. Useful when matrix internal flow and matrix-fracture coupling have different effective permeabilities (e.g. damaged or coated matrix surfaces). `MULTMF` is a multiplier on the matrix-fracture permeability.

3. **1D-extended LGRs**: if your global grid is 1D in Y or Z but the LGR extends in X, X-perm is zero everywhere and PERMMF MUST be set or NNCs cannot be generated. Mostly a test-problem trap; rarely hits real simulations.

## Multipliers and modifiers
Layered on top of the base transmissibility:
- `MULTSIG` / `MULTSIGV` — multiplier on σ (entire grid / per cell)
- `MULSGGD` / `MULSGGDV` — multiplier on σ_gd
- `MULTMF` — multiplier on the matrix-fracture permeability (Eclipse 300)

These let you tune by region without changing the underlying SIGMA values.

## When σ = 0
If neither SIGMA nor SIGMAV is set (and LTOSIGMA isn't computing it), σ defaults to 0 → matrix and fracture are uncoupled. Your matrix cells will be dead weight. This is rarely useful but Eclipse won't error — it'll just produce a "fracture-only" simulation. Always check the .PRT file after the first run.

## Block-to-block (BTOBALFA / BTOBALFV)
By default a fracture cell connects to the matrix cell *directly below it* only. When matrix block size ≈ grid cell size, the lower matrix also physically touches the *upper fracture*. BTOBALFA enables an additional transmissibility between non-co-located matrix and fracture cells (TD figs 2.16-2.17, p.102-103).

- BTOBALFA: single contact-area multiplier for the whole grid
- BTOBALFV: per-cell multiplier
- Setting either keyword *activates* the connection (otherwise it doesn't exist)
- **Restriction**: not compatible with multi-porosity (NMATRIX or TRPLPORO)
- Useful when matrix block ≈ grid block (avoids artificial decoupling)

## Summary cheat sheet
| What you want to control | Knob |
|--------------------------|------|
| How fast oil drains from matrix to fracture | SIGMA (or SIGMAV, or LTOSIGMA via L_x,y,z) |
| Gravity-drainage-specific rate | SIGMAGD (E100 switch / E300 smooth interp) |
| Fracture perm interpretation | NODPPM (skip the φ multiplier) |
| Matrix-fracture coupling perm independent of matrix internal perm | PERMMF (E300 only) |
| Regional sigma scaling | MULTSIG / MULTSIGV |
| Lower-matrix to upper-fracture connection | BTOBALFA / BTOBALFV |
| Σ-from-block-dimensions | LTOSIGMA + LX/LY/LZ |
