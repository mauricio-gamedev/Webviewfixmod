#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_SRC="${CHROMIUM_SRC:-$ROOT/chromium/src}"
OUT_DIR="${OUT_DIR:-$CHROMIUM_SRC/out/A06WebCore}"
BUILD_FLAVOR="${BUILD_FLAVOR:-local-test}"

if [[ ! -d "$CHROMIUM_SRC" || ! -f "$CHROMIUM_SRC/BUILD.gn" ]]; then
  echo "ERROR: Chromium source checkout not found: $CHROMIUM_SRC" >&2
  echo "Follow docs/build.md to fetch Chromium; source is not vendored here." >&2
  exit 2
fi

command -v gn >/dev/null 2>&1 || { echo "ERROR: gn not found in PATH" >&2; exit 2; }
command -v autoninja >/dev/null 2>&1 || { echo "ERROR: autoninja not found in PATH" >&2; exit 2; }

case "$BUILD_FLAVOR" in
  local-test)
    PACKAGE_NAME="com.android.webview"
    ;;
  aosp-custom)
    PACKAGE_NAME="io.github.astromg01.a06webcore"
    ;;
  *)
    echo "ERROR: BUILD_FLAVOR must be local-test or aosp-custom" >&2
    exit 2
    ;;
esac

mkdir -p "$OUT_DIR"
cat > "$OUT_DIR/args.gn" <<GN
target_os = "android"
target_cpu = "arm64"
is_debug = false
is_component_build = false
is_official_build = false
is_chrome_branded = false
use_official_google_api_keys = false
system_webview_package_name = "$PACKAGE_NAME"
GN

(
  cd "$CHROMIUM_SRC"
  gn gen "$OUT_DIR"
  autoninja -C "$OUT_DIR" system_webview_apk
)

echo "Build finished. Check output and preserve build logs and APK SHA-256."
echo "Flavor: $BUILD_FLAVOR; package: $PACKAGE_NAME"
if [[ "$BUILD_FLAVOR" == "aosp-custom" ]]; then
  echo "AOSP system image integration and matching project-controlled release certificate are still required."
else
  echo "Local-test flavor is for compatible AOSP userdebug/eng test images, not stock Samsung production firmware."
fi
