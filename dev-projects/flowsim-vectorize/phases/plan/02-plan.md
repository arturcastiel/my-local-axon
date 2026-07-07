# Plan — flowsim-vectorize

_Authored 2026-07-03 after study phase closure. Turns study findings into a concrete PR list._
_Anchor artifacts: `../study/01-study.md`, `../study/artifacts/{folder-layout,data-structures,module-encapsulation,production-target-decision,rewrite-map}.md`_

## Goal (immutable — from study)

Heavily vectorize FlowSim, delivering line-by-line vectorized rewrites that match
legacy numerical results, organized in maximally encapsulated modules with a
runnable initializer, and validated by an oracle test harness.

## Non-goals for this project cycle

- **No GPU / MEX / parfor** — vectorization only (`bsxfun`/broadcasting, `accumarray`, sparse triplets, indexed gathers)
- **No new numerical methods** — only rewrites of existing methods
- **No paper-comparison verification** — that's a follow-up scope

## Anchoring decisions (from study)

1. **Production target**: MPFA-D. Full rationale in `../study/artifacts/production-target-decision.md`.
2. **Test infrastructure**: fresh MATLAB session per test via `tools/mrun` (WSL bridge, headless matlab.exe -batch).
3. **Correctness oracle**: Frobenius relative diff, `1e-12` for matrices, `1e-10` for pressure/flow (owner-confirmed).
4. **Working branch**: `flowsim-artur` on the FlowSim repo. All rewrites land there.
5. **Module encapsulation**: one `+fs/+<method>/` package per discretization holds its Metodo class + preprocess + assembly + flowrate + pInterp + README. Shared kernels (LPEW2, iterators, mesh, geom, CSR) live in their own siblings.
6. **Legacy retention during migration**: legacy `ferncodes_*` and `transm*` stay in `legacy/` (or in place, path-shadowed) until every dependent PR is green. Deletion is a separate late PR per file.

## Six execution phases (each a batch of PRs)

Order is dependency-driven, not chronological. Later phases assume earlier phases are green.

### Phase A — Foundation (7 PRs)
Everything else depends on this. Sets up FS struct, path initializer, oracle harness, and fixes the broken OOP hierarchies discovered by the study.

- **PR-A1** — `flowsim_init.m` + `flowsim_deinit.m` at repo root (path setup)
- **PR-A2** — Fix broken OOP: create `SolverBase.m`, `BenchmarkBase.m` OR rename `SolverMPFAH → MetodoMPFAH < MetodoBase`; decide by owner input
- **PR-A3** — `+fs/+util/assertFS.m` — invariant checker for the FS struct
- **PR-A4** — `+fs/+mesh/build.m` — construct `FS.mesh` + `FS.geom` from `preprocessormod` outputs (adapter, not a rewrite yet)
- **PR-A5** — `+fs/+csr/buildCorners.m` — the CSR corner layout (the KEY vectorization enabler)
- **PR-A6** — `tests/unit/unit_fs_build.m` + `tests/unit/unit_csr_corners.m` — first unit tests
- **PR-A7** — Golden-baseline capture script: `tests/helpers/capture_baseline.m` runs TPFA + MPFAD on `M8.msh` for numcase 439 and writes `tests/golden/M8-num439-{tpfa,mpfad}.mat`

### Phase B — LPEW2 vectorization (5 PRs)
Kill the last per-node loop in the LPEW2 pipeline. All work under `+fs/+lpew/+v2/`.

- **PR-B1** — `+fs/+lpew/OPT.m` — batched geometry gather (replaces `OPT_Interp_LPEW`)
- **PR-B2** — `+fs/+lpew/+v2/angulos.m` + `netas.m` — per-corner arithmetic (vectorized over CSR-flat corners)
- **PR-B3** — `+fs/+lpew/+v2/ksInterp.m` — batched tensor projection (replaces `ferncodes_Ks_Interp_LPEW2`)
- **PR-B4** — `+fs/+lpew/+v2/lambdaWeights.m` — segmented `accumarray` interior + masked boundary (replaces `Lamdas_Weights_LPEW2` + Neumann handling from `Pre_LPEW_2`)
- **PR-B5** — `+fs/+lpew/+v2/preLPEW2.m` — loop-free driver; wire `MetodoMPFAD.atualizarPremethod` to call it behind an `env.config.useVectLPEW2` flag; add `tests/unit/unit_lpew2_vect.m` that diffs against captured baseline

Every PR-B* ends with a `tests/unit/unit_lpew2_*.m` addition. Merges only on Frobenius-diff green.

### Phase C — Assembly vectorization (6 PRs)
Universal triplet recipe applied per method. MPFA-D first (already the cleanest starting point).

- **PR-C1** — `+fs/+assembly/+mpfad/faceCoeffs.m` + `boundaryCoeffs.m` (batched over `inedge` / `bedge`)
- **PR-C2** — `+fs/+assembly/+mpfad/build.m` — one-shot `sparse(rows, cols, vals, nE, nE)` assembly; wire MetodoMPFAD.montarSistema behind `env.config.useVectAssembly` flag
- **PR-C3** — `+fs/+assembly/+tpfa/{faceCoeffs,boundaryCoeffs,build}.m` — TPFA counterpart
- **PR-C4** — `+fs/+assembly/+mpfah/{faceCoeffs,boundaryCoeffs,build}.m` — the 820L beast (BLOCKED on PR-A2 resolving the SolverBase issue for MPFA-H)
- **PR-C5** — `+fs/+assembly/+nlfvpp/{...}` + `+fs/+assembly/+mpfaql/{...}` — same recipe (BLOCKED on PR-A2)
- **PR-C6** — `+fs/+assembly/+dmp/{...}` + `+nlfvh/{...}` — DMP variants

### Phase D — Flow rate + post-processing (3 PRs)
- **PR-D1** — `+fs/+flow/mpfad.m` — vectorized `ferncodes_flowrate` (batched over faces)
- **PR-D2** — `+fs/+flow/tpfa.m` — vectorized `ferncodes_flowrateTPFA`
- **PR-D3** — `+fs/+lpew/pinterp.m` — rename + vectorize `ferncodes_pressureinterpNLFVPP` (it's a shared kernel, not NLFVPP-specific — see study module-encapsulation.md § "cross-cluster leaks")

### Phase E — Reorganization (7 PRs, mechanical, can parallelize)
- **PR-E1** — Move all `.msh` fixtures to `meshes/{hermeline,kozdon,other}/`
- **PR-E2** — Move all `*.asv` autosave files to `/dev/null` (delete outright — owner authorised)
- **PR-E3** — Move `transm*.m` (8 files, ~7k LOC, all dead) to `legacy/transm/`
- **PR-E4** — Move `preprocessor.m` + `preprocessor2.m` to `legacy/preprocessor/` (canonical is `preprocessormod.m`)
- **PR-E5** — Move data-table `.m` files (`parametrosGauss*.m`, `parametrosExpo.m`, `conduchidraulica.m` — ~97k LOC) to `data/` as `.mat` with loader stubs
- **PR-E6** — Move `ferncodes_*_con.m` variants (all dead per callgraph agent) to `legacy/ferncodes-con/`
- **PR-E7** — Group remaining `ferncodes_*` files by cluster into `legacy/ferncodes/{mpfad,mpfah,mpfaql,nlfvh,nlfvpp,dmp,shared}/`

### Phase F — Cleanup + rename (5 PRs)
- **PR-F1** — Kill `global` declarations from the reachable set — one file per PR, oracle-diff after each
- **PR-F2** — Rename cross-cluster kernels to their true home: `ferncodes_pressureinterpNLFVPP` → `+fs/+lpew/pinterp.m`, `ferncodes_iterpicardANLFVPP2` → `+fs/+iter/anderson.m`, etc.
- **PR-F3** — Triage the 27 unknown-bucket files (see study `unknown-triage.md`) — actual DELETE/KEEP/REFACTOR one-per-file
- **PR-F4** — Update FlowSim's `startup.m` (discovered by MATLAB probe) to invoke `flowsim_init` — one entry point
- **PR-F5** — Add `CHANGELOG.md` and `docs/vectorization-guide.md`

## Total PR count: 33

Phase | PRs | Est. LOC written | Est. LOC deleted (net) | Verifiable via
:---: | :---: | :---: | :---: | :---
A | 7 | ~800 | 0 | env/class smoke, mesh smoke, capture harness
B | 5 | ~600 | 0 (legacy stays) | LPEW2 unit test (Frobenius vs baseline)
C | 6 | ~1500 | 0 (legacy stays) | Assembly unit test per method
D | 3 | ~300 | 0 (legacy stays) | Flow-rate unit test per method
E | 7 | ~50 (mostly moves) | ~110000 net (data files + `.asv` + dead code) | full smoke green after each
F | 5 | ~200 | ~5000 (dead legacy) | full harness green

## Gate mechanics

- Every PR must add or update at least one test in `tests/`.
- Every method-vectorization PR (Phases B, C, D) writes a new `+fs/` file alongside the legacy — path shadowing ensures new wins by default, but the legacy stays reachable behind an `env.config.useVect<X>` flag until Phase F retires it.
- Merge to `flowsim-artur` requires `tools/mrun tests/run_all.m` green.
- **No PR touches the AXON kernel (`axon/` tree)** — this is a FlowSim-side project, not AXON.

## Explicit blockers

- **PR-A2 blocks C4, C5, C6** — cannot vectorize MPFA-H/NLFVPP/MPFAQL/DMP/NLFVH assembly until their OOP wrappers can instantiate. Owner input requested in PR-A2 spec: create `SolverBase.m` (preserving Solver* naming) OR rename `SolverMPFAH.m` → `MetodoMPFAH.m` (aligning with factory's expectation).
- **PR-A7 blocks all B-D PRs** — no golden baseline means no correctness gate.
- **PR-E5 (data-table extraction) blocks nothing** but is high value (repo shrinks by ~1/3 of total LOC).

## Explicit non-blockers

- Phase E (reorganization) can be run entirely in parallel with B–D as long as the moved files aren't on the current PR's dependency chain.
- Phase F (cleanup) is fully after A–E.

## Study gaps still open at plan-time

Per `../study/artifacts/study-evaluation.md` — 13 addressable gaps remain. The plan tolerates them (they refine, don't block). The gap-closing next-cycle in the evaluation is a study continuation, not a plan blocker.

## Open questions surfaced by plan (need owner input)

1. **PR-A2**: create missing `SolverBase.m` + `BenchmarkBase.m` (preserve current naming) OR rename orphan `Solver*.m` files to `Metodo*.m < MetodoBase` (align with factory)?
2. **PR-A7 baseline mesh**: `M8.msh` (6 KB) is fastest for baseline capture; is that OK or should we capture on the `HermelineMeshModQuad_48_48.msh` or larger?
3. **PR-E2 (.asv deletion)**: confirmed by owner already ("yes to 7"), no further ask.
4. **PR-E5 data-table extraction format**: `.mat` (binary, fast load) or `.csv` (git-friendly diff)?
5. Fields to preserve in `env.config.numcase` dispatch for `PLUG_bcfunction`, `PLUG_sourcefunction` etc. — a follow-up refactor or leave as-is behind the `+fs/+bc/` module?

## Next

- `code-dev pr 1` — draft the first PR spec (PR-A1: flowsim_init at repo root, using the version already in `../study/artifacts/flowsim_init.m`)
- OR answer the open questions above so I can pre-adjust the plan before PR-drafting starts
