# PR-G3 — Contract integrity: bound the `_policy.md` Notes slurp

- **Status:** spec
- **Phase:** 3-reaudit-fixes
- **Complexity:** S
- **Depends on:** none
- **Why:** Re-audit R5 (LOW, integrity — no privilege flip since `aegis_policy.load_policy` reads the first
  `## capabilities` block): `_preserve_and_backup` (PR-F5) has two content-capture bugs. (a) An
  `# Owner directive` line living INSIDE the `## Notes` block is captured twice — once by the directive
  scan over all lines, once by the Notes-to-EOF slurp → duplicated in the rewritten `_policy.md`. (b) When
  `## Notes` is authored ABOVE `## capabilities`, the Notes-to-EOF slurp carries the stale `## capabilities`
  block across → the file ends with two capabilities blocks (contradictory, misleads a human auditor).

## Mechanism
- Compute the `## Notes` span as `[notes heading .. next top-level "## " heading or EOF)` and slurp only
  that span — so it never swallows a following `## capabilities` block (R5b).
- Capture `# Owner directive` provenance lines only OUTSIDE the Notes span (R5a — a directive nested in
  Notes is already carried by the Notes slurp).

## Acceptance criteria
1. An owner-directive nested in `## Notes` appears exactly once after a re-write (R5a).
2. `## Notes` above `## capabilities` → the rewritten file has exactly one `## capabilities` block (the
   freshly-rendered one); the note body is preserved; the stale caps are dropped (R5b).
3. The F5 happy path (directive + Notes below capabilities) still preserves both + backs up.
4. `crucible gate` passed:true on this on-workflow changeset.

## Changes Required
### tools/autonomy_contract.py
- `_preserve_and_backup`: bound the Notes slurp to the next `## ` heading; exclude in-Notes lines from the
  owner-directive capture.
### tests/test_autonomy_contract.py
- R5a (nested directive not duplicated) + R5b (Notes-above-capabilities, single caps block).

## Test plan
Targeted contract tests + full suite + gate (parse passed SEPARATELY). No dev-mode.
