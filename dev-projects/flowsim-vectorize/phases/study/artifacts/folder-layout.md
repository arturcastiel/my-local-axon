# Target folder layout — FlowSim reorganization

## Principles
1. **No `.m` files at repo root** (except `flowsim_init.m` / `flowsim_deinit.m` /
   `flowsim_run.m`). Everything else lives in a categorised subfolder.
2. **MATLAB `+package` namespaces** for module isolation — every module exports
   through `+fs.<module>.<func>` rather than global scope. This kills accidental
   name shadowing and forces explicit dependency.
3. **Old procedural code preserved during migration** — legacy files move to
   `legacy/` unchanged. Vectorized twins land in the new tree with the same
   function name; the initializer path-orders new tree first so vectorized code
   wins by shadowing.
4. **Data (meshes, .mat, .dat) never mixed with code.** All meshes to `meshes/`.
5. **Autosave (`.asv`) files deleted** — MATLAB regenerates on demand.
6. **`.git`, `.gitignore`, `manual/manual.pdf` stay at root.**

## Proposed tree (verbatim; use as ground-truth)

```
FlowSim/
├── flowsim_init.m                 # add all paths, banner, version check
├── flowsim_deinit.m               # symmetric rmpath cleanup
├── flowsim_run.m                  # one-line entry: read Start.dat + dispatch
├── Start.dat                      # runtime config (unchanged)
├── README.md
├── CHANGELOG.md                   # NEW — track vectorization deltas
├── manual/                        # docs (manual.pdf)
│
├── meshes/                        # ALL .msh / .mat mesh fixtures
│   ├── hermeline/                 # HermelineMeshMod{Quad,Triang}_NxN.msh
│   ├── kozdon/                    # M8*.msh + MalhaKozdon.m helper
│   └── raw/                       # Perm_Var0p1.mat, other permeability .mat
│
├── +fs/                           # top-level namespace (fs.<mod>.<func>)
│   │
│   ├── +io/                       # file / config I/O
│   │   ├── readStart.m            # was: parseStart.m / inline reads
│   │   ├── readGmsh.m             # gmsh .msh reader
│   │   ├── writeVTK.m             # was: plotandwrite (VTK-only slice)
│   │   ├── writeTable.m           # xlsx / dat writers
│   │   └── loadPermeability.m
│   │
│   ├── +mesh/                     # topology construction (once per mesh)
│   │   ├── build.m                # env.geometry from raw gmsh
│   │   ├── connectivity.m         # nsurn1/2, esurn1/2 (CSR builders)
│   │   ├── faceTables.m           # bedge, inedge
│   │   ├── centroids.m            # elem centroids (batched by shape)
│   │   ├── normals.m              # face normals + length
│   │   └── areas.m                # element areas
│   │
│   ├── +geom/                     # geometric queries (per-solver-call)
│   │   ├── faceMidpoints.m
│   │   ├── nodeToCornerCSR.m      # NEW: flat CSR corner map
│   │   ├── paddedCorners.m        # NEW: [nNodes x maxNec] padded view
│   │   └── segments.m             # shifted-index neighbour arrays
│   │
│   ├── +perm/                     # permeability / material tensors
│   │   ├── isotropic.m
│   │   ├── anisotropic.m
│   │   ├── fromField.m
│   │   ├── randistLognorm.m       # was: getrandist
│   │   └── fromImage.m            # was: getchue
│   │
│   ├── +bc/                       # boundary conditions
│   │   ├── flags.m                # nflag, nflagface
│   │   ├── dirichlet.m
│   │   ├── neumann.m
│   │   └── plug.m                 # was: PLUG_bcfunction*
│   │
│   ├── +lpew/                     # LPEW1/LPEW2 pipelines (FULLY VECTORIZED)
│   │   ├── +v1/                   # LPEW1 (scalar reference — kept for oracle)
│   │   │   ├── preLPEW1.m         # driver
│   │   │   ├── angulos.m
│   │   │   ├── ksInterp.m
│   │   │   └── lambdaWeights.m
│   │   ├── +v2/                   # LPEW2 — vectorized rewrite
│   │   │   ├── preLPEW2.m         # driver (NO per-node loop)
│   │   │   ├── angulos.m          # vectorized over all corners
│   │   │   ├── netas.m
│   │   │   ├── ksInterp.m
│   │   │   ├── lambdaWeights.m    # segmented, accumarray-based
│   │   │   └── neumannSource.m    # boundary-node s(No) vectorized
│   │   ├── OPT.m                  # gather O,P,T,Qo (batched)
│   │   └── pinterp.m              # element→node pressure interp
│   │
│   ├── +assembly/                 # global-matrix builders (triplet form)
│   │   ├── +mpfah/                # Hybrid MPFA — the 820-line beast, refactored
│   │   │   ├── build.m            # sparse(rows,cols,vals,nE,nE) — one shot
│   │   │   ├── faceCoeffs.m       # batched over inedge
│   │   │   ├── boundaryCoeffs.m   # batched over bedge
│   │   │   └── neumannRHS.m
│   │   ├── +mpfad/                # Diamond MPFA — was globalmatrix_MPFAD
│   │   │   ├── build.m
│   │   │   ├── faceCoeffs.m
│   │   │   └── boundaryCoeffs.m
│   │   ├── +nlfvpp/               # NLFV positive-preserving
│   │   ├── +nlfvh/                # NLFV hybrid
│   │   ├── +dmp/                  # discrete-max-principle
│   │   ├── +mpfaql/               # QL scheme
│   │   ├── +tpfa/                 # two-point flux (baseline)
│   │   ├── +fps/                  # full-pressure-support (legacy — study only)
│   │   └── +enriched/             # enriched schemes
│   │
│   ├── +flow/                     # flow-rate computation per face
│   │   ├── mpfa.m
│   │   ├── nlfv.m
│   │   └── spectral.m             # was: calcSpectralFlux
│   │
│   ├── +sat/                      # saturation / two-phase updates
│   │   ├── update.m
│   │   ├── maxMin.m               # was: Saturation_max_min
│   │   ├── limiter.m              # was: MLPlimiter (dispatch)
│   │   └── mood.m                 # was: MOODmaneger
│   │
│   ├── +time/                     # time-step control
│   │   ├── impes.m
│   │   ├── impec.m
│   │   ├── imhec.m
│   │   └── cflStep.m
│   │
│   ├── +iter/                     # nonlinear iterators (Picard / AA / L-scheme)
│   │   ├── picard.m
│   │   ├── anderson.m
│   │   └── lscheme.m              # was: L_scheme
│   │
│   ├── +sim/                      # Simulacao* classes (already OOP)
│   │   ├── Base.m                 # was: SimulacaoBase
│   │   ├── Groundwater.m          # was: SimGroundwater
│   │   └── Richards.m             # was: SimRichards
│   │
│   ├── +method/                   # Metodo* classes (already OOP)
│   │   ├── Base.m                 # was: MetodoBase
│   │   ├── MPFAD.m                # was: MetodoMPFAD
│   │   ├── MPFAH.m
│   │   ├── NLFVPP.m
│   │   ├── MPFAQL.m
│   │   └── TPFA.m
│   │
│   ├── +bench/                    # CasoNNN benchmark classes
│   │   ├── Caso1.m
│   │   ├── Caso341.m
│   │   ├── Caso431.m
│   │   ├── Caso437.m
│   │   ├── Caso439.m
│   │   └── ...                    # populate as-needed per test coverage
│   │
│   ├── +plot/                     # visualisation
│   │   ├── field.m                # scalar-field plot
│   │   ├── vector.m
│   │   ├── catchLine.m            # was: CatchLine
│   │   └── catchPicture.m         # was: CatchPicture
│   │
│   ├── +factory/                  # createXxx factories (already exist)
│   │   ├── benchmark.m            # was: createBenchmark
│   │   ├── metodo.m               # was: createMetodo
│   │   └── simulacao.m            # was: createSimulacao
│   │
│   └── +util/                     # generic helpers (no domain knowledge)
│       ├── csrShift.m             # k-1 / k+1 shifted-neighbour helper
│       ├── accumarray2.m          # 2-D accumarray convenience
│       ├── padRagged.m            # ragged→[N x maxK] padded view
│       └── segNorm.m              # segmented vector norm
│
├── legacy/                        # OLD procedural code — untouched during migration
│   ├── ferncodes/                 # all ferncodes_*.m files
│   ├── transm/                    # transmFPS*, transmTPS*, transmEnriched*
│   ├── preprocessor/              # preprocessor.m, preprocessor2.m, mod
│   ├── deprecated/                # .asv, dead scripts, unused variants
│   └── README.md                  # explains: preserved for oracle, will shrink
│
├── benchmarks/                    # OOP benchmark subclasses (already exists)
│   └── ... (move into +fs/+bench/ during migration)
│
├── tests/                         # NEW — golden-oracle harness
│   ├── golden/                    # captured outputs from legacy runs
│   ├── smoke/                     # runs a 12x12 mesh in <30s
│   ├── unit/                      # per-function scalar-vs-vectorized diff
│   └── run_all.m
│
└── docs/                          # NEW — architecture notes, not the manual
    ├── data-structures.md
    ├── vectorization-guide.md
    └── migration-log.md
```

## Movement rules (per legacy file)
- Every legacy file gets a category from the CATALOG (see `catalog.md`).
- Files marked `deprecated-asv` → **delete outright** (autosaves).
- Files with `unknown` bucket → **move to `legacy/deprecated/` pending review**.
- Files listed as dead (grep-no-refs) → **move to `legacy/deprecated/`** with a
  `.dead-since-2026-07-03` marker.
- Files with the `global` declaration set intersecting our mesh globals
  (`bedge, inedge, coord, elem, centelem, esurn1/2, nsurn1/2, normals, ...`) →
  wrap in a shim under `legacy/ferncodes/` that unpacks from `env` at entry,
  so the vectorized twins can be introduced side-by-side.

## Path shadowing strategy
The initializer adds `+fs/` FIRST, `legacy/` LAST. So a vectorized
`+fs.assembly.mpfah.build` resolves before the legacy `ferncodes_assemblematrixMPFAH`.
During the migration, each PR replaces a legacy call site with the `+fs` twin;
result parity is gated on the oracle diff (see `docs/vectorization-guide.md`).
