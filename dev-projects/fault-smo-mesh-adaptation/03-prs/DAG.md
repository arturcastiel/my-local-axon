<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:fault-smo-mesh-adaptation

- schema-version: `v1`
- generated:      `2026-07-28T09:15:46Z`
- generator:      `tools/dag.py`
- nodes:          17
- edges:          23
- critical-path:  PR-000a → PR-002 → PR-004 → PR-005 → PR-007 → PR-008 → PR-015

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-000a | pr | Gate setup — cpg2python (resfo, mypy, ruff cfg, CI) | Gate setup — cpg2python (resfo, mypy, ruff cfg, CI) | pending |
| PR-000b | pr | Gate setup — fault-projections (mypy, ruff cfg, CI) | Gate setup — fault-projections (mypy, ruff cfg, CI) | pending |
| PR-001 | pr | Write CPG grid keywords to an INCLUDE deck | Write CPG grid keywords to an INCLUDE deck | pending |
| PR-002 | pr | Pillar lattice accessors and validity primitives | Pillar lattice accessors and validity primitives | pending |
| PR-003 | pr | Carry segment provenance through projection | Carry segment provenance through projection | pending |
| PR-004 | pr | morph_pillars least-squares core | morph_pillars least-squares core | pending |
| PR-005 | pr | Validity-guaranteed solve: bisection on w | Validity-guaranteed solve: bisection on w | pending |
| PR-006 | pr | targets_from_polyline (stage 1) | targets_from_polyline (stage 1) | pending |
| PR-007 | pr | Stage-1 end to end: deck in, deformed INCLUDE out | Stage-1 end to end: deck in, deformed INCLUDE out | pending |
| PR-008 | pr | Regenerate FAULTS and assert face-set invariance | Regenerate FAULTS and assert face-set invariance | pending |
| PR-009 | pr | targets_from_polygon (stage 2) | targets_from_polygon (stage 2) | pending |
| PR-010 | pr | Rim taper | Rim taper | pending |
| PR-011 | pr | Stage-2 validity: slanted-pillar fold detection | Stage-2 validity: slanted-pillar fold detection | pending |
| PR-012 | pr | Stage-2 end to end, including curved faults | Stage-2 end to end, including curved faults | pending |
| PR-013 | pr | P1: build_topology must survive welded corners | P1: build_topology must survive welded corners | pending |
| PR-014 | pr | P2: projected_topology on slanted pillars | P2: projected_topology on slanted pillars | pending |
| PR-015 | pr | Norne validation harness and benchmark | Norne validation harness and benchmark | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-000a | PR-001 | depends |
| PR-000a | PR-002 | depends |
| PR-000b | PR-003 | depends |
| PR-002 | PR-004 | depends |
| PR-004 | PR-005 | depends |
| PR-002 | PR-005 | depends |
| PR-003 | PR-006 | depends |
| PR-002 | PR-006 | depends |
| PR-001 | PR-007 | depends |
| PR-005 | PR-007 | depends |
| PR-006 | PR-007 | depends |
| PR-007 | PR-008 | depends |
| PR-006 | PR-009 | depends |
| PR-009 | PR-010 | depends |
| PR-005 | PR-011 | depends |
| PR-007 | PR-012 | depends |
| PR-009 | PR-012 | depends |
| PR-011 | PR-012 | depends |
| PR-000a | PR-013 | depends |
| PR-000a | PR-014 | depends |
| PR-008 | PR-015 | depends |
| PR-013 | PR-015 | depends |
| PR-014 | PR-015 | depends |
