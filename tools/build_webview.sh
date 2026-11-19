#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_SRC="${CHROMIUM_SRC:-$ROOT/chromium/src}"
OUT_DIR="${OUT_DIR:-$CHROMIUM_SRC/out/A06WebCore}"
BUILD_FLAVOR="${BUILD_FLAVOR:-local-test}"
EXPECTED_REVISION="$(python3 - "$ROOT/project.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    print(json.load(f)["chromium_revision"])
PY
)"

if [[ ! -d "$CHROMIUM_SRC" || ! -f "$CHROMIUM_SRC/BUILD.gn" ]]; then
  echo "ERROR: Chromium source checkout not found: $CHROMIUM_SRC" >&2
  echo "Run tools/sync_chromium.sh on a prepared Linux build host." >&2
  exit 2
fi

command -v gn >/dev/null 2>&1 || { echo "ERROR: gn not found in PATH" >&2; exit 2; }
command -v autoninja >/dev/null 2>&1 || { echo "ERROR: autoninja not found in PATH" >&2; exit 2; }

ACTUAL_REVISION="$(git -C "$CHROMIUM_SRC" rev-parse HEAD)"
if [[ "$ACTUAL_REVISION" != "$EXPECTED_REVISION" ]]; then
  echo "ERROR: checkout is not the pinned Chromium revision." >&2
  echo "Expected: $EXPECTED_REVISION" >&2
  echo "Actual:   $ACTUAL_REVISION" >&2
  echo "Run tools/sync_chromium.sh before building." >&2
  exit 2
fi

gn_string() {
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"
}

case "$BUILD_FLAVOR" in
  local-test)
    PACKAGE_NAME="com.android.webview"
    OFFICIAL_BUILD=false
    EXTRA_ARGS=""
    ;;
  aosp-custom)
    PACKAGE_NAME="io.github.astromg01.a06webcore"
    OFFICIAL_BUILD=true
    : "${A06_WEBVIEW_KEYSTORE_PATH:?Set A06_WEBVIEW_KEYSTORE_PATH to a project-owned release keystore}"
    : "${A06_WEBVIEW_KEY_ALIAS:?Set A06_WEBVIEW_KEY_ALIAS}"
    : "${A06_WEBVIEW_KEY_PASSWORD:?Set A06_WEBVIEW_KEY_PASSWORD}"
    [[ -f "$A06_WEBVIEW_KEYSTORE_PATH" ]] || {
      echo "ERROR: release keystore not found." >&2
      exit 2
    }
    install -m 600 "$A06_WEBVIEW_KEYSTORE_PATH" "$CHROMIUM_SRC/a06-webcore-release.keystore"
    EXTRA_ARGS="disable_fieldtrial_testing_config = true
android_channel = \"stable\"
default_android_keystore_path = \"//a06-webcore-release.keystore\"
default_android_keystore_name = $(gn_string "$A06_WEBVIEW_KEY_ALIAS")
default_android_keystore_password = $(gn_string "$A06_WEBVIEW_KEY_PASSWORD")"
    ;;
  *)
    echo "ERROR: BUILD_FLAVOR must be local-test or aosp-custom" >&2
    exit 2
    ;;
esac

mkdir -p "$OUT_DIR"
ARGS_FILE="$OUT_DIR/args.gn"
cat > "$ARGS_FILE" <<GN
target_os = "android"
target_cpu = "arm64"
is_debug = false
is_component_build = false
is_official_build = $OFFICIAL_BUILD
is_chrome_branded = false
use_official_google_api_keys = false
system_webview_package_name = "$PACKAGE_NAME"
$EXTRA_ARGS
GN
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
echo "Chromium revision: $ACTUAL_REVISION"
if [[ "$BUILD_FLAVOR" == "aosp-custom" ]]; then
  echo "AOSP image integration and matching framework provider certificate are still required."
else
  echo "Local-test APK is intended for compatible AOSP userdebug/eng images, not stock Samsung retail firmware."
fi
