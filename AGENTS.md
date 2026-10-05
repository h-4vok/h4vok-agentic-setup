# Cómo trabajar con este repositorio

## Objetivo

Este repositorio documenta e instala el setup local opinionado del propietario. Debe poder seguirlo un humano o una IA sin depender de conversaciones anteriores. El README raíz es un índice; los procedimientos viven en la carpeta de cada componente.

## Instalar en una máquina

1. Leer el README raíz y la guía del componente solicitado, incluidos los pasos específicos del sistema operativo y del cliente (Codex/Claude).
2. Detectar sistema, shell, comandos, versiones y configuración existente antes de modificar nada. No asumir que una instalación anterior aplica a otra PC.
3. Instalar sólo el alcance solicitado. Reutilizar dependencias compatibles; no reinstalar o actualizar otras herramientas porque sí.
4. Guardar copias locales de los archivos que se modificarán, fuera del repositorio. Combinar cambios con la configuración existente; nunca reemplazarla completa ni mostrar secretos en logs.
5. Aplicar las preferencias explícitas de cada guía. Para Headroom: beacon apagado y output shaping activado; proxy en loopback.
6. Ejecutar la verificación de la guía y revisar los códigos de salida. Separar instalación, configuración, arranque, pruebas locales y pruebas reales contra el proveedor.
7. Corregir problemas dentro del alcance autorizado. Documentar pasos extras, causas y soluciones reproducibles en troubleshooting y registrar resultados con fecha y versiones.
8. Informar qué quedó funcionando, qué requiere una nueva terminal/reinicio del cliente y qué falta verificar. No declarar ahorro medido sin datos ni llamar end-to-end a una prueba que sólo usa --version.

## Mantener las guías

- Escribir en español, con comandos completos y bloques marcados por lenguaje.
- Una carpeta por componente dentro de su categoría. Evitar duplicar requisitos comunes entre guías de clientes.
- Incluir propósito, requisitos, preferencias, instalación, uso diario, verificación, actualización y reversión.
- Marcar opciones como opcionales. No aplicarlas automáticamente durante una instalación básica.
- Verificar los comandos contra --help y fuentes oficiales actuales. Registrar la versión probada y enlazar las fuentes; los procedimientos pueden cambiar.
- Si se incluyen scripts, deben fallar claramente, conservar configuraciones ajenas y tolerar una segunda ejecución.
- No versionar credenciales, configuraciones personales completas, historiales de agentes, backups, logs privados o binarios descargados.
- No hacer commits, publicar ni enviar mensajes a terceros salvo que el usuario lo solicite.
- Las carpetas pendientes no autorizan instalar su contenido.
