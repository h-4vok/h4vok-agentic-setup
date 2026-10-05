# Headroom

Proxy local y herramientas MCP para reducir contexto enviado a los modelos. Se instala una vez por PC; Codex CLI y Claude Code pueden usar el mismo proxy. El output shaping también ajusta la verbosidad de las respuestas.

## Índice y orden de instalación

1. [Instalación común en Windows](windows.md): requisitos, preferencias y registro MCP.
2. [Claude Code](claude.md): autenticación y sesiones con proxy.
3. [Codex](codex.md): CLI con proxy y MCP para CLI/app.
4. [Trimming de salida](output-trimming.md): activar, medir, aprender y desactivar.
5. [Verificación](verification.md): salud, prueba MCP y solicitudes reales.
6. [Problemas y soluciones](troubleshooting.md): diferencias de Windows y documentación desactualizada.
7. [Registro de esta PC](validation/2026-10-05-windows.md): evidencia y límites de la instalación inicial.

## Preferencias de este setup

| Decisión | Valor |
| --- | --- |
| Instalación | `uv tool`, Python 3.13, `headroom-ai[all]` |
| Versión reproducible inicial | `0.39.1` |
| Beacon | `HEADROOM_BEACON=off`, persistente a nivel usuario |
| Output shaping | `HEADROOM_OUTPUT_SHAPER=1`, persistente a nivel usuario |
| Proxy | Loopback `127.0.0.1:8787`; sesión iniciada con `wrap` |
| Serena | Predeterminado de `wrap`, configurable por proyecto/cliente |
| Aprendizaje y holdout | Opcionales; no se aplican al instalar |

Los wrappers son para las CLI. Registrar MCP en la app Codex permite que el modelo use sus herramientas; no convierte todas las conversaciones de la app en tráfico del proxy. Tampoco el MCP solo activa el output shaping.

No se instalan servicios de inicio automático ni se reemplazan modelos, credenciales o configuraciones completas de los clientes. Una terminal/app ya abierta necesita reiniciarse para heredar variables persistentes.

## Fuentes y vigencia

Guía contrastada el **5 de octubre de 2026** con el paquete instalado 0.39.1, su `--help` y las fuentes oficiales:

- [Repositorio y README de Headroom](https://github.com/headroomlabs-ai/headroom).
- [Quickstart](https://docs.headroomlabs.ai/docs/quickstart), [proxy](https://docs.headroomlabs.ai/docs/proxy) y [savings](https://docs.headroomlabs.ai/docs/savings).
- [Referencia de configuración de Codex](https://developers.openai.com/codex/config-reference/).

`main` y la documentación web pueden avanzar antes que esta guía. Para otra versión, revisar los comandos y repetir las verificaciones antes de actualizar el registro.
