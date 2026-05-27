# Study — Reservoir-Eng (phase 1)

> Goal: how to leverage AXON's workflow machinery to build a new set of
> programs for petroleum reservoir engineers, derived from
> /home/arturcastiel/projects/Claude-for-reservoir-engineering.
> Method: layered study (domain → tasks → workflows → AXON mapping →
> connection architecture). Companion docs: `_domain-taxonomy.md`,
> `_workflow-designs.md`, `_new-programs.md`, `_open-questions.md`.

## 1. What the source actually is
A Claude Code *course* (9 numbered modules) that teaches CC best-practices —
explore→plan→code→verify, specific-context, tests-as-spec, CLAUDE.md memory,
skills, subagent review, CLI QA, MCP/pyResToolbox, parallel fan-out — THROUGH
reservoir-engineering tasks (production QA, water-cut, PVT units, DCA/EUR,
material balance, nodal, rel-perm, sim tables, sensitivity).

The course's real thesis is NOT "AI does engineering" — it's **disciplined
direction**: supply units, constrain assumptions, prefer proven tools
(pyResToolbox) over invented formulas, and verify with tests + sanity checks.
That discipline is exactly what AXON's kernel already enforces structurally —
so AXON is an unusually good fit for this domain.

## 2. The central finding — assets map 1:1 onto AXON primitives
The course ships Claude assets that each have a direct AXON counterpart:
- a domain **skill** → AXON **programs** (markdown programs ARE skills)
- a **reviewer subagent** → an AXON **response-gate** + review program
- **CLAUDE.md** domain rules → AXON **preferences + L: keys + a domain gate**
- **pyResToolbox via MCP** → a new AXON **mcp_client tool**
- **parallel fan-out** → AXON **workflow + orchestrator + SPAWN** (already exist)
- **explore→plan→code→verify** → AXON **code-dev lifecycle + simulate** (already exist)

So most of the "machinery" already exists in AXON. The reservoir project is
mostly (a) authoring domain programs, (b) adding ONE new connection type
(MCP egress), and (c) adding a domain discipline gate. Full map in `_new-programs.md`.

## 3. The pivotal dependency — MCP egress
pyResToolbox's real value is surfaced through **pyrestoolbox-mcp (108 tools)**.
AXON has **no MCP client** today (this is axons-audit lever #1). So to "use the
machinery" for live correlations, AXON needs `tools/mcp_client.py` first — OR a
direct `pyrestoolbox` import bridge. This is a genuine architectural decision
(see _open-questions A1) and it is SHARED with the axon-ascent project. Building
it here closes two backlogs at once.

This is also the cleanest answer to your "do we need to connect differently?"
question: **yes — AXON needs a new outbound connection type (MCP egress).** It
has only ever had internal tools; pyrestoolbox-mcp would be its first external
tool server.

## 4. Workflows to carve out (the "break into specific workflows" ask)
Three first-class workflows, each proving a different machinery capability
(full DAGs in `_workflow-designs.md`):
- **WF-1 reservoir-screening** (Fixed): production QA → water-cut → DCA fit →
  EUR → review-gate. The simplest complete end-to-end; best first build.
- **WF-2 reservoir-pvt-table** (Fixed, convergent): recommend → oil+gas PVT →
  harmonize → black-oil table → review. Proves provenance + param-pitfall guard.
- **WF-3 reservoir-sensitivity** (Adaptive/Hybrid): fan independent cases
  (pb×Z×skin) → per-case MCP calc → aggregate-without-averaging → review.
  This is the headline test of the fan-out machinery (orchestrator + SPAWN).

## 5. Do we need new programs? (your direct question)
Yes — a `reservoir-*` family (~9 programs: dispatcher, qa, pvt, dca, matbal,
nodal, relperm, sensitivity, review) + 1 new tool (mcp_client) + 1 prefs file
+ 1 domain gate + 3 workflow YAMLs. But the EXECUTION machinery (workflow
engine, orchestrator, fan-out, simulate, test discipline, code-dev lifecycle)
is REUSED, not rebuilt. Net-new surface is the domain layer + the MCP egress,
not the engine. Catalog + reuse-map: `_new-programs.md`.

## 6. Layered conclusion
- **L1 domain**: 12 calculation families, ~108 MCP tools available.
- **L2 tasks**: 9 course tasks; modules 1-3 hand-roll (teaching), 5/8/9 defer to tools.
- **L3 workflows**: 10 canonical RE workflows; 3 chosen for v1.
- **L4 AXON mapping**: assets→primitives is 1:1; mostly authoring + reuse.
- **L5 connection**: ONE new wiring type (MCP egress) + a domain gate + fan-out reuse.

## 7. Risks / discipline carried from the course
- Unit/correlation mistakes are the #1 failure mode → the domain gate must
  enforce the output-standard (inputs/units/method/result/sanity/assumptions).
- "Prefer proven tools" → programs should call MCP/pyResToolbox, not hand-roll
  correlations (except deliberate teaching cases).
- Sensitivity aggregation must NOT average unlike methods → hard constraint in WF-3.
- Sample data is fictional/educational → decide decision-grade vs demo (Q B4).

## 8. Status + next
Study is broad and, I believe, more-than-satisfactory for setting a goal.
Remaining is a set of DECISIONS only you can make — captured in
`_open-questions.md` (architecture, scope, fidelity, endgame). My current lean
is in that doc's section D. Once you answer, I'll set the plan-phase goal and
move `reservoir-eng` from study → plan.
