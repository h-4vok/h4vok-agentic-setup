# Troubleshooting

Cases observed with Headroom 0.39.1 on Windows. For later versions, check `--help` and installed files before reusing a workaround.

## uv/headroom is missing from this terminal

Installation changes persistent PATH, not existing processes. Open another terminal or add the directory from `uv tool dir --bin` to the process PATH. On this PC it is `~/.local/bin`; use the actual result on each machine. Restart Codex/Claude as well if already open.

## MCP help says only Claude is supported

The `headroom mcp install --help` text in 0.39.1 lags behind implementation: `--agent codex` works. Explicit registration of both clients was tested. Use `headroom mcp install --agent claude --agent codex` and inspect the results.

That version's `headroom mcp uninstall` has **no agent selector** and visits every known registrar. Review `--help` and scope before running it if other clients are configured. For selective removal, use each client's native commands and verify configuration afterwards.

## Existing MCP mismatch / lost Codex markers

Headroom compares paths, arguments, and environment. Even `.exe` versus `.EXE`, or adding `HEADROOM_BEACON` to the entry's environment, can produce `existing config differs`. Do not blindly use `--force`: Headroom deliberately preserves entries it considers user-managed.

During this installation, a temporary `codex mcp add` alternative worked, but `codex mcp remove` reserialized TOML and lost ownership comments. Afterwards, `--code-memory none` reported `Serena MCP: removal failed` while Serena remained registered.

Applied fix: after confirming **headroom and serena were added during this installation**, only those two entries were removed with native commands, then `headroom wrap codex -- --version` was run again. Headroom recreated both entries and their markers. Do not repeat this if Serena is a pre-existing user integration. Record and preserve customizations before migrating them.

CLI reserialization also omitted explicit fields from other MCP entries (empty `args` and default-valued `enabled`). Only those fields were restored from the backup using `tomlkit`, without replacing the entire file. Final semantic comparison confirmed all previous MCP entries and non-MCP keys retained their values. Future installations therefore use Headroom's registrar directly.

To disable a Headroom-installed Serena entry that the wrapper cannot remove, inspect `codex mcp get serena` and use `codex mcp remove serena` only after confirming its origin. This can also remove comments from other blocks, so inspect TOML afterwards.

## Claude returns Not logged in

`claude auth status` may report `loggedIn: false` even if another client or app is authenticated. Run `claude auth login` or `/login` in Claude Code, complete the flow as the user, and repeat the real request. `wrap ... --version` establishes startup only, not authentication or Anthropic traffic.

## doctor reports warnings

With a healthy proxy, exit code 1 can indicate missing **global** routing, no data, no budget, or deferred Kompress. Wrappers configure their process; permanently setting `OPENAI_BASE_URL`/`ANTHROPIC_BASE_URL` is unnecessary to hide these warnings. Preserve normal routing for unwrapped sessions.

During testing, `/health` returned `healthy`, `ready=true`, and a loaded Rust core; `/debug/warmup` showed `smart_crusher=loaded`, `code_aware=loaded`, `tree_sitter=loaded`, and `kompress.info.source_status=deferred`. Kompress's ML path was not tested: do not declare it operational merely because `[all]` was installed. If it still fails to load when a text workload needs it, inspect warmup and local logs, and document model downloads/errors before changing flags.

## doctor --network does not exist

Version 0.39.1 supports only `--port` and `--json`. Do not copy that flag from an external guide. For connectivity diagnostics:

```powershell
headroom doctor --json
Test-NetConnection api.anthropic.com -Port 443
Test-NetConnection api.openai.com -Port 443
```

A port check does not establish TLS trust. For certificate errors on a corporate network, follow its authorized CA configuration and the relevant transport documentation; do not disable TLS verification. No certificate workaround was needed on this PC.

## output-savings recommends beta despite enabled shaping

The no-data message in 0.39.1 contains an outdated beta-channel recommendation. The implementation accepts `HEADROOM_OUTPUT_SHAPER=1` on stable. Check `headroom rollout status` and effective `/health` values; do not enable other beta features just because of that message.

## Disabling does not change a shared proxy

Removing a variable does not necessarily clear an override already received by the proxy. Use `HEADROOM_OUTPUT_SHAPER=0` and run `wrap` again; for holdout use `HEADROOM_OUTPUT_HOLDOUT=0`. A 0-to-1 shaping change was verified in the same proxy process.

## Magika/ONNX warning on Windows

The MCP test reported use of the Python detector because the native Magika/ONNX backend is unsafe by default on Windows. That fallback was retained; compression and retrieval passed. Do not enable `HEADROOM_DETECT_BACKEND=rust` merely to hide the warning.

## Logs and generated files

Headroom warns that Unix file modes do not establish Windows ACLs for logs. This setup does not enable full message logging. Keep logs and backups in the local profile and review ACLs if sharing that directory. Do not copy complete configurations, tokens, or histories into the repository.

`wrap claude` generated `.claude/settings.local.json` with hooks and a lock in this project. Git ignores them; Headroom configures them during each installation. Serena and `.headroom/` are also ignored local state. Do not treat these generated files as portable templates.
