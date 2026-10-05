# Problemas y soluciones

Casos observados con Headroom 0.39.1 en Windows. Para versiones posteriores, contrastar con `--help` y los archivos instalados antes de reutilizar un workaround.

## uv/headroom no aparece en esta terminal

Una instalación cambia el PATH persistente, pero no el de los procesos existentes. Abrir otra terminal o agregar el directorio de `uv tool dir --bin` al PATH del proceso. En esta PC es `~/.local/bin`; usar el resultado real en cada máquina. Reiniciar también Codex/Claude si estaban abiertos.

## La ayuda de MCP dice que sólo admite Claude

El texto de `headroom mcp install --help` en 0.39.1 está atrasado respecto de la implementación: `--agent codex` funciona. Probamos registros explícitos de ambos. Usar `headroom mcp install --agent claude --agent codex`, y comprobar sus resultados.

`headroom mcp uninstall` de esa versión **no tiene selector de agente** y recorre todos los registrars conocidos. Revisar `--help` y el alcance antes de ejecutarlo si hay otros clientes configurados. Para una eliminación selectiva se pueden usar los comandos nativos de cada cliente, verificando la configuración después.

## MCP existente distinto / marcadores perdidos en Codex

Headroom compara ruta, argumentos y entorno. Incluso `.exe` frente a `.EXE`, o agregar `HEADROOM_BEACON` al env del bloque, puede producir `existing config differs`. No usar `--force` a ciegas: preserva deliberadamente entradas que considera gestionadas por el usuario.

En esta instalación, una alternativa temporal con `codex mcp add` funcionó, pero `codex mcp remove` reserializó el TOML y perdió comentarios de ownership. Luego `--code-memory none` reportó `Serena MCP: removal failed` aunque Serena seguía registrado.

Solución aplicada: se confirmó que **headroom y serena habían sido agregados durante esta instalación**, se quitaron sólo esos dos registros con los comandos nativos y se volvió a ejecutar `headroom wrap codex -- --version`. Así Headroom recreó ambos registros y sus marcadores. No repetirlo si Serena es una integración previa del usuario. Registrar y preservar cualquier personalización antes de migrarla.

La reserialización de la CLI también omitió campos explícitos de otros MCP (`args` vacío y `enabled` con valor predeterminado). Se restauraron únicamente esos campos desde el backup usando `tomlkit`, sin reemplazar el archivo completo. La comparación semántica final confirmó que todos los MCP previos y todas las claves ajenas a MCP conservaban sus valores. Por eso las próximas instalaciones usan directamente el registrar de Headroom.

Si sólo se desea desactivar un Serena instalado por Headroom y el wrapper no puede retirarlo, revisar `codex mcp get serena` y usar `codex mcp remove serena` exclusivamente después de confirmar su origen. Eso también puede quitar comentarios de otros bloques, por lo que hay que revisar el TOML después.

## Claude devuelve Not logged in

`claude auth status` puede mostrar `loggedIn: false` aunque otro cliente o una app tenga sesión. Ejecutar `claude auth login` o `/login` en Claude Code, completar el flujo como usuario y repetir la solicitud real. `wrap ... --version` sólo acredita arranque, no autenticación ni tráfico Anthropic.

## doctor devuelve advertencias

Con proxy saludable, código 1 puede incluir ausencia de rutas **globales**, falta de datos, ausencia de presupuesto o Kompress aún diferido. Los wrappers usan configuración de proceso; no hace falta fijar permanentemente `OPENAI_BASE_URL`/`ANTHROPIC_BASE_URL` para ocultar esos avisos. Preservar el routing normal de sesiones no envueltas.

En la prueba, `/health` devolvió `healthy`, `ready=true`, core Rust cargado; `/debug/warmup` mostró `smart_crusher=loaded`, `code_aware=loaded`, `tree_sitter=loaded` y `kompress.info.source_status=deferred`. No se comprobó el camino ML de Kompress: no declararlo operativo por el solo hecho de instalar `[all]`. Si sigue sin cargar cuando una carga de texto lo requiere, revisar warmup y logs locales y documentar la descarga/error del modelo antes de cambiar flags.

## No existe doctor --network

La versión 0.39.1 sólo admite `--port` y `--json`. No copiar ese flag de una guía externa. Para diagnóstico de conectividad:

```powershell
headroom doctor --json
Test-NetConnection api.anthropic.com -Port 443
Test-NetConnection api.openai.com -Port 443
```

La prueba de puerto no acredita confianza TLS. Si aparecen errores de certificados en una red corporativa, seguir su configuración de CA autorizada y la documentación del transporte correspondiente; no desactivar la verificación TLS. No fue necesario aplicar un workaround de certificados en esta PC.

## output-savings recomienda beta aunque shaping está activado

El mensaje sin datos de 0.39.1 contiene una recomendación antigua de canal beta. La implementación admite `HEADROOM_OUTPUT_SHAPER=1` en stable. Verificar `headroom rollout status` y el valor efectivo en `/health`; no activar otras funciones beta sólo por ese mensaje.

## Desactivar no cambia un proxy compartido

Quitar una variable no necesariamente borra el override que ya recibió el proxy. Usar `HEADROOM_OUTPUT_SHAPER=0` y volver a ejecutar `wrap`; para holdout usar `HEADROOM_OUTPUT_HOLDOUT=0`. Se comprobó el cambio de shaper 0→1 en el mismo proceso proxy.

## Warning de Magika/ONNX en Windows

La prueba MCP informó que usa el detector Python porque el backend nativo Magika/ONNX no es seguro por defecto en Windows. Se conservó ese fallback; la compresión y recuperación pasaron. No activar `HEADROOM_DETECT_BACKEND=rust` sólo para ocultar el warning.

## Logs y archivos generados

Headroom advierte que los modos de archivo Unix no establecen ACL de Windows para los logs. En este setup no se activa logging completo de mensajes. Mantener logs y backups en el perfil local y revisar ACL si se comparte ese directorio. No copiar configuraciones completas, tokens o historiales al repo.

`wrap claude` generó `.claude/settings.local.json` con hooks y un lock en este proyecto. Están ignorados en Git; los configura Headroom en cada instalación. Serena y `.headroom/` también son estado local ignorado. No tratar esos archivos generados como plantillas portables.
