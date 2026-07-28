# ADR-002 — dead-key gate + parser consolidation (PR-006) + graph (PR-007) deferred, with evidence
date: 2026-07-13 · status: accepted (evidence-driven, autonomous)

## Context — measured on the live tree via the canonical extractor (PR-004)
- dead-EXEC (dangling EXEC(program)): after hardening axonlang to skip comments + render-string
  examples, = **0**. A clean, real gate → SHIPPED (PR-005, axonlang-exec BLOCK control).
- dead-key (written-never-read): **79 candidates even with W:_* + template exemptions** — DOMINATED
  by FALSE POSITIVES because the markdown extractor does NOT see reads via `ASSERT(L:key)` or by
  Python tools. Proven: L:cognition-frame shows as "written-never-read" yet is read by ASSERT in
  autonomy-contract.md:31, code-dev-combine.md:31, and 8× in KERNEL-SLIM. A written-never-read gate
  over markdown RETRIEVE alone would false-block the OS's most critical keys.

## Decision
1. dead-KEY gate DEFERRED. It needs cross-layer READ awareness (ASSERT(scope:key) parsing + Python
   read-sites) before it can gate without a false-positive flood. The canonical extractor already
   holds the WRITE side; the READ side is the genuine remaining work. This is the deeper form of the
   markdown-blindness the whole project studied — and it's a real follow-up, not a shiny graph.
2. PR-006 (migrate the 6-17 legacy parsers onto axonlang) DEFERRED. The alternative seat's own flip-risk
   (conf 68): axonlang is BETTER than the legacy parsers (multi-line, code-span-stripped, W|L|E), so a
   migration is behavior-IMPROVING, not behavior-preserving — it changes what each lint reports. That is a
   careful, incremental, per-consumer refactor (each with a re-baseline), not a rushed same-session merge.
   axonlang stands as the canonical PRODUCER; consumers migrate onto it deliberately.
3. PR-007 (graph emission) stays DECISION-GATED and is DEFERRED: the residual gap (dead-key) is a
   READ-EXTRACTION gap, not a transitive/multi-hop reachability gap — so it argues for completing the
   reader side, NOT building a graph. The graph is only warranted if a future finding is genuinely
   multi-hop. Not yet.

## What shipped (the goal, delivered)
The goal was "make AXON's self-analysis see its own AXON-LANG layer — gating lints first." DELIVERED:
tools/axonlang.py is the canonical extractor (98-100% coverage, full W|L|E alphabet, the E: scope
memory_key_lint misses), and axonlang-exec is a real BLOCK gate over it. AXON now sees + gates its own
program→program EXEC topology — the first time the neuron layer is a first-class gated citizen.

## Follow-ups (run 5 candidates)
dead-key via ASSERT+Python read extraction · PR-006 incremental parser consolidation · PR-007 graph IF a
multi-hop finding appears.
