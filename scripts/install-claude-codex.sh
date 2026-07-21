#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${CLAUDE_BIN_DIR:-${HOME:?HOME is required}/.local/bin}"
TARGET="$TARGET_DIR/claude"
NATIVE="$TARGET_DIR/claude-native"
WRAPPER="$PROJECT_ROOT/bin/claude"
UTILITY="$TARGET_DIR/claude-codex"
UTILITY_SOURCE="$PROJECT_ROOT/bin/claude-codex"

canonical_path() {
  readlink -f "$1" 2>/dev/null || printf '%s\n' "$1"
}

if [[ ! -x "$WRAPPER" ]]; then
  echo "Launcher is missing or not executable: $WRAPPER" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

target_installed=0
if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  if [[ "$(canonical_path "$TARGET")" == "$(canonical_path "$WRAPPER")" ]]; then
    echo "Claude Code wrapper is already installed at $TARGET"
    target_installed=1
  fi
  if ((target_installed == 0)) && [[ -e "$NATIVE" || -L "$NATIVE" ]]; then
    echo "Refusing to replace $TARGET because $NATIVE already exists." >&2
    echo "Move the existing wrapper aside manually if you want to reinstall." >&2
    exit 1
  fi
  if ((target_installed == 0)); then
    mv "$TARGET" "$NATIVE"
    echo "Preserved the native Claude Code command at $NATIVE"
  fi
fi

if ((target_installed == 0)); then
  ln -s "$WRAPPER" "$TARGET"
  echo "Installed claude wrapper at $TARGET"
fi
if [[ -e "$UTILITY" || -L "$UTILITY" ]]; then
  if [[ "$(canonical_path "$UTILITY")" != "$(canonical_path "$UTILITY_SOURCE")" ]]; then
    echo "Refusing to replace existing command: $UTILITY" >&2
    exit 1
  fi
else
  ln -s "$UTILITY_SOURCE" "$UTILITY"
fi
echo "Installed helper command at $UTILITY"
echo "Use: claude --codex [--model sol|terra|luna] [--effort low|medium|high|xhigh|max]"
