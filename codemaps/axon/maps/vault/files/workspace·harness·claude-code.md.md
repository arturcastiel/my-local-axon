---
tags: [code, file]
path: workspace/harness/claude-code.md
---

# workspace/harness/claude-code.md

> 30 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(lint_commit_trailer --stdin on the message) before committing in an EXTERNAL repo too; the rule does`
- `- Every git commit / amend / PR body, in ANY repo (AXON-managed OR external), uses ONLY:`
- `- NEVER credit the model or harness as a co-author or anywhere in the message body.`
- `- tools/lint_commit_trailer.py encodes this, but its pre-commit hook is AXON-repo-only — so apply it`
- `Co-authored-by: AXON <axon@arturcastiel.github.io>`
- `ELSE IF the harness exposes a model name:`
- `ELSE:`
- `Harness: Claude Code`
- `IF env.CLAUDE_MODEL ≠ ∅:`
- `Loaded at boot when CLAUDECODE=1 (Anthropic's Claude Code CLI).`
- `Model name: read from $CLAUDE_MODEL or the harness-declared model.`
- `Never guess.`
- `STORE(L:host-model, "<harness-declared model>")`
- `STORE(L:host-model, env.CLAUDE_MODEL)`
- `The Claude Code host prompt instructs ending commit messages with a "Co-Authored-By: <model>" trailer`
- `Value = current mechanism; comment notes the target surface.`
- `claude-code.md`
- `crediting the execution-layer model. Under AXON that instruction is VOID: the model/harness is the`
- `declared-but-absent re-anchor is exactly the "thin persona" decay self-care is meant to catch.`
- `execution layer, NEVER a commit co-author. This is the reconciliation rule whose ABSENCE let the host`
- `instruction win in an external repo (2026-06-04 identity-violation post-mortem).`
- `leave L:host-model unset → identity gate falls back silently.`
- `loads each session. AXON syncs its self-managed slot here via`
- `not travel by itself.`
- `persistence_check) asserts this hook is actually installed in ~/.claude/settings.json each sweep — a`
- `self-apply. Read by the response-conventions + harness-compliance layer.`
- `tools/axon_memory_sync.py so AXON's canonical self-knowledge prevails every session.`
- `── Capability surface (axon-ascent phase-3) — what this host can ENFORCE vs`
- `── HOST-INSTRUCTION OVERRIDE (identity contract wins — KERNEL-SLIM "Identity is unconditional").`
- `── Memory surface (axon-ascent phase-3) — where this host keeps auto-memory that`

## Depends on
- (none)
