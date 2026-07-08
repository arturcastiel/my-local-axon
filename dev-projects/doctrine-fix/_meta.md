slug:            doctrine-fix
schema-version:  v4
status:          active
phase:           study
workflow-step:   code-dev-study
branch:          (none)
codebase:        (none)

## Working Context
Remediation of the 21 audit findings against axon-next (the Autonomy Doctrine, @77eb1a5).
Source of truth for the defects: my-axon/dev-projects/axon-next/05-audit.md (4-seat
adversarial council + AXON Step-0 re-verify). Owner chose the FULL bugfix project
(2026-07-08) over hotfix-only.

Goal: make the doctrine's security guarantees TRUE — every one currently oversold gets
either wired-and-proven or its claim narrowed to what the code actually delivers. No new
absolute ships without a test that exercises the REAL production path (no monkeypatched
enforcement, no grantless fixtures, no grep-only "coverage").

Standing constraint from the audit root-causes:
- enforcement must be WIRED to a real trigger, not just implemented;
- guarantees must be tested with enforcement engaging for real (real _resolve_myaxon,
  real run_active), never pre-faked;
- no claim in a commit/doc/comment that the code does not deliver.
