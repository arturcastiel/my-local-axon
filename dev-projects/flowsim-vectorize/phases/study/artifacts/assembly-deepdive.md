# Assembly deep-dive — per-file map + cross-cutting notes

_Compiled from parallel deep-read pass on 2026-07-03. Source: 17 files, ~2500 lines total._

## Per-file map

### ferncodes_assemblematrixMPFAH.m  (820 L — the giant)
- **Sig:** `function [M,I,elembedge]=ferncodes_assemblematrixMPFAH(parameter,nflagface,weightDMP,SS,dt,h,MM,gravrate,viscosity)`
- **Globals:** bcflag, bedge, coord, elem, inedge, methodhydro, numcase (+ implicit access via callees)
- **Outer loops:** `for ifacont=1:bedgesize` @L21 · `for iface=1:inedgesize` @L83 · `for iw=1:size(elembedge,1)` @L815
- **Fill pattern:** `M(i,j)=M(i,j)+...` direct sparse writes (worst case for MATLAB perf — every write triggers reallocation)
- **Branches:** `numcase` dispatch (200<x<300 = contaminant, 30<x<200 = two-phase, 341 special, 245/246/247/248/249/251 special, `methodhydro` variants, `modflowcompared` gate)
- **Calls:** ferncodes_K, ferncodes_implicitandcranknicolson, ferncodes_tratmentcontourlfvHP
- **Math role:** hybrid MPFA pressure matrix + edge couplings
- **Vectorization plan:** (a) preallocate rows/cols/vals triplet buffers sized by max fill; (b) per-face compute contribution vectors in bulk over `bedge`/`inedge`; (c) `sparse(rows, cols, vals, nE, nE)` once at the end (MATLAB coalesces duplicates); (d) hoist `numcase`-dependent scalars out of the loop
- **Risk:** fp order matters in accumulation → validate via Frobenius diff at 1e-12 rel; boundary special-cases likely non-commutative

### ferncodes_globalmatrix_MPFAD.m  (295 L)
- **Sig:** `function [M,I,elembedge] = ferncodes_globalmatrix_MPFAD(env, parms)`
- **Globals:** NONE — already migrated to env-style
- **Outer loops:** `for k=edges1.'` @L209 · `for k=edges2.'` @L241 (two edge-set sweeps)
- **Fill pattern:** likely triplet-based already
- **Branches:** `isConc && is2phase`, `isSat`, `idxFacesHasBC*`, `auxmodflowcompared`
- **Calls:** none intra-file
- **Math role:** MPFA-D global matrix + edge connectivity
- **Vectorization plan:** the two edge sweeps can collapse to one masked kernel; already the cleanest starting point — port other assemblers TO this style

### ferncodes_assemblematrixMPFAQL.m  (199 L)
- **Sig:** `function [M,I]=ferncodes_assemblematrixMPFAQL(parameter,w,s,nflag,weightDMP,mobility)`
- **Globals:** bcflag, bedge, coord, elem, esurn1, esurn2, inedge, phasekey
- **Outer loops:** `for ifacont=1:bedgesize` @L14 · `for iface=1:inedgesize` @L62
- **Inner loops:** 4 local neighbour loops (`j` spans over `esurn2` ranges) — CSR ideal
- **Fill:** direct writes
- **Branches:** `bedge(:,5)>200` · `nflag<200` / `==202` · interior vs boundary
- **Vectorization plan:** replace adjacency spans with vectorized neighbour gather (`FS.mesh.esurn1(esurn2(No)+1:esurn2(No+1))` becomes flat + `accumarray`); emit triplets; mask boundary
- **Risk:** DMP stabilization depends on face-weight accumulation order

### ferncodes_assemblematrixNLFVH.m  (107 L)
- **Sig:** `function [M,I]=ferncodes_assemblematrixNLFVH(pinterp,parameter,viscosity)`
- **Globals:** bcflag, bedge, coord, elem, inedge, numcase, phasekey
- **Outer loops:** `for ifacont=1:bedgesize` @L12 · `for iface=1:inedgesize` @L57
- **Fill:** direct writes
- **Branches:** numcase dispatch (200<x<300, x<200, 245/246/247/...) + boundary flag
- **Math role:** nonlinear FV H-scheme
- **Vectorization plan:** two-pass masked kernel (boundary / interior); precompute face geom once
- **Risk:** pressure-dependent coefficients may need consistent update order (nonlinear iter)

### ferncodes_assemblematrixNLFVPP.m  (174 L)
- **Sig:** `function [M,I]=ferncodes_assemblematrixNLFVPP(pinterp,parameter,viscosity,...)`
- **Globals:** bcflag, bedge, coord, elem, inedge, keygravity, numcase
- **Outer loops:** `for ifacont=1:bedgesize` @L18 · `for iface=1:inedgesize` @L79 · `for iw=1:size(elembedge,1)` @L165
- **Fill:** direct writes
- **Branches:** numcase, modflowcompared, `keygravity=='y'`, boundary
- **Vectorization plan:** split gravity-on/off paths (different algebra); adjacency-span → gather; triplets
- **Risk:** gravity branch changes algebra — do not fuse

### ferncodes_assemblematrixDMP.m  (220 L)
- **Sig:** `function [M,I]=ferncodes_assemblematrixDMP(p,pinterp,gamma,parameter,weightDMP,mobility,graviterm)`
- **Globals:** bcflag, bedge, coord, elem, inedge, phasekey
- **Outer loops:** `for ifacont=1:size(bedge,1)` @L8 · `for iface=1:size(inedge,1)` @L53
- **Fill:** direct + helper appends
- **Branches:** phasekey==1, `bedge(:,5)>200`, sign/zero tests (F1/F2), geometric orientation
- **Calls:** ferncodes_calfluxopartialDMP + 3 DMP helpers (interior1/interior2/contour)
- **Vectorization plan:** precompute flux-sign masks; batch triplets from helpers; separate interior vs contour kernels
- **Risk:** sign / zero-crossing logic numerically delicate — do NOT reorder fp comparisons

### ferncodes_auxassemblematrixinteriorDMP1.m + DMP2.m + contourDMP.m
- **Role:** scalar per-face helpers that append into `M`/`I` inline
- **Vectorization plan:** batch across all interior/contour faces; return triplet vectors; call site does one `sparse(...)`
- **Risk:** side-selection (`auxlef==ielem` vs right) → mask matrix by ownership; asymmetric weights (`mu1/mu2`, `weight1/weight2`) easy to swap

### ferncodes_flowratelfvMPFAQL.m  (+ _con.m variant)
- **Sig:** `function [flowrate,flowresult]=ferncodes_flowratelfvMPFAQL(parameter,weightDMP,mobility,pinterp,p)`
- **Globals:** bcflag/bcflagc, bedge, centelem, coord, inedge, phasekey
- **Outer loops:** `for ifacont` + `for iface`
- **Vectorization plan:** left/right face gather + one-pass compute; mask boundary; concentration variant uses `bedge(:,7)` instead of `(:,5)`
- **Risk:** flux sign convention must stay consistent with normal orientation

### ferncodes_coefficientmpfaH.m + ferncodes_elementfacempfaH.m
- **Role:** MPFA-H preprocessing (transmissibility coeffs + element-face incidence)
- **Loops:** many local geometry passes
- **Vectorization plan:** precompute all face-local vectors + dot-products in arrays; masks for tolerance checks; batched boundary/interior passes; adjacency table via CSR instead of per-element loop
- **Risk:** normalisation singularities (`norm≈0`, clipped cosines) — preserve tolerance behaviour

### ferncodes_solverpressureMPFAH.m + MPFAQL.m (wrappers)
- **Globals:** none
- **Loops:** none
- **Role:** orchestrate assembly + solve + postprocess
- **Vectorization plan:** NO rewrite needed — keep API stable, delegate to vectorized kernels

### ferncodes_pressureinterpMPFAQL.m
- **Loops:** `for no=1:size(coord,1)` @L6 with 2 stencil loops per node
- **Vectorization plan:** per-node stencils via CSR (`esurn1/esurn2`); mask flagged vs regular nodes

### ferncodes_pressureinterpNLFVPP.m + HP.m
- **Vectorization plan:** process all nodes/faces in bulk from `env.geometry`; split `numcase` branch once, not per node/face; mask boundary classes
- **Risk:** denominator guard `abs(sum)<1e-5` — preserve exactly

## Cross-cutting facts

### Globals union across the 17 assembly files
| Global | Files using |
|---|---|
| bedge | 13 |
| inedge | 13 |
| coord | 11 |
| bcflag | 7 |
| elem | 7 |
| phasekey | 4 |
| numcase | 4 |
| centelem | 3 |
| esurn1 | 2 |
| esurn2 | 2 |
| bcflagc | 2 |
| keygravity | 1 |
| methodhydro | 1 |

→ **These 13 globals are the migration target for `FS.mesh` / `FS.cfg` / `FS.bc`.**

### Common access patterns
- `bedge(:,5)` — main boundary/material flag (pressure paths)
- `bedge(:,7)` — concentration boundary flag (`_con` variants)
- `inedge(:,3:4)` — left/right adjacent elements (the workhorse for face-based vectorization)
- `esurn1/esurn2` — CSR offsets for per-node/per-face stencils
- `centelem` / `coord` / `elem` — geometry driver for face geometry

### Shared helpers (>1 caller)
- `ferncodes_implicitandcranknicolson` (2)
- `ferncodes_pressureinterpHP` (2), `ferncodes_pressureinterpMPFAQL` (2)
- `ferncodes_flowratelfvMPFAQL` (2)
- DMP helpers (interior1/interior2/contour) each (2)

## Assembly triplet recipe (universal)

```matlab
% Estimate max fill: bedge contributes up to 2 entries/face; inedge up to 4.
nnz_est = 2 * FS.mesh.nBFaces + 4 * FS.mesh.nIFaces;
rows = zeros(nnz_est, 1);
cols = zeros(nnz_est, 1);
vals = zeros(nnz_est, 1);
rhs  = zeros(FS.mesh.nElems, 1);
ptr  = 0;

% --- Interior faces: batched contribution ---
Lelem = FS.mesh.inedge(:,3);           % [nIFaces x 1]
Relem = FS.mesh.inedge(:,4);
[coefLL, coefLR, coefRL, coefRR, rhsL, rhsR] = ...
    fs.assembly.mpfah.faceCoeffs(FS, parameter, weightDMP, viscosity);

k = numel(Lelem);
rows(ptr+1:ptr+4*k) = [Lelem; Lelem; Relem; Relem];
cols(ptr+1:ptr+4*k) = [Lelem; Relem; Lelem; Relem];
vals(ptr+1:ptr+4*k) = [coefLL; coefLR; coefRL; coefRR];
ptr = ptr + 4*k;

rhs = rhs + accumarray(Lelem, rhsL, [FS.mesh.nElems 1]);
rhs = rhs + accumarray(Relem, rhsR, [FS.mesh.nElems 1]);

% --- Boundary faces: same idea, only left-element diagonals + RHS ---
Belem = FS.mesh.bedge(:,3);
[coefBB, rhsB] = fs.assembly.mpfah.boundaryCoeffs(FS, parameter, nflagface);
k = numel(Belem);
rows(ptr+1:ptr+k) = Belem;
cols(ptr+1:ptr+k) = Belem;
vals(ptr+1:ptr+k) = coefBB;
ptr = ptr + k;
rhs = rhs + accumarray(Belem, rhsB, [FS.mesh.nElems 1]);

% --- Assemble once ---
M = sparse(rows(1:ptr), cols(1:ptr), vals(1:ptr), FS.mesh.nElems, FS.mesh.nElems);
I = rhs;
```

This pattern applies to MPFAH, MPFAD, MPFAQL, NLFVH, NLFVPP, DMP — the differences live only inside `faceCoeffs` and `boundaryCoeffs`.
