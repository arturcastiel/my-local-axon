# SHADOW: /home/arturcastiel/projects/new-axon/axon/tools/code_symbols.py
source-path: /home/arturcastiel/projects/new-axon/axon/tools/code_symbols.py
shadow-created: 2026-06-11
shadow-updated: 2026-06-11
git-hash: 22efee865563f25de4313937f058bd22342e7afa
git-branch: main
git-commit: 06c49f8
git-commit-msg: Merge branch 'general-bugfix/docs-closeout' into 'main'
caller-program: code-dev-study
caller-project: graphify-obsidian

## Summary
Deterministic exported-symbol extraction from a single source file. Python via ast (confidence EXTRACTED, honors literal __all__); C/C++/JS/TS/Go/Rust/Java via conservative regex (INFERRED). Never raises.

## Key Structures
extract(path) -> {file,lang,confidence,exported}; _python_symbols(), _regex_symbols(); language ext sets _PY/_C_FAMILY/_JS_FAMILY/_GO/_RUST/_JAVA; CLI: exports --file.

## Dependencies
Pure stdlib (argparse/ast/json/re/pathlib). No writes, no network.

## Architecture Role
Symbol foundation of the integration; feeds code-dev-knowledge-impact caller/blast-radius (fixed the empty symbols.exported => \b()\b fake-caller bug, FAILURE-MODES D4). Same EXTRACTED/INFERRED provenance ladder as R6.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-11 |  | Precision-over-recall by design for regex languages; keyword denylist strips control-flow tokens that slip the C func regex. Unknown extensions => empty exported list with confidence null (callers must guard). |