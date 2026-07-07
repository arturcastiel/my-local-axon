# Call graph, reachability, and dead code

_Study — what is actually reachable from the entry points, and what is dead._

## Counts
- Total `.m` files: **298**
- Reachable functions from entry points: **106**
- REACHABLE files: **113**
- HELPER-ONLY (called only by other unreachable code): **62**
- OUTRIGHT DEAD (zero callers): **62**
- TEST/SCRIPT (no `function` line — top-level scripts): **61**

**≈ 20% of the codebase (62 / 298 files) is outright dead by grep.**

_Caveat_: MATLAB OOP dispatch (`obj.method(...)`) is dynamic — grep-based reachability can miss calls that go through class method resolution. Files listed as "dead" that are actually class methods invoked via `obj.` may be reachable at runtime. Sample: `preRE.m` shows as dead in the reachability set but is called by `SimRichards.preprocessar`. The 62 count is an upper bound on truly dead code; the reality is likely 40–55 files.

## Entry-point set (Richards, pmethod=tpfa|mpfad, phasekey=6)
```
main.m
  ↓ createSimulacao(6)           → SimRichards
  ↓ createMetodo(pmethod)        → MetodoTPFA | MetodoMPFAD
  ↓ createBenchmark(numcase)     → Caso439 (only one wired for Richards range)
  ↓ preprocessormod(1)           → env.geometry.{coord, elem, bedge, inedge, nsurn1/2, esurn1/2, centelem, normals, elemarea}
  ↓ preRE(env)                   → parms (benchmark preprocessar)
  ↓ setmethod / hydraulic_RE     → time loop
```

## Richards time-loop hot path (per outer iteration)
From `hydraulic_RE.m`:
```
while stopcriteria < 100
    ferncodes_solver(env, parms, dt, source_wells, time)
        └─ env.metodo.montarSistema(env, parms, dt)      → M, I
        └─ addsource(M, mvector, source_wells, env)
        └─ sourceterm
        └─ env.metodo.resolver(M, I, ...)                 → Picard | AA | L-scheme
    time += dt
    theta_n = thetafunction(...)
    benchmark.atualizarEstado(...)
    PLUG_kfunction(env, parms, time)                     → refreshes env.config.kmap
    metodo.atualizarPremethod(env, parms)                → refreshes Kde/Ded/Kt/Kn + LPEW2 weights
    [optional] ferncodes_calflag(...)                    → refresh BC flags
    [optional] benchmark.deveParar(...)                  → early stop
end
```

Inside `env.metodo.resolver` (Picard iterator, per iteration):
```
while step < maxiter && er > nltol
    PLUG_kfunction                        → new kmap
    ferncodes_Kde_Ded_Kt_Kn (or _TPFA)    → new transmissibilities
    ferncodes_globalmatrix_MPFAD (or _TPFA) → new M, I
    addsource + sourceterm
    p = M \ I                             → linear solve
    er = norm(p - p_old) / norm(p_old)    → residual check
end
```

**Vectorization payoff surface**: every Picard iteration rebuilds `M` and recomputes LPEW2 weights + transmissibilities. That's `Picard_iters × time_steps` reassemblies. Each reassembly currently costs one full pass over `bedge` + `inedge` with scalar sparse writes.

## `transm*` files — verdict
| File | Lines | Callers | Reachable? |
|---|---:|---|---|
| `transmAxissTPS.m` | 877 | none | ✗ DEAD |
| `transmEnriched.m` | 1140 | none | ✗ DEAD |
| `transmFPS.m` | 1144 | none | ✗ DEAD |
| `transmFPScon.m` | 1156 | none | ✗ DEAD |
| `transmTPFA.m` | 205 | 1 comment-only mention | ✗ DEAD |
| `transmTPS.m` | 810 | none | ✗ DEAD |
| `transmTPS_MSFV.m` | 854 | none | ✗ DEAD |
| `transmTPScon.m` | 810 | none | ✗ DEAD |

**All ~7000 lines of `transm*.m` are dead code**, along with their heavy `global` usage. Historical MPFA/TPFA transmissibility implementations, superseded by `ferncodes_Kde_Ded_Kt_Kn*`.

## Top 30 outright-dead files (sample)
`IC.m`, `PLUG_Gfunction.m`, `PLUG_dfunction.m`, `Pinterp.m`, `SWcapacity.m`,
`Zcontribution.m`, `analentropy.m`, `applyinicialcond.m`, `attribinitialcond.m`,
`calcflowrateTPFA_con.m`, `calcintegvalanalBL.m`, `calcmodifmoodflux.m`,
`calcnumflux_aux_HOFVM.m`, `calcresultvel.m`, `calctimestepSFV.m`,
`carga_hidraulica.m`, `conduchidraulica.m`, `errorateconv.m`,
`ferncodes_Pre_LPEW_2_con.m`, `ferncodes_calcfonte_1D.m`,
`ferncodes_calcpermeab_1D.m`, `ferncodes_contflagface.m`,
`ferncodes_elementfacempfaH.m`, `ferncodes_elementype.m`,
`ferncodes_flowrateNLFVPP_con.m`, `ferncodes_flowrateTPFA_con.m`,
`ferncodes_flowrate_con.m`, `ferncodes_flowratelfvHP_con.m`,
`ferncodes_flowratelfvMPFAQL_con.m`, `ferncodes_iterpicardANLFVPP.m`.

Notable in this list:
- `ferncodes_elementfacempfaH.m` — dead. Yet `SolverMPFAH.preprocessar` (which is itself unreachable — MPFAH is unwired) calls it. So MPFA-H is dead-code all the way down.
- Every `*_con.m` variant is dead — the concentration-coupled paths appear to be a historical fork that never merged back.
- `ferncodes_Pre_LPEW_2_con.m` — the third LPEW2 variant, dead.
- `Pinterp.m` — likely OOP-dispatch-hidden; needs manual verification before deletion.
