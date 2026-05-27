# PR-S01 — README refresh
Project:     axon-docs
Created:     2026-05-17
Complexity:  M
Depends on:  none
Touches axon/: no
Status:      complete (2026-05-17, awaiting user review + commit)
AXON score:  9/10

## Summary
Refresh `README.md` to match current AXON state: trim the Quick-Start,
scrub deprecated subsystem mentions, fix install instructions, add a
"Read in this order" navigation block (T4), and add CI / tests-mandatory /
coverage badges shipped by axon-tests PR-021. README is the first doc
every new reader sees — every other PR in this project depends on it
being accurate.

## Goal Context
From `01-study.md`:
- G1 — README still references `semantic-search` (removed in
  axon-cleanup wave 2) and `requirements.txt` (replaced by
  `pyproject.toml`).
- T3 — "remove `semantic-search` mentions; reduce Quick-Start to 6
  lines; replace `requirements.txt` references with
  `pip install -e \".[dev]\"`; add a 'Where to read more'
  navigation block."
- T4 — navigation map (7-step read order ending at KERNEL-SLIM →
  CONTRIBUTING) lands here as a `## Read in this order` section.

## Entry Conditions
- `README.md` exists at repo root.
- `pyproject.toml` is the live dep source (verified — present at root).
- `AXON-DOCS-CI.md` does NOT yet exist (PR-N01 lands later); README
  may forward-reference it as "see AXON-DOCS-CI.md (coming in PR-N01)"
  or simply link to `.github/workflows/ci.yml` for now. Decision below.

## Changes Required

### README.md
- **Quick-Start trim** — current Quick-Start block is >6 lines and
  cites `pip install -r requirements.txt`. Replace with exactly 6
  lines, ending in `python3 axon.py boot`. Install line becomes
  `pip install -e ".[dev]"`.
- **Scrub deprecated subsystems** — remove every mention of:
  `semantic-search`, `chromadb`, `sentence-transformers`, `torch`.
  Also remove references to the removed `tools/semantic_search.py`
  if present.
- **Tool count refresh** — any number-of-tools mention updated to
  the live `REGISTRY.json` count (75 at study time; PR will re-read
  live count before writing).
- **Test count refresh** — any "1929" / "315" / similar updated to
  the live `pytest --collect-only -q` count (2880+ at study time).
- **Add badges block** at the top (echoes PR-021):
  - CI status (`tests-full` workflow)
  - Coverage (`tools/rules/*` 100 %, `tools/*` 80 %)
  - Tests-mandatory marker
  - docgen-strict marker
- **Add `## Read in this order` section** (T4):
  1. `README.md` — overview (this file)
  2. `SETUP.md` — install
  3. `axon/HOWTO.md` — first workflow
  4. `WORKFLOW.md` — full workflow narrative
  5. `workspace/AXON-DOCS-*.md` — authoritative subject pages
  6. `axon/KERNEL-SLIM.md` — kernel contract (read before editing `axon/`)
  7. `CONTRIBUTING.md` — for contributors
- **Forward-reference policy** — for `AXON-DOCS-CI.md`,
  `AXON-DOCS-DEPRECATIONS.md`, `AXON-DOCS-ARCHITECTURE.md` (none
  exist yet), use the form `(see AXON-DOCS-CI.md — coming in PR-N01)`
  rather than linking to a missing file. After phase 3 closes, PR-N01..N03
  will rewrite these as live links.

### `## Guarded by` block
README itself is not currently a `## Guarded by` doc. PR-T01 adds
`tests/test_no_stale_subsystems.py` which guards README against
re-introducing deprecated terms. Forward-reference the test by name
in a footer comment.

## Out of Scope
- No code, tool, or test changes (T01 handles the deprecation test).
- No changes to other docs (S02 owns CHANGELOG/CONTEXT, S03/04/05
  own the rest).
- No new subsystem-map content (PR-N03 owns the architecture page).

## Exit Conditions
- `README.md` contains zero matches for any of:
  `semantic-search | chromadb | sentence-transformers | torch | requirements.txt`.
- Quick-Start block is 6 lines.
- `## Read in this order` section present.
- Live tool/test counts present (with the date they were read).
- Badges block present.
- `grep -nE 'semantic-search|chromadb|sentence-transformers|torch' README.md`
  returns no matches.

## Risk
- **Low.** README is documentation only, no machine code paths touch it.
- Forward-references to PR-N01..N03 must be parenthetical, not links,
  to avoid broken-link CI noise. (Verified: docgen-strict only guards
  `AXON-DOCS-*.md`, not README, so broken links would not currently
  fail CI — but they would in PR-T01's strict extension.)

## Plan
1. Read live counts: `pytest --collect-only -q | tail -1` (test count),
   `python -c "import json; print(len(json.load(open('tools/REGISTRY.json'))))"`
   (tool count). Capture date.
2. Edit `README.md` per "Changes Required".
3. Run `grep -nE 'semantic-search|chromadb|sentence-transformers|torch|requirements.txt' README.md` — must return empty.
4. Append round entry to `04-log.md`.
5. Surface for review. Agent does NOT run pytest, git add, git commit,
   or git push — user does that.

## Status notes
- Awaits user `go PR-S01` (or `start`) to begin step 2.
