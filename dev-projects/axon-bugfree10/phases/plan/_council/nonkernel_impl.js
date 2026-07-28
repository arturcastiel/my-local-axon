export const meta = {
  name: 'axon-bugfree10-nonkernel-impl',
  description: 'Implement 24 non-kernel PRs in parallel (worktree-isolated): fix + tests + patch per PR',
  phases: [{ title: 'Implement', detail: 'one worktree-isolated agent per non-kernel PR' }],
}

const A = (typeof args === 'string') ? JSON.parse(args) : args
const ROOT = A.root
const SPEC = A.specPath
const PATCHDIR = A.patchDir

const IMPL_SCHEMA = {
  type: 'object',
  properties: {
    pr_id: { type: 'string' },
    bugs_fixed: { type: 'array', items: { type: 'string' } },
    bugs_skipped: { type: 'array', items: { type: 'string' } },
    files_changed: { type: 'array', items: { type: 'string' } },
    tests_added: { type: 'array', items: { type: 'string' } },
    self_test: {
      type: 'object',
      properties: {
        ran: { type: 'boolean' }, command: { type: 'string' },
        result: { type: 'string', enum: ['pass', 'fail', 'n/a'] }, detail: { type: 'string' },
      },
      required: ['ran', 'result'],
    },
    patch_written: { type: 'boolean' },
    notes: { type: 'string' },
  },
  required: ['pr_id', 'bugs_fixed', 'files_changed', 'patch_written'],
}

function implPrompt(pr) {
  return `You are implementing ONE PR of a bug-fix release on AXON (an OS-for-AI-agents: Python tools in tools/*.py + Markdown "programs" in workspace/programs/*.md written in AXON-LANG pseudocode). You are in an ISOLATED git worktree — edit freely; nothing merges until a human approves.

YOUR PR: ${pr.pr_id} — ${pr.title}
Files you own (edit ONLY these + new tests): ${pr.files.join(', ')}
${pr.depends_on && pr.depends_on.length ? `NOTE: plan lists depends_on ${pr.depends_on.join(',')} (a sibling PR). Your files are disjoint from theirs, so implement your fix self-containedly. If your fix would ideally reuse a helper another PR introduces, it is fine to implement it correctly within your own files — integration combines all PRs.` : ''}

STEP 1 — read your precise bug specs:
  python3 -c "import json;d=json.load(open('${SPEC}'));p=[x for x in d['prs'] if x['pr_id']=='${pr.pr_id}'][0];print(json.dumps(p['bugs'],indent=1))"
Each bug: id, file, line, severity, category, summary, failure_scenario (concrete repro).

STEP 2 — for EACH bug, read the real file under ${ROOT}/ (paths are repo-relative; your worktree root IS the repo root), understand the failure_scenario, implement the MINIMAL correct fix. No refactoring beyond the bug. Preserve the non-buggy path.

STEP 3 — tests: for a .py bug add/extend a pytest under tests/ that FAILS before / PASSES after (tied to the failure_scenario). For a .md program bug, add a structural test if one fits (assert the fixed token/branch exists), else state in notes that verification is structural and describe the change. Do NOT fabricate a passing test.

STEP 4 — self-verify: run ONLY your targeted tests (NOT the full suite). Record command + result.

STEP 5 — emit your patch from your worktree root:
  git add -A && git diff --cached HEAD > ${PATCHDIR}/${pr.pr_id}.patch
  Confirm it is non-empty.

RULES: edit ONLY your listed files (+ your new tests). Minimal, correct fixes. If a bug's failure_scenario does not reproduce against the real current code, do NOT invent a change — list it in bugs_skipped with the reason.

Return the structured summary.`
}

const prs = A.prs
phase('Implement')
const results = (await parallel(prs.map((pr) => () =>
  agent(implPrompt(pr), {
    label: `nkimpl:${pr.pr_id}`,
    phase: 'Implement',
    effort: 'high',
    isolation: 'worktree',
    agentType: 'general-purpose',
    schema: IMPL_SCHEMA,
  })
))).filter(Boolean)

let fixed = 0, skipped = 0
for (const r of results) {
  fixed += (r.bugs_fixed || []).length
  skipped += (r.bugs_skipped || []).length
  log(`${r.pr_id}: ${(r.bugs_fixed || []).length} fixed, ${(r.bugs_skipped || []).length} skipped · patch=${r.patch_written} · self-test=${r.self_test ? r.self_test.result : '?'}`)
}
return { prs_implemented: results.length, bugs_fixed: fixed, bugs_skipped: skipped, results }
