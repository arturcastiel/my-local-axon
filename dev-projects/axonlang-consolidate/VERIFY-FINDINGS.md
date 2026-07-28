# Quarantined-leads verification (R4) — reconfirm-or-close, 2026-07-13/14
method: 4 parallel read-only deep-search agents, one per run-3 quarantined lead; adversarial
reconfirm against SOURCE + live probe; each → CONFIRMED-BUG / CLOSED / PARTIAL with file:line.

---

## LEAD 2 — hr-team persistence tier + empty events.jsonl · **VERDICT: CONFIRMED-BUG · MEDIUM**
The lead is substantively correct (one phrasing imprecision on --manifest). Two live defects:

**(a) tier persistence is dead at the write point.** hr-team.md:40 loads
`persistence ← RETRIEVE(W:hr-team-persistence) | "full-audit"` in LOAD CONTEXT — BEFORE the
selector runs (EXEC'd at :120). The selector computes a tier-scoped persistence
(selector.md:210-215: micro/low→no-logs, medium/high→decisions-only, xhigh/full→full-audit) but
stores it ONLY inside the result object (:301, :308) — it NEVER STOREs W:hr-team-persistence
(grep: the only STORE of that key is a wiki recipe). So absent a CLI --persistence flag, line 40
falls to the literal "full-audit" EVERY time, and the router's write call (:171) uses that stale
local, never sel.persistence. ASYMMETRY: the convener DOES honor it (convener.md:49 has the
`| selector.persistence |` fallback); the router — the actual write point — omits it.

**(b) events.jsonl is always empty.** Router write (hr-team.md:171) passes only
--call-id/--mode/--verdict/--transcript — NO --events. tools/hr_team.py:624 defaults --events to
"[]" → :809 full-audit branch writes `"\n".join(...)` over [] = a 0-BYTE events.jsonl. The events
ARE emitted (deliberator EMITs seat_responded/aggregation_computed/… :62,74-75,240-241; inits
seat-events←[] :53) but that local is NEVER appended-to or STORE'd to a W: key the router reads.
EMPIRICALLY REPRODUCED: bundle written with decision.md 195B, manifest 91B, transcript 26B,
checksums 317B, events.jsonl = 0 bytes — violating V-checklist.md:263-264 (V-10.5: events.jsonl must
carry seat_invoked/seat_responded/protocol_started/protocol_completed/aggregation_computed), while the
checksums file dutifully certifies the empty log.

**Already-fixed? NO — sibling bug.** Commit 4e5ddca (2026-07-07) fixed write_audit_bundle being
unregistered/unreachable (the "zero persisted audit trail" comment at :168-170) + the vocabulary
mismatch (:778). Neither wired --events NOR made the router honor the tier. This lead is a distinct,
still-live gap the comment does not describe.

**Failure scenario:** `hr-team full --task "…"` no --persistence flag → selector picks micro/no-logs
→ router ignores it (line-40 default = full-audit) → writes a checksummed full-audit bundle whose
events.jsonl is empty, over-persisting private council data the tier said to minimize.

**Fix (one line each):** (a) resolve persistence AFTER the selector in OUTPUT:
`persistence ← RETRIEVE(W:hr-team-persistence) | sel.persistence | "full-audit"` (mirror convener.md:49;
line-40 is too early — sel doesn't exist yet). (b) collect emitted events into W:hr-team-events
(deliberator STORE + convener lifecycle) and pass `--events {RETRIEVE(W:hr-team-events) | '[]'}` at :171.
**Severity MEDIUM** — audit-completeness + data-minimization integrity; not a crash/bypass, but silently
defeats a documented full-audit invariant + renders the tier control inert.
Minor: lead's --manifest claim is wrong (CLI auto-derives a 91B manifest, hr_team.py:639-641); :157→:171.

---

## LEAD 1 — hr_team cwd-relative defaults + fail-closed-gate-crashes · **VERDICT: PARTIAL · MEDIUM**
The three underlying defects are REAL + mechanically confirmed; the terminal "open-catalog takeover" is
NOT reliably reachable in normal (repo-root) operation.
- Side 1 (CONFIRMED contract violation): hr_team.py uses _axon_paths default_workspace/myaxon for
  --workspace/--myaxon (:625,:948-949, cwd-safe) BUT hardcodes RELATIVE literals for catalog/prompts/ledger:
  :331 _CATALOG_DEFAULT="workspace/hr-team/catalog/professions/_REGISTRY.md", :325 --prompts-root,
  :421 --catalog, :572/:604 --ledger-dir="workspace/log/receipts". _axon_paths.py:10-13 explicitly says
  tools must use the constants "instead of relative literals … cwd-independent". Clear internal inconsistency.
- Side 2 (CONFIRMED, reproduced): match_roster→_parse_catalog(:343-356) does Path(catalog).read_text() with
  NO try/except → missing catalog raises uncaught FileNotFoundError (reproduced from /tmp, exit 1). So the
  "fail-closed roster gate" CRASHES rather than returning fail_closed=True.
- Side 3 (CONFIRMED): router hr-team.md:67 `match-roster … | ∅` (no --catalog → relative default), crash→∅→
  stored; selector :101-102 → ∅/[]; :125 `IF det-roster ≠ ∅ AND det-roster.fail_closed ≡ true → LOG(WARN)`
  does NOT fire (guard needs ≠∅); :127-128 ELSE DERIVE(open-catalog optimal-slug-list), no warning.
- REACHABILITY (why PARTIAL): axon.py:95 runs tools with NO cwd= (no os.chdir anywhere) — but the ENTIRE
  .md layer is cwd-relative too and designed for repo-root, so normal ops never crash. Forcing cwd≠root hits
  the selector STEP-4 backstop (:131-140, same relative catalog-root) → REFUSAL: catalog-incomplete →
  selector-result.ok:false → router :122 gates → "council NOT convened" (a fail-safe REFUSAL). The takeover
  needs the Python tool's cwd-resolution and the .md FILE-EXISTS resolution to DIVERGE — runtime-dependent,
  not guaranteed.
- **Severity MED** — latent robustness/contract bug; inert under repo-root; worst straightforward manifestation
  is a refusal (fail-safe-ish).
- **Fix:** resolve catalog/prompts/ledger defaults through _axon_paths (cwd-independent, like --workspace);
  defense-in-depth: _parse_catalog returns {} on missing file (→ fail_closed=True not a raise) + selector treats
  det-roster ≡ ∅ the same as fail_closed so the WARN fires instead of silently opening the catalog.

---

## LEAD 4 — REGISTRY.json descriptive drift · **VERDICT: PARTIAL · LOW**
Drift facts CONFIRMED + UNGATED, but impact LOW (no discovery path consumes purpose/args as a contract).
- Quantified (registry vs live argparse): quality-loop documents 2 of 7 subcommands (omits all 5 ramp-* incl.
  ramp-unlock HUMAN-ONLY); autonomous-mode purpose omits bind/renew (grant-lifecycle, no args field);
  agent-memory purpose ~2 of 8 subcommands; shadow args 7 of 9 (omits header/coverage). retrieval-trace purpose
  implies a `capture` subcommand that doesn't exist (only replay/dump-case). DEPRECATED token 0/189 (data
  absence, not a code gap — registry_drift + synapse handle it).
- Design tempering: only 19 of 189 tools carry an `args` field (optional best-effort hint, not a contract);
  purpose is a one-line summary.
- IMPACT (why LOW): boot.py list_tools() returns NAMES ONLY (the primary discovery path never surfaces
  purpose/args); mcp_server exposes purpose as the MCP description BUT its SAFE_TOOLS allowlist excludes all 4
  drifted tools + never surfaces args; synapse_suggest uses purpose only as TF-IDF ranking bag-of-words (default
  corpus is programs, the tools-registry is a degraded-fallback) → mild ranking degradation, not a false
  capability claim; docgen = docs only. NO authoritative path treats purpose/args as a contract; the real
  contract is --help (which program_tool_conformance enforces for call-sites).
- GATED? NO — registry_drift.py checks script/status/category only, never purpose/args; no test validates them.
- **Severity LOW.** Fix (low-effort/high-value): add a purpose/args accuracy check to registry_drift.py reusing
  program_tool_conformance's --help-probe (WARN when documented subcommands ⊊ real ones) + correct the 4 strings.

---

## LEAD 3 — agent_memory.py (3 sub-claims) · **VERDICT: 2 CONFIRMED-BUG + 1 doc-defect**

### 3a — capture(source='decision') writes GENERAL not "episodic" · PARTIAL doc-defect · LOW
There is NO 'episodic' tier in agent_memory (TIERS=general/project/program; the E: episodic store is a
DIFFERENT subsystem). capture('decision') correctly writes general per its own docstring (:390-396). The
only "episodic" claim is a STALE/aspirational comment in recall() :249-250 describing wiring that DOESN'T
EXIST (recall calls retrieval_trace.capture, never agent_memory.capture). DOC wrong, CODE self-consistent.
Footgun: an agent trusting the comment pollutes the boot-loaded general tier. Fix: delete/correct the comment.

### 3b — binding-liveness checks only workspace/programs/ · **CONFIRMED-BUG · MEDIUM (latent)**
_binding_alive (:189): `program:` → exists(join(workspace,"programs",f"{value}.md")) — ONLY workspace/programs/.
The 29 built-in programs live in axon/programs/ (ZERO overlap, verified via comm) + private in my-axon/programs/.
So program:mode-run / program:identity / program:badmem → missing workspace/programs/X.md → _binding_alive False
→ entry_alive False. Consequences: silent exclusion from recall (ALWAYS-ON, ungated :228) + destructive
quarantine by gc (os.replace :342) when gc on. LATENT: no on-disk `program:` binding victim exists today, and
no code path produces program: bindings — but it bites the instant anyone binds a memory to a core/private
program. Fix: check axon/programs/ + my-axon/programs/ too (mirror the program-resolution used elsewhere).

### 3c — _read_gate is a 9th divergent L: parser on gc's DESTRUCTIVE path · **CONFIRMED-BUG · HIGH-consequence / LOW-likelihood**
_read_gate (:286-298) scans EVERY line for `value:` and returns the last-ish match. The canonical
_longterm.read_longterm_value (:27-30) checks ONLY the first line, and _longterm.py:23-26 documents THIS EXACT
hazard: "Scanning every line would let a 'value:' line buried inside a multi-line value hijack the read … e.g.
'false\nvalue: true' read as 'true', flipping dev-mode/halt-mode." agent_memory does NOT import _longterm — it
hand-rolls a divergent parser reintroducing the precise bug the canonical reader exists to fix. It guards the
DESTRUCTIVE gate: gc() :326 `enabled = _read_gate(workspace,"memory-gc-enabled",False)` → :331-349 os.replace
orphans. Failure: a multi-line `L:memory-gc-enabled` whose first-line value is false but a later line reads
`value: true` flips gc from default-OFF to ON → destructive quarantine (compounding with 3b's false orphans).
Trigger needs corrupted multi-line content (canonical writer emits bare values), so LOW likelihood — but a
divergent parser on the safety gate of a destructive op is the worst place for one. **Fix: import + use
_longterm.read_longterm_value; delete the hand-rolled scanner.** Cheapest fix, highest consequence-reduction.

Ranking: 3b most REAL (always-on, ungated, natural trigger) · 3c most DANGEROUS in principle (destructive gate) · 3a least (doc).

---

# ═══ CONSOLIDATED TALLY (R4 verification) ═══
Of the 4 quarantined run-3 leads → 6 sub-findings:
- **CONFIRMED real bugs: 3** — hr-team persistence/events (MED, reproduced) · agent_memory binding-liveness
  (MED, latent) · agent_memory _read_gate on gc (HIGH-consequence/LOW-likelihood, destructive gate).
- **PARTIAL (real defect, bounded impact): 2** — hr_team cwd relative defaults (MED latent; takeover unreachable) ·
  REGISTRY descriptive drift (LOW, ungated, no discovery path consumes it as a contract).
- **Doc-defect: 1** — agent_memory recall() stale "episodic" comment (LOW).
The quarantine paid off: 3 genuine bugs that a single pass would have dropped.

## RECOMMENDED FIX ORDER (yield-per-effort)
1. **3c** — swap _read_gate to the canonical _longterm reader (removes a documented hazard from a DESTRUCTIVE gate; ~5 lines).
2. **3b** — widen binding-liveness to axon/programs/ + my-axon/programs/ (always-on silent exclusion; ~3 lines).
3. **2**  — hr-team: honor selector tier persistence + wire --events (reproduced empty audit log; .md, 2 edits).
4. **1**  — hr_team: _axon_paths the catalog/prompts/ledger defaults + fail-closed _parse_catalog (contract; latent).
5. **4**  — registry: add a purpose/args accuracy WARN to registry_drift + correct the 4 strings (LOW).
6. **3a** — delete/correct the stale recall() comment (LOW).
Non-kernel, all inside the autonomous envelope. None touch the kernel floor.
