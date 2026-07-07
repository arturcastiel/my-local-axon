# Richards time loop + data flow

## Per-time-step sequence (from `hydraulic_RE.m:58-107`)

```
while stopcriteria < 100                                        (outer time loop)
  1. ferncodes_solver(env, parms, dt, source_wells, time)     [line 66-67]
       │  Solves the nonlinear pressure system for this dt.
       │  Interior loop: Picard / AA / L-scheme (see below).
       │
  2. time += dt;  count++;  h = h_new                            [69-75]
  3. theta_n = thetafunction(h_new)                              [77-88]
     append h_storage, theta_storage, kmap_storage, time_storage
  4. benchmark.atualizarEstado(env, parms, time, h_new)          [89-94]
     (Caso-specific hook — record monitoring points, etc.)
  5. PLUG_kfunction(env, parms, time)                            [95-99]
     → refreshes env.config.kmap from new h
  6. metodo.atualizarPremethod(env, parms)                       [100]
     → refreshes env.premethod.MPFAD.{Kde, Ded, Kt, Kn, weight, s}
  7. IF benchmark.precisaAtualizarFlags →
        ferncodes_calflag(env, parms, time)                      [102-107]
        → refresh env.config.nflag / nflagFace
  8. benchmark.deveParar(...) — optional early exit              [109-114]
end
```

## Inside `env.metodo.resolver` (Picard iterator — per Picard iteration)
From `ferncodes_iterpicard.m`:
```
while step < maxiter && er > nltol                              (Picard loop)
    1. PLUG_kfunction(env, parms, time)                          → new kmap(h_old)
    2. ferncodes_Kde_Ded_Kt_Kn (or _TPFA for TPFA method)        → new Kde, Ded, Kt, Kn
    3. ferncodes_Pre_LPEW_2_vect (MPFA-D only)                   → new weight, s
    4. ferncodes_globalmatrix_MPFAD (or _TPFA)                    → new M, I
    5. addsource(M, mvector, source_wells, env)                  → wells in
    6. sourceterm                                                 → sources in
    7. p = M \ I                                                  → linear solve
    8. er = norm(p - p_old) / norm(p_old)                        → check residual
    9. p_old = p
end
```

## L-scheme variant (`L_scheme.m`)
Same shape as Picard, but adds a diagonal regularization:
```
M_L   = M_old + L * I_identity
RHS_L = RHS_old + L * h_old
```
Convergence structure differs from Picard: unconditionally stable, more iterations, better for very dry soils where kmap(h) is steeply nonlinear.

## Anderson acceleration (`ferncodes_andersonacc.m` / `..._acc2.m`)
Same Picard shape but replaces the naive fixed-point update with a mixed history projection (superlinear convergence when the residual is well-conditioned).

## Reassembly cost accounting

Per time step:
```
T_step = T_solve(nonlinear)
       + T_theta_update
       + T_benchmark_hook
       + T_kmap_refresh
       + T_premethod_refresh
       + T_flag_refresh (rare)
```
And per nonlinear iteration (typically 5–30 iters for Richards):
```
T_iter = T_kmap
       + T_Kde_Ded_Kt_Kn
       + T_LPEW2 (MPFA-D only)
       + T_assembly (M reconstruction)
       + T_linear_solve
       + T_residual
```

Bottleneck accounting (from function line counts + loop shape):
- **T_assembly ≈ dominant**: 295 L in `ferncodes_globalmatrix_MPFAD` with two edge sweeps and direct sparse writes; O(nFaces) with a large per-face constant.
- **T_LPEW2**: outer `for y = 1:nNodes` in `Pre_LPEW_2_vect.m` — vectorizable per corner, currently per-node.
- **T_Kde_Ded_Kt_Kn**: per-edge transmissibility computation — vectorizable but not currently.
- **T_kmap**: benchmark-specific hook; usually a per-element expression `Kr = Kr(h)` — already trivially vectorized in most CasoNNN.

**Conclusion**: assembly + LPEW2 rebuild dominates each Picard iteration. Vectorizing them collapses the inner cost by (guess) 5-20× on typical meshes.

## What is stored vs recomputed per iteration

### Stored (carried across iterations, computed once per time step or once per mesh)
- Mesh topology: `env.geometry.{coord, elem, bedge, inedge, nsurn1/2, esurn1/2, centelem, normals, elemarea}` — once per mesh
- Element-face maps: `env.premethod.MPFAD.{V, N, F}` — once per mesh (from `ferncodes_elementface`)
- Orthogonal height: `env.premethod.MPFAD.Hesq` — once per mesh
- Iterate: `parms.h_old` (Picard current)
- Anderson history: `x_hist`, `res_hist` (only in AA)

### Recomputed EVERY Picard iteration (this is the payoff)
- `env.config.kmap` — per element (cheap if the physics is simple)
- `env.premethod.MPFAD.{Kde, Ded, Kt, Kn}` — per edge (expensive: `ferncodes_Kde_Ded_Kt_Kn`)
- `env.premethod.MPFAD.{weight, s}` — per node/corner (expensive: `Pre_LPEW_2_vect`)
- `M` sparse — full assembly
- `I` RHS
- residual norm

**Vectorizing the "recomputed each iter" set is where the total-time savings live.**

## Data-flow inventory: quantity → producer → consumer

| Quantity | Built by | Stored in | Read by (top consumers) |
|---|---|---|---|
| `coord` | `preprocessormod.m:16-19` | `env.geometry.coord` | preprocessormod, ferncodes_elementface, PLUG_bcfunction, postprocessor, ferncodes_Kde_Ded_Kt_Kn |
| `elem` | `preprocessormod.m:21-25` | `env.geometry.elem` | ferncodes_elementface, ferncodes_Kde_Ded_Kt_Kn, PLUG_sourcefunction, postprocessor |
| `bedge` | `preprocessormod.m:40-47` | `env.geometry.bedge` | ferncodes_elementface, ferncodes_Kde_Ded_Kt_Kn, PLUG_bcfunction, Caso439.configurarFlags |
| `inedge` | `preprocessormod.m:40-47` | `env.geometry.inedge` | ferncodes_elementface, ferncodes_Kde_Ded_Kt_Kn, MetodoMPFAD.preprocessar |
| `nsurn1/nsurn2` | `preprocessormod.m:56-117` (CSR) | `env.geometry.nsurn1/2` | ferncodes_elementface, ferncodes_Pre_LPEW_2_vect, transm*/legacy |
| `esurn1/esurn2` | `preprocessormod.m:56-117` (CSR) | `env.geometry.esurn1/2` | ferncodes_elementface, ferncodes_Pre_LPEW_2_vect, ferncodes_pressureinterpNLFVPP |
| `centelem` | `preprocessormod.m:27-33` | `env.geometry.centelem` | PLUG_sourcefunction, postprocessor, PLUG_bcfunction, ferncodes_Kde_Ded_Kt_Kn |
| `normals` | `preprocessormod.m:48-51` | `env.geometry.normals` | ferncodes_Kde_Ded_Kt_Kn, ferncodes_elementface, legacy flux routines |
| `elemarea` | `preprocessormod.m:35-38` | `env.geometry.elemarea` | PLUG_sourcefunction, soil_properties, addsource, postprocessor |
| `V, N, F` | `ferncodes_elementface.m:3-192` | `env.premethod.MPFAD.{V, N, F}` | ferncodes_Pre_LPEW_2_vect, ferncodes_globalmatrix_MPFAD, ferncodes_pressureinterpNLFVPP |
| `Hesq` | `ferncodes_Kde_Ded_Kt_Kn.m:21-34` | `env.premethod.MPFAD.Hesq` | ferncodes_globalmatrix_MPFAD, ferncodes_flowrate |
| `Kde` | `ferncodes_Kde_Ded_Kt_Kn.m:117-155` | `env.premethod.MPFAD.Kde` | ferncodes_globalmatrix_MPFAD, ferncodes_flowrate, L_scheme |
| `Ded` | `ferncodes_Kde_Ded_Kt_Kn.m:132-155` | `env.premethod.MPFAD.Ded` | ferncodes_globalmatrix_MPFAD, ferncodes_flowrate |
| `Kt` | `ferncodes_Kde_Ded_Kt_Kn.m:39-60` | `env.premethod.MPFAD.Kt` | ferncodes_globalmatrix_MPFAD, ferncodes_flowrate (boundary) |
| `Kn` | `ferncodes_Kde_Ded_Kt_Kn.m:39-60` | `env.premethod.MPFAD.Kn` | ferncodes_globalmatrix_MPFAD, ferncodes_flowrate (boundary) |
| `weight` | `ferncodes_Pre_LPEW_2_vect.m:33-223` | `env.premethod.MPFAD.weight` | ferncodes_pressureinterpNLFVPP, ferncodes_globalmatrix_MPFAD, ferncodes_flowrate |
| `s` | `ferncodes_Pre_LPEW_2_vect.m:218-223` | `env.premethod.MPFAD.s` | ferncodes_globalmatrix_MPFAD (Neumann RHS), ferncodes_pressureinterpNLFVPP |

**Clean picture**: there are exactly two data-creation stages (preprocessormod, then the metodo's preprocessar) and everything else reads. This confirms the `FS.mesh` + `FS.geom` invariant + `FS.premethod` refresh design proposed in `data-structures.md`.
