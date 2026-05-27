# AXON — The Conformance Layer for AI Agents

> **Professional positioning & pitch** (2026-05-25). Companion to
> `architecture-bones.md` (the engineering substantiation). This is the
> outward-facing narrative — the same product told at four altitudes. Research-
> backed; honest by design (no overclaiming — the proof is that AXON governs
> itself).

---

## The one-liner

**AXON is git + CI for your agent's constitution** — the conformance layer that
keeps a sprawling, multi-host, multi-model set of AI-agent instructions **provably
coherent, drift-checked, and portable.**

*(One-breath intuition, secondary: "an operating layer for AI agents." Use the
metaphor to spark understanding — never as the headline.)*

---

## Why now (the inflection)

Three things became true in 2025–26, at once:

1. **AI coding agents went mainstream** — Claude Code, Cursor, Copilot, Codex,
   Gemini CLI. Every team now runs agents on real work.
2. **Agent behavior is governed by sprawling instruction files** — `CLAUDE.md`,
   `AGENTS.md`, `.cursor/rules`, `GEMINI.md`, skills, prompts — and that corpus
   **drifts silently, contradicts itself across tools, and is unversioned and
   untested.** (`AGENTS.md` is now under the Linux Foundation and read by 7+ tools —
   but Claude Code still won't read it. Multi-host shops are *structurally*
   incoherent.)
3. **Models churn quarterly** — and switching model or host means re-deriving and
   re-validating that whole corpus by hand, or accepting lock-in.

There is no tool that **continuously validates a large agent-instruction system for
internal coherence and re-projects it, conformance-checked, across hosts and
models.** Memory products (Letta) give you state, not integrity. `AGENTS.md` gives
you a shared file, not a validator. That gap is AXON.

---

## The problem AXON solves (the job-to-be-done)

> "I have a growing pile of agent instructions across tools and vendors. I can't
> prove it's consistent, I can't see when it drifts, I can't safely move it to a new
> model, and I can't audit what my agents are actually allowed to do."

AXON makes that corpus a **governed, self-checking system** instead of a pile of
markdown.

---

## What AXON is (plainly)

AXON treats every agent capability as a **typed, registered, gated "program" in a
self-checking graph** — and continuously proves the whole graph is coherent.

- **Typed contract.** Every capability declares a *synapse* (domain / family /
  role). Organization, routing, and discovery are *derived* from the contract, not
  hand-maintained — so growth never outpaces structure.
- **Self-checking.** Drift gates, registry/contract conformance, live-computed
  counts, and a full test suite run before anything merges. Nothing depends on a
  human remembering to update a number.
- **Portable.** One neutral core; per-host *adapters* map it onto Claude Code,
  Cursor, Copilot, or a bare model. Author once; run anywhere; **prove it still
  holds after the move.**
- **Self-governing.** AXON is built and maintained *through its own framework* —
  the self-audit is real and runs on itself.

---

## How it works (credibly — the mechanism, not magic)

| Layer | What it does | How it's enforced |
|---|---|---|
| **Contract** | Each capability declares domain/family/role | Mandatory at registration; drift gate fails without it |
| **Graph** | Capabilities form a typed, self-checking graph | Conformance + drift gates, full suite before merge |
| **Projection** | One source of truth → host/model targets | Generated + **drift-gated** (divergence = fail = auto-correct) |
| **Enforcement** | Invariants live in tools/hooks, not prose | Host hooks (a real syscall gate) where available; deterministic verify→repair elsewhere; behavioral floor as the last tier |

**Honest about limits:** on a hosted model we don't control the decoder, so persona
and free-text behavior are *detected and corrected*, never claimed-prevented. AXON
maximizes the share of guarantees that are *mechanically* enforced and is explicit
about the rest. That honesty is the credibility.

---

## Why it's innovative & defensible (the moat)

- **Cross-host neutrality the labs won't build.** Anthropic has no incentive to keep
  you portable to GPT; AXON's whole reason to exist is that neutrality. The moat is
  *structural*, not feature-deep.
- **A genuinely hard validation engine.** "Keep a large instruction system provably
  coherent + portable" is real, unsolved work — not packaging the hosts replicate
  for free.
- **Proof by self-governance.** AXON audits and develops itself. The demo isn't a
  slide — it's the live system catching its own violations.

**What AXON deliberately is *not* (so it can't be commoditized from below):** not an
agent *framework* (LangGraph/CrewAI/AutoGen/SDKs build agents); not a *memory layer*
(Letta/mem0/Zep); not a skills/hooks/registry *marketplace* (the hosts ship those
now). AXON is the **conformance + portability layer above all of them.**

---

## The same pitch, four altitudes

**Tagline** — *"Keep your AI agents coherent and portable — on any host, any model."*

**Executive / management** — Your agent instructions sprawl across tools and
vendors, drift silently, and lock you in. AXON makes the whole agent layer
versioned, tested, provably coherent, and portable: **fewer agent-caused incidents,
a real audit trail, no vendor lock-in.** Adopt bottom-up (developers), govern
top-down (compliance).

**Engineering** — A type system + CI for agent behavior. Capabilities are typed,
registered, and gated in a self-checking graph; a single source of truth projects,
drift-checked, onto every host. Determinism where the host allows it (hooks as
syscall gates, structured tool-args), a graceful floor where it doesn't. Add a
capability → it auto-registers, auto-gates, auto-organizes.

**Investor** — *Market:* agent infrastructure. *Why now:* coding agents exploded;
instruction sprawl is ungovernable and model lock-in is biting. *Wedge:* the
unserved seam between *frameworks* (build agents) and *hosts* (run agents) — keep
the agent system coherent and model-portable. *Moat:* cross-vendor neutrality the
labs are disincentivized to build + a hard conformance engine + a self-governing
proof point. *GTM:* open-source-led developer adoption → enterprise governance (the
HashiCorp/dbt motion).

---

## The category we're naming

Like Temporal coined **"durable execution,"** AXON names a real, felt pain into a
category: **agent conformance** — *provable coherence, drift-detection, and
portability for AI-agent instruction systems.* We don't ask buyers to learn a new
*name and* a new *category* at once; we anchor on "git/CI for agents" and let the
artifact teach the category.

---

## Proof points to build (show, don't tell)

1. **The cross-host coherence demo** — catch a real conformance violation across two
   hosts; re-project a drift-free instruction set. The killer artifact.
2. **The self-audit, live** — AXON reports its own conformance, coverage, and
   enforcement-tier mix on itself.
3. **Token + fidelity numbers** — measured, not asserted (compression ratio,
   eval-verified instruction-following).
4. **A model-swap, validated** — same agent system, new model, conformance still
   green.
