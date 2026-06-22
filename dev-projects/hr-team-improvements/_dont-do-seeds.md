# Don't-do seeds — HR-Team Improvements
- [pattern] A STUB / placeholder seat response must NEVER reach a §4.3 verdict object surfaced to a user
  review: human    # the core Core-Rule-6 invariant of this project
- [scope] AXON_HR_TEAM_ALLOW_STUB is tests-only — never a production deliberation path
  match: AXON_HR_TEAM_ALLOW_STUB
- [scope] Never edit the kernel file without dev-mode + per-change owner confirm
  match: KERNEL-SLIM
- [process] No force / history-rewriting git ops in the gated flow
  match: --force
- [pattern] No fingerprint-only closure — a STRONG automated test must prove fail-open is blocked
  review: human
