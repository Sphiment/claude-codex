#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="${CLIPROXYAPI_HOME:-$PROJECT_ROOT/.cliproxyapi}"
BIN_DIR="$INSTALL_DIR/bin"
INSTALL_PATH="$BIN_DIR/cli-proxy-api"
REPOSITORY="${CLIPROXYAPI_REPOSITORY:-router-for-me/CLIProxyAPI}"
VERSION="${CLIPROXYAPI_VERSION:-latest}"

for command_name in curl tar install; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 127
  fi
done

case "$(uname -s)" in
  Linux) release_os="linux" ;;
  Darwin) release_os="darwin" ;;
  *) echo "Unsupported operating system: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) release_arch="amd64"; release_arch_regex="amd64|x86_64" ;;
  aarch64|arm64) release_arch="arm64"; release_arch_regex="arm64|aarch64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

if [[ "$VERSION" == "latest" ]]; then
  release_url="https://api.github.com/repos/$REPOSITORY/releases/latest"
else
  release_url="https://api.github.com/repos/$REPOSITORY/releases/tags/$VERSION"
fi

release_json="$(curl -fsSL --retry 2 "$release_url")"
if command -v jq >/dev/null 2>&1; then
  asset_url="$(printf '%s' "$release_json" | jq -r --arg os "$release_os" --arg arch "$release_arch_regex" '
    .assets[]
    | select((.name | ascii_downcase | contains($os)))
    | select((.name | ascii_downcase | test($arch)))
    | select((.name | ascii_downcase | test("sha256|checksum|\\.sig|\\.txt$")) | not)
    | .browser_download_url
  ' | head -n 1)"
elif command -v python3 >/dev/null 2>&1; then
  asset_url="$(printf '%s' "$release_json" | python3 -c '
import json, re, sys
os_name, arch_pattern = sys.argv[1].lower(), re.compile(sys.argv[2], re.I)
for asset in json.load(sys.stdin).get("assets", []):
    name = asset.get("name", "").lower()
    if os_name in name and arch_pattern.search(name) and not re.search(r"sha256|checksum|\.sig|\.txt$", name):
        print(asset.get("browser_download_url", ""))
        break
' "$release_os" "$release_arch_regex")"
else
  if [[ "$VERSION" == "latest" ]]; then
    latest_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/$REPOSITORY/releases/latest")"
    release_tag="${latest_url##*/}"
  else
    release_tag="$VERSION"
  fi
  release_tag="${release_tag#v}"
  asset_url="https://github.com/$REPOSITORY/releases/download/v$release_tag/CLIProxyAPI_${release_tag}_${release_os}_${release_arch}.tar.gz"
  echo "Using the standard release asset path because jq/python3 is unavailable."
fi

if [[ -z "$asset_url" || "$asset_url" == "null" ]]; then
  echo "Could not find a $release_os/$(uname -m) CLIProxyAPI release asset." >&2
  echo "Inspect available assets with: $release_url" >&2
  exit 1
fi

temporary_dir="$(mktemp -d)"
cleanup() { rm -rf "$temporary_dir"; }
trap cleanup EXIT

archive_path="$temporary_dir/asset"
echo "Downloading CLIProxyAPI from $asset_url"
curl -fL --retry 2 "$asset_url" -o "$archive_path"

source_binary="$archive_path"
asset_name="${asset_url##*/}"
if [[ "$asset_name" == *.tar.gz || "$asset_name" == *.tgz ]]; then
  extract_dir="$temporary_dir/extracted"
  mkdir -p "$extract_dir"
  tar -xzf "$archive_path" -C "$extract_dir"
  source_binary="$(find "$extract_dir" -type f \( -name 'cli-proxy-api' -o -name 'cliproxyapi' \) -print -quit)"
  if [[ -z "$source_binary" ]]; then
    source_binary="$(find "$extract_dir" -type f -perm -u+x -print -quit)"
  fi
fi

if [[ ! -f "$source_binary" ]]; then
  echo "The downloaded release did not contain a CLIProxyAPI executable." >&2
  exit 1
fi

mkdir -p "$BIN_DIR"
install -m 0755 "$source_binary" "$INSTALL_PATH"
echo "Installed CLIProxyAPI at $INSTALL_PATH"
echo "Config: $PROJECT_ROOT/config/cliproxyapi.yaml"
