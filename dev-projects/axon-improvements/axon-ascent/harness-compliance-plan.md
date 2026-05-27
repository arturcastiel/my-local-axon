# Phase 3 — Harness-AGNOSTIC AXON Integration

*Principle: **AXON is the OS; the harness is the hardware.** AXON must run on ANY
host (Claude Code, Copilot, Cursor, Gemini CLI, Aider, …) — the CORE (kernel,
tools, rules, memory, output layer) is **harness-neutral** — AND every host must
**comply with + ENFORCE** AXON's kernel (deny violations), not merely re-anchor a
persona. A thin **harness-adapter** wires each host to enforce AXON as strongly as
its mechanisms allow. The goal is **agnostic + enforcing**: AXON runs anywhere,
and everywhere the harness structurally enforces the kernel — not behavioral trust.*

Status: PLAN (2026-05-25). User: "I want AXON to be harness-agnostic." Way overdue / ASAP.

---

## 1. We already have the seed — formalize it, don't hardwire

`KERNEL-SLIM.md` boot step **G-11** already detects the host and `EXEC`s
`workspace/harness/<harness>.md` (e.g. `claude-code.md` when `CLAUDECODE≡1`).
So AXON is *designed* to be adapter-driven — but today only the persona re-anchor
is wired (Claude Code's UserPromptSubmit hook + output-style), and there's no
formal **adapter contract**, so it isn't portable or enforceable.

**The fix is an abstraction, not Claude-Code plumbing:** define what AXON needs
as harness-NEUTRAL *capabilities*, let each `workspace/harness/<harness>.md`
adapter declare *how* (or that it can't, → fallback).

---

## 2. The Harness-Adapter Contract (the core deliverable)

AXON defines six capabilities it wants from any host. Each adapter manifest
declares, per capability: **supported? via which surface? else fallback.**

| Capability (neutral) | What AXON needs | claude-code | copilot | cursor | gemini-cli | generic fallback |
|---|---|---|---|---|---|---|
| **BOOT** | load kernel+memory at session start | SessionStart hook | `.github/copilot-instructions.md` | `.cursorrules` | `GEMINI.md` | persona prompt (`startup.md`) |
| **REANCHOR** | identity/rules each turn | UserPromptSubmit hook | instructions file | rules file | context file | output discipline |
| **ENFORCE** | block kernel-forbidden tool calls | PreToolUse hook → `enforce.py` | — → self-enforce | — → self-enforce | — → self-enforce | behavioral (self) |
| **LOG/CHECKPOINT** | mechanical session-log + checkpoint | PostToolUse/Stop hooks | — → self | — → self | — → self | behavioral (self) |
| **TOOLS** | call AXON tools without narration | MCP server | MCP (if supported) | MCP | MCP | `Bash`/CLI |
| **BACKSTOP** | always-loaded rules | `CLAUDE.md` | instructions file | `.cursorrules` | `GEMINI.md` | `startup.md` |

The capabilities are written **once** (in the core); adapters only *map* them.

### Enforcement is the goal — and it stays agnostic via the MCP boundary

The point isn't just to *run* AXON anywhere — it's to make every host **enforce**
it. Enforcement has three tiers; each adapter targets the highest the host supports:

- **Tier 1 — full (hook interception):** the host intercepts *every* tool call and
  denies kernel violations (Claude Code `PreToolUse` → `enforce.py`). All tools gated.
- **Tier 2 — MCP boundary (the AGNOSTIC enforcer):** AXON exposes its tools through
  an MCP server that **itself enforces the gates** — so on ANY MCP-capable host,
  every AXON-tool call is denied-or-allowed host-independently. This is the portable
  enforcement layer; the adapter pushes the host to route mutating ops through it.
- **Tier 3 — behavioral (floor only):** the kernel's self-applied gates (today's
  state). A last resort, never the target.

A lean host with no hooks still reaches **Tier 2** simply by speaking MCP — so
"agnostic" does **not** mean "unenforced." The adapter's job is to lift each host
to Tier 1/2 (structural enforcement), never to settle for Tier 3.

---

## 3. Plan

1. **Adapter-contract spec** (harness-neutral). A schema for `workspace/harness/<harness>.md`:
   each declares the 6 capabilities × {supported, surface, fallback}. Plus a
   `harness-detect` step (already G-11) that picks the adapter, and a tiny
   `harness-capabilities` query so the agent/tools know what's mechanically
   enforced vs self-enforced this session.
2. **Reference adapter — claude-code** (the richest host): formalize `claude-code.md`
   to declare all six, backed by the WS1–WS5 wiring below. This is where the
   "make Claude Code comply" work lands — but as a *swappable adapter*, not core.
3. **Stub adapters** — `copilot.md`, `cursor.md`, `gemini-cli.md`, `generic.md` —
   each declaring its surfaces + fallbacks (most ENFORCE/LOG → self). Cheap; proves portability.
4. **Graceful degradation** in the core: when a capability is `fallback`, the kernel
   keeps its behavioral gate (today's behavior). When `supported`, it trusts the host.
5. **Conformance check** (mirrors `registry_drift`/`programs-drift`): every adapter
   manifest declares all six capabilities; the detected adapter loads cleanly.

### Claude-code adapter wiring (capabilities → surfaces), behind the contract
- **BOOT** → `SessionStart` hook injects `boot.py` context (kernel+memory+phase). *HIGH/LOW-risk; do first.*
- **ENFORCE** → `PreToolUse` hook → `enforce.py` (write-gate to `axon/` first; ship `ask` → `deny`). *Highest leverage; most care.*
- **LOG** → `PostToolUse`/`Stop` hooks → `E:session-log` + CHECKPOINT.
- **TOOLS** → MCP server (`tools/mcp_server.py`, on tno/main; reconcile trees, then wire `.mcp.json`).
- **BACKSTOP** → `CLAUDE.md`.

---

## 4. Sequencing (ASAP)
1. **Contract spec + formalize `claude-code.md` + a `generic.md` fallback** — the agnostic foundation; pure docs/schema, no risk. **Do first.**
2. **claude-code BOOT (SessionStart) + BACKSTOP (CLAUDE.md)** — deterministic boot, reversible.
3. **LOG hooks**, then **MCP**, then **ENFORCE (PreToolUse)** — the deny power, phased `ask`→`deny`.
4. **Add copilot/cursor/gemini stub adapters** — proves harness-agnosticism end-to-end.

---

## 5. Risks + safeguards
- **No host specifics in the core** — adapters are the only harness-aware layer; a lint/conformance check enforces this.
- **Modifying my own runtime** (claude-code adapter): per-change isolation, `settings.json` backup, a single **`AXON_HARNESS_OFF` kill-switch** making every hook a no-op, fail-open on hook error.
- **Latency**: hooks fire per action → <1s, no full-audit-in-hook.
- **Privacy**: adapter/memory wiring touches `my-axon` (private) — stays local, never synced to a shareable repo.
- **Tree divergence**: `/mnt/c/projects/axon` (canonical) vs `tno/main` (mcp_server + new gates) — reconcile before host wiring.

---

## 6. Definition of done
AXON runs **the same kernel on any harness**: an adapter manifest per host declaring
the six capabilities; the richest host (Claude Code) **boots deterministically,
denies kernel-forbidden actions, logs mechanically, and calls tools via MCP**;
lean hosts **self-enforce via the same gates**; a kill-switch reverts. The core
imports zero harness specifics — AXON is the OS, the harness is swappable hardware.
