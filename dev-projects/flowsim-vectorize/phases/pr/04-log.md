# PR execution log — flowsim-vectorize

_Append-only. One line per PR event (START, DONE, HALT). One file per PR spec goes in `03-prs/PR-XX.md`._

| timestamp | PR | event | notes | commit |
|---|---|---|---|---|
2026-07-03T11:10:12Z  PR-A1  DONE   flowsim_init + deinit at root   tests: smoke_env(8/8)  commit=f8da9ad
2026-07-03T11:16:48Z  PR-A2  DONE   unified Metodo* hierarchy   tests: smoke_class_hierarchy(17/17)  commit=bd306b6
2026-07-03T11:19:54Z  PR-A3  DONE   +fs.util.assertFS               tests: unit_assertFS(5/5)          commit=747b975
2026-07-03T11:19:54Z  PR-A4  DONE   +fs.mesh.build (env→FS adapter) tests: unit_fs_mesh_build(14/14)   commit=08c9572
2026-07-03T11:19:54Z  PR-A5  DONE   +fs.csr.buildCorners            tests: unit_csr_corners(10/10)     commit=788eb0b
2026-07-03T11:55:03Z  chore  DONE   gitignore + untrack 154MB (Option A)   commit=3eebac2
2026-07-03T12:18:20Z  PR-A6  DONE   golden capture harness + M8 baselines   tests: unit_baseline_reproduces(35/35)  commit=8f62828
2026-07-03T12:18:20Z  PR-A7  DONE   unit_baseline_reproduces oracle gate     tests: self(35/35 bit-identical)         commit=407a2b4
2026-07-03T12:22:56Z  PR-E5  DONE   Option D data relocation + fs.data.paths  tests: unit_data_paths(4/4)  commit=be094f8
2026-07-03T12:25:11Z  PR-B1  DONE   +fs.lpew.OPT (batched geometry gather)  tests: unit_lpew_OPT(41/41)  commit=5d101e0
2026-07-03T12:29:15Z  PR-B2  DONE   fs.lpew.v2.angulos + netas + buildCornerShifts   tests: unit_lpew2_angulos_netas(35/35)   commit=67bcf77
2026-07-03T13:05:24Z  PR-B3  DONE   fs.lpew.v2.ksInterp (batched K projections)  tests: unit_lpew2_ksInterp(36/36)  commit=df5922b
2026-07-03T13:11:08Z  PR-B4  DONE   fs.lpew.v2.lambdaWeights (interior vect + boundary loop)   tests: unit_lpew2_lambda(9/9)   commit=5b1ab59
2026-07-03T13:14:57Z  PR-B5  DONE   fs.lpew.v2.preLPEW2 end-to-end (Phase B close)   tests: unit_lpew2_preLPEW2(8/8)   commit=8187d7e
2026-07-03T14:23:57Z  PR-C1+C2  DONE   fs.assembly.mpfad.build (fully vectorized)  tests: unit_assembly_mpfad(7/7)  commit=35811a5
2026-07-03T14:29:41Z  PR-C3  DONE   fs.assembly.tpfa.build (vectorized)   tests: unit_assembly_tpfa(7/7)   commit=699d053
2026-07-03T14:32:23Z  PR-C4+C5+C6  DONE   scaffold packages (5 assemblers)   tests: unit_assembly_scaffolds(5/5)   commit=8305a76
2026-07-03T14:33:57Z  PR-D1+D2+D3  DONE   flow-rate + pinterp scaffolds (Phase D close)   tests: unit_flow_pinterp_scaffolds(3/3)   commit=1a8878d
2026-07-03T14:36:03Z  PR-E3+E4+E6  DONE   17 dead files → legacy/   tests: smoke_env(8/8) + unit_baseline_reproduces(35/35)   commit=08c7e9a
2026-07-03T14:38:37Z  PR-F4+F5  DONE   startup.m + CHANGELOG + docs   commit=08c7e9a
2026-07-03T14:46:30Z  PR-E7+F3  DONE   ferncodes_* clustered + unknown → legacy   tests: unit_baseline_reproduces(35/35)   commit=fa09f0f
2026-07-03T14:49:39Z  PR-F5b  DONE   README + code-map + how-to-use docs   commit=fa09f0f
2026-07-03T14:50:25Z  PR-F5b  DONE   README + code-map + how-to-use   commit=a4b062c
2026-07-03T15:00:19Z  PR-E1  DONE   .msh → meshes/{hermeline,kozdon,other}/   tests: unit_baseline_reproduces(35/35)   commit=2c2d670
2026-07-03T15:02:40Z  PR-F1+F2  DONE   wrappers + globals-audit   tests: unit_fs_iter_wrappers(4/4)   commit=7514264
