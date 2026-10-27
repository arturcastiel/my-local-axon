# Changed-files registry — 1-prereqs

| File | PR | Note |
|------|----|------|
| cpg2python/cpg2unstructured/unstructured.py | 1eef539 | D1: `_fault_stack_faces` + helpers, build_topology splice, padded cell_faces, `_remap_cell_faces` |
| cpg2python/cpg2unstructured/geometry.py | 1eef539 | D4 diagonal pairing; triangle centroid; cell_geometry skips −1 |
| cpg2python/tests/test_build_topology_faulted.py | 1eef539 | closure / exact-volume / tilted / tip-triangle tests; shapes → 6+E |
| cpg2python/tests/test_{find_i,find_j}_faces_dispatch.py, test_find_faulted_i_faces.py, test_faulted_mask.py, test_unstructured.py | 1eef539 | counts include exposed pieces |
| cpg2python/tests/test_split.py, test_geometry.py | 1eef539 | padding survives split; D4 trapezoid + triangle |
| cpg2python/{pyproject.toml, cpg2unstructured/__init__.py} | 1eef539 | 0.2.0 → 0.3.0 |
| cpg2python/{CHANGELOG.md, README.md, docs/TUTORIAL.md} | 1eef539 | 0.3.0 entry, cell_faces shape, limitations |
| cpg2python/cpg2unstructured/grdecl_reader.py | 2d41127 | `_MULTI_RECORD_KEYWORDS` skipped to empty `/`; `_NO_DATA_KEYWORDS` consume nothing |
| cpg2python/tests/test_grdecl_reader.py | 2d41127 | inline FAULTS/MULTFLT, section headers, missing closing `/` |
| cpg2python/CHANGELOG.md | 2d41127 | 0.3.0 Fixed entry |
