export const meta = {
  name: 'axon-bugfree10-swarm',
  description: 'HR-swarm bug hunt over AXON: 8 parts x 10 finder seats -> dedup -> adversarial verify',
  phases: [
    { title: 'Hunt', detail: '10 finder seats per part read their slice and report grounded bugs' },
    { title: 'Verify', detail: '2-lens adversarial verification of each deduped candidate' },
  ],
}

const FINDER_SCHEMA = {
  type: 'object',
  properties: {
    bugs: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          file: { type: 'string', description: 'repo-relative path' },
          line: { type: 'integer' },
          severity: { type: 'string', enum: ['critical', 'high', 'medium', 'low'] },
          category: { type: 'string' },
          summary: { type: 'string' },
          failure_scenario: { type: 'string', description: 'concrete inputs/state -> wrong behavior' },
          confidence: { type: 'number' },
        },
        required: ['file', 'severity', 'summary', 'failure_scenario'],
      },
    },
  },
  required: ['bugs'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    real: { type: 'boolean' },
    verdict: { type: 'string', enum: ['CONFIRMED', 'PLAUSIBLE', 'REFUTED'] },
    reason: { type: 'string' },
    corrected_severity: { type: 'string', enum: ['critical', 'high', 'medium', 'low'] },
  },
  required: ['real', 'verdict', 'reason'],
}

const A = (typeof args === 'string') ? JSON.parse(args) : args
const ROOT = A.root
const MPATH = A.manifestPath
const SEV = { critical: 0, high: 1, medium: 2, low: 3 }

function resolveCmd(partId, seatNo) {
  return `python3 -c "import json; m=json.load(open('${MPATH}')); p=next(x for x in m['parts'] if x['id']=='${partId}'); s=next(y for y in p['seats'] if y['seat']==${seatNo}); print('\\n'.join(m['root']+'/'+f for f in s['files']))"`
}

function finderPrompt(part, seatNo) {
  return `You are seat ${seatNo} of a 10-member bug-hunting council auditing part "${part.id}" (${part.theme}) of AXON.

AXON is an "operating system for AI agents": a Python tool layer (tools/*.py, entrypoint axon.py) plus a corpus of Markdown "programs" written in a symbolic pseudo-language (AXON-LANG: ops like EXEC/RETRIEVE/ASSERT/IF/STORE, memory scopes W:/L:/E:, TOOL(name, sub, --flags) calls). Programs route commands and orchestrate the Python tools.

STEP 1 — get YOUR assigned files. Run exactly this shell command:
${resolveCmd(part.id, seatNo)}

STEP 2 — Read EACH listed file IN FULL with the Read tool (they are small). Read related files if needed to judge a suspected bug.

STEP 3 — hunt for REAL bugs. Prioritize: logic errors; wrong/misspelled state keys; dead or unreachable branches; gate/guard bypasses (fail-open where fail-closed intended); unhandled exceptions & swallowed errors; incorrect regex; off-by-one/boundary; resource leaks (unclosed files/procs); ordering/race hazards; wrong tool invocation or arg marshaling; contract/schema violations; stale pointers. In .md programs: broken routing (first-match-wins shadowing), unreachable IF branches, undefined {interpolations}, missing DONE/phase-state writes, two-token dispatch errors.

RULES (grounded claims — non-negotiable):
- Report ONLY bugs tied to a concrete file:line AND a concrete failure_scenario (specific inputs/state -> specific wrong behavior). No style nits, no "consider refactoring", no speculation.
- If your slice is clean, return an empty bugs array. Do NOT invent findings.
- Report at most your 5 highest-confidence REAL bugs.
- Files under axon/ are a human-only kernel floor: still report findings, but they are advisory only.

Return the structured bug list (file is repo-relative, e.g. "tools/foo.py").`
}

function verifyPrompt(b, lens) {
  const lensText = lens === 0
    ? 'CORRECTNESS — read the actual code and determine whether the described failure genuinely occurs for the stated inputs/state.'
    : 'REFUTATION — actively try to prove this is NOT a real bug: a guard elsewhere, an unreachable/dead input, a misread of the code, or behavior that is actually intended.'
  return `Adversarially verify a candidate bug in the AXON codebase. YOUR LENS: ${lensText}

Candidate:
  file: ${ROOT}/${b.file}
  line: ${b.line || '?'}
  severity: ${b.severity}
  category: ${b.category || '-'}
  summary: ${b.summary}
  failure_scenario: ${b.failure_scenario}

Read the real file with the Read tool (and any related file needed via Read/Grep). Reproduce the logic mentally. Default to REFUTED if you cannot substantiate the failure from the ACTUAL code. Set real=true and verdict=CONFIRMED only if the failure scenario genuinely holds; use PLAUSIBLE if real but the scenario is imprecise. Give a one-to-two sentence reason citing what you saw in the code.`
}

const parts = A.parts

const results = await pipeline(
  parts,
  // STAGE 1 — hunt: 10 seats read their slice in parallel, then dedup within the part
  async (part) => {
    const seatResults = await parallel(
      Array.from({ length: part.nseats }, (_, i) => i + 1).map((seatNo) => () =>
        agent(finderPrompt(part, seatNo), {
          label: `hunt:${part.id}:s${seatNo}`,
          phase: 'Hunt',
          schema: FINDER_SCHEMA,
        })
      )
    )
    const raw = seatResults.filter(Boolean).flatMap((r) => r.bugs || [])
    const seen = new Set()
    const deduped = []
    for (const b of raw) {
      const k = `${b.file || ''}::${b.line || ''}::${(b.summary || '').slice(0, 40).toLowerCase()}`
      if (!seen.has(k)) { seen.add(k); deduped.push(b) }
    }
    deduped.sort((a, b) => (SEV[a.severity] ?? 9) - (SEV[b.severity] ?? 9) || (b.confidence || 0) - (a.confidence || 0))
    const CAP = 12
    const kept = deduped.slice(0, CAP)
    if (deduped.length > CAP) log(`${part.id}: ${deduped.length} candidates -> verifying top ${CAP} (dropped ${deduped.length - CAP} lower-severity)`)
    else log(`${part.id}: ${kept.length} candidate bug(s) after dedup`)
    return { part: part.id, theme: part.theme, raw_count: raw.length, candidates: kept }
  },
  // STAGE 2 — verify: each candidate gets a 2-lens skeptic panel
  async (hunt) => {
    const verified = await parallel(
      hunt.candidates.map((b) => () =>
        parallel([0, 1].map((lens) => () =>
          agent(verifyPrompt(b, lens), {
            label: `verify:${hunt.part}:${(b.file || '').split('/').pop()}`,
            phase: 'Verify',
            effort: 'high',
            schema: VERDICT_SCHEMA,
          })
        )).then((votes) => {
          const good = votes.filter(Boolean)
          const reals = good.filter((v) => v.real).length
          const refuted = good.filter((v) => v.verdict === 'REFUTED').length
          let status
          if (good.length === 0) status = 'unverified'   // verify never ran (error/limit) — NOT refuted
          else if (reals >= 2) status = 'confirmed'
          else if (refuted >= 2) status = 'refuted'
          else if (reals >= 1) status = 'plausible'
          else status = 'refuted'
          const corrected = good.map((v) => v.corrected_severity).filter(Boolean)
          return { ...b, status, severity: corrected[0] || b.severity, votes: good.map((v) => ({ verdict: v.verdict, reason: v.reason })) }
        })
      )
    )
    const findings = verified.filter(Boolean)
    const conf = findings.filter((f) => f.status === 'confirmed').length
    const plaus = findings.filter((f) => f.status === 'plausible').length
    const ref = findings.filter((f) => f.status === 'refuted').length
    const unver = findings.filter((f) => f.status === 'unverified').length
    log(`${hunt.part}: verified -> ${conf} confirmed, ${plaus} plausible, ${ref} refuted, ${unver} unverified`)
    return { part: hunt.part, theme: hunt.theme, raw_count: hunt.raw_count, findings }
  }
)

const ledger = results.filter(Boolean)
const flat = ledger.flatMap((p) => p.findings.map((f) => ({ ...f, part: p.part })))
const confirmed = flat.filter((f) => f.status === 'confirmed')
const plausible = flat.filter((f) => f.status === 'plausible')
const unverified = flat.filter((f) => f.status === 'unverified')
const refutedAll = flat.filter((f) => f.status === 'refuted')
return {
  parts: ledger.length,
  totals: {
    raw: ledger.reduce((s, p) => s + (p.raw_count || 0), 0),
    confirmed: confirmed.length,
    plausible: plausible.length,
    unverified: unverified.length,
    refuted: refutedAll.length,
  },
  ledger,
}
