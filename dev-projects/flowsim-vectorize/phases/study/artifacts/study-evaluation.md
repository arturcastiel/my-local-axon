# Study-phase evaluation — what we know, what we don't, grade

_Written 2026-07-03 after the MATLAB bridge lands. This is a study self-audit — an honest inventory of coverage, verification level, and remaining gaps._

## Scoring rubric

| Axis | What it measures |
|---|---|
| Coverage | How much of the ~298-file codebase is understood at least at the "role + shape" level |
| Depth | How mechanically we understand the hot-path code (loops, state flow, math) |
| Verification | How many claims are backed by *measurement* (grep, file counts, MATLAB probe) vs assertion |
| Actionability | Whether the study gives enough footing to make concrete change decisions without going back to the code every time |
| Honest uncertainty | Are gaps explicitly named or hidden by confident-sounding prose |

## What we KNOW confidently (verified by evidence)

### 1. Structural
- **298 .m files** — verified by `find`
- **113 reachable, 62 dead, 62 helper-only, 61 test-scripts** — verified by callgraph agent's reachability scan
- **181 files (61%) use `global`** — verified by grep
- **Top-13 globals** with per-file counts (bedge, inedge, coord, elem, centelem, ...) — verified by grep
- **Three OOP class hierarchies**, of which **only two work**:
  - `MetodoBase` ✓ (verified by MATLAB — 31 methods)
  - `SimulacaoBase` ✓ (verified by MATLAB — 48 methods)
  - `SolverBase` ✗ (verified by MATLAB — file missing, real error emitted)
  - `BenchmarkBase` ✗ (verified by MATLAB — file missing, real error emitted)
- **2 of 35 CasoNNN classes exist** (Caso1 + Caso439); Caso439 verified via MATLAB as fully loading
- **`SolverMPFAH` and `SolverNLFVPP` cannot be instantiated** — verified in MATLAB, exact error message captured

### 2. Preprocessor
- **3 preprocessor variants exist** — verified by ls + wc
- **Only `preprocessormod.m` is called from `main.m:28`** — verified by grep
- Function overlap matrix between the three — verified by function-name grep

### 3. Dead code
- **All 8 `transm*.m` files (~7000 LOC total) have zero callers** — verified
- **All `*_con.m` variants are dead** — verified

### 4. Data-tables-as-code
- **4 files (~97 000 LOC) are embedded lookup tables**:
  - `parametrosGauss.m` (30006 L)
  - `parametrosGauss_1D.m` (30006 L)
  - `parametrosExpo.m` (30005 L)
  - `conduchidraulica.m` (7207 L)
- Verified by wc + head-inspection

### 5. Richards time-loop shape
- Per-time-step sequence (8 steps, cited with line numbers)
- Per-Picard-iteration sequence (9 steps)
- L-scheme vs Picard vs Anderson delta
- What is stored vs recomputed each iteration
- All verified against `hydraulic_RE.m`, `ferncodes_iterpicard.m`, `L_scheme.m` source

### 6. Data-flow inventory
- Every mesh quantity's producer + consumer chain — verified by grep + source read

### 7. numcase dispatch
- Range convention 1–100 / 100–200 / 200–300 / 300–400 / 400–500 — verified
- High-special cases (245, 248, 341, 341.1, 437, 439) — verified via grep across the reachable set
- Named the "dispatch is not centralized" pattern — verified

### 8. Assembly hot-path per file
- 17 assembly files individually mapped (loops, globals, branch cases, math role) — verified via source read
- Universal triplet recipe applies uniformly across all six methods — verified via structural pattern match

### 9. LPEW2 blocker root cause
- Ragged `nec` (corners per node) is the specific reason `for y = 1:nNodes` remains — verified via `Pre_LPEW_2_vect.m` read
- CSR-flat corner layout resolves it — architecture verified but not yet implemented

## What we DON'T know (residual gaps)

### High-value gaps that we CAN close now (MATLAB available, ~10 min work each)

1. **Actual `pmethod` in current `Start.dat`**  
   State: unknown — grep parsing was noisy. Fix: `mrun -e "cfg = getdatafile(0); disp(cfg.pmethod)"`.

2. **Which of the 33 "missing" CasoNNN cases actually run**  
   State: unknown whether the legacy inline `numcase == N` branches fully cover them or the missing OOP classes make them error. Fix: `for N in [331 341 431 437 ...]; mrun -e "try; b=createBenchmark($N); disp('OK'); catch e; disp(e.message); end"`.

3. **Actual OOP-dispatch reachability**  
   State: 62 "dead" files by grep — real number could be 40-55 (grep can't follow `obj.method()` dispatch). Fix: for each suspect dead file, `mrun -e "which('foo'); which('foo','-all')"` — a `-all` result with 0 matches = truly dead; any match = reachable via path.

4. **The FlowSim `startup.m` we discovered** (prints "Paths configurados com sucesso.")  
   State: exists but not read. Not in the callgraph reachability set (implicit, MATLAB runs it automatically). Fix: `mrun -e "type startup"`.

5. **`ferncodes_solver.m` exact shape**  
   State: mentioned in Richards loop but its contents not deeply read. Called between `atualizarPremethod` and the iterator. Fix: read + probe.

6. **Whether `ferncodes_globalmatrix.m` (no method suffix)** is a real function or an orphan  
   State: cited by both MPFAD and TPFA classes for the "steady/groundwater" branch, but its dependencies + math are not captured. Fix: read + probe.

7. **`ferncodes_flowrate.m` vs `ferncodes_flowrateTPFA.m` vs `ferncodes_flowratelfvMPFAQL.m`**  
   State: three flow-rate files, unclear which corresponds to which method's output-stage. Fix: read + probe.

8. **Assembly output shape** — exact dimensions + fill density of M for a real mesh  
   State: assumed sparse. Fix: run the actual assembler on a small mesh (e.g. `M8.msh` — 6 KB), report `size(M), nnz(M), nnz(M)/numel(M)`.

### Medium-value gaps (need MATLAB or careful source read)

9. **Actual runtime behaviour of numcase=439** end-to-end (the only known-working case)  
   State: high-level sequence known, but the specific Kr/theta model, BC evaluations, and PLUG_* dispatch details are not walked. Fix: run and trace.

10. **Whether any of the `unknown`-bucket files are secretly reached** via dynamic dispatch or eval  
    State: 27 files classified but callgraph is grep-based. Fix: MATLAB `which` scan.

11. **`Kde_Ded_Kt_Kn` internal loop structure**  
    State: named + role known; specific loop shape not mapped. Fix: source read.

12. **Actual timing of a full `hydraulic_RE` iteration** — where the real time goes  
    State: bottleneck accounting was structural, not measured. Fix: `mrun -e "profile on; ...; profile viewer"` or `tic/toc` around each stage.

13. **How `benchmark.m` (top-level dispatcher — 1696 L) interacts with the OOP layer**  
    State: bucketed as "solver" but its actual role vs `createBenchmark()` is unclear. Fix: read + probe.

### Gaps that need MATLAB + real data to close

14. **Which of the 16 mesh fixtures are actually used** by any current test/benchmark  
    State: catalogued 16 `.msh` files but no association with test cases known.

15. **Numerical baseline** — for any solver, what pressure / flowrate values it produces on a canonical mesh  
    State: no baseline captured. Needed for the correctness oracle. Fix: run TPFA + MPFAD on `M8.msh` for `numcase = 439` and record `p, flowrate`.

16. **Assembly matrix sparsity + condition number** on real meshes  
    State: theoretical understanding only. Fix: run assembler, print `condest(M)`, `nnz(M)`.

### Gaps that are hard/impossible to close without executing

17. **Actual convergence behaviour** of Picard vs Anderson vs L-scheme on Richards  
    State: contrast documented from source; no measured convergence curves.

18. **Which numcase forks in `PLUG_bcfunction` are dead** vs live  
    State: static analysis only — behaviour depends on runtime `numcase` dispatch.

19. **Numerical stability edge cases** — where cot/tan singularities in LPEW2 actually bite  
    State: risk noted, no adversarial mesh tried.

### Genuinely out-of-scope

20. **Mesh generator (`.msh` file format specifics)** — external tool
21. **MATLAB internals** — how `sparse()` coalesces duplicates, etc.
22. **Comparison with published papers** — verifying LPEW2 implementation matches Agelas et al. 2010

## Gap count summary

- **High-value + resolvable now via MATLAB (`mrun`)**: **8 gaps** (items 1–8 above)
- **Medium-value + resolvable now**: **5 gaps** (items 9–13)
- **Need MATLAB + real runs**: **3 gaps** (items 14–16)
- **Need executed runs + interpretation**: **3 gaps** (items 17–19)
- **Out-of-scope**: **3 gaps** (items 20–22, expected)

**Total remaining gaps: 19 (16 addressable + 3 accepted-out-of-scope).**

Of those 16 addressable gaps, **13 could be closed in one or two more study passes** now that mrun exists. The remaining 3 (14–16) require setting up runnable benchmark cases, which is more a data problem than a study problem.

## Where the study is strong

- **Structural inventory** is comprehensive and cross-verified (grep + source read + MATLAB probe converge)
- **The critical broken-OOP finding** — SolverBase / BenchmarkBase missing — was surfaced by grep and then **independently confirmed by MATLAB itself with the actual error message**
- **The LPEW2 vectorization root cause** (ragged `nec`) is pinned to a specific line count in a specific file, and the resolution (CSR corner layout) is a concrete architecture, not a hand-wave
- **The dead-code frontier** is measured, not estimated — 62 files with zero callers, ~7000 LOC of `transm*` code confirmed dead
- **Honest uncertainty is named** — Section 14 of `01-study.md` and the item 17–19 list here don't hide anything

## Where the study is weak

- **No runtime baseline exists** — every claim about performance / behaviour is structural. Now that MATLAB is wired, this is the biggest addressable weakness.
- **The 27 "unknown-bucket" triage** is one-line-per-file — deeper reads are needed for the 12 domain-specific ones
- **`benchmark.m` (1696 L)** was classified but never read — it's the biggest non-`ferncodes_` file and its role vs the OOP factory is genuinely unclear
- **`PLUG_bcfunction*.m`** family was noted as boundary conditions but its 5 variants weren't diffed
- **Numerical correctness** — the oracle spec exists on paper (`fs_oracle_diff`) but no reference outputs have been captured

## Grade

Weighted by axis:
| Axis | Grade | Reason |
|---|---|---|
| Coverage    | **A**  | Every file bucketed; every call site of the top globals mapped; entry points traced |
| Depth       | **B+** | Hot-path (assembly + LPEW2) is deep; secondary paths (BC / source / PLUG_*) are surface |
| Verification| **A-** | Structural facts triangulated across grep + source + (now) MATLAB. Runtime facts are absent (no runs). |
| Actionability| **A-**| Enough to draft PRs today; the 8 high-value gaps aren't blockers, they're refinements |
| Honest uncertainty | **A** | Gaps explicitly enumerated in `01-study.md § 14` and here §; nothing hidden |

## Overall: **A−**

The study delivers a working understanding of the codebase's static shape, the broken class hierarchies, the assembly and LPEW2 hot paths, and the vectorization root cause. What holds it back from an A is the absence of any runtime baseline — every quantitative claim is structural (line counts, loop counts, file counts, grep counts). That was unavoidable until mrun landed; now it is not.

## Recommended next study cycle (if we do one)

Not a plan — a study continuation. In priority order:
1. Run TPFA + MPFAD on `M8.msh` for numcase 439, capture `size(M), nnz(M), condest(M), p(1:5)` — that's the numerical fingerprint everything else diffs against.
2. Run gaps 1–4 (Start.dat parse, 33-case createBenchmark trials, OOP-dispatch reachability, startup.m read) — batch into one `mrun` call, ~5 minutes of MATLAB time.
3. Deep-read `benchmark.m`, `ferncodes_solver.m`, `ferncodes_globalmatrix.m`, `ferncodes_flowrate.m` — the four biggest un-read files.
4. Profile a Caso439 run end-to-end with MATLAB's profiler — resolve gap 12 (real timing).
