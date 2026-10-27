# Phase prohibitions — 0-spike

_(seeded from _dont-do-seeds.md on phase start)_

- Never modify COORD in the z-slide path — only ZCORN changes.
- Never change the fault face set — FAULTS must be byte-identical before/after a slide.
- Never rewrite a whole deck — output goes through `grdecl_writer.write_grid_include`.
- Never put fault semantics in cpg2python — it stays fault-agnostic.
- Never vendor/fork cpg2unstructured; never edit the SUPERSEDED repos.
- Never merge spike code — spike branches are `spike/*`, marked NOT FOR MERGE.
- Never merge a z-slide PR before cpg2python D1 is fixed.
- Never commit `out/` or generated grid/deck/VTK/PNG artifacts.
