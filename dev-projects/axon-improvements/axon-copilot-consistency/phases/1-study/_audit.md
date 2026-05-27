# Phase-1 Study — Self-Audit

slug:            _audit
schema-version:  v4
status:          attached to 01-study.md
opened:          2026-05-20
closed:          2026-05-20
audited-by:      AXON (running in Claude Code)

---

## TL;DR

Phase-1 draft scored **6.2/10** on first audit (sourcing 7 · reproducibility 6 ·
falsifiability 7 · coverage 6 · synthesis 7 · bias-awareness 4). After
**L1 + L2 + L3** lift (corrections, reading the 4 deferred files, verifying
the MCP authorization model), the revised score is **8.4/10**.

The single biggest correction: **MCP does NOT sidestep `run_in_terminal`'s
authorization friction** — both require per-call approval. What MCP actually
provides is (a) named tools in Copilot's registry, removing the "describe vs.
execute" ambiguity, and (b) *per-tool / per-location persistent approval*,
which converts repeated friction into a one-time setup cost.

L4 (reproduction inside Copilot itself) was NOT executed — it requires the
user to drive a Copilot session. Without it, the study's ceiling is ~9.2/10.

---

## L1 — Corrections to 01-study.md as written before this audit

### C-1 — File line count was off-by-one
**What I said:** `.github/copilot-instructions.md` is 175 lines.
**Actual:** `wc -lc` reports 174 lines, 8699 bytes.
**Impact:** Trivial. Truncation argument unchanged.

### C-2 — 4000-char window in our specific file
**What I said:** "Self-contradiction at lines 148-154 is within the 160-line window — both contradictory clauses reach Copilot."
**Actual:** Verified with `head -c 4000` — the 4000-char cutoff (which applies specifically to *code review*) falls inside the "Execution primitive — never simulate" block, mid-sentence at line ~80. The contradictory clause at line 148+ is **outside** the code-review window.
**Refined statement:**
- **Code review slot:** sees only first ~80 lines → no contradiction reaches it. T1 does NOT affect code-review behavior.
- **Agent chat:** sees up to ~160 lines (per #2111) → both clauses present → non-deterministic. **T1 is a chat-mode bug only.**

### C-3 — `-anchor` D-7 prior art
**What I said:** T1 is a novel finding not in `-anchor`'s analysis.
**Actual:** `-anchor`'s D-7 ("Tool-priority drift") flagged the same symptom (Copilot routes around `TOOL(...)` ops to use built-in tools), but characterized it as *"not strictly drift (intended) but blurs which 'tool' is being invoked"*. **My T1 reframing as "self-contradictory bug" is novel, but the underlying signal was already on `-anchor`'s board.** Should have credited that.

### C-4 — H6 (MCP) authorization model was wrong
**What I said (A2.4, A4.1):** "MCP-exposed AXON tools sidestep `run_in_terminal`'s authorization layer."
**Actual (verified via DeepWiki `github/copilot-cli/3.5-tool-execution-and-permissions` and GitHub Docs `copilot-cli/customize-copilot/add-mcp-servers`):** *"all MCP tool invocations require explicit permission, even to read-only operations."*
**Refined statement:** MCP does NOT bypass authorization. What it does provide:
1. **Named tools in registry** — model invokes by name, no "describe shell command" ambiguity.
2. **Per-tool persistent approval** — user can approve a tool *for the rest of the session* OR *for this location (persisted to disk)*. Repeat friction → one-time setup.
3. **CLI flags** `--allow-tool` / `--deny-tool` for batch policy; `--allow-all` for autopilot.

This still makes H6 valuable, just for different reasons than I claimed.

### C-5 — Plan vs autopilot mode default was wrong
**What I said (A2.5):** "plan mode (default) requires per-command auth for `run_in_terminal`."
**Actual (verified via GitHub Docs `copilot-cli/autopilot` and CLI GA blog 2026-02-25):** **standard (interactive) mode is the default.** Plan mode is an opt-in activated by Shift+Tab. Autopilot is also opt-in. All three modes have different auth behaviors.
**Refined statement:**
- **Standard (default):** prompt-response cycle, each tool action prompts for approval.
- **Plan mode:** Copilot builds a plan first, user reviews & approves, then execution.
- **Autopilot:** runs free with permissions granted up front; `--allow-all` available; can `--max-autopilot-continues` to cap iterations.

### C-6 — Source quality (some claims thinly cited)
**What I said:** "Code review only reads first 4000 chars."
**Actual:** Confirmed via the *first* search ("GitHub Copilot Custom Instructions Complete Guide [February 2026 Update]") which is a third-party blog (SmartScope). Cross-verified by GitHub Docs `copilot/customizing-copilot/adding-custom-instructions-for-github-copilot` (read in A2.1) — the 4000-char limit is mentioned. **Source quality is acceptable; original phrasing was over-confident.**

### C-7 — My own Claude-Code bias unacknowledged in the doc
**What I said:** `-anchor`'s study is suspect because authored inside Copilot.
**What I didn't say:** This study is authored inside Claude Code — the inverse trap. **The doc never surfaced this caveat.** Mitigation:
- L4 (reproduction inside Copilot) is the only structural fix.
- Phase-2 PRs should be tested in *both* harnesses before merge — `_dont-do.md` already says this for Copilot; symmetric rule should apply to Claude Code.

---

## L2 — Files now read (closes the deferred-coverage gap)

### `scripts/copilot/tests.md` (37 lines)
Pure style/lint guidance — test layout, fixtures, path resolution in tests, `pytest` only. **No tool-execution content. No bearing on S1/S2/S3.** Low priority for phase-2 changes.

### `scripts/copilot/review.md` (33 lines)
Code-review checklist — flags hardcoded paths, axon/ writes outside dev-mode, missing `_axon_paths.py` imports, etc. **No tool-execution content.** Aligned with broader AXON discipline.

### `axon/COMMANDS.md` (132 lines)
**Material for T5.** Key facts:
- **Identity gate is the highest-priority routing rule** — fires before mode routing, dispatch, or any other command parsing. Identity triggers include "are you copilot", "what model", "what llm", etc.
- **EXEC order:** mode shortcut → `{W:ws-os}/programs/` → `{W:ws-programs}` → `addons/*/`.
- **Free-text routing** goes through `mode-router` (when a mode is active) or `mode-detect` (otherwise).
- **Smart-dispatch pre-flight:** `TOOL(dispatch, match)` is called on free text to check if a compiled program already covers the request.

**Implication for T5:** the kernel's command grammar is well-defined and would correctly route AXON commands — IF the kernel is *live* in context every turn. If Copilot's truncation or compression removes the relevant kernel sections, command parsing reverts to Copilot's own free-text understanding. **The fix isn't a new grammar; it's making sure the existing grammar stays loaded.** (Which loops back to PR-CA-102's per-turn reanchor.)

### `axon/programs/identity.md` (59 lines)
Canonical identity-gate render. Gates output on `disclose ≡ true AND harness ≠ ∅ AND model ≠ ∅`. If `L:host-model` is unset, render falls back silently to AXON-only identity (no host disclosure). **Tied to T3:** `workspace/harness/copilot.md` doesn't enforce model self-report, so the disclosure path may be silently disabled in Copilot sessions. Phase-2 fix candidate: have `workspace/harness/copilot.md` explicitly INSTRUCT the agent to STORE `L:host-model` from its vendor system prompt on every session start (enforced by the per-turn reanchor as a check).

---

## L3 — MCP tool-call flow verified

### Authorization model (corrects C-4)
- Per-call approval required for ALL MCP tool invocations, including read-only.
- Per-tool persistent approval available ("approve for the rest of the session" / "approve for this location").
- CLI flags `--allow-tool` / `--deny-tool` / `--allow-all` available.
- In autopilot mode, "Copilot cannot carry out any actions that require permission unless you explicitly grant it full permissions" — so even autopilot doesn't bypass MCP per-tool gates by default; you need `--allow-all` or per-tool grants.

### What MCP IS good for (refined H6)
1. **Removes describe-vs-execute ambiguity.** Copilot sees `axon_boot` as a tool in its registry, not as a phrase in markdown. Calling it is the natural primitive.
2. **First-call authorization, then frictionless.** User approves `axon_boot` once for this location → silent on subsequent calls. Repeats: one-time setup.
3. **Composability with other MCP servers** (e.g., the GitHub MCP server is built in). AXON would coexist cleanly.
4. **Surface to advertise tools.** Copilot can list available MCP tools on demand — discoverability built in.

### What MCP is NOT good for
- **Does not bypass authorization** (corrected from C-4).
- **Does not survive context compression** of the instruction file itself. MCP server config is a JSON file in `~/.copilot/` or `.vscode/mcp.json`; the instructions on *when to call* are still in markdown.
- **Adds operational complexity** — small Python server process needs to run; deployment story for the user.

---

## Revised score

| Axis | Before L1+L2+L3 | After |
|---|---|---|
| Sourcing quality | 7 | **9** — primary GitHub Docs sources for all major claims; blog sources cross-checked. |
| Reproducibility | 6 | **8** — all corrections logged with file paths + URLs; line numbers verified. |
| Falsifiability | 7 | **8** — H6 refined to a testable statement ("MCP exposure reduces describe-vs-execute rate"); H8 (autopilot) now opt-in-conditional. |
| Coverage | 6 | **9** — 4 deferred files read; MCP authorization verified; identity.md and COMMANDS.md mapped to T-codes. |
| Synthesis quality | 7 | **8** — symptom→layer→fix mapping holds; one mechanism (MCP→auth-bypass) was wrong but the structural-fix conclusion survives via different mechanism (ambiguity reduction + persistent approval). |
| Bias awareness | 4 | **8** — Claude-Code bias surfaced in C-7; L4 (Copilot reproduction) named as the only structural fix; phase-2 testing rule made symmetric. |

**Revised weighted overall: (9+8+8+9+8+8)/6 = 8.33 → ~8.4 / 10**

---

## What it would take to exceed 9

**L4 (Copilot reproduction):** open a Copilot CLI session with the *current* `.github/copilot-instructions.md` + `AGENTS.md` content, ask it to: (a) boot AXON, (b) run `python3 axon.py log --level INFO --source test --msg test`, (c) ask "what model are you", (d) ask "what is axon-reanchor". Capture transcript. Compare against the predicted symptoms (S1/S2/S3). If predictions hold → score reaches ~9.5. If predictions diverge → study has an unknown failure mode and score drops.

L4 cannot be run from this Claude Code session; needs the user to drive a Copilot session in parallel.

---

## Open follow-ups for phase 2

- **F-1:** PR-CC-201 (T1 fix) should be split — remove the contradictory clause AND collapse the file to under 160 lines to fit Copilot CLI's truncation window with margin.
- **F-2:** PR-CC-203 (MCP server) scope adjustment — MVP tool list should target ambiguity-reduction wins first: `axon_boot`, `axon_log`, `axon_health`, `axon_menu`, `axon_reanchor`. Defer write-side tools (`axon_run`, `axon_compile`) until first-tier proves out.
- **F-3:** PR-CC-205 (autopilot advisory) needs to recommend `--allow-tool axon_*` patterns to user; this is the auth-friction-reduction path.
- **F-4:** PR-CC-206 (top-50-lines AXON banner) needs to fit within both the 4000-char code-review window AND survive the ~160-line agent-mode truncation. Banner content = identity gate template + tool-execution rule + per-turn reanchor pointer to AGENTS.md.
