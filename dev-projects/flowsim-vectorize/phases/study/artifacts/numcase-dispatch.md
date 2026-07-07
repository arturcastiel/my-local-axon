# numcase dispatch map — every physics fork in the code

_Study only — enumerate where the code branches on `numcase`, and what each branch guards._

## Range convention (from `factories/createBenchmark.m` header)
```
1   – 100  reference tensors / manufactured solutions
100 – 200  single-phase flow tests
200 – 300  contaminant transport
300 – 400  groundwater / hydraulic head
400 – 500  Richards (partially saturated / unsaturated flow)
```

## Physics dispatch mode by range

| Range | Family | Primary dispatch site | Fork surface |
|---|---|---|---|
| 1–100     | reference tensors | `IC.m`, `benchmark.m`, `PLUG_bcfunction*` | BC + IC + mobility/viscosity + source |
| 100–200   | single-phase / advection | `calcnewsatfield.m`, `highorder_DRLFK.m`, `PLUG_sourcefunction.m` | saturation update + entropy + source + limiter |
| 200–300   | contaminant | `IMPEC.m`, `IMHEC.m`, `preconcentration.m`, `PLUG_dfunction.m`, `PLUG_bcfunction_con.m`, `ferncodes_assemblematrix*` | assembly + BC + source + IC + fractional flow |
| 300–400   | groundwater head | `prehydraulic.m`, `solvePressure_TPFA.m`, `ferncodes_globalmatrix_TPFA.m`, `defineWells.m` | pressure assembly + well setup + gravity + benchmark geometry |
| 400–500   | Richards | `PLUG_sourcefunction.m`, `SWcapacity.m`, `solvePressure_TPFA.m`, `ferncodes_flowrate*.m`, `createBenchmark.m` | source + kappa/capacity + flow rate + benchmark selection |

## High-specialness cases (many files fork specifically on these)

| numcase | Special-cased in | Why |
|---|---|---|
| **245** | `IMPEC.m`, `IMHEC.m`, `preconcentration.m`, `PLUG_dfunction.m`, `attribinitialcond.m`, `ferncodes_*` flux/assembly | Contaminant benchmark with unique BC/perm/source shape |
| **248** | `preconcentration.m`, `PLUG_dfunction.m`, `ferncodes_analyticalSolution.m`, `PLUG_bcfunction_con.m`, `PLUG_bcfunction_con_mpfa_o_fps.m`, `calcnewsatfield.m`, `getsatandflag.m`, `IMPEC.m`, `IMHEC.m` | Very special contaminant case with analytical solution |
| **341** | `prehydraulic.m`, `defineWells.m`, `createBenchmark.m`, `benchmark.m`, `ferncodes_globalmatrix_TPFA.m`, `ferncodes_assemblematrixMPFAH.m` | Groundwater with mixed Dirichlet+Neumann BC, uses `ferncodes_K` for variable-K Neumann boundary |
| **341.1** | Same as 341 plus 1D variant handling | 1D reduction of case 341 |
| **434, 436** | `PLUG_sourcefunction.m:21-85` | Richards source-term specials |
| **437** | `SWcapacity.m`, `ferncodes_flowrate*.m`, `createBenchmark.m` | Richards Gardner model with analytical solution (L2/H1 error reporting) |
| **439** | Everywhere — the only fully-implemented Caso class | Richards recharge benchmark, 6 monitoring points, saves indices to `.mat` |

## Boundary of "monolithic" vs "clean" dispatch

- **Clean** (dispatch confined to one place):
  - `createBenchmark(numcase)` — factory. This is the intended dispatch point.
  - `createSimulacao(phasekey)` — simulation family factory.
  - `createMetodo(pmethod)` — numerical method factory.

- **Monolithic** (dispatch spread across many files):
  - `PLUG_bcfunction.m` — inline switch on numcase inside a supposedly-generic BC evaluator.
  - `PLUG_sourcefunction.m` — inline switch on numcase for source terms.
  - `PLUG_dfunction.m` — inline switch on numcase for diffusion.
  - `PLUG_kfunction.m` — inline switch on numcase for permeability.
  - `ferncodes_assemblematrixMPFAH.m` — inline `if 200<numcase<300 ... elseif ...` inside the assembly loop.
  - `ferncodes_flowrate*.m` — inline numcase forks.
  - `calcnewsatfield.m` — inline numcase forks in saturation update.

The `PLUG_*` files are the intended abstraction layer (one file per physical concept: BC, source, k, d). But they still switch on numcase internally rather than delegating to the benchmark class — because most Caso classes don't exist. Once benchmark classes are implemented, the `PLUG_*` files can shrink to thin dispatchers (`return env.benchmark.evaluateBC(...)`).

## Answer to "given numcase=N, what code paths execute?"

For any given numcase, at least these files fork on it:
1. `factories/createBenchmark.m` — instantiates Caso class (or ERRORS if missing — likely for 33/35 cases)
2. `PLUG_bcfunction.m` — evaluates boundary condition
3. `PLUG_sourcefunction.m` — evaluates source
4. `PLUG_kfunction.m` — evaluates permeability
5. `PLUG_dfunction.m` — evaluates diffusion (transport cases only)
6. `PLUG_bcfunction_con.m` — evaluates concentration BC (transport cases only)
7. `SWcapacity.m` — evaluates specific hydraulic capacity (Richards only)
8. `benchmark.m` — top-level benchmark dispatcher (legacy path)
9. `ferncodes_assemblematrixMPFAH.m` and similar assemblers — physics-dependent coefficient branches
10. `calcnewsatfield.m` — saturation-update branch (transport / two-phase only)

**Recommendation for study clarity**: for any specific numcase, the honest way to trace "what runs" is to grep for `numcase == N`, `case N`, `numcase < N`, `numcase > N` across the reachable set — because dispatch is not centralized.
