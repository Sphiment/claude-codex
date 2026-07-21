#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROXY_BINARY="${CLIPROXYAPI_BIN:-$PROJECT_ROOT/.cliproxyapi/bin/cli-proxy-api}"
PROXY_CONFIG="${CLIPROXYAPI_CONFIG:-$PROJECT_ROOT/config/cliproxyapi.yaml}"

if [[ ! -x "$PROXY_BINARY" ]]; then
  echo "CLIProxyAPI is not installed at $PROXY_BINARY." >&2
  echo "Run: bash $PROJECT_ROOT/scripts/setup-cliproxyapi.sh" >&2
  exit 127
fi

exec "$PROXY_BINARY" --config "$PROXY_CONFIG" --codex-login "$@"
