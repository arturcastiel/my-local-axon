# Data-structure redesign for vectorization

## Goal
Replace the ~40 mesh/config globals (`bedge, inedge, coord, elem, centelem,
esurn1/2, nsurn1/2, normals, elemarea, numcase, bcflag, ...`) with a single
`FS` struct passed explicitly. Add derived, vectorization-friendly layouts
computed **once per mesh** and reused by every solver call.

## Top-level struct

```matlab
FS = struct( ...
    'mesh',    [],  ...  % raw connectivity (from gmsh) — INVARIANT per mesh
    'geom',    [],  ...  % derived geometry (centroids, normals, areas) — INVARIANT
    'csr',     [],  ...  % CSR / padded neighbour layouts — INVARIANT (KEY for vect)
    'perm',    [],  ...  % permeability tensor (may vary per solver call in Richards)
    'bc',      [],  ...  % boundary conditions (nflag, nflagface, bcflag)
    'cfg',     [],  ...  % config: numcase, phasekey, method, pmethod, ...
    'state',   [],  ...  % current solution: p, h, Sw, Con
    'workspace', []  );  % scratch buffers (preallocated, resized on demand)
```

Each field is itself a struct — see below.

## FS.mesh  (raw topology — set once per mesh load)

```matlab
FS.mesh = struct( ...
    'nNodes',   n_v,    ...   % scalar
    'nElems',   n_e,    ...   % scalar
    'nBFaces',  n_bf,   ...   % scalar (boundary faces)
    'nIFaces',  n_if,   ...   % scalar (interior faces)
    ...
    'coord',    coord,  ...   % [nNodes x 3]  (col 3 = z, may be zeros for 2D)
    'elem',     elem,   ...   % [nElems x 5]  (cols 1-4 = vertex ids; tri: col 4 = 0)
                        ...   %                col 5 = material id
    'bedge',    bedge,  ...   % [nBFaces x 5] (n1, n2, elem, ?, bcFlag)
    'inedge',   inedge, ...   % [nIFaces x 6] (n1, n2, elemLeft, elemRight, ?, ?)
    ...
    'nsurn1',   nsurn1, ...   % CSR: neighbour-node flat list
    'nsurn2',   nsurn2, ...   % CSR: row-pointer (length nNodes+1)
    'esurn1',   esurn1, ...   % CSR: elements-surrounding-node flat list
    'esurn2',   esurn2  );    % CSR: row-pointer (length nNodes+1)
```

## FS.geom  (derived, INVARIANT per mesh — compute ONCE via +fs.mesh.build)

```matlab
FS.geom = struct( ...
    'centElem',    centElem,    ...  % [nElems x 3]   element centroids (batched)
    'elemArea',    elemArea,    ...  % [nElems x 1]
    'nvert',       nvert,       ...  % [nElems x 1]   vertices per elem (3 or 4)
    ...
    'faceMidBnd',  faceMidBnd,  ...  % [nBFaces x 3]  boundary-face midpoints
    'faceMidInt',  faceMidInt,  ...  % [nIFaces x 3]  interior-face midpoints
    'faceLenBnd',  faceLenBnd,  ...  % [nBFaces x 1]  face lengths (2D) / areas (3D)
    'faceLenInt',  faceLenInt,  ...  % [nIFaces x 1]
    'normalBnd',   normalBnd,   ...  % [nBFaces x 3]  outward face normals
    'normalInt',   normalInt   );    % [nIFaces x 3]  from left to right elem
```

## FS.csr  (the KEY vectorization enabler)

Node-to-corner ragged layout, flattened:

```matlab
FS.csr = struct( ...
    ...  % Corner = (node, incident-element) pair. Total across mesh: nCorners.
    'nCorners',    nCorners,    ...  % scalar = sum_i esurn2(i+1)-esurn2(i)
    'cornerNode',  cornerNode,  ...  % [nCorners x 1]  which node this corner belongs to
    'cornerElem',  cornerElem,  ...  % [nCorners x 1]  which element
    'cornerPos',   cornerPos,   ...  % [nCorners x 1]  position of node in that elem (1..4)
    'cornerNext',  cornerNext,  ...  % [nCorners x 1]  index of the "k+1" corner of same node
    'cornerPrev',  cornerPrev,  ...  % [nCorners x 1]  index of the "k-1" corner
    'nodePtr',     nodePtr,     ...  % [nNodes+1 x 1]  = FS.mesh.esurn2 (alias for clarity)
    'nodeNec',     nodeNec,     ...  % [nNodes x 1]    corners per node (esurn2 diff)
    'maxNec',      maxNec,      ...  % scalar = max(nodeNec)
    ...
    ...  % Padded view — used by pure-arithmetic kernels
    'padCornerIdx', padCornerIdx,... % [nNodes x maxNec] with 0 sentinel for pad slots
    'padMask',      padMask     );   % [nNodes x maxNec] logical, true where corner exists
```

**Key insight** — with this layout, the entire LPEW2 pipeline becomes:

```matlab
% Gather all corners' geometry in bulk:
Oflat = FS.geom.centElem(FS.csr.cornerElem, :);        % [nCorners x 3]
% Node coord for each corner:
Qflat = FS.mesh.coord(FS.csr.cornerNode, :);           % [nCorners x 3]
% Neighbour node coords via nsurn CSR:
Pflat = FS.mesh.coord(FS.csr.cornerP, :);              % [nCorners x 3]
% Midpoints:
Tflat = 0.5 * (Pflat + Qflat);                          % [nCorners x 3]

% Angles — all corners in one shot:
angles = fs.lpew.v2.angulos(Oflat, Pflat, Tflat, Qflat, FS.csr);
% Tensor projections:
K = fs.lpew.v2.ksInterp(Oflat, Tflat, Qflat, FS.perm.tensor(FS.csr.cornerElem,:), FS.csr);
% Etas, zetas, lambdas — all fully flat:
[lambdaFlat, rFlat] = fs.lpew.v2.lambdaWeights(K, angles, netas, FS.csr);
% Segmented normalisation:
lambdaSum = accumarray(FS.csr.cornerNode, lambdaFlat);        % [nNodes x 1]
weightFlat = lambdaFlat ./ lambdaSum(FS.csr.cornerNode);      % [nCorners x 1]

% weightFlat is now the ordered nodal weight vector — same layout as legacy `weight`
```

**The per-node `for y = 1:nNodes` loop is gone.**

## FS.perm

```matlab
FS.perm = struct( ...
    'tensor',   tensor,   ...  % [nElems x 4]  = [K11 K12 K21 K22] per element
    'kmap',     kmap,     ...  % [nElems x nComp]  raw kmap (legacy shape)
    'auxperm',  auxperm,  ...  % Richards: kmap * kr(h) at current iter
    'material', matId     );   % [nElems x 1]  material id (= FS.mesh.elem(:,5))
```

## FS.bc

```matlab
FS.bc = struct( ...
    'nflag',      nflag,      ...  % [nNodes  x 2] node BC (col 1: flag, col 2: value)
    'nflagFace',  nflagFace,  ...  % [nFaces  x 2] face BC
    'bcflag',     bcflag,     ...  % [nBcTypes x 2] flag → value map
    'bcflagc',    bcflagc,    ...  % concentration BC map
    'wells',      wells       );   % well descriptors
```

## FS.cfg

```matlab
FS.cfg = struct( ...
    'numcase',      numcase,      ...  % scalar
    'phasekey',     phasekey,     ...  % scalar (1=single, 2=two-phase, 6=Richards)
    'pmethod',      pmethod,      ...  % 'mpfad' | 'mpfah' | 'nlfvpp' | ...
    'smethod',      smethod,      ...  % saturation method
    'keygravity',   keygravity,   ...  % 'y' | 'n'
    'visc',         visc,         ...  % viscosity(ies)
    'dens',         dens,         ...  % density(ies)
    'order',        order,        ...  % time-integration order
    'timelevel',    timelevel,    ...  % current time
    'totaltime',    totaltime,    ...  % end time
    'courant',      courant,      ...  % CFL number
    'filepath',     filepath,     ...  % output path
    'resfolder',    resfolder,    ...  % results subfolder
    'satlimit',     satlimit      );
```

## FS.state

```matlab
FS.state = struct( ...
    'p',       p,       ...  % [nElems x 1]  pressure
    'h',       h,       ...  % [nElems x 1]  hydraulic head (Richards)
    'h_old',   h_old,   ...  % previous Picard iterate
    'Sw',      Sw,      ...  % [nElems x 1]  water saturation
    'Con',     Con,     ...  % [nElems x 1]  concentration
    'iter',    iter,    ...  % current iteration
    'time',    time     );   % current time
```

## FS.workspace  (preallocated scratch — resized only when nElems changes)

```matlab
FS.workspace = struct( ...
    'rows',    zeros(0,1), ...  % triplet accumulator for sparse(M)
    'cols',    zeros(0,1), ...
    'vals',    zeros(0,1), ...
    'rhs',     zeros(0,1), ...  % RHS vector scratch
    'lambdaFlat', zeros(0,1) ... % LPEW scratch
    );
```

## Migration policy

- **Every new (`+fs.*`) function takes `FS` as first argument.**
- **Legacy `ferncodes_*` shims** unwrap `FS` into old globals at entry, call the
  legacy function, wrap results back. This lets the migration proceed one
  function at a time with the oracle running old-and-new side by side.
- **Once a legacy function has a vectorized twin passing the oracle**, its
  shim is deleted and call sites switch to `+fs.<mod>.<func>`.

## Invariants (asserted by `+fs.util.assertFS(FS)`)

1. `numel(FS.csr.nodePtr) == FS.mesh.nNodes + 1`
2. `FS.csr.nCorners == FS.csr.nodePtr(end) - 1`
3. `all(FS.csr.cornerNode == repelem(1:FS.mesh.nNodes, FS.csr.nodeNec))`
4. `size(FS.geom.centElem, 1) == FS.mesh.nElems`
5. `size(FS.perm.tensor, 1) == FS.mesh.nElems`
