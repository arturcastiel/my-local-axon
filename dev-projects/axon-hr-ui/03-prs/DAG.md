<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-hr-ui

- schema-version: `v1`
- generated:      `2026-06-23T12:05:24Z`
- generator:      `code-dev sync (AXON dev instance) — reconciled to BUILD-STATE.md + git origin/main f9c90f1 + GAPFIND.json + this session's commits`
- nodes:          31
- edges:          18
- critical-path:  PR-001 → PR-008 → PR-018 → PR-019 → PR-008b

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | phase_model add subcommand — fix phase-registry split-brain | phase_model add | merged |
| PR-004 | pr | kv-store --raw flag + actionable non-JSON error | kv-store --raw | merged |
| PR-005 | pr | synapse-infer precondition dedup (the 11x repeat) | synapse dedup | merged |
| PR-016-017 | pr | R9 hook->enforce integration + R_GROUNDED_CLAIMS two-tier tests | enforcement tests | merged |
| PR-008 | pr | forward ladder advances the phase manifest (real node-order state) | ladder advances manifest | merged |
| PR-018 | pr | phase_model distinguish done() reasons (reason_code) + reject normalized-collision ids | phase_model reason_code | merged |
| PR-003 | pr | OS-STATE nominal-collapse + code-dev replay menu surface (folds PR-011) | OS-STATE collapse | merged |
| PR-011 | pr | surface code-dev-replay menu verb | replay surface | merged |
| FIX-FRESHNESS | pr | regenerate DOC-INDEX + program registry + code-map after the menu change (PR-003 follow-on) | freshness artifacts | merged |
| PR-002a-relabel | pr | code-dev SHADOW GATE label 'enforced' -> 'advisory · fail-open' (truthful posture) + recompiled mirror | shadow-gate relabel | merged |
| FIX-FLAKY-GATE | pr | crucible pytest control retries the suite once on failure (xdist flakiness mitigation) + guard test | flaky-gate fix | merged |
| PR-002a-boot | pr | enforcement-posture boot line in axon/BOOT.md (after 'Boot complete.', sourced from verify status) | enforcement-posture boot line | merged |
| PR-007 | pr | resume-truth re-entry + :done marker normalization (kernel slice) | resume-truth marker | merged |
| PR-019 | pr | code-dev-study mode-dispatch skips the manifest advance (line 92-95 DONE before line 528) + emits/WRITE drift (01-study.md vs study/<mode>.md) -> ladder silently never advances under mode flags. Multi-file, back-compat-sensitive (01-study.md read at 118/521); needs OR-semantics outputs + a program-exec test (markdown runner). ROOT CAUSE in todo b3b5aea3. | PR-019 ladder-advance fix | merged |
| PR-008b | pr | resume/code-dev-next reads _phases.json (visible consumer) — close the _meta vs _phases dual-SSOT + behavioral e2e ladder test | PR-008b visible consumer | merged |
| PR-009b | pr | adaptive-loop termination tests for the 4 exits + the 'Skip to next iteration' no-op fix (PR-009 dropped: loop already terminates via UNTIL max-iter=3 + KERNEL-SLIM:155) | PR-009b termination tests | deferred |
| PR-005bc | pr | on-disk precondition scrub + recompile + synapse-validate semantic lint + unbalanced-paren clamp | PR-005b/c hygiene | merged |
| GAP-HARDENING | pr | gap-find residue: phase-new cascade pre-filter, R_TOOL_CALL_EXISTS phase-model blindspot, compiled-staleness hash-based, kv --raw TTL test | gap-find hardening batch | merged |
| PR-010 | pr | reanchor cadence knob (kernel G-02) — deterministic, never context-suppression | reanchor cadence | deferred |
| PR-012 | pr | single save/sync verb hiding the two-repo split — needs repo-scoping design | save/sync verb | deferred |
| PR-015 | pr | component grammar demoted to internal render contract | component grammar | deferred |
| PR-006 | pr | code-dev start front door | code-dev start | dropped |
| PR-013 | pr | stranger-test gate tool (standalone) | stranger-test gate | dropped |
| PR-014 | pr | fast-boot + first-run onboarding + discoverability rank() — GATED on a real stranger session. Owner share-decision = SHARE -> onboarding KEPT as a future project. | fast-boot/discoverability | gated |
| GATE-SUITE | gate | full crucible/pytest suite green on origin/main — gate reliability fixed (FIX-FLAKY-GATE). Green at f9c90f1. | suite-green | done |
| GATE-RULE12 | gate | Core Rule 12 ruling for PR-003 — OWNER RULED (a) rule-OK 2026-06-23 ('I gate ok'). PR-003 merged. | Core Rule 12 ruling | done |
| GATE-STRANGER | gate | REDEFINED 2026-06-23 (deep HR council, owner constraint: no human but the owner). Renamed from a 'stranger test' (a label that claimed a de-biased human signal it never had) to a MECHANICAL BOOT-CONFORMANCE gate: satisfied when `run.sh --live` shows Layer-0 boot-friction green AND every reached task passes the FABRICATION-HARDENED grader (>=3 reached) AND PR-T0-bootflow (the my-axon-gate halt) is resolved. The author satisfies this by running the benchmark — the naive AI is the subject, not a human. HONEST ADMISSION (written per the adversary seat): under 'no human but the owner', the non-author DESIRE/abandonment signal is UNOBTAINABLE (an instruction-follower complies where a human quits; the author cannot un-know AXON's idiom). We are NOT measuring it and we accept we are blind to whether a stranger would WANT to continue. The desire half is DROPPED as a blocker (see PR-014). | boot-conformance gate (was 'stranger') | owner-open |
| PR-014a-coldboot | pr | AXON-COLDBOOT mechanical preflight — boot-friction Layer 0 (static boot-path audit) + cold_stranger Layer 1 (naive-agent harness) + robustness fixes (per-run credential refresh, 5xx/overloaded retry, honest reached/auth/skip tally). Realizes dropped PR-013 as the WIRED preflight; author-runnable, does NOT need the owner stranger session. | coldboot preflight (L0+L1) | merged |
| PR-T0-bootflow | finding | First-run boot HALTS at the my-axon [F/C/S] gate before rendering banner+menu — a newcomer sees a setup prompt, not the home screen. Surfaced by AXON-COLDBOOT T0. DESIGN: render menu FIRST then offer my-axon setup, or auto-Fresh->menu. Kernel boot-flow (BOOT.md / KERNEL G-10) -> owner-merged. | T0 menu-first boot finding | owner-open |
| PR-DAG-LEDGER | pr | code-dev status DAG-aware PR ledger — tools/dag.py summarize()/cmd_summary() exposed as TOOL(dag,summary) + code-dev-state-status.md DAG ledger line. Fixes the glob-only PR count reading v4 DAG-only projects (PRs tracked in DAG.json, 0 standalone PR-*.md) as empty. STANDALONE — unrelated to coldboot. | dag-summary ledger | merged |
| PR-014b-coldboot-grader | pr | Non-fabrication grader for the cold-start benchmark — corroborate boot-state claims against the checkout's REGISTRY.json ground truth so a confabulated boot (the live '162 ACTIVE tools while python3 sandboxed', real=160) scores failure_kind:fabricated, never a pass. Makes the mechanical gate trustworthy (Core Rule 6). | non-fabrication grader | merged |

## Edges

| from | to | kind |
|------|----|------|
| PR-001 | PR-008 | depends |
| PR-001 | PR-018 | depends |
| PR-008 | PR-018 | depends |
| PR-003 | FIX-FRESHNESS | depends |
| PR-018 | PR-019 | depends |
| PR-019 | PR-008b | depends |
| PR-008 | PR-008b | depends |
| PR-005 | PR-005bc | depends |
| GATE-RULE12 | PR-003 | gates |
| GATE-STRANGER | PR-014 | gates |
| PR-013 | PR-014 | folds-into |
| PR-011 | PR-003 | folds-into |
| PR-013 | PR-014a-coldboot | folds-into |
| PR-014a-coldboot | PR-014 | informs |
| PR-014a-coldboot | PR-T0-bootflow | informs |
| PR-T0-bootflow | PR-014 | informs |
| PR-014b-coldboot-grader | GATE-STRANGER | informs |
| PR-T0-bootflow | GATE-STRANGER | informs |
