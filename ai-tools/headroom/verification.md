# Verificación

Separar los niveles de prueba. Un paquete instalado o `--version` exitoso no acredita una solicitud real contra el proveedor.

## 1. Paquete, preferencias y MCP

```powershell
headroom --version
codex --version
claude --version
[Environment]::GetEnvironmentVariable('HEADROOM_BEACON', 'User')
[Environment]::GetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', 'User')
codex mcp get headroom
headroom mcp status
```

Esperado: Headroom 0.39.1 para la guía inicial, beacon `off`, shaper `1` y MCP registrado en ambos clientes con comando válido. Revisar el registro global de Claude sin volcar su configuración completa, que puede contener secretos.

## 2. Arranque de los wrappers

```powershell
headroom wrap codex -- --version
headroom wrap claude -- --version
```

Esperado: arranque/reutilización del proxy, URL de routing y versiones de los clientes con código 0. El primer arranque puede tardar más. Si el proxy lo creó un wrapper, puede terminar al salir su último cliente; no asumir que sigue corriendo después de `--version`.

## 3. Proxy y dashboard

Mantener abierto un wrapper real o, para diagnóstico, una terminal con:

```powershell
$env:HEADROOM_BEACON = 'off'
$env:HEADROOM_OUTPUT_SHAPER = '1'
headroom proxy --host 127.0.0.1 --port 8787
```

En otra terminal:

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

Esperado: HTTP 200, `healthy`, `ready=True`, shaping `1`. `doctor` distingue código **0** (todo saludable), **1** (advertencias) y **2** (fallo). Leer los checks: puede avisar que la configuración global no tiene routing aunque el wrapper lo haya configurado sólo para su proceso. No alterar el proveedor global para hacer desaparecer esa advertencia.

`kompress` puede estar `deferred` antes de necesitar el modelo ML; el compresor estructural y otros componentes tienen estados separados. Consultar `/debug/warmup` y la explicación en troubleshooting.

## 4. Compresión y recuperación MCP local

Desde la raíz, con el Python del entorno instalado:

```powershell
$toolDir = (uv tool dir | Out-String).Trim()
$binDir = (uv tool dir --bin | Out-String).Trim()
$env:PATH = "$binDir;$env:PATH"
& (Join-Path $toolDir 'headroom-ai\Scripts\python.exe') .\ai-tools\headroom\scripts\verify-mcp.py
```

El script abre el servidor MCP por stdio, verifica sus herramientas, comprime JSON sintético y recupera exactamente el original en la misma sesión. Falla si faltan herramientas, hay errores, no reduce el fixture o no recupera el contenido. No usa credenciales ni llama a un modelo remoto. Puede guardar contadores locales de esa prueba en Headroom; no confundirlos con actividad de proyectos reales.

Esperado: `result: PASS`, `retrieval_exact: true`, menos tokens comprimidos que originales. El porcentaje es del fixture, no una promesa de ahorro en el trabajo diario.

## 5. Solicitudes reales

Con clientes autenticados:

```powershell
headroom wrap codex -- exec --ephemeral --skip-git-repo-check 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
headroom wrap claude -- -p 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
```

Cada comando consume uso del proveedor. Esperado: `HEADROOM_OK`, código 0 y actividad en `headroom perf` o `/stats` mientras el proxy esté activo. Si falta login, registrar la prueba como pendiente. No iniciar un login no interactivo usando credenciales copiadas de otro cliente.

## 6. Savings y sincronización del trimming

```powershell
headroom perf
headroom output-savings
```

Registrar por separado ahorro de entrada, caché y salida. Si el reporte de salida no tiene muestras, registrar «sin datos».

Con el proxy compartido abierto, probar shaper `0` seguido de `headroom wrap codex -- --version`, consultar el valor en `/health`, luego restaurar `1` con `headroom wrap claude -- --version` y volver a consultarlo. Esto prueba la sincronización sin reiniciar el proxy ni gastar solicitudes de modelo.

Al terminar diagnósticos, detener con Ctrl+C el proxy que se inició manualmente. No detener procesos ajenos ni dejar servicios de prueba corriendo innecesariamente. Guardar fecha, versiones, resultados y pendientes en `validation/`, sin datos sensibles.
