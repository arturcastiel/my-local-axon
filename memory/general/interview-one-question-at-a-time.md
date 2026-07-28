---
id: interview-one-question-at-a-time
tier: general
scope-ref: 
bindings: interview,elicitation,owner-preference
source: owner correction 2026-07-28
date: 2026-07-28
confidence: high
privacy: private
supersedes: 
---
OWNER CORRECTION (2026-07-28, interviewing for a feature spec): ask ONE question per turn, not a batch. Do the thinking BEFORE asking and PROPOSE concrete options for the owner to select from -- do not present a wall of parallel questions and do not ask open-ended questions with no proposal. Evidence: three consecutive 4-question AskUserQuestion batches were interrupted; the owner answered at most 1-2 of 4 each time and finally said 'interview question by question, think before and propose so I can select'. WHY: a 4-question grid forces the owner to context-switch across independent decisions at once, and later questions are often invalidated by the answer to an earlier one (e.g. choosing global least-squares implicitly answered the free-pillars question). HOW TO APPLY: one AskUserQuestion call = ONE question; state the reasoning/trade-off that led to the options FIRST, in prose, then offer 2-4 concrete choices with a recommendation. Re-derive the NEXT question from the answer just given. Relates to [[surface-handoffs-via-tool]] [[complete-contracted-work]].
