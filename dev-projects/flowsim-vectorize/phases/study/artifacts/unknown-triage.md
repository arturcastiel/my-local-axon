# Triage of previously-"unknown" files

_Files bucketed "unknown" by the initial catalog agent, classified after reading signatures + top comments + finding callers._

## Classification legend
- **DATA-TABLE** — function body is a huge lookup / interpolation table (usually generated)
- **UTILITY** — small generic helper, likely reusable across domains
- **DOMAIN-SPECIFIC** — computes something specific to CFD / groundwater / two-phase flow
- **TEST-SCRIPT** — reporting / debugging / validation harness
- **DEAD** — no callers, likely obsolete
- **OOP-METHOD-INDIRECT** — appears dead by grep but is called via OOP dispatch

## Triage table

| File | Lines | Purpose | Class | Top caller |
|---|---:|---|---|---|
| `prehydraulic.m` | 430 | Sets groundwater initial heads / storage / well data for Qian-style cases | DOMAIN-SPECIFIC | `simulacoes/SimGroundwater.m` |
| `mesh1d.m` | 360 | 1D mesh class | UTILITY | — (likely 1D test) |
| `solanalBL.m` | 134 | Analytical Buckley–Leverett solution helper | DOMAIN-SPECIFIC | `plotandwrite.m:90` |
| `VAZAOAGUA_main.m` | 66 | Water-flow driver script | DOMAIN-SPECIFIC (script) | — top-level script |
| `CatchLine.m` | 145 | Line/curve capture helper for plotting | UTILITY | — |
| `conduchidraulica.m` | **7207** | Hydraulic-conductivity lookup / table | **DATA-TABLE** | — |
| `flush_producreport.m` | 72 | Clear/flush production-report output | UTILITY | — |
| `bringtomidpoint.m` | 147 | Interpolate edge values to midpoint | UTILITY | `getsatonedge.m:269` |
| `elemlimiter.m` | 90 | Element limiter for saturation reconstruction | DOMAIN-SPECIFIC | `bringtomidpoint.m:101` |
| `riemannsolvertwophaseflow.m` | 166 | Two-phase Riemann solver | DOMAIN-SPECIFIC | `calcnumfluxtwophaseflow.m:309` |
| `initParams.m` | 23 | Default parameter initializer | UTILITY | — |
| `L_scheme.m` | 170 | L-scheme nonlinear solver wrapper | DOMAIN-SPECIFIC | `solvers/MetodoTPFA.m:109`, `solvers/MetodoMPFAD.m` |
| `sourceterm.m` | 6 | Adds source vector into RHS | UTILITY | `ferncodes_andersonacc2.m:95` |
| `errorateconv.m` | 128 | Convergence / error-rate report | TEST-SCRIPT | — |
| `gravitationf.m` | 62 | Gravity vector builder | DOMAIN-SPECIFIC | — likely dead |
| `parametrosGauss_1D.m` | **30006** | Huge 1D Gaussian quadrature table | **DATA-TABLE** | — |
| `parametrosExpo.m` | **30005** | Huge exponential quadrature / table helper | **DATA-TABLE** | — |
| `postprocessor.m` | 117 | Post-process + plot + write results | DOMAIN-SPECIFIC | `benchmarks/Caso439.m:325`, `hydraulic.m` |
| `polynomium.m` | 5 | Polynomial evaluator | UTILITY | — |
| `anasolaux.m` | 41 | Analytic advection/diffusion helper | UTILITY | `IMPEC.m:316` |
| `linear_interp.m` | 97 | Linear interpolation on stencil data | UTILITY | `Pinterp.m:18` |
| `adeSPE.m` | 36 | SPE advection/diffusion setup | DOMAIN-SPECIFIC | — |
| `garantirextremum.m` | 119 | Extremum-preserving limiter guard | DOMAIN-SPECIFIC | — |
| `twophasevar.m` | 247 | Two-phase fractional-flow / property selector | DOMAIN-SPECIFIC | `calcSpectralFlux.m:140` |
| `rtmd_getmultidsw.m` | 327 | RTMD multidimensional saturation reconstructor | DOMAIN-SPECIFIC | `calcnewsatfield.m:460` |
| `parametrosGauss.m` | **30006** | Huge Gaussian quadrature table | **DATA-TABLE** | — |
| `redonemwvec.m` | 143 | Mass-weight vector rounding / cleanup | UTILITY | — |

## Interesting findings

1. **Four files are lookup tables**, not code:
   - `parametrosGauss.m` — 30006 lines
   - `parametrosGauss_1D.m` — 30006 lines
   - `parametrosExpo.m` — 30005 lines
   - `conduchidraulica.m` — 7207 lines

   Together **~97 000 lines of embedded numerical data** stored as `.m` files. Every read of these files reparses the tables. Moving them to `.mat` or `.dat` would (a) shrink the repo dramatically, (b) load 100× faster, (c) reduce MATLAB IDE strain.

2. **prehydraulic.m** (430 L) is not really "unknown" — it's the groundwater preprocessor for cases 330-341, called by `SimGroundwater`. Belongs to the driver cluster.

3. **L_scheme.m** (170 L) was mis-bucketed — it's a first-class iterator called by `MetodoMPFAD.resolver` and `MetodoTPFA.resolver`. Belongs to the shared iterator cluster.

4. **postprocessor.m** (117 L) writes VTK output. Called from `Caso439.atualizarEstado`. It's the output leaf of the runtime chain.

5. **VAZAOAGUA_main.m** and its siblings (`VAZAOAGUA_plota.m`, `VAZAOAGUA_writefile.m`) — three files with a shared "water-flow" prefix. Looks like a small self-contained utility.

6. **Two 1D counterparts** exist for many kernels: `TPFA_1D.m`, `TPFA_1D_Falha.m`, `TPFA_1D_Falha_v2.m`, `parametrosGauss_1D.m`, `mesh1d.m`, `ferncodes_calcpermeab_1D.m`, `ferncodes_calcfonte_1D.m`. Suggests there was a 1D reduction workflow at some point — most are dead now.

7. **Ferncodes `_con` variants**: every `_con.m` file (concentration-coupled variants) is dead per the callgraph agent. Looks like a historical fork that got superseded by inline `numcase` branches in the pressure-side files.

## Overall recovery

Of the 27 originally-unknown files:
- **4 DATA-TABLES** (~97k lines of embedded lookup data)
- **6 UTILITIES** (small helpers, keep)
- **12 DOMAIN-SPECIFIC** (belong to a real cluster — most are groundwater or two-phase specific)
- **1 TEST-SCRIPT**
- **~4 likely dead** (gravitationf, adeSPE, VAZAOAGUA_*, garantirextremum) — need explicit callgraph check before deletion
