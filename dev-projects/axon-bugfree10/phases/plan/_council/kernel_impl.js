export const meta = {
  name: 'axon-bugfree10-kernel-impl',
  description: 'Implement 7 kernel PRs in parallel (worktree-isolated): fix + tests + patch per PR',
  phases: [{ title: 'Implement', detail: 'one worktree-isolated agent per kernel PR' }],
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
    files_changed: { type: 'array', items: { type: 'string' } },
    tests_added: { type: 'array', items: { type: 'string' } },
    self_test: {
      type: 'object',
      properties: {
        ran: { type: 'boolean' },
        command: { type: 'string' },
        result: { type: 'string', enum: ['pass', 'fail', 'n/a'] },
        detail: { type: 'string' },
      },
      required: ['ran', 'result'],
    },
    patch_written: { type: 'boolean' },
    patch_path: { type: 'string' },
    notes: { type: 'string' },
    owner_scrutiny: { type: 'string', description: 'anything the owner should look at closely' },
  },
  required: ['pr_id', 'bugs_fixed', 'files_changed', 'patch_written'],
}

function implPrompt(pr) {
  return `You are implementing ONE kernel-floor PR on AXON. You are in an ISOLATED git worktree — edit files freely; nothing you do here touches the owner's main tree until they approve.

YOUR PR: ${pr.pr_id} — ${pr.title}
Files you own (edit ONLY these): ${pr.files.join(', ')}

STEP 1 — read the precise bug specs:
  python3 -c "import json;d=json.load(open('${SPEC}'));p=[x for x in d['prs'] if x['pr_id']=='${pr.pr_id}'][0];print(json.dumps(p['bugs'],indent=1))"
Each bug has: file, line, severity, category, summary, failure_scenario (a concrete repro).

STEP 2 — for EACH bug, read the real file under ${ROOT}/ (your cwd IS the repo root of your worktree, so the file paths are relative), understand the failure_scenario, and implement the MINIMAL correct fix. Do not refactor beyond the bug. Preserve behavior for the non-buggy path.

STEP 3 — tests:
  - For a Python (.py) bug: add or extend a pytest test under tests/ that FAILS before your fix and PASSES after (a real regression test tied to the failure_scenario). Name it clearly.
  - For a Markdown (.md / .tpl.md) bug (KERNEL-SLIM.md, compiler templates, kernel program specs): these are pseudocode/spec — a pytest may not apply. If a structural/lint check fits (e.g. an existing linter that would now catch the old bug), add it; otherwise state in notes that verification is by structural review and describe exactly what changed and why it is correct. Do NOT fabricate a passing test.

STEP 4 — self-verify: run ONLY your targeted tests (NOT the full suite), e.g. \`python3 -m pytest tests/your_test.py -q\`. Record the command + result.

STEP 5 — emit your patch (from your worktree root):
  git add -A && git diff --cached HEAD > ${PATCHDIR}/${pr.pr_id}.patch
  Confirm the file is non-empty.

RULES: edit ONLY your listed files (+ your new test files under tests/). This is kernel code — correctness over cleverness. If a bug's failure_scenario does not actually reproduce against the real current code, do NOT invent a change: report it in notes with result n/a and skip it.

Return the structured summary (include owner_scrutiny for anything delicate — especially any KERNEL-SLIM.md change).`
}

const prs = A.prs
phase('Implement')
const results = (await parallel(prs.map((pr) => () =>
  agent(implPrompt(pr), {
    label: `kimpl:${pr.pr_id}`,
    phase: 'Implement',
    effort: 'high',
    isolation: 'worktree',
    agentType: 'general-purpose',
    schema: IMPL_SCHEMA,
  })
))).filter(Boolean)

for (const r of results) {
  log(`${r.pr_id}: ${r.bugs_fixed.length} fixed · ${(r.files_changed || []).length} files · patch=${r.patch_written} · self-test=${r.self_test ? r.self_test.result : '?'}`)
}

return {
  prs_implemented: results.length,
  results,
}
