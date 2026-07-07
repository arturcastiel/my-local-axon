# Study — flowsim-vectorize / study phase

_Pure-understanding synthesis. What is true about the codebase — no plan, no migration order._
_Sources: initial recon + 7 parallel deep-dive investigations. Backing artifacts in `./artifacts/`._

## 1. Codebase at a glance

- **Path**: `/home/arturcastiel/projects/contreras/FlowSim`
- **298 `.m` files** + 16 `.msh` meshes + 12 `.asv` autosaves + 5 `.mat` + 2 `.xlsx` + 1 `manual.pdf`
- **~113 files (38%)** are reachable from the entry points; **~62 (20%)** are outright dead by grep; **~61 (20%)** are top-level scripts / tests; the rest are OOP methods potentially invoked via dynamic dispatch.
- **~97 000 lines** of embedded numerical lookup tables masquerading as `.m` files (see § 8).
- Language: MATLAB; two coexisting coding styles — modern OOP (env-based, no globals) and legacy procedural (globals-heavy, per-node loops).

## 2. Three class hierarchies — only one alive

| Base class | Status | Working subclasses |
|---|---|---|
| `MetodoBase` (`solvers/MetodoBase.m`) | ✓ exists | `MetodoMPFAD`, `MetodoTPFA` |
| `SimulacaoBase` (`base/SimulacaoBase.m`) | ✓ exists | `SimRichards`, `SimGroundwater`, `Caso439` |
| `SolverBase` (referenced by `SolverMPFAH`, `SolverNLFVPP`) | ✗ **missing** | 0 |
| `BenchmarkBase` (referenced by `Caso1`) | ✗ **missing** | 0 |

Consequence: **MPFA-H, NLFV-PP, and MPFA-QL cannot be instantiated as written** — their factory entries call classes (`MetodoMPFAH()`, `MetodoNLFVPP()`, `MetodoMPFAQL()`) whose class files do not exist on disk, and their `Solver*.m` orphans inherit from a base class that also does not exist.

**Only TPFA and MPFA-D run end-to-end today.**

## 3. Benchmark inventory — 2 of 35 exist

`factories/createBenchmark.m` dispatches to 35 numcases. Actual class files on disk:
- `benchmarks/Caso1.m` — `classdef Caso1 < BenchmarkBase` (base missing, and factory doesn't reference case 1)
- `benchmarks/Caso439.m` — `classdef Caso439 < SimulacaoBase` (correctly wired for Richards)

**33 CasoNNN class files are missing.** The runtime still handles those numcases via inline `numcase == N` branches in the legacy `PLUG_*`, `benchmark.m`, and `ferncodes_*` files — but the OOP-first structure is aspirational for all cases except 439.

## 4. Preprocessor — 1 canonical, 2 dead variants

| File | Callers | Verdict |
|---|---|---|
| `preprocessor.m` (3363 L) | none | historical |
| `preprocessor2.m` (3299 L) | none | modernized cleanup of `preprocessor.m` — unused |
| `preprocessormod.m` (1642 L) | `main.m:28 → preprocessormod(1)` | **canonical — the only one wired** |

`preprocessormod.m` builds every mesh-derived quantity (`coord/elem/bedge/inedge/nsurn1-2/esurn1-2/centelem/normals/elemarea`). Nothing else writes them — they are read-only downstream.

## 5. Globals inventory

**181 of 298 files (61%)** declare `global`. Top-count globals:

| Global | Files | Kind |
|---|---:|---|
| bedge | 116 | mesh face table |
| inedge | 107 | mesh face table |
| coord | 107 | mesh nodes |
| elem | 90 | mesh connectivity |
| centelem | 90 | derived geom |
| numcase | 62 | physics dispatch |
| bcflag | 38 | BC table |
| normals | 29 | derived geom |
| esurn2 | 25 | CSR ptr |
| nsurn2 | 22 | CSR ptr |
| phasekey | 21 | physics dispatch |
| elemarea | 19 | derived geom |

All are produced by `preprocessormod` and consumed by dozens of legacy `ferncodes_*` and `transm*` files. The modern OOP layer (`MetodoMPFAD.m`, `SimRichards.m`, `factories/*`) accesses them via `env.geometry.*` and `env.config.*` — the migration to env-based access has landed in a small vertical slice around MPFA-D.

## 6. `transm*` files — all dead

Every file in `transm{FPS,FPScon,TPS,TPScon,TPS_MSFV,AxissTPS,Enriched,TPFA}.m` has **zero callers**. Total: **~7000 lines of dead code** carrying **~50 global declarations** across the set. Historical MPFA/TPFA transmissibility implementations, superseded by `ferncodes_Kde_Ded_Kt_Kn*`.

## 7. LPEW2 — the last per-node loop

`ferncodes_Pre_LPEW_2_vect.m` (222 L) is the partial vectorization of the LPEW2 pipeline. What was already done:
- Precomputed element centroids (`centpre`) hoisted out of the loop
- Interior-node `netas` fully vectorized inside the loop
- Interior tensor pre-indexing (`jj_all/matids/K11v/…`) vectorized
- Interior `zeta/lambda` computed via shifted arrays

What still runs scalar (blocking full vectorization):
- Outer `for y = 1:nNodes` (222 L, entire body)
- Angle loop per node
- Boundary-path netas + Kt/Kn + zeta/r
- Building `P/T/O` per node
- Final scatter to `weight`

**Cause of the remaining loop**: `nec` (corners-per-node) is ragged — varies per node. Ragged shape blocks a naive rectangular vectorization.

**Structural resolution** (see `artifacts/data-structures.md`): flatten the corners into a CSR-flat layout (`cornerNode`, `cornerElem`, `cornerNext`, `cornerPrev`, `nodePtr`) and use `accumarray(cornerNode, ...)` for segmented normalization. Under that layout, the per-node work becomes per-corner arithmetic on flat vectors, plus one accumarray per reduction.

## 8. Data-table files (~97 000 lines masquerading as code)

Four files store embedded numerical tables:
| File | Lines |
|---|---:|
| `parametrosGauss.m` | 30006 |
| `parametrosGauss_1D.m` | 30006 |
| `parametrosExpo.m` | 30005 |
| `conduchidraulica.m` | 7207 |

Every load of these files reparses the tables. If moved to `.mat` or `.dat`, load is ~100× faster and the repo shrinks by ~1/3 of total .m LOC.

## 9. Assembly hot path

All `ferncodes_assemblematrix*` files follow the same shape:
```
for ifacont = 1:size(bedge, 1)     % boundary faces
    ... M(i,j) = M(i,j) + coef ...
end
for iface = 1:size(inedge, 1)      % interior faces
    ... M(i,j) = M(i,j) + coef ...
end
```
Direct sparse-matrix writes inside a face loop — the pattern MATLAB documents as the worst case for `sparse` performance (each write can trigger reallocation).

Only `ferncodes_globalmatrix_MPFAD.m` (295 L) is globals-free and env-based; every other assembler carries 5-13 globals and uses inline `numcase` dispatch.

Bytes-per-assembler (largest first):
| Assembler | Lines | Globals |
|---|---:|---:|
| `ferncodes_assemblematrixMPFAH.m` | 820 | 7 |
| `ferncodes_globalmatrix_MPFAD.m` | 295 | **0** |
| `ferncodes_assemblematrixDMP.m` | 220 | 6 |
| `ferncodes_assemblematrixMPFAQL.m` | 199 | 8 |
| `ferncodes_assemblematrixNLFVPP.m` | 174 | 7 |
| `ferncodes_assemblematrixNLFVH.m` | 107 | 7 |

## 10. Richards time-loop shape

```
hydraulic_RE.m (outer time loop)
├── ferncodes_solver
│   └── env.metodo.montarSistema       → M, I
│       └── ferncodes_globalmatrix_MPFAD (or _TPFA)  [ASSEMBLY]
│   └── addsource + sourceterm
│   └── env.metodo.resolver             [nonlinear iteration]
│       ├── FPI  → ferncodes_iterpicard
│       │       └── LOOP: PLUG_kfunction → Kde_Ded_Kt_Kn → Pre_LPEW_2_vect → globalmatrix → solve
│       ├── AA   → ferncodes_iterpicardANLFVPP2
│       └── LSCH → L_scheme
├── thetafunction(h_new)
├── benchmark.atualizarEstado
├── PLUG_kfunction                     → refresh env.config.kmap
├── metodo.atualizarPremethod          → refresh Kde/Ded/Kt/Kn + LPEW2 weights
└── [optional] ferncodes_calflag
```

**Per Picard iteration** (inside the nonlinear iterator), the following are recomputed:
`kmap` → `Kde/Ded/Kt/Kn` → LPEW2 `weight/s` → **full matrix `M`** → linear solve → residual.

That is where every vectorized second is banked: N_time_steps × N_picard_iters full reassemblies.

## 11. Six functional clusters emerge from the call structure

_Detailed in `artifacts/module-encapsulation.md`._

1. **MPFA-D pipeline** (class + preproc + LPEW2 + assembly + iter + post-proc). Cleanest. Standard method.
2. **TPFA pipeline** (class + preproc + assembly + iter + post-proc). Smallest. Baseline.
3. **MPFA-H pipeline** (orphaned OOP wrapper + preproc + assembly). Broken at class-load.
4. **NLFV-PP pipeline** (orphaned OOP wrapper + preproc + assembly + iter). Broken at class-load.
5. **DMP / MPFA-QL / NLFV-H** cluster (assembly files, no OOP wrapper, share DMP helpers).
6. **Shared substrate**: mesh preproc, BC flags, iterators, time drivers, post-proc, PLUG_*.

**Cross-cluster leaks** — functions with a method name that are actually shared kernels:
- `ferncodes_pressureinterpNLFVPP` — used by BOTH MPFA-D and NLFV-PP. Not NLFVPP-specific.
- `ferncodes_iterpicardANLFVPP2` — used by MPFA-D case `'AA'`. Not NLFVPP-specific.
- `ferncodes_Pre_LPEW_2_vect` — used by MPFA-D and NLFV-PP.
- `ferncodes_weightnlfvDMP` — used by MPFA-H and DMP.

Naming discipline broke early — the "true home" of these functions is a shared kernel bucket, not a method-specific one.

## 12. Production target

**MPFA-D** (see `artifacts/production-target-decision.md`).

Rationale: only method with (a) complete OOP wrapper, (b) globals-free assembly, (c) explicit "default method for the majority of cases" designation in the codebase's own documentation, (d) coverage of every physics regime (steady, groundwater, Richards).

TPFA is a valuable secondary baseline (its simplicity makes it an oracle for MPFA-D on ortho-aligned tests). The remaining three named methods (MPFAH, NLFVPP, MPFAQL) are auxiliary variants for MPFA-D failure modes, and their OOP wiring is broken today.

## 13. Facts summary (the "gaps closed")

| Question at start of session | Fact discovered |
|---|---|
| Which discretization is production? | MPFA-D |
| Are `transm*` files still on the runtime path? | No — all dead, ~7000 LOC |
| Which of 3 preprocessors is canonical? | `preprocessormod.m` (only one called from `main.m`) |
| How many benchmark classes exist? | 2 of 35 — the factory is aspirational for 33 |
| Tolerance for oracle diff? | 1e-12 rel Frobenius (matrix) / 1e-10 (pressure) — confirmed |
| What are the `.asv` autosave files? | 12 autosaves in `solvers/`, root, etc. Owner authorises deletion. |
| What do the 27 unknown files do? | 4 data tables (~97k lines), 6 utilities, 12 domain-specific (mostly groundwater/two-phase), 1 test script, ~4 likely dead |

## 14. Remaining honest uncertainty

1. **Reachability set is conservative** — 62 files marked dead include some (like `preRE.m`, `Pinterp.m`) that are actually reached through OOP method dispatch. Real dead-code count is 40–55.
2. **The runtime `pmethod` value** — Start.dat's `pmethod` line was not captured cleanly in the parse. It probably matches the working set (`tpfa` or `mpfad`) since those are the only wired methods.
3. **Whether the missing 33 Caso classes have ever run** — the inline `numcase` branches in legacy files may fully cover the physics for those cases (making the missing OOP classes cosmetic), or may not (making 33/35 numcases outright broken). Determining which requires actually running each numcase.
4. **Whether `Pinterp.m` and its neighbours are OOP-dispatch-reached** — the callgraph agent lists them dead but they may be class methods on a hidden dispatcher.

Closing these residual gaps requires either running MATLAB (out of scope for AXON per Rule 9) or tracing every OOP dispatch site manually.

## 15. Artifact index

All files in `./artifacts/`:

| File | Content |
|---|---|
| `folder-layout.md` | Proposed `+fs/` package tree (retained from earlier iteration — pure structural sketch) |
| `flowsim_init.m` | Runnable MATLAB path initializer |
| `flowsim_deinit.m` | Symmetric cleanup |
| `data-structures.md` | `FS` struct + CSR corner layout design |
| `assembly-deepdive.md` | 17 assembly files mapped end-to-end |
| `module-encapsulation.md` | Six functional clusters + cross-cluster leaks |
| `production-target-decision.md` | Evidence for MPFA-D as target |
| `call-graph-and-reachability.md` | 106 reachable functions + 62 dead + `transm*` verdict + Richards hot path |
| `preproc-canonical-and-benchmarks.md` | preprocessormod canonical + 33 missing benchmark classes |
| `richards-loop-and-dataflow.md` | Per-step + per-Picard-iter sequences + data-flow inventory |
| `numcase-dispatch.md` | Per-range physics forks, high-special cases, dispatch monoliths |
| `unknown-triage.md` | 27 previously-unknown files classified |
| `rewrite-map.md` | Earlier planning-oriented artifact — SUPERSEDED by pure-study framing but retained for reference |
