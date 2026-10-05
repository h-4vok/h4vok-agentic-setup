# Instalación en Windows

## Requisitos

Windows x64, PowerShell, acceso a internet, Codex CLI y Claude Code instalados. Verificar antes de cambiar nada:

```powershell
Get-Command winget, uv, codex, claude -ErrorAction SilentlyContinue
codex --version
claude --version
codex login status
claude auth status
```

Si falta un cliente, seguir su instalador oficial: [Codex CLI](https://developers.openai.com/codex/cli/) o [Claude Code](https://code.claude.com/docs/en/setup). No confundir la app Codex con la CLI. Para autenticar: `codex login` y `claude auth login`; las credenciales las introduce el usuario, fuera del repo.

Headroom requiere Python 3.10+. Usamos el Python 3.13 que administra uv en un entorno aislado; no cambia el Python global. Hay wheel de Windows x64 para Headroom, pero algunos extras pueden requerir preparación adicional. `[all]` descarga muchas dependencias, incluida PyTorch.

## Opción A: script reproducible

Desde la raíz del repo:

```powershell
.\ai-tools\headroom\scripts\install-windows.ps1
```

El script instala uv si falta, configura las dos variables en usuario y proceso, respalda archivos locales, instala Headroom **0.39.1** si falta y registra el MCP en ambos clientes. Si encuentra otra versión, se detiene para revisarla; no fuerza cambios de MCP existentes. Una segunda ejecución con la misma versión conserva la instalación. Revisar la salida de registro: ambos deben decir `registered` o `already registered`.

Si la política de ejecución bloquea scripts, usar los pasos manuales siguientes; no hace falta cambiar la política de toda la máquina. Después seguir las guías de clientes y verificación: el script no realiza logins ni inicia conversaciones.

## Opción B: instalación manual

### 1. Reutilizar uv o instalarlo

Si `Get-Command uv` ya lo encuentra, omitir la instalación:

```powershell
winget install --id astral-sh.uv --exact
```

Abrir otra terminal si todavía no aparece `uv`. Si winget no funciona, seguir el [instalador oficial de uv](https://docs.astral.sh/uv/getting-started/installation/). `python -m pip install 'headroom-ai[all]'` es una alternativa de upstream, pero no fue el método probado aquí: cambia el entorno y requiere revisar su PATH por separado.

### 2. Aplicar las preferencias antes de ejecutar Headroom

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_BEACON', 'off', 'User')
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', '1', 'User')
$env:HEADROOM_BEACON = 'off'
$env:HEADROOM_OUTPUT_SHAPER = '1'
```

Esto afecta al usuario actual y al proceso actual, sin pedir administrador. Es equivalente a persistir con `setx` y además actualizar esta terminal. El script no registra un exportador externo de observabilidad.

### 3. Instalar el paquete Python y revisar PATH

```powershell
uv tool install --python 3.13 'headroom-ai[all]==0.39.1'
uv tool update-shell
$binDir = (uv tool dir --bin | Out-String).Trim()
$env:PATH = "$binDir;$env:PATH"
headroom --version
where.exe headroom
```

Esperado: versión 0.39.1. El CLI viene de PyPI; el paquete npm `headroom-ai` es el SDK TypeScript.

### 4. Respaldar y registrar las integraciones

Guardar copias de `~/.codex/config.toml`, `~/.claude.json` y `~/.claude/settings.json` fuera del repo antes de modificar. Si se usan `CODEX_HOME` o `CLAUDE_CONFIG_DIR`, respaldar también las rutas activas. El script de la opción A hace esas copias en `%LOCALAPPDATA%/h4vok-agentic-setup/backups/`.

```powershell
headroom mcp install --agent claude --agent codex
codex mcp get headroom
```

No usar `--force` para resolver configuraciones personales sin revisarlas. La versión 0.39.1 sí implementa el registrar Codex aunque su ayuda mencione solamente Claude. Este registro instala el MCP; Serena se agrega al lanzar cada wrapper, según las guías de clientes.

Abrir una terminal nueva y reiniciar los clientes. Continuar con [Claude](claude.md), [Codex](codex.md) y [verificación](verification.md).

## Actualizar

```powershell
headroom update
```

O bien, elegir una versión explícita para uv:

```powershell
uv tool upgrade headroom-ai
```

Estos comandos salen del pin inicial. Revisar la nueva versión, repetir las pruebas, actualizar el valor del script y registrar la evidencia antes de considerar el setup reproducible con esa versión. Detener los procesos de Headroom antes de actualizar si Windows bloquea sus ejecutables.

## Desinstalar

Desde cada proyecto envuelto, revisar las instrucciones de `unwrap` y las configuraciones afectadas:

```powershell
headroom unwrap claude
headroom unwrap codex
headroom mcp uninstall --help
```

En 0.39.1, `headroom mcp uninstall` no tiene selector: quita Headroom de todos los clientes detectados. Ejecutarlo sólo si ese es el alcance deseado; para quitar una integración específica, usar el comando nativo de ese cliente. Revisar Serena por separado: `unwrap` puede encontrar registros sin marcadores, como se explica en troubleshooting. Finalmente:

```powershell
uv tool uninstall headroom-ai
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', $null, 'User')
[Environment]::SetEnvironmentVariable('HEADROOM_BEACON', $null, 'User')
Remove-Item Env:HEADROOM_OUTPUT_SHAPER -ErrorAction SilentlyContinue
Remove-Item Env:HEADROOM_BEACON -ErrorAction SilentlyContinue
```

Si esas variables tenían valores previos propios, restaurarlos en lugar de borrarlos. No borrar otros MCP ni restaurar un backup completo encima de cambios posteriores del usuario.
