[CmdletBinding()]
param(
    [string]$Version = '0.39.1'
)

$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'This script requires Windows.' }
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Version must use the X.Y.Z format.' }

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command exited with code $LASTEXITCODE" }
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Invoke-Checked -Command 'winget' -Arguments @('install', '--id', 'astral-sh.uv', '--exact', '--accept-source-agreements', '--accept-package-agreements')
    # winget does not refresh PATH in its parent process.
    $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw 'uv is not on PATH. Open another terminal and run the script again.' }
foreach ($client in 'codex', 'claude') {
    if (-not (Get-Command $client -ErrorAction SilentlyContinue)) { throw "$client is missing. Install and authenticate that client using the guide before continuing." }
}

$backupDir = Join-Path $env:LOCALAPPDATA ('h4vok-agentic-setup\backups\headroom-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$codexDir = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$claudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$files = @{
    'codex-config.toml' = (Join-Path $codexDir 'config.toml')
    'claude-settings.json' = (Join-Path $claudeDir 'settings.json')
    'claude-state.json' = (Join-Path $env:USERPROFILE '.claude.json')
    'claude-config-state.json' = (Join-Path $claudeDir '.claude.json')
}
foreach ($file in $files.GetEnumerator()) {
    if (Test-Path -LiteralPath $file.Value) { Copy-Item -LiteralPath $file.Value -Destination (Join-Path $backupDir $file.Key) }
}
$previousPreferences = @{}
foreach ($name in 'HEADROOM_BEACON', 'HEADROOM_OUTPUT_SHAPER') {
    $previousPreferences[$name] = [Environment]::GetEnvironmentVariable($name, 'User')
}
$previousPreferences | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $backupDir 'previous-preferences.json')
# Persist for new sessions and update the current process environment.
foreach ($entry in @{ HEADROOM_BEACON = 'off'; HEADROOM_OUTPUT_SHAPER = '1' }.GetEnumerator()) {
    [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'User')
    [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
}
Write-Output "Local backups: $backupDir"

$existingTools = (& uv tool list 2>&1 | Out-String)
if ($LASTEXITCODE -ne 0) { throw 'Failed to query uv tool list.' }
if ($existingTools -notmatch '(?m)^headroom-ai v') {
    Invoke-Checked -Command 'uv' -Arguments @('tool', 'install', '--python', '3.13', "headroom-ai[all]==$Version")
} elseif ($existingTools -notmatch "(?m)^headroom-ai v$([regex]::Escape($Version))(\s|$)") {
    throw "Another Headroom version is already installed. Review uv tool list and the update guide; it was not replaced automatically."
}
Invoke-Checked -Command 'uv' -Arguments @('tool', 'update-shell')
$binDir = (& uv tool dir --bin | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Failed to query uv tool dir --bin.' }
$env:PATH = $binDir + ';' + $env:PATH
$headroom = Join-Path $binDir 'headroom.exe'
Invoke-Checked -Command $headroom -Arguments @('--version')
Invoke-Checked -Command $headroom -Arguments @('mcp', 'install', '--agent', 'claude', '--agent', 'codex')
Invoke-Checked -Command $headroom -Arguments @('rollout', 'status')
Write-Output 'Registration complete. Check that both clients report registered/already. Open a new terminal and restart clients to inherit the environment.'
Write-Output 'Usage: headroom wrap claude / headroom wrap codex. For authentication and real requests, see the guides.'
