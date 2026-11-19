#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_SRC="${CHROMIUM_SRC:-$ROOT/chromium/src}"
WORKSPACE="$(dirname "$CHROMIUM_SRC")"
EXPECTED_REVISION="$(python3 - "$ROOT/project.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    print(json.load(f)["chromium_revision"])
PY
)"

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
  echo "ERROR: project.json does not contain a full Chromium commit SHA." >&2
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
  echo "ERROR: Chromium checkout does not match the pinned revision." >&2
  echo "Expected: $EXPECTED_REVISION" >&2
  echo "Actual:   $ACTUAL_REVISION" >&2
  exit 1
fi

echo "Chromium source synchronized to $ACTUAL_REVISION"
