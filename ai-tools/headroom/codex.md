# Codex

Complete the [shared installation](windows.md) first.

## CLI with proxy: primary option

```powershell
codex login status
# If needed, the user completes login:
codex login
```

From the project directory, for each session:

```powershell
headroom wrap codex
```

The wrapper starts or reuses the proxy, registers retrieval MCP and Serena, and passes the proxy URL to the CLI for that execution. In 0.39.1 it uses a `--config openai_base_url=...` override; it does not leave a required global provider for future sessions. Do not manually change `model_provider` or login for this setup.

The proxy transforms requests routed through it; it does not depend on the model choosing `headroom_compress`. Retrieval of originals uses MCP when the agent needs it. Compression depends on content type and thresholds: not every input shrinks.

Before running without Serena, review the note about entries without markers in [troubleshooting](troubleshooting.md):

```powershell
headroom wrap codex --code-memory none
```

## MCP: CLI and desktop app

The shared installer registers:

```powershell
headroom mcp install --agent codex
codex mcp get headroom
```

Codex receives `headroom_compress`, `headroom_retrieve`, and `headroom_stats`. The model decides when to invoke them. This option can explicitly compress content without a proxy; retrieving proxy-generated markers requires that proxy to remain reachable.

Restart the Codex app to load MCP and user variables. Verify the connection/tools in a new session. Registration was checked here through the CLI and a test MCP client; the restarted app UI must be verified separately. The current chat does not acquire new tools during installation.

**MCP does not automatically route the app through the proxy or enable trimming there.** `headroom wrap codex` launches Codex CLI; it does not wrap the desktop process.

### If the command cannot be found

```powershell
where.exe headroom
uv tool dir --bin
```

Headroom already generates an absolute path in 0.39.1. If necessary, correct only its block in `~/.codex/config.toml` (or `$env:CODEX_HOME/config.toml`), preserving the others:

```toml
[mcp_servers.headroom]
command = 'C:\Users\YOUR_USERNAME\.local\bin\headroom.exe'
args = ["mcp", "serve"]
```

TOML single quotes allow literal backslashes. Replace the path with the actual result; do not copy a path from another PC. With a manual block, `wrap` may report that it is user-managed and refuse to replace it.

`codex mcp add headroom -- <path> mcp serve` is another option, but in the tested version `codex mcp add/remove` reserialize TOML and can lose the comments Headroom uses to identify its entries. We prefer Headroom's installer.

## Tests

```powershell
headroom wrap codex -- --version
headroom wrap codex -- exec --ephemeral --skip-git-repo-check 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
```

The second request consumes provider usage. Expected: `HEADROOM_OK`, exit code 0, and real proxy activity. See [verification.md](verification.md).

## Rollback

```powershell
headroom unwrap codex
```

Review the separately installed MCP and Serena. Do not restore a complete configuration over subsequent changes. User variables and package removal are covered in [windows.md](windows.md).
