# Prior-work cross-reference — AXON Polish

> Run after Phase 1-audit completed (2026-05-21). Surveyed 14 prior AXON-themed projects
> in my-axon. All prior projects target prod `/mnt/c/projects/axon` (v1.1.4);
> axon-polish targets the dev tree `/home/arturcastiel/projects/axon-development/axon` (v3.7.0).
> Some prior work was rolled into v3.7.0; some was not. This file maps both.

## Prior projects surveyed

| Project | Status | Phase | Relevant scope |
|---|---|---|---|
| axon-synapse | done (2026-05-18) | 3-implement | BUILT v3.7.0 headline (orchestrator + ranker + DAG + workflows) |
| axon-master | active | 2-plan-complete-v5-detailed | 54-PR umbrella plan; nothing implemented |
| axon-cleanup | active (effectively closed) | 3-implement | Wave 0-3 shipped; CI + bulk autopatch (126 programs) + deps cleanup + autonomous deletes |
| axon-tests | active | 5-enforce | 21 PRs (PR-001..021); rule-tests + workflow-e2e + co-output discipline |
| axon-autoimprove | CLOSED-EXCEPT-PR-211 | closed | Loop-receipt substrate + 4 auto-actors migrated + drift fail-closed |
| axon-coherence-v2 | proposed | 0-seed | Static-lint framework (FA-22 + FA-23) |
| axon-ranker-v2 | proposed | 0-seed | Closed-loop ranker controller (cap/floor/decay) |
| axon-claude-code-consistency | active | 2-design | PR-CD-201 merged: persona binding table + identity-gate dispatch |
| axon-copilot-consistency | active | 2-design | PR-CC-201 merged: T1 fix + binding table; CC-204..209 queued |
| axon-copilot-anchor | active | 2-design | `axon-reanchor` dual-mode + drift codes D-1..D-7 |
| axon-wiring-gaps | active | 1-design | Memory-key audit method (reader/writer join over W:/L:) |
| axon-user | active | 0-init | 5-persona × 15-workflow corpus + friction-scoring rubric (19 findings filed) |
| axon-docs | done (2026-05-17) | 4-closed | Full AXON OS doc set authored |
| firing-dag-missing | proposed | 1-study | DAG-skip path enumeration (un-executed) |
| copilot-deviation-study | active | 1-design | Forensic study of harness DRIFT-INCIDENT |

---

## Cross-reference matrix — 10 systemic pain points × prior projects

Legend: ✓ shipped · ◐ designed-not-built · ○ studied-only · ✗ unaddressed · ⚠ conflict

| # | Pain point | synapse | master | cleanup | tests | autoimprove | coh-v2 | rank-v2 | cd-cc | co-cc | wiring | user |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | PR-111 composition broken | ◐ shipped both as siblings | ✗ | ✗ | ✗ | ✗ (substrate ✓) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| 2 | 5/12 Core Rules have enforcers | ✓ shadow gates G2-G5 | ◐ PR-4/10/11/22 | ✗ | ✓ PR-007/009 | ✓ R9 chokepoint | ✗ | ✗ | ✓ PR-CD-201 | ✓ PR-CC-201 | ✗ | ✗ |
| 3 | TOOL(shell) gate evasion | ✗ | ○ F-06 backlog | ⚠ PR-120 codified evasion | ✗ | ✗ | ◐ static-lint slot | ✗ | ✗ | ✗ | ✗ | ✗ |
| 4 | Catalog rot ~30% | ◐ PR-117 alias canonicalization | ◐ rename waves PR-26/27/28 | ✓ Wave 1: 126 autopatched + 4 stubs + dep cleanup | ✗ | ◐ PR-401 archive cooldown | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| 5 | No real interrupt/resume | ◐ shipped FL-09 deviation class | ◐ PR-9 _session.md + PR-15 compaction banner | ✓ PR-105 PID fix only | ✗ | ✓ recover() reaps BEGUNs | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| 6 | Context-pressure miscalibrated | ✗ | ◐ W3-01/W3-03 (cache_control + ai-tokenizer) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ◐ truncation invariants | ✗ | ✗ |
| 7 | menu/help duplicated | ✗ | ○ TOP-12 F-07 lazy-load | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ◐ F-016 in user findings |
| 8 | Name overlap | ◐ PR-117 (one cluster) | ◐ rename waves | ◐ alias-via-comment | ✗ | ✗ | ◐ R_PROGRAM_NAME_UNIQUE slot | ✗ | ◐ binding table pattern | ◐ binding table pattern | ✗ | ◐ F-012 in user findings |
| 9 | Promise/Impl gap (explain/simulate/modes) | ◐ workflow-simulate shipped | ◐ PR-8/16 mode taxonomy | ⚠ stubs ARE the implementation | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ◐ explain/simulate target wiring | ◐ F-001..F-019 |
| 10 | FAIL block ignored by 94 programs | ✗ | ◐ PR-7 failure-mode catalog | ⚠ autopatch's 6 canonical pieces OMIT FAIL | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

## Active conflicts surfaced (need explicit user decision)

### Conflict #1 — TOOL(shell) gate (pain point #3)
- **axon-cleanup PR-120** registered `shell` as `OPTIONAL, category=host, script=tools/shell.py` with **no implementation file**, citing "no new tools" constraint. The audit was patched (`OPTIONAL host-dispatched → INFO not WARN`) to suppress the surfacing.
- **axon-master study finding 3.A** named "96 unregistered shell calls — First-class shell tool (F-06)" — intent was opposite of what cleanup shipped.
- **axon-polish finding F-D8-008** classifies the current state as gate evasion.
- **Decision needed**: keep host-dispatched (cleanup's path; document the security model) OR implement sandboxed `tools/shell.py` with allowlist (master's intent) OR split into specific tools (`git-info`, `fs-list`, etc.). Each has different cost and security profile.

### Conflict #2 — FAIL block standard (pain point #10)
- **Kernel mandates** `Problem / Cause / Fix / Suggested next` block per FAIL.
- **axon-cleanup `scripts/autopatch_programs.py`** ships 126 programs with 6 canonical pieces — banner + DONE + OUTPUT — but **NOT the FAIL block**. The autopatched programs pass lint without FAIL.
- **axon-polish F-D2-001 / F-D2-007** identify 94 programs (subset/overlap with the 126) ignoring the standard.
- **Decision needed**: extend the canonical-pieces list to mandate FAIL block + bulk re-autopatch (medium cost) OR accept the current divergence (cheap but kernel-doc-rot).

### Conflict #3 — Catalog rot policy (pain point #4)
- **axon-cleanup** adopted **deprecate-via-comment** (`# deprecated (axon-cleanup PR-142): TOOL(semantic-search)`) — kept in source, audited skip-comment-lines.
- **axon-polish** found 9 alias-stubs + 6 DEPRECATED files + 3 orphan-stubs still shipping after that policy adopted.
- **axon-master rename waves PR-26/27/28** would have removed many of these but were never executed.
- **Decision needed**: trust the comment-based deprecation forever, OR commit to a hard-delete sweep gated on dev-mode + user authorization (master's intent).

---

## Findings to retire from axon-polish queue (already done elsewhere)

| Finding | Resolved by | Status |
|---|---|---|
| D-D8-018 identity behavioral test | axon-tests PR-007 (`tests/test_identity_gate.py`) | ✓ shipped |
| D-D8-019 R9 bypass tests | axon-tests PR-009 (`tests/test_rules/test_r9_axon_write.py`) | ✓ shipped |
| D-D8-020 override message format | axon-tests PR-007 banned-subject-form cases | ◐ partial (one extra case needed for exact wording) |
| D-D9-003 heavy-workflow stress fixture | axon-tests PR-013/014 e2e workflow tests + DEV-001 structural pattern | ◐ pattern shipped; structural form replaced spec'd `workflow_test.py` |

## Findings to route to specialized projects

| Finding | Route to | Why |
|---|---|---|
| F-D1-004 (`explain X`/`simulate X` no dispatcher wiring) | axon-wiring-gaps | Same "5-readers, 0-writers" pattern; project owns the audit method |
| F-D5-005 (synapse metadata 96% auto-inferred and wrong) | axon-wiring-gaps | Provenance column extension of the audit |
| F-D6-009 (igap log empty) | axon-autoimprove substrate + caller wiring | Substrate landed PR-AUTO-204; missing caller-side wiring R11→igap.append |
| F-D6-010 (igap not wired to drift) | axon-autoimprove + drift recompute | Feedback-loop wiring: drift should read E:igap-log |
| All D1 usability findings (menu volume, mode overlap, quickstart contradictions) | axon-user | Persona-driven friction discovery already shipped: 5 personas × 15 workflows × file:line citations |

## Patterns to adopt (verbatim from prior projects)

### From axon-synapse
- **9-section PR spec template** at `phases/N/03-prs/pr-NNN.md` (Depends-on, Blocks, Wave, Reversibility, Domain, dev-mode-required, Risk, Status, Goal {Statement/Acceptance/Rejection}, Linked-finding, Linked-demand, Linked-ADR, Files-changed, Rollback, Audit-trail)
- **`_flaws.md` lifecycle**: 🟥 open → 🟧 spec-fixed → 🟨 impl-fixed → 🟩 closed → ⬛ wontfix
- **Fixture-driven loop testing** via frozen session.json files
- **AUDIT.md self-audit pattern** post-close (severity ✅/🟡/🟠/🔴/❗)
- **glossary frontmatter** on every spec

### From axon-master
- **`_meta.md INVARIANTS` block** (5 invariants enforced by `_check-all.sh`)
- **9-section PR schema** + 3-section version-bump schema
- **F-* failure-mode codes** (Class A-E)
- **Wave gates with MUST/NICE split**
- **"AGENT writes, HUMAN runs" convention** per Core Rule 3
- **Replan trigger** (HALT-and-revise on MUST-fail / new failure mode / token forecast > budget × 1.5)

### From axon-cleanup
- **L1→L2→L3 study layers** (Surface → Root-cause → Solution shapes with blast-radius)
- **`02-deviations.md` ledger** per PR (spec vs reality vs shipped vs verified vs tech-debt-surfaced)
- **"Guarded by" co-output rule** (every behavior ships with an AXON-DOCS-*.md row naming the test)
- **Scale-finding escalation** (any factor-of-N estimate divergence pauses for re-auth)
- **`scripts/autopatch_programs.py` idempotent + marked** (`autogen-stub` token)
- **deprecate-via-comment** (`# deprecated (axon-XXX PR-NNN):`)

### From axon-tests
- **"Agent does not run tests"** invariant
- **"Test PR → doc PR → enforce PR"** triple cadence
- **`test_rules_meta.py`** convention (every rule has matching test, all `rule_id` covered, all rules declare phase/severity)
- **`tests/test_rules/`** + **`tests/test_workflows/`** + **`tests/test_smoke.py`** structure

### From axon-autoimprove
- **Closed-loop discipline** (record metric at decision time + re-read next tick + auto-revert + 3-strikes pause)
- **Two-phase receipt** for every state-mutating write (`pending` → `applied`/`failed`)
- **Closed-set vocabularies** (7 intents · 4 target_kinds · 5 triggers — no extension during build)
- **Opt-in HARD** + idle-gap > 7d retrigger
- **`monkeypatch.setattr` over `importlib.reload`** for test isolation
- **`loop_receipt.py` substrate** for any new auto-actor

### From axon-claude-code-consistency / axon-copilot-consistency
- **Op→CLI binding table** at top of persona contract
- **Identity-gate dispatch rule** in heredoc
- **9-probe corpus** (P-1..P-9 with rubric) for behavioral measurement
- **Reproduce-in-both** discipline as hard constraint
- **Truncation-safe invariants** (≤160 lines / ≤6000 bytes for contract files)

### From axon-wiring-gaps
- **Reader/writer join over W:/L: ops** as canonical detection method
- **Three-way triage**: wire upstream / delete reader / guard reader with FAIL
- **"Loud FAIL beats silent ∅"** principle

### From axon-user
- **5-persona corpus** (P1-novice / P2-speedrun / P3-careful / P4-recovery / P5-meta) verbatim
- **Friction-scoring rubric** via patience-budget + turns-spent
- **Every finding cites file:line + proposed edit** (vague rejected)
- **Exit criteria pattern** (S1 → 0, S2 ↓50%, cheatsheet passes novice unaided)

---

## Net effect on axon-polish

**Before cross-ref**: 137 flaws + 48 demands, 22 BLOCKER, plan-readiness A-. Three findings (#1, #3, #8) graded B because of open design decisions.

**After cross-ref**:
- ~6 demands retire (axon-tests already shipped)
- ~5 findings route to specialized projects (axon-wiring-gaps, axon-autoimprove, axon-user)
- ~3 findings downgrade to "track-only" (axon-cleanup / axon-master handle them)
- 3 weak findings upgrade because:
  - #1: substrate available (loop_receipt) even though boundary decision remains open
  - #3: prior conflict IS the design landscape (3 named options with cost/security trade-offs)
  - #8: 3-component design template emerges (binding-table + static-lint slot + comment-based deprecation)
- 3 active conflicts surface for explicit user decision (shell.py, FAIL canonical, deprecate policy)
- ~7 pattern groups adopt verbatim — no re-design needed

**New plan-readiness grade**: **A** (was A-). Remaining design-open count: 1 (workflow-run↔orchestrator boundary, even with substrate available). Two conflicts (shell.py, FAIL canonical) and one policy (deprecate hard-delete) need user decision before Phase 3-design.

## Recommended Phase 2-prioritise structure
1. **Surface the 3 conflicts to user** — get decisions before ranking.
2. **Retire the 6 already-shipped demands** — annotate _demands.md.
3. **Route the 5 specialized findings** — annotate + cross-link in _flaws.md.
4. **Adopt patterns verbatim** — write a `_patterns.md` referencing prior projects.
5. **Then rank remaining findings** — by impact × difficulty as before, with prior-work cost reductions factored in.
