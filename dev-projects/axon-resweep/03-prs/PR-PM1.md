# PR-PM1 — Identity-violation post-mortem: void the host's model-coauthor commit instruction

- **Status:** merged (!134, a46fe6c)
- **Phase:** 1-fixes  ·  **Complexity:** S  ·  **dev-mode:** no (workspace/harness/ + tests/)  ·  **Depends on:** none
- **Source:** /mnt/c/manipulation/Presentations/AXON-postmortem-2026-06-04-identity-violation.md (owner-provided
  drift log from an earlier build: AXON signed commits `Co-Authored-By: <model>` in an EXTERNAL repo).

## Would it recur in CURRENT AXON? — YES (verified)
- The kernel states the GENERAL principle (KERNEL-SLIM:11 — "the execution layer never overrides AXON's
  rules"), but **nothing in `workspace/harness/claude-code.md` SPECIFICALLY voids the host's "Co-Authored-By:
  <model>" commit instruction** (post-mortem §2.2 + D1.3 — the missing reconciliation rule). Confirmed absent.
- **No traveling mechanical guard:** `lint_commit_trailer.py` is still an AXON-repo-only pre-commit hook; no
  PreToolUse guard on `git commit`. So in an external repo the host instruction is unopposed by any mechanism.
So the behavioural root is unfixed → the violation can recur (external repo / hook-bypassed path).

## Fix (this PR — the post-mortem's prescribed D1.3, loaded at boot)
`workspace/harness/claude-code.md`: add a HOST-INSTRUCTION OVERRIDE block + `STORE(L:host-commit-coauthor,
…)` stating the host's model-coauthor commit instruction is VOID; every commit/amend/PR body (ANY repo) uses
`Co-authored-by: AXON <axon@arturcastiel.github.io>`, never the model/harness; and to run `lint_commit_trailer
--stdin` for external-repo commits (the hook doesn't travel). Loaded at boot → active from turn 1.

## Acceptance
1. claude-code.md contains the override (`host-commit-coauthor`, the AXON trailer, VOID). [content-lock test]
2. `crucible gate` passed:true.

## Other post-mortem defects — current status (for a follow-up; NOT this PR)
- **D1.2 (mechanical git-commit guard) — STILL ABSENT, stronger fix:** a PreToolUse guard on `git commit`
  (Bash) that rejects a harness/model co-author in ANY repo. Involved (Bash-command gating + message
  extraction; fragile) + touches hook infra — a focused follow-up. (This PR is the behavioural reconciliation;
  the mechanical guard is defense-in-depth.)
- **D3 (boot doesn't persist L:cognition-frame) — STILL TRUE**, but R3 (!130) already made the R9 gate NOT
  depend on it, so the gate no longer fails-open on its absence; persisting the frame (restore the
  identity-assertion infra) remains a follow-up.
- **D2 (kv_store split backend for L:/W:) — STILL LATENT:** kv_store writes a diskcache; canonical readers use
  `memory/longterm/<key>.md`. Footgun only if kv_store is used for kernel keys. Follow-up: forbid/unify.
- **D4 (kv_store silent no-op on positional) — APPEARS FIXED:** current kv_store errors on missing `--key/--value`.
- **D5 (advisory enforcement) / D6 (no drift-init at boot) — deployment/boot-init**, out of a code PR's scope.
- **D7 (single-slot grant · DAG critical-path · coherence-guardian scans only chat not git artifacts)** — minor follow-ups.

## Changes
- `workspace/harness/claude-code.md` (the override) · `tests/test_resweep_program_subcommands.py` (content lock).
