#!/usr/bin/env bash
set -euo pipefail

command -v adb >/dev/null 2>&1 || { echo "ERROR: adb not found" >&2; exit 2; }
[[ "$(adb get-state 2>/dev/null || true)" == "device" ]] || {
  echo "ERROR: no authorized Android device" >&2
  exit 2
}

OUT_DIR="${1:-device-baseline}"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/$(date -u +%Y%m%dT%H%M%SZ)-baseline.txt"
{
  echo "# A06 WebCore device baseline"
  echo "# Review before publishing; build properties may identify device/firmware."
  for key in ro.product.manufacturer ro.product.model ro.build.version.release ro.build.version.sdk ro.build.version.security_patch ro.build.fingerprint ro.product.cpu.abi; do
    printf '%s=' "$key"
    adb shell getprop "$key" | tr -d '\r'
  done
  echo
  echo "## WebView provider service"
  adb shell dumpsys webviewupdate 2>&1 | tr -d '\r' || true
} > "$REPORT"
echo "Wrote $REPORT"
