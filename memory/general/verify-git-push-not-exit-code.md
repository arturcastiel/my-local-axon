---
id: verify-git-push-not-exit-code
tier: general
scope-ref: 
bindings: 
source: session 2026-05-27
date: 2026-05-27
confidence: high
privacy: private
supersedes: 
---
PROCESS LESSON (2026-05-27): NEVER trust a background command exit code to confirm a git push. A backgrounded 'git add && commit && git push; echo ...' returns the echo exit (0) even when the push FAILED. That day an HTTP 408 ('remote end hung up') failed the my-axon backup push, but the exit-0 notification led to stamping myaxon-backup-status 'ok' -- false, then corrected to 'error'. HOW TO APPLY: pipe git push to a log with an explicit PUSH_RC line and READ it; only stamp backup ok on PUSH_RC=0 with no RPC/fatal errors. Large pushes (many renames) can 408 -- raise http.postBuffer + retry, or hand the push to the owner's terminal. Honesty discipline, relates to [[artifact-identity-hard-rule-commits-prs-files-ma]].
