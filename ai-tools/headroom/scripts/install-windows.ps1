[CmdletBinding()]
param(
    [string]$Version = '0.39.1'
)

$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Este script requiere Windows.' }
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Version debe tener formato X.Y.Z.' }

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command terminó con código $LASTEXITCODE" }
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Invoke-Checked -Command 'winget' -Arguments @('install', '--id', 'astral-sh.uv', '--exact', '--accept-source-agreements', '--accept-package-agreements')
    # winget no refresca el PATH del proceso que lo invocó.
    $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw 'uv no está en PATH. Abrí otra terminal y repetí el script.' }
foreach ($client in 'codex', 'claude') {
    if (-not (Get-Command $client -ErrorAction SilentlyContinue)) { throw "Falta $client. Instalá y autenticá ese cliente según la guía antes de continuar." }
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
# Persistencia para nuevas sesiones + entorno del proceso actual.
foreach ($entry in @{ HEADROOM_BEACON = 'off'; HEADROOM_OUTPUT_SHAPER = '1' }.GetEnumerator()) {
    [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'User')
    [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
}
Write-Output "Backups locales: $backupDir"

$existingTools = (& uv tool list 2>&1 | Out-String)
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar uv tool list.' }
if ($existingTools -notmatch '(?m)^headroom-ai v') {
    Invoke-Checked -Command 'uv' -Arguments @('tool', 'install', '--python', '3.13', "headroom-ai[all]==$Version")
} elseif ($existingTools -notmatch "(?m)^headroom-ai v$([regex]::Escape($Version))(\s|$)") {
    throw "Ya hay otra versión de Headroom. Revisá uv tool list y la guía de actualización; no se reemplazó automáticamente."
}
Invoke-Checked -Command 'uv' -Arguments @('tool', 'update-shell')
$binDir = (& uv tool dir --bin | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar uv tool dir --bin.' }
$env:PATH = $binDir + ';' + $env:PATH
$headroom = Join-Path $binDir 'headroom.exe'
Invoke-Checked -Command $headroom -Arguments @('--version')
Invoke-Checked -Command $headroom -Arguments @('mcp', 'install', '--agent', 'claude', '--agent', 'codex')
Invoke-Checked -Command $headroom -Arguments @('rollout', 'status')
Write-Output 'Registro terminado. Revisá que ambos clientes digan registered/already. Abrí una terminal nueva y reiniciá los clientes para heredar el entorno.'
Write-Output 'Uso: headroom wrap claude / headroom wrap codex. Autenticación y pruebas reales: ver las guías.'
