# CD·TOOLS·P4 — prior art for verb-centric CLI organization

> External validation: every mature CLI of this size uses 8–15 top-level verbs with sub-commands. The proposed 10-verb umbrella matches industry pattern, not novel.

## Comparable CLIs (verb count + subcommand depth)

| CLI       | Top-level verbs | Sub-commands per verb | Notes |
|-----------|----------------:|----------------------:|-------|
| `git`     | ~15 plumbing + ~30 porcelain | shallow | huge surface; relies on `git help` and abbreviations |
| `gh`      | ~12 (issue, pr, repo, run, workflow, …) | 5–10 each | clean grouping; widely cited as a good model |
| `kubectl` | ~10 verbs (get, create, apply, …) + ~30 nouns | 2 layers (verb × noun) | matrix model; works for resource-style CLIs |
| `docker`  | ~10 verbs (container, image, network, volume, …) | 5–10 each | recently refactored from flat verbs to nouns + verbs |
| `aws` (CLI)| ~300 services × ~20 verbs each | 2 layers | extreme scale; verb-noun fully required |
| `terraform`| ~15 verbs              | shallow | flat; works because each verb is conceptually distinct |
| `npm`     | ~30 flat verbs         | shallow | flat; works because users learn the dozen they use |
| `cargo`   | ~20 verbs              | shallow | flat; sub-commands are extensions |
| `gt` (Graphite) | ~12 verbs (branch, stack, repo, log, …) | 5–10 each | matches our scope very closely |
| `gs` (git-spice) | ~10 verbs        | similar grouping |

**Take:** the proposed 10-verb umbrella (`lifecycle`, `state`, `journal`, `pr`, `review`, `shape`, `safety`, `knowledge`, `flow`, `meta`) is well within industry norms.

## CLI design principles that apply

### From `gh` (and the GitHub CLI design doc)
- Group by **noun the user thinks about** (issue, pr, repo) rather than by *action*.
- Every verb has consistent sub-commands: `list`, `view`, `create`, `delete`, `edit`.
- `gh <verb> --help` is the discovery surface — don't make users grep the man page.
- One-line summary per verb in the top-level `gh --help`.

**Mapped to code-dev:**
- `code-dev pr list/view/create/update-spec/review/respond/ready/github` matches this idiom.
- `code-dev state status/next/resume/save/restore` matches `gh issue` style.

### From `kubectl`
- Verb × resource: `get pods`, `describe deployment`. Predictable.
- `--output` flag on every verb for machine-readable forms.

**Mapped to code-dev:**
- `code-dev pr view 3 --output json` becomes natural.
- `code-dev safety preflight --output summary` (already proposed as `--mode=summary`).

### From Docker's flat→grouped migration
- Docker famously moved from `docker run|ps|images|rm` to `docker container run|ls|rm`, `docker image ls`, etc.
- They KEPT the flat verbs as aliases for years (and most users still use them).
- **Lesson:** alias-stubs work; deprecate slowly.

### From `git`
- "Plumbing vs porcelain" distinction. We've informally done this too (router + internal programs).
- `git stash {push|pop|list|show|drop}` is the closest mirror of our proposed `state save/restore/list/undo`.

### From `gt` (Graphite)
- `gt branch track/submit/restack`, `gt stack submit/restack/sync`.
- This is *exactly* the model `code-dev pr stack {new|restack|push|list}` (Wave 6) would follow.

## Migration playbooks (external)

### Docker
- Phase 1 (Docker 1.13): add `docker container`, `docker image`, etc. as new groups. Old verbs work.
- Phase 2 (Docker 17.06+): document the new way; old way deprecated in docs.
- Phase 3 (years later): old verbs still work. Migration is opt-in.

**Take:** our W2 (alias stubs) + W5 (drop stubs) is more aggressive. Could relax W5 to "keep stubs indefinitely" given low maintenance cost.

### `npm` → `pnpm` / `yarn`
- New tools introduced incompatibly; migration was external.
- **Take:** doesn't apply — we're not introducing a new tool.

### Kubernetes `kubectl get` evolution
- Added `--output` formats one at a time over years.
- Each addition was independently shippable.
- **Take:** matches our wave model (each wave independently shippable).

## CLI documentation patterns

### gh-style help
```
USAGE
  code-dev <verb> <subcommand> [flags]

CORE VERBS
  state       project state, status, resume, save/restore
  journal     log, decision, event, search, since
  pr          PR specs, review, respond, ready, github, stack
  …

EXAMPLES
  code-dev state status
  code-dev pr create 3
  code-dev pr review 3 --quick
```

### kubectl-style help
```
Usage:
  code-dev [command]

Available Commands:
  …

Flags:
  -h, --help              help for code-dev
  -v, --verbose           verbose output

Use "code-dev [command] --help" for more information about a command.
```

**Take:** gh-style fits AXON markdown better (less chrome). Adopt for `code-dev help` output.

## Anti-patterns to avoid (from prior art)

1. **AWS-style verbosity** (`aws s3api list-objects-v2 --bucket …`). Too deep. Cap at 2 levels.
2. **`docker -f`-style global flags** that confuse users (interaction with sub-commands). Keep flags scoped to the subcommand.
3. **`git`-style abbreviations** (`git ci`) — confusing for newcomers. Prefer explicit.
4. **`make`-style "everything is a target"** — destroys discoverability. We're already past this.
5. **`npm`-style "the deprecated way is now the new way"** — versioning chaos. Stick to wave plan.

## Free-text dispatch alignment

The kernel's `dispatch.py` matches free-text prompts to programs using TF-IDF over `# desc:` lines. After Wave 1 (routers added), each router gets a strong `# desc:` matching a broad query like *"work with a PR"* → routes to `code-dev pr`. Sub-commands handle drilling down.

**Take:** verb-centric naming aligns with how users phrase requests. *"Review my PR"* → matches `code-dev pr review N` more strongly than the 8 candidate programs today.

## Open questions (cycle-5 candidates)
- Should the routers themselves accept `--help` and produce a sub-command listing? (Yes — adopt gh-style.)
- Should `code-dev state save` and `code-dev pr stack` both use the word "save"? (No — `state save` is checkpoint, `pr stack create` is structural.)
- Where do `whatif` and `help` live? (Under `meta` — fine; alternative: top-level.)
- Should `library-dev` adopt the same verb pattern? (Yes — separate study.)

## Summary

The proposed 10-verb umbrella is **incremental, validated by 10+ mature CLIs, and migration-safe** (alias stubs preserve every old invocation through ≥1 release). The expected user-visible result is:
- Fewer top-level options to choose from (10 vs 57)
- Better dispatch from free-text prompts
- Cleaner help output (`code-dev pr --help` shows ~11 things instead of grepping 57 program files)
- Same workflow capability — no functionality removed

The only genuinely novel element is the **group naming** (`lifecycle`, `safety`, `knowledge`, `flow`) — but those names are descriptive and align with how users discuss code-dev workflows in chats.

→ executive summary + integration with cycle-1..4 top-15 in `cd-tools-summary.md` (next).
