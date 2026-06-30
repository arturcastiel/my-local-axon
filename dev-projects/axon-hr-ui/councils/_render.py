#!/usr/bin/env python3
"""Render hr-team council results → audit JSONs + study + masterplan. Deterministic transform."""
import json, os

OUT = "/tmp/claude-1000/-mnt-c-Users-castielreisdesouzaa/9ab8dd48-061a-4643-afc5-a2354d8e4a50/tasks/wcimclt23.output"
ROOT = "/home/arturcastiel/projects/new-axon/axon/my-axon/dev-projects/axon-hr-ui"
COUNCILS = f"{ROOT}/councils"
DATE = "2026-06-22"

d = json.load(open(OUT))["result"]
councils = {c["key"]: c for c in d["councils"]}
plan = d["consolidation"]["plan"]

def cell(s):  # table-safe
    return str(s or "").replace("|", "/").replace("\n", " ").strip()

# ---- 1. audit JSONs ----
json.dump(d, open(f"{COUNCILS}/_result-full.json", "w"), indent=2, ensure_ascii=False)
for k, c in councils.items():
    json.dump(c, open(f"{COUNCILS}/verdict-{k}.json", "w"), indent=2, ensure_ascii=False)
json.dump(plan, open(f"{COUNCILS}/plan-D.json", "w"), indent=2, ensure_ascii=False)

# ---- 2. masterplan.md ----
PHASE_ORDER = ["quick-wins", "foundation", "ui-overhaul", "workflow-overhaul", "later", "other"]
def pkey(p):
    p = (p or "other").strip().lower()
    return PHASE_ORDER.index(p) if p in PHASE_ORDER else len(PHASE_ORDER)

inits = sorted(plan.get("initiatives", []), key=lambda i: (pkey(i.get("phase")), i.get("rank", 999)))
groups = {}
for i in inits:
    groups.setdefault((i.get("phase") or "other").strip().lower(), []).append(i)

m = []
m.append("# Masterplan — AXON HR UI")
m.append("> Source: 4-council hr-team advisory run (deep tier) · 2026-06-22 · **advisory_only**")
m.append("> Councils: A discovery · B UI ideation · C user perspectives · D consolidation (70 seat-agents, 3 rounds adversarial/debate)")
m.append("> Raw verdicts: `councils/verdict-A.json` · `verdict-B.json` · `verdict-C.json` · `plan-D.json` · `_result-full.json`")
m.append("")
m.append("## Executive summary")
m.append(plan.get("executive_summary", "").strip())
m.append("")
m.append(f"## Initiatives ({len(inits)}) — ranked, grouped by rollout phase")
m.append("")
m.append("| # | Initiative | Area | Impact | Effort | Phase | Sources |")
m.append("|---|-----------|------|--------|--------|-------|---------|")
for i in inits:
    m.append(f"| {i.get('rank','?')} | {cell(i.get('title'))} | {cell(i.get('area'))} | {cell(i.get('impact'))} | {cell(i.get('effort'))} | {cell(i.get('phase'))} | {cell(', '.join(i.get('sources',[])))} |")
m.append("")
m.append("## Initiative detail (by phase)")
for ph in PHASE_ORDER:
    if ph not in groups: continue
    m.append("")
    m.append(f"### {ph}")
    for i in groups[ph]:
        m.append("")
        m.append(f"**#{i.get('rank','?')} · {i.get('title')}**  ·  _{i.get('area')} · impact {i.get('impact')} · effort {i.get('effort')} · sources: {', '.join(i.get('sources',[]))}_")
        m.append(f"- **Problem:** {i.get('problem','').strip()}")
        m.append(f"- **Proposal:** {i.get('proposal','').strip()}")
m.append("")
m.append("## Sequencing (recommended rollout)")
for n, s in enumerate(plan.get("sequencing", []), 1):
    m.append(f"{n}. {str(s).strip()}")
m.append("")
m.append("## Risks")
for r in plan.get("risks", []):
    m.append(f"- {str(r).strip()}")
m.append("")
m.append("## Dissent (preserved — minority positions, never suppressed)")
for x in plan.get("dissent", []):
    m.append(f"- {str(x).strip()}")
m.append("")
m.append("---")
m.append(f"**advisory_only: {plan.get('advisory_only')}** — no recommendation has decision-making force. The owner decides what to action.")
m.append("Next: `code-dev plan` to turn chosen initiatives into PR specs · `code-dev study` is populated at phases/study/01-study.md")
open(f"{ROOT}/masterplan.md", "w").write("\n".join(m) + "\n")

# ---- 3. phases/study/01-study.md ----
def render_council(s, c, charge):
    v = c["verdict"]
    out = []
    out.append(f"## Council {c['key']} — {c['title'].split('· ')[-1]}")
    out.append(f"_{charge}_")
    out.append("")
    out.append(f"**Summary.** {v.get('summary','').strip()}")
    out.append("")
    out.append("**Verdict distribution** (dissent-preserving):")
    for p in v.get("verdict_distribution", []):
        out.append(f"- `{p.get('share')}` — {p.get('position','').strip()}  ·  seats: {', '.join(p.get('seats',[]))}")
    out.append("")
    out.append(f"**Ranked findings ({len(v.get('ranked_findings',[]))}):**")
    for f in v.get("ranked_findings", []):
        out.append("")
        out.append(f"- **{c['key']}#{f.get('rank','?')} · {f.get('title')}**  _[{f.get('area')} · {f.get('severity')}]_")
        out.append(f"    - Rationale: {str(f.get('rationale','')).strip()}")
        out.append(f"    - Proposal: {str(f.get('proposal','')).strip()}")
        out.append(f"    - Support: {str(f.get('support','')).strip()}")
    out.append("")
    out.append("**Dissent (preserved):**")
    for x in v.get("dissent", []):
        out.append(f"- {str(x).strip()}")
    out.append("")
    return out

CHARGES = {
 "A": "Where are code-dev + workflows weak, over-engineered, or under-built? (7 seats × 3 rounds · adversarial)",
 "B": "Concrete UI/UX ideas for the AXON terminal shell. (6 seats × 2 rounds · debate)",
 "C": "How real users — novice→power — experience AXON. (6 seats × 2 rounds · debate)",
}
s = []
s.append("# Study — axon-hr-ui")
s.append("> Discovery synthesis from hr-team councils A / B / C · 2026-06-22 · **advisory_only**")
s.append("> Consolidated, prioritized plan → `../../masterplan.md`")
s.append("> Grounding context the councils critiqued → `../../councils/_context.md`")
s.append("")
s.append("This study captures the raw council findings. The owner-facing plan lives in masterplan.md.")
s.append("Everything here is advisory — no recommendation has decision-making force.")
s.append("")
for k in ["A", "B", "C"]:
    s += render_council(s, councils[k], CHARGES[k])
    s.append("---")
    s.append("")
s.append("## → Consolidation")
s.append("Council D synthesized the above into 15 ranked initiatives. See `../../masterplan.md`.")
open(f"{ROOT}/phases/study/01-study.md", "w").write("\n".join(s) + "\n")

# ---- 4. digest to stdout ----
print("WROTE:")
print(" ", f"{ROOT}/masterplan.md")
print(" ", f"{ROOT}/phases/study/01-study.md")
print(" ", f"{COUNCILS}/verdict-A.json verdict-B.json verdict-C.json plan-D.json _result-full.json")
print()
print("=== EXEC SUMMARY (D) ===")
print(plan.get("executive_summary", "").strip())
print()
print(f"=== {len(inits)} INITIATIVES ===")
for i in inits:
    print(f"  #{i.get('rank')} [{i.get('phase')}] {i.get('title')}  ({i.get('area')} · impact {i.get('impact')} · effort {i.get('effort')} · src {','.join(i.get('sources',[]))})")
print()
print("=== SEQUENCING ===")
for n, x in enumerate(plan.get("sequencing", []), 1):
    print(f"  {n}. {x}")
print()
print("=== RISKS ===")
for r in plan.get("risks", []):
    print(f"  - {r}")
