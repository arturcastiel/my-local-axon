# PR List — AXON Next (Autonomy Doctrine + T3 floor)
Updated: 2026-07-08  ·  Total PRs: 17  ·  Waves: A t3-floor · B doctrine-spine · C doctrine-graph · D obedience+proof

## PR-001 — Deletion-verb gate coverage: verbs, wrappers, interpreters, bulk threshold
- **Status:** not-started
- **Complexity:** L
- **Phase:** wave-a-t3-floor
- **Scope:** tools/shell.py (new 2pre/3c classifier pair), tools/autonomous_mode.py (DESTRUCTIVE_OPS += bulk-delete), tools/hooks/enforce_pretooluse.py (data-driven code registry), tools/output_manifest.json, tests
- **Depends on:** none
- **Why:** live-probed holes (G5, red-team-widened): find -delete / -exec rm, xargs/env/timeout wrappers, shred, unlink, git clean -fdx, tar --remove-files, busybox applets, interpreter deletes (_INTERP_WRITE_CALL gains os.remove|os.unlink|shutil.rmtree|Path.unlink), rsync --delete deletion semantic; bulk threshold + protected-subtree DENY (workspace/programs, workspace/memory, project dirs). Hook registry becomes data-driven so new GateBlock codes bite by construction; the fail-open→fail-closed hook flip ships STAGED (log-only soak + promotes_on), never smuggled.

## PR-002 — Build G1c for real: the write-barrier the comments already cite
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-a-t3-floor
- **Scope:** new tools/write_barrier.py (sys.addaudithook harness: open-for-write/os.remove/os.unlink/os.rename/shutil ops vs a protected-subtree set), wiring into cmd_exec's python-interpreter executions for unattended runs, shell.py comment cleanup, tests
- **Depends on:** none
- **Why:** red-team BLOCKER: shell.py:96 + :487 delegate the undecidable residual (computed-path interpreter writes/deletes) to an "OS write-barrier (G1c)" that does not exist anywhere — negligence-by-citation. Honest scope: the barrier arms for python-driven executions under unattended runs; the residual beyond it (non-python computed paths) is DOCUMENTED as covered by protected-subtree deny (PR-001) + receipts, not silently claimed.

## PR-003 — Grant TTL + human-only renewal + ledger reconciliation
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-a-t3-floor
- **Scope:** tools/autonomous_mode.py (_expired() consulted in authorized(); renew CLI; grant_off reconciles the accountability entry), tools/hooks/enforce_pretooluse.py (deny autonomous-mode on|renew while run_active — anti-self-renew), tests
- **Depends on:** none
- **Why:** G6: granted_ts/budget are write-only; grants are immortal (live one is 16+ days). THE INVARIANT (named test): an expired grant makes authorized() return False for every op while run_active() STILL returns True — expiry denies, never disarms kernel-floor/breaker/cadence mid-run. Renewal is mechanically un-invokable by the agent (red-team: self-renew = TTL theater). Expiry surfaces at node boundaries via the runner (PR-014/016), never a silent stall.

## PR-004 — Receipts v1.1: one enum bump, hash-chained rows, destructive-act wrapping
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-a-t3-floor
- **Scope:** tools/loop_receipt.py + tools/_loop_receipt_ctx.py (SCHEMA v1.1: intents doctrine-node, delegated-destructive, dag-repair; triggers unattended-run, doctrine-run; target kind tree; prev-sha hash-chain per row, verify checks chain), tools/shell.py cmd_exec (receipt wrap generic over gate classification), tests
- **Depends on:** none
- **Why:** S8 + ordering seat (ALL doctrine-era enum vocabulary lands in ONE version event, incl. dag-repair reserved for v2) + red-team (the "actor whitelist" trust rationale is FALSE — an unauthenticated kwarg; hash-chain makes silent edits detectable breaks; the claim is struck from all docs). recover() over node receipts = crash-consistent run-until-end for free.

## PR-005 — Program-integrity manifest: programs + AUTONOMY.md + run graphs
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-a-t3-floor
- **Scope:** new tools/program_integrity.py + tools/program_hash_manifest.json (sha256, bless action, receipted), crucible control (WARN + promotes_on), tests
- **Depends on:** none
- **Why:** G10/S10 + red-team HIGH: the manifest covers workspace/programs/*.md AND the files that grant power — AUTONOMY.md instances (project anchors) and per-run doctrine graphs — BEFORE the spine exists (wave order fixed), so activation (PR-008/012) can verify hashes before trusting any doc. Separate reviewed file, never auto-blessed by generators; proven WARN→promotes_on→BLOCK staging.

## PR-006 — AUTONOMY.md: format, template, parser, anchor decision
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-b-doctrine-spine
- **Scope:** workspace/templates/autonomy.md, new tools/autonomy_doc.py (parser: meta.py-style key header + load_policy-style sections: capabilities/destructive/deviation-policy/floor + preserved Notes + Dependency-graph REPLACE-SECTION target), anchor = project dir (sibling of _policy.md; per-project primary, repo-root fallback — the G7 sliver), tests
- **Depends on:** none
- **Why:** S1, pillar 1. The standing doctrine instance, machine-parseable by three existing idioms at once; never embedded in _policy.md (contract rewrites clobber all but Notes).

## PR-007 — The activation interview: four-artifact transaction
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-b-doctrine-spine
- **Scope:** workspace/programs/autonomy-contract.md (extended: explain-first banner, TOOL(decide) questions with explanations in option labels — level, ops, destructive, deviation policy w/ halt-default, budget in NODE-COMPLETIONS (D4), scope), tools/autonomy_contract.py (write() gains AUTONOMY.md as the fourth artifact, atomic, receipted), tests
- **Depends on:** PR-006
- **Why:** S2, pillar 2. Extends the existing per-run entry gate into the doctrine's standing rite — no parallel interview machine (reduce-surface). House style verified by study D.

## PR-008 — Fail-closed activation stage 1 + the grant⟷doctrine binding
- **Status:** not-started
- **Complexity:** L
- **Phase:** wave-b-doctrine-spine
- **Scope:** tools/autonomous_mode.py (grant gains doctrine field: path+hash of the AUTONOMY.md+run-graph binding; authorized() refuses ALL ops when run_active and the binding is absent/invalid), tools/aegis_policy.py (doctrine predicate), new crucible STATIC rule (r_doctrine_active pattern), integrity-hash verification at activation (via PR-005), tests
- **Depends on:** PR-006, PR-003, PR-005
- **Why:** G1 + the red-team's #1 BLOCKER: today run_active means "an unattended grant file exists" — an agent can skip the runner and act under the raw grant. After this PR, an unattended grant without a valid, hash-verified doctrine binding authorizes NOTHING. Stage 1 = doc-presence + hash + structural verify; stage 2 (validated-DAG) arrives with PR-012 — staged exactly like every other gate (no forward dep).

## PR-009 — Walking skeleton: one tiny mission end-to-end
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-b-doctrine-spine
- **Scope:** sandbox fixture project + a 2-node plain routine (existing schema, no typed nodes yet): interview → four artifacts → activation stage 1 → advance-bound run → node receipts → completion report; deterministic-fake tests + one live smoke
- **Depends on:** PR-004, PR-007, PR-008
- **Why:** ordering seat (dissent recorded): without this, the spine first integrates after ~16 merges — canonical late-integration failure. This fixture is what PRs 010-017 extend, not a throwaway.

## PR-010 — Workflow schema: outputs legalized, typed node kinds
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-c-doctrine-graph
- **Scope:** workspace/schemas/workflow-file.schema.json (synapse gains outputs (G8 — the runner already enforces what the schema forbids, verified) + kind: gate|checkpoint|human-handoff|action), workflow_run validate/check lints kind-aware, doctrine-routine profile lint (every gate node carries if: rules; every human-handoff node maps to the handoff renderer), tests
- **Depends on:** none
- **Why:** G8 + G3 under the D1 format flip: typed kinds land in the format that already executes, as a schema-enum PR (the precedent: role: orchestrator special-casing) — not a new graph engine.

## PR-011 — Goal-ctx bridge + deterministic resolve-next
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-c-doctrine-graph
- **Scope:** tools/workflow_run.py (build_gate_ctx gains a goal source from tools/goal.py state (G9); new resolve-next: evaluates on-complete rules IN ORDER via predicate.py and returns the first-true target — the tool picks the branch, not the walker), tests
- **Depends on:** none
- **Why:** skeptic V2.2 (verified): next_allowed ignores if: — branch selection is self-graded today; an agent could take the tests-green branch on red with no deterministic violation. resolve-next closes it; the goal bridge makes acceptance/rejection vocabulary actually evaluable.

## PR-012 — Validation preflight + activation stage 2
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-c-doctrine-graph
- **Scope:** new tools/doctrine_preflight.py (composes: schema validate + check-stale + check-templating + workflow_dag static + constraints.run_checks + r_dont_do compilation into gate nodes + integrity hashes) → stamps validated on the routine; activation (PR-008 seam) upgraded to require it, tests
- **Depends on:** PR-010, PR-006
- **Why:** S5, pillar 4 — "the DAG checks against the program itself." Composition of six existing detectors (zero new detection code, re-verified under the YAML format where their entry points already exist — the dag.py path would have forced reimplementation).

## PR-013 — Derived DAG ledger + the mermaid fluxogram
- **Status:** not-started
- **Complexity:** S
- **Phase:** wave-c-doctrine-graph
- **Scope:** projector (routine YAML + trajectory/receipts → DAG.json statuses/provenance, one-way) + mermaid render into the AUTONOMY.md Dependency-graph section and the run dir (plan_dag.emit_mermaid idiom), tests
- **Depends on:** PR-010
- **Why:** D1's second half: the ledger/fluxogram is a VIEW, never authored — the split-brain stays dead by construction. This is what the owner sees before approving a run.

## PR-014 — The doctrine runner: bound execution, receipts, the wall
- **Status:** not-started
- **Complexity:** L
- **Phase:** wave-c-doctrine-graph
- **Scope:** new tools/doctrine_run.py (deterministic core: advance + resolve-next + per-node receipts + node-state record into working memory) + workspace/programs/doctrine-run.md (the neuron: mission → proposed routine → preflight → fluxogram → owner gate → bound run-until-end; one loop_contract per run as the budget wall (D4 node-completions); deviation policy honored fail-closed: halt-and-handoff into the EXHAUSTED/handoff renderer (D3); per-node capability routing through aegis resolve — 6/6 for doctrine runs), extends the PR-009 skeleton, tests (deterministic core fully faked; program by content pins + skeleton smoke)
- **Depends on:** PR-009, PR-010, PR-011, PR-012, PR-013
- **Why:** S6, pillar 5. The 015a/b split lives INSIDE this PR as tool-vs-program layering; the deterministic core is the mergeable heart.

## PR-015 — S7b: the current-node op-class gate + scope binding
- **Status:** not-started
- **Complexity:** L
- **Phase:** wave-d-obedience-proof
- **Scope:** tools/shell.py gate_check (new doctrine segment: reads the runner-recorded current-node state; while run_active, DENIES ops outside the node's declared op-class and file/dir scope — fail-closed, hook-registered via PR-001's registry), grant scope binding (the contract's scope answer becomes enforced paths), tests
- **Depends on:** PR-014, PR-001
- **Why:** the council's unanimous missing tooth (skeptic's strongest objection; ordering's "sharpest unattended tooth"; red-team blocker #1's op-time half): the HOST refuses out-of-class ops mid-run — "run and obeyed" becomes mechanically true, not self-reported.

## PR-016 — Unattended arming: evidence-gated promotion
- **Status:** not-started
- **Complexity:** M
- **Phase:** wave-d-obedience-proof
- **Scope:** arming flag with promotes_on: 3 clean fully-receipted attended doctrine runs (D2); expiry-at-node-boundary → EXHAUSTED handoff (never a silent stall, never splits an atomic node); host-mirror receipt rows via the Stop hook (the agent-unreachable writer — red-team's real answer for unattended evidence); run report + accountability ledger close, tests
- **Depends on:** PR-014, PR-015, PR-003
- **Why:** D2: "all modes" as staging — the same discipline every AXON gate obeys, applied to autonomy itself.

## PR-017 — External-repo E2E proof + docs + v2 stub
- **Status:** not-started
- **Complexity:** L
- **Phase:** wave-d-obedience-proof
- **Scope:** one real code-dev mission under the doctrine on an EXTERNAL repo (cpg2python-class, for-use checkout) as the acceptance run; workspace/AXON-DOCS-AUTONOMY.md (+ Guarded-by block); doctrine-v2 project stub (append-repair mechanics, legacy vocab alignment, remaining resolve rewiring); dogfood run on axon-next as the SECOND exercise
- **Depends on:** PR-014, PR-015, PR-016
- **Why:** economist (adopted): the doctrine's birth certificate doubles as the platform's first external-evidence artifact. Nothing silently evaporates into "later" — v2 is a named project.
