# SHADOW: /home/arturcastiel/projects/new-axon/axon/tools/graphify_bridge.py
source-path: /home/arturcastiel/projects/new-axon/axon/tools/graphify_bridge.py
shadow-created: 2026-06-11
shadow-updated: 2026-06-11
git-hash: 8acc742e4c33adb1f08990d01caef6a7ab9d1365
git-branch: main
git-commit: 06c49f8
git-commit-msg: Merge branch 'general-bugfix/docs-closeout' into 'main'
caller-program: code-dev-study
caller-project: graphify-obsidian

## Summary
OPTIONAL bridge to external Graphify tool for multi-language code-dev TARGET repos. Subcommands: check (never raises), build (graphify update, degrades if absent), affected (reverse blast-radius over graph.json — works WITHOUT graphify), semantic (P3 LLM overlay — inert, AEGIS web-grant-gated, advisory-only).

## Key Structures
available(), check(), build(repo,out), affected(graph,symbol,depth,min_confidence), semantic(repo,out,policy), _aegis_web_granted(policy), _load(), _build_parser(), main(). CONFIDENCE_TAGS={EXTRACTED,INFERRED,AMBIGUOUS}.

## Dependencies
stdlib only (argparse/json/shutil/subprocess/importlib). Runtime-optional: graphify CLI/module (pin graphifyy>=0.8.36,<0.9.0 as extra). Calls tools/aegis_policy.py via subprocess for the web grant.

## Architecture Role
The multi-language half of the graphify-obsidian hybrid. NEVER on an AXON gate; fail-degrade contract: absent => {ok:false, degraded:true} and callers (code-dev-knowledge-impact) fall back to stdlib code_symbols.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-11 |  | Reads typed links confidence (NOT lossy MCP text). graph key is 'links' with 'edges' fallback (sec-19 gotcha). Exit code of graphify can lie — stdout marker 'graph.json' checked instead. Node match: id, label (stripped parens), or id suffix after colon. AMBIGUOUS never auto-followed. Graphify IS installed on this machine (cli+module) as of 2026-06-11. |