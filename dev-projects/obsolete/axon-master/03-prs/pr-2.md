# pr-2 — Compile audit + regression gate + static-prefix lint

**Wave**: W1 · **Goals**: G.tok.01, G.tok.02, G.tok.03, G.tok.04 · **Score**: 5.0 (T-A1) + 4.0 (T-A3) — top of executive backlog · **Depends-on**: none · **Blocks**: PR-3 and ALL recompiles

## Why (problem statement)
R2 cycle-3 measured every compiled `*.cmp.md` and found **`code-dev-pr-review.cmp.md` is bigger than its source** (23,056 vs 22,856 bytes → −1% "compression"). That single file silently erases ~30% of the shadow system's per-session savings. No gate exists today to prevent another regression: compile artifacts (priority preamble + identity locks + expanded EXEC chains) can outweigh the prose savings. This PR is **#1 and #2 on the executive top-15 backlog** (T-A1 quarantine, T-A3 gate) and must ship before any other PR that would recompile programs.

## Evidence (from studies)
- `helpers/cd-c3-p1-tokens.md` line 9 → `code-dev-pr-review.cmp.md` measured at **22,856 src → 23,056 cmp = −1%**. "zero-compression — bigger than source".
- `helpers/cd-c3-p1-tokens.md` line 23 → overall compression 34%; one file is net loss.
- `helpers/cd-c3-p1-tokens.md` line 39 → "Compile artifacts (priority preamble, identity locks, expanded EXEC chains) outweigh prose savings. This file should be either quarantined or split."
- `helpers/cd-c4-p3-improvements.md` Rank 1-2 → T-A1 (score 5.0), T-A3 (score 4.0).
- `helpers/cd-gap-c2-p1-compiled-audit.md` → calls for `study/compiled-audit.md` artifact with full numbers table per program.
- `helpers/cd-c3-p4-web-findings.md` → Anthropic prompt-caching docs: "static prefix discipline is the single largest predictor of cache hit rate".

## Design notes
- `tools/audit_compiled.py` walks `workspace/programs/compiled/*.cmp.md`, computes `{src_bytes, cmp_bytes, src_tokens, cmp_tokens, ratio_bytes, ratio_tokens, class}` for each, emits Markdown table to `study/compiled-audit.md` (in `axon-master/`) and JSONL to `my-axon/log/compile-audit/<date>.jsonl`.
- **Classification**: GREEN (ratio ≤ 0.6), YELLOW (0.6–0.85), RED (>0.85 or > src), GREY (src < 512 B — too small to measure).
- **Gate** in `tools/compile-write.py`: refuse to write when `cmp_bytes > 0.95 × src_bytes` AND `cmp_tokens > 0.95 × src_tokens`. Floor: src < 512 B skips check. Override via `--override "<reason>"` logged to `_actions.log`.
- **Two-stage flip**: ship as WARN first, run one full audit pass clean, then flip to BLOCK in `workspace/preferences/compile.toml` (`gate-mode: warn|block`).
- **Static-prefix lint**: re-compile each program twice in a row; first 2 KB must be byte-identical. Catches dynamic content (timestamps, random IDs) in the cacheable prefix.
- **Tokenizer**: pin Anthropic tokenizer (`tools/tokenizer.py`); fallback `len(text)/4` if package missing — graceful.
- **Quarantine path**: `workspace/programs/compiled/_quarantine.md` declares files temporarily off-dispatch; dispatch loader skips them.
- **First quarantine target**: `code-dev-pr-review.cmp.md` until PR-20.8 splits it into P1-P9.

## Pitfalls (from failure-mode catalog)
- **F-C1 negative compression** → this PR is the fix.
- **F-C2 static-prefix drift (cache-hostile)** → static-prefix lint catches.
- Gate too tight → `--override "<reason>"` + WARN-first flip plan + 512-byte floor.

## Interface sketch
```text
$ python3 tools/audit_compiled.py
[GREEN]  code-dev-status.cmp.md             1,420 → 480   (34%)
[YELLOW] code-dev-resume.cmp.md             5,200 → 3,900 (75%)
[RED]    code-dev-pr-review.cmp.md         22,856 → 23,056 (-1%) → quarantined
[GREY]   code-dev-tour.cmp.md                 320 → 290   (skip: src < 512 B)
Summary: 18 files · 1 RED · 4 YELLOW · 13 GREEN · 0 GREY
Wrote study/compiled-audit.md and my-axon/log/compile-audit/2026-05-17.jsonl

$ python3 tools/compile-write.py workspace/programs/code-dev-pr-respond.md
ERROR: cmp_bytes (4180) > 0.95 × src_bytes (4280). Refusing to write.
       Override: --override "<reason>" (logged).
```

## Spec (canonical)
- **Files**:
  - new: `tools/audit_compiled.py`, `workspace/programs/compiled/_quarantine.md`, `study/compiled-audit.md` (in axon-master project).
  - modified: `tools/compile-write.py`, `tools/tokenizer.py`, `tools/REGISTRY.json`, `tests/test_compiled_regression.py`, `workspace/preferences/compile.toml` (`gate-mode`).
- **Acceptance**:
  1. Audit produces full numbers table covering all compiled programs (≥ 10 files).
  2. Classified GREEN/YELLOW/RED/GREY per thresholds above.
  3. ≥ 1 RED quarantined (`code-dev-pr-review.cmp.md` confirmed).
  4. Gate enforces both `bytes_ratio ≤ 0.95` AND `tokens_ratio ≤ 0.95`.
  5. Floor: `src_bytes < 512` skips check; logged as GREY.
  6. `--override "<reason>"` logs to `_actions.log` with reason.
  7. Static-prefix lint: first 2 KB byte-stable across two consecutive compiles.
  8. Gate ships in `warn` mode; flip to `block` after one full audit pass clean.
  9. Tokenizer pinned to Anthropic, fallback `len/4` with WARN.
  10. `tools/lint_paths.py` clean.
- **Rollback**: revert `compile-write.py` (gate disappears, advisory only).
- **Owner**: AGENT writes; HUMAN runs audit + reviews quarantine list.
- **Parallelism**: blocks PR-3 (resume edit must not regress compiled size) and all recompiles.

## Codebase grounding
- **new**: `tools/audit_compiled.py` — walks [`workspace/programs/compiled/*.cmp.md`](../../../../workspace/programs/compiled/) (10 files today: code-dev, code-dev-audit, -explain, -init, -log, -plan, -pr, -pr-review, -shadow, -study), pairs each to its source in [`workspace/programs/`](../../../../workspace/programs/), runs [`tools/tokenizer.py`](../../../../tools/tokenizer.py) on both, classifies GREEN/YELLOW/RED/GREY.
- **modify**: [`tools/compile-write.py`](../../../../tools/compile-write.py) (~65 lines) — between current `ratio` calculation (line ~40) and the `with open(out_path, "w") as f:` write block, insert gate: load prior `.cmp.md` token count, compare to new; if new > prior × 1.05 (bytes or tokens) AND prior_src ≥ 512 B → BLOCK unless `--override <reason>` provided; log to `_actions.log`.
- **modify**: [`tools/tokenizer.py`](../../../../tools/tokenizer.py) — currently uses `tiktoken.get_encoding(args.encoding)` defaulting to `cl100k_base`; pin to Anthropic-aligned encoding selection by version, fallback to `len(text) // 4` if tiktoken import fails (already partially handled at line 13).
- **modify**: [`tools/REGISTRY.json`](../../../../tools/REGISTRY.json) — add `audit_compiled` entry under `tools` (mirror `tokenizer`/`compile-write` entries; ~line 15 pattern).
- **modify**: [`tests/test_compiled_regression.py`](../../../../tests/test_compiled_regression.py) — currently iterates `COMPILED_DIR.glob("*.cmp.md")`; add a parametrized test asserting ratio ≤ stored baseline + ε; baseline in `tests/compiled-baseline.json`.
- **new**: `workspace/preferences/compile.toml` — sibling to `workspace/preferences/smart-dispatch.md`; field `gate-mode = "warn" | "block"`. Read via existing pattern in [`tools/prefs.py`](../../../../tools/prefs.py).
- **new**: `workspace/programs/compiled/_quarantine.md` — header lists quarantined programs (T-A1: `code-dev-pr-review` per `helpers/cd-c3-p1-tokens.md` line 9, src 22,856 → cmp 23,056 = −1%).
- **new**: `study/compiled-audit.md` inside `my-axon/dev-projects/axon-master/study/` — full audit table.
- **static-prefix lint**: assert first 2048 bytes of each `.cmp.md` byte-identical across two consecutive compiles (no timestamp/random in prefix).

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-2.
- Helpers: `helpers/cd-c3-p1-tokens.md`, `helpers/cd-c4-p3-improvements.md` (T-A1, T-A3, top of backlog), `helpers/cd-gap-c2-p1-compiled-audit.md`, `helpers/cd-c3-p4-web-findings.md` (prompt-caching).
