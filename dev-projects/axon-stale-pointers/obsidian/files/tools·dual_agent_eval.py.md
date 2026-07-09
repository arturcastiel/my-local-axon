---
tags: [code, file]
path: tools/dual_agent_eval.py
---

# tools/dual_agent_eval.py

> 68 symbol(s) · 2 outbound file dependency(ies)

## Symbols
- `.__call__()`
- `.__call__()`
- `.__init__()`
- `.__init__()`
- `._build_cmd()`
- `._render()`
- `95% Wilson score interval for a binomial proportion.      Honest small-sample CI`
- `AnthropicBackend`
- `Backend powered by the Claude Code CLI in headless mode (`claude -p`) — uses you`
- `Build a pre-registration record: the LOCKED protocol for a specific run, stamped`
- `Claude-CLI MCP config that launches AXON's MCP server (read-only tool allowlist)`
- `ClaudeCliBackend`
- `Cost + best-case-CI projection before any budgeted run (no backend, no spend).`
- `Drive Agent-U (pursuing `goal`) ↔ Agent-A (operator). Returns the transcript.`
- `Estimate cost AND whether a run CAN be conclusive at this n — BEFORE spending a`
- `Generic objective arm: run the conversation, extract the produced solver, and gr`
- `Goal id -> (agent-visible spec, oracle grade_fn). 'bl:N' -> the Buckley-Leverett`
- `Live backend: ANTHROPIC_API_KEY + the anthropic SDK. Lazy — only imported/     c`
- `Map a backend call-time error to an actionable hint (auth / model / transient).`
- `Objective MMS proof run: paired AXON-vs-bare per manufactured goal, oracle-grade`
- `Offline, deterministic backend — NO key, NO network. Simulates the A/B so     yo`
- `One MMS arm (back-compat wrapper): grade the produced solver via proof_mms.grade`
- `Per goal id: resolve to its oracle (MMS order-fit OR Buckley-Leverett analytical`
- `Pull the operator's produced solver from the transcript: the most recent python`
- `Run AXON arm + baseline arm per goal; return per-goal deltas + aggregate.`
- `Run one MMS arm (back-compat wrapper).`
- `Score a conversation. Heuristic baseline scorer; a richer rubric/axon-eval     p`
- `Spec -> the agent-visible task. Contains PDE/coeffs/domain/t_final/forcing-or-fl`
- `Stamp + write a LOCKED pre-registration record (commit it BEFORE running).`
- `The AXON arm prepends the AXON-discipline system prompt. For the RIGOROUS arm (B`
- `The proof unit for an MMS goal — PAIRED + OBJECTIVE. axon_wins iff the AXON arm'`
- `The proof unit: AXON arm vs baseline arm on one goal.`
- `_backend_error_hint()`
- `_code_fingerprint()`
- `_demo_backend()`
- `_git_head()`
- `_grade_arm()`
- `_resolve_goal()`
- `_run_resolved_arm()`
- `aggregate()`
- `axon_mcp_config()`
- `build_parser()`
- `cmd_preflight()`
- `cmd_prereg()`
- `cmd_run()`
- `cmd_run_mms()`
- `delta()`
- `dual_agent_eval.py`
- `extract_solver_code()`
- `grade_mms_arm()`
- `load_fixtures()`
- `main()`
- `make_backend()`
- `make_operator()`
- `mms_delta()`
- `preflight()`
- `prereg()`
- `render_mms_goal()`
- `run_arm()`
- `run_conversation()`
- `run_fixtures()`
- `run_mms_arm()`
- `run_mms_fixtures()`
- `score()`
- `sha256 (16 hex) over the methodology + oracle + harness bytes — pins the EXACT v`
- `wilson_interval()`
- `write_mms_report()`
- `write_report()`

## Depends on
- [[_unknown_]]
- [[tools·proof_bl.py]]
