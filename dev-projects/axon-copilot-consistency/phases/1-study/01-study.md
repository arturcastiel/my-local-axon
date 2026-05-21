# Study — 1-study · AXON Copilot Consistency

_Status: scaffold. Population pending — run `code-dev study` or proceed inline._

> **AUDIT NOTE (2026-05-20):** This document was self-audited and corrected
> via `_audit.md` in the same phase. Read `_audit.md` before treating any
> specific claim below as authoritative — especially A2.4-A2.5 (MCP and mode
> defaults) and the A3.2/A4.2 symptom-to-fix mapping, which were materially
> refined in C-4 and C-5. Score after audit: **8.4/10**.
>
> **Bias caveat:** authored inside Claude Code. The inverse of `-anchor`'s
> in-Copilot bias. Phase-2 PRs must be reproduced in *both* harnesses before
> merge.

## Reported symptoms (from user, Claude Code session)

| # | Symptom | Where observed | Severity |
|---|---------|----------------|----------|
| S1 | Command comprehension < Claude Code baseline | Copilot CLI + IDE | high |
| S2 | Tool-call gap — Python access exists, not invoked consistently | Copilot CLI + IDE | high |
| S3 | Persona / cognition-frame drift across turns | Copilot CLI + IDE | medium (owned by `-anchor`) |

Same Opus model in both harnesses → gap is harness-level.

## Research axes (all four — to be populated)

### A1 — Codebase audit
**Goal:** map every AXON file that participates in the Copilot boot path or
behaves differently between harnesses.

**Status:** ✓ DONE — 2026-05-20

#### A1.1 — Files present and their role

| File | LOC | Role | Sufficient? |
|---|---|---|---|
| `startup.md` lines 48-74 | 27 | "FOR THE AGENT (GitHub Copilot)" boot directive | ✓ |
| `.github/copilot-instructions.md` | 175 | Always-on baseline auto-prepended to every chat turn | ⚠ has contradictions (see A1.4) |
| `.vscode/settings.json` | 16 | Wires Copilot Chat slots → `scripts/copilot/{code,tests,commits,review}.md` | ✓ |
| `scripts/copilot/code.md` | 37 | Code-gen slot — path resolution + style | ⚠ no tool-execution rules |
| `scripts/copilot/commits.md` | 27 | Commit-msg slot — format + tone | ✓ scope-correct |
| `scripts/copilot/tests.md` | 37 | Test-gen slot (not read this audit) | ? |
| `scripts/copilot/review.md` | 33 | Review-selection slot (not read this audit) | ? |
| `AGENTS.md` | 72 | Short-form contract, points to copilot-instructions | ✓ |
| `workspace/harness/copilot.md` | 15 | Sets `L:host-harness="GitHub Copilot"`; model self-reported | ⚠ no enforcement of model self-report |
| `workspace/programs/axon-reanchor.md` | 109 | Per-turn re-anchor program (PR-CA-102 spec) | ✓ |
| `tools/axon_drift_log.py` | n/a | Append-only drift event log (PR-CA-105') | ✓ |

#### A1.2 — Sibling project state

- `axon-copilot-anchor` phase-1: **CLOSED** 2026-05-19 — produced `01-drift-vectors.md` with 7 drift codes (D-1..D-7) and 4 strategies (A baseline-strengthening, B externalized re-anchor, C slot-level, D self-check).
- `axon-copilot-anchor` phase-2: **active** — locked 5 PRs (PR-CA-101..105').
- PR-CA-102 (`axon-reanchor`) has been **implemented** — commit `708450b` on current branch `feature/pr-ca-102-axon-reanchor`.
- Other PRs (CA-101, CA-103, CA-104, CA-105') — implementation status pending verification.

#### A1.3 — How the Copilot boot path actually fires

1. Copilot CLI auto-prepends `.github/copilot-instructions.md` to chat context.
2. That file directs the agent to read `startup.md` first.
3. `startup.md` → "FOR THE AGENT (GitHub Copilot)" section says: skip Step 0 (Claude-Code-specific), read KERNEL-SLIM.md, follow boot steps.
4. KERNEL-SLIM boot step 2 → G-11 harness detection executes `workspace/harness/copilot.md`.
5. `workspace/harness/copilot.md` sets `L:host-harness="GitHub Copilot"` and **instructs the agent to self-report `L:host-model` from its own system prompt**.
6. Boot continues to my-axon detection, resume offer, menu render.
7. **PR-CA-102 layer:** `.github/copilot-instructions.md` § "Per-turn reanchor" mandates that **every** subsequent turn begins with `EXEC(axon-reanchor)` before parsing the user input.

#### A1.4 — Tensions found in current state (NEW — not in -anchor's analysis)

These are root-cause candidates for the symptoms the user reports.

**T1 — Self-contradictory directive on tool execution** (likely root cause of S2):
- `.github/copilot-instructions.md` lines 68-80: "Execution primitive — never simulate. When a program is named ... the correct response is a literal `bash` call: `bash('python3 axon.py run ...')`. Never substitute 'I'll act as if I were the program' for an actual EXEC."
- `.github/copilot-instructions.md` lines 148-154 (§ "Out of scope for Copilot"): "You cannot run AXON tools yourself. When the AXON program needs `TOOL(boot)`, `TOOL(health)`, `TOOL(memory)` etc., **describe what would run and wait for the human to execute it.**"
- These two clauses **directly contradict**. The first was added by PR-CA-102 (2026-05-19); the second is older and was not updated. Copilot reads both and defaults to the more conservative "describe and wait" — which produces exactly the user-reported symptom: "has access to Python but does not call things."

**T2 — Slot files don't reinforce tool-execution behavior**:
- None of `scripts/copilot/{code,commits,tests,review}.md` mention literal `bash` invocation of `python3 axon.py …`.
- These files anchor *style*, not *behavior*. When the chat slot is active, the agent leans on slot guidance — and the slots are silent on tool calls.
- Symptom: stylistic AXON behavior in code-gen contexts; execution drift in chat/agent contexts.

**T3 — `workspace/harness/copilot.md` is too minimal**:
- 15 lines. Sets only `L:host-harness`. Instructs the agent to self-report model "if your system prompt names one" — no enforcement.
- Contrast: `claude-code.md` reads `$CLAUDE_MODEL` env var (mechanical).
- If Copilot's vendor system prompt names "Claude Opus 4.7" (per `-anchor` D-3 evidence), the agent *should* report it — but if it skips this STORE, the identity gate silently falls back to AXON-only, and we lose observability of which model is actually running.

**T4 — Per-turn reanchor is unverifiable from the outside**:
- `axon-reanchor.md` mandates `READ(axon/KERNEL-SLIM.md, lines=1..200)` + `READ(axon/core/LANG.md, lines=1..160)` every turn.
- Nothing forces Copilot to actually perform those reads — it can generate text that *looks like* the reanchor was performed (the same failure mode as S2).
- Mitigation idea (phase-2): a tiny side-effect — write a timestamp file on every successful reanchor — that the next turn can verify exists.

**T5 — Command-parsing path may diverge between harnesses** (likely root cause of S1):
- `axon/COMMANDS.md` defines `EXEC` order: mode shortcut → `{W:ws-os}/programs/{cmd}.md` → `{W:ws-programs}{cmd}.md` → `addons/*/`.
- This depends on the agent treating user input as a *dispatch directive*, not as a *prose request*.
- Copilot's vendor system prompt (per `-anchor` D-5) mandates calls like `fetch_copilot_cli_documentation` for capability questions, **routing user input through Copilot's own command grammar before AXON's**.
- Symptom: AXON command words (e.g. `axon-reanchor`, `code-dev study`, `menu`) get misclassified by Copilot's pre-AXON layer and never reach the kernel's command parser.

#### A1.5 — Hypothesis carry-forward (input to A2/A3)

H1 from `01-study.md` "Hypotheses" section now refined:
- **H1' (T1-confirmed):** Copilot reads the older "describe and wait" clause in copilot-instructions.md and defers to it. **Fix candidate for phase 2:** remove or invert the § "Out of scope for Copilot" block; merge its content with the newer "Execution primitive" block.
- **H2 (T5-related):** Copilot's command-routing layer intercepts AXON commands before the kernel sees them. **Need from A2:** does Copilot 2026 expose any way to mark certain string prefixes as "pass directly to instructions"?
- **H3 (T4-related):** Per-turn reanchor only works if Copilot actually re-reads the files. **Need from A2:** does Copilot 2026 expose any "verifiable instruction execution" mechanism (e.g. tool-call attestation, hashed-prompt receipts)?
- **H4 (T3-related):** Model self-report is unenforced. **Need from A2:** any way to read Copilot's vendor system prompt programmatically.

#### A1.6 — Files not yet read (deferred)

- `scripts/copilot/tests.md`, `scripts/copilot/review.md` — slot files; low priority for execution-gap study, deferred to phase 2 if relevant.
- `workspace/programs/axon-reanchor.cmp.md` — compiled form, if exists (verify in A1.7 followup).
- `axon/programs/identity.md` — the identity-gate program; only relevant if S1 traces back to identity routing.
- `axon/COMMANDS.md` — referenced in T5 but not re-read this audit; needed if A4 deepens command-grammar diff.

### A2 — Online: Copilot extension points (2026)
**Goal:** authoritative answer to "what hooks/instructions does Copilot
actually expose, today, for persona anchoring and tool-use steering?"

**Status:** ✓ DONE — 2026-05-20

#### A2.1 — Instruction file precedence (Copilot CLI, May 2026)

Per GitHub Docs (`docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions`):

| File / location | Role | Precedence (Copilot CLI) |
|---|---|---|
| `AGENTS.md` (repo root) | **Primary** instructions — explicitly named "primary" | **highest (repo-scope)** |
| `AGENTS.md` (cwd or `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` dirs) | Additional primary | high |
| `CLAUDE.md` (repo root) | Read by Copilot CLI as a Claude-pattern instruction file | high |
| `GEMINI.md` (repo root) | Read by Copilot CLI as a Gemini-pattern instruction file | high |
| `.github/copilot-instructions.md` | Repository-wide custom instructions | medium |
| `.github/instructions/NAME.instructions.md` | Path-scoped instructions (matches via `applyTo` frontmatter) | scoped |
| `$HOME/.copilot/copilot-instructions.md` | Per-user local instructions | personal |

**Multi-user precedence (any Copilot surface):** *personal > repository > organization* — explicitly stated in GitHub Docs.

**Conflict resolution:** Docs say verbatim: *"Copilot's choice between conflicting instructions is non-deterministic"*. **This directly validates T1** — our self-contradicting clauses (lines 68-80 vs. 148-154) produce *random* tool-call behavior, not deterministic deference.

#### A2.2 — Instruction file truncation (confirmed bug, OPEN)

Two GitHub issues on `github/copilot-cli`:

- **Issue #2111** (open, reported 2026-03-17) — *"Instruction file gets truncated at around 160 lines when loaded into context"* — a user's 364-line file was cut at the Git Workflow section "roughly the first ~160 lines"; cut is silent. No documented limit.
- **Issue #567** (closed, no documented resolution) — *"Custom instructions are truncated at startup"* — both `AGENTS.md` and `.github/copilot-instructions.md` affected, "only about 15 lines of the markdown is provided to copilot CLI at startup, cutting it off in the middle of a line." Recommended workaround: **"first instruction can be for it to read `AGENTS.md`" — i.e. tell the auto-prepended fragment to MANUALLY read the longer file**.

**Implications for AXON:**
- Our `.github/copilot-instructions.md` is **175 lines** — past issue #2111's ~160 threshold. Lines 168-175 ("See also" cross-refs to AXON-DOCS-* pages) likely truncated.
- The "Per-turn reanchor" section (lines 24-80) is safely *under* 160 lines if injected from the top. ✓
- The **self-contradiction at lines 148-154** is **within** the 160-line window — both contradictory clauses reach Copilot. Conflict resolution is non-deterministic per A2.1. **Confirms T1 as a real, currently-active bug.**
- Our `AGENTS.md` is **72 lines** — safe from truncation, and is the **highest-precedence** file. Currently underused.
- **Strategic implication:** the load-bearing rules (identity, tool execution, kernel boot directive) should live in `AGENTS.md`, not `.github/copilot-instructions.md`, in Copilot CLI. The VS Code Chat extension uses different precedence (see A2.3).

**Code review reads only the first 4000 characters** of any custom instruction file — that's roughly 40-50 lines. Stricter than the agent mode limit. Our file's identity + boot protocol fits in the first 4000 chars (line 22, ~700 chars), but the per-turn reanchor block (line 24+, ~2600 chars from top) is mostly inside the 4000-char budget too. The cognition-frame rules at line 54+ may be at the edge.

#### A2.3 — VS Code Copilot Chat slot config (May 2026)

Per `code.visualstudio.com/docs/copilot/customization/custom-instructions`:

- `.github/copilot-instructions.md` is **auto-detected** by VS Code and applied to all chat requests in that workspace. No setting required.
- **Settings-based instructions deprecated** (as of VS Code 1.102):
  - `github.copilot.chat.codeGeneration.instructions` — **DEPRECATED** (file-based now preferred)
  - `github.copilot.chat.testGeneration.instructions` — **DEPRECATED**
- Settings still supported for:
  - `github.copilot.chat.commitMessageGeneration.instructions`
  - `github.copilot.chat.reviewSelection.instructions`
  - PR description generation

**Implications for AXON:**
- Our `.vscode/settings.json` uses `github.copilot.chat.codeGeneration.instructions` and `github.copilot.chat.testGeneration.instructions` → **using deprecated APIs**. Slot file rules (`scripts/copilot/code.md`, `scripts/copilot/tests.md`) may stop being honored.
- The replacement is `.github/instructions/NAME.instructions.md` files with `applyTo:` frontmatter for path-scoped rules.
- `commits.md` and `review.md` slots remain valid via settings.

#### A2.4 — MCP support (NEW anchoring surface — not in -anchor's analysis)

Per GitHub Docs `docs.github.com/en/copilot/concepts/context/mcp`:

- **MCP is supported across CLI + VS Code + JetBrains + Xcode + cloud agent.**
- VS Code 1.99+ required; Copilot CLI supports local and remote MCP servers natively.
- MCP servers can **expose custom tools to the agent**. The GitHub MCP server is built in.
- Configuration:
  - VS Code: `.vscode/mcp.json` or per-user MCP config.
  - Copilot CLI: `~/.copilot/config` or `mcp-servers` block.
  - Repo-scoped: `mcp.json` at repo root (varies by client).
- Org-level policy can disable MCP entirely (disabled by default at enterprise; usually enabled for personal).

**Strategic implication — biggest anchoring lever not yet pulled:** AXON could ship a tiny MCP server (`axon-mcp`) that exposes `python3 axon.py boot`, `axon log`, `axon health`, etc., as **native MCP tools** to Copilot. Copilot's agent loop calls MCP tools the same way it calls `run_in_terminal` — except they appear in the tool registry by name, making them harder to "skip and describe" (the S2 symptom). This is the closest equivalent to Claude Code's pre-mounted Bash tool with auto-allow.

#### A2.5 — Copilot CLI agent mode + run_in_terminal (May 2026)

Per `github.blog` (CLI GA March 2026) and `learn.microsoft.com/agent-framework`:

- **Two run modes:** *plan* (model outlines, asks for approval per step) and *autopilot* (model executes tools/commands without per-step approval).
- `run_in_terminal` is the canonical shell-tool primitive — requires per-command authorization in default (plan) mode, can run free in autopilot.
- URL allowlist/denylist configurable in `~/.copilot/config` (`allowed_urls`, `denied_urls`) — applies to `curl`/`wget`/etc.
- Both autonomous JetBrains and VS Code CLI agents share unified sessions view (May 2026 changelog).

**Implications for AXON:**
- The mismatch is real but the *mechanism* is now clearer: in **plan mode** (default), Copilot is **expected** to ask before each shell call. That's a UX feature, not a bug — but combined with our contradictory instructions (T1), the model defers to "describe and ask" by default.
- **Autopilot mode would close S2** for read-only AXON tool calls (boot, log, health). But the user has to opt in — Copilot won't switch modes from an instruction file.
- An MCP-based AXON tool exposure (A2.4) sidesteps the issue entirely: MCP tools don't go through `run_in_terminal`'s authorization layer the same way.

#### A2.6 — Other Copilot 2026 facts relevant to AXON

- **`COPILOT_CUSTOM_INSTRUCTIONS_DIRS`** env var lets you point Copilot CLI at additional directories of instruction files. Could be used to dynamically load a per-session AXON re-anchor file from `my-axon/`.
- **Claude Opus 4.6** is GA on Copilot since Feb 2026 (`github.blog/changelog/2026-02-05`); Opus 4.7 referenced in `metacto.com` comparison piece. Same model family as Claude Code; **the gap is harness-level, not model-level — confirmed empirically by external comparisons**.
- **Plan vs autopilot mode** is set per-session; not auto-promotable from instructions.

### A3 — Online: tool-calling behavior on Copilot Opus
**Goal:** understand why Copilot-on-Opus often *describes* a shell/Python call
instead of executing it, when Claude-Code-on-Opus reliably executes.

**Status:** ✓ DONE — 2026-05-20 (folded into A2 findings; no separate corpus required)

#### A3.1 — Hypotheses revisited

Hypotheses from initial 01-study.md, now graded against A1+A2 findings:

| # | Hypothesis | Verdict | Evidence |
|---|---|---|---|
| H1 | Vendor system prompt outranks AXON instructions | **PARTIAL** | A2.1: precedence is *personal > repository > org*; vendor system prompt is *prepended* (not replaceable) but our instruction files DO load — issue is content conflict (T1), not precedence. |
| H1' | Self-contradiction in our own instruction file → random tool-call rate | **CONFIRMED** | A2.1: docs state conflict resolution is "non-deterministic". T1 self-contradiction exists. Direct hit. |
| H2 | Shell tool is permissioned/asked, not auto-allowed → model defers | **CONFIRMED** | A2.5: plan mode is default; `run_in_terminal` asks per-command unless user opts into autopilot. |
| H3 | Instruction-priority puts our file below vendor → tie loss | **REJECTED for repo files** | A2.1: AGENTS.md is treated as *primary*. Lost is *content* battle (T1), not *precedence* battle. |
| H4 | Long instruction silently truncated | **CONFIRMED** | A2.2: copilot-cli #2111 (open) — truncation at ~160 lines, silent, non-deterministic boundary. Our file is 175 lines. |

#### A3.2 — Root-cause synthesis for S2 (tool-call gap)

S2 is a **compound bug**, not a single failure. Three layers, each independently sufficient:

1. **Authorization friction (H2):** Plan mode (default) asks per-command. Combined with AXON's high cadence of small ops (`boot`, `log`, `health`, etc.), the asking friction → users implicitly train Copilot to "describe instead of asking" as a UX favor.
2. **Self-contradiction (H1' / T1):** Lines 68-80 say "never simulate, literal bash() call"; lines 148-154 say "describe what would run and wait". Conflict resolution is non-deterministic.
3. **Truncation (H4 / A2.2):** Our 175-line file may have any portion past ~line 160 cut. The "Verifying you have loaded this file" section (line 163) is at the edge — sometimes loads, sometimes doesn't.

#### A3.3 — Root-cause synthesis for S1 (command comprehension)

S1 likely stems from:

- **A2.2 truncation:** kernel boot directive at lines 10-22 is safe, but commands defined in `axon/COMMANDS.md` (mode shortcuts `1`-`7`, `0`/`menu`, `D`, free-text routing rules) are read lazily — Copilot only loads them if the boot sequence completes and references them. If truncation cuts the per-turn reanchor mid-file, the kernel never gets re-loaded turn-to-turn.
- **A2.4 absence:** Without MCP exposure, AXON commands look like *prose user input* to Copilot. Claude Code's harness has no special command grammar either — but its persistent Output Style + UserPromptSubmit hook make the kernel "live" every turn, so command dispatch happens. On Copilot, the kernel becomes "memory" within a few turns.
- **No verifiable reanchor execution (T4):** The reanchor program tells Copilot to RE-READ KERNEL-SLIM 1-200 + LANG 1-160. Nothing forces this read to happen — Copilot can generate text that *looks like* the reanchor without actually fetching the files (the same failure mode as S2).

#### A3.4 — Hypotheses to add (for phase-2 design)

- **H5 (truncation-aware design):** Move load-bearing content to `AGENTS.md` (72 lines now, safe), and treat `.github/copilot-instructions.md` as a "shim" that points to AGENTS.md + critical kernel sections.
- **H6 (MCP anchoring):** Expose `python3 axon.py {boot,log,health,...}` as MCP tools. Copilot calls them by name, not via `run_in_terminal`, sidestepping the authorization friction and the "describe vs. execute" ambiguity.
- **H7 (env-driven instruction load):** Use `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` to inject a session-scoped AXON re-anchor file at session start. Survives compression as long as the env var is set.
- **H8 (autopilot opt-in):** Document the autopilot-mode opt-in in user-facing setup; phase-2 setup script can advise the user.

### A4 — Diff vs Claude Code
**Goal:** for each Claude Code anchoring mechanism, identify the
closest Copilot equivalent (if any) and the cost of using it.

**Status:** ✓ DONE — 2026-05-20

#### A4.1 — Defense-layer matrix (refined from `-anchor`'s 5/7 vs 3/7 scoring)

| Layer | Claude Code | Copilot CLI (today) | Copilot CLI (achievable in 2026) | Cost |
|---|---|---|---|---|
| Replace system prompt | ✅ Output Style (`~/.claude/output-styles/axon.md`) replaces entire CC system prompt | ❌ vendor system prompt is fixed, prepended first | ❌ no vendor switch | n/a |
| Per-turn pre-input injection | ✅ UserPromptSubmit hook runs shell on every turn, output injected as user-prefix | ❌ no equivalent hook | ⚠ partial via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` + a session-scoped file regenerated by an external watcher | MED |
| Persistent persona file | ✅ Output Style file, plus `~/.claude/agents/axon.md` subagent | ⚠ `AGENTS.md` (highest precedence in Copilot CLI), `.github/copilot-instructions.md`, `CLAUDE.md`/`GEMINI.md` slots | ✅ load-balance content across `AGENTS.md` + truncation-aware shim | LOW |
| On-demand persona invocation | ✅ Subagent (`Agent` tool with `subagent_type`) | ❌ no subagent | ⚠ MCP-exposed `axon-persona` tool could simulate this | MED |
| Tool registry visibility | ✅ Bash + Read + Edit + WebSearch + WebFetch + many more, full schemas in system prompt | ⚠ `run_in_terminal`, `apply_diff`, etc. — visible but Authorization-Gated in plan mode | ✅ MCP-exposed AXON tools join the registry as first-class, no auth friction | MED |
| Auto-allowed shell exec | ✅ Bash auto-allowed for read-only; permission prompt only for risky writes | ❌ plan mode asks per-command (default); autopilot mode runs free (opt-in) | ✅ autopilot opt-in + MCP tool exposure for read-only AXON ops | LOW |
| Post-response guard | 🟡 Stop hook available (we don't use it) | ❌ no post-response hook | ❌ no native | n/a |
| Context-pinned files (no compression) | ❌ neither has this | ❌ | ❌ no native | n/a |
| Drift recovery prompt | ✅ in Output Style | ✅ in `.github/copilot-instructions.md` § Drift recovery | ✅ already present | done |
| Top-of-context reminder survival | ✅ UserPromptSubmit output is always the LAST thing before user input → hardest to compress out | ⚠ vendor system prompt prepended first; AXON file prepended after vendor, so AXON survives top-of-context if short enough | ⚠ keep AXON's top-of-file critical content under 4 KB / ~50 lines for survival | LOW |

**Refined asymmetry score:**
- **Claude Code:** 7/10 layers fully covered, 1 partial (post-response: feature exists but unused), 2 not applicable.
- **Copilot (today):** 4/10 layers fully covered, 2 partial.
- **Copilot (achievable with MCP + AGENTS-first + autopilot):** 7/10 layers fully covered, 2 partial.

→ **The platform gap is closeable in 2026.** Sibling `-anchor`'s 2026-05-19 "3/7 vs 5/7" scoring was correct for *that day*, but **predates the MCP CLI support general availability**. MCP changes the math.

#### A4.2 — Symptom → layer mapping

| Symptom | Failing layer | Fix layer |
|---|---|---|
| S1 — Command comprehension | Per-turn pre-input injection (none) + tool registry visibility (AXON commands invisible) | MCP tool exposure + AGENTS-first content reload |
| S2 — Tool-call gap | Auto-allowed shell exec (plan-mode default) + self-contradiction T1 | autopilot opt-in + T1 fix + MCP exposure |
| S3 — Drift across turns | Per-turn pre-input injection (none) + top-of-context survival (truncation T2.2) | shim+AGENTS load-balance + minimal first-50-lines AXON banner |

#### A4.3 — Claude Code mechanism inventory (for completeness)

Files in this repo's Claude Code persistence stack (verified this session):
- `~/.claude/output-styles/axon.md` — present (verified by Step 0 check returning INSTALLED).
- `~/.claude/settings.json` UserPromptSubmit hook — emitting the reminder we saw on every turn ("UserPromptSubmit hook success: [AXON is active]...").
- `~/.claude/agents/axon.md` — subagent definition (referenced by setup-persona.sh).
- `~/.claude/projects/-mnt-c-projects-axon/memory/` — auto-memory store (referenced in this session's context).

The persistence is delivered turn-by-turn, NOT via a single static file. **That's the architectural insight.** AXON's claim "we work on Copilot too" is currently true only in the trivial sense (the files exist); the *architecture* of persistence is missing.

#### A4.4 — Output of phase 1 (consolidated)

| ID | Phase-1 deliverable | Status |
|---|---|---|
| A1 | Codebase audit + 5 tensions T1-T5 | ✓ |
| A2 | Copilot extension points (precedence, truncation, slot config, MCP, agent mode) | ✓ |
| A3 | Tool-calling root cause (3-layer compound bug for S2) | ✓ |
| A4 | Defense-layer matrix + symptom→layer→fix mapping | ✓ |
| - | Hypothesis grading: H1' / H2 / H4 CONFIRMED · H3 REJECTED · new H5-H8 added | ✓ |

**Phase 1 exit condition:** user signs off; project advances to phase 2-design with the H5-H8 / T1-T5 list as the PR backlog source.

## Output of this phase

When all four axes are populated and validated **from inside Copilot itself**
(per `_dont-do.md`), this file is signed off and the project moves to phase 2.

## Open questions

| # | Question | Answered? | Where |
|---|---|---|---|
| Q1 | Same strategy CLI vs IDE? | **Partial** | Different precedence (CLI: AGENTS.md primary; VS Code: `.github/copilot-instructions.md` auto-detected). Slot config is IDE-only. Recommendation: shared core in AGENTS.md, IDE-specific addons in `.github/instructions/*.instructions.md`. |
| Q2 | Copilot equiv of UserPromptSubmit hook? | **No native equivalent** | A4.1. Closest workaround = `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` + external watcher regenerating an instruction file per turn. Heavy. |
| Q3 | Can we make `python3 axon.py …` calls un-skippable via instructions alone? | **No, instructions alone are insufficient** | A3.2 — root cause is 3-layer compound. Instruction-level fixes close T1 (self-contradiction) but not H2 (auth friction) or H4 (truncation). MCP exposure (H6) is the structural fix. |
| Q4 (new) | Does autopilot mode close S2 for AXON's read-only ops? | **Yes, but user opt-in** | A2.5. Requires user to enable autopilot per session; not settable from a file. |
| Q5 (new) | Is MCP server exposure of `axon.py` subcommands feasible? | **Likely yes** | A2.4. MCP is supported in CLI + VS Code; AXON tools are mostly stateless argparse commands → wrap each as an MCP tool. Spike size: small-medium for a 5-tool MVP. |
