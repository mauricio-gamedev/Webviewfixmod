#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v gradle >/dev/null 2>&1 || {
  echo "ERROR: Gradle 9.6.0 is required. Install it or use the GitHub Actions workflow." >&2
  exit 2
}
command -v java >/dev/null 2>&1 || {
  echo "ERROR: JDK 17 is required." >&2
  exit 2
}

GRADLE_VERSION="$(gradle --version | awk '/^Gradle / {print $2; exit}')"
if [[ "$GRADLE_VERSION" != "9.6.0" ]]; then
  echo "ERROR: expected Gradle 9.6.0, found $GRADLE_VERSION." >&2
  exit 2
fi

JAVA_VERSION="$(java -version 2>&1 | awk -F '"' '/version/ {print $2; exit}')"
if [[ "$JAVA_VERSION" != 17* ]]; then
  echo "ERROR: expected JDK 17, found $JAVA_VERSION." >&2
  exit 2
fi

if [[ -z "${ANDROID_HOME:-}${ANDROID_SDK_ROOT:-}" ]]; then
  echo "ERROR: Android SDK location not configured." >&2
  exit 2
fi

gradle --no-daemon --stacktrace :app:assembleDebug :app:lintDebug
APK="$ROOT/app/build/outputs/apk/debug/app-debug.apk"
[[ -f "$APK" ]] || { echo "ERROR: APK was not produced." >&2; exit 1; }
sha256sum "$APK"
echo "APK: $APK"
