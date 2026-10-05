# Headroom

A local proxy and MCP tools to reduce context sent to models. Install it once per PC; Codex CLI and Claude Code can share the proxy. Output shaping also adjusts response verbosity.

## Contents and installation order

1. [Shared Windows installation](windows.md): requirements, preferences, and MCP registration.
2. [Claude Code](claude.md): authentication and proxy sessions.
3. [Codex](codex.md): CLI proxy and MCP for the CLI/app.
4. [Output trimming](output-trimming.md): enable, measure, learn, and disable.
5. [Verification](verification.md): health, MCP tests, and real requests.
6. [Troubleshooting](troubleshooting.md): Windows differences and outdated documentation.
7. [This PC's validation record](validation/2026-10-05-windows.md): evidence and limits of the initial installation.

## Setup preferences

| Decision | Value |
| --- | --- |
| Installation | `uv tool`, Python 3.13, `headroom-ai[all]` |
| Initial reproducible version | `0.39.1` |
| Beacon | `HEADROOM_BEACON=off`, persisted for the user |
| Output shaping | `HEADROOM_OUTPUT_SHAPER=1`, persisted for the user |
| Proxy | Loopback `127.0.0.1:8787`; launch sessions with `wrap` |
| Serena | `wrap` default, configurable per project/client |
| Learning and holdout | Optional; not applied during installation |

Wrappers target the CLIs. Registering MCP in the Codex app lets the model use its tools; it does not route every app conversation through the proxy. MCP alone does not activate output shaping either.

This setup does not install startup services or replace models, credentials, or complete client configurations. Restart an already open terminal/app to inherit persistent variables.

## Sources and currency

Checked on **5 October 2026** against the installed 0.39.1 package, its `--help`, and official sources:

- [Headroom repository and README](https://github.com/headroomlabs-ai/headroom).
- [Quickstart](https://docs.headroomlabs.ai/docs/quickstart), [proxy](https://docs.headroomlabs.ai/docs/proxy), and [savings](https://docs.headroomlabs.ai/docs/savings).
- [Codex configuration reference](https://developers.openai.com/codex/config-reference/).

`main` and web documentation may move ahead of this guide. For another version, review commands and repeat verification before updating the record.
