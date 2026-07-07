# Legacy binary storage — FlowSim large files

_Owner-authorised Option D relocation (2026-07-03)._

Files here were previously committed to the FlowSim repo at its root but
exceeded GitHub's 50 MB threshold. Moved out so FlowSim stays lean.

## Files

| File | Size | Purpose |
|---|---:|---|
| `gmsh.exe` | 64 MB | Windows binary of Gmsh mesh generator — should be installed via package manager |
| `spe10.mat` | 35 MB | SPE10 permeability field data |
| `spe_perm.dat` | 55 MB | SPE benchmark raw permeability |

## Restoration

FlowSim's `+fs.data.paths` returns the path here when queried:
`p = fs.data.paths('spe10')` → this folder's `spe10.mat`.

To make FlowSim see them at legacy locations, symlink back:
```bash
cd ~/projects/contreras/FlowSim
ln -s ~/projects/new-axon/axon/my-axon/dev-projects/flowsim-vectorize/data/legacy-binaries/spe10.mat .
ln -s ~/projects/new-axon/axon/my-axon/dev-projects/flowsim-vectorize/data/legacy-binaries/spe_perm.dat .
```

**Never commit these back** — `.gitignore` catches `spe*.mat`, `spe*.dat`, `gmsh.exe`.

## History note

Files remain in FlowSim git history until an owner-authorized `git filter-repo`
pass. Fresh clones still download ~155 MB. That cleanup requires force-push.
