# Source audit link — axon-ascent

This project executes the findings of an external strategic audit. It does
NOT re-run that audit; the audit is the input.

## Linked folder
```
/home/arturcastiel/projects/axons-audit
  (UNC: \\wsl.localhost\Ubuntu\home\arturcastiel\projects\axons-audit)
```
Audit subject: AXON at `axon-development/axon` · audit date 2026-05-23
Audit verdict: "promising substrate, immature product — HEALTHY structurally ·
Good (72.6/100) usefulness · LOW integration surface · uniquely defensible kernel."

## File map of the source
```
axons-audit/
├── README.md                 ← 4 questions, TL;DR, methodology
├── HIGHLIGHTS.md             ← punch-line view
├── ASSESSMENT.md             ← honest "where it grates" + scores
├── PUBLISHING.md             ← thesis + staged launch plan
├── capabilities/{AXON-CAPABILITIES,WHAT-IS-AXON,WHAT-IS-IT-GOOD-FOR}.md
├── competitors/{AXON-COMPARE-PROGRAM,COMPETITOR-PROFILES}.md
├── comparison/{MATRIX,IS-IT-UNIQUE}.md
└── recommendations/
    ├── IMPROVEMENTS.md            ← 15 prioritized levers (the spine of this project)
    ├── FEATURES-FROM-COMPETITORS.md  ← 22 features in 3 buckets
    ├── LOW-HANGING-FRUIT.md       ← quick wins (Phase 1)
    └── MISSING-AND-HELPFUL.md     ← condensed missing/unique/common
```

## The 15 levers → phase map
| # | Lever | Effort/Impact | Phase | State 2026-05-23 |
|---|-------|---------------|-------|------------------|
| 1  | MCP client + server          | M/high | 2-integration  | OPEN |
| 2  | Fix axon-compare scoring     | S/med  | 4-eval         | OPEN (hardcoded) |
| 3  | A2A protocol on handoff      | M/high | 2-integration  | OPEN |
| 4  | Sandboxed code execution     | L/high | 3-safety-budget| PARTIAL (shell.py gate exists; no Docker) |
| 5  | Reproducible eval harness    | M/high | 4-eval         | PARTIAL (Phase-5 e2e is the seed) |
| 6  | Spend/token budget gate      | S/med  | 3-safety-budget| OPEN |
| 7  | Background/remote exec       | M/med  | 6-ecosystem    | OPEN |
| 8  | Plan-mode default code-dev   | S/med  | 3-safety-budget| OPEN (simulate exists, not default) |
| 9  | SKILL.md shim                | S/med  | 2-integration  | OPEN |
| 10 | Subagent registry (SPAWN)    | M/med  | 6-ecosystem    | OPEN |
| 11 | Browser/computer-use tool    | L/med  | 6-ecosystem    | OPEN |
| 12 | Multi-runtime TS bridge      | L/med  | — SKIP         | (use MCP server) |
| 13 | Observability dashboard      | L/med  | 1-telemetry    | OPEN (axon-state is terminal seed) |
| 14 | SWE-bench public run         | L/high | 5-benchmark    | OPEN |
| 15 | Plugin/registry ecosystem    | L/med  | 6-ecosystem    | OPEN |

## Low-hanging fruit → Phase 1 (still all un-picked as of 2026-05-23)
- B: `L:prompt-log-enabled` / `L:turn-log-enabled` → unset
- C: dispatch index → 0 entries (187 compiled, none indexed)
- D: `axon-audit` weekly cron → not added
- F: `L:auto-improve` → unset

## Moat-guard test (apply to every change)
> "Does this preserve the property that AXON behaves the same way 100 turns
> from now as it does on turn 1?"  yes → ship · no → reject (even if competitors have it).
