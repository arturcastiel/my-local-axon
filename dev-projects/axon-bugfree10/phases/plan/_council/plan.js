export const meta = {
  name: 'axon-bugfree10-deepplan',
  description: 'Deep plan for 91 confirmed bugs: propose PR batches -> HR expert council -> synthesize plan + DAG',
  phases: [
    { title: 'Propose', detail: 'cluster 91 bugs into a candidate PR batching + sequence' },
    { title: 'Council', detail: '8-lens HR council (incl. Challenger) critiques the proposal' },
    { title: 'Synthesize', detail: 'deliberate critiques into a final plan + dependency DAG' },
  ],
}

const A = (typeof args === 'string') ? JSON.parse(args) : args
const ROOT = A.root
const INPUT = A.inputPath

const PROPOSAL_SCHEMA = {
  type: 'object',
  properties: {
    prs: { type: 'array', items: { type: 'object', properties: {
      pr_id: { type: 'string' }, title: { type: 'string' }, subsystem: { type: 'string' },
      bug_ids: { type: 'array', items: { type: 'string' } },
      rationale: { type: 'string' }, risk: { type: 'string', enum: ['low', 'medium', 'high'] },
      effort: { type: 'string', enum: ['S', 'M', 'L'] },
      depends_on: { type: 'array', items: { type: 'string' } },
      test_strategy: { type: 'string' }, kernel_floor: { type: 'boolean' },
    }, required: ['pr_id', 'title', 'bug_ids', 'risk', 'effort'] } },
    sequencing: { type: 'array', items: { type: 'string' } },
    notes: { type: 'string' },
  },
  required: ['prs', 'sequencing'],
}

const CRITIQUE_SCHEMA = {
  type: 'object',
  properties: {
    lens: { type: 'string' },
    overall: { type: 'string', enum: ['endorse', 'revise', 'reject'] },
    issues: { type: 'array', items: { type: 'string' } },
    batch_changes: { type: 'array', items: { type: 'string' } },
    sequencing_changes: { type: 'array', items: { type: 'string' } },
    missed_dependencies: { type: 'array', items: { type: 'string' } },
    top_priority_prs: { type: 'array', items: { type: 'string' } },
  },
  required: ['lens', 'overall'],
}

const FINAL_SCHEMA = {
  type: 'object',
  properties: {
    prs: { type: 'array', items: { type: 'object', properties: {
      pr_id: { type: 'string' }, title: { type: 'string' }, subsystem: { type: 'string' },
      bug_ids: { type: 'array', items: { type: 'string' } }, rationale: { type: 'string' },
      risk: { type: 'string' }, effort: { type: 'string' },
      depends_on: { type: 'array', items: { type: 'string' } },
      test_strategy: { type: 'string' }, kernel_floor: { type: 'boolean' }, dissent: { type: 'string' },
    }, required: ['pr_id', 'title', 'bug_ids'] } },
    sequence: { type: 'array', items: { type: 'string' } },
    dag: { type: 'object', properties: {
      nodes: { type: 'array', items: { type: 'string' } },
      edges: { type: 'array', items: { type: 'object', properties: {
        from: { type: 'string' }, to: { type: 'string' }, reason: { type: 'string' },
      }, required: ['from', 'to'] } },
    } },
    plan_narrative: { type: 'string' },
    dissent: { type: 'array', items: { type: 'string' } },
    council_summary: { type: 'string' },
  },
  required: ['prs', 'sequence', 'dag', 'plan_narrative'],
}

const LENSES = [
  { key: 'security-kernel-integrity', brief: 'Kernel/gate integrity & security. The R9 write-gate and fail-open gates are the crown jewels — these fixes must land first and cannot themselves introduce a bypass. Flag any PR that touches a gate without a regression test that proves the hole is closed.' },
  { key: 'architecture-coupling', brief: 'Module coupling & cohesion. Are bugs batched so each PR touches one coherent surface? Flag PRs that span unrelated modules (hard to review/revert) or that split one root-cause across PRs.' },
  { key: 'test-strategy', brief: 'Test coverage & verifiability. Every bug is AI-verified, NOT human-confirmed. Each PR MUST carry a test that fails before / passes after. Flag PRs with vague or missing test strategy; call out bugs that need a fixture.' },
  { key: 'release-sequencing-risk', brief: 'Order & blast radius. Sequence so foundational/low-risk-high-value fixes land first and risky ones are isolated. Flag orderings that put a risky refactor before the gate fixes, or that batch too much into one PR.' },
  { key: 'effort-estimation', brief: 'Effort realism. Challenge S/M/L sizing; a PR bundling 10 bugs across 8 files is not "M". Recommend splits where a batch is too big to review in one sitting.' },
  { key: 'regression-blast-radius', brief: 'Regression risk. Which fixes could break callers? shell.py, run.py, drift.py, phase-model are high-traffic. Flag fixes that change a widely-used contract and demand caller-audit + broad test.' },
  { key: 'dependency-dag', brief: 'Dependency correctness. Build the true fix-order DAG: which PRs must precede others (shared file, shared helper, gate-before-consumer). Flag missing or wrong depends_on edges and any cycle.' },
  { key: 'challenger', brief: 'MANDATORY adversary. Argue the plan is WRONG: over-batched, mis-prioritized, scope-creeping, or violating the axon/ human-only floor by proposing autofix PRs for kernel files. Push for fewer/smaller PRs and for demoting low-severity noise. Default to "revise" unless the plan is genuinely tight.' },
]

function proposePrompt() {
  return `You are the lead planner for a bug-fix release on AXON (an OS-for-AI-agents: Python tools + Markdown "programs").

STEP 1 — read the full confirmed-bug ledger:
  cat ${INPUT}
(It is JSON: {total_confirmed, first_cut_subsystems, bugs:[{id,file,line,severity,category,part,summary,kernel_floor}]}. You may also Read any cited source file under ${ROOT}/ to judge how to batch.)

STEP 2 — propose a PR batching that turns 91 confirmed bugs into a reviewable, sequenced release. Rules:
- Group bugs that share a file, a root cause, or a fix pattern into ONE PR. Keep each PR small enough to review in one sitting (rough ceiling ~6-8 bugs / a few files).
- Gate/security fixes (shell.py R9 anchor + fail-open gates) are the highest priority and should land first.
- Files under axon/* are a HUMAN-ONLY kernel floor: put them in ADVISORY, findings-only PR(s) — describe the fix, but mark kernel_floor:true and do NOT plan an autofix.
- Every PR needs a concrete test_strategy (a test that fails before / passes after).
- Give each PR: pr_id (PR-01…), title, subsystem, the exact bug_ids it fixes, rationale, risk, effort (S/M/L), depends_on (other pr_ids), test_strategy, kernel_floor.
- Provide a recommended sequencing (ordered list of pr_ids). Ensure EVERY one of the 91 bug ids lands in exactly one PR.

Return the structured proposal.`
}

function councilPrompt(lens, proposal) {
  return `You are a seat on an AXON advisory HR council reviewing a bug-fix release plan. YOUR LENS: ${lens.key}.
${lens.brief}

The confirmed-bug ledger is at ${INPUT} (read it with \`cat ${INPUT}\` for bug detail; Read any source under ${ROOT}/ as needed).

PROPOSED PLAN (${proposal.prs.length} PRs):
${JSON.stringify(proposal, null, 1)}

Critique the plan STRICTLY through your lens only. Be concrete and cite pr_ids / bug_ids. Return:
- overall: endorse | revise | reject
- issues: specific problems you see
- batch_changes: concrete regroupings (merge/split/move bug X to PR Y)
- sequencing_changes: order fixes
- missed_dependencies: depends_on edges the plan is missing
- top_priority_prs: the pr_ids that must land first from your lens

Advisory only — recommendations, not decisions. Preserve your dissent even if it is a minority view.`
}

function synthPrompt(proposal, critiques) {
  return `You are the council deliberator. Synthesize ONE final bug-fix release plan for AXON from the proposal + 8 expert critiques. This is a DEEP plan — it must be defensible and dependency-correct.

LEDGER: ${INPUT} (read with \`cat ${INPUT}\` — you MUST ensure every one of the 91 bug_ids appears in exactly one final PR).

ORIGINAL PROPOSAL:
${JSON.stringify(proposal, null, 1)}

COUNCIL CRITIQUES (8 lenses):
${JSON.stringify(critiques, null, 1)}

Produce the FINAL plan:
- prs: the reconciled PR list. Apply the council's batch_changes where they converge; where lenses conflict, choose and record the loser's view in that PR's "dissent" field. Keep gate/security PRs first; keep axon/* fixes as advisory kernel_floor:true PRs. Each PR keeps title, subsystem, bug_ids, rationale, risk, effort, depends_on, test_strategy, kernel_floor, dissent.
- sequence: the final ordered list of pr_ids (topologically valid vs depends_on).
- dag: {nodes:[pr_ids], edges:[{from,to,reason}]} — the real fix-order dependency graph, no cycles.
- plan_narrative: 1-2 paragraphs — the strategy, the phasing, why this order.
- dissent: council disagreements that survived synthesis.
- council_summary: one line per lens — its overall verdict + its single most important point.

Verify coverage: every bug_id assigned once; every depends_on target exists; sequence respects the DAG.`
}

phase('Propose')
const proposal = await agent(proposePrompt(), { label: 'propose:batching', phase: 'Propose', effort: 'high', schema: PROPOSAL_SCHEMA })
if (!proposal || !proposal.prs) {
  log('proposer returned no plan — aborting')
  return { error: 'no proposal' }
}
log(`proposer: ${proposal.prs.length} candidate PRs over ${proposal.prs.reduce((s, p) => s + (p.bug_ids ? p.bug_ids.length : 0), 0)} bug-assignments`)

phase('Council')
const critiques = (await parallel(LENSES.map((lens) => () =>
  agent(councilPrompt(lens, proposal), { label: `council:${lens.key}`, phase: 'Council', effort: 'medium', schema: CRITIQUE_SCHEMA })
))).filter(Boolean)
const tally = { endorse: 0, revise: 0, reject: 0 }
for (const c of critiques) tally[c.overall] = (tally[c.overall] || 0) + 1
log(`council: ${critiques.length}/8 seats — endorse ${tally.endorse}, revise ${tally.revise}, reject ${tally.reject}`)

phase('Synthesize')
const final = await agent(synthPrompt(proposal, critiques), { label: 'synthesize:final-plan', phase: 'Synthesize', effort: 'high', schema: FINAL_SCHEMA })

return {
  proposal_pr_count: proposal.prs.length,
  council_tally: tally,
  final,
}
