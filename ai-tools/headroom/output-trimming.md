# Output token trimming

The output shaper runs inside the proxy. Unlike input tool compression, it steers verbosity and adjusts effort on supported paths. It applies to Claude `/v1/messages` and OpenAI-compatible endpoints, including `/v1/responses`. It does not simply truncate the end of a response.

## Enabling

This repository's installation already enables it. To configure it manually on Windows:

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', '1', 'User')
$env:HEADROOM_OUTPUT_SHAPER = '1'
headroom rollout status
```

Expected in 0.39.1: `proxy_output_shaper: enabled=true`. That version does not require `HEADROOM_ROLLOUT_CHANNEL=beta`.

From the project directory:

```powershell
headroom wrap claude
# Or, in another session:
headroom wrap codex
```

The wrapper synchronizes the variable with an existing proxy without restarting it. If both clients share a port, the change is global: the last explicitly synchronized setting wins. Persisting a variable alone does not change an already running proxy or app.

To check the effective value while the proxy runs:

```powershell
$health = Invoke-RestMethod http://127.0.0.1:8787/health
$health.config.runtime_env.HEADROOM_OUTPUT_SHAPER
```

Expected: `1`. `rollout status` alone describes the command's environment; it does not guarantee another proxy process received that environment.

## Learning verbosity: optional

```powershell
headroom learn --verbosity
headroom learn --verbosity --apply
```

The first command previews the result; the second saves a level learned from previous sessions. Run these at the user's discretion, outside the basic installation. Do not commit histories or results that expose conversation data. Review output and affected files before applying.

## Measuring

```powershell
headroom output-savings
headroom dashboard
headroom perf
```

Output savings without a control group are estimated, with a confidence interval when enough data exists. `No output-savings data yet` does not by itself mean the shaper is disabled. Check runtime status.

To compare against conversations without shaping, set a holdout before launching:

```powershell
$env:HEADROOM_OUTPUT_HOLDOUT = '0.1'
headroom wrap codex
# This also works with headroom wrap claude.
```

The 10% serves as a control. The dashboard can report measured savings with enough samples; a short test does not establish those savings. This setup does not persist holdout.

To disable an already synchronized holdout, send an explicit zero:

```powershell
$env:HEADROOM_OUTPUT_HOLDOUT = '0'
headroom wrap codex
```

## Disabling

If responses lose useful detail, disable shaping and compare sessions:

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', '0', 'User')
$env:HEADROOM_OUTPUT_SHAPER = '0'
headroom wrap codex
# Or headroom wrap claude: the change affects the shared proxy.
```

An **explicit 0** also disables shaping in a reused proxy. Merely removing the shell variable can leave the previously synchronized value active.

To remove the preference entirely, stop your own proxy first, then run:

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', $null, 'User')
Remove-Item Env:HEADROOM_OUTPUT_SHAPER -ErrorAction SilentlyContinue
```

Open a new terminal and launch a new proxy. Do not use `setx HEADROOM_OUTPUT_SHAPER ""` to delete variables: the Environment API with `$null` expresses deletion clearly.
