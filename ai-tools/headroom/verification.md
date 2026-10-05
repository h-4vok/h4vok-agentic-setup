# Verification

Distinguish test levels. An installed package or successful `--version` check does not establish an actual provider request.

## 1. Package, preferences, and MCP

```powershell
headroom --version
codex --version
claude --version
[Environment]::GetEnvironmentVariable('HEADROOM_BEACON', 'User')
[Environment]::GetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', 'User')
codex mcp get headroom
headroom mcp status
```

Expected: Headroom 0.39.1 for the initial guide, beacon `off`, shaper `1`, and MCP registered in both clients with a valid command. Inspect Claude's global registration without dumping its complete configuration, which may contain secrets.

## 2. Wrapper startup

```powershell
headroom wrap codex -- --version
headroom wrap claude -- --version
```

Expected: proxy startup/reuse, routing URL, and client versions with exit code 0. The first startup may take longer. A wrapper-created proxy may stop when its last client exits; do not assume it remains running after `--version`.

## 3. Proxy and dashboard

Keep a real wrapper session open or, for diagnostics, use a terminal running:

```powershell
$env:HEADROOM_BEACON = 'off'
$env:HEADROOM_OUTPUT_SHAPER = '1'
headroom proxy --host 127.0.0.1 --port 8787
```

In another terminal:

```powershell
headroom doctor --json
$LASTEXITCODE
headroom dashboard --no-open
(Invoke-WebRequest http://127.0.0.1:8787/dashboard).StatusCode
$health = Invoke-RestMethod http://127.0.0.1:8787/health
$health.status
$health.ready
$health.config.runtime_env.HEADROOM_OUTPUT_SHAPER
```

Expected: HTTP 200, `healthy`, `ready=True`, and shaping `1`. `doctor` distinguishes exit codes **0** (all healthy), **1** (warnings), and **2** (failure). Read individual checks: it may warn about missing global routing even though a wrapper configured routing only for its process. Do not change the global provider to hide that warning.

`kompress` may be `deferred` before the ML model is needed; the structural compressor and other components have separate states. Consult `/debug/warmup` and the troubleshooting explanation.

## 4. Local MCP compression and retrieval

From the repository root, using Python from the installed environment:

```powershell
$toolDir = (uv tool dir | Out-String).Trim()
$binDir = (uv tool dir --bin | Out-String).Trim()
$env:PATH = "$binDir;$env:PATH"
& (Join-Path $toolDir 'headroom-ai\Scripts\python.exe') .\ai-tools\headroom\scripts\verify-mcp.py
```

The script opens the MCP server over stdio, verifies tools, compresses synthetic JSON, and retrieves the exact original within the same session. It fails on missing tools, errors, no fixture reduction, or a retrieval mismatch. It uses no credentials and calls no remote model. It may store local counters for this test in Headroom; do not confuse them with real project activity.

Expected: `result: PASS`, `retrieval_exact: true`, and fewer compressed than original tokens. The percentage applies to the fixture; it is not a promise of daily savings.

## 5. Real requests

With authenticated clients:

```powershell
headroom wrap codex -- exec --ephemeral --skip-git-repo-check 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
headroom wrap claude -- -p 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
```

Each command consumes provider usage. Expected: `HEADROOM_OK`, exit code 0, and activity in `headroom perf` or `/stats` while the proxy runs. If login is missing, record the test as pending. Do not attempt noninteractive login with credentials copied from another client.

## 6. Savings and trimming synchronization

```powershell
headroom perf
headroom output-savings
```

Record input, cache, and output savings separately. If the output report has no samples, record "no data".

With the shared proxy open, set shaping to `0`, run `headroom wrap codex -- --version`, and check `/health`. Then restore `1` with `headroom wrap claude -- --version` and check again. This tests synchronization without restarting the proxy or consuming model requests.

After diagnostics, stop the manually started proxy with Ctrl+C. Do not stop unrelated processes or leave test services running unnecessarily. Save dates, versions, results, and pending checks in `validation/`, without sensitive data.
