# C1·P4 — Web Research (cycle 1)

> Targeted at gaps surfaced in C1·P3. Topics: prompt caching, agent OS frameworks, symbolic DSL compression, Claude Code primitives.

## A. PROMPT CACHING (token economy — gold mine)

### Headline numbers
- **Up to 90% savings** on cached input tokens (Claude API, OpenAI API).
- Time-to-first-token latency reduction **up to 80%**.
- Real-world: ProjectDiscovery cut LLM costs by **59%** with caching, ramped to **70%** after 10 days.
- Smart context engine layered on top adds **40-60%** more.
- Industry estimate: most teams **squander 40-60% of token budgets**.

### Structural prescription (universal)
Layer prompts in this order to maximize cache hits:
1. **Static content first** — system instructions, persona definitions, few-shot examples (rarely change).
2. **Heavy context second** — large documents loaded for a session.
3. **Dynamic content last** — user query + conversation history (changes every turn, can't be cached).

### Applicability to AXON
- AXON's **boot chain is already mostly static** (KERNEL-SLIM, harness, MYAXON.md). Verify it's first in every prompt sent to the upstream model.
- The **menu render** is mostly static; cacheable.
- **Compiled `.cmp.md` programs** are static between edits — cacheable as second tier.
- **Workspace state** (W: keys) is dynamic — must come last.
- **Action**: audit how the host harness (Claude Code) lays out our prompts; if AXON content is interleaved with conversation history, cache hits are minimal. May need to reshape the boot/preamble injection pattern.

### Cited
- [Prompt caching · Claude API](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Prompt caching · OpenAI API](https://developers.openai.com/api/docs/guides/prompt-caching)
- [Prompt Caching 201 · OpenAI cookbook](https://developers.openai.com/cookbook/examples/prompt_caching_201)
- [How We Cut LLM Costs by 59% With Prompt Caching · ProjectDiscovery](https://projectdiscovery.io/blog/how-we-cut-llm-cost-with-prompt-caching)
- [Token optimization 2026 · Obvious Works](https://www.obviousworks.ch/en/token-optimization-saves-up-to-80-percent-llm-costs/)
- [Prompt Caching and Context Optimization in Coding Agents](https://susheemk.substack.com/p/prompt-caching-and-context-optimization)

---

## B. AGENT FRAMEWORK COMPARISON (positioning)

| Framework | Architecture                                | Strength                       |
|-----------|---------------------------------------------|--------------------------------|
| LangGraph | Graph-based, nodes + edges, conditional routing | Production, checkpointing, audit trails. Best success rate (62% complex, 76% medium) |
| CrewAI    | Role-based (agents w/ goals + backstories)  | Rapid prototyping, YAML config |
| AutoGen   | Multi-agent conversation loop               | Microsoft-backed, message-driven |
| Smolagents| HuggingFace, code-first, direct local LLM   | Easiest entry, research community |

### What AXON does that these don't (apparent moats)
1. **Symbolic kernel-ops cognition layer** — none of the above mandate compressed reasoning. AXON's R11 is unique.
2. **File-as-program model** — programs are markdown; anyone can read/edit. CrewAI/LangGraph require Python.
3. **Boot-time identity contract + harness contract** — explicit. Most frameworks treat persona as a system message.
4. **In-OS phase tracking + interrupt gate** — built-in resumability without manual checkpoints.
5. **Memory scope semantics (W:/L:/E:/local)** — explicit lifetimes; most frameworks lump into "memory" or RAG.

### What they do that AXON might learn from
- **LangGraph's graph state machine** — AXON's program-to-program EXEC chain could benefit from explicit DAG (today implicit via EXEC calls).
- **CrewAI's role/goal abstraction** — AXON has `code-dev`/`library-dev` modes but no explicit "agent role" composition.
- **AutoGen's multi-agent conversation** — maps to AXON's parallel SPAWN; underused today.
- **Smolagents' direct local-LLM** — AXON is harness-agnostic but no native local-LLM story.

### Cited
- [LangGraph vs CrewAI vs AutoGen 2026 · Pooya Golchian](https://pooya.blog/blog/crewai-vs-langgraph-autogen-comparison-2026/)
- [AI Agents in 2026 · DEV Community](https://dev.to/pooyagolchian/ai-agents-in-2026-langgraph-vs-crewai-vs-smolagents-with-real-benchmarks-on-local-llms-4ma1)
- [10 AI Agent Frameworks 2026 · Medium](https://medium.com/@atnoforgenai/10-ai-agent-frameworks-you-should-know-in-2026-langgraph-crewai-autogen-more-2e0be4055556)
- [DataCamp · CrewAI vs LangGraph vs AutoGen](https://www.datacamp.com/tutorial/crewai-vs-langgraph-vs-autogen)

---

## C. SYMBOLIC DSL COMPRESSION (validates AXON's R11)

### ReaComp (arXiv 2605.05485)
> "Compiles LLM reasoning into symbolic solvers ... distills recurring strategies into standalone synthesizers over a constrained DSL ... substantially reduces LLM token usage."

**For AXON**: validates the compiler model. Already on this path. Worth examining the paper's grammar mechanics for `compiler/GRAMMAR.md` improvements (cycle 2).

### MetaGlyph (arXiv 2601.07354)
> "Encodes instructions as mathematical symbols rather than prose ... uses symbols like ⇒ that models already understand from training ... 62-81% token reduction."

**For AXON**: AXON-LANG already does this (→ ⊕ ⊗ ∅ ✓ etc.). MetaGlyph confirms the approach and the magnitude (62-81%) — measurable target for AXON's compression-ratio metric.

### Symbolic Compression Framework (arXiv 2501.18657)
> "Achieves 78.3% token compression in code generation ... improves logical traceability by 62%."

**For AXON**: traceability matters because AXON is auditable (E: log). Token-compression + traceability is exactly AXON's pitch.

### Z-Tokens / RuPLaR (arXiv 2605.09346, 2603.25340)
> "Z-Tokens treated as symbolic interface ... model thinks directly using its own abstract language."

**For AXON**: long-term direction. Could explore "AXON-LANG-as-trained-vocab" via fine-tuning, but out of scope for kernel work.

### Reasoning Path Compression (arXiv 2505.13866)
> "Compresses generation trajectories for efficient LLM reasoning."

**For AXON**: maps to E:session-log compression (T-12 in backlog).

### Cited
- [ReaComp: Compiling LLM Reasoning · arXiv](https://arxiv.org/abs/2605.05485)
- [Semantic Compression of LLM Instructions via Symbolic Metalanguages · arXiv](https://arxiv.org/html/2601.07354v1)
- [Enhancing LLM Efficiency via Symbolic Compression · arXiv](https://arxiv.org/html/2501.18657v1)
- [RuPLaR: Latent Compression of LLM Reasoning Chains · arXiv](https://arxiv.org/html/2605.09346v1)
- [Reasoning Path Compression · arXiv](https://arxiv.org/html/2505.13866v2)

---

## D. CLAUDE CODE PRIMITIVES (for harness optimization)

### The Skills/Subagents/Hooks spectrum
| Primitive | Context isolation | Cost     | Use when                                |
|-----------|-------------------|----------|-----------------------------------------|
| Skill     | Same context      | Low      | Reusable prompt or workflow             |
| Subagent  | Isolated context  | Medium   | Parallel work or context isolation      |
| Hook      | Deterministic shell  | Trivial  | Lifecycle enforcement (no model in loop)|

### Key behaviors
- **Skill descriptions** loaded into context at start; full body only on invoke.
- **Subagents with preloaded skills** inject full skill content at startup.
- **Hooks are deterministic** — no hallucination. Use for enforcement (write-gate, identity-gate).

### Applicability to AXON
- AXON already uses **UserPromptSubmit hook** for persona re-anchor (good).
- AXON's **Output Style** is the persona-as-system-prompt anchor.
- AXON's **subagent (axon)** lets non-AXON sessions spawn AXON for one task — good but underused.
- AXON's **gates** (write-gate, identity-gate) should map to **hooks** to gain deterministic enforcement (they're partially in-model today).
- **Action**: convert R7/R9/R11 gates to a Claude Code Stop hook for deterministic enforcement, especially for write-gate (axon/ writes when dev-mode=false).

### Cited
- [Claude Code: Hooks, Subagents, Skills · ofox.ai](https://ofox.ai/blog/claude-code-hooks-subagents-skills-complete-guide-2026/)
- [Claude Code · Skills, Subagents, Hooks · boringbot.substack.com](https://boringbot.substack.com/p/claude-code-skills-subagents-hooks)
- [Inside Claude Code Architecture · penligent.ai](https://www.penligent.ai/hackinglabs/inside-claude-code-the-architecture-behind-tools-memory-hooks-and-mcp/)
- [Claude Code Skills · Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents, Skills, Hooks: Real Workflows · TechPlained](https://www.techplained.com/claude-code-subagents-skills)
- [Skills, Hooks, Subagents · Medium](https://medium.com/@boredhead/context-skills-hooks-subagents-how-claude-code-actually-works-acdbb7baef6a)
- [Designing CLAUDE.md right (2026) · Obvious Works](https://www.obviousworks.ch/en/designing-claude-md-right-the-2026-architecture-that-finally-makes-claude-code-work/)

---

## E. CROSS-CUTTING TAKEAWAYS

1. **Prompt-caching is the single highest-leverage move** — 59-90% cost reduction across multiple case studies. AXON's static-first structure is naturally cache-friendly; verify host-harness usage.
2. **Symbolic compression is validated empirically** — MetaGlyph + ReaComp show 62-81% token reduction. AXON-LANG is on this path; the open question is *measurable compression ratio* (already in COMPILER.md but underused).
3. **AXON's moat is the cognition layer + boot chain** — no major framework competes here. Lean into it.
4. **Hook-based enforcement** is industry-best practice for deterministic gates — AXON should expose its gates as hook contracts wherever possible.
5. **Subagents are under-utilized in AXON** — Claude Code makes this easy; AXON could route long-running phases (cycle work, library ingestion) to subagents to keep main context clean.

---

## F. NEW IMPROVEMENT ITEMS DERIVED FROM RESEARCH

(extends c1-p3 backlog)

| ID    | Item                                                         | Impact | Effort | Score |
|-------|--------------------------------------------------------------|--------|--------|-------|
| W-01  | Audit prompt structure for cache hits (verify static-first)  | 5      | 2      | 2.5   |
| W-02  | Measure & report compression-ratio per compiled program (target 62%+) | 4 | 2 | 2.0 |
| W-03  | Convert write-gate / identity-gate to deterministic hooks    | 4      | 3      | 1.3   |
| W-04  | Route cycle-style long workflows to subagents (e.g. axon-master cycles) | 3 | 2 | 1.5 |
| W-05  | Document AXON's symbolic compression vs MetaGlyph as positioning material | 2 | 1 | 2.0 |
| W-06  | Explicit DAG annotation per multi-step program (à la LangGraph) | 3 | 4 | 0.75 |
| W-07  | Native local-LLM harness (Smolagents-style)                  | 3      | 5      | 0.6   |

---

## G. FOR CYCLES 2-3

- **Cycle 2** can deepen on the **compiler/GRAMMAR.md** angle — ReaComp shows what a constrained DSL grammar can do.
- **Cycle 3** can run a **measured token-cost baseline** before applying T-01..T-12 + W-01..W-05.
- **Cycle 4** synthesis should weave the empirical compression numbers into the executive summary.
