---
id: autonomous-loop-wired-resume-pointer
tier: general
scope-ref: 
bindings: 
source: session 2026-05-27
date: 2026-05-27
confidence: high
privacy: private
supersedes: 
---
AUTONOMOUS DEV LOOP WIRED + PROVEN (2026-05-27). Grant active on artur.castiel-tno/axon (commit/push/pr-create/merge-squash; deny kernel-edit/force-push/reset-hard/branch-delete). AEGIS _policy.md (repo-root, LOCAL/uncommitted): test-execution/merge=green-only. glab authed at ci.tno.nl/gitlab SUBPATH (api_host=ci.tno.nl/gitlab; token in glab config) -- NEVER 'glab auth login' (404s on subpath); use 'glab config set --host ci.tno.nl token <PAT>'. LOOP: branch->draft->FULL crucible gate->green->git push (SSH)->glab mr create->glab mr merge <iid> --squash. Commits REQUIRE trailer 'Co-authored-by: AXON <axon@arturcastiel.github.io>' (pre-commit hook); NEVER Claude. Merged this way: axon-viz project-graph (MR!1 edb74fda), dont-do-enforce R_DONT_DO (MR!2 91ee027). RESUME: load axon -> code-dev load axon-improvements -> masterplan STATUS BOARD; full handover in axon-improvements/RESUME.md; next = dont-do-enforce PR-0/schema/backfill. Relates to [[canonical-axon-tree-is-new-axon]] [[run-full-gate-before-push]] [[verify-git-push-not-exit-code]].
