# Build-driver workflow preference (cpg-to-unstructure)

User stated 2026-05-21T15:29 — applies to all `prN-build.sh` scripts:

> "I prefer you organize and commit things, select branch
>  automatically, we just push."

## Required behaviour for every prN-build.sh

Step 2 ("branch") must be self-healing — the user does not babysit
git state. Concretely:

1. `git fetch origin --quiet`.
2. If working tree is dirty (tracked or untracked), `git stash push -u`.
3. `git checkout main && git pull --ff-only origin main`.
4. Auto-prune local `pr-*` branches whose remote is gone (squash-merged
   PRs). Never touch `main`, never touch the current target branch.
5. `git checkout -B pr-NN-<slug>` (create if absent, switch if present).
6. `git stash pop` (so any in-flight PR-N edits land on the new branch).

Subsequent steps (install, smoke, pytest, commit, push, `gh pr create`)
stay as-is. The user's only job is:

```bash
./prN-build.sh --pr
```

Driver scripts live at `/mnt/c/projects/prN-build.sh` (one per PR).
