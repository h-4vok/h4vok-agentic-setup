# Claude Code

Primero completar [la instalación común](windows.md).

## Autenticación

```powershell
claude auth status
```

Si `loggedIn` es `false`:

```powershell
claude auth login
```

El usuario completa el login. Headroom no sustituye las credenciales. Si Claude ya está abierto, también ofrece `/login`. No pegar credenciales en este repo.

## Uso diario

Desde la carpeta del proyecto:

```powershell
headroom wrap claude
```

El wrapper inicia o reutiliza el proxy, dirige el proceso Claude por `ANTHROPIC_BASE_URL` y registra Serena para ese proyecto con alcance local. No supone que todos los proyectos usan esa integración. En 0.39.1 mantiene `ENABLE_TOOL_SEARCH=true` salvo una preferencia explícita previa, para conservar la carga de herramientas bajo demanda.

Sin Serena:

```powershell
headroom wrap claude --code-memory none
```

Para pasar argumentos a Claude, usar `--`:

```powershell
headroom wrap claude -- --resume
headroom wrap claude -- --model sonnet
```

El modelo habitual se conserva al no elegir otro. La opción `--1m` cambia la selección de modelo/contexto: revisar `headroom wrap claude --help` si se necesita; no se activa en la instalación básica.

## Pruebas

Arranque local, sin consulta al modelo:

```powershell
headroom wrap claude -- --version
```

Solicitud real mínima, requiere login y consume una consulta:

```powershell
headroom wrap claude -- -p 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
```

Esperado: `HEADROOM_OK`, código 0 y actividad del proxy. `Not logged in` significa que el cliente arrancó pero no hubo prueba contra Anthropic. Ver [verification.md](verification.md).

## Reversión

Desde el proyecto afectado:

```powershell
headroom unwrap claude
```

Revisar el MCP global instalado aparte, los registros Serena y `.claude/settings.local.json`: no borrar hooks o servidores ajenos. `unwrap` no elimina las variables persistentes del usuario ni desinstala el paquete.
