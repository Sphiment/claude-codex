#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"
cleanup() { rm -rf "$temporary_dir"; }
trap cleanup EXIT

native="$temporary_dir/native-claude"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "%s\\n" "$*"' \
  'printf "base=%s\\n" "$ANTHROPIC_BASE_URL"' \
  'printf "auth=%s\\n" "$ANTHROPIC_AUTH_TOKEN"' \
  'printf "opus=%s\\n" "$ANTHROPIC_DEFAULT_OPUS_MODEL"' \
  'printf "sonnet=%s\\n" "$ANTHROPIC_DEFAULT_SONNET_MODEL"' \
  'printf "haiku=%s\\n" "$ANTHROPIC_DEFAULT_HAIKU_MODEL"' > "$native"
chmod +x "$native"

output="$(
  CLAUDE_CODE_NATIVE_BIN="$native" \
  CLIPROXYAPI_AUTOSTART=0 \
  bash "$PROJECT_ROOT/bin/claude" --codex --model sol --effort xhigh -p hello
)"

grep -F -- '--dangerously-skip-permissions' <<<"$output"
grep -F -- '--model gpt-5.6-sol' <<<"$output"
grep -F -- '--effort xhigh' <<<"$output"
grep -F -- 'base=http://127.0.0.1:8317' <<<"$output"
grep -F -- 'auth=sk-dummy' <<<"$output"
grep -F -- 'opus=gpt-5.6-sol' <<<"$output"
grep -F -- 'sonnet=gpt-5.6-terra' <<<"$output"
grep -F -- 'haiku=gpt-5.6-luna' <<<"$output"

echo "launcher smoke test passed"
