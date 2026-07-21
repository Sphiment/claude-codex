#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_URL="${CLAUDE_CODEX_REPOSITORY_URL:-https://github.com/Sphiment/claude-codex.git}"
INSTALL_ROOT="${CLAUDE_CODEX_HOME:-${HOME:?HOME is required}/.local/share/claude-codex}"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required. Install Git, then rerun this command." >&2
  exit 127
fi

if [[ -e "$INSTALL_ROOT" && ! -d "$INSTALL_ROOT/.git" ]]; then
  echo "Refusing to overwrite existing non-repository directory: $INSTALL_ROOT" >&2
  exit 1
fi

if [[ -d "$INSTALL_ROOT/.git" ]]; then
  git -C "$INSTALL_ROOT" pull --ff-only
else
  mkdir -p "$(dirname "$INSTALL_ROOT")"
  git clone --depth 1 "$REPOSITORY_URL" "$INSTALL_ROOT"
fi

bash "$INSTALL_ROOT/scripts/setup-claude-codex.sh"
