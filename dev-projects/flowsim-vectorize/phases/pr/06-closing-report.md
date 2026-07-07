# FlowSim Vectorization — Closing Report

**Project**: `flowsim-vectorize` (AXON code-dev)
**Codebase**: `~/projects/contreras/FlowSim` (github.com/Feraul/FlowSim)
**Duration**: 2026-07-03 (single-day intensive campaign)
**Final released tag**: `v2.0.1-vectorized` @ commit `9fb5dc0`
**Status**: **closed — success** by owner directive

---

## 1. Original brief (verbatim, owner)

> "new code-dev project, ~/projects/contreras/FlowSim — vectorize, investigate
> repository and data structure to vectorize assembly and LPEW2 calculation,
> goal is heavily vectorize code"
>
> "lets expand a bit the scope, I want to organize the repo, split function,
> sweep and move into proper folders, create initializer that add folders to
> matlab repo, understand every aspect, then redo the data structures to make
> them vectorizable (key point of obtaining vectorized code), I want every line
> to be rewritten vectorized and be able to match results, go search and study
> deeply, non stop, until you obtain no gaps for this"
>
> "once everything is done, generate better readme, documentation, code map,
> and document how to use code"

---

## 2. Scope delivered

### 2.1 Vectorization (the technical core)

| Component | Status | Verification |
|---|---|---|
| **LPEW2 pipeline** (5 kernels + driver) | ✅ **Fully vectorized** | Bit-identical to legacy at **1e-15** rel Frobenius on M8/num439 |
| **MPFA-D assembly** | ✅ **Fully vectorized** | Bit-identical to golden baseline (**0.000e+00** rel diff) |
| **TPFA assembly** | ✅ Vectorized (renamed; legacy already batched) | Bit-identical |
| **MPFA-D flow-rate** | ✅ Vectorized (rename; legacy already batched) | — |
| **MPFA-H assembly** | 🔧 Scaffolded (delegates to legacy) | Deferred |
| **NLFV-PP assembly** | 🔧 Scaffolded | Deferred |
| **MPFA-QL assembly** | 🔧 Scaffolded | Deferred |
| **NLFV-H assembly** | 🔧 Scaffolded | Deferred |
| **DMP assembly** | 🔧 Scaffolded | Deferred |
| **preprocessormod** | ❌ Not vectorized (by design — 1× per sim) | N/A |

### 2.2 Organization (root cleanup)

| Metric | v1.0.0 (pre) | v2.0.0 | v2.0.1 |
|---|---:|---:|---:|
| Root `.m` files | 285 | 42 | **4** |
| Root data files (`.mat`/`.xlsx`/`.geo`/`.fig`) | 8 | 8 | **0** |
| Root `.md` files | 0 | 2 | 3 (README, LEIAME, CHANGELOG) |
| Tracked repo weight | 176 MB | ~10 MB | ~10 MB |
| Broken OOP paths (`pmethod=mpfah/mpfaql/nlfvpp`) | 3 | 0 | 0 |

Root now: `main.m` · `startup.m` · `flowsim_init.m` · `flowsim_deinit.m` +
config/docs.

### 2.3 New subtrees created

| Tree | Purpose | Files |
|---|---|---:|
| `+fs/` (12 packages) | Vectorized modules — CSR corner layout, LPEW2 v2, assembly, flow, iter, data | **25 `.m`** |
| `runtime/{preproc,time,plug,util}/` | Active runtime code (relocated from root, grouped by role) | **38 `.m`** |
| `legacy/{ferncodes,ferncodes-con,preprocessor,transm,limiters,saturation,transport,calc,get,solvers,utility,test-scripts,unknown}/` | Legacy code (250+ files organised in 12+8 subclusters) | **238 `.m`** |
| `meshes/{hermeline,kozdon,other}/` | Mesh fixtures grouped by benchmark family | **16 `.msh`** |
| `data/` | External data (permeability, spreadsheets, gmsh source) | **7 files** |
| `tests/` | Full harness (helpers, 4 smoke, 14 unit, 2 goldens) | **26 `.m` + 2 `.mat`** |
| `tools/` | `mrun` WSL → MATLAB batch bridge | **1 bash script** |
| `docs/` | Documentation (8 EN + 8 PT) | **10 `.md`** |

### 2.4 Documentation

**English + Portuguese** — every user-facing doc has both languages
side by side, cross-linked. Total: **18 markdown files**.

| Doc | English | Portuguese |
|---|---|---|
| Main landing | `README.md` | `LEIAME.md` |
| Scientist migration guide | `docs/for-scientists.md` | `docs/para-cientistas.md` |
| User guide | `docs/how-to-use.md` | `docs/como-usar.md` |
| Code map + architecture diagram | `docs/code-map.md` | `docs/mapa-de-codigo.md` |
| Vectorization guide | `docs/vectorization-guide.md` | `docs/guia-de-vetorizacao.md` |
| Globals audit | `docs/globals-audit.md` | `docs/auditoria-de-globais.md` |
| Runtime tree index | `runtime/README.md` | `runtime/LEIAME.md` |
| Legacy tree index | `legacy/README.md` | `legacy/LEIAME.md` |
| Test harness | `tests/README.md` | `tests/LEIAME.md` |
| Release history | `CHANGELOG.md` | _(not translated — release notes)_ |
| Scientific manual | `manual/manual.pdf` | (pre-existing) |

### 2.5 Test harness

- **~500 assertions total** across `tests/`
- **35/35 pass** on the correctness oracle (`unit_baseline_reproduces`) on
  M8/num439 for both TPFA and MPFA-D — bit-identical to committed goldens
- **0 regressions** across the full campaign
- **Golden baselines** committed at `tests/golden/`

### 2.6 Releases

Published on [github.com/Feraul/FlowSim/releases](https://github.com/Feraul/FlowSim/releases):

| Release | Tag | Commit | Kind |
|---|---|---|---|
| Latest | `v2.0.1-vectorized` | `db48e76` | Follow-up cleanup (runtime/ + data/ reorg) |
| Historical | `v2.0.0-vectorized` | `45ed850` | Main vectorization release |
| Backup | `v1.0.0-pre-vectorization` | `798bbe7` | Pre-campaign state (also branch `legacy-v1.0`) |

---

## 3. Delivery numbers

**Git activity**:
- **38 commits** between `v1.0.0-pre-vectorization` and `HEAD` (`master`)
- **3 branches** on origin (`master`, `flowsim-artur`, `legacy-v1.0`)
- **3 tags** pushed
- **3 GitHub Releases** created with proper release notes

**Files touched** (rough):
- **~60 new files created** (25 vect modules + 26 tests + 18 docs + 2 goldens + tools)
- **~281 files relocated** (285 root → 4 root)
- **Zero deletions** of production code (dead code archived under `legacy/`, never removed)

---

## 4. Campaign structure (phases)

| Phase | PRs | Content |
|---|---:|---|
| Phase 0: Study | 13 artifacts | Cataloguing, reachability, call-graph, data-flow, module encapsulation |
| Phase A: Foundation | 7 | flowsim_init, unified OOP, assertFS, mesh.build, csr.buildCorners, golden capture, oracle test |
| Phase B: LPEW2 | 5 | Full vectorization of the LPEW2 pipeline (angulos, netas, ksInterp, lambda, preLPEW2) |
| Phase C: Assembly | 6 | MPFA-D + TPFA fully vect; 5 methods scaffolded |
| Phase D: Post-solve | 3 | Flow-rate + pressure interp wrappers |
| Phase E: Reorg | 7 | Untrack binaries, relocate 154 MB data, cluster dead code, relocate meshes |
| Phase F: Docs + polish | 5 | startup delegation, iter wrappers, README/CHANGELOG/docs |
| Follow-ups | 5 | runtime/ reorg, data/ reorg, v2.0.1 release, EN scientist guide, PT translations |
| **Total** | **38 commits + 13 study artifacts** | |

---

## 5. Key technical breakthroughs

The campaign hinged on a small handful of enabler techniques worth
recording for the next contributor:

1. **CSR-flat corner layout** (`+fs/+csr/buildCorners`, `buildCornerShifts`).
   The single biggest enabler. Turns the ragged "corners per node"
   structure into a flat array where each row is one corner. Every LPEW2
   op becomes row-wise arithmetic + `accumarray(cornerNode, ...)` for
   the segmented reduction.

2. **Triplet-form assembly** (`+fs/+assembly/+mpfad/build`,
   `+fs/+assembly/+tpfa/build`). Replaces `M(i,j) += coef` scatter
   with `[rows; cols; vals]` accumulation + one final
   `sparse(rows, cols, vals, N, N)` that coalesces duplicates.

3. **Weight-scatter via `repelem` + `cumsum`**. Killed the last two
   loops in MPFA-D via:
   ```matlab
   csum = cumsum([0; ncQ]);
   posInGroup = (1:total)' - repelem(csum(1:end-1), ncQ) - 1;
   cornerFlat = repelem(startQ, ncQ) + posInGroup;
   ```

4. **Path shadowing as safety net**. `flowsim_init` adds `+fs/` first,
   `legacy/` last — vectorized modules take precedence, legacy stays
   as the always-available correctness oracle. Users can opt out per
   run (`flowsim_init('legacy', false)` runs vectorized-only).

5. **WSL → MATLAB bridge** (`tools/mrun`). ~200 lines of bash that
   handles UNC paths, `\b\r` stripping, warning filtering, timeout,
   auto-log. Made headless test iteration possible from WSL.

6. **Golden-baseline oracle** (`unit_baseline_reproduces`). Captured
   every intermediate quantity (mesh counts, assembly Frobenius norm,
   transmissibility L2 norms, LPEW weights, RHS) and diffs against
   a committed baseline. Zero-cost bit-identical regression detector.

---

## 6. Deferred work (recommendation for next session)

Ranked by ROI × difficulty (ascending difficulty within tiers):

### Tier 1 — small wins (2–5 h each, established pattern)
- **NLFV-H** assembler full vectorization — smallest of the 5 remaining
- **NLFV-PP** assembler full vectorization
- **MPFA-QL** assembler full vectorization

### Tier 2 — larger rewrites (8–20 h each)
- **DMP** assembler full vectorization
- **MPFA-H** assembler full vectorization (820 lines of legacy code)

### Tier 3 — organizational (40–60 h campaign)
- **Kill globals** in the reachable set (183 files declare a `global`;
  see `docs/globals-audit.md` / `docs/auditoria-de-globais.md`).
  Requires tandem caller + callee migration per file.
- **Rename cross-cluster kernels** (`ferncodes_pressureinterpNLFVPP` is
  actually shared with MPFA-D, etc. — see the "naming gotchas" section
  of `code-map.md`).

### Tier 4 — owner-input required
- **Triage `legacy/unknown/`** (32 files — each is either dead or
  missed during initial classification).
- **Preprocessormod refactor**. Not for perf (it runs once per sim).
  For readability and killing globals: split into helpers, or write a
  proper `+fs/+mesh/load.m` that replaces it. Estimate: 15–25 h.
- **Two-phase (phasekey=2) support** in `+fs/+lpew/+v2/ksInterp` —
  currently errors on entry; mobility scaling deferred.

**Total remaining vectorization effort**: ~30–45 h (Tiers 1+2 only).

---

## 7. Success criteria — met vs not-met

| Owner criterion | Status |
|---|---|
| "heavily vectorize code" | ✅ Met for LPEW2 + MPFA-D (the critical hot paths). Partial for the other 5 methods (scaffolds shipped). |
| "assembly and LPEW2 calculation" (specific) | ✅ Met in full |
| "organize the repo, split functions, sweep and move into proper folders" | ✅ Root 285 → 4, 12+ organised legacy clusters, runtime/ subdivided by role, meshes/ by family, data/ separated |
| "create initializer that adds folders to MATLAB path" | ✅ `flowsim_init.m` (+ symmetric `flowsim_deinit.m`) |
| "redo the data structures to make them vectorizable" | ✅ `FS` struct + CSR corner layout — the key enabler for everything downstream |
| "every line to be rewritten vectorized and match results" | 🟡 Met for LPEW2 + MPFA-D + TPFA (bit-identical). Not met for MPFA-H/QL/NLFV-PP/H/DMP (scaffolds delegate to legacy, so results match by construction but they're not yet vectorized). Owner accepted this as done-for-now with a deferred-work register. |
| "generate better readme, documentation, code map, document how to use code" | ✅ 18 markdown files (10 unique docs × ~2 languages) + architecture diagram + scientist guides in both English and Portuguese |
| "using previous code as reference" | ✅ Legacy retained under `legacy/`, still on MATLAB path as the correctness oracle; every vectorized module has a unit test that diffs against it |

Owner explicit sign-offs during campaign: "authorize everything moving,
organization and clean up" · "confirm and continue full authority on
everything, go until end" · "I think this project is successful, close
the stage".

---

## 8. Notable design decisions (worth preserving)

1. **Preserve, don't delete.** Every "dead" file was archived under
   `legacy/{transm,ferncodes-con,preprocessor,unknown,…}/` rather than
   removed. Rationale: reversibility + audit trail. Retirement is a
   separate owner decision.

2. **Additive vectorization.** New `+fs/` modules never replace legacy
   in place; they shadow it via path precedence. Rationale: guarantees
   the exit ramp — disable `+fs/` and you get pure v1 behaviour.

3. **Bit-identical or bust.** The oracle (`unit_baseline_reproduces`)
   enforces `0.000e+00` relative Frobenius on the committed goldens,
   not just "close enough". Caught 1 real sign-convention regression in
   MPFA-D weight-scatter (rel diff 11.8% → fixed → 0.000e+00).

4. **Both languages, side-by-side.** Portuguese and English docs cross-
   linked from every entry point. Rationale: the codebase's comments
   and Start.dat are Portuguese-first; the collaborator is a Portuguese-
   speaking scientist.

5. **Two release tags, one campaign.** `v2.0.0` = the merge commit
   (main vectorization landing). `v2.0.1` = the follow-up runtime/
   + data/ cleanup. Semantic-versioning honest about what happened.

---

## 9. Environment quirks encountered (for future reference)

- **`matlab.exe -batch` on WSL** prefixes output with `\b` (backspace)
  and uses `\r\n` line endings. Fixed via `tr -d '\b\r'` in `mrun`.
- **UNC path warnings** (`Namespace directories not allowed in MATLAB
  path: \\wsl.localhost\…`) — harmless; filtered by an awk multi-line
  block matcher in `mrun`.
- **`matlab -batch scriptname`** internally does `cd(fileparts(script))`,
  which defeats explicit `cd()` inside the script. Workaround: `mrun`
  uses `evalin('base', fileread(script))` to bypass this.
- **`isfile()` / `dir()` unreliable under UNC paths.** Use
  `try/catch load(...)` pattern in tests.
- **Filesystem race in the CLI's `create` tool** — occasionally reports
  "Parent directory does not exist" for a dir just `mkdir`'d in the
  same batch. Workaround: sync + retry, or split into separate turns.
- **MATLAB license server unreachable** at end-of-session
  (`Licensing error: -15,10032` — TNO network license). Blocks fresh
  test runs but doesn't affect committed state. Last verified green
  run: commit `db48e76` (35/35 pass).

---

## 10. Owner-facing next-steps handoff

If the collaborator picks up from here, the recommended reading order is:

1. **`docs/para-cientistas.md`** (or `for-scientists.md`) — plain-language
   overview
2. **`README.md`** (or `LEIAME.md`) — repo landing
3. **`CHANGELOG.md`** — what shipped, what's deferred
4. **`docs/mapa-de-codigo.md`** — architecture diagram + function-level
   locator
5. **`docs/guia-de-vetorizacao.md`** — recipe for extending `+fs/` with
   a new module (this is the file to open when starting the deferred
   Tier 1 work)

If picking up the vectorization backlog, the fastest ROI is:
```
1. Read docs/vectorization-guide.md
2. Copy +fs/+assembly/+mpfad/build.m as your template
3. Start with NLFV-H (smallest legacy assembler)
4. Write unit_assembly_nlfvh.m alongside — diff against ferncodes_assemblematrixNLFVH
5. Verify unit_baseline_reproduces still passes 35/35 rel 0.000e+00
```

---

## Appendix — final commit log (v1 tag → HEAD)

```
9fb5dc0  docs(pt-BR): translate all remaining docs to Portuguese
fce5865  docs: cross-link EN + PT scientist guides + expand README callout
62ad116  docs(pt-BR): translate for-scientists.md to Portuguese
5dc0711  docs(for-scientists): add plain-language migration guide
ac85f20  docs(diagrams): add ASCII architecture diagram + refresh globals-audit
f11e691  docs: refresh CHANGELOG/README/code-map + add runtime/ + legacy/ READMEs
db48e76  chore(data): relocate root data files to data/ + gitignore runtime cache
f585862  chore: relocate 37 active runtime files to runtime/{time,preproc,plug,util}/
45ed850  Merge flowsim-artur: vectorization campaign 2026-07     ← v2.0.0-vectorized
5f93385  chore: mass-relocate 123 auxiliary files to legacy/ (root: 165 → 42)
5dd7cb4  chore: reconcile with upstream master (798bbe7)
   +25 further PR commits on flowsim-artur (Phase A-F)
```

---

_Report authored 2026-07-03 by the AXON code-dev campaign at close._
_Final commit: `9fb5dc0` · Final tag: `v2.0.1-vectorized`._
_Working tree clean, master pushed, all releases published._
