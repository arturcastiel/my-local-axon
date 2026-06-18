# SHADOW: /home/arturcastiel/projects/new-axon/axon/workspace/AXON-DOCS.md
source-path: /home/arturcastiel/projects/new-axon/axon/workspace/AXON-DOCS.md
shadow-created: 2026-06-18
shadow-updated: 2026-06-18
git-hash: 50c1f80
git-branch: main
git-commit: 50c1f80
git-commit-msg: chore: regenerate maintenance artifacts
caller-program: code-dev-study
caller-project: axon-paper

## Summary
Primary AXON system documentation. Generated 2026-06-18 11:21. Describes AXON as instruction-based OS for AI agents. Layer 0=LLM (execution layer), Layer 1=axon/ kernel, Layer 2=workspace/ userspace, Layer 3=addons, Layer 4=tools/. 156 ACTIVE tools. Covers architecture, memory model (W:/L:/E:), compilation pipeline, program model, boot chain, harness adapters.

## Key Structures
_(not yet analysed)_

## Dependencies
_(not yet analysed)_

## Architecture Role
_(not yet analysed)_

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-18 |  | VERIFIED: '40-70% token reduction' is stated in AXON-DOCS. ACTUAL benchmark data (benchmark.py stats): avg=30.3%, best=44%, worst=23% over 3 runs. The '40-70%' claim is OVERSTATED — real average is 30.3%. Paper must use 23-44% range or 30% average. benchmark-log (L:benchmark-log) not in longterm memory — benchmark.py has a list subcommand but only 3 entries recorded. benchmark.py benchmark.stats = {total_runs:3, avg_compression:30.3%, best:44%, worst:23%, rating:moderate}. File size reduction (bytes not tokens): code-dev-review 26%, quality-loop 28%, goal-define 28%, code-dev-knowledge-impact 24%, code-dev-plan 19%, code-dev-study 19%. Mode-detect shows 0% file reduction (possibly pre-existing compiled form). |