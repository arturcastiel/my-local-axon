---
tags: [code, file]
path: axon/compiler/templates/feedback-loop.tpl.md
---

# axon/compiler/templates/feedback-loop.tpl.md

> 23 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `EXTENSION POINTS`
- `INITIALIZATION`
- `INSTANTIATION`
- `INVARIANTS`
- `LOAD CONTEXT`
- `LOOP — plan → act → evaluate → retry`
- `PROGRAM: {goal}-loop`
- `Params:`
- `RESULT ROUTING`
- `TEMPLATE: feedback-loop`
- `actor-program     string   Program that performs the action each iteration`
- `desc:    Feedback loop for {goal} — plan/act/eval/retry pattern`
- `desc:    Plan → act → evaluate → retry loop — core harness engineering pattern`
- `eval-criteria     object   {name: "description of passing"} dict for EVAL`
- `eval-tolerance    float    Minimum score to accept output (default 0.8)`
- `feedback-loop.tpl.md`
- `goal              string   What the loop is trying to achieve`
- `max-iterations    int      Maximum retry attempts before escalating (default 3)`
- `notify-target     string   Who to notify on completion (optional)`
- `on-failure        string   Program to run when max-iterations exceeded (optional)`
- `on-success        string   Program to run when eval passes (optional)`
- `version: 1.0.0`
- `version: 1.0.0`

## Depends on
- (none)
