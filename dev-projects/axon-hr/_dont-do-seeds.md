# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.
Add project-wide invariants here (e.g. 'never commit generated files').

- Never WRITE to `axon/` kernel files without `L:dev-mode ≡ true` (Core Rule 9). The
  HR-Team mode is a program/tool in `workspace/`, NOT a kernel edit — keep it there.
- Preserve the hr-team 3-layer separation (SELECTOR / CONVENER / DELIBERATOR); do not
  collapse it into a single prompt (HANDOFF.md reader contract §2).
- Preserve dissent in council output; never smooth minority positions into synthetic
  agreement (reader contract §3).
- Keep `advisory_only: true` non-overridable — it is a legal/governance invariant
  (Moffatt v. Air Canada 2024 BCCRT 149), not a UX label (reader contract §5).
- New program/tool MUST ship tests before ACTIVE registration (Core Rule 13).
- The neuron must stay callable standalone AND from workflows — do not hard-wire it
  to the menu-only entry point.
