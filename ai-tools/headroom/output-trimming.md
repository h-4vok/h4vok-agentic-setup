# Trimming de tokens de salida

El output shaper actúa dentro del proxy. Es distinto de comprimir herramientas de entrada: orienta la verbosidad y ajusta esfuerzo en los caminos admitidos. Se aplica a Claude `/v1/messages` y a los endpoints OpenAI compatibles, incluido `/v1/responses`. No corta texto simplemente al final de una respuesta.

## Activar

La instalación de este repo ya lo deja activado. Para hacerlo manualmente en Windows:

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', '1', 'User')
$env:HEADROOM_OUTPUT_SHAPER = '1'
headroom rollout status
```

Esperado en 0.39.1: `proxy_output_shaper: enabled=true`. No hace falta `HEADROOM_ROLLOUT_CHANNEL=beta` en esa versión.

Desde el proyecto:

```powershell
headroom wrap claude
# O, en otra sesión:
headroom wrap codex
```

El wrapper sincroniza la variable con un proxy ya iniciado sin reiniciarlo. Si ambos comparten puerto, el cambio es global: gana la última configuración explícita sincronizada. Persistir una variable no cambia por sí solo un proxy ni una app ya abierta.

Para comprobar el valor efectivo mientras el proxy corre:

```powershell
$health = Invoke-RestMethod http://127.0.0.1:8787/health
$health.config.runtime_env.HEADROOM_OUTPUT_SHAPER
```

Esperado: `1`. `rollout status` por sí solo describe el entorno del comando, no garantiza que otro proceso proxy haya recibido ese entorno.

## Aprender la verbosidad: opcional

```powershell
headroom learn --verbosity
headroom learn --verbosity --apply
```

El primer comando es una vista previa; el segundo guarda el nivel aprendido a partir de sesiones anteriores. Ejecutarlos por decisión del usuario, fuera de la instalación básica. No versionar historiales ni resultados que expongan información de esos chats. Revisar la salida y los archivos afectados antes de aplicar.

## Medir

```powershell
headroom output-savings
headroom dashboard
headroom perf
```

El ahorro de salida sin grupo de control es estimado, con intervalo de confianza cuando existen datos suficientes. `No output-savings data yet` no indica por sí solo que el shaper esté apagado. Comprobar el estado de runtime.

Para comparar conversaciones con un control sin shaping, antes de lanzar la sesión:

```powershell
$env:HEADROOM_OUTPUT_HOLDOUT = '0.1'
headroom wrap codex
# También sirve con headroom wrap claude.
```

El 10% actúa como control. El dashboard puede presentar ahorro medido cuando hay muestras suficientes; una prueba corta no demuestra ese ahorro. No se persiste holdout en este setup.

Para desactivar un holdout ya sincronizado, transmitir un cero explícito:

```powershell
$env:HEADROOM_OUTPUT_HOLDOUT = '0'
headroom wrap codex
```

## Desactivar

Si las respuestas pierden detalle útil, desactivar y comparar sesiones:

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', '0', 'User')
$env:HEADROOM_OUTPUT_SHAPER = '0'
headroom wrap codex
# O headroom wrap claude: el cambio afecta al proxy compartido.
```

Usar **0 explícito** permite apagar también un proxy reutilizado. Sólo quitar la variable del shell puede dejar vigente el valor previamente sincronizado.

Si se quiere borrar totalmente la preferencia, detener primero el proxy propio y después:

```powershell
[Environment]::SetEnvironmentVariable('HEADROOM_OUTPUT_SHAPER', $null, 'User')
Remove-Item Env:HEADROOM_OUTPUT_SHAPER -ErrorAction SilentlyContinue
```

Abrir una terminal nueva y lanzar un proxy nuevo. No usar `setx HEADROOM_OUTPUT_SHAPER ""` para borrar variables: la API de Environment con `$null` expresa la eliminación de manera clara.
