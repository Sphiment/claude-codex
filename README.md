# Claude Code + Codex

Run Claude Code through OpenAI Codex models using a local CLIProxyAPI sidecar.
The normal `claude` command keeps working; `claude --codex` opts into the
Codex route and automatically enables Claude Code's bypass-permissions mode.

## One-click install

On a machine that already has Claude Code installed:

```bash
curl -fsSL https://raw.githubusercontent.com/Sphiment/claude-codex/main/install.sh | bash
```

The installer clones this repository to
`~/.local/share/claude-codex`, downloads the matching CLIProxyAPI release,
and installs two user-local commands:

- `claude` — the wrapper; ordinary invocations delegate to your existing
  Claude Code binary.
- `claude-codex` — setup, login, and status helper commands.

The existing native Claude Code executable is preserved at
`~/.local/bin/claude-native`. The proxy binary and runtime log stay under the
ignored installation directory.

## First login

Authenticate the Codex OAuth provider once:

```bash
claude-codex login
```

On a headless machine, use `claude-codex login --no-browser` and open the
printed URL on a machine with a browser. CLIProxyAPI's Codex OAuth callback
uses port `1455` by default.

## Usage

```bash
# Defaults to GPT-5.6 Terra with medium effort
claude --codex

# Explicit model and Claude Code effort
claude --codex --model sol --effort high
claude --codex --model terra --effort medium
claude --codex --model luna --effort low
```

Model aliases map as follows:

| Claude Code slot | Model ID |
| --- | --- |
| `opus`, `sol` | `gpt-5.6-sol` |
| `sonnet`, `terra` | `gpt-5.6-terra` |
| `haiku`, `luna` | `gpt-5.6-luna` |

The wrapper passes `--effort` directly to Claude Code. Supported levels are
determined by the installed Claude Code version; current versions expose
`low`, `medium`, `high`, `xhigh`, and `max`.

## Check the setup

```bash
claude-codex status
claude --version
```

`claude-codex status` checks the local authenticated `/v1/models` endpoint.
An empty model list before login is expected.

## Configuration overrides

The defaults are intentionally local-only:

- proxy URL: `http://127.0.0.1:8317`
- client key: `sk-dummy`
- config: `config/cliproxyapi.yaml`
- auth directory: `~/.cli-proxy-api`

Override paths or the URL for advanced setups with `CLIPROXYAPI_URL`,
`CLIPROXYAPI_CONFIG`, `CLIPROXYAPI_BIN`, `CLIPROXYAPI_HOME`, or
`CLIPROXYAPI_CLIENT_KEY`.

## Safety

`claude --codex` deliberately adds `--dangerously-skip-permissions`. Use it
only in a trusted, isolated workspace. Run plain `claude` when you want the
native permission prompts.

## Development

This repository has no runtime dependency on Node or Python. Run the shell
smoke test with:

```bash
bash tests/test-launcher.sh
```

The GitHub repository is public so the one-click installer works without a
GitHub token. Do not commit OAuth credentials or proxy runtime files.
