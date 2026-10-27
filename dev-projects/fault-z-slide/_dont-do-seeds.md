# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.

- Never modify COORD in the z-slide path — only ZCORN changes. Lateral motion is the
  xy-morph's job (fault-smo-mesh-adaptation).
- Never change the fault face set — FAULTS must be byte-identical before/after a slide.
- Never rewrite a whole deck — output goes through `grdecl_writer.write_grid_include`
  (INCLUDE file), same contract as adapt_deck.
- Never put fault semantics (sides, profiles, FAULTS parsing) in cpg2python — it stays
  fault-agnostic (ZCORN ops + validity only), mirroring the existing D12 split.
- Never vendor/fork cpg2unstructured; never edit the SUPERSEDED repos
  (`/mnt/c/projects/smo-faults`, `/mnt/c/projects/faults/fault-projection`).
- Never merge spike code — spike branches are `spike/*`, marked NOT FOR MERGE.
- Never merge a z-slide PR before cpg2python D1 is fixed (round-trip would be wrong).
- Never commit `out/` or generated grid/deck/VTK/PNG artifacts.
