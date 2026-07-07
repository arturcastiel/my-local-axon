# MATLAB WSL Bridge (`mrun`)

_Owner grant 2026-07-03: "I grant autonomous use of MATLAB entirely" (AXON project flowsim-vectorize AEGIS policy)._

## What it is

`mrun` is a bash wrapper at `FlowSim/tools/mrun` that lets us call MATLAB from a WSL terminal:

```
mrun <script.m>                          # run a script from anywhere
mrun -e "matlab expression"              # run a MATLAB expression
mrun -c <cwd> <script.m>                 # cd to <cwd> before running
mrun -c <cwd> -e "..."                   # same for -e
mrun -t 3600 <script.m>                  # override 30-min default timeout
mrun -L <script.m>                       # auto-log to /tmp/mrun-logs/YYYYMMDD-HHMMSS-name.log
mrun -l /path/to/log.txt <script.m>      # tee to specific logfile
mrun -q <script.m>   / -v <script.m>     # explicit quiet / verbose
```

## What it invokes

```
matlab.exe -batch "<preamble>; <MATLAB_CMD>"  2>&1  | tr -d '\b\r'  | awk-filter  | tee?
```

- `matlab.exe` — Windows-side MATLAB R2024a (auto-discovered on WSL PATH)
- `-batch` — headless mode (no GUI, no splash, no JVM UI, no user prompts, exits after)
- `<preamble>` — auto-injected (unless `-v`):
  - `warning off backtrace` — single-line warnings (no "In foo/In bar" stacks)
  - `warning('off','MATLAB:mpath:nonExistentOrNotADirectory')` — silences the "Name is nonexistent" flood
  - `cd('<UNC Windows path>')` — from `-c` (auto-resolved to Windows form via `wslpath -w`)
- `<MATLAB_CMD>` — for a script, `addpath('<dir>'); evalin('base', fileread('<script>'))`. We use `fileread` + `evalin` instead of `run(...)` because MATLAB's `run()` cd's to the script's directory, defeating our `-c`.
- `tr -d '\b\r'` — strips MATLAB's Windows-console artefacts (leading backspace on warnings + CRLF line endings) so the awk filter can match line-anchored regex.
- awk filter — matches known-harmless WSL warning blocks and skips them + their multi-line continuations (until closing `]`).
- `tee` — optional, when `-l` or `-L` is passed.

## Runtime characteristics (measured)

| Scenario | Elapsed |
|---|---:|
| MATLAB cold start (fresh session, `-batch "disp('x')"`) | ~50 s |
| Warm re-invocation (right after another mrun call) | ~14 s |
| Loading FlowSim's `startup.m` + 5 subfolder addpath's | ~5 s within cold start |
| Full class-hierarchy probe (14 classes via `meta.class.fromName`) | ~1 s within warm run |
| Default hard timeout | 30 min (1800 s) |

Exit codes:
- `0` — MATLAB succeeded
- `1..99` — MATLAB reported an error (see stdout for the `{Error using ...}` block)
- `2` — mrun argument error
- `124` — mrun killed MATLAB via timeout

## What works today (verified via TEST 9)

- ✓ Script arg (WSL path → auto-detected → invoked from any cwd)
- ✓ `-e "expr"` mode
- ✓ `-c <dir>` overrides implicit cd (verified against MATLAB's own `pwd`)
- ✓ Warning suppression (verified: no leaked lines from a script that would normally emit 5+ addpath warnings)
- ✓ Try/catch propagation — MATLAB errors report cleanly with exit=1
- ✓ FlowSim's own `base/startup.m` runs automatically (prints "Paths configurados com sucesso.")
- ✓ Class-hierarchy checks return real MATLAB metadata (method counts, superclass names)
- ✓ Timeouts kill hung MATLAB jobs and report distinctly

## What it does NOT do

- No `-desktop` or `-nodesktop` or `-nojvm` fallbacks — always headless. There is no interactive path through mrun by design.
- No parallel jobs — one MATLAB per invocation. If you need parallel, wrap with GNU parallel.
- No log ROTATION — `-L` files accumulate in `/tmp/mrun-logs/`; clean up manually.
- No `.p` (protected) file support — MATLAB reads them fine, but we don't have a special path.
- No transfer of `stdin` — MATLAB has no interactive prompt.

## Confirmed study findings from real MATLAB (bonus)

Running `/tmp/flowsim_probe.m` via mrun on 2026-07-03:

| Study assertion | MATLAB verdict |
|---|---|
| `MetodoBase` + `MetodoMPFAD` + `MetodoTPFA` are alive | ✓ 31 / 32 / 31 methods, correct superclasses |
| `SolverBase` file is missing | ✓ "not found (no class file)" |
| `SolverMPFAH` + `SolverNLFVPP` cannot instantiate | ✓ MATLAB literally says: "The specified superclass 'SolverBase' contains a parse error, cannot be found on MATLAB's search path" |
| `BenchmarkBase` file is missing | ✓ "not found (no class file)" |
| `Caso1.m` is broken via missing `BenchmarkBase` | ✓ "BenchmarkBase contains a parse error, cannot be found" |
| `Caso439` is the only working benchmark | ✓ Loads with 51 methods, base = SimulacaoBase |
| `Caso331`, `Caso437` etc. are missing | ✓ "not found (no class file)" |

Every hard structural claim in the study is now verified against MATLAB itself, not just grep.

## Test scripts

- `/tmp/flowsim_probe.m` — resilient class-hierarchy probe (used for TEST 9 above)

## Reference invocation

```bash
# Simple: run a script from FlowSim's own dir
tools/mrun myscript.m

# Explicit cwd (e.g., run a test that lives outside FlowSim but must operate on FlowSim data):
tools/mrun -c /home/arturcastiel/projects/contreras/FlowSim /tmp/myprobe.m

# One-shot expression (checking MATLAB version, quick sanity):
tools/mrun -e "disp(version); disp(computer)"

# With auto-log for a long-running benchmark:
tools/mrun -L -c /home/arturcastiel/projects/contreras/FlowSim benchmarks/bench_mpfad.m

# Extended timeout for a big-mesh case (2 hours):
tools/mrun -t 7200 tests/richards_caso439_192x192.m
```

## Scope (per AEGIS policy)

Allowed autonomous MATLAB invocations under owner grant 2026-07-03:
- `matlab.exe -batch` on any `.m` in `/home/arturcastiel/projects/contreras/FlowSim/` or subdirs of `/tmp/`
- Writes to `FlowSim/*` (results, `.mat`, VTK, logs)

Not allowed without re-authorization:
- MATLAB outside the FlowSim tree
- Writes to `axon/` or `my-axon/`
- Interactive MATLAB (no `-desktop`)
- Uninstall / reconfigure MATLAB
