#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$PROJECT_ROOT/scripts/setup-cliproxyapi.sh"
bash "$PROJECT_ROOT/scripts/install-claude-codex.sh"

echo
echo "Next step: claude-codex login"
