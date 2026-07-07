# PR list — flowsim-vectorize

_Companion to `02-plan.md`. Every PR gets one row. Order = merge-order (respects dependencies)._

## Legend
- **id**: PR-<PHASE><INDEX>, e.g. PR-A3, PR-C2
- **depends**: earlier PRs that MUST be green before this can merge
- **owner**: `axon` (autonomous), `human` (owner input needed to unblock), `both`
- **branch**: always `flowsim-artur` (single working branch per owner directive)
- **tests**: which test file(s) the PR adds/updates
- **legacy**: what happens to the corresponding legacy code — `keep` (still called), `shadow` (new wins but legacy accessible), `delete` (removed at merge)

## Foundation (Phase A)

| id | depends | owner | title | tests | legacy |
|---|---|---|---|---|---|
| PR-A1 | — | axon | `flowsim_init.m` + `flowsim_deinit.m` at repo root (path setup) | `tests/smoke/smoke_env.m` (existing) | — |
| PR-A2 | — | **both** | Fix broken OOP: create `SolverBase.m` + `BenchmarkBase.m` OR rename Solver* → Metodo* | `tests/smoke/smoke_class_hierarchy.m` (existing) — flip to expect all-OK | keep |
| PR-A3 | A1 | axon | `+fs/+util/assertFS.m` — 5-invariant checker for FS struct | `tests/unit/unit_assertFS.m` | — |
| PR-A4 | A1, A3 | axon | `+fs/+mesh/build.m` — adapt preprocessormod output → FS.mesh + FS.geom | `tests/unit/unit_fs_build.m` | shadow |
| PR-A5 | A4 | axon | `+fs/+csr/buildCorners.m` — the CSR corner layout | `tests/unit/unit_csr_corners.m` | — |
| PR-A6 | A5 | axon | Golden-baseline capture (`tests/helpers/capture_baseline.m` + first `tests/golden/M8-num439-{tpfa,mpfad}.mat`) | `tests/unit/unit_baseline_present.m` | — |
| PR-A7 | A6 | axon | Add `unit_baseline_reproduces.m` — replay the baseline capture, assert Frobenius diff = 0 | (self) | — |

## LPEW2 vectorization (Phase B)

| id | depends | owner | title | tests | legacy |
|---|---|---|---|---|---|
| PR-B1 | A5 | axon | `+fs/+lpew/OPT.m` — batched geometry gather (replaces `OPT_Interp_LPEW`) | `tests/unit/unit_lpew_OPT.m` | shadow |
| PR-B2 | B1 | axon | `+fs/+lpew/+v2/{angulos,netas}.m` — per-corner arithmetic | `tests/unit/unit_lpew2_angles.m`, `unit_lpew2_netas.m` | shadow |
| PR-B3 | B1 | axon | `+fs/+lpew/+v2/ksInterp.m` — batched tensor projection | `tests/unit/unit_lpew2_ks.m` | shadow |
| PR-B4 | B2, B3 | axon | `+fs/+lpew/+v2/lambdaWeights.m` — segmented accumarray | `tests/unit/unit_lpew2_lambda.m` | shadow |
| PR-B5 | B4 | axon | `+fs/+lpew/+v2/preLPEW2.m` (loop-free driver) + wire MetodoMPFAD.atualizarPremethod behind `env.config.useVectLPEW2` flag | `tests/unit/unit_lpew2_pipeline.m` (Frobenius vs baseline) | shadow |

## Assembly vectorization (Phase C)

| id | depends | owner | title | tests | legacy |
|---|---|---|---|---|---|
| PR-C1 | A5, A6 | axon | `+fs/+assembly/+mpfad/{faceCoeffs,boundaryCoeffs}.m` | `tests/unit/unit_mpfad_face_coeffs.m` | shadow |
| PR-C2 | C1 | axon | `+fs/+assembly/+mpfad/build.m` — one-shot triplet-form sparse; wire MetodoMPFAD.montarSistema behind `env.config.useVectAssembly` flag | `tests/unit/unit_mpfad_build.m` (Frobenius vs baseline) | shadow |
| PR-C3 | A5, A6 | axon | `+fs/+assembly/+tpfa/{faceCoeffs,boundaryCoeffs,build}.m` — TPFA counterpart | `tests/unit/unit_tpfa_build.m` | shadow |
| PR-C4 | A2, C1, C2 | axon | `+fs/+assembly/+mpfah/{...}` — 820L rewrite (BLOCKED until PR-A2 fixes MPFA-H OOP) | `tests/unit/unit_mpfah_build.m` | shadow |
| PR-C5 | A2, C1, C2 | axon | `+fs/+assembly/+nlfvpp/{...}` + `+mpfaql/{...}` | `tests/unit/unit_nlfvpp_build.m`, `unit_mpfaql_build.m` | shadow |
| PR-C6 | A2, C1, C2 | axon | `+fs/+assembly/+dmp/{...}` + `+nlfvh/{...}` (+ 3 DMP helpers folded into masked pass) | `tests/unit/unit_dmp_build.m`, `unit_nlfvh_build.m` | shadow |

## Flow + post-processing (Phase D)

| id | depends | owner | title | tests | legacy |
|---|---|---|---|---|---|
| PR-D1 | C2 | axon | `+fs/+flow/mpfad.m` — vectorized `ferncodes_flowrate` | `tests/unit/unit_flow_mpfad.m` | shadow |
| PR-D2 | C3 | axon | `+fs/+flow/tpfa.m` — vectorized `ferncodes_flowrateTPFA` | `tests/unit/unit_flow_tpfa.m` | shadow |
| PR-D3 | B5 | axon | `+fs/+lpew/pinterp.m` — vectorized rename of misnamed `ferncodes_pressureinterpNLFVPP` (shared kernel, not NLFVPP-specific) | `tests/unit/unit_pinterp.m` | shadow |

## Reorganization (Phase E — mechanical, parallelizable)

| id | depends | owner | title | tests | legacy |
|---|---|---|---|---|---|
| PR-E1 | — | axon | Move all `.msh` to `meshes/{hermeline,kozdon,other}/` + update loaders | (all smoke) | — |
| PR-E2 | — | axon | Delete all `.asv` autosaves (owner-authorised); add `*.asv` to `.gitignore` | — | delete |
| PR-E3 | — | axon | Move `transm*.m` (8 files) to `legacy/transm/` | `smoke_env` | shadow |
| PR-E4 | — | axon | Move `preprocessor.m` + `preprocessor2.m` to `legacy/preprocessor/` (canonical is `preprocessormod`) | `smoke_env` | shadow |
| PR-E5 | — | axon | Extract `parametrosGauss*.m` + `parametrosExpo.m` + `conduchidraulica.m` (~97k LOC) to `data/` as `.mat` with loader stubs | `tests/unit/unit_data_tables.m` | shadow |
| PR-E6 | — | axon | Move `ferncodes_*_con.m` variants (all dead) to `legacy/ferncodes-con/` | `smoke_env` | shadow |
| PR-E7 | E3, E4, E6 | axon | Group remaining `ferncodes_*` into `legacy/ferncodes/{mpfad,mpfah,mpfaql,nlfvh,nlfvpp,dmp,shared}/` | (all smoke) | shadow |

## Cleanup + rename (Phase F)

| id | depends | owner | title | tests | legacy |
|---|---|---|---|---|---|
| PR-F1 | A4 | axon | Kill `global` decls from the reachable set (one file per PR — track subprogress with PR-F1a...F1z) | oracle diff after each | — |
| PR-F2 | D3 | axon | Rename cross-cluster kernels (pressureinterp, iterpicardANLFVPP2, etc.) to true-home names in `+fs/` | (per rename) | delete |
| PR-F3 | E7 | axon | Triage 27 unknown-bucket files — one disposition per PR (delete/keep/refactor) | (per file) | (per file) |
| PR-F4 | A1 | axon | Update `base/startup.m` to invoke `flowsim_init` — one entry point | `smoke_env` | shadow |
| PR-F5 | ALL | axon | Add `CHANGELOG.md` and `docs/vectorization-guide.md` | — | — |

## Summary

- **Total PRs**: 33
- **Autonomous**: 32 (owner input only on PR-A2)
- **Human decision needed**: 1 (PR-A2 — SolverBase creation vs Solver→Metodo rename)
- **Blocked chains**: PR-A2 → C4, C5, C6 (MPFA-H, NLFVPP, MPFAQL, DMP assembly all wait on OOP resolution)
- **Deletes / shrinks**: ~110000 LOC of dead code, autosaves, embedded data tables

## Merge-order fast-track (unblocked chain)

If PR-A2 is deferred, the unblocked chain is:
```
A1 → A3 → A4 → A5 → A6 → A7
           ↓
           B1 → B2, B3 → B4 → B5 → D3
           ↓
           C1 → C2 → D1
           ↓
           C3 → D2
```
Phase E can start immediately in parallel (any PR not touching MPFA-H/NLFVPP/MPFAQL/DMP surface).
