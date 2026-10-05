# Codex

Primero completar [la instalación común](windows.md).

## CLI con proxy: opción principal

```powershell
codex login status
# Si hace falta, el usuario completa:
codex login
```

Desde el proyecto, en cada sesión:

```powershell
headroom wrap codex
```

El wrapper inicia o reutiliza el proxy, registra MCP de recuperación y Serena, y pasa la URL del proxy a la CLI para esa ejecución. En 0.39.1 usa una sobrescritura `--config openai_base_url=...`; no deja un proveedor global obligatorio para futuras sesiones. No cambiar manualmente `model_provider` o el login para este setup.

El proxy transforma solicitudes que pasan por él; no depende de que el modelo elija `headroom_compress`. La recuperación de los originales sí usa MCP cuando el agente la necesita. La compresión depende del tipo de contenido y sus umbrales: no todo se reduce.

Sin Serena, revisar primero la nota sobre registros sin marcadores en [troubleshooting](troubleshooting.md):

```powershell
headroom wrap codex --code-memory none
```

## MCP: CLI y app de escritorio

El instalador común registra:

```powershell
headroom mcp install --agent codex
codex mcp get headroom
```

Codex obtiene `headroom_compress`, `headroom_retrieve` y `headroom_stats`. El modelo decide cuándo invocarlas. Esta alternativa puede comprimir contenido explícitamente sin proxy; el retrieval de marcadores creados por el proxy requiere que ese proxy siga accesible.

Reiniciar la app Codex para cargar el MCP y las variables del usuario. Verificar la conexión/herramientas en una sesión nueva. El registro se comprobó aquí desde la CLI y un cliente MCP de prueba; la UI de una app reiniciada se debe verificar por separado. El chat actual no adquiere herramientas nuevas durante la instalación.

**MCP no enruta automáticamente la app por el proxy ni habilita allí el trimming.** `headroom wrap codex` lanza Codex CLI, no envuelve el proceso de escritorio.

### Si el comando no se encuentra

```powershell
where.exe headroom
uv tool dir --bin
```

Headroom ya genera una ruta absoluta en 0.39.1. Si hace falta, corregir solamente su bloque en `~/.codex/config.toml` (o `$env:CODEX_HOME/config.toml`), conservando los demás:

```toml
[mcp_servers.headroom]
command = 'C:\Users\TU_USUARIO\.local\bin\headroom.exe'
args = ["mcp", "serve"]
```

Las comillas simples de TOML admiten barras invertidas literales. Reemplazar la ruta por el resultado real; no copiar la ruta de otra PC. Si se usa un bloque manual, `wrap` puede avisar que es gestionado por el usuario y negarse a reemplazarlo.

`codex mcp add headroom -- <ruta> mcp serve` también es una alternativa, pero en la versión probada los comandos `codex mcp add/remove` reserializan TOML y pueden perder los comentarios con los que Headroom identifica sus registros. Preferimos el instalador de Headroom.

## Pruebas

```powershell
headroom wrap codex -- --version
headroom wrap codex -- exec --ephemeral --skip-git-repo-check 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
```

La segunda consulta consume uso del proveedor. Esperado: `HEADROOM_OK`, código 0 y actividad real en el proxy. Ver [verification.md](verification.md).

## Reversión

```powershell
headroom unwrap codex
```

Revisar el MCP que se instaló aparte y Serena. No restaurar una configuración completa encima de cambios posteriores. Las variables de usuario y el paquete tienen su reversión en [windows.md](windows.md).
