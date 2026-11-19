#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_SRC="${CHROMIUM_SRC:-$ROOT/chromium/src}"
WORKSPACE="$(dirname "$CHROMIUM_SRC")"
CHROMIUM_CHANNEL="${CHROMIUM_CHANNEL:-$(python3 - "$ROOT/project.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    print(json.load(f)["chromium_release_channel"])
PY
)}"

case "$CHROMIUM_CHANNEL" in
  stable|beta|dev|canary) ;;
  *)
    echo "ERROR: CHROMIUM_CHANNEL must be stable, beta, dev, or canary; got '$CHROMIUM_CHANNEL'." >&2
    exit 2
    ;;
esac

mapfile -t PIN < <(python3 - "$ROOT/project.json" "$CHROMIUM_CHANNEL" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)
pin = data.get("chromium_channels", {}).get(sys.argv[2])
if not pin:
    raise SystemExit(f"Missing Chromium pin for channel: {sys.argv[2]}")
print(pin["version"])
print(pin["revision"])
PY
)
if [[ "${#PIN[@]}" -ne 2 ]]; then
  echo "ERROR: could not resolve the pinned Chromium channel metadata." >&2
  exit 2
fi
CHROMIUM_VERSION="${PIN[0]}"
EXPECTED_REVISION="${PIN[1]}"

command -v fetch >/dev/null 2>&1 || {
  echo "ERROR: depot_tools 'fetch' is not in PATH." >&2
  echo "Install depot_tools using Chromium's official Android build guide." >&2
  exit 2
}
command -v gclient >/dev/null 2>&1 || {
  echo "ERROR: depot_tools 'gclient' is not in PATH." >&2
  exit 2
}
[[ "${#EXPECTED_REVISION}" -eq 40 ]] || {
  echo "ERROR: project.json does not contain a full Chromium commit SHA for $CHROMIUM_CHANNEL." >&2
  exit 2
}

mkdir -p "$WORKSPACE"
bash "$ROOT/tools/check_build_host.sh" "$WORKSPACE"
if [[ ! -f "$CHROMIUM_SRC/BUILD.gn" ]]; then
  if [[ -e "$CHROMIUM_SRC" ]]; then
    echo "ERROR: $CHROMIUM_SRC exists but is not a Chromium checkout." >&2
    exit 2
  fi
  (
    cd "$WORKSPACE"
    fetch --nohooks android
  )
fi

git -C "$CHROMIUM_SRC" fetch origin "$EXPECTED_REVISION"
(
  cd "$CHROMIUM_SRC"
  gclient sync -D --with_branch_heads --with_tags --revision="src@$EXPECTED_REVISION"
  gclient runhooks
)

ACTUAL_REVISION="$(git -C "$CHROMIUM_SRC" rev-parse HEAD)"
if [[ "$ACTUAL_REVISION" != "$EXPECTED_REVISION" ]]; then
  echo "ERROR: Chromium checkout does not match the pinned $CHROMIUM_CHANNEL revision." >&2
  echo "Expected: $EXPECTED_REVISION" >&2
  echo "Actual:   $ACTUAL_REVISION" >&2
  exit 1
fi

echo "Chromium source synchronized:"
echo "  Channel:   $CHROMIUM_CHANNEL"
echo "  Version:   $CHROMIUM_VERSION"
echo "  Revision:  $ACTUAL_REVISION"
