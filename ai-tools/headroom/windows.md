# Windows installation

## Requirements

Windows x64, PowerShell, internet access, and installed Codex CLI and Claude Code clients. Check before making changes:

```powershell
Get-Command winget, uv, codex, claude -ErrorAction SilentlyContinue
codex --version
claude --version
codex login status
claude auth status
```

If a client is missing, follow its official installer: [Codex CLI](https://developers.openai.com/codex/cli/) or [Claude Code](https://code.claude.com/docs/en/setup). The Codex app and CLI are separate clients. Authenticate with `codex login` and `claude auth login`; the user enters credentials outside the repository.

Headroom requires Python 3.10+. We use uv-managed Python 3.13 in an isolated environment; this does not change global Python. Headroom publishes a Windows x64 wheel, but some extras may need additional preparation. `[all]` downloads many dependencies, including PyTorch.

## Option A: reproducible script

From the repository root:

```powershell
.\ai-tools\headroom\scripts\install-windows.ps1
```

The script installs uv if missing, sets both variables for the user and current process, backs up local files, installs Headroom **0.39.1** if missing, and registers MCP in both clients. It stops for review if another version exists; it does not force changes to existing MCP entries. Running it again with the same version preserves the installation. Inspect registration output: both clients must report `registered` or `already registered`.

If execution policy blocks scripts, use the manual steps below; changing machine-wide policy is unnecessary. Then follow the client and verification guides: the script does not perform logins or start conversations.

## Option B: manual installation

### 1. Reuse or install uv

Skip installation if `Get-Command uv` already finds it:

```powershell
winget install --id astral-sh.uv --exact
```

Open another terminal if `uv` is still unavailable. If winget fails, follow the [official uv installer](https://docs.astral.sh/uv/getting-started/installation/). `python -m pip install 'headroom-ai[all]'` is an upstream alternative, but was not the method tested here: it changes the environment and requires a separate PATH check.

### 2. Apply preferences before running Headroom

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_BEACON', 'off', 'User')
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', '1', 'User')
$env:HEADROOM_BEACON = 'off'
$env:HEADROOM_OUTPUT_SHAPER = '1'
```

This affects the current user and process without administrator access. It is equivalent to persisting with `setx` and also updating this terminal. The script does not configure an external observability exporter.

### 3. Install the Python package and check PATH

```powershell
uv tool install --python 3.13 'headroom-ai[all]==0.39.1'
uv tool update-shell
$binDir = (uv tool dir --bin | Out-String).Trim()
$env:PATH = "$binDir;$env:PATH"
headroom --version
where.exe headroom
```

Expected: version 0.39.1. The CLI comes from PyPI; the npm `headroom-ai` package is the TypeScript SDK.

### 4. Back up and register integrations

Before modifying configuration, save copies of `~/.codex/config.toml`, `~/.claude.json`, and `~/.claude/settings.json` outside the repository. If using `CODEX_HOME` or `CLAUDE_CONFIG_DIR`, back up the active paths as well. The option A script saves copies in `%LOCALAPPDATA%/h4vok-agentic-setup/backups/`.

```powershell
headroom mcp install --agent claude --agent codex
codex mcp get headroom
```

Do not use `--force` to resolve personal configuration differences without reviewing them. Version 0.39.1 implements the Codex registrar even though its help mentions only Claude. This registers MCP; each wrapper adds Serena when launched, as described in the client guides.

Open a new terminal and restart the clients. Continue with [Claude](claude.md), [Codex](codex.md), and [verification](verification.md).

## Updating

```powershell
headroom update
```

Alternatively, upgrade through uv:

```powershell
uv tool upgrade headroom-ai
```

These commands move beyond the initial pin. Review the new version, repeat tests, update the script's version, and record evidence before treating that version as reproducible. Stop Headroom processes before upgrading if Windows locks its executables.

## Uninstalling

From each wrapped project, review `unwrap` instructions and the affected configuration:

```powershell
headroom unwrap claude
headroom unwrap codex
headroom mcp uninstall --help
```

In 0.39.1, `headroom mcp uninstall` has no agent selector: it removes Headroom from all detected clients. Run it only if that is the intended scope; use the client's native command to remove a specific integration. Review Serena separately: `unwrap` may encounter entries without markers, as explained in troubleshooting. Finally:

```powershell
uv tool uninstall headroom-ai
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', $null, 'User')
[Environment]::SetEnvironmentVariable('HEADROOM_BEACON', $null, 'User')
Remove-Item Env:HEADROOM_OUTPUT_SHAPER -ErrorAction SilentlyContinue
Remove-Item Env:HEADROOM_BEACON -ErrorAction SilentlyContinue
```

Restore previous custom variable values instead of deleting them, if applicable. Do not remove other MCP servers or restore a complete backup over subsequent user changes.
