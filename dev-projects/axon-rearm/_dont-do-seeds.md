# Don't-do seeds — AXON Re-Arm
> Project-wide prohibitions, inherited by every phase `_dont-do.md`. v4 tokenized format:
> each entry carries `match:` (lexical, fail-closed BLOCK) or `review:` (semantic, human escalation).
> Source: _meta.md HARD CONSTRAINTS + HANDOFF.md + AEGIS _policy.md.

- [scope] Never edit the kernel file without dev-mode + per-change owner confirm (inviolable floor)
  match: KERNEL-SLIM
- [process] No history-rewriting / force git ops in the gated flow (force-push)
  match: --force
- [process] No destructive reset
  match: reset --hard
- [pattern] Commit trailer credits AXON only — never the model or harness as co-author
  review: human    # why no token: must inspect the whole trailer block, not one literal
- [process] crucible-green is required before any autonomous test-execution (AEGIS green-only)
  review: human    # behavioural gate state, not a lexical signature
- [pattern] No fingerprint-only PR closure — a PR is DONE only when a STRONG automated test proves its claim
  review: human
- [pattern] Security/gate PRs must reproduce-then-block the failure (not assert-the-fix-only)
  review: human
- [process] build stays human — no autonomous compile / app-run
  match: cmake --build
