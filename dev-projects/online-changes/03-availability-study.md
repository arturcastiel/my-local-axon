# 03 — Wide-availability study: RAG retrieval-eval machinery

> 6-axis grounded study (in-process API, CLI/discoverability, MCP, cross-harness, packaging, governance) + synthesis.
> Question: how to make the retrieval-eval / rag-maturity machinery *widely available* — reachable from everywhere, safely.

## Thesis

The retrieval-eval machinery is already runnable but invisible and unreachable off the shell path. The single highest-leverage move is the MCP allowlist: tools/mcp_server.py's SAFE_TOOLS / READONLY_SUBCOMMANDS / _FORBIDDEN_FLAG_TOKENS gate is the one chokepoint that, with ~5 verified line-edits, exposes both read-only query tools to EVERY MCP client at once (Claude Desktop, non-shell Copilot, external agents) with no new code, no model dependency, and no per-harness wiring. Everything else (menu/list-tools discoverability, the in-process import shim, a standalone pip package) is lower-reach polish that hangs off that same conservative read-only-by-default contract — and the contract is only honest if the write flag (--append-log) is forbidden in the SAME commit that grants exposure.

**Canonical surface:** tools/mcp_server.py's allowlist triad — SAFE_TOOLS (which names are exposed) + READONLY_SUBCOMMANDS (which positional is legal) + _FORBIDDEN_FLAG_TOKENS (which flags are refused pre-subprocess by _is_readonly_call). This is the host-independent exposure point: a name added here is reachable identically by every MCP client, and liveness.py already regexes this file as the canonical MCP invocation surface, so no separate registration is needed.

## ⚠ Security finding (load-bearing)

An analyst *executed* `_is_readonly_call` and confirmed a **live write hole**: today both
`['evaluate','--append-log']` and `['audit','--root','/etc']` return `(True,'')` — i.e. they pass the
read-only check. `--append-log` mkdir+appends JSONL under private `my-axon/`; `--root` retargets the scan.
`--workspace` is already forbidden, but `--root` is not. **Therefore exposing the tools over MCP without
forbidding `--append-log` and `--root` in the SAME commit would let a remote MCP client write under private
data over a 'read-only' boundary.** The flag-deny must ship *with*, never after, the exposure.

## Phases (reach-per-effort order)

### Phase 1 — MCP exposure (guarded) — the cheapest, widest reach
*Goal:* Make both read-only tools callable by every MCP client in one conservative, fail-safe edit, without opening any write path.
*Reach after:* Every MCP client (Claude Desktop, non-shell Copilot, external MCP/A2A agents) can list and call retrieval-eval/rag-maturity-audit read-only; shell-capable hosts (Claude Code, bash-cli Copilot) already had them and now have UNIFORM reach. SAFE_TOOLS goes from 13 to 15.

- **[S] Forbid the write/retarget flags FIRST**
  - In tools/mcp_server.py:64 extend _FORBIDDEN_FLAG_TOKENS with "--append-log" (retrieval_eval.py:187 _append_log writes JSONL under my-axon/log/retrieval-evals via mkdir) and "--root" (rag_maturity_audit.py:480 retargets the scanned tree; --workspace is ALREADY forbidden, verified). This must precede exposure: I ran _is_readonly_call and confirmed both currently pass as (True,'').
- **[S] Add the two tools to SAFE_TOOLS**
  - tools/mcp_server.py:46-53 add "retrieval-eval","rag-maturity-audit". exposed_tools() lists only ACTIVE allowlisted names (both ACTIVE in REGISTRY, verified); _mcp_tool reads the populated `purpose` field for the MCP description, so no schema/description work is needed.
- **[S] Pin the read-only subcommands (defense-in-depth)**
  - tools/mcp_server.py:58-61 add READONLY_SUBCOMMANDS["retrieval-eval"]=frozenset({"evaluate"}) and ["rag-maturity-audit"]=frozenset({"audit"}). Their argparse already constrains choices to these, but pinning blocks any future mutating subcommand from silently riding the exposure.
- **[S] Lock the guard with a regression test + docstring**
  - Add a test asserting handle_call('retrieval-eval', {'args':['evaluate','--append-log']}) returns isError, and update the SAFETY docstring (lines 12-14) to state eval/query tools are exposed read-only and their write flags are categorically forbidden over MCP. Freezes the guarantee against silent re-opening.
*Safety:* This is the entire security surface of the project and the one place 'available' could become 'unguarded'. The blast radius without the flag-deny is file creation under private my-axon/ runtime data over a 'read-only' boundary — verified reachable today. With the flag-deny + subcommand pin + test, both tools are strictly read-only, model-free, stdlib-only, deterministic, bounded-output, and run under the existing CALL_TIMEOUT. rag-maturity-audit's default scan reads only axon.git content (the publicly shareable layer), so disclosure to an external client is bounded to already-shippable content. Do NOT route these through aegis_policy or the autonomous grant — that conflates dev-autonomy with a deterministic query read and adds friction for zero safety gain.

### Phase 2 — Discoverability — convert 'available' into 'found'
*Goal:* Make the tools findable by humans and agents through list-tools and the menu, fixing the real root cause (a stale hardcoded purposes dict), not just the two RAG tools.
*Reach after:* Anyone on the menu home screen sees the two tools under SELF-OBSERVE (today: absent); anyone running list-tools sees them WITH a real one-liner — plus ~90 other registered tools get un-blanked as a side effect because list-tools now falls back to the registry's single source of truth.

- **[S] Fix list-tools to fall back to the registry purpose**
  - workspace/programs/list-tools.md:45 change `{purposes[t.name]}` to `{purposes[t.name] | t.purpose}` so any tool absent from the hardcoded ~11-entry dict (lines 23-35) renders its REGISTRY.json `purpose` instead of blank. Then recompile compiled/list-tools.cmp.md (python3 axon.py compile format ...) to avoid an orphan-compiled lint flag. Highest-leverage discoverability fix: it makes the whole registry self-describing.
- **[S] Add a RAG line to the menu SELF-OBSERVE band**
  - workspace/programs/menu.md after line 333 add two documentation lines for rag-maturity-audit and retrieval-eval alongside drift-check/dispatch-stats. Keep them in SELF-OBSERVE/discover region, NOT a top-numbered mode, so the home screen stays uncluttered and no new executable surface is created.
*Safety:* Read-only render programs only (menu.md and list-tools.md are read-only); no new executable surface, so liveness/orphan gates and the MCP allowlist are untouched. The `|` default operator guards the dict-miss, and load_registry always populates `purpose`, so the fallback cannot crash. find-program already matches both wrappers via their `# desc:` lines (verified present), so no change there. The only risk is over-exposure conflicting with the reduce-surface ethos — mitigated by keeping menu placement in the quiet discover band.

### Phase 3 — In-process import surface — optional, narrower than Axis A claimed
*Goal:* Let in-repo tools/tests/CI compose the metrics without a subprocess JSON round-trip — but only via the contract the codebase actually supports.
*Reach after:* A future retrieval-quality CI gate or composed tool can call the metric functions in-process. NOTE: this does NOT add new harness or MCP reach; programs/workflows already reach the tools via TOOL()/synapse-name → axon.py subprocess, which is unchanged.

- **[S] Add __all__ to declare the public function contract**
  - Add `__all__` to retrieval_eval.py (evaluate, score_case, aggregate, the four metric fns, RetrievalCase, RetrievedChunk) and rag_maturity_audit.py (audit, build_rows). Pure documentation of the stable surface; zero behavior change.
- **[S] Keep flat sibling imports as-is; do NOT add package-qualified imports**
  - CORRECTION to Axis A: tools/__init__.py ALREADY exists and explicitly documents that AXON dispatches every tool as a standalone script (sys.path[0]=tools/), so flat `from _axon_paths import ...` is the load-bearing contract and `tools.retrieval_eval` import is intentionally unsupported until the dispatcher migrates to module-mode. I verified `python3 -c 'import tools.retrieval_eval'` fails by design. Do NOT add a try/except package shim or claim the pyproject package promise is broken — that contradicts the documented architecture. Leave imports flat; only the optional-import guard in Phase 4 is appropriate, and only for standalone-file reach.
*Safety:* Both modules are already pure (frozen dataclasses, no mutable module singletons except a keyed lru_cache). Keeping _append_log gated behind its flag (never auto-invoked from the library function) preserves the pure-read contract. Low risk; the main hazard is the stale Axis-A premise, which would have broken the deliberate script-mode contract — avoided here.

### Phase 4 — Standalone portability — defer until external demand signal
*Goal:* Reach the general Python ecosystem (RAG devs, CI, notebooks) outside any AXON clone — but only if there is real interest, not speculatively.
*Reach after:* If built: `pip install axon-retrieval-eval` gives anyone deterministic, zero-dependency retrieval metrics + CLI with no numpy/scikit-learn/tiktoken/PyPDF2/sympy stack (the heavy AXON deps, verified in pyproject) and no kernel exposure. Until then, cross-AXON reach already works: cloning axon.git ships the engine + 2 sanitized fixtures (verified in tests/fixtures/retrieval_eval/).

- **[S] Make _axon_paths an optional import (enables standalone-file run)**
  - retrieval_eval.py:20 wrap `from _axon_paths import AXON_ROOT, MYAXON_ROOT` in try/except deriving AXON_ROOT from __file__ on ImportError. Used at exactly two argparse-default sites; the engine itself takes no AXON path. Zero behavior change inside AXON (the real import still wins). 3 lines, safe to land alone.
- **[S] Document cross-install reach now (free)**
  - One line in workspace/AXON-DOCS-RAG-DEVELOPMENT.md: the engine + sanitized fixtures ship in axon.git; private eval logs stay in gitignored my-axon/log/retrieval-evals/. Makes the already-true cross-AXON reach discoverable.
- **[M] Build the pip package only on demand**
  - packaging/retrieval-eval/ with a dependencies=[] pyproject and a single thin module generated as a BUILD ARTIFACT from canonical tools/retrieval_eval.py (never a hand-edited fork), bundling only the 2 sanitized tracked fixtures. Skip rag_maturity_audit (its rubric scans AXON's own programs, marginal value outside AXON).
*Safety:* The pip artifact is the only place a private-data leak is possible: package data must be an explicit allowlist of tests/fixtures/retrieval_eval/*.json (already sanitized/tracked); my-axon/ is gitignored and must never enter the sdist (add a build-time assert). Source-drift guard: the standalone module is generated + CI-checked byte-identical to source modulo the import line, never hand-forked. Dependency-creep guard: a venv test importing with stdlib-only must pass. None of this touches the MCP allowlist or any mutating path.

## Reach matrix — who gets in, how, at what access level

| Consumer | Access level | Path |
|---|---|---|
| Program (LANG TOOL op) | read-only by default; --append-log writable ONLY on the local shell path, never over MCP | TOOL(retrieval-eval, "evaluate --format json") in workspace/programs/retrieval-eval.md → axon.py subprocess → argparse main(); already live, unchanged. |
| Workflow / synapse | read-only by default | synapse `name: rag-maturity-audit` (e.g. rag-master-plan.yml) → workflow_run check_stale name→tool resolution → axon.py subprocess; already live, unchanged. |
| CLI human | full local CLI incl. --append-log (writes to private my-axon/log) | python3 axon.py retrieval-eval evaluate / rag-maturity-audit audit; discovery via `axon.py help <tool>` (reads purpose, works today), list-tools (Phase 2 un-blanks it), and the menu SELF-OBSERVE band (Phase 2). |
| Claude Code harness | read-only over MCP; full on shell path | STORE(L:host-cap-tools,"bash-cli") → python3 axon.py <tool> (shell path, works today); ALSO the MCP path (claude-code.md:37 names tools/mcp_server.py as target) after Phase 1. |
| Copilot harness | read-only over MCP; --append-log/--root refused pre-subprocess | bash-cli Copilot uses the shell path today; a Copilot configured as a non-shell MCP client reaches them ONLY after Phase 1 adds them to SAFE_TOOLS — its sole path to these tools. |
| Generic MCP client (Claude Desktop / external A2A agent) | strictly read-only; SAFE_TOOLS + READONLY_SUBCOMMANDS pin + _FORBIDDEN_FLAG_TOKENS triple gate | stdio JSON-RPC → tools/mcp_server.py tools/list (sees populated `purpose` as description) → tools/call; reachable only after Phase 1. |
| Another AXON install | full local CLI (same as any AXON install) | clone axon.git → gets tools/retrieval_eval.py + rag_maturity_audit.py + tests/fixtures/retrieval_eval/*.json with zero extra work; runs via its own axon.py. Documented in Phase 4. |
| Standalone non-AXON Python user | read-only metrics, no kernel exposure, stdlib-only | TODAY: none. AFTER Phase 4 optional-import guard: run retrieval_eval.py as a standalone file. AFTER optional pip publish: pip install axon-retrieval-eval → CLI + import, zero deps. |
| In-repo tool / CI gate / test | in-process function calls; pure read (logging stays flag-gated, never auto-invoked) | tests use sys.path.insert(0, tools) + flat `import retrieval_eval` (the supported contract); __all__ (Phase 3) documents the public surface. Package-qualified `tools.retrieval_eval` is intentionally NOT supported. |

## Honest callouts (incl. corrections to the brief)
- CORRECTION to Axis A: tools/__init__.py ALREADY EXISTS (verified, dated May 30) and its docstring deliberately documents that flat sibling imports are the load-bearing script-mode contract and that `import tools.retrieval_eval` is intentionally unsupported until the dispatcher migrates to module-mode. Axis A's recommendation to add __init__.py and a try/except package shim is based on a stale premise and should NOT be applied — it would fight the documented architecture. The pyproject `packages=["tools"]` is for ship-the-files, not for package-qualified import; that is fine.
- The ONLY genuinely high-value, must-do work is Phase 1 (MCP exposure) — and its value is entirely contingent on shipping the --append-log/--root flag-denies in the SAME commit. I verified by executing _is_readonly_call that today ['evaluate','--append-log'] and ['audit','--root','/etc'] both return (True,''), i.e. the write/retarget hole is real. Exposing without the deny would silently break read-only-by-default by letting a remote client mkdir+append under private my-axon/. This is the single security surface that matters.
- Phase 2's list-tools fix is the highest-leverage discoverability change but its RAG benefit is incidental: the real win is un-blanking ~90 tools by reading the registry's single source of truth instead of a hand-maintained dict that has already drifted. The menu/find-program 'empty description' framing in the brief is slightly off — find-program reads `# desc:` (populated, verified) and MCP/CLI read `purpose` (populated, verified); the only actually-empty field is the REGISTRY `description`/`desc`, which NO live surface reads. So 'fill the empty REGISTRY descriptions' is largely ceremony; the substantive fix is the list-tools fallback.
- Phase 3 (in-process API) is low-reach: programs and workflows already reach the tools via subprocess, and there is currently NO in-process consumer. __all__ is cheap documentation; anything more is speculative until a second consumer (e.g. a retrieval-quality CI gate) actually exists. Don't over-invest here.
- Phase 4's standalone pip package is real but speculative scope creep — it adds a second publishable artifact (axon-retrieval-eval) to maintain alongside axon 3.6.1. The optional-import guard (3 lines) and the cross-install doc line are worth doing now; the actual wheel publish should be GATED on a real external-demand signal, not built ahead of need. Skip a standalone rag_maturity_audit entirely (its rubric scans AXON's own programs, marginal off-AXON value).
- Phase ordering reflects reach-per-effort: Phase 1 unlocks the entire non-shell harness tier for ~5 lines; Phase 2 is system-wide discoverability for ~3 lines + a recompile; Phases 3-4 are narrow/optional. Phases 1, 2, 3-guard, and 4-import-guard are mutually independent and can land in parallel, EXCEPT the two flag-denies must never lag the SAFE_TOOLS add.
- Deliberately NOT done: routing the read-only eval/audit through aegis_policy.py or the autonomous grant. They are deterministic query reads; gating them would be governance theater. AEGIS is the correct home ONLY for FUTURE write/network capabilities (an invoked _append_log, a dump-case fixture writer, or a score_live→web_search fallback that breaks determinism and spends) — those get named GATED capabilities then, not now.

## First move
Phase 1 as one PR: add \"retrieval-eval\" and \"rag-maturity-audit\" to SAFE_TOOLS in tools/mcp_server.py and, in the SAME diff, add \"--append-log\" and \"--root\" to _FORBIDDEN_FLAG_TOKENS, pin both subcommands in READONLY_SUBCOMMANDS, and add the handle_call --append-log refusal test. Cheapest-widest-reach because it touches one file with ~5 verified lines, needs no new code/deps/model, and is the only edit that unlocks the entire non-shell harness tier (Copilot-as-MCP-client, Claude Desktop, external agents) that has no other path to these tools — while keeping them strictly read-only. I confirmed the write hole is live (_is_readonly_call passes --append-log today) and that --workspace is already blocked but --root is not, so the two flag-denies are load-bearing and must ship with, never after, the exposure.