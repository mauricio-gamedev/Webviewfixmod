#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_SRC="${CHROMIUM_SRC:-$ROOT/chromium/src}"
OUT_DIR="${OUT_DIR:-$CHROMIUM_SRC/out/A06WebCore}"
BUILD_FLAVOR="${BUILD_FLAVOR:-local-test}"
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

if [[ ! -d "$CHROMIUM_SRC" || ! -f "$CHROMIUM_SRC/BUILD.gn" ]]; then
  echo "ERROR: Chromium source checkout not found: $CHROMIUM_SRC" >&2
  echo "Run bash tools/sync_chromium.sh on a prepared Linux build host." >&2
  exit 2
fi

bash "$ROOT/tools/check_build_host.sh" "$CHROMIUM_SRC"

command -v gn >/dev/null 2>&1 || { echo "ERROR: gn not found in PATH" >&2; exit 2; }
command -v autoninja >/dev/null 2>&1 || { echo "ERROR: autoninja not found in PATH" >&2; exit 2; }

ACTUAL_REVISION="$(git -C "$CHROMIUM_SRC" rev-parse HEAD)"
if [[ "$ACTUAL_REVISION" != "$EXPECTED_REVISION" ]]; then
  echo "ERROR: checkout is not the pinned Chromium $CHROMIUM_CHANNEL revision." >&2
  echo "Expected: $EXPECTED_REVISION" >&2
  echo "Actual:   $ACTUAL_REVISION" >&2
  echo "Run CHROMIUM_CHANNEL=$CHROMIUM_CHANNEL tools/sync_chromium.sh before building." >&2
  exit 2
fi

gn_string() {
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"
}

case "$BUILD_FLAVOR" in
  local-test)
    TEMPLATE="$ROOT/chromium/args/a06-arm64.gn"
    PACKAGE_NAME="com.android.webview"
    ;;
  aosp-custom)
    TEMPLATE="$ROOT/chromium/args/a06-arm64-aosp-custom.gn"
    PACKAGE_NAME="io.github.astromg01.a06webcore"
    : "${A06_WEBVIEW_KEYSTORE_PATH:?Set A06_WEBVIEW_KEYSTORE_PATH to a project-owned release keystore}"
    : "${A06_WEBVIEW_KEY_ALIAS:?Set A06_WEBVIEW_KEY_ALIAS}"
    : "${A06_WEBVIEW_KEY_PASSWORD:?Set A06_WEBVIEW_KEY_PASSWORD}"
    [[ -f "$A06_WEBVIEW_KEYSTORE_PATH" ]] || {
      echo "ERROR: release keystore not found." >&2
      exit 2
    }
    install -m 600 "$A06_WEBVIEW_KEYSTORE_PATH" "$CHROMIUM_SRC/a06-webcore-release.keystore"
    ;;
  *)
    echo "ERROR: BUILD_FLAVOR must be local-test or aosp-custom" >&2
    exit 2
    ;;
esac

[[ -f "$TEMPLATE" ]] || {
  echo "ERROR: GN template not found: $TEMPLATE" >&2
  exit 2
}

mkdir -p "$OUT_DIR"
ARGS_FILE="$OUT_DIR/args.gn"
install -m 600 "$TEMPLATE" "$ARGS_FILE"
{
  printf '\n# Selected upstream release channel; resolved from project.json.\\n'
  printf 'android_channel = %s\\n' "$(gn_string "$CHROMIUM_CHANNEL")"
} >> "$ARGS_FILE"

if [[ "$BUILD_FLAVOR" == "aosp-custom" ]]; then
  {
    printf '\n# Injected from environment; never commit this generated file.\\n'
    printf 'default_android_keystore_path = "//a06-webcore-release.keystore"\\n'
    printf 'default_android_keystore_name = %s\\n' "$(gn_string "$A06_WEBVIEW_KEY_ALIAS")"
    printf 'default_android_keystore_password = %s\\n' "$(gn_string "$A06_WEBVIEW_KEY_PASSWORD")"
  } >> "$ARGS_FILE"
fi
chmod 600 "$ARGS_FILE"

(
  cd "$CHROMIUM_SRC"
  gn gen "$OUT_DIR"
  autoninja -C "$OUT_DIR" system_webview_apk
)

APK="$OUT_DIR/apks/SystemWebView.apk"
if [[ ! -f "$APK" ]]; then
  APK="$(find "$OUT_DIR" -type f -name 'SystemWebView.apk' -print -quit)"
fi
if [[ -z "$APK" || ! -f "$APK" ]]; then
  echo "ERROR: build command returned but SystemWebView.apk was not found." >&2
  exit 1
fi

sha256sum "$APK"
echo "Build flavor: $BUILD_FLAVOR"
echo "Package: $PACKAGE_NAME"
echo "Chromium channel: $CHROMIUM_CHANNEL"
echo "Chromium version: $CHROMIUM_VERSION"
echo "Chromium revision: $ACTUAL_REVISION"
if [[ "$BUILD_FLAVOR" == "aosp-custom" ]]; then
  echo "AOSP image integration and matching framework provider certificate are still required."
else
  echo "Local-test APK is intended for compatible AOSP userdebug/eng images, not stock Samsung retail firmware."
fi
