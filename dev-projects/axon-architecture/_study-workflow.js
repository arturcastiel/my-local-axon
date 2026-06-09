export const meta = {
  name: 'axon-arch-study',
  description: 'Exhaustive loop-until-dry architecture audit of AXON: grounded, adversarially-verified, prioritized roadmap',
  phases: [
    { title: 'Sweep', detail: 'parallel auditors across 8 architecture dimensions, grounded at file:line' },
    { title: 'Verify', detail: 'adversarial refutation of each finding' },
    { title: 'Critic', detail: 'completeness critic then follow-up audits until dry' },
    { title: 'Synthesize', detail: 'dedup + prioritize into a flawless roadmap, graded' },
  ],
}

const REPO = '/home/arturcastiel/projects/new-axon/axon'

const FINDINGS = {
  type: 'object', additionalProperties: false,
  required: ['findings'],
  properties: { findings: { type: 'array', items: {
    type: 'object', additionalProperties: false,
    required: ['title', 'severity', 'evidence', 'why', 'fix', 'effort'],
    properties: {
      title: { type: 'string' },
      severity: { type: 'string', enum: ['CRITICAL', 'MAJOR', 'MINOR'] },
      evidence: { type: 'string', description: 'file:line plus short quote proving it is real' },
      why: { type: 'string', description: 'why it hurts maintainability or the system goal' },
      fix: { type: 'string', description: 'concrete proposed change' },
      effort: { type: 'string', enum: ['S', 'M', 'L'] },
    } } } },
}
const VERDICT = {
  type: 'object', additionalProperties: false,
  required: ['real', 'confidence', 'reason'],
  properties: {
    real: { type: 'boolean', description: 'true only if the evidence holds and it is a genuine architecture problem' },
    confidence: { type: 'number' },
    reason: { type: 'string' },
    corrected_severity: { type: 'string', enum: ['CRITICAL', 'MAJOR', 'MINOR', ''] },
  },
}
const GAPS = {
  type: 'object', additionalProperties: false,
  required: ['gaps'],
  properties: { gaps: { type: 'array', items: {
    type: 'object', additionalProperties: false,
    required: ['key', 'prompt'],
    properties: { key: { type: 'string' }, prompt: { type: 'string', description: 'a concrete follow-up audit instruction for an unexamined file/claim/dimension' } } } } },
}
const ROADMAP = {
  type: 'object', additionalProperties: false,
  required: ['summary', 'items', 'confidence_grade', 'residual_risks'],
  properties: {
    summary: { type: 'string' },
    items: { type: 'array', items: {
      type: 'object', additionalProperties: false,
      required: ['rank', 'title', 'severity', 'leverage', 'effort', 'fix', 'depends_on'],
      properties: {
        rank: { type: 'number' }, title: { type: 'string' },
        severity: { type: 'string' }, leverage: { type: 'string', enum: ['HIGH', 'MED', 'LOW'] },
        effort: { type: 'string', enum: ['S', 'M', 'L'] }, fix: { type: 'string' },
        depends_on: { type: 'string' },
      } } },
    confidence_grade: { type: 'number', description: '0-10 readiness of this study for the PLAN phase' },
    residual_risks: { type: 'array', items: { type: 'string' } },
  },
}

const preamble = `You are a senior architect auditing AXON, an instruction-based "OS for AI agents" at ${REPO}. ` +
  `AXON is LLM-interpreted markdown programs (workspace/programs/*.md, 187 of them) plus Python tools (tools/, 145 registered) plus ` +
  `an LLM-interpreted kernel (axon/KERNEL-SLIM.md). Its stated goal: "Execute programs. Enforce rules. Protect memory. ` +
  `Surface state. Fail loudly." Use Read/Grep/Glob/Bash to READ THE ACTUAL CODE. Ground EVERY finding at file:line with a ` +
  `short verbatim quote, no vague "could be improved". Find real ARCHITECTURE problems hurting maintainability or that goal. ` +
  `Be adversarial and specific. Only return findings you can prove from the code.`

const DIMENSIONS = [
  { key: 'enforcement-reality', prompt: `${preamble}\nDIMENSION: Enforcement reality. The central claim is "enforce rules / fail loudly", but programs and kernel are LLM-interpreted (advisory) and only Python tools plus a harness hook have teeth. Audit: axon/KERNEL-SLIM.md response gate; tools/verify.py and tools/enforce.py; .claude/ (is the hook installed?); workspace/harness/*.md (host-cap-enforce); which rules actually BLOCK at merge vs WARN-first vs silent-until-flag. Quantify the gap between claimed and mechanical enforcement.` },
  { key: 'orphan-liveness', prompt: `${preamble}\nDIMENSION: Orphaning / wiring-liveness. "Features go missing" is a recurring disease here. Audit tools/REGISTRY.json (145 tools), tools/rules/ (27 rules), workspace/programs/ (187). Determine how "is this invoked?" is even defined (TOOL() in programs, an import, a tools/crucible.json control cmd, the pre-commit config, an axon.py dispatch) and whether any single source of truth exists. Find ACTIVE tools/rules/schema-fields with no live invocation. Re-check the ~11 flagged unreferenced tools (a2a, axiom, axon-bridge, axon-eval, axon-managed, axon-state, dag-consistency, lint-commit-trailer, memory-sync, metric-integrity, skill-adapter): which are truly dead vs reached via a non-TOOL() path a grep missed.` },
  { key: 'sprawl-complexity', prompt: `${preamble}\nDIMENSION: Sprawl / complexity. code-dev is 118 of 187 programs; largest files reach 506 lines (code-dev-pr-review.md), 465 (code-dev-study.md), 455 (code-dev-plan.md). 145 tools. Audit for redundant/overlapping tools and programs; oversized LLM-interpreted files that should be thinner; logic that belongs in testable, deterministic Python instead of markdown; consolidation opportunities. Quantify with file:line.` },
  { key: 'kernel-integrity', prompt: `${preamble}\nDIMENSION: Kernel integrity. axon/KERNEL-SLIM.md declares "immutable" Core Rules 1-13 plus identity-lock plus memory-protection plus the write-gate, but it is markdown the model reads. Audit which of these have ACTUAL Python/hook enforcement vs honor-system prose. Check non-determinism hazards (wall-clock reads, RNG seeding, or cwd-dependence) in tools/. Note the dual checkout (new-axon dev vs library-development for-use; the /mnt/c copy is stale) as a drift risk.` },
  { key: 'footguns', prompt: `${preamble}\nDIMENSION: Maintainability footguns. Audit: strict-halt mode making a runtime WARN equal a BLOCK on the kernel gate (tools/verify.py) and the "silent-until-flag" workaround it forces; proliferation of L:*-required activation flags with no central manifest of "what is active"; fail-open vs fail-closed defaults across tools; error-handling consistency; any place a default silently degrades enforcement.` },
  { key: 'testing-arch', prompt: `${preamble}\nDIMENSION: Testing architecture. 3969 tests pass yet wiring rots (orphans persist). Audit tests/ structure: unit vs integration coverage; does anything exercise programs end-to-end; the crucible gate composition (tools/crucible.json controls plus tools/crucible.py); lock-tests vs behavior-tests. Find why green tests coexist with missing features, and what class of test would catch it.` },
  { key: 'data-state-model', prompt: `${preamble}\nDIMENSION: Data + state model. Audit the W:/L:/E: memory scopes (workspace/memory/*), _phases.json, intent-queue, persistence and parsing (e.g. the dev-mode/halt-mode value formats had a parse bug). Find coupling, fragile parsing, inconsistent scope conventions, or state with no single owner.` },
  { key: 'coupling-boundaries', prompt: `${preamble}\nDIMENSION: Coupling + module boundaries. Audit dependency structure across tools, programs, and kernel: circular or surprising imports, god-modules, tools that reach across layers, _axon_paths/registry coupling, whether there are clean module boundaries or one big ball. Use imports plus grep to ground it.` },
]

function fkey(f) {
  const file = (f.evidence || '').split(/[:\s]/)[0].toLowerCase()
  return file + '|' + (f.title || '').toLowerCase().slice(0, 45)
}

const seen = new Set()
const confirmed = []
let round = 0, dry = 0
let toRun = DIMENSIONS

while (round < 4 && dry < 2 && toRun.length) {
  round++
  log(`Round ${round}: ${toRun.length} audit task(s)`)
  const swept = (await parallel(toRun.map(d => () =>
    agent(d.prompt, { label: `audit:${d.key}`, phase: 'Sweep', schema: FINDINGS })
  ))).filter(Boolean).flatMap(r => r.findings || [])
  const fresh = swept.filter(f => f && !seen.has(fkey(f)))
  if (!fresh.length) { dry++; log(`Round ${round}: nothing fresh (dry ${dry}/2)`); toRun = [] }
  else {
    dry = 0
    fresh.forEach(f => seen.add(fkey(f)))
    const verified = await parallel(fresh.map(f => () =>
      agent(`${preamble}\nADVERSARIALLY VERIFY this finding by trying to REFUTE it. Re-read the cited code. Is the evidence accurate? Is it a genuine architecture problem, or already mitigated / a false positive / reached via a path the auditor missed? Default real=false if the evidence does not hold.\n\nFINDING: ${JSON.stringify(f)}`,
        { label: `verify:${fkey(f).slice(0, 30)}`, phase: 'Verify', schema: VERDICT })
        .then(v => ({ ...f, verdict: v }))
    ))
    confirmed.push(...verified.filter(x => x && x.verdict && x.verdict.real))
    log(`Round ${round}: ${fresh.length} fresh, ${verified.filter(x => x && x.verdict && x.verdict.real).length} survived verification`)
  }
  if (round < 4) {
    const critic = await agent(
      `${preamble}\nCOMPLETENESS CRITIC. So far the CONFIRMED findings (titles plus evidence) are:\n${confirmed.map(f => '- ' + f.title + '  [' + (f.evidence || '') + ']').join('\n') || '(none yet)'}\n\nName concrete GAPS: architecture files/subsystems/claims NOT yet examined, or confirmed findings whose ROOT CAUSE or BLAST RADIUS is unverified. For each gap give a precise follow-up audit instruction. Return [] if coverage is genuinely exhaustive.`,
      { label: `critic:r${round}`, phase: 'Critic', schema: GAPS })
    toRun = (critic.gaps || []).filter(g => g && !seen.has('gap|' + g.key)).map(g => { seen.add('gap|' + g.key); return g })
    if (!toRun.length) { dry++; log(`Round ${round}: critic found no fresh gaps (dry ${dry}/2)`) }
  } else { toRun = [] }
}

log(`Sweep complete: ${confirmed.length} confirmed findings over ${round} round(s). Synthesizing.`)

const roadmap = await agent(
  `${preamble}\nSYNTHESIZE the final architecture study. Here are the VERIFIED findings:\n${JSON.stringify(confirmed, null, 1)}\n\n` +
  `Deduplicate, group by theme, and produce a PRIORITIZED roadmap ranked by (severity times leverage divided by effort). For each item give rank, title, severity, leverage, effort, the concrete fix, and any dependency. ` +
  `Then give an honest confidence_grade (0-10) for whether this study is ready for a PLAN phase, and list residual_risks / things still uncertain. The bar is FLAWLESS, so be rigorous about what is proven vs assumed.`,
  { label: 'synthesize', phase: 'Synthesize', schema: ROADMAP })

return { rounds: round, confirmed_count: confirmed.length, confirmed, roadmap }
