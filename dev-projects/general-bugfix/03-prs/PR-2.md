# PR-2 — conversational subsystem repoint [crit C3,C4,C5]

Status: merged — COMPLETE (2a !165 · kernel half + mode-wiring + BLOCK promotion merged via owner script; lint-path-vars BLOCK, 0 violations)
Branch: general-bugfix/pr-2a-conversational-workspace → main
Depends-on: PR-0a (merged !159)
Phase: 3-prs
Covers: C3 (dead ws-* keys), C4 (mode-router false comments), C5 (menu modes [1]–[5])

## Split (kernel floor forces it)
The 25 undefined path-var refs split 12 workspace / 13 kernel (`axon/programs/
{new-chat,plan-*,mode-*,list-chats,chat-folder,switch-chat,_chat-checkpoint}`).
Kernel files are human-only → same owner-script pattern as the mirror-kill patch.

## 2a — workspace half (this branch, autonomous)
- 5 library roots: `W:ws-libraries → W:myaxon-libraries`, silent `| "workspace/libraries/"`
  fallback replaced with a LOUD ASSERT/FAIL (boot my-axon or my-axon-init).
- `W:ws-name → W:myaxon-name` (autonomy-reanchor ×2, handoff, resume, stats — display/label
  uses keep their safe fallbacks).
- `W:ws-path` eliminated: igap-improve uses the git-root shell fallback it already had;
  workflow-run/-new state files use the relative `workspace/memory/working/` convention
  (also heals the 2 refs the PR-1 edits had introduced — caught by our own lint).
- menu.md C5 repair: `mode-hints` dict header + chat entry restored (was orphaned onto the
  resumable block); mode menu rows **[1] CHAT – [5] SYSTEM** restored before the dangling ELSE.
- Workspace lint-path-vars violations: 12 → 0.

## 2b — kernel half (owner script, to generate)
- Repoint the 13 kernel refs (`ws-chats→myaxon-chats` ×6, `ws-plans→myaxon-plans` ×6,
  `ws-episodic→myaxon-episodic` ×1) with the same loud-guard pattern.
- mode-router: delete the false "not wired yet" comments; wire `new-chat` + `plan-new`.
- plan `completed` token fix (plan-done).

## 2c — promotion (autonomous, after 2b)
- lint-path-vars crucible control WARN → BLOCK (requires 0 total violations).

## Guarded-by
- `lint-path-vars` (BLOCK at 2c) · program contract tests · full gate per sub-PR.
