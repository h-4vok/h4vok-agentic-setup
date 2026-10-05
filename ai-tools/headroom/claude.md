# Claude Code

Complete the [shared installation](windows.md) first.

## Authentication

```powershell
claude auth status
```

If `loggedIn` is `false`:

```powershell
claude auth login
```

The user completes login. Headroom does not replace credentials. An already open Claude session also offers `/login`. Do not paste credentials into this repository.

## Daily usage

From the project directory:

```powershell
headroom wrap claude
```

The wrapper starts or reuses the proxy, routes the Claude process through `ANTHROPIC_BASE_URL`, and registers Serena for that project with local scope. It does not assume every project uses that integration. In 0.39.1 it retains `ENABLE_TOOL_SEARCH=true` unless an explicit preference already exists, preserving on-demand tool loading.

Without Serena:

```powershell
headroom wrap claude --code-memory none
```

Use `--` to pass arguments to Claude:

```powershell
headroom wrap claude -- --resume
headroom wrap claude -- --model sonnet
```

The usual model is preserved when another is not selected. The `--1m` option changes model/context selection: review `headroom wrap claude --help` if needed; it is not enabled by the basic installation.

## Tests

Local startup without a model request:

```powershell
headroom wrap claude -- --version
```

A minimal real request requires login and consumes a provider request:

```powershell
headroom wrap claude -- -p 'Respond exactly HEADROOM_OK. Do not use tools or modify files.'
```

Expected: `HEADROOM_OK`, exit code 0, and proxy activity. `Not logged in` means the client started but no Anthropic request was tested. See [verification.md](verification.md).

## Rollback

From the affected project:

```powershell
headroom unwrap claude
```

Review the separately installed global MCP, Serena entries, and `.claude/settings.local.json`: do not remove unrelated hooks or servers. `unwrap` does not remove persistent user variables or uninstall the package.
