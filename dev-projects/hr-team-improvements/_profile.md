# Profile — HR-Team Improvements
codebase:      /home/arturcastiel/projects/new-axon/axon
vcs:           git
remote:        GitLab (artur.castiel-tno/axon)
review-guide:  CONTRIBUTING.md
linter:        ruff check .
test-runner:   python3 -m pytest   # HUMAN-run unless AEGIS test-execution grant + crucible green
cross-repo:    ["for-use checkout: /mnt/c/projects/library-development/axon"]   # the divergent copy to reconcile
key-files:     tools/hr_team.py · workspace/programs/hr-team*.md · workspace/hr-team/catalog/professions/
