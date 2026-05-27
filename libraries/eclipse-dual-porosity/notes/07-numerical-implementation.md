# 07 — Numerical implementation: linear solver, Jacobian structure

## Why this matters for users
You don't normally touch the solver. But:
- DK is 2–4× slower than DP — knowing *why* tells you when the cost is justified
- Convergence problems in DK can be addressed via OPTIONS item 60
- Understanding the Schur-complement trick demystifies why DUALPORO is so much cheaper

## The dual-porosity linear system

The Jacobian of a DP run has the block form:
```
[ A   C ] [ x ]   [ R_m ]
[ D   B ] [ y ] = [ R_f ]
```
- x: matrix unknowns (pressures, saturations)
- y: fracture unknowns
- A: matrix-side Jacobian block
- B: fracture-side Jacobian block (banded, like a single-porosity Jacobian)
- C, D: diagonal coupling matrices (each matrix cell connects to ONE fracture cell)
- R_m, R_f: residuals

## The Schur-complement reduction (DUALPORO only)

**Key observation**: In DUALPORO, there are no matrix-matrix connections. A is *diagonal*.

Since A is diagonal:
- A⁻¹ is trivial (just invert each diagonal entry)
- D · A⁻¹ · C is the product of three diagonals → also diagonal
- The reduced Schur system `(B − D·A⁻¹·C) · y = R_f − D·A⁻¹·R_m` has the *same band structure as B*

We solve:
```
1. Reduce: (B − D·A⁻¹·C) · y = R_f − D·A⁻¹·R_m      (Eq. 2.82)
2. Solve  for y (fracture system only — half the unknowns)
3. Back-substitute: x = A⁻¹ · (R_m − C·y)            (Eq. 2.83)
```

Effectively, DUALPORO costs about the same as a single-porosity simulation of the *fracture* grid alone. The matrix is "free."

## The dual-permeability linear system

In DUALPERM, matrix cells have spatial transmissibilities to their neighbours. **A is no longer diagonal** — it has the same banded structure as B.

The Schur trick fails: `D · A⁻¹ · C` is no longer diagonal (because A⁻¹ has fill-in throughout the band), so the reduced system is not sparse in the same way.

### What Eclipse does instead (post-97A)
Solves matrix and fracture systems simultaneously. The Jacobian is re-organised so each *cell pair* (matrix cell + corresponding fracture cell) is represented as a 6×6 block (3-phase: pressure + 2 saturations per cell × 2 cells). The off-diagonal flow bands extend in 3 spatial directions × 2 porosities = 6 bands:

```
J = D + L1 + U1 + L2 + U2 + L3 + U3                  (Eq. 2.85)
```
- D: 6×6 block diagonal (matrix + fracture Jacobian per cell pair)
- L_k / U_k: flow bands in direction k (one of x, y, z), one for matrix and one for fracture

The Nested Factorization preconditioner is extended with a fourth nesting level:
```
T = D + L3 · S⁻¹ · U3              (innermost, matrix-vs-fracture)
S = T + L2 · R⁻¹ · U2
R = S + L1 · Q⁻¹ · U1
Q = Γ + L · Γ⁻¹ · U                (outermost)         (Eq. 2.86)
```
Γ is diagonal; L and U have the same structure as the band terms.

### Pre-97A solver (OPTIONS item 60 > 0)
A different (slower but possibly more robust) solver. Use it if you have convergence problems with the default.

## Cost comparison

| Operation | DUALPORO | DUALPERM |
|-----------|----------|----------|
| Effective unknowns per cell pair | NUM_PHASE × 1 (fracture) | NUM_PHASE × 2 (matrix + fracture) |
| Matrix Jacobian | diagonal | banded |
| Schur complement | exact, preserves bandedness | not applicable |
| Linear solve cost | ~ single-porosity equivalent | ~ 2–4× single-porosity |

## Discretized matrix (NMATRIX) — what changes

The matrix sub-cells form *tri-diagonal* sub-systems connected to the fracture only at the outermost sub-cell. In the linear-solve preconditioning step, Eclipse:
1. Eliminates the tri-diagonal sub-systems (cheap because tri-diagonals are O(N) to invert)
2. Solves the resulting fracture-only system (with effective coupling adjusted for the elimination)
3. Back-substitutes for each sub-cell

So the discretized-matrix cost is much smaller than the naive N-fold cell scaling would suggest. Typical wallclock penalty for NMATRIX = 6: maybe 30–80% above the equivalent classical DP run.

## Newton convergence

Both DP and DK use the same outer Newton loop. Convergence behaviour differs:
- DP: Newton iterations are usually comparable to single-porosity (the Schur reduction doesn't change convergence rate)
- DK: extra unknowns can slow Newton; if the matrix and fracture states have very different timescales (e.g. tight matrix with high-perm fractures), iteration counts can spike. Adaptive timestepping helps; CFL conditions are tighter for the fast (fracture) sub-system.

## When to suspect a solver issue

- Convergence warnings in the .PRT file
- Many Newton failures and timestep cuts
- TR (transmissibility) reported as zero or NaN for matrix-fracture connections
- Material balance errors growing with time

First check is always physical (units, σ values, DZMTRX, well placement). Last resort:
- OPTIONS item 60 > 0 (pre-97A DK solver)
- OPTIONS item 11 (init steady-state for gravity drainage)

## Eclipse 100 vs 300

E100's solver was historically built around IMPES-style approximations and has been progressively extended. E300 is fully implicit with automatic-differentiation Jacobians and was designed from the start to handle the more general multi-porosity case (NMATRIX > 1). For most practical DP/DK problems, both work; for multi-porosity > 2, E300 is the natural choice.

## Tip: monitoring solver behaviour

Print the .PRT file occasionally — look for:
- "Linear iterations" — how many for each Newton step? > 20–30 is a warning sign
- "Material balance error" — should stay small (< 1e-6 relative)
- "Maximum cut" — frequent timestep cuts mean the solver is struggling
