# Per-file rewrite mapping — FlowSim 298 .m files

_Policy: every `.m` file gets exactly one disposition. Buckets from catalog + deep-dive._

## Disposition legend
- **KEEP-AS-IS** — moves to new folder unchanged; no vectorization needed (already clean, or too small to matter)
- **REFACTOR** — moves to new folder + rewritten with FS struct + no globals + vectorization opportunity applied
- **REPLACE** — legacy stays in `legacy/`; a vectorized twin is authored under `+fs/`. Call sites migrate progressively.
- **DELETE-DEAD** — no repo references and no runtime path leads here (grep-verified). Marked with `.dead-since-2026-07-03`.
- **DELETE-ASV** — MATLAB autosave file; always deletable.
- **REVIEW** — bucket is `unknown` or dead-check inconclusive. Manual owner call before disposition.

## Summary counts (from catalog agent)

| Bucket | # files | Default disposition |
|---|---|---|
| driver              | 34 | REFACTOR → `+fs/+time/` or `+fs/+sim/` |
| factory             | 41 | REFACTOR → `+fs/+factory/` or REPLACE if global-heavy |
| solver              | 25 | REFACTOR → `+fs/+method/` |
| saturation          | 22 | REFACTOR → `+fs/+sat/` |
| flowrate            | 19 | REPLACE → `+fs/+flow/` (batched over faces) |
| geometry            | 89 | REFACTOR → `+fs/+geom/` or `+fs/+mesh/` |
| mesh                | 8  | REFACTOR → `+fs/+mesh/` |
| assembly-mpfah      | (part of 820L file) | REPLACE → `+fs/+assembly/+mpfah/` |
| assembly-mpfad      | 2 (globalmatrix_MPFAD + helpers) | REPLACE → `+fs/+assembly/+mpfad/` |
| assembly-nlfv       | 2 (NLFVH + NLFVPP) | REPLACE → `+fs/+assembly/+nlfvh|nlfvpp/` |
| assembly-dmp        | 2 (+ 3 aux) | REPLACE → `+fs/+assembly/+dmp/` |
| assembly-tpfa       | 2 | REFACTOR → `+fs/+assembly/+tpfa/` |
| assembly-fps        | (transmFPS*) | LEGACY-KEEP → `legacy/transm/` (unclear whether still in use) |
| assembly-enriched   | (transmEnriched, solveEnriched) | LEGACY-KEEP → `legacy/transm/` |
| lpew1               | 1 kernel + 3 support | REFACTOR → `+fs/+lpew/+v1/` (kept as scalar oracle) |
| lpew2               | 1 kernel + 6 support | REPLACE → `+fs/+lpew/+v2/` (fully vectorized) |
| interp-other        | 4 | REFACTOR → `+fs/+lpew/` or `+fs/+geom/` |
| pressure            | 1 (Pinterp) | REFACTOR → `+fs/+lpew/pinterp.m` |
| permeability        | 5 (+ 3 massive `.m` — 30K+ lines each are data tables) | REFACTOR → `+fs/+perm/`; data files → `meshes/raw/` as .mat |
| boundary-condition  | 7 | REFACTOR → `+fs/+bc/` |
| timestep            | 2 | REFACTOR → `+fs/+time/cflStep.m` |
| limiter             | 1 (MLPlimiter) | REFACTOR → `+fs/+sat/limiter.m` |
| two-phase           | 2 | REFACTOR → `+fs/+sat/` |
| contaminant         | (assembly `_con` variants + IMPEC) | REFACTOR alongside pressure counterparts |
| mood                | 1 (MOODmaneger) | REFACTOR → `+fs/+sat/mood.m` |
| io                  | ~5 | REFACTOR → `+fs/+io/` |
| plot                | 2 (CatchLine, CatchPicture) + plotandwrite | REFACTOR → `+fs/+plot/` |
| utility             | ~10 | REFACTOR → `+fs/+util/` |
| benchmark           | 3 (in benchmarks/ folder) | REFACTOR → `+fs/+bench/` (keep filename) |
| deprecated-asv      | 12 `.asv` files | **DELETE-ASV** |
| unknown             | 27 | **REVIEW** with owner |

## Explicit high-risk / high-value files

### Must-vectorize (owner priority, per user directive)
1. `ferncodes_assemblematrixMPFAH.m` (820 L) → `+fs.assembly.mpfah.build` — REPLACE
2. `ferncodes_assemblematrixMPFAQL.m` → `+fs.assembly.mpfaql.build` — REPLACE
3. `ferncodes_assemblematrixNLFVH.m` → `+fs.assembly.nlfvh.build` — REPLACE
4. `ferncodes_assemblematrixNLFVPP.m` → `+fs.assembly.nlfvpp.build` — REPLACE
5. `ferncodes_assemblematrixDMP.m` + 3 helpers → `+fs.assembly.dmp.*` — REPLACE
6. `ferncodes_globalmatrix_MPFAD.m` → `+fs.assembly.mpfad.build` — REFACTOR (already env-based)
7. `Lamdas_Weights_LPEW2.m` → `+fs.lpew.v2.lambdaWeights` — REPLACE (segmented `accumarray`)
8. `ferncodes_Pre_LPEW_2.m` + `..._vect.m` + `..._con.m` → `+fs.lpew.v2.preLPEW2` — REPLACE (final kill of per-node loop)
9. `ferncodes_Ks_Interp_LPEW2.m` → `+fs.lpew.v2.ksInterp` — REPLACE
10. `angulos_Interp_LPEW2.m` + `netas_Interp_LPEW.m` + `OPT_Interp_LPEW.m` → `+fs.lpew.v2.*` + `+fs.lpew.OPT` — REPLACE
11. `ferncodes_flowratelfvMPFAQL.m` + `_con.m` → `+fs.flow.mpfaql` — REPLACE
12. `ferncodes_coefficientmpfaH.m` + `ferncodes_elementfacempfaH.m` → `+fs.assembly.mpfah.coeffs` / `elementFace` — REPLACE
13. `ferncodes_pressureinterpHP.m` + `MPFAQL.m` + `NLFVPP.m` → `+fs.lpew.pinterp{HP,QL,PP}` — REPLACE

### Massive data-embedded files (special handling)
- `permeabilitytest.m` (30073 L)
- `parametrosGauss.m` / `_1D.m` / `parametrosExpo.m` (~30000 L each)
- `getchue.m` (4101 L)
- `conduchidraulica.m` (7207 L)
→ **These are data tables masquerading as .m files.** Convert to .mat / .csv at repo root move; loader stubs at `+fs/+perm/` load them on demand.

### Preprocessors
- `preprocessor.m` (3363 L), `preprocessor2.m` (3299 L), `preprocessormod.m` (1642 L)
→ REFACTOR into `+fs/+mesh/build.m` + `+fs/+geom/` + `+fs/+io/readGmsh.m`. The three variants likely serve different mesh generators — one is the reference, the others need diffing.

### Legacy transmissibility (large + globals-heavy)
- `transmFPS*.m`, `transmTPS*.m`, `transmEnriched.m`, `transmAxissTPS.m`, `transmTPS_MSFV.m` (each 800-1200 L, 5-10 globals each)
→ LEGACY-KEEP unless owner confirms they're on the runtime path. If active → REPLACE.

## Migration order (dependency-driven)

**Phase A — foundation (unblocks everything else):**
1. `+fs/+mesh/build.m` — construct FS struct from raw gmsh
2. `+fs/+geom/*` — centroids, normals, face midpoints, areas
3. `+fs/+geom/nodeToCornerCSR.m` — the KEY vectorization enabler
4. `+fs/+util/*` — assertFS, padRagged, csrShift, accumarray2
5. `flowsim_init.m` + `flowsim_deinit.m` — path setup
6. `tests/` scaffolding — golden-oracle harness

**Phase B — LPEW2 vectorization (small surface, high leverage):**
7. `+fs/+lpew/OPT.m` — batched geometry gather (kills the innermost geometry loop)
8. `+fs/+lpew/+v2/angulos.m` + `netas.m` — pure arithmetic over corners
9. `+fs/+lpew/+v2/ksInterp.m` — batched tensor projection
10. `+fs/+lpew/+v2/lambdaWeights.m` — segmented `accumarray` interior; masked boundary
11. `+fs/+lpew/+v2/preLPEW2.m` — the loop-free driver
12. Oracle-diff vs `ferncodes_Pre_LPEW_2.m` on all 16 test meshes → 1e-12 rel Frobenius

**Phase C — Assembly vectorization (largest surface):**
13. `+fs/+assembly/+mpfad/build.m` — port the already-env-based file first as reference for the triplet pattern
14. `+fs/+assembly/+mpfah/{faceCoeffs,boundaryCoeffs,build}.m` — hardest (820 L legacy)
15. `+fs/+assembly/+mpfaql/*.m`
16. `+fs/+assembly/+nlfvh/*.m` + `+nlfvpp/*.m`
17. `+fs/+assembly/+dmp/*.m` (+ 3 helpers folded into one masked pass)
18. `+fs/+assembly/+tpfa/*.m` (baseline, small)
19. Oracle-diff each vs legacy on golden matrices → 1e-12 rel Frobenius on M and RHS

**Phase D — Flow rate + post-processing:**
20. `+fs/+flow/{mpfa,nlfv,spectral}.m`
21. `+fs/+lpew/pinterp*.m`

**Phase E — Non-hot-path files:**
22. Batch-move remaining files by bucket (saturation, timestep, IO, plot, benchmark, factory, sim, method classes)
23. Delete all `.asv` files
24. Owner-triage the 27 `unknown` files
25. Final `legacy/` cleanup — remove any file whose vectorized twin is gate-green

**Phase F — Verification + docs:**
26. Regression benchmark on all 16 test meshes: runtime + accuracy
27. `docs/vectorization-guide.md`, `docs/migration-log.md`
28. Delete `legacy/` files whose vectorized twin has been production-clean for one full test cycle

## Correctness oracle spec

```matlab
function [ok, report] = fs_oracle_diff(FSlegacy, FSvect, tol)
%  tol.frobenius  = 1e-12
%  tol.linfinity  = 1e-10
%  tol.matrixRel  = 1e-12
%  tol.flowRel    = 1e-10
    % Assemble both matrices, compare
    [M0, I0] = ferncodes_assemblematrixMPFAH_LEGACY(...);
    [M1, I1] = fs.assembly.mpfah.build(FSvect, ...);
    ok.M   = norm(M0 - M1, 'fro') / norm(M0, 'fro') < tol.matrixRel;
    ok.RHS = norm(I0 - I1)         / norm(I0)         < tol.linfinity;
    % Solve both, compare pressure
    p0 = M0 \ I0;
    p1 = M1 \ I1;
    ok.p   = norm(p0 - p1) / norm(p0) < tol.linfinity;
    report = ...
end
```

Every REPLACE-tagged file gets a matching entry in `tests/unit/` that invokes `fs_oracle_diff` on ALL 16 mesh fixtures (`meshes/hermeline/*.msh` + `meshes/kozdon/M8*.msh`).
